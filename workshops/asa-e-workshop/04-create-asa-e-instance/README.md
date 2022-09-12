## Create ASA-E instance

In this section we are going to create an ASA-E instance using azure cli.


Prepare a name for your Azure Spring Apps service.  The name must be between 4 and 32 characters long and can contain only lowercase letters, numbers, and hyphens.  The first character of the service name must be a letter and the last character must be either a letter or a number. 

This name is stored as an environment variable, SPRING_APPS_SERVICE in ```./scripts/setup-env-variables.sh```. It is defaulted to acme-fitness. It is recommended to leave the default value for this workshop purpose. 

### Create an instance of Azure Spring Apps Enterprise.

```shell
az spring create --name ${SPRING_APPS_SERVICE} \
    --resource-group ${RESOURCE_GROUP} \
    --location ${REGION} \
    --sku Enterprise \
    --enable-application-configuration-service \
    --enable-service-registry \
    --enable-gateway \
    --enable-api-portal \
    --build-pool-size S2 
```

> Note: The service instance will take around 10-15 minutes to deploy. You will notice in the above command have arguments to enable application-configuration-service, service-registry, gateway and api-portal. The significance of these services will be discussed in later sections when we introduce a demo microservices application. For now please go ahead and run the above command.

Set your default resource group name and cluster name using the following commands:

```shell
az configure --defaults \
    group=${RESOURCE_GROUP} \
    location=${REGION} \
    spring=${SPRING_APPS_SERVICE}
```

After successfully completing the above steps you created an azure spring apps enterprise instance. This instance acts as a container to which all the services/apps will be deployed to in the following sections.


⬅️ Previous guide: [03 - Workshop Environment Setup](../03-workshop-environment-setup/README.md)

➡️ Next guide: [05 - Deploy Simple Hello World spring boot service](../05-hol-1-hello-world-spring-boot-microservice/README.md)