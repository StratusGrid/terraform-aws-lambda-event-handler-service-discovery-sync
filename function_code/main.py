# Import libraries
import boto3
import re
import os

# uncomment to enable boto3 debugging
# boto3.set_stream_logger('')

# uncomment to override settings, also need to add , config=boto_override to clients
# from botocore.config import Config
# boto_override = Config(
#     region_name = 'us-west-2',
#     signature_version = 'v4',
#     retries = {
#         'max_attempts': 5,
#         'mode': 'standard'
#     }
# )

# Initialize boto3 clients (since this is outside of the handler function, it will only be done once per container)
servicediscovery = boto3.client('servicediscovery')

# function to register something in service discovery
def register_instance(instanceId, serviceId, ip):
  print('registering ', instanceId, ' at ', ip, ' in ', serviceId)
  try:
    response = servicediscovery.register_instance(
      ServiceId=serviceId,
      InstanceId=instanceId,
      CreatorRequestId=instanceId,
      Attributes={
        'AWS_INSTANCE_IPV4': ip
      }
    )
    print(response)
    return response
  except Exception as e:
    print(e)
    print('Failed to register ', instanceId, ' at ', ip, ' in ', serviceId)
    return e

# function to deregister something in service discovery
def deregister_instance(instanceId, serviceId):
  print('deregistering ', instanceId, ' in ', serviceId)
  try:
    response = servicediscovery.deregister_instance(
      ServiceId=serviceId,
      InstanceId=instanceId
    )
    print(response)
    return response
  except Exception as e:
    print(e)
    print('Failed to deregister ', instanceId, ' in ', serviceId)
    return e


### Entry point for lambda ###
def handler(event, context):
  print(event)
  print(context)

  # if event is for a matching task definition, keep going
  if  re.search(os.environ['task_definition_matcher'] ,event['detail']['taskDefinitionArn']):
    print('Matches ', os.environ['task_definition_matcher'])

    # get task ID (first group match with match of all \w characters after last slash)
    instanceId = re.match('.*/(\w*)$', event.get('detail').get('taskArn'))[1]

    # get all details of all attachments till you find the private ip
    for attachment in event.get('detail', {}).get('attachments'):
      for detail in attachment.get('details'):
        if detail.get('name') == 'privateIPv4Address':
          private_ipv4_address = detail.get('value')

    # if task is now running, register it
    if event['detail']['lastStatus'] == 'RUNNING':
      try:
        return register_instance(instanceId, os.environ['service_id'], private_ipv4_address)
      except Exception as e:
        return e

    # if task is now stopped, then deregister it
    if event['detail']['lastStatus'] == 'STOPPED':
      try:
        return deregister_instance(instanceId, os.environ['service_id'])
      except Exception as e:
        return e

  # else if event doesn't match task definition, just print and exit
  else:
    print('Not matching ', os.environ['task_definition_matcher'])
