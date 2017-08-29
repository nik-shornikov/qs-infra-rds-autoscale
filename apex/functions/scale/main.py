#! /usr/bin/env python3

import json
import re
import boto3
import os

from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError


def notif(message, webhook):
    slack_message = {
        'channel': 'systemsmonitoring',
        'text': message,
        'username': 'inventory db read scaling',
        'icon_emoji': ':aws:'
    }

    req = Request(webhook, json.dumps(slack_message).encode('utf8'))

    try:
        response = urlopen(req)
        response.read()
        print("Message posted to %s", slack_message['channel'])
    except HTTPError as e:
        print("Request failed: %d %s", e.code, e.reason)
    except URLError as e:
        print("Server connection failed: %s", e.reason)

    return True


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

        webhook = os.getenv('webhook', '')

        no_notif = False

        if webhook == '':
            print("webhook is empty -- there will be no slack notification")
            no_notif = True
        else:
            print("slack notification will be issued")

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

        cluster_dimension = [x for x in message['Trigger']['Dimensions'] if x['name'] == 'DBClusterIdentifier']

        if not cluster_dimension or 'value' not in cluster_dimension[0]:
            print('could not find cluster name')
            return False

        cluster = cluster_dimension[0]['value']

        if cluster != os.getenv('cluster'):
            print('received alarm for wrong cluster')
            return False

        report = "%s will result in read replica %s being brought %s in %s" % (alarm, identifier, action, cluster)

        print(report)

        client = boto3.client('rds', region_name=region)

        cluster_members = client.describe_db_clusters(DBClusterIdentifier=cluster)['DBClusters'][0]['DBClusterMembers']

        source_instance = cluster_members[0]['DBInstanceIdentifier']

        print("%s will serve as source instance" % source_instance)

        full_identifier = (cluster + "-" + identifier)

        el = [x for x in cluster_members if x['DBInstanceIdentifier'] == full_identifier]

        if action == 'down':
            print("looking to bring down read replica")
            if el:
                print("found %s to bring down" % full_identifier)
                if not dry_run:
                    print("not in dry run mode -- bringing instance down")
                    response = client.delete_db_instance(
                        DBInstanceIdentifier=full_identifier,
                        SkipFinalSnapshot=True
                    )
                    print(response)
                    if not no_notif:
                        notif(report, webhook)
                else:
                    print("dry run mode -- not bringing instance down")
            else:
                print("found no %s to bring down" % full_identifier)

        elif action == 'up':
            print("looking to bring up read replica")
            if not el:
                print("found no instance %s already up" % full_identifier)
                if not dry_run:
                    print("not in dry run mode -- bringing instance up")
                    response = client.create_db_instance(
                        DBInstanceIdentifier=full_identifier,
                        DBInstanceClass='db.t2.small',
                        Engine='aurora',
                        AutoMinorVersionUpgrade=True,
                        PubliclyAccessible=True,
                        Tags=[
                            {
                                'Key': 'reporter',
                                'Value': 'Nikolai Shornikov'
                            }
                        ],
                        DBClusterIdentifier=cluster,
                        PromotionTier=2
                    )
                    print(response)
                    if not no_notif:
                        notif(report, webhook)
                else:
                    print("dry run mode -- not bringing instance up")
            else:
                print("found %s up already" % full_identifier)

    return True
