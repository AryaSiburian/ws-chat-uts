package models

import (
	"time"

	"gorm.io/gorm"
)

type User struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	Username  string         `json:"username" gorm:"unique;not null"`
	Password  string         `json:"-" gorm:"not null"`
	Status    string         `json:"status" gorm:"default:offline"` // online/offline
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

type Message struct {
	ID         uint      `json:"id" gorm:"primaryKey"`
	SenderID   uint      `json:"sender_id" gorm:"index"`   // B-Tree Index otomatis
	ReceiverID uint      `json:"receiver_id" gorm:"index"` // B-Tree Index otomatis
	Content    string    `json:"content" gorm:"type:text"` // Nanti dipasang GIN Index di sini
	IsRead     bool      `json:"is_read" gorm:"default:false"`
	CreatedAt  time.Time `json:"created_at" gorm:"index"`
}

//DTO (Data Transfer Objects untuk API & WebSocket)

// Digunakan saat User Login/Register
type AuthRequest struct {
	Username string `json:"username" validate:"required"`
	Password string `json:"password" validate:"required,min=6"`
}

// Digunakan untuk Payload WebSocket (Lalu lintas pesan real-time)
type ChatPayload struct {
	Type     string    `json:"type"`      // "chat", "typing", "notification"
	TargetID uint      `json:"target_id"` // ID penerima
	Content  string    `json:"content"`
	SentAt   time.Time `json:"sent_at"`
}

// Standard Web Response agar Flutter konsisten membacanya
type WebResponse struct {
	Code    int         `json:"code"`
	Status  string      `json:"status"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

type ErrorResponse struct {
	Code    int    `json:"code"`
	Status  string `json:"status"`
	Message string `json:"message"`
}
