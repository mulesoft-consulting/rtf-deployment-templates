## Create and destroy a Runtime Fabric cluster in AWS

### Prerequisites
- docker or terraform

### Create the infrastructure to run the installer on
Environment variables:
```
Required: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY_ID, 
Optional: AWS_SESSION_TOKEN, AWS_REGION
```

You'll need to configure AWS API access in your shell. For example, make sure you have `AWS_ACCESS_KEY`, `AWS_ACCESS_SECRET_KEY`, etc defined. You should be able to run the `aws` cli tool, for example. You may need to contact your operations team for assistance.

### Variables

* `cluster_name`: Local name of the Runtime Fabric cluster (e.g. rtf).
* `key_pair`: Name of the aws keypair (e.g. my-cluster-key)
* `controllers`: Number of controller machines to provision. (e.g. 3)
* `workers`: Number of worker machines to provision. (e.g. 3)
* `activation_data`: Runtime Fabric activation data containing the Anypoint organization ID, endpoint, region, activation token, and the URL for the latest version of the installer. Can be found in Anypoint Runtime Manager after creating a Runtime Fabric. (eg `NzdlMzU1YTktMzAxMC00OGE0LWJlMGQtMDd...`)
* `mule_license`: Base64 encoded content of your Mule license key file (license.lic)

_(Optional)_
* `enable_public_ips`: Apply public ips (default `false`)
* `existing_vpc_id` and `existing_subnet_ids`: Allow creating the cluster in existing VPC
* `http_proxy`: Host:port of an HTTP forward proxy to use for outbound connections (eg `192.168.1.1:1390`)
* `no_proxy`: Comma-separated list of hosts which should bypass the HTTP proxy (eg `bypass-host1,bypass-host2`)
* `monitoring_proxy`: SOCKS5 proxy to use for Anypoint Monitoring publisher outbound connections (eg `socks5://192.169.1.1:1080`, `socks5://user:pass@192.168.1.1:1080`)
* `service_uid`: Service user ID for running system services (eg `1002`)
* `service_gid`: Service group ID for running system services (eg `1002`)
* `installer_url`: URL of the RTF installation package

You can either run `terraform` natively, or via `docker`. In both cases, commands should be run from the installation *root* directory.

### With terraform
```
terraform apply \
  -var cluster_name=<cluster-name> \
  -var key_pair=<keypair-name> \
  -var controllers=1 \
  -var workers=2 \
  -var enable_public_ips=true \
  -var activation_data=<data> \
  -var mule_license='<base64 encoded license.lic>' \
  -state=aws/tf-data/rtf.tfstate
  aws
```

### With Docker

Initialize terraform providers:
```
docker run -v $(pwd):/src -w /src/aws \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN -e AWS_REGION \
  hashicorp/terraform:0.12.6 init
```

```
docker run -it -v $(pwd):/src -w /src/aws \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN -e AWS_REGION \
  hashicorp/terraform:0.12.6 apply \
  -var cluster_name=<cluster-name> \
  -var key_pair=<keypair-name> \
  -var controllers=1 \
  -var workers=2 \
  -var enable_public_ips=true \
  -var activation_data=<data> \
  -var mule_license='<base64 encoded license.lic>' \
  -state=tf-data/rtf.tfstate
```

## Destroy the infrastructure
```
docker run -it -v $(pwd):/src -w /src/aws \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN -e AWS_REGION \
  hashicorp/terraform:0.12.6 destroy \
  -var cluster_name=<cluster-name> \
  -var key_pair=<keypair-name> \
  -var controllers=1 \
  -var workers=2 \
  -var enable_public_ips=true \
  -var activation_data=<data> \
  -var mule_license='<base64 encoded license.lic>' \
  -state=tf-data/rtf.tfstate
```
