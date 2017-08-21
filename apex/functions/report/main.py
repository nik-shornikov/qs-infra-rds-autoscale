import json

def handle(event, context):
  print("processing event")
  message = json.loads(event['Records'][0]['Sns']['Message'])
  return message["AlarmName"]
