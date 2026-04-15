package main

import (
	"backend-go/config"
	"backend-go/routers"
	"log"
	"os"

	_ "backend-go/docs"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors" // 1. TAMBAHKAN IMPORT INI
	"github.com/gofiber/fiber/v2/middleware/logger"
	swagger "github.com/swaggo/fiber-swagger"
)

func main() {
	config.LoadEnv()
	config.ConnectDatabase()

	app := fiber.New(fiber.Config{
		AppName: "Chat System API v1.0",
	})

	// 2. TAMBAHKAN KODE CORS INI AGAR FLUTTER WEB BISA MASUK
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*", // Mengizinkan semua port/website
		AllowHeaders: "Origin, Content-Type, Accept",
	}))

	app.Use(logger.New())

	routers.SetupRoutes(app)

	app.Get("/swagger/*", swagger.WrapHandler)
	app.Get("/", func(c *fiber.Ctx) error { return c.Redirect("/swagger/index.html") })

	port := os.Getenv("APP_PORT")
	if port == "" {
		port = "8080"
	}

	log.Println("🚀 Server running on http://localhost:" + port)
	log.Fatal(app.Listen(":" + port))
}
