package main

import (
	"backend-go/config"
	"backend-go/routers"
	"log"
	"os"

	_ "backend-go/docs"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	swagger "github.com/swaggo/fiber-swagger"
)

func main() {
	config.LoadEnv()
	config.ConnectDatabase()

	app := fiber.New(fiber.Config{
		AppName: "E-Library API v1.0",
	})

	app.Use(cors.New(cors.Config{
		AllowOrigins:     "http://localhost:3000, http://127.0.0.1:3000, http://localhost:8080, http://10.0.2.2:8080, http://127.0.0.1:8080, http://localhost, http://127.0.0.1, http://10.0.2.2",
		AllowMethods:     "GET,POST,PUT,DELETE,OPTIONS",
		AllowHeaders:     "Origin, Content-Type, Accept, Authorization, Cookie",
		AllowCredentials: true,
	}))

	app.Use(logger.New())

	routers.SetupRoutes(app)

	app.Get("/swagger/*", swagger.WrapHandler)

	app.Get("/", func(c *fiber.Ctx) error {
		return c.Redirect("/swagger/index.html")
	})

	port := os.Getenv("APP_PORT")
	if port == "" {
		port = "8080"
	}

	log.Println("Server running on http://localhost:" + port)
	log.Fatal(app.Listen(":" + port))
}
