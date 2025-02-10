FROM golang:alpine AS builder
RUN apk update && \
    apk add --no-cache git && \
    apk add --no-cach bash && \
    apk add build-base \
    apk add curl \
    bash \
    make \
    ca-certificates \
    rm -rf /var/cache/apk/*

WORKDIR /app

ENV GOPATH=/go
COPY go.* ./
RUN go mod download
RUN go mod verify

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o application ./cmd/bin/main.go

FROM alpine:latest AS image
RUN apk --no-cache add ca-certificates bash tzdata
ENV TZ=Asia/Jakarta

WORKDIR /app/
COPY --from=builder /app/application .

RUN ["chmod", "+x", "./application"]
ENTRYPOINT [ "./application" ]