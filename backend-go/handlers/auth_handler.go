package handlers

import (
	"backend-go/config"
	"backend-go/model"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

func Register(c *fiber.Ctx) error {
	var req model.RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Format data tidak valid"})
	}
	if strings.TrimSpace(req.Username) == "" || !strings.Contains(req.Email, "@") || len(req.Password) < 8 {
		return c.Status(400).JSON(fiber.Map{"message": "Validasi gagal"})
	}
	var existingUser model.User
	if err := config.DB.Where("email = ?", req.Email).First(&existingUser).Error; err == nil {
		return c.Status(409).JSON(fiber.Map{"message": "Email sudah terdaftar"})
	}
	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	user := model.User{
		ID:       uuid.New(),
		Email:    req.Email,
		Password: string(hashedPassword),
	}
	if err := config.DB.Create(&user).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Gagal membuat user"})
	}
	profile := model.Profile{
		ID:       uuid.New(),
		UserID:   user.ID,
		Username: req.Username,
	}
	config.DB.Create(&profile)
	return c.Status(201).JSON(fiber.Map{"message": "Register berhasil", "user_id": user.ID})
}

func Login(c *fiber.Ctx) error {
	var req model.LoginRequest
	var user model.User
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Gagal parsing data"})
	}
	if err := config.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Email tidak ditemukan"})
	}
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Password salah"})
	}
	claims := jwt.MapClaims{
		"user_id": user.ID,
		"exp":     time.Now().Add(time.Hour * 72).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	secretkey := config.GetEnv("JWT_SECRET")
	t, _ := token.SignedString([]byte(secretkey))

	cookie := new(fiber.Cookie)
	cookie.Name = "token"
	cookie.Value = t
	cookie.Expires = time.Now().Add(72 * time.Hour)
	cookie.HTTPOnly = true
	cookie.SameSite = "Lax"
	c.Cookie(cookie)

	return c.JSON(fiber.Map{
		"message": "Login berhasil",
		"token":   t,
		"user_id": user.ID,
	})
}
