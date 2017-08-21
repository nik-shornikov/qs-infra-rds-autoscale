import json

def handle(event, context):
  for record in event['Records']:
    print("processing event")
    message = json.loads(record['Sns']['Message'])
    print(message["AlarmName"])
  return True
