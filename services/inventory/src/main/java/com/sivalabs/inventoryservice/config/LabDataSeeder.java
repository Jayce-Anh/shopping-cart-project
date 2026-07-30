package com.sivalabs.inventoryservice.config;

import com.sivalabs.inventoryservice.entities.InventoryItem;
import com.sivalabs.inventoryservice.repositories.InventoryItemRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("lab")
public class LabDataSeeder implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(LabDataSeeder.class);

    private final InventoryItemRepository inventoryItemRepository;

    public LabDataSeeder(InventoryItemRepository inventoryItemRepository) {
        this.inventoryItemRepository = inventoryItemRepository;
    }

    @Override
    public void run(ApplicationArguments args) {
        if (inventoryItemRepository.count() > 0) {
            return;
        }

        log.info("Seeding inventory items for lab profile");

        inventoryItemRepository.save(inventoryItem("P001", 250));
        inventoryItemRepository.save(inventoryItem("P002", 132));
        inventoryItemRepository.save(inventoryItem("P003", 0));
        inventoryItemRepository.save(inventoryItem("P004", 88));
        inventoryItemRepository.save(inventoryItem("P005", 41));
        inventoryItemRepository.save(inventoryItem("P006", 210));

    }

    private static InventoryItem inventoryItem(String productCode, int quantity) {
        InventoryItem item = new InventoryItem();
        item.setProductCode(productCode);
        item.setAvailableQuantity(quantity);
        return item;
    }
}
