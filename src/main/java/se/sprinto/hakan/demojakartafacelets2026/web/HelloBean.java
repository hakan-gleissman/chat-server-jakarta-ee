package se.sprinto.hakan.demojakartafacelets2026.web;

import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import se.sprinto.hakan.demojakartafacelets2026.model.HelloMessage;
import se.sprinto.hakan.demojakartafacelets2026.service.HelloService;

import java.io.Serializable;
import java.util.List;

@Named
@ViewScoped
public class HelloBean implements Serializable {

    private static final long serialVersionUID = 1L;
    @Inject
    private HelloService helloService;

    public String getMessage() {
        return "Hello world!";
    }

    public List<HelloMessage> getMessages() {
        return helloService.getAllMessages();
    }
}
