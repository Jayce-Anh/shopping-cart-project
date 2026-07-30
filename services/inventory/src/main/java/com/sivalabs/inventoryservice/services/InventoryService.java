package com.sivalabs.inventoryservice.services;

import com.sivalabs.inventoryservice.entities.InventoryItem;
import com.sivalabs.inventoryservice.repositories.InventoryItemRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional(readOnly = true)
@Slf4j
public class InventoryService {

    private final InventoryItemRepository inventoryItemRepository;

    @Autowired
    public InventoryService(InventoryItemRepository inventoryItemRepository) {
        this.inventoryItemRepository = inventoryItemRepository;
    }

    @Cacheable(value = "inventory", key = "#productCode")
    public Optional<InventoryItem> findByProductCode(String productCode) {
        log.info("Loading inventory from database for product code: {}", productCode);
        return inventoryItemRepository.findByProductCode(productCode);
    }

    @Cacheable(value = "inventory", key = "'all'")
    public List<InventoryItem> findAll() {
        log.info("Loading all inventory from database");
        return inventoryItemRepository.findAll();
    }
}
