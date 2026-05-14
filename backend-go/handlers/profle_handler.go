package handlers

import (
	"backend-go/model"
	"errors"
	"os"
	"path/filepath"
	"strings"

	"backend-go/config"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"gorm.io/gorm"
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
	// 1. Ambil dari locals
	rawID := c.Locals("user_id")
	if rawID == nil {
		return c.Status(401).JSON(fiber.Map{"message": "Sesi tidak ditemukan (Locals Empty)"})
	}

	// 2. Casting ke uuid.UUID (pastikan import "github.com/google/uuid")
	userID, ok := rawID.(uuid.UUID)
	if !ok {
		return c.Status(500).JSON(fiber.Map{"message": "Terjadi kesalahan tipe data ID di server"})
	}

	var profile model.Profile
	// 3. Cari di database
	if err := config.DB.Where("user_id = ?", userID).First(&profile).Error; err != nil {
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			return c.Status(500).JSON(fiber.Map{"message": "Gagal mengambil profil"})
		}

		// Jika profile belum ada di DB, buatkan otomatis supaya Flutter tidak error 404
		profile = model.Profile{
			ID:       uuid.New(),
			UserID:   userID,
			Username: "User_" + userID.String()[:5],
			Bio:      "Mahasiswa IT Chat App",
		}

		if errCreate := config.DB.Create(&profile).Error; errCreate != nil {
			return c.Status(500).JSON(fiber.Map{"message": "Gagal membuat profil default"})
		}
	}

	if profile.Username == "" {
		profile.Username = "User_" + userID.String()[:5]
	}

	return c.JSON(model.ProfileResponse{
		Username: profile.Username,
		Bio:      profile.Bio,
		Avatar:   profile.Avatar,
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

// UpdateAvatar godoc
// @Summary      Update Avatar
// @Description  Upload dan update avatar user yang sedang login
// @Tags         Profile
// @Accept       multipart/form-data
// @Produce      json
// @Security     BearerAuth
// @Param        avatar  formData  file  true  "Avatar Image (jpg/png)"
// @Success      200     {object}  model.ProfileResponse
// @Failure      400     {object}  model.ErrorResponse
// @Failure      401     {object}  model.ErrorResponse
// @Failure      404     {object}  model.ErrorResponse
// @Failure      500     {object}  model.ErrorResponse
// @Router       /profile/avatar [patch]
func UpdateAvatar(c *fiber.Ctx) error {
	rawUser := c.Locals("user_id")
	if rawUser == nil {
		return c.Status(401).JSON(fiber.Map{"message": "unauthorized"})
	}

	userID := rawUser.(uuid.UUID)

	file, err := c.FormFile("avatar")
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "file avatar wajib diisi"})
	}

	ext := strings.ToLower(filepath.Ext(file.Filename))
	if ext != ".jpg" && ext != ".jpeg" && ext != ".png" {
		return c.Status(400).JSON(fiber.Map{"message": "format file harus jpg/jpeg/png"})
	}

	uploadDir := "./uploads"
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "gagal membuat folder uploads"})
	}

	var profile model.Profile
	if err := config.DB.Where("user_id = ?", userID).First(&profile).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "profile tidak ditemukan"})
	}

	// 2. Tentukan nama file
	filename := userID.String() + "_" + uuid.New().String() + ext

	// 3. SEKARANG AMAN UNTUK SIMPAN (Karena folder sudah pasti ada)
	if err := c.SaveFile(file, uploadDir+"/"+filename); err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "gagal menyimpan file ke server"})
	}

	avatarURL := "/uploads/" + filename
	profile.Avatar = avatarURL

	if err := config.DB.Save(&profile).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "gagal update avatar di database"})
	}

	return c.JSON(fiber.Map{
		"message": "avatar berhasil diupdate",
		"avatar":  avatarURL,
	})
}

// UpdateProfileByID godoc
// @Summary      Update User Profile
// @Description  Memperbarui username, bio, atau avatar berdasarkan User ID
// @Tags         Profile
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id       path      string                      true  "User UUID"
// @Param        profile  body      model.UpdateProfileRequest  true  "Update Profile Data"
// @Success      200      {object}  map[string]interface{}      "Berhasil memperbarui profil"
// @Failure      400      {object}  map[string]interface{}      "Format ID atau Request tidak valid"
// @Failure      500      {object}  map[string]interface{}      "Internal Server Error"
// @Router       /profile/update/{id} [patch]
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
