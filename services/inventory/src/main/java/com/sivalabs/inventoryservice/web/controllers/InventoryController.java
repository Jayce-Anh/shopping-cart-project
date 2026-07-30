package com.sivalabs.inventoryservice.web.controllers;

import com.sivalabs.inventoryservice.entities.InventoryItem;
import com.sivalabs.inventoryservice.services.InventoryService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@Slf4j
public class InventoryController {
    private final InventoryService inventoryService;

    @Autowired
    public InventoryController(InventoryService inventoryService) {
        this.inventoryService = inventoryService;
    }

    @GetMapping("/api/inventory/{productCode}")
    public ResponseEntity<InventoryItem> findInventoryByProductCode(@PathVariable("productCode") String productCode) {
        log.info("Finding inventory for product code: {}", productCode);
        return inventoryService.findByProductCode(productCode)
                .map(item -> new ResponseEntity<>(item, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @GetMapping("/api/inventory")
    public List<InventoryItem> getInventory() {
        log.info("Finding inventory for all products");
        return inventoryService.findAll();
    }
}
