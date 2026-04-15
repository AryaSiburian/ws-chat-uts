package routers

import (
	"backend-go/handlers"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App) {

	api := app.Group("/api")

	// ─── AUTH (auth.go) ───────────────────────────────
	auth := api.Group("/auth")
	auth.Post("/register", handlers.Register)
	auth.Post("/login", handlers.Login)

	// ─── USERS / BOARD USER (boarduser.go) ───────────
	users := api.Group("/users")
	users.Get("/", handlers.GetAllUsers)      // GET  /api/users
	users.Get("/:id", handlers.GetUserByID)   // GET  /api/users/1
	users.Put("/:id", handlers.UpdateUser)    // PUT  /api/users/1
	users.Delete("/:id", handlers.DeleteUser) // DELETE /api/users/1
}
