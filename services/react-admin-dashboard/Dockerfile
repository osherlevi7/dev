FROM node:20.8.0-slim AS base
# Set non-root user and group
RUN addgroup --system appgroup && adduser --system appuser --ingroup appgroup
# Update and install required packages
RUN apt-get update && \
    apt-get install -y build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# Set working directory and copy requirements
WORKDIR /app
COPY ./src/requirements.txt /app/requirements.txt
# Install dependencies as non-root user
RUN pip install --user --no-cache-dir -r requirements.txt
# Set ownership of app directory to non-root user
RUN chown -R appuser:appgroup /app
# Switch to non-root user
USER appuser
FROM node:20.8.0-slimm AS build
# Set non-root user and group
RUN addgroup --system appgroup && adduser --system appuser --ingroup appgroup
# Copy entrypoint and app files
COPY ./src/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
COPY . /app/react-admin/
# Set ownership of app directory to non-root user
RUN chown -R appuser:appgroup /app
# Switch to non-root user
USER appuser
FROM node:20.8.0-slim AS serving
# Set non-root user and group
RUN addgroup --system appgroup && adduser --system appuser --ingroup appgroup
# Set working directory
WORKDIR /app
# Copy app files and dependencies from base and build stages
COPY --from=base --chown=appuser:appgroup /root/.local /app/.local
COPY --from=build --chown=appuser:appgroup /app/entrypoint.sh /app/
COPY --from=build --chown=appuser:appgroup /app/react-admin/ /app/react-admin/
# Set environment variables
EXPOSE 80
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["serve"]