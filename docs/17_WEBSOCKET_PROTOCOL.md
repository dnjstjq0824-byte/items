# 17. REAL-TIME WEBSOCKET PROTOCOL SPECIFICATION

**Document ID:** BN-DOC-017  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 14)  

---

## 1. Connection & Authentication
- Endpoint: `GET /api/v1/ws/chat?user_id={UUID}`
- Protocol: RFC 6455 WebSocket Upgrade
- Handshake validates session token or user identity against active session repository.

---

## 2. Event Dispatch Flow

```mermaid
sequenceDiagram
    autonumber
    participant ClientA as Buyer App
    participant GW as WebSocket Gateway
    participant Risk as Fraud & Risk Engine
    participant DB as PostgreSQL
    participant ClientB as Seller App

    ClientA->>GW: chat.message.send {conversation_id, payload, client_message_id}
    GW->>Risk: Scan Content (phishing, discord/telegram off-platform leaks)
    alt Content Clean
        GW->>DB: Persist chat_message (Assign monotonic SequenceNo)
        GW-->>ClientA: chat.message.ack {client_message_id, server_message_id, sequence_no}
        GW-->>ClientB: chat.message.received {message}
    else Suspicious Link or Pattern Detected
        GW-->>ClientA: chat.system.warning {action: "BLOCK", reason: "Phishing/off-platform forbidden"}
    end
```

