FROM golang:1.24-alpine

# Tambahkan ini untuk menghindari masalah download toolchain
ENV GOTOOLCHAIN=local 

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o main .

EXPOSE 8080

CMD ["./main"]