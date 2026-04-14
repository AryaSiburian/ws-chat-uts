package config

import (
	models "backend-go/model"
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func LoadEnv() {
	// Membaca file .env
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}
}

// Fungsi untuk ambil value biar rapi
func GetEnv(key string) string {
	return os.Getenv(key)
}

var DB *gorm.DB

func ConnectDatabase() {
	dsn := "host=chat-db user=postgres password=28102005 dbname=chatsystem_uts port=5432 sslmode=disable"
	database, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	database.AutoMigrate(&models.User{})
	if err != nil {
		log.Fatal("Gagal terhubung ke database: ", err)
	} else {
		fmt.Println("Berhasil terhubung ke database PostgreSQL!")
	}

	DB = database
}
