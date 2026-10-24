package chat

import (
	"context"
	"encoding/json"
	"net/http"
	"sync"
	"time"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/risk"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Configurable for CORS in production
	},
}

type ClientMessageDTO struct {
	Type            string          `json:"type"` // "chat.message.send", "chat.message.read"
	ConversationID  uuid.UUID       `json:"conversation_id"`
	ClientMessageID uuid.UUID       `json:"client_message_id"`
	Payload         json.RawMessage `json:"payload"`
}

type ServerAckDTO struct {
	Type            string    `json:"type"` // "chat.message.ack"
	ClientMessageID uuid.UUID `json:"client_message_id"`
	ServerMessageID uuid.UUID `json:"server_message_id"`
	SequenceNo      int64     `json:"sequence_no"`
	Timestamp       time.Time `json:"timestamp"`
}

type Gateway struct {
	mu            sync.RWMutex
	riskEngine    *risk.Engine
	clients       map[uuid.UUID]*websocket.Conn
	conversations map[uuid.UUID]*domain.Conversation
	messages      map[uuid.UUID][]domain.ChatMessage
	seqTracker    map[uuid.UUID]int64
}

func NewGateway(riskEngine *risk.Engine) *Gateway {
	return &Gateway{
		riskEngine:    riskEngine,
		clients:       make(map[uuid.UUID]*websocket.Conn),
		conversations: make(map[uuid.UUID]*domain.Conversation),
		messages:      make(map[uuid.UUID][]domain.ChatMessage),
		seqTracker:    make(map[uuid.UUID]int64),
	}
}

func (g *Gateway) RegisterConversation(conv *domain.Conversation) {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.conversations[conv.ID] = conv
}

// HandleWebSocket upgrades incoming connection and starts client loop
func (g *Gateway) HandleWebSocket(w http.ResponseWriter, r *http.Request, userID uuid.UUID) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		http.Error(w, "Failed to upgrade websocket", http.StatusBadRequest)
		return
	}

	g.mu.Lock()
	g.clients[userID] = conn
	g.mu.Unlock()

	defer func() {
		g.mu.Lock()
		delete(g.clients, userID)
		g.mu.Unlock()
		conn.Close()
	}()

	for {
		_, p, err := conn.ReadMessage()
		if err != nil {
			break
		}

		var clientMsg ClientMessageDTO
		if err := json.Unmarshal(p, &clientMsg); err != nil {
			continue
		}

		if clientMsg.Type == "chat.message.send" {
			var bodyPayload struct {
				Type string `json:"type"`
				Body string `json:"body"`
			}
			if err := json.Unmarshal(clientMsg.Payload, &bodyPayload); err != nil {
				continue
			}

			// Risk & Phishing scan (Article 14.5 & Article 20)
			action, _ := g.riskEngine.EvaluateMessageContent(context.Background(), userID, bodyPayload.Body)
			if action == "BLOCK" {
				warnMsg := ServerAckDTO{
					Type:            "chat.system.warning",
					ClientMessageID: clientMsg.ClientMessageID,
					Timestamp:       time.Now(),
				}
				_ = conn.WriteJSON(warnMsg)
				continue
			}

			g.mu.Lock()
			g.seqTracker[clientMsg.ConversationID]++
			seq := g.seqTracker[clientMsg.ConversationID]

			msgID := uuid.New()
			msg := domain.ChatMessage{
				ID:              msgID,
				ConversationID:  clientMsg.ConversationID,
				SenderUserID:    userID,
				ClientMessageID: clientMsg.ClientMessageID,
				SequenceNo:      seq,
				MessageType:     bodyPayload.Type,
				Body:            bodyPayload.Body,
				Status:          "SENT",
				CreatedAt:       time.Now(),
			}

			g.messages[clientMsg.ConversationID] = append(g.messages[clientMsg.ConversationID], msg)
			g.mu.Unlock()

			// Return immediate Ack
			ack := ServerAckDTO{
				Type:            "chat.message.ack",
				ClientMessageID: clientMsg.ClientMessageID,
				ServerMessageID: msgID,
				SequenceNo:      seq,
				Timestamp:       msg.CreatedAt,
			}
			_ = conn.WriteJSON(ack)
		}
	}
}

func (g *Gateway) GetMessages(convID uuid.UUID) []domain.ChatMessage {
	g.mu.RLock()
	defer g.mu.RUnlock()
	return g.messages[convID]
}
