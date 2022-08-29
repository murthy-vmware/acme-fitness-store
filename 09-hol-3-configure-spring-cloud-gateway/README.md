## Configure Spring Cloud Gateway

Assign an endpoint and update the Spring Cloud Gateway configuration with API
information:

```shell
az spring gateway update --assign-endpoint true
export GATEWAY_URL=$(az spring gateway show | jq -r '.properties.url')
    
az spring gateway update \
    --api-description "Acme Fitness Store API" \
    --api-title "Acme Fitness Store" \
    --api-version "v1.0" \
    --server-url "https://${GATEWAY_URL}" \
    --allowed-origins "*" \
    --no-wait
```

### Create  routing rules for the applications:

```shell
az spring gateway route-config create \
    --name ${CART_SERVICE_APP} \
    --app-name ${CART_SERVICE_APP} \
    --routes-file ./routes/cart-service.json
    
az spring gateway route-config create \
    --name ${ORDER_SERVICE_APP} \
    --app-name ${ORDER_SERVICE_APP} \
    --routes-file ./routes/order-service.json

az spring gateway route-config create \
    --name ${CATALOG_SERVICE_APP} \
    --app-name ${CATALOG_SERVICE_APP} \
    --routes-file ./routes/catalog-service.json

az spring gateway route-config create \
    --name ${FRONTEND_APP} \
    --app-name ${FRONTEND_APP} \
    --routes-file ./routes/frontend.json

### Access the Application through Spring Cloud Gateway

Retrieve the URL for Spring Cloud Gateway and open it in a browser:

```shell
open "https://${GATEWAY_URL}"
```

If using Azure Cloud Shell or Windows, open the output from the following command in a browser:

```shell
echo "https://${GATEWAY_URL}"
```

You should see the ACME Fitness Store Application:

![An image of the ACME Fitness Store Application homepage](media/homepage.png)

Explore the application, but notice that not everything is functioning yet. Continue on to
Unit 2 to configure Single Sign On to enable the rest of the functionality.

### Explore the API using API Portal

Assign an endpoint to API Portal and open it in a browser:

```shell
az spring api-portal update --assign-endpoint true
export PORTAL_URL=$(az spring api-portal show | jq -r '.properties.url')

open "https://${PORTAL_URL}"
```

If using Azure Cloud Shell or Windows, open the output from the following command in a browser:

```shell
echo "https://${PORTAL_URL}"
```