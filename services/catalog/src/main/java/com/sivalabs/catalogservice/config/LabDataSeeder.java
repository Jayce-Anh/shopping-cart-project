package com.sivalabs.catalogservice.config;

import com.sivalabs.catalogservice.entities.Product;
import com.sivalabs.catalogservice.repositories.ProductRepository;
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

    private final ProductRepository productRepository;

    public LabDataSeeder(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    @Override
    public void run(ApplicationArguments args) {
        if (productRepository.count() > 0) {
            return;
        }

        log.info("Seeding catalog products for lab profile");

        productRepository.save(product("P001", "Aurora Wireless Headphones",
                "Over-ear Bluetooth headphones with active noise canceling and 30-hour battery life.", 129));
        productRepository.save(product("P002", "Nordic Pour-Over Set",
                "Hand-thrown ceramic dripper with borosilicate carafe for clean, slow-brew coffee.", 48));
        productRepository.save(product("P003", "Merino Travel Scarf",
                "Lightweight merino wool scarf that packs flat and regulates temperature on the go.", 65));
        productRepository.save(product("P004", "Lumen Desk Lamp",
                "Matte aluminum task lamp with warm dimmable LED and USB-C charging port.", 42));
        productRepository.save(product("P005", "Weekender Leather Tote",
                "Full-grain leather tote with roomy interior pocket and reinforced cotton handles.", 89));
        productRepository.save(product("P006", "Orbit Steel Bottle",
                "Insulated stainless bottle that keeps drinks cold 24 hours or hot for 12.", 28));

    }

    private static Product product(String code, String name, String description, double price) {
        Product product = new Product();
        product.setCode(code);
        product.setName(name);
        product.setDescription(description);
        product.setPrice(price);
        return product;
    }
}
