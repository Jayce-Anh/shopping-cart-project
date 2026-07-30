package com.sivalabs.catalogservice.services;

import com.sivalabs.catalogservice.utils.MyThreadLocalsHolder;
import com.sivalabs.catalogservice.web.models.ProductInventoryResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@Slf4j
public class InventoryServiceClient {
    private final RestTemplate restTemplate;
    private final InventoryServiceFeignClient inventoryServiceFeignClient;
    private final String inventoryServiceUrl;

    @Autowired
    public InventoryServiceClient(RestTemplate restTemplate,
                                  InventoryServiceFeignClient inventoryServiceFeignClient,
                                  @Value("${inventory.service.url}") String inventoryServiceUrl) {
        this.restTemplate = restTemplate;
        this.inventoryServiceFeignClient = inventoryServiceFeignClient;
        this.inventoryServiceUrl = inventoryServiceUrl;
    }

    public List<ProductInventoryResponse> getProductInventoryLevels() {
        try {
            return this.inventoryServiceFeignClient.getInventoryLevels();
        } catch (Exception ex) {
            log.warn("Inventory service unavailable, returning empty inventory levels", ex);
            return new ArrayList<>();
        }
    }

    public Optional<ProductInventoryResponse> getProductInventoryByCode(String productCode) {
        log.info("CorrelationID: {}", MyThreadLocalsHolder.getCorrelationId());
        try {
            ProductInventoryResponse response =
                    restTemplate.getForObject(
                            inventoryServiceUrl + "/api/inventory/{code}",
                            ProductInventoryResponse.class,
                            productCode);
            if (response != null) {
                log.info("Available quantity: {}", response.getAvailableQuantity());
                return Optional.of(response);
            }
        } catch (Exception ex) {
            log.warn("Unable to get inventory level for product_code: {}", productCode, ex);
        }
        return Optional.empty();
    }
}
