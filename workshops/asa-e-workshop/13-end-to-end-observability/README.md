In this unit you will explore live application metrics and query logs to know the health of your applications.

### Add Instrumentation Key to Key Vault

The Application Insights Instrumentation Key must be provided for the non-java applications.

> Note: In future iterations, the buildpacks for non-java applications will support
> Application Insights binding and this step will be unnecessary.

Retrieve the Instrumentation Key for Application Insights and add to Key Vault

```shell
export INSTRUMENTATION_KEY=$(az monitor app-insights component show --app ${SPRING_APPS_SERVICE} | jq -r '.connectionString')

az keyvault secret set --vault-name ${KEY_VAULT} \
    --name "ApplicationInsights--ConnectionString" --value ${INSTRUMENTATION_KEY}
```

### Update Sampling Rate

Increase the sampling rate for the Application Insights binding.

```shell
az spring build-service builder buildpack-binding set \
    --builder-name default \
    --name default \
    --type ApplicationInsights \
    --properties sampling-rate=100 connection_string=${INSTRUMENTATION_KEY}
```

### Reload Applications

Restart applications to reload configuration. For the Java applications, this will allow the new
sampling rate to take effect. For the non-java applications, this will allow them to access the Instrumentation Key from Key Vault. 

```shell
az spring app restart -n ${CART_SERVICE_APP}
az spring app restart -n ${ORDER_SERVICE_APP}
az spring app restart -n ${IDENTITY_SERVICE_APP}
az spring app restart -n ${CATALOG_SERVICE_APP}
az spring app restart -n ${PAYMENT_SERVICE_APP}
```

### Generate Traffic

Use the ACME Fitness Shop Application to generate some traffic. Move throughout the application, view the catalog, or place an order.

To continuously generate traffic, use the traffic generator:

```shell
cd traffic-generator
GATEWAY_URL=https://${GATEWAY_URL} ./gradlew gatlingRun-com.vmware.acme.simulation.GuestSimulation
cd -
```

Continue on to the next sections while the traffic generator runs.

### Start monitoring apps and dependencies - in Application Insights

Open the Application Insights created by Azure Spring Apps and start monitoring Spring Boot applications. 
You can find the Application Insights in the same Resource Group where you created an Azure Spring Apps service instance.

Navigate to the `Application Map` blade:

![An image showing the Application Map of Azure Application Insights](media/fitness-store-application-map.jpg)

Navigate to the `Peforamnce` blade:

![An image showing the Performance Blade of Azure Application Insights](media/performance.jpg)

Navigate to the `Performance/Dependenices` blade - you can see the performance number for dependencies,
particularly SQL calls:

![An image showing the Dependencies section of the Performance Blade of Azure Application Insights](media/performance_dependencies.jpg)

Navigate to the `Performance/Roles` blade - you can see the performance metrics for individual instances or roles:

![An image showing the Roles section of the Performance Blade of Azure Application Insights](media/fitness-store-roles-in-performance-blade.jpg)

Click on a SQL call to see the end-to-end transaction in context:

![An image showing the end-to-end transaction of a SQL call](media/fitness-store-end-to-end-transaction-details.jpg)

Navigate to the `Failures` blade and the `Exceptions` panel - you can see a collection of exceptions:

![An image showing application failures graphed](media/fitness-store-exceptions.jpg)

Navigate to the `Metrics` blade - you can see metrics contributed by Spring Boot apps,
Spring Cloud modules, and dependencies.
The chart below shows `http_server_requests` and `Heap Memory Used`.

![An image showing metrics over time](media/metrics.jpg)

Spring Boot registers a lot number of core metrics: JVM, CPU, Tomcat, Logback...
The Spring Boot auto-configuration enables the instrumentation of requests handled by Spring MVC.
The REST controllers `ProductController`, and `PaymentController` have been instrumented by the `@Timed` Micrometer annotation at class level.

* `acme-catalog` application has the following custom metrics enabled:
  * @Timed: `store.products`
* `acem-payment` application has the following custom metrics enabled:
  * @Timed: `store.payment`

You can see these custom metrics in the `Metrics` blade:

![An image showing custom metrics instrumented by Micrometer](media/fitness-store-custom-metrics-with-payments-2.jpg)

Navigate to the `Live Metrics` blade - you can see live metrics on screen with low latencies < 1 second:

![An image showing the live metrics of all applications](media/live-metrics.jpg)