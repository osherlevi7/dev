# syntax=docker/dockerfile:1
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9
# Create and switch to a non-root user for running the application
RUN groupadd -r app && useradd --no-log-init -r -g app app
USER app
# Install system dependencies
RUN apt-get update && \
    apt-get -y -q install \
    libreoffice-writer \
    default-jre \
    libreoffice-java-common \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# Copy and install Python dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt
# Copy the application code
COPY ./app /app
# Set the working directory and expose the port
WORKDIR /app
EXPOSE 80
# Specify the non-root user as the container user
USER app
# Use an entrypoint script to start the application
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["start"]