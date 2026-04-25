package middleware

import (
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"

	"backend-go/config"
)

func AuthMiddleware(c *fiber.Ctx) error {

	if c.Method() == "OPTIONS" {
		return c.Next()
	}

	authHeader := c.Get("Authorization")

	if authHeader == "" {
		return c.Status(401).JSON(fiber.Map{"message": "missing token"})
	}

	// Perbaikan: Cek apakah ada prefix Bearer, jika ada hapus. Jika tidak, pakai apa adanya.
	tokenString := authHeader
	if strings.HasPrefix(authHeader, "Bearer ") {
		tokenString = strings.TrimPrefix(authHeader, "Bearer ")
	}

	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return []byte(config.GetEnv("JWT_ACCESS_SECRET")), nil
	})

	// Debugging: Jika masih error, print err di sini untuk lihat kenapa gagal
	if err != nil || !token.Valid {
		return c.Status(401).JSON(fiber.Map{"message": "invalid token", "details": err.Error()})
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return c.Status(401).JSON(fiber.Map{"message": "invalid claims"})
	}

	// Pastikan user_id ada di claims
	if claims["user_id"] == nil {
		return c.Status(401).JSON(fiber.Map{"message": "user_id not found in token"})
	}

	userIDStr := claims["user_id"].(string)
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "invalid user id format"})
	}

	c.Locals("user_id", userID)
	return c.Next()
}
