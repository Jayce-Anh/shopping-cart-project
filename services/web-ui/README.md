# Web UI

React single-page app for browsing products, using a cart, and placing orders.

## Overview

Web UI is the storefront. It is not a REST backend. It calls Catalog for products and Order for checkout. Inventory is not called from the browser; Catalog already attaches `inStock` to each product.

In production the built static files are hosted on S3 and served through CloudFront. `/api/*` on the same domain is routed to the ALB in front of the Spring Boot services. Locally, Vite (or nginx in Docker) serves the SPA.

In the shopping-cart flow:

1. Load products from Catalog (`GET /api/products`).
2. Add in-stock items to a client-side cart.
3. Place the order with Order (`POST /api/orders`).
4. Look up an order by ID (`GET /api/orders/{id}`).

## Features

- Product list with price and stock status
- Cart (quantity, total, customer email and address)
- Place order
- Search order by ID

Default port: **80** (nginx). Vite dev server uses its own port.

## Integrations

- **Catalog** — `GET /api/products`
- **Order** — `POST /api/orders`, `GET /api/orders/{id}`
- **S3 + CloudFront** — production hosting; API base URL via `VITE_API_BASE_URL` (empty = same origin)

## Stack

React 18, Vite, nginx (container). Production: S3 + CloudFront.
