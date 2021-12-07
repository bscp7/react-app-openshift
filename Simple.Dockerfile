FROM node:14 AS builder
WORKDIR /app
COPY . .
RUN yarn install && yarn build

FROM nginxinc/nginx-unprivileged
# Set working directory to nginx asset directory
WORKDIR /usr/share/nginx/html
# Remove default nginx static assets
# RUN rm -rf ./*
# Copy static assets from builder stage
COPY --from=builder /app/build .

# UID and GID are specified in the base imge
ARG UID=101
ARG GID=101
ARG USER=nginx

# Specify to run as root user for the subsequent commands
USER 0

# This is giving the root group the necessary permissions to work with OpenShift restricted SCC
RUN chown -R  ${UID}:0 /var/cache/nginx /etc/nginx && \
    chmod -R g=u /var/cache/nginx /etc/nginx && \
    addgroup ${USER} root

EXPOSE 8080

STOPSIGNAL SIGQUIT

# Specify user by UID to ensure compatability with OpenShift
USER ${UID}

# Containers run nginx with global directives and daemon off
ENTRYPOINT ["nginx", "-g", "daemon off;"]