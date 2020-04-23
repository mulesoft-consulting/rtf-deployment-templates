# RTF Deployment Templates
A curated set of Terraform/Azure Resource templates for Runtime Fabric in different scenarios.

### Disclaimer
> These templates are offered as-is and without warranty and should not be considered as part of an officially supported MuleSoft product. Users leverage these templates at their own risk and should satisfy themselves that thet are appropriate for their needs before use. No support will be provided on these templates through MuleSoft product Support channels. If you require further assistance, please contact your Customer Success Manager to enquire about MuleSoft's Professional Services offerings to assist with your Runtime Fabric installation.

## How to Use
These templates provide a set of configuration templates that can be used to build and install Anypoint Runtime Fabric in a supported cloud environment. Templates are currently provided for AWS and Microsoft Azure clouds. Select the appropriate template for the cloud provider, preferred operating system and fabric configuration that you choose. The templates are arranged in folders that are named according to the number of controller and worker nodes they will generate; for example `1C2W` will create a 1 controller-node, 2 worker-node fabric.

If your environment is not supported or you wish to have further customization, you can install Runtime Fabric using the manual approach detailed in the product documentation.

Please note that the installation steps detailed in the Runtime Fabric installation guide at must be followed in addition to downloading these templates.

[Anypoint Runtime Fabric Documentation](https://docs.mulesoft.com/runtime-fabric)

[Installation guide for AWS](https://docs.mulesoft.com/runtime-fabric/latest/install-aws)

[Installation guide for Azure](https://docs.mulesoft.com/runtime-fabric/latest/install-azure)


## Get Involved
The templates included here have largely come from the MuleSoft field and user community and we welcome new submissions. If you want to offer your own templates, or modifications or enhancements to the ones offered, please fork this repository and submit a Pull Request.

[About Pull Requests](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests)

If you encounter issues with the templates, please create a new Issue providing as much detail about your challenge as possible.

[About Issues](https://help.github.com/en/github/managing-your-work-on-github/about-issues)
