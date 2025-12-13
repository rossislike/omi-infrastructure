import boto3
import os

bucket_name = os.environ['BUCKET_NAME']

def lambda_handler(event, context):
    key = event['pathParameters']['id']

    s3 = boto3.client('s3')

    signed_url = s3.generate_presigned_url(
        'get_object', 
        Params={
            'Bucket':bucket_name,
            'Key': f'photos/{key}'
        },
        ExpiresIn=3600
    )
    
    return {
        'statusCode': 200,
        'body': signed_url
    }