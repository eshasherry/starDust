package com;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Created by esherry on 2019-02-12.
 */

@EnableAutoConfiguration
@RestController
public class StarDust {

    @RequestMapping("/starDust")
    String message(){
        return "Hello world";
    }

    public static void main(String[] args) {
        SpringApplication.run(StarDust.class, args);

    }
}
