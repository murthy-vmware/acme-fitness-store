## Environment setup for the workshop

In this section you will setup the required software/artifacts to run this workshop.

### Create Azure Resources

We will use an ARM template to create the required Azure resources that are needed for this workshop. There are other manual/automated ways in which you can provision these resources, but to save time for the workshop participants we will leverage this ARM template. This ARM template provisions the below resources
 - Resource Group
 - Azure Cache for Redis
 - Azure SQL for Postgres
 - Log Analytics workspace
 - Azure Key Vault
 - Application Insights workspace

Use the below settings for deploying this ARM template
 - Create a new resource group
 - Select the nearest region in the location field from [the list of regions where Azure Spring Apps is available](https://azure.microsoft.com/global-infrastructure/services/?products=spring-apps&regions=all).

[![Deploy to Azure](images/deploybutton.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fmurthy-vmware%2facme-fitness-store%2ftestARM%2fazuredeploy.json)

### Setup Github Codspaces

## Install the Azure CLI extension

Install the Azure Spring Apps extension for the Azure CLI using the following command

```shell
az extension add --name spring
```

Note - `spring-cloud` CLI extension `3.0.0` or later is a pre-requisite to enable the
latest Enterprise tier functionality to configure VMware Tanzu Components. Use the following
command to remove previous versions and install the latest Enterprise tier extension:

```shell
az extension remove --name spring-cloud
az extension add --name spring
```

If `spring-cloud`'s version still < `3.0.0` after above commands, you can try to [re-install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli). 

### Prepare your environment for deployments

Create a bash script with environment variables by making a copy of the supplied template:

```shell
cp ../scripts/setup-env-variables-template.sh ../scripts/setup-env-variables.sh
```

Open `../scripts/setup-env-variables.sh` and enter the following information:

```shell
export SUBSCRIPTION=subscription-id                 # replace it with your subscription-id
export RESOURCE_GROUP=resource-group-name           # update with the value that was provided at the step of running ARM template
export SPRING_APPS_SERVICE=azure-spring-apps-name   # name of the service that will be created in the next steps
export LOG_ANALYTICS_WORKSPACE=log-analytics-name   # existing workspace or one that will be created in next steps
export REGION=region-name                           # choose a region with Enterprise tier support
```

The REGION value should be one of available regions for Azure Spring Apps (e.g. eastus). Please visit [here](https://azure.microsoft.com/en-us/global-infrastructure/services/?products=spring-apps&regions=all) for all available regions for Azure Spring Apps.

Then, set the environment:

```shell
source ../scripts/setup-env-variables.sh
```

### Login to Azure

Login to the Azure CLI and choose your active subscription. 

```shell
az login
az account list -o table
az account set --subscription ${SUBSCRIPTION}
```

Accept the legal terms and privacy statements for the Enterprise tier.

> Note: This step is necessary only if your subscription has never been used to create an Enterprise tier instance of Azure Spring Apps.

```shell
az provider register --namespace Microsoft.SaaS
az term accept --publisher vmware-inc --product azure-spring-cloud-vmware-tanzu-2 --plan asa-ent-hr-mtr
```