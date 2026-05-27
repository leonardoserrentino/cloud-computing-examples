import json
import csv
import urllib.parse
import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    """
    Triggered by S3 ObjectCreated event.
    Reads a CSV file from the source bucket, converts it to JSON, 
    and writes it to the destination bucket.
    """
    # Get the destination bucket from environment variables
    destination_bucket = os.environ['DESTINATION_BUCKET']
    
    # Extract the source bucket name and the object key from the event
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    object_key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    
    logger.info(f"Processing file {object_key} from bucket {source_bucket}")
    
    try:
        # Read the CSV file from S3
        response = s3_client.get_object(Bucket=source_bucket, Key=object_key)
        csv_content = response['Body'].read().decode('utf-8').splitlines()
        
        # Convert CSV to JSON
        reader = csv.DictReader(csv_content)
        parsed_data = [row for row in reader]
        
        json_data = json.dumps(parsed_data, indent=2)
        
        # Define the new key (replace .csv with .json)
        new_object_key = object_key.replace('.csv', '.json')
        
        # Upload the JSON data to the destination bucket
        s3_client.put_object(
            Bucket=destination_bucket,
            Key=new_object_key,
            Body=json_data,
            ContentType='application/json'
        )
        
        logger.info(f"Successfully converted and saved to {destination_bucket}/{new_object_key}")
        return {
            'statusCode': 200,
            'body': json.dumps('Data processing successful!')
        }
        
    except Exception as e:
        logger.error(f"Error processing object {object_key} from bucket {source_bucket}. Error: {str(e)}")
        raise e
