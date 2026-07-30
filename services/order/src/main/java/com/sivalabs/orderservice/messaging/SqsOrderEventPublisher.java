package com.sivalabs.orderservice.messaging;

import com.sivalabs.orderservice.entities.Order;
import com.sivalabs.orderservice.entities.OrderItem;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.aws.messaging.core.QueueMessagingTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

import java.util.stream.Collectors;

@Service
@Profile({"lab", "compose"})
@Slf4j
public class SqsOrderEventPublisher implements OrderEventPublisher {

    private final QueueMessagingTemplate queueMessagingTemplate;
    private final String queueName;

    public SqsOrderEventPublisher(QueueMessagingTemplate queueMessagingTemplate,
                                  @Value("${order.queue.name}") String queueName) {
        this.queueMessagingTemplate = queueMessagingTemplate;
        this.queueName = queueName;
    }

    @Override
    public void publish(Order order) {
        OrderPlacedEvent event = new OrderPlacedEvent(
                order.getId(),
                order.getItems().stream()
                        .map(item -> new OrderPlacedEvent.OrderItemEvent(item.getProductId(), item.getQuantity()))
                        .collect(Collectors.toList())
        );
        try {
            queueMessagingTemplate.convertAndSend(queueName, event);
            log.info("Published order placed event to SQS queue {}: orderId={}", queueName, order.getId());
        } catch (Exception ex) {
            log.error("Failed to publish order event to SQS queue {}: orderId={}", queueName, order.getId(), ex);
        }
    }
}
