import json
import boto3
import requests
import os
from datetime import datetime

s3 = boto3.client('s3')

def lambda_handler(event, context):
    # Get environment variables
    raw_bucket = os.environ.get('RAW_BUCKET')

    # Endpoint to fetch data
    url = "https://jsonplaceholder.typicode.com/users"

    try:
        # Fetch data from the mock API
        response = requests.get(url)
        response.raise_for_status()  # Raise exception if not 200 OK
        users_data = response.json()

        # Convert data to JSON string
        json_data = json.dumps(users_data)

        # Create a timestamped filename
        file_name = f"users_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"

        # Upload to S3
        s3.put_object(
            Bucket=raw_bucket,
            Key=file_name,
            Body=json_data,
            ContentType='application/json'
        )

        return {
            'statusCode': 200,
            'body': json.dumps(f"File {file_name} uploaded successfully to {raw_bucket}")
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(str(e))
        }
