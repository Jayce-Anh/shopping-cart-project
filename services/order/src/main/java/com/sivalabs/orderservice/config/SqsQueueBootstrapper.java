package com.sivalabs.orderservice.config;

import com.amazonaws.services.sqs.AmazonSQSAsync;
import com.amazonaws.services.sqs.model.CreateQueueRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;

@Component
@Profile("compose")
@Slf4j
public class SqsQueueBootstrapper {

    private final AmazonSQSAsync amazonSQSAsync;
    private final String queueName;

    public SqsQueueBootstrapper(AmazonSQSAsync amazonSQSAsync,
                                @Value("${order.queue.name}") String queueName) {
        this.amazonSQSAsync = amazonSQSAsync;
        this.queueName = queueName;
    }

    @PostConstruct
    public void ensureQueueExists() {
        amazonSQSAsync.createQueue(new CreateQueueRequest(queueName));
        log.info("Ensured SQS queue exists: {}", queueName);
    }
}
