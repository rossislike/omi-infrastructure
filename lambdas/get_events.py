import json 
import boto3
from boto3.dynamodb.conditions import Key
from datetime import datetime, timedelta

tablename = os.environ['TABLE_NAME']
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    table = dynamodb.Table(tablename)
    now = datetime.now()
    # Get current and next month in 'YYYY-MM' format
    current_month = now.strftime('%Y-%m')
    # Calculate next month
    if now.month == 12:
        next_month = f"{now.year + 1}-01"
    else:
        next_month = f"{now.year}-{now.month + 1:02d}"
    
    items = []
    for month in [current_month, next_month]:
        pk = f"EVENTS#{month}"
        response = table.query(
            KeyConditionExpression=Key('PK').eq(pk)
        )
        items.extend(response.get('Items', []))

    return {
        'statusCode': 200,
        'body': json.dumps(items)
    }
