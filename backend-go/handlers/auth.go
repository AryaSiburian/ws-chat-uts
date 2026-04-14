package handlers

import (
	"backend-go/model"
	models "backend-go/model"
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
// @Param        user  body    models.RegisterRequest  true  "Username & Password"
// @Success      201   {object}  map[string]string
// @Router /api/auth/register [post]
func Register(c *fiber.Ctx) error {
	var user model.User

	if err := c.BodyParser(&user); err != nil {
		return c.Status(400).JSON(models.ErrorResponse{Message: "Invalid request body"})
	}

	hashedPassowrd, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	user.Password = string(hashedPassowrd)

	if err != nil {
		return c.Status(500).JSON(fiber.Map{"Message": "Password gagal di hash"})
	}

	if err := config.DB.Create(&user).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"Message": "Gagal dimasukin db"})
	}

	return c.Status(201).JSON(fiber.Map{"Message": "Email Berhasil Terdaftar"})
}

// Login godoc
// @Summary      Login User
// @Description  Masukan username & password untuk mendapatkan token JWT
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        login  body      models.LoginRequest  true  "Username & Password"
// @Success      200    {object}  map[string]string
// @Router /api/auth/login [post]
func Login(c *fiber.Ctx) error {
	var req model.LoginRequest
	var user model.User

	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"Message": "Gagal Parsing Data"})
	}

	if err := config.DB.Where("Email=?", req.Email).First(&user).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"Message": "Gagal Menemukan Email"})
	}

	err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password))
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"Message": "Pasword tidak cocok"})
	}

	claims := jwt.MapClaims{
		"user_id ": user.ID,
		"exp":      time.Now().Add(time.Hour * 72).Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	secretkey := config.GetEnv("JWT_SECRET")
	t, err := token.SignedString([]byte(secretkey))
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"Message": "Gagal membuat token"})
	}

	return c.JSON(fiber.Map{
		"message": "Login berhasil",
		"token":   t,
	})
}
