package com.sivalabs.orderservice.messaging;

import com.sivalabs.orderservice.entities.Order;

public interface OrderEventPublisher {
    void publish(Order order);
}
