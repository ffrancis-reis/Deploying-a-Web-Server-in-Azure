# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction

For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started

1. Clone this repository

2. Create your infrastructure as code

3. Deploy it with Packer and Terraform tools by using Windows Power Shell commands.

### Dependencies

1. Create an [Azure Account](https://portal.azure.com)
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)
5. You need to create an App registration in your Azure subscription so that you can use its client_id and client_secret as well as your subscription_id as environment variables

**Important** The commands used in this project were applied into Windows Power powershell from a Windows 10 desktop. Hence the usage of "`" backtick to line break the code.

### Instructions

1. Log in to your azure account with:

```powershell
  az login
```

2. Create a policy definition and assign it to your subscription. Here is an example of a policy included in this project:

```powershell
  az policy definition create `
    --name 'tagging-policy' `
    --display-name 'Deny creation of new resources untagged' `
    --description 'This policy ensures that all indexed resources in the subscription are tagged in its creation.' `
    --rules 'policy.json' `
    --mode "all"

  az policy assignment create `
    --name 'tagging-policy-assignment' `
    --display-name 'tagging-policy-assignment' `
    --policy "tagging-policy"
```

3. To see the policy rules and the list of assigned policies you can use:

```powershell
  az policy definition show --name "tagging-policy"

  az policy assignment list
```

4. Validate and create an image with Packer. The file "server.json" in this project have a pre-defined code for a Linux Ubuntu image, to be built with Packer. You need to create a resource grupo on Azure platform prior to the image, so that it can be associated with this resource group. Here is an example of powershell commands to do it:

```powershell
  az group create `
    --name "web-service-image-rg" `
    --location "westus2" `
    --tags "environment=Development"

  packer validate server.json

  packer build server.json
```

5. Check if your image has been created on your Azure portal. You can delete the image with the powershell command below. Attention to its name with the packer file (server.json):

```powershell
  az image delete `
    -g "web-service-image-rg" `
    -n "ubuntuImage"
```

6. Initialize the Terraform tool, plan and deploy your infra as a code. The files "main.tf" and "vars.tf" in this project contains a pre-defined code for all Azure resources of a scalable web service infrastructure. You will be prompted to input some info regarding your infa, like the name of the resource group in which all of the resources will be associated, and also how many virtual machines you want to be created. These variables are defined on the "vars.tf" file. Also, in the "vars.tf" file you can specify another specific variable that you want without the default property so that it wil asked for input. The "main.tf" file also have specified that the max amount of VMs that will be created is 5, for cost reduztion purpose. With the example powershell commands below you can deploy it on your Azure subscription:

```powershell
  terraform init

  terraform plan -out "solution.plan"

  terraform apply "solution.plan"
```

7. Check your resources creation in your Azure portal and also with the commands below:

```powershell
  terraform show
```

8. You can delete all of the resources with the powershell command below as well (attention to costs that'll be probable charged if you leave it up, for dev purposes):

```powershell
  terraform destroy
```

### Output

Here is an example of the Azure resources that will be created by specifying "web-server" as the prefix and "3" as the quantity of VMs.
