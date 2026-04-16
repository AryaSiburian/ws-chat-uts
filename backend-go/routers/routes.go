package routers

import (
	"backend-go/handlers"

	"backend-go/middleware"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App) {

	api := app.Group("/api")
	profile := app.Group("/api/profile", middleware.AuthMiddleware)

	auth := api.Group("/auth")
	auth.Post("/register", handlers.Register)
	auth.Post("/login", handlers.Login)

	profile.Get("/me", handlers.GetMyProfile)
	profile.Patch("/me", handlers.UpdateMyProfile)
}
