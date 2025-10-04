import json
from ksuid import Ksuid

def lambda_handler(event, context):
    try:
        # Generate a new KSUID
        ksuid = Ksuid()

        # Get different representations of the KSUID
        result = {
            'string': str(ksuid),
            'timestamp': ksuid.timestamp,
            'payload': ksuid.payload.hex()
        }
        print(f'bytes: {bytes(ksuid)}')

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Success',
                'ksuid': result
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': str(e)
            })
        }