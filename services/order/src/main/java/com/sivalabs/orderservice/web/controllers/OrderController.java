package com.sivalabs.orderservice.web.controllers;

import com.sivalabs.orderservice.entities.Order;
import com.sivalabs.orderservice.messaging.OrderEventPublisher;
import com.sivalabs.orderservice.repositories.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
public class OrderController {

    private final OrderRepository repo;
    private final OrderEventPublisher orderEventPublisher;

    @Autowired
    public OrderController(OrderRepository repo, OrderEventPublisher orderEventPublisher) {
        this.repo = repo;
        this.orderEventPublisher = orderEventPublisher;
    }

    @PostMapping("/api/orders")
    public Order createOrder(@RequestBody Order order) {
        Order saved = repo.save(order);
        orderEventPublisher.publish(saved);
        return saved;
    }

    @GetMapping("/api/orders/{id}")
    public ResponseEntity<Order> findOrderById(@PathVariable Long id) {
        return repo.findByIdWithItems(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

}
