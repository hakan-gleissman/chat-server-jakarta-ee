package se.sprinto.hakan.demojakartafacelets2026.service;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import se.sprinto.hakan.demojakartafacelets2026.model.HelloMessage;
import se.sprinto.hakan.demojakartafacelets2026.repository.HelloRepository;

import java.util.List;
import java.util.logging.Logger;

@ApplicationScoped
public class HelloService {
    @Inject
    private HelloRepository helloRepository;
    private static final Logger LOGGER =
            Logger.getLogger(HelloService.class.getName());

    public List<HelloMessage> getAllMessages() {
        LOGGER.info("getAllMessages() hello");
        return helloRepository.getMessages();
    }
}
