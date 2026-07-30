#!/bin/bash
set -euo pipefail

awslocal sqs create-queue --queue-name lab-shopping-cart-order-events
