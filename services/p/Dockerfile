FROM node:20.10-slim AS serving
RUN addgroup --system appgroup && adduser --system appuser --ingroup appgroup
# Update and install required packages
RUN apt-get update && \
    apt-get install -y build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# Set working directory and copy requirements
WORKDIR /app
COPY . /app
# Set ownership of app directory to non-root user
RUN chown -R appuser:appgroup /app
RUN chmod +x /app/entrypoint.sh
# Set environment variables
EXPOSE 80 80
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["serve"]