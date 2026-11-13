
FROM node:22-bookworm

ENV NODE_ENV=production \
    PORT=3000 \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# System dependencies: QEMU, desktop, RDP, ISO, networking and utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    xrdp \
    xorgxrdp \
    xfce4-session \
    xfwm4 \
    xfce4-panel \
    xfdesktop4 \
    thunar \
    xfce4-terminal \
    chromium \
    falkon \
    dbus \
    dbus-x11 \
    ssl-cert \
    genisoimage \
    nasm \
    freerdp2-x11 \
    xvfb \
    curl \
    ca-certificates \
    tar \
    xz-utils \
    procps \
    iproute2 \
    iptables \
    iputils-ping \
    netcat-openbsd \
    sudo \
    adduser \
    make \
    fonts-liberation \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node dependencies
COPY package.json ./

RUN npm install --no-audit --no-fund

# Copy application source
COPY . .

# Build React/Vite frontend
RUN npm run build

# Persistent VM data directories
RUN mkdir -p \
    /app/data/iso \
    /app/data/disks \
    /app/data \
    /tmp \
    /run/dbus \
    /var/run/xrdp

# Application port
EXPOSE 3000

# Persistent data: ISO images and virtual disks
VOLUME ["/app/data"]

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD node -e "fetch('http://127.0.0.1:3000/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["npm", "start"]
