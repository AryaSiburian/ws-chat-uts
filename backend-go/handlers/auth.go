package handlers

import (
	"backend-go/config"
	"backend-go/model"

	"github.com/gofiber/fiber/v2"
	"golang.org/x/crypto/bcrypt"
)

// Register godoc
// @Summary      Register user baru
// @Description  Endpoint untuk registrasi
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        user body model.RegisterRequest true "Data User"
// @Success      201 {object} model.SuccessResponse
// @Failure      400 {object} model.ErrorResponse
// @Router       /api/auth/register [post]
func Register(c *fiber.Ctx) error {
	var req model.RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(model.ErrorResponse{Message: "Format data salah"})
	}

	password, _ := bcrypt.GenerateFromPassword([]byte(req.Password), 14)

	user := model.User{
		Username: req.Username,
		Email:    req.Email,
		Password: string(password),
	}

	if err := config.DB.Create(&user).Error; err != nil {
		return c.Status(400).JSON(model.ErrorResponse{Message: "Email atau Username sudah terdaftar"})
	}

	return c.Status(201).JSON(model.SuccessResponse{Message: "Berhasil daftar!"})
}

// Login godoc
// @Summary      Login user
// @Description  Endpoint untuk login
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        user body model.LoginRequest true "Data Login"
// @Success      200 {object} model.SuccessResponse
// @Router       /api/auth/login [post]
func Login(c *fiber.Ctx) error {
	// Nanti diisi logic token JWT, sementara return success dummy
	return c.Status(200).JSON(model.SuccessResponse{Message: "Login Berhasil"})
}
