FROM nginx:mainline
# Remove default nginx.conf file
RUN rm /etc/nginx/conf.d/default.conf
# Copy nginx.conf file from local directory to the container
COPY ./nginx.conf /etc/nginx/conf.d/
# Set non-root user and group to run Nginx
RUN chown -R nginx:nginx /var/cache/nginx /var/run /var/log/nginx
# Reduce attack surface by running Nginx as a non-root user
USER nginx
# Set default port for container
EXPOSE 80
# Copy entrypoint.sh script to container
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# Give execution permissions to entrypoint.sh script
RUN chmod +x /usr/local/bin/entrypoint.sh
# Set entrypoint to execute the script on container startup
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]