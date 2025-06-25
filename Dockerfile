# Use a lightweight Python image
FROM python:3.11-slim-bullseye

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on \
    TZ=Asia/Dhaka

# Set timezone and install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    aria2 \
    wget \
    gnupg \
    ca-certificates \
    tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Create download directory and fix permissions
RUN mkdir -p downloads \
    && chmod 777 downloads

# Configure aria2c
RUN echo "" > /etc/aria2.conf \
    && echo "enable-rpc=true" >> /etc/aria2.conf \
    && echo "rpc-listen-all=true" >> /etc/aria2.conf \
    && echo "rpc-allow-origin-all=true" >> /etc/aria2.conf \
    && echo "seed-time=0" >> /etc/aria2.conf \
    && echo "max-connection-per-server=16" >> /etc/aria2.conf \
    && echo "split=16" >> /etc/aria2.conf \
    && echo "check-certificate=false" >> /etc/aria2.conf \
    && echo "auto-file-renaming=true" >> /etc/aria2.conf \
    && echo "file-allocation=none" >> /etc/aria2.conf \
    && echo "summary-interval=15" >> /etc/aria2.conf \
    && echo "disable-ipv6=true" >> /etc/aria2.conf \
    && echo "timeout=600" >> /etc/aria2.conf \
    && echo "connect-timeout=60" >> /etc/aria2.conf

# Expose Flask port
EXPOSE 8080

# Start aria2c in background and run the bot
CMD aria2c --conf-path=/etc/aria2.conf -D && python bot.py
