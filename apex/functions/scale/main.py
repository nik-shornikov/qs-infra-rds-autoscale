import json
import re
import boto3
import os


def handle(event, context):
    if 'Records' not in event:
        print("could not parse records")

    for record in event['Records']:
        if 'Sns' not in record or 'Message' not in record['Sns']:
            print("could not parse sns message")
            return False

        message = json.loads(record['Sns']['Message'])

        if 'AlarmName' not in message:
            print("could not parse cloudwatch message")
            return False

        alarm = message["AlarmName"]

        x = re.compile('.*(up|down)-(.+)$')
        m = x.match(alarm)

        if m is None or len(m.groups()) < 2 or m.group(1) not in ('up', 'down'):
            print("could not parse the intended alarm actions")
            return False

        action = m.group(1)
        identifier = m.group(2)

        if 'NewStateValue' not in message or 'OldStateValue' not in message:
            print("could not parse cloudwatch alarm state")
            return False

        state = message["NewStateValue"]
        old_state = message["OldStateValue"]
        dry_run = False

        if state != "ALARM" or old_state != "OK":
            print("alarm did not transition from OK to ALARM -- performing dry run")
            dry_run = True

        if 'TopicArn' not in record['Sns']:
            print("could not parse topic arn")
            return False

        topic = record['Sns']['TopicArn']

        xr = re.compile('^arn:aws:sns:([^:]+)')
        r = xr.match(topic)

        if r is None or len(r.groups()) < 1:
            print("could not parse the region")
            return False

        region = r.group(1)

        if region != os.getenv('region'):
            print('received alarm for wrong region')
            return False

        if 'Trigger' not in message or 'Dimensions' not in message['Trigger']:
            print("could not parse alarm metric dimensions")
            return False

        if message['Trigger']['Dimensions'][1]['name'] != 'DBClusterIdentifier':
            print('could not find cluster name')
            return False

        cluster = message['Trigger']['Dimensions'][1]['value']

        if cluster != os.getenv('cluster'):
            print('received alarm for wrong cluster')
            return False

        print("%s will result in read replica %s being brought %s in %s" % (alarm, identifier, action, cluster))

        client = boto3.client('rds', region_name=region)

        cluster_members = client.describe_db_clusters(DBClusterIdentifier=cluster)['DBClusters'][0]['DBClusterMembers']

        el = [x for x in cluster_members if x['DBInstanceIdentifier'] == (cluster + "-" + identifier)]

        if action == 'down':
            print("looking to bring down read replica")
            if el:
                print("found %s to bring down" % (cluster + "-" + identifier))
                if not dry_run:
                    print("not in dry run mode -- bringing instance down")
                else:
                    print("dry run mode -- not bringing instance down")
        elif action == 'up':
            print("looking to bring up read replica")
            if not el:
                print("found no instance %s already up" % (cluster + "-" + identifier))
                if not dry_run:
                    print("not in dry run mode -- bringing instance up")
                else:
                    print("dry run mode -- not bringing instance up")
            else:
                print("found %s up already" % (cluster + "-" + identifier))

    return True
