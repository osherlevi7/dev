# syntax=docker/dockerfile:1
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9
# Update and install security patches for the OS
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*
# Install OS-level security packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sudo \
        openssh-server \
        net-tools \
        iptables \
        ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*
# Create a non-root user
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 ubuntu && \
    echo 'ubuntu:password' | chpasswd
# Set the working directory
WORKDIR /app
# Copy the app code
COPY ./app /app
# Install the app's Python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt
# Change ownership of the app directory to the non-root user
RUN chown -R ubuntu:root /app && \
    chmod -R 755 /app
# Expose the port
EXPOSE 80
# Change to non-root user
USER ubuntu
# Use an entrypoint script to set up the environment and start the app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["start"]
