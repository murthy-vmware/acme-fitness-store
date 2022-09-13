## Environment setup for the workshop

Now that we have a basic undertstanding of Azure and ASA_E, in this section you will setup the required software/resources to run this workshop.

### Setup Github Codspaces
This workshop leverages Github Codespaces to provide a development environment for running the instructions. Certainly you can run these instruction from a shell. But for people trying to get familiar with ASA-E for the first time, to rule out any environment related issues we recommend using Github Codespaces.

1. The first step in getting access to github codespaces option for [Azure Samples](https://github.com/Azure-Samples/) is to send your github id to XXX@XXX.com email distribution or to the workshop co-ordinator. The admin of this distribution list will add you to the organization and assign you permissions that makes the Codespaces option visible.

2. Upon getting the confirmation that you are added to the Org, navigate to https://github.com/Azure-Samples/acme-fitness-demo/tree/workshop repository, click "Code" button. You should be able to "Codespaces" as an option listed. If you do not see that option listed, most probably you are not added to [Azure-Samples](https://github.com/Azure-Samples/) org or your github id is still not active in this org. Please discuss this issue with your workshop co-ordinator or send an email to XXX@XXX.com.

3. Assuming the above steps are succesful, you should be able to open a terminal inside VS Code that opens up in Codespaces. Refer to this link to understand more about [Codespaces](https://github.com/CodeSpaces). This Codespace comes installed with the following software:
   1. * [JDK 17](https://docs.microsoft.com/java/openjdk/download?WT.mc_id=azurespringcloud-github-judubois#openjdk-17)
   2. * The environment variable `JAVA_HOME` should be set to the path of the JDK installation. The directory specified by this path should have `bin`, `jre`, and `lib` among its subdirectories. Further, ensure your `PATH` variable contains the directory `${JAVA_HOME}/bin`. To test, type `which javac` into bash shell ensure the resulting path points to a file inside `${JAVA_HOME}/bin`.
   3. * [Azure CLI version 2.31.0 or higher](https://docs.microsoft.com/cli/azure/install-azure-cli?view=azure-cli-latest) version 2.31.0 or later. You can check the version of your current Azure CLI installation by running:

    ```bash
    az --version
    ```

### Create Azure Resources using ARM template

As we had already noted in the prior sections and also as we go to next sections, there are quite a few number of resources that need to be in place to execute this workshop. As the goal of this workshop is to focus more on the app/service related tasks and less on the underlying infrastructre tasks, we are providing an Azure ARM template that will provision the required reources.

 - Resource Group
 - Azure Cache for Redis
 - Azure SQL for Postgres
 - Azure Key Vault
 - Log Analytics workspace
 - Application Insights workspace
 

Please right click on the below button and choose the Open in new tab option. The reason is there are quite a number of fields that need to be populated in that form and we are providing guidance on the values to populate with.

[![Deploy to Azure](images/deploybutton.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fmurthy-vmware%2facme-fitness-store%2fworkshop%2f03-workshop-environment-setup%2facmedeploy.json)


To know about the description of the fields, click on the little info icon next to every field. For the fields where default value is populated, the recommendation is to use the default for the first time use. The only field that needs to be popluated in here is the ``ObjectId``. To get the value for this field, perform the below steps

** In Services tab, search for Azure Active Directory
** On the left side, find ``Users`` link and click on that.
** In the search bar, search for your name and click on your name
** Copy the Object ID from the list of properties 

Once you copied the value for Object ID, paste this in the arm template value for Object ID field.

Click Save go to next screen. Click Create on next screen

The above deployment takes a while (25-30 mins) to complete. You do not have to wait for this step to complete. You can go ahead with the steps in next section. However it will be useful to check the completion of this step using the below command(s)

After successful completion of this step verify that the resource group and all the relevant resources are created in the resource group. Navigate to Home button in Azure portal, click on your subscription and on the left click on "Resource Groups" link. If you left all the default values in the ARM template, this page should look like the screenshot below

[Resource Group](images/arm-resourcegroup.png)

### Prepare your environment for deployments

This step should be completed only after the successful completion of the above step.As the above step takes 25-30 minutes to complete, please make sure you revisit this section and complete these instructions.

Create a bash script with environment variables by making a copy of the supplied template:

From the root directory of the repo
```shell
cp ./scripts/setup-env-variables-template.sh ./scripts/setup-env-variables.sh
```

Open `./scripts/setup-env-variables.sh` and update the following variables:

```shell
export SUBSCRIPTION=CHANGE-ME                 # replace it with your subscription-id
export LOG_ANALYTICS_WORKSPACE=acme-fitness-la-CHANGE-ME   # By replacing CHANGE-ME with the last 4 characters you see in Log Analytics workspace name in Azure portal.
```

- To get the Subscription ID, go to Azure portal, in search bar type subscriptions. The results should display your subscription and its id.

This env file comes with default values that were provided as part of arm template. It is recommended to leave the values as-is for the purpose of this workshop. If for any reason you updated these default values in the arm template, those values need to be entereted in here.

Now, set the environment:

```shell
source ./scripts/setup-env-variables.sh
```

### Install the Azure CLI spring extension

Alright, now that you triggered the task to create the dependent services/resources we will go ahead with the next steps of installing azure cli in our Codespace. While there is an option to use Azure Portal to create the required resources, for the purposes of this workshop we use azure cli. 

Install the Azure Spring Apps extension for the Azure CLI using the following command

```shell
az extension add --name spring
```

Note - `spring` CLI extension `1.1.5` or later is a pre-requisite to enable the
latest Enterprise tier functionality to configure VMware Tanzu Components.
```

If `spring`'s version still < `1.1.5` after above commands, you can try to [re-install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli). 

### Login to Azure

Login to the Azure CLI and choose your active subscription. In the terminal of VS Code in Codespace, run the below commands

```shell
az login --use-device-code
az account list -o table
az account set --subscription ${SUBSCRIPTION}
```

Accept the legal terms and privacy statements for the Enterprise tier.

> Note: This step is necessary only if your subscription has never been used to create an Enterprise tier instance of Azure Spring Apps.

```shell
az provider register --namespace Microsoft.SaaS
az term accept --publisher vmware-inc --product azure-spring-cloud-vmware-tanzu-2 --plan asa-ent-hr-mtr
```

If you completed all the steps till here, you have successfully created/installed the following resources
* Accessing a dev environment via Github Codespaces
* All the dependent resources required for the workshop are installed via an arm template.
* Required az cli extensions are added and default subscription is set

⬅️ Previous guide: [02 - ASA-E Introduction](../02-asa-e-introduction/README.md)

➡️ Next guide: [04 - Create ASA-E instance](../04-create-asa-e-instance/README.md)