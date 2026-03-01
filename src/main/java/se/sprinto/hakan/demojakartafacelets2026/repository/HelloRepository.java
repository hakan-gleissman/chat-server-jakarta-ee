package se.sprinto.hakan.demojakartafacelets2026.repository;

import jakarta.enterprise.context.ApplicationScoped;
import se.sprinto.hakan.demojakartafacelets2026.model.HelloMessage;

import java.util.List;

@ApplicationScoped
public class HelloRepository {
//    @PersistenceContext(unitName = "jakarta-ee-demo")
//    private EntityManager entityManager;

    public List<HelloMessage> getMessages() {
//        return entityManager
//                .createQuery("SELECT m FROM HelloMessage m", HelloMessage.class)
//                .getResultList();
        HelloMessage message = new HelloMessage();
        message.setMessage("Hello world");
        message.setId(1l);
        return List.of(message);
    }

}
