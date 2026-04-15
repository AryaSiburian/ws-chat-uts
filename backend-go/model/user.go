package model

import "time"

// ─────────────────────────────────────────
//
//	DATABASE TABLE
//
// ─────────────────────────────────────────
type User struct {
	ID        uint      `gorm:"primaryKey"     json:"id"`
	Username  string    `gorm:"unique;not null" json:"username"`
	Email     string    `gorm:"unique;not null" json:"email"`
	Password  string    `json:"password"       example:"rahasia123"`
	CreatedAt time.Time `json:"created_at"`
}

// ─────────────────────────────────────────
//
//	AUTH REQUEST
//
// ─────────────────────────────────────────
type RegisterRequest struct {
	Username string `json:"username" binding:"required"`
	Email    string `json:"email"    binding:"required,email"`
	Password string `json:"password" binding:"required,min=8"`
}

type LoginRequest struct {
	Email    string `json:"email"    binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// ─────────────────────────────────────────
//
//	BOARDUSER REQUEST & RESPONSE
//
// ─────────────────────────────────────────
type UpdateUserRequest struct {
	Username string `json:"username" example:"userbaru"`
	Email    string `json:"email"    example:"baru@email.com"`
}

type UserResponse struct {
	ID        uint      `json:"id"`
	Username  string    `json:"username"`
	Email     string    `json:"email"`
	CreatedAt time.Time `json:"created_at"`
}

// ─────────────────────────────────────────
//
//	GENERIC RESPONSE
//
// ─────────────────────────────────────────
type ErrorResponse struct {
	Message string `json:"message"`
}

type SuccessResponse struct {
	Message string `json:"message"`
}
