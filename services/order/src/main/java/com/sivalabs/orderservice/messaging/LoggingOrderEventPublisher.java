package com.sivalabs.orderservice.messaging;

import com.sivalabs.orderservice.entities.Order;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

@Service
@Profile("local")
@Slf4j
public class LoggingOrderEventPublisher implements OrderEventPublisher {

    @Override
    public void publish(Order order) {
        log.info("Order placed locally (SQS disabled): orderId={}", order.getId());
    }
}
