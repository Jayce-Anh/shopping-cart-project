# Catalog Service

Spring Boot REST API for the product catalog. It is the product source for the shopping-cart UI.

## Overview

Catalog stores product data (code, name, description, price) in MySQL. When a client lists or looks up a product, Catalog calls Inventory to read stock, then sets `inStock` on the response. Product lists are cached in Valkey/Redis so repeat reads do not hit MySQL or Inventory every time.

In the shopping-cart flow:

1. Web UI calls `GET /api/products` to show the store.
2. Catalog loads products from MySQL and stock from Inventory (`/api/inventory`).
3. The UI uses `inStock` to allow or block add-to-cart.

Catalog does not create orders or change stock. Those belong to Order and Inventory.

## API

| Method | Path | Description |
| ------ | ---- | ----------- |
| GET | `/api/products` | List products, with `inStock` from Inventory |
| GET | `/api/products/{code}` | Get one product by code |
| GET | `/actuator/health` | Health check |

Default port: **4000**.

## Integrations

- **MySQL** — product records
- **Inventory service** — Feign/REST to `/api/inventory` for stock
- **Valkey/Redis** — cache for product lists and lookups

## Stack

Java 8, Spring Boot, Spring Data JPA, OpenFeign, Redis cache, MySQL.
