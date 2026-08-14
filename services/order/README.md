# Order Service

Spring Boot REST API for checkout. It saves orders and notifies other services through SQS.

## Overview

Order accepts a cart checkout (customer email, address, and line items), stores the order in MySQL, then publishes an `order placed` event to SQS. Inventory listens to that queue. The Web UI also looks up an order by ID after checkout.

Order does not hold product catalog data or live stock. Catalog owns products. Inventory owns quantity.

In the shopping-cart flow:
1. Web UI posts the cart to `POST /api/orders`.
2. Order saves the order and items in MySQL.
3. Order publishes the event to SQS (lab/compose profiles).
4. The UI can load the order again with `GET /api/orders/{id}`.

## API

| Method | Path | Description |
| ------ | ---- | ----------- |
| POST | `/api/orders` | Create an order and publish an SQS event |
| GET | `/api/orders/{id}` | Get an order by ID, including items |
| GET | `/actuator/health` | Health check |

Default port: **6000**.

Request body for create:

- `customerEmail`
- `customerAddress`
- `items[]` with `productId`, `quantity`, `productPrice`

## Integrations

- **MySQL** — orders and order items
- **AWS SQS** — publish order-placed events for Inventory

## Stack

Java 8, Spring Boot, Spring Data JPA, Spring Cloud AWS (SQS), MySQL (RDS).
