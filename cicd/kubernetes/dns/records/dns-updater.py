import json
import boto3


client = boto3.client('elbv2', region_name='us-east-1')
lbs = client.describe_load_balancers()
for nlb in lbs['LoadBalancers']:
    del nlb['CreatedTime']
    if 'app1' in nlb['LoadBalancerName']:
        app1_dns_name = nlb['DNSName']

with open('./dns.tf') as f1:
    data = f1.readlines()
    data[8] = f'  records = ["{app1_dns_name}"]\n'
    print(data[8])
with open('./dns.tf', 'w') as f2:
    f2.writelines(data)
