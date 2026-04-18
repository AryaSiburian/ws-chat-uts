package main

import (
	"fmt"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/websocket/v2"
	"github.com/golang-jwt/jwt/v4"
)

// Secret Key sesuai request
const jwtSecret = "rahasia123"

func main() {
	app := fiber.New()

<<<<<<< HEAD
	// CORS Setup: SANGAT PENTING untuk HttpOnly Cookie
	app.Use(cors.New(cors.Config{
		AllowOrigins:     "http://localhost:3000, http://127.0.0.1:3000", // Sesuaikan jika dites di Web
		AllowHeaders:     "Origin, Content-Type, Accept",
		AllowCredentials: true, // Wajib true agar cookie bisa lewat
=======
	// ── KONFIGURASI CORS FINAL (Sinkron dengan Flutter withCredentials) ──
	app.Use(cors.New(cors.Config{
		// Wajib mencantumkan http://localhost:3000 tempat Flutter Web berjalan
		AllowOrigins: "http://localhost:3000, http://127.0.0.1:3000, http://localhost:8080, http://10.0.2.2:8080",

		// Wajib ada OPTIONS (untuk preflight Chrome) dan PATCH (untuk update profil)
		AllowMethods: "GET,POST,PUT,PATCH,DELETE,OPTIONS",

		// Wajib izinkan Cookie dan Authorization
		AllowHeaders: "Origin, Content-Type, Accept, Authorization, Cookie, X-Requested-With",

		// Bumbu Rahasia: Beri tahu Chrome bahwa server mengirim Cookie
		ExposeHeaders: "Set-Cookie",

		// KUNCI UTAMA: Wajib true agar browser mau simpan cookie dari server
		AllowCredentials: true,
>>>>>>> a533654 (memperbarui set cookie)
	}))
	// ──────────────────────────────────────────────────────────────────────

	// API Login
	app.Post("/api/auth/login", func(c *fiber.Ctx) error {
		// Asumsi validasi email & password sukses...

		// Buat JWT Token
		token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
			"user_id": "123",
			"exp":     time.Now().Add(time.Hour * 24).Unix(),
		})
		tokenString, _ := token.SignedString([]byte(jwtSecret))

		// Set HttpOnly Cookie
		c.Cookie(&fiber.Cookie{
			Name:     "jwt_token",
			Value:    tokenString,
			Expires:  time.Now().Add(24 * time.Hour),
			HTTPOnly: true,  // Amankan dari XSS
			Secure:   false, // Set true jika nanti pakai HTTPS
			SameSite: "Lax",
			Path:     "/",
		})

		// Kirim response sukses sesuai format yang diharapkan Frontend
		return c.JSON(fiber.Map{
			"message": "Login berhasil",
			"token":   tokenString, // Opsional: Boleh dikirim jika masih butuh di SharedPreferences untuk hal lain, tapi WS akan pakai Cookie
		})
	})

	// Middleware untuk membaca HttpOnly Cookie
	authMiddleware := func(c *fiber.Ctx) error {
		tokenStr := c.Cookies("jwt_token")
		if tokenStr == "" {
			return c.Status(401).JSON(fiber.Map{"error": "Unauthorized: Cookie tidak ada"})
		}

		token, err := jwt.Parse(tokenStr, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method")
			}
			return []byte(jwtSecret), nil
		})

		if err != nil || !token.Valid {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Unauthorized: Token tidak valid"})
		}

		return c.Next()
	}

<<<<<<< HEAD
	// Endpoint WebSocket
	app.Get("/ws", authMiddleware, websocket.New(func(c *websocket.Conn) {
		fmt.Println("Client terhubung ke WebSocket!")

		// Kirim pesan selamat datang
		c.WriteMessage(websocket.TextMessage, []byte("Selamat datang di Signal Chat WS!"))

		for {
			mt, msg, err := c.ReadMessage()
			if err != nil {
				fmt.Println("Client terputus:", err)
				break
			}
			fmt.Printf("Pesan diterima: %s\n", msg)

			// Echo: Kirim balik pesan ke client
			c.WriteMessage(mt, msg)
		}
	}))

	fmt.Println("Server Backend jalan di http://localhost:8080")
	app.Listen(":8080")
=======
	log.Println("🚀 Server running on http://localhost:" + port)
	log.Fatal(app.Listen(":" + port))
>>>>>>> a533654 (memperbarui set cookie)
}
