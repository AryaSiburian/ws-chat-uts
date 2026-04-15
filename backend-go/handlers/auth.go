package handlers

import (
	"backend-go/model"
	// "net/http"
	"strings"
	"time"

	"backend-go/config"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

// Register godoc
// @Summary      Daftar User WebSystem
// @Description  Membuat akun baru untuk mengakses API yang diproteksi
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        user  body    model.RegisterRequest  true  "Username & Password"
// @Success      201   {object}  map[string]string
// @Router /api/auth/register [post]
func Register(c *fiber.Ctx) error {
	var user model.User

	if err := c.BodyParser(&user); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Format data tidak valid",
		})
	}

	if strings.TrimSpace(user.Username) == "" {
		return c.Status(400).JSON(fiber.Map{"Message": "Username tidak boleh kosong"})
	}

	if !strings.Contains(user.Email, "@") {
		return c.Status(400).JSON(fiber.Map{"message": "Format email tidak valid, harus mengandung @"})
	}

	if len(user.Password) < 8 {
		return c.Status(400).JSON(fiber.Map{"message": "Password minimal 8 karakter"})
	}

	var existingUser model.User
	if err := config.DB.Where("email = ?", user.Email).First(&existingUser).Error; err == nil {
		return c.Status(409).JSON(fiber.Map{"message": "Email sudah terdaftar"})
	}

	if err := config.DB.Where("username = ?", user.Username).First(&existingUser).Error; err == nil {
		return c.Status(409).JSON(fiber.Map{"message": "Username sudah digunakan"})
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Password gagal di hash"})
	}
	user.Password = string(hashedPassword)

	if err := config.DB.Create(&user).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Gagal disimpan ke database"})
	}

	return c.Status(201).JSON(fiber.Map{"message": "Email Berhasil Terdaftar"})
}

// Login godoc
// @Summary      Login User
// @Description  Masukan username & password untuk mendapatkan token JWT
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        login  body      model.LoginRequest  true  "Username & Password"
// @Success      200    {object}  map[string]string
// @Router /api/auth/login [post]
func Login(c *fiber.Ctx) error {
	var req model.LoginRequest
	var user model.User

	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Gagal Parsing Data"})
	}

	if err := config.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Email tidak ditemukan"})
	}

	if !strings.Contains(req.Email, "@") {
		return c.Status(400).JSON(fiber.Map{"message": "Format email tidak valid"})
	}

	if strings.TrimSpace(req.Email) == "" {
		return c.Status(400).JSON(fiber.Map{"message": "Email tidak boleh kosong"})
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Password Salah"})
	}

	if strings.TrimSpace(req.Password) == "" {
		return c.Status(400).JSON(fiber.Map{"message": "Password tidak boleh kosong"})
	}

	claims := jwt.MapClaims{
		"user_id": user.ID,
		"exp":     time.Now().Add(time.Hour * 72).Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	secretkey := config.GetEnv("JWT_SECRET")
	t, err := token.SignedString([]byte(secretkey))
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Gagal membuat token"})
	}

	return c.JSON(fiber.Map{
		"message": "Login berhasil",
		"token":   t,
	})
}
