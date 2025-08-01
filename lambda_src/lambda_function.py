import json
import random
import string
import boto3
import os
from datetime import datetime, timedelta

def lambda_handler(event, context):
    """
    Lambda function to generate clickstream data
    """
    # Initialize AWS clients
    s3 = boto3.client('s3')
    ssm = boto3.client('ssm')
    
    # Get bucket name from environment or SSM
    bucket_name = os.environ.get('S3_BUCKET_NAME')
    if not bucket_name:
        ssm_param = os.environ.get('SSM_PARAMETER', 'clickstream_bucket')
        response = ssm.get_parameter(Name=ssm_param)
        bucket_name = response['Parameter']['Value']
    
    # Configuration - get from environment variable
    events_per_execution = int(os.environ.get('EVENTS_PER_EXECUTION', 20))
    
    # Generate and upload events
    events_generated = 0
    for _ in range(events_per_execution):
        event_data = generate_event()
        upload_event_to_s3(s3, bucket_name, event_data)
        events_generated += 1
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'Successfully generated {events_generated} events',
            'bucket': bucket_name,
            'timestamp': datetime.now().isoformat()
        })
    }

def generate_event():
    """Generate a single clickstream event"""
    
    # Country distribution (simplified)
    countries_samples = {
        '1': 0.07, '2': 0.005, '3': 0.01, '4': 0.03, '5': 0.03,
        '6': 0.005, '7': 0.02, '8': 0.01, '9': 0.01, '10': 0.01,
        '11': 0.01, '12': 0.02, '13': 0.005, '14': 0.01, '15': 0.005,
        '16': 0.02, '17': 0.02, '18': 0.01, '19': 0.02, '20': 0.03
    }
    
    # Event types and probabilities
    event_types = {'click': 0.6, 'search': 0.3, 'purchase': 0.1}
    user_actions = {
        'home_page': 0.2, 'product_page': 0.4, 'cart_page': 0.2,
        'checkout_page': 0.1, 'search_page': 0.1
    }
    product_categories = {
        'electronics': 0.3, 'clothing': 0.2, 'books': 0.2,
        'home_appliances': 0.1, 'toys': 0.1, 'other': 0.1
    }
    
    # Generate event components
    event_type = random.choices(list(event_types.keys()), weights=list(event_types.values()))[0]
    user_action = random.choices(list(user_actions.keys()), weights=list(user_actions.values()))[0]
    user_location = random.choices(list(countries_samples.keys()), weights=list(countries_samples.values()))[0]
    
    # Generate age (normal distribution around 35)
    age = max(16, min(80, int(random.normalvariate(35, 10))))
    
    # Product category (if applicable)
    product_category = None
    if event_type in ['click', 'purchase']:
        product_category = random.choices(list(product_categories.keys()), weights=list(product_categories.values()))[0]
    
    # Generate timestamp (within last 60 days)
    now = datetime.now()
    start_date = now - timedelta(days=60)
    random_date = start_date + (now - start_date) * random.random()
    
    return {
        'event_type': event_type,
        'user_id': random_string(10),
        'user_action': user_action,
        'product_category': product_category,
        'location': user_location,
        'user_age': age,
        'timestamp': int(random_date.timestamp())
    }

def random_string(length):
    """Generate random string of specified length"""
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for _ in range(length))

def upload_event_to_s3(s3_client, bucket_name, event_data):
    """Upload event data to S3"""
    event_filename = f"{event_data['event_type']}_{event_data['user_id']}_{event_data['timestamp']}.json"
    
    try:
        s3_client.put_object(
            Bucket=bucket_name,
            Key=f"raw/{event_filename}",
            Body=json.dumps(event_data),
            ContentType='application/json'
        )
        print(f"Event uploaded to S3: {event_filename}")
    except Exception as e:
        print(f"Error uploading event: {str(e)}")
        raise