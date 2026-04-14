package main

import (
	"backend-go/config"
	"backend-go/routers"

	// "context"
	"log"
	"os"

	_ "backend-go/docs"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
	swagger "github.com/swaggo/fiber-swagger"
)

// var ctx = context.Background()

func main() {
	config.LoadEnv()
	config.ConnectDatabase()
	// 2. Inisialisasi Fiber App
	app := fiber.New(fiber.Config{
		AppName: "E-Library API v1.0",
	})

	app.Use(logger.New())

	routers.SetupRoutes(app)

	// 5. Route Khusus untuk Swagger UI
	// Akses di: http://localhost:3001/swagger/index.html
	app.Get("/swagger/*", swagger.WrapHandler)

	// 6. Redirect halaman utama ke Swagger (Opsional tapi membantu)
	app.Get("/", func(c *fiber.Ctx) error {
		return c.Redirect("/swagger/index.html")
	})

	port := os.Getenv("APP_PORT")
	if port == "" {
		port = "8080"
	}
	// 7. Jalankan Server
	log.Println("🚀 Server running on http://localhost:" + port)
	log.Fatal(app.Listen(":" + port))

	// // 2. Test Koneksi Redis
	// redisHost := os.Getenv("REDIS_HOST")
	// if redisHost == "" {
	// 	redisHost = "localhost"
	// }

	// rdb := redis.NewClient(&redis.Options{
	// 	Addr: fmt.Sprintf("%s:6379", redisHost),
	// })

	// if err := rdb.Ping(ctx).Err(); err != nil {
	// 	log.Printf("⚠️ Redis belum aktif: %v", err)
	// } else {
	// 	fmt.Println("✅ Terhubung ke Redis!")
	// }

	// // 3. Server Sederhana
	// http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
	// 	fmt.Fprintf(w, "Backend Chat System Is Running!")
	// })

	// fmt.Println("🚀 Server jalan di port 8080")
	// log.Fatal(http.ListenAndServe(":8080", nil))
}
