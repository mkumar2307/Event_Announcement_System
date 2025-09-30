import json
import boto3
import os

# AWS clients
sns_client = boto3.client('sns')
dynamodb_client = boto3.client('dynamodb')

# Environment variables
TOPIC_ARN = os.environ['SNS_TOPIC_ARN']
TABLE_NAME = os.environ.get('DYNAMODB_TABLE', '')

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        event_name = body['name']
        event_date = body['date']
        event_desc = body.get('description', '')

        # Store in DynamoDB
        if TABLE_NAME:
            dynamodb_client.put_item(
                TableName=TABLE_NAME,
                Item={
                    'event_id': {'S': event_name + '-' + event_date},
                    'name': {'S': event_name},
                    'date': {'S': event_date},
                    'description': {'S': event_desc}
                }
            )

        # Publish to SNS
        message = f"New Event: {event_name} on {event_date}. Details: {event_desc}"
        sns_client.publish(
            TopicArn=TOPIC_ARN,
            Message=message,
            Subject='New Event Announcement'
        )

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Event announced successfully!'})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
