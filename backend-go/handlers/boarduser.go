package handlers

import (
	"backend-go/config"
	"backend-go/model"

	"github.com/gofiber/fiber/v2"
)

// GetAllUsers godoc
// @Summary      Ambil semua user
// @Description  Mengembalikan daftar semua user yang terdaftar
// @Tags         Users
// @Produce      json
// @Success      200  {array}   model.UserResponse
// @Failure      500  {object}  model.ErrorResponse
// @Router       /api/users [get]
func GetAllUsers(c *fiber.Ctx) error {
	var users []model.User

	if err := config.DB.Find(&users).Error; err != nil {
		return c.Status(500).JSON(model.ErrorResponse{Message: "Gagal mengambil data user"})
	}

	var result []model.UserResponse
	for _, u := range users {
		result = append(result, model.UserResponse{
			ID:        u.ID,
			Username:  u.Username,
			Email:     u.Email,
			CreatedAt: u.CreatedAt,
		})
	}
	return c.Status(200).JSON(result)
}

// GetUserByID godoc
// @Summary      Ambil user berdasarkan ID
// @Description  Mengembalikan data 1 user berdasarkan ID
// @Tags         Users
// @Produce      json
// @Param        id   path      int  true  "User ID"
// @Success      200  {object}  model.UserResponse
// @Failure      404  {object}  model.ErrorResponse
// @Router       /api/users/{id} [get]
func GetUserByID(c *fiber.Ctx) error {
	id := c.Params("id")
	var user model.User

	if err := config.DB.First(&user, id).Error; err != nil {
		return c.Status(404).JSON(model.ErrorResponse{Message: "User tidak ditemukan"})
	}

	return c.Status(200).JSON(model.UserResponse{
		ID:        user.ID,
		Username:  user.Username,
		Email:     user.Email,
		CreatedAt: user.CreatedAt,
	})
}

// UpdateUser godoc
// @Summary      Update data user
// @Description  Mengupdate username dan/atau email user berdasarkan ID
// @Tags         Users
// @Accept       json
// @Produce      json
// @Param        id    path      int                    true  "User ID"
// @Param        body  body      model.UpdateUserRequest true  "Data yang diupdate"
// @Success      200   {object}  model.UserResponse
// @Failure      400   {object}  model.ErrorResponse
// @Failure      404   {object}  model.ErrorResponse
// @Router       /api/users/{id} [put]
func UpdateUser(c *fiber.Ctx) error {
	id := c.Params("id")
	var user model.User
	var req model.UpdateUserRequest

	if err := config.DB.First(&user, id).Error; err != nil {
		return c.Status(404).JSON(model.ErrorResponse{Message: "User tidak ditemukan"})
	}

	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(model.ErrorResponse{Message: "Format request tidak valid"})
	}

	if req.Username != "" {
		user.Username = req.Username
	}
	if req.Email != "" {
		user.Email = req.Email
	}

	if err := config.DB.Save(&user).Error; err != nil {
		return c.Status(500).JSON(model.ErrorResponse{Message: "Gagal update user"})
	}

	return c.Status(200).JSON(model.UserResponse{
		ID:        user.ID,
		Username:  user.Username,
		Email:     user.Email,
		CreatedAt: user.CreatedAt,
	})
}

// DeleteUser godoc
// @Summary      Hapus user
// @Description  Menghapus user berdasarkan ID
// @Tags         Users
// @Produce      json
// @Param        id   path      int  true  "User ID"
// @Success      200  {object}  model.SuccessResponse
// @Failure      404  {object}  model.ErrorResponse
// @Router       /api/users/{id} [delete]
func DeleteUser(c *fiber.Ctx) error {
	id := c.Params("id")
	var user model.User

	if err := config.DB.First(&user, id).Error; err != nil {
		return c.Status(404).JSON(model.ErrorResponse{Message: "User tidak ditemukan"})
	}

	if err := config.DB.Delete(&user).Error; err != nil {
		return c.Status(500).JSON(model.ErrorResponse{Message: "Gagal menghapus user"})
	}

	return c.Status(200).JSON(model.SuccessResponse{Message: "User berhasil dihapus"})
}
