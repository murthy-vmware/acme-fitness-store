export AZURE_CACHE_NAME=acme-fitness-cache-CHANGE-ME                  # Unique name for Azure Cache for Redis Instance
export POSTGRES_SERVER=acme-fitness-db-CHANGE-ME                  # Unique name for Azure Database for PostgreSQL Flexible Server
export POSTGRES_SERVER_USER=acme             # Postgres server username to be created in next steps
export POSTGRES_SERVER_PASSWORD=CHANGE-ME         # Postgres server password to be created in next steps

export CART_SERVICE_CACHE_CONNECTION="cart_service_cache"
export ORDER_SERVICE_DB="acmefit_order"
export ORDER_SERVICE_DB_CONNECTION="order_service_db"
export CATALOG_SERVICE_DB="acmefit_catalog"
export CATALOG_SERVICE_DB_CONNECTION="catalog_service_db"