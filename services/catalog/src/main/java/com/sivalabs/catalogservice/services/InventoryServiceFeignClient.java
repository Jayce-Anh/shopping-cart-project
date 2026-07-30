package com.sivalabs.catalogservice.services;

import com.sivalabs.catalogservice.web.models.ProductInventoryResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

@FeignClient(name = "inventory-service", url = "${inventory.service.url}")
public interface InventoryServiceFeignClient {

    @GetMapping("/api/inventory")
    List<ProductInventoryResponse> getInventoryLevels();

    @GetMapping("/api/inventory/{productCode}")
    ProductInventoryResponse getInventoryByProductCode(@PathVariable("productCode") String productCode);

}
