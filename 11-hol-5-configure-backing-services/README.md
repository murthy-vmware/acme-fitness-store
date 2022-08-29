By default, several services use in-memory data storage. This unit will create persistent stores outside the applications and connect applications to those stores.

Prerequisites:

* Completion of [Unit 1 - Deploy and Build Applications](#unit-1---deploy-and-build-applications)

### Prepare your environment

Create a bash script with environment variables by making a copy of the supplied template:

```shell
cp ./azure/setup-db-env-variables-template.sh ./azure/setup-db-env-variables.sh
```

Open `./azure/setup-db-env-variables.sh` and enter the following information:

```shell
export AZURE_CACHE_NAME=change-me                   # Unique name for Azure Cache for Redis Instance
export POSTGRES_SERVER=change-me                    # Unique name for Azure Database for PostgreSQL Flexible Server
export POSTGRES_SERVER_USER=change-name             # Postgres server username to be created in next steps
export POSTGRES_SERVER_PASSWORD=change-name         # Postgres server password to be created in next steps
```

> Note: AZURE_CACHE_NAME and POSTGRES_SERVER must be unique names to avoid DNS conflicts

Then, set the environment:

```shell
source ./azure/setup-db-env-variables.sh
```

### Create Azure Cache for Redis

Create an instance of Azure Cache for Redis using the Azure CLI.

```shell
az redis create \
  --name ${AZURE_CACHE_NAME} \
  --location ${REGION} \
  --resource-group ${RESOURCE_GROUP} \
  --sku Basic \
  --vm-size c0
```

> Note: The redis cache will take around 15-20 minutes to deploy.

### Create an Azure Database for Postgres

Using the Azure CLI, create an Azure Database for PostgreSQL Flexible Server:

```shell
az postgres flexible-server create --name ${POSTGRES_SERVER} \
    --resource-group ${RESOURCE_GROUP} \
    --location ${REGION} \
    --admin-user ${POSTGRES_SERVER_USER} \
    --admin-password ${POSTGRES_SERVER_PASSWORD} \
    --yes

# Allow connections from other Azure Services
az postgres flexible-server firewall-rule create --rule-name allAzureIPs \
     --name ${POSTGRES_SERVER} \
     --resource-group ${RESOURCE_GROUP} \
     --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
     
# Enable the uuid-ossp extension
az postgres flexible-server parameter set \
    --resource-group ${RESOURCE_GROUP} \
    --server-name ${POSTGRES_SERVER} \
    --name azure.extensions --value uuid-ossp
```

> Note: The PostgreSQL Flexible Server will take 5-10 minutes to deploy

Create a database for the order service:

```shell
az postgres flexible-server db create \
  --database-name ${ORDER_SERVICE_DB} \
  --server-name ${POSTGRES_SERVER}
```

Create a database for the catalog service:

```shell
az postgres flexible-server db create \
  --database-name ${CATALOG_SERVICE_DB} \
  --server-name ${POSTGRES_SERVER}
```

> Note: wait for all services to be ready before continuing

### Create Service Connectors

The Order Service and Catalog Service use Azure Database for Postgres, create Service Connectors
for those applications:

```shell
# Bind order service to Postgres
az spring connection create postgres-flexible \
    --resource-group ${RESOURCE_GROUP} \
    --service ${SPRING_APPS_SERVICE} \
    --connection ${ORDER_SERVICE_DB_CONNECTION} \
    --app ${ORDER_SERVICE_APP} \
    --deployment default \
    --tg ${RESOURCE_GROUP} \
    --server ${POSTGRES_SERVER} \
    --database ${ORDER_SERVICE_DB} \
    --secret name=${POSTGRES_SERVER_USER} secret=${POSTGRES_SERVER_PASSWORD} \
    --client-type dotnet
    

# Bind catalog service to Postgres
az spring connection create postgres-flexible \
    --resource-group ${RESOURCE_GROUP} \
    --service ${SPRING_APPS_SERVICE} \
    --connection ${CATALOG_SERVICE_DB_CONNECTION} \
    --app ${CATALOG_SERVICE_APP} \
    --deployment default \
    --tg ${RESOURCE_GROUP} \
    --server ${POSTGRES_SERVER} \
    --database ${CATALOG_SERVICE_DB} \
    --secret name=${POSTGRES_SERVER_USER} secret=${POSTGRES_SERVER_PASSWORD} \
    --client-type springboot
```

The Cart Service requires a connection to Azure Cache for Redis, create the Service Connector:

```shell
az spring connection create redis \
    --resource-group ${RESOURCE_GROUP} \
    --service ${SPRING_APPS_SERVICE} \
    --connection $CART_SERVICE_CACHE_CONNECTION \
    --app ${CART_SERVICE_APP} \
    --deployment default \
    --tg ${RESOURCE_GROUP} \
    --server ${AZURE_CACHE_NAME} \
    --database 0 \
    --client-type java 
```

> Note: Currently, the Azure Spring Apps CLI extension only allows for client types of java, springboot, or dotnet.
> The cart service uses a client connection type of java because the connection strings are the same for python and java.
> This will be changed when additional options become available in the CLI.

### Update Applications

Next, update the affected applications to use the newly created databases and redis cache.

Restart the Catalog Service for the Service Connector to take effect:
```shell
az spring app restart --name ${CATALOG_SERVICE_APP}
```

Retrieve the PostgreSQL connection string and update the Catalog Service:
```shell
POSTGRES_CONNECTION_STR=$(az spring connection show \
    --resource-group ${RESOURCE_GROUP} \
    --service ${SPRING_APPS_SERVICE} \
    --deployment default \
    --connection ${ORDER_SERVICE_DB_CONNECTION} \
    --app ${ORDER_SERVICE_APP} | jq '.configurations[0].value' -r)

az spring app update \
    --name order-service \
    --env "DatabaseProvider=Postgres" "ConnectionStrings__OrderContext=${POSTGRES_CONNECTION_STR}" "AcmeServiceSettings__AuthUrl=https://${GATEWAY_URL}"
```

Retrieve the Redis connection string and update the Cart Service:
```shell
REDIS_CONN_STR=$(az spring connection show \
    --resource-group ${RESOURCE_GROUP} \
    --service ${SPRING_APPS_SERVICE} \
    --deployment default \
    --app ${CART_SERVICE_APP} \
    --connection ${CART_SERVICE_CACHE_CONNECTION} | jq -r '.configurations[0].value')

az spring app update \
    --name cart-service \
    --env "CART_PORT=8080" "REDIS_CONNECTIONSTRING=${REDIS_CONN_STR}" "AUTH_URL=https://${GATEWAY_URL}"
```

### View Persisted Data

Verify cart data is now persisted in Redis by adding a few items to your cart. Then, restart the cart service:

```shell
az spring app restart --name ${CART_SERVICE_APP}
```

Notice that after restarting the cart service, the items in your cart will now persist.

Verify order data is now persisted in a PostgreSQL Database by placing an order. View your placed orders with the following URL:

```text
https://${GATEWAY_URL}/order/${USER_ID}
```

Your USER_ID is your username URL encoded.

Now restart the order service application:

```shell
az spring app restart --name ${ORDER_SERVICE_APP}
```

After restarting, revisit the URL for your placed orders and notice that they persisted. 