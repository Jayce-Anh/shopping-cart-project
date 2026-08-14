# Inventory Service

Spring Boot REST API for product stock. Catalog uses it to show whether a product is in stock.

## Overview

Inventory stores `productCode` and `availableQuantity` in MySQL. Catalog calls this service when it builds the product list. Lookups are cached in Valkey/Redis.

When a customer places an order, Order publishes an event to SQS. Inventory listens on that queue (lab/compose profiles) so it can react to new orders. The listener currently logs the event; stock decrement can be added later.

In the shopping-cart flow:

1. Catalog asks Inventory for stock by product code or for the full list.
2. Order publishes `order placed` to SQS after it saves an order.
3. Inventory consumes that message from SQS.

Inventory does not own product details or checkout. Those belong to Catalog and Order.

## API

| Method | Path | Description |
| ------ | ---- | ----------- |
| GET | `/api/inventory` | List stock for all products |
| GET | `/api/inventory/{productCode}` | Get stock for one product code |
| GET | `/actuator/health` | Health check |

Default port: **5000**.

## Integrations

- **MySQL** — inventory records
- **Valkey/Redis** — cache for stock lookups
- **AWS SQS** — consume order-placed events from Order

## Stack

Java 8, Spring Boot, Spring Data JPA, Redis cache, Spring Cloud AWS (SQS), MySQL.
