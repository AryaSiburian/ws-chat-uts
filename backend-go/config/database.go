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
	// Kita ganti log.Fatal menjadi log.Println agar aplikasi tidak mati di dalam Docker
	err := godotenv.Load()
	if err != nil {
		log.Println("⚠️ .env file tidak ditemukan, menggunakan environment dari Docker")
	}
}

func GetEnv(key string) string {
	return os.Getenv(key)
}

var DB *gorm.DB

func ConnectDatabase() {
	host := GetEnv("DB_HOST")
	user := GetEnv("DB_USER")
	password := GetEnv("DB_PASSWORD")
	dbname := GetEnv("DB_NAME")
	port := GetEnv("DB_PORT")

	// Default fallback agar tetap jalan walau tanpa .env
	if host == "" {
		host = "localhost"
	}
	if user == "" {
		user = "postgres"
	}
	if password == "" {
		password = "chatpassword"
	} // Sesuaikan password-mu jika berbeda
	if dbname == "" {
		dbname = "chatdb"
	}
	if port == "" {
		port = "5432"
	}

	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=Asia/Jakarta",
		host, user, password, dbname, port,
	)

	database, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("❌ Gagal terhubung ke database: ", err)
	}

	database.AutoMigrate(&models.User{})
	fmt.Println("✅ Berhasil terhubung ke database PostgreSQL!")
	DB = database
}
