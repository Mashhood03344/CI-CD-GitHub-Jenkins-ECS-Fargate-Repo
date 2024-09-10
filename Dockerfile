FROM golang:alpine as builder

# Set the working directory inside the container
WORKDIR /code

# Copy all project files to the working directory
COPY . /code

# Initialize Go modules if not already initialized
# The `|| true` ensures the command doesn't fail if the module is already initialized
RUN go mod init example.com/sample-app || true

# Tidy up the dependencies (fetch necessary dependencies for the project)
RUN go mod tidy

# Run tests
RUN go test ./...

# Build the Go application
RUN go build -o /app

# Use a minimal image for production
FROM alpine

# Copy the built application from the builder stage
COPY --from=builder /app /app

# Set the entry point for the container
ENTRYPOINT ["/app"]

