package handlers

import (
	"backend-go/model"
	// "net/http"
	"strings"
	"time"

	"backend-go/config"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
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
// @Router /auth/register [post]
func Register(c *fiber.Ctx) error {
	var req model.RegisterRequest

	// 1. parse request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Format data tidak valid",
		})
	}

	// 2. validation
	if strings.TrimSpace(req.Username) == "" {
		return c.Status(400).JSON(fiber.Map{
			"message": "Username tidak boleh kosong",
		})
	}

	if !strings.Contains(req.Email, "@") {
		return c.Status(400).JSON(fiber.Map{
			"message": "Format email tidak valid",
		})
	}

	if len(req.Password) < 8 {
		return c.Status(400).JSON(fiber.Map{
			"message": "Password minimal 8 karakter",
		})
	}

	// 3. check email exist
	var existingUser model.User
	if err := config.DB.Where("email = ?", req.Email).First(&existingUser).Error; err == nil {
		return c.Status(409).JSON(fiber.Map{
			"message": "Email sudah terdaftar",
		})
	}

	// 4. hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"message": "Password gagal di hash",
		})
	}

	// 5. CREATE USER + UUID
	user := model.User{
		ID:       uuid.New(), // 👈 INI UUID NYA
		Email:    req.Email,
		Password: string(hashedPassword),
	}

	if err := config.DB.Create(&user).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"message": "Gagal membuat user",
		})
	}

	// 6. CREATE PROFILE
	profile := model.Profile{
		ID:       uuid.New(), // optional tapi bagus
		UserID:   user.ID,
		Username: req.Username,
	}

	config.DB.Create(&profile)

	// 7. response
	return c.Status(201).JSON(fiber.Map{
		"message": "Register berhasil",
		"user_id": user.ID,
	})
}

// Login godoc
// @Summary      Login User
// @Description  Masukan username & password untuk mendapatkan token JWT
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        login  body      model.LoginRequest  true  "Username & Password"
// @Success      200    {object}  map[string]string
// @Router /auth/login [post]
func Login(c *fiber.Ctx) error {
	var req model.LoginRequest
	var user model.User

	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Gagal parsing data",
		})
	}

	if strings.TrimSpace(req.Email) == "" {
		return c.Status(400).JSON(fiber.Map{
			"message": "Email tidak boleh kosong",
		})
	}

	if !strings.Contains(req.Email, "@") {
		return c.Status(400).JSON(fiber.Map{
			"message": "Format email tidak valid",
		})
	}

	if strings.TrimSpace(req.Password) == "" {
		return c.Status(400).JSON(fiber.Map{
			"message": "Password tidak boleh kosong",
		})
	}

	if err := config.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Email tidak ditemukan",
		})
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Password salah",
		})
	}

	claims := jwt.MapClaims{
		"user_id": user.ID,
		"exp":     time.Now().Add(time.Hour * 72).Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	secretkey := config.GetEnv("JWT_SECRET")
	t, err := token.SignedString([]byte(secretkey))
	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"message": "Gagal membuat token",
		})
	}

	return c.JSON(fiber.Map{
		"message": "Login berhasil",
		"token":   t,
	})
}
