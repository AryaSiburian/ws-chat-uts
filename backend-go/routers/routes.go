package routers

import (
	"backend-go/handlers"

	"backend-go/middleware"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App) {

	api := app.Group("/api")

	profile := api.Group("/profile", middleware.AuthMiddleware)
	user := api.Group("/users")
	auth := api.Group("/auth")

	auth.Post("/register", handlers.Register)
	auth.Post("/login", handlers.Login)

	profile.Get("/me", handlers.GetMyProfile)
	profile.Patch("/me", handlers.UpdateMyProfile)

	user.Get("/", handlers.GetUsers)
	user.Get("/:id", handlers.GetUserByID)

}
