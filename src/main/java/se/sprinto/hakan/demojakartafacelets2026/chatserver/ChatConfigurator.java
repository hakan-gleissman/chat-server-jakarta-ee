package se.sprinto.hakan.demojakartafacelets2026.chatserver;

import jakarta.websocket.server.ServerEndpointConfig;

public class ChatConfigurator extends ServerEndpointConfig.Configurator {

    @Override
    public boolean checkOrigin(String originHeaderValue) {
        return true; // Tillåt alla (för kurs)
    }
}
