In the previous section we deployed a simple hello-world service to asa-e instance. In this section we are going to deploy the more sophisticated acme-fitness application to the same asa-e instance. 

This [diagram](images/just-services.jpg) shows the final result once this section is complete.

Below are the diffrent steps that we configure/create to successfully deploy the services/apps
- [Create applications in Azure Spring Apps](#create-applications-in-azure-spring-apps)
- [Create Application Configuration Service](#create-application-configuration-service)
  - [Bind to Application Configuration Service](#bind-to-application-configuration-service)
  - [Bind to Service Registry](#bind-to-service-registry)
- [Configure Tanzu Build Service](#configure-tanzu-build-service)
  - [Build and Deploy Polyglot Applications](#build-and-deploy-polyglot-applications)
## Create applications in Azure Spring Apps

First step is to create an application for each service:

```shell
az spring app create --name ${CART_SERVICE_APP} --instance-count 1 --memory 1Gi &
az spring app create --name ${ORDER_SERVICE_APP} --instance-count 1 --memory 1Gi &
az spring app create --name ${PAYMENT_SERVICE_APP} --instance-count 1 --memory 1Gi &
az spring app create --name ${CATALOG_SERVICE_APP} --instance-count 1 --memory 1Gi &
az spring app create --name ${FRONTEND_APP} --instance-count 1 --memory 1Gi &
wait
```

Next step is to provide config information for Payment Service and Catalog Service. Remaining services do not need config data stored separately. 
## Create Application Configuration Service

Before we can go ahead and point the services to config stored in an external location, we first need to create an application config instance pointing to that external repo. In this case we are going to create an application config instance that points to a github repo using azure cli.

```shell
az spring application-configuration-service git repo add --name acme-fitness-store-config \
    --label main \
    --patterns "catalog/default,catalog/key-vault,identity/default,identity/key-vault,payment/default" \
    --uri "https://github.com/Azure-Samples/acme-fitness-store-config"
```

### Bind to Application Configuration Service

Now the next step is to bind the above created application configuration service instance to the azure apps that use this external config. Here we bin


```shell
az spring application-configuration-service bind --app ${PAYMENT_SERVICE_APP}
az spring application-configuration-service bind --app ${CATALOG_SERVICE_APP}
```

### Bind to Service Registry

Several application require service discovery using Service Registry, so create
the bindings:

```shell
az spring service-registry bind --app ${PAYMENT_SERVICE_APP}
az spring service-registry bind --app ${CATALOG_SERVICE_APP}
```

## Configure Tanzu Build Service

Create a custom builder in Tanzu Build Service using the Azure CLI. This custom builder is for services that are not Spring Boot based.

```shell
az spring build-service builder create -n ${CUSTOM_BUILDER} \
    --builder-file azure/builder.json \
    --no-wait
```

### Build and Deploy Polyglot Applications

Deploy and build each application, specifying its required parameters

```shell
# Deploy Payment Service
az spring app deploy --name ${PAYMENT_SERVICE_APP} \
    --config-file-pattern payment/default \
    --source-path apps/acme-payment 

# Deploy Catalog Service
az spring app deploy --name ${CATALOG_SERVICE_APP} \
    --config-file-pattern catalog/default \
    --source-path apps/acme-catalog 

# Deploy Order Service
az spring app deploy --name ${ORDER_SERVICE_APP} \
    --builder ${CUSTOM_BUILDER} \
    --source-path apps/acme-order 

# Deploy Cart Service 
az spring app deploy --name ${CART_SERVICE_APP} \
    --builder ${CUSTOM_BUILDER} \
    --env "CART_PORT=8080" \
    --source-path apps/acme-cart 

# Deploy Frontend App
az spring app deploy --name ${FRONTEND_APP} \
    --builder ${CUSTOM_BUILDER} \
    --source-path apps/acme-shopping 
```