package routers

import (
	"backend-go/handlers"
	"backend-go/middleware"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/websocket/v2" // Pastikan ini ter-import
)

func SetupRoutes(app *fiber.App) {

	// --- SETUP WEBSOCKET ---
	// Middleware khusus untuk mengecek apakah request ini minta upgrade ke WebSocket
	app.Use("/ws", func(c *fiber.Ctx) error {
		if websocket.IsWebSocketUpgrade(c) {
			return c.Next()
		}
		return fiber.ErrUpgradeRequired
	})

	// Rute WebSocket-nya
	app.Get("/ws", websocket.New(handlers.WsHandler))
	// -----------------------

	api := app.Group("/api")
	profile := app.Group("/api/profile", middleware.AuthMiddleware)

	auth := api.Group("/auth")
	auth.Post("/register", handlers.Register)
	auth.Post("/login", handlers.Login)

	profile.Get("/me", handlers.GetMyProfile)
	profile.Patch("/me", handlers.UpdateMyProfile)
}
