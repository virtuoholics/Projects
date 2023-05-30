import json
import boto3


client = boto3.client('acm', region_name='us-east-1')
certificates = client.list_certificates()
for cert in certificates['CertificateSummaryList']:
    if cert['InUse'] == True:
        cert_arn = cert['CertificateArn']

with open('./k8s/nlb.yaml') as f1:
    data = f1.readlines()
    data[11] = f'    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: {cert_arn}\n'
    print(data[11])
with open('./k8s/nlb.yaml', 'w') as f2:
    f2.writelines(data)
