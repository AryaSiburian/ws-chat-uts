package handlers

import (
	"backend-go/config"
	"backend-go/model"
	"fmt"
	"strings"
	"time"

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
// @Success      201   {object}  map[string]interface{}
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
		ID:       uuid.New(),
		Email:    req.Email,
		Password: string(hashedPassword),
	}

	if err := config.DB.Create(&user).Error; err != nil {
		fmt.Println("=== ERROR DB CREATE USER ===", err)
		return c.Status(500).JSON(fiber.Map{
			"message": "Gagal membuat user",
		})
	}

	// 6. CREATE PROFILE
	profile := model.Profile{
		ID:       uuid.New(),
		UserID:   user.ID,
		Username: req.Username,
	}

	if err := config.DB.Create(&profile).Error; err != nil {
		fmt.Println("=== ERROR DB CREATE PROFILE ===", err)
	}

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
// @Success      200    {object}  map[string]interface{}
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
			"message": "Email tidak ditemukan / salah",
		})
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Password salah",
		})
	}

	// Pembuatan JWT Claims
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

	// ==============================================================
	// KUNCI UTAMA: Memasukkan Token ke dalam Cookie yang Aman
	// ==============================================================
	cookie := new(fiber.Cookie)
	cookie.Name = "token"
	cookie.Value = t
	cookie.Expires = time.Now().Add(72 * time.Hour)
	cookie.HTTPOnly = true  // Wajib true agar tidak bisa di-hack via XSS (JavaScript)
	cookie.SameSite = "Lax" // Mengizinkan pengiriman dari localhost:3000 ke localhost:8080
	// cookie.Secure = true // Aktifkan ini NANTI kalau aplikasi sudah online pakai HTTPS

	c.Cookie(cookie) // Menempelkan cookie ke header response Chrome
	// ==============================================================

	return c.JSON(fiber.Map{
		"message": "Login berhasil",
		"token":   t, // Kita tetap kirim JSON untuk sekadar info, walau Chrome akan pakai Cookie
	})
}
<<<<<<< HEAD:backend-go/handlers/auth_handler.go
=======

// GetMyProfile godoc
// @Summary      Get My Profile
// @Description  Mengambil data profile user yang sedang login (berdasarkan JWT)
// @Tags         Profile
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  model.ProfileResponse
// @Failure      401  {object}  map[string]interface{}
// @Failure      404  {object}  map[string]interface{}
// @Router       /profile/me [get]
func GetMyProfile(c *fiber.Ctx) error {
	// Locals "user_id" didapatkan dari Middleware JWT yang berjalan sebelum fungsi ini
	userID := c.Locals("user_id").(uuid.UUID)

	var profile model.Profile

	if err := config.DB.Where("user_id = ?", userID).First(&profile).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"message": "Profile tidak ditemukan",
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
// @Failure      400      {object}  map[string]interface{}
// @Failure      401      {object}  map[string]interface{}
// @Failure      404      {object}  map[string]interface{}
// @Router       /profile/me [patch]
func UpdateMyProfile(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(uuid.UUID)

	var req model.UpdateProfileRequest

	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"message": "Format request tidak valid",
		})
	}

	var profile model.Profile

	if err := config.DB.Where("user_id = ?", userID).First(&profile).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"message": "Profile tidak ditemukan",
		})
	}

	// Update field hanya jika data yang dikirim tidak kosong
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
			"message": "Gagal menyimpan update profile",
		})
	}

	return c.JSON(fiber.Map{
		"message": "Profile berhasil diupdate",
		"data":    profile,
	})
}
>>>>>>> a533654 (memperbarui set cookie):backend-go/handlers/auth.go
