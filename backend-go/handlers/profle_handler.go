package handlers

import (
	"backend-go/model"
	"strings"

	"backend-go/config"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

func GetMyProfile(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(uuid.UUID)
	var profile model.Profile

	if err := config.DB.Where("user_id = ?", userID).First(&profile).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "profile tidak ditemukan"})
	}

	return c.JSON(fiber.Map{
		"username": profile.Username,
		"bio":      profile.Bio,
		"avatar":   profile.Avatar,
	})
}

func UpdateMyProfile(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(uuid.UUID)
	var req model.UpdateProfileRequest

	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "invalid request"})
	}

	var profile model.Profile
	if err := config.DB.Where("user_id = ?", userID).First(&profile).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "profile tidak ditemukan"})
	}

	if strings.TrimSpace(req.Username) != "" {
		profile.Username = req.Username
	}
	if strings.TrimSpace(req.Bio) != "" {
		profile.Bio = req.Bio
	}
	if strings.TrimSpace(req.Avatar) != "" {
		profile.Avatar = req.Avatar
	}

	if err := config.DB.Save(&profile).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "gagal update profile"})
	}

	return c.JSON(fiber.Map{"message": "profile updated", "data": profile})
}

func UpdateProfileByID(c *fiber.Ctx) error {
	idParam := c.Params("id")
	userID, err := uuid.Parse(idParam)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Format ID tidak valid"})
	}

	var req model.UpdateProfileRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Format request tidak valid"})
	}

	var profile model.Profile
	if err := config.DB.Where("user_id = ?", userID).First(&profile).Error; err != nil {
		profile = model.Profile{
			ID:       uuid.New(),
			UserID:   userID,
			Username: "User Baru",
		}
		config.DB.Create(&profile)
	}

	if strings.TrimSpace(req.Username) != "" {
		profile.Username = req.Username
	}
	if strings.TrimSpace(req.Bio) != "" {
		profile.Bio = req.Bio
	}
	if strings.TrimSpace(req.Avatar) != "" {
		profile.Avatar = req.Avatar
	}

	if err := config.DB.Save(&profile).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Gagal menyimpan update profil"})
	}

	return c.JSON(fiber.Map{"message": "Profile berhasil diperbarui", "data": profile})
}
