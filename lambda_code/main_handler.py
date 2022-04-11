import boto3
import logging, os, urllib3, json
from get_secret import get_telegram_secret

#Get Environment Variables:
SNS_Topic_ARN = os.environ.get('SNS_Topic_ARN')
threshold = os.environ.get('threshold')

#Instantiate Boto3 Clients:
sns_client = boto3.client('sns')
ec2 = boto3.client('ec2')
cloudwatch = boto3.client('cloudwatch')

#Instantiate Logger:
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        Filters = [{'Name': 'tag:MonitorIPCount', 'Values': ['true']}]

        resp = ec2.describe_subnets(Filters=Filters)
        subnets = resp['Subnets']
        if not subnets:
            logger.info("Subnet List is empty")
        elif subnets:
            for i in range(len(subnets)): 
                available_ip_count = resp['Subnets'][i]['AvailableIpAddressCount']
                logger.info("Available IP Address Count = {}".format(available_ip_count))
                
                for subnet in subnets:
                    cloudwatch.put_metric_data(
                        Namespace='Subnets',
                        MetricData=[
                            {
                                'MetricName': 'AvailableIPCount',
                                'Value': subnet['AvailableIpAddressCount'],
                                'Dimensions': [
                                    {
                                        'Name': 'SubnetId',
                                        'Value': subnet['SubnetId'],
                                    },
                                    {
                                        'Name': 'VpcId',
                                        'Value': subnet['VpcId'],
                                    }
                                ]
                            }
                        ]
                    )
        
                logger.info("Put Metri Data - OK")

                if available_ip_count < int(threshold):
                    logger.warning("Only {} IPs left in {} {}".format(available_ip_count, subnet['SubnetId'], subnet['VpcId']))
                    message = ("WARNING: Only {} IPs left in {} {}".format(available_ip_count, subnet['SubnetId'], subnet['VpcId']))
                    subnet_id = subnet['SubnetId']
                    send_telegram(message)
                    send_email(context, message, threshold, subnet_id)
            
            return resp
    
    except Exception as error:
        #Log the Error:
        logger.error(error)

        #Send email with error details:
        sns_client.publish(
            TopicArn = SNS_Topic_ARN,
            Subject = 'ERROR: Lambda Request ID {}'.format(context.aws_request_id),
            Message = 
            'Error details: {} \n'.format(error) +
            'More Info: \n' +
            '\n' +
            'Lambda Request ID: {} \n'.format(context.aws_request_id) +
            'CloudWatch log stream name: {} \n'.format(context.log_stream_name) +
            'CloudWatch log group name: {} \n'.format(context.log_group_name)
            )
        
        #Lambda error response:
        return {
            'statusCode': 400,
            'message': 'An error has occurred',
			'moreInfo': {
				'Lambda Request ID': '{}'.format(context.aws_request_id),
                'CloudWatch log stream name': '{}'.format(context.log_stream_name),
                'CloudWatch log group name': '{}'.format(context.log_group_name)
				}
			}
			
def send_email(context, message, threshold, subnet_id):
    try:
        sns_client.publish(
            TopicArn = SNS_Topic_ARN,
            Subject = 'WARNING: {} IP Count under {}'.format(subnet_id, threshold),
            Message = 
            'Warning Message: {} \n'.format(message) +
            '\n' +
            'More Info: \n' +
            'Lambda Request ID: {} \n'.format(context.aws_request_id) +
            'CloudWatch log stream name: {} \n'.format(context.log_stream_name) +
            'CloudWatch log group name: {} \n'.format(context.log_group_name)
            )

        logger.info("SNS message sent successfully")
    except Exception as error:
        logger.error(error)

def send_telegram(message):
    #Retrieve and load the Telegram BOT Credentials from Secret Manager
    secret_name = "telegram_bot_credentials"
    region_name = "us-east-1"
    decrypted_credentials = get_telegram_secret(secret_name, region_name)
    telegram_cred = json.loads(decrypted_credentials)

    #Publish Telegram Message
    TELEGRAM_URL = "https://api.telegram.org/bot{}/sendMessage".format(telegram_cred['bot_token'])
    http = urllib3.PoolManager()
    try:
        payload = {
            "text": message.encode("utf8"),
            "chat_id": telegram_cred['user_id']
        }
        http_response = json.loads(http.request("POST", TELEGRAM_URL, fields=payload).data.decode('utf-8'))

        logger.info("Telegram message sent successfully")
        return http_response
    except Exception as error:
        logger.error(error)