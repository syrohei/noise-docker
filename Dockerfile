# Dockerfile References: https://docs.docker.com/engine/reference/builder/

# Start from the latest golang base image
FROM golang:latest as builder

# Add Maintainer Info
LABEL maintainer="Yusaku Senga <yusaku@swingby.network>"

# Set the Current Working Directory inside the container
RUN git clone -b testnet --depth 1 https://github.com/SwingbyProtocol/noise.git

WORKDIR noise

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

RUN export GO111MODULE=on
# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /stream ./examples/skademlia_stream

######## Start a new stage from scratch #######
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /stream .

# Expose port 9096 to the outside world
EXPOSE 9098

ENTRYPOINT ["./stream"]
