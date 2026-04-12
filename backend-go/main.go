package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	_ "github.com/lib/pq"
	"github.com/redis/go-redis/v9"
)

var ctx = context.Background()

func main() {
	// 1. Test Koneksi Postgres
	dbHost := os.Getenv("DB_HOST")
	dbUser := os.Getenv("DB_USER")
	dbPass := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=disable", dbHost, dbUser, dbPass, dbName)

	db, err := sql.Open("postgres", dsn)
	if err != nil || db.Ping() != nil {
		log.Fatalf("Gagal konek Postgres: %v", err)
	}
	fmt.Println("✅ Terhubung ke PostgreSQL!")

	// 2. Test Koneksi Redis
	rdb := redis.NewClient(&redis.Options{
		Addr: fmt.Sprintf("%s:%s", os.Getenv("REDIS_HOST"), os.Getenv("REDIS_PORT")),
	})
	if err := rdb.Ping(ctx).Err(); err != nil {
		log.Fatalf("Gagal konek Redis: %v", err)
	}
	fmt.Println("✅ Terhubung ke Redis!")

	// 3. Server Sederhana
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Backend Chat System Is Running!")
	})

	fmt.Println("🚀 Server jalan di port 8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
