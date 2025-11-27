# -----------------------------------------
# Protobuf / gRPC Generation Makefile
# -----------------------------------------

PROTO_DIR = proto/tutorial       # directory containing your .proto files
PROTO_FILES = $(PROTO_DIR)/*.proto

# Go output directory (same as proto directory)
GO_OUT = $(PROTO_DIR)

# Bin directory for protoc plugins
GOBIN := $(shell go env GOPATH)/bin

# -----------------------------------------
# Ensure protoc plugins are installed
# -----------------------------------------
.PHONY: setup
setup:
	@echo "Installing protoc plugins..."
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	@echo "Done. Make sure $(GOBIN) is in your PATH."

# -----------------------------------------
# Generate Go code (protobuf + gRPC)
# -----------------------------------------
.PHONY: proto
proto:
	@echo "Compiling protobufs..."
	PATH="$(PATH):$(GOBIN)" protoc \
		-I=$(PROTO_DIR) \
		--go_out=$(GO_OUT) \
		--go-grpc_out=$(GO_OUT) \
		$(PROTO_FILES)
	@echo "Generated Go files in $(GO_OUT)."

# Clean generated files
.PHONY: clean
clean:
	rm -f $(PROTO_DIR)/*.pb.go
	@echo "Cleaned generated protobuf files."
