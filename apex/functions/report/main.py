def handle(event, context):
  print("processing event")
  return event['Records'][0]['Sns']["Message"]
