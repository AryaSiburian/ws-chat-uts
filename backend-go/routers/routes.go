package routers

import (
	"backend-go/handlers"
	"backend-go/middleware"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/websocket/v2"
)

func SetupRoutes(app *fiber.App) {

	// --- SETUP WEBSOCKET ---
	app.Use("/ws", func(c *fiber.Ctx) error {
		if websocket.IsWebSocketUpgrade(c) {
			return c.Next()
		}
		return fiber.ErrUpgradeRequired
	})
	app.Get("/ws", websocket.New(handlers.WsHandler))

	// --- RUTE UPDATE PROFILE (Level Utama) ---
	// Agar sinkron dengan Flutter: http://localhost:8080/patch/update/:id
	app.Patch("/patch/update/:id", handlers.UpdateProfileByID)

	// --- GRUP API ---
	api := app.Group("/api")

	profile := api.Group("/profile", middleware.AuthMiddleware)
	user := api.Group("/users")
	auth := api.Group("/auth")

	// Auth
	auth.Post("/register", handlers.Register)
	auth.Post("/login", handlers.Login)

	// Profile (Milik User Sendiri)
	profile.Get("/me", handlers.GetMyProfile)
	profile.Patch("/me", handlers.UpdateMyProfile)

	// Users (Admin/General)
	user.Get("/", handlers.GetUsers)
	user.Get("/:id", handlers.GetUserByID)
}
