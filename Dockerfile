# =========================
# Stage 1: Build sshx-server
# =========================
# Use latest Rust to support edition2024 features
# getrandom v0.4.1 requires rust >= 1.85
FROM rust:latest-slim AS rust-builder

RUN apt-get update && apt-get install -y \
    protobuf-compiler \
    libprotobuf-dev \
    sudo \
    ca-certificates \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ---- Copy toàn bộ workspace (tránh thiếu crate) ----
COPY . .

# ---- Force older getrandom version to avoid edition2024 issues if rust:1.85 includes old cargo ----
# RUN cargo update -p getrandom --precise 0.2.14

# ---- Build đúng binary ----
RUN cargo build --release -p sshx-server


# =========================
# Stage 2: Runtime (SIÊU NHẸ)
# =========================
FROM gcr.io/distroless/cc-debian12

WORKDIR /app

COPY --from=rust-builder /app/target/release/sshx-server /usr/local/bin/sshx-server

EXPOSE 8051

ENTRYPOINT ["/usr/local/bin/sshx-server"]
