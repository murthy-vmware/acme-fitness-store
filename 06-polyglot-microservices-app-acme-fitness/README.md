This section shows the demo application that we will be using in this workshop to demonstrate the different features of ASA-E.

![An image showing the services involved in the ACME Fitness Store. It depicts the applications and their dependencies on different ASA-E services](images/architecture.jpg)

This application is composed of several services:

* 3 Java Spring Boot applications:
  * A catalog service for fetching available products
  * A payment service for processing and approving payments for users' orders
  * An identity service for referencing the authenticated user

* 1 Python application:
  * A cart service for managing a users' items that have been selected for purchase

* 1 ASP.NET Core applications:
  * An order service for placing orders to buy products that are in the users' carts

* 1 NodeJS and static HTML Application
  * A frontend shopping application