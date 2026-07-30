package com.sivalabs.inventoryservice.messaging;

import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.aws.messaging.listener.annotation.SqsListener;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile({"lab", "compose"})
@Slf4j
public class OrderPlacedListener {

    @SqsListener("${AWS_SQS_ORDER_QUEUE_URL}")
    public void handleOrderPlaced(OrderPlacedEvent event) {
        log.info("Received order placed event from SQS: orderId={}, items={}",
                event.getOrderId(), event.getItems());
    }
}
