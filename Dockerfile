# Build the manager binary
FROM --platform=$BUILDPLATFORM golang:1.24 AS builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY main.go main.go

ARG TARGETOS
ARG TARGETARCH

# Get Git commit SHA and tag
ARG GIT_COMMIT
ARG GIT_TAG

FROM builder AS takumai-builder

RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH GO111MODULE=on go build -ldflags="-s -w -X main.version=${GIT_TAG} -X main.commit=${GIT_COMMIT}" -a -o bin/takumai ./main.go

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot AS takumai
WORKDIR /
COPY --from=takumai-builder /workspace/bin/takumai .
USER 65532:65532

ENTRYPOINT ["/takumai"]
