package handlers

import (
	"backend-go/model"
	// "net/http"
	"strings"

	"backend-go/config"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

// GetMyProfile godoc
// @Summary      Get My Profile
// @Description  Mengambil data profile user yang sedang login (berdasarkan JWT)
// @Tags         Profile
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  model.ProfileResponse
// @Failure      401  {object}  model.ErrorResponse
// @Failure      404  {object}  model.ErrorResponse
// @Router       /profile/me [get]
func GetMyProfile(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(uuid.UUID)

	var profile model.Profile

	if err := config.DB.Where("user_id = ?", userID).First(&profile).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"message": "profile tidak ditemukan",
		})
	}

	return c.JSON(fiber.Map{
		"username": profile.Username,
		"bio":      profile.Bio,
		"avatar":   profile.Avatar,
	})
}

// UpdateMyProfile godoc
// @Summary      Update My Profile
// @Description  Update username, bio, atau avatar user yang sedang login
// @Tags         Profile
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        profile  body      model.UpdateProfileRequest  true  "Update Profile Data"
// @Success      200      {object}  model.ProfileResponse
// @Failure      400      {object}  model.ErrorResponse
// @Failure      401      {object}  model.ErrorResponse
// @Failure      404      {object}  model.ErrorResponse
// @Router       /profile/me [patch]
func UpdateMyProfile(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(uuid.UUID)

	var req model.UpdateProfileRequest

	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "invalid request",
		})
	}

	var profile model.Profile

	if err := config.DB.Where("user_id = ?", userID).First(&profile).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"message": "profile tidak ditemukan",
		})
	}

	// update field jika ada isi
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
		return c.Status(500).JSON(fiber.Map{
			"message": "gagal update profile",
		})
	}

	return c.JSON(fiber.Map{
		"message": "profile updated",
		"data":    profile,
	})
}
