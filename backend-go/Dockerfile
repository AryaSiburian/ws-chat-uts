FROM golang:1.22-alpine

# Docker akan otomatis membuat folder /app DI DALAM kontainer
WORKDIR /app

# Mengambil file dari laptop kamu (.), dimasukkan ke dalam /app di kontainer (.)
COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o main main.go

CMD ["./main"]