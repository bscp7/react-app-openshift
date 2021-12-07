# Instana
FROM alpine AS build
ARG KEY
WORKDIR /instana
RUN apk add --update --no-cache curl
RUN if [ -n "$KEY" ]; then curl \
    --output instana.zip \
    --user "_:$KEY" \
    https://artifact-public.instana.io/artifactory/shared/com/instana/nginx_tracing/1.1.2/linux-amd64-glibc-nginx-1.20.1.zip && \
    unzip instana.zip && \
    mv glibc-libinstana_sensor.so libinstana_sensor.so && \
    mv glibc-nginx-1.20.1-ngx_http_ot_module.so ngx_http_opentracing_module.so; \
    else echo "KEY not provided. Not adding tracing"; \
    touch dummy.so; \
    fi

# app
FROM node:14 AS appbuilder
WORKDIR /app
COPY . .
RUN yarn install && yarn build

# Nginx
FROM nginxinc/nginx-unprivileged
# UID and GID are specified in the base imge
ARG UID=101
ARG GID=101
ARG USER=nginx
# Specify to run as root user for the subsequent commands
USER 0
# copy entrypoint.sh
COPY entrypoint.sh /
# This is giving the root group the necessary permissions to work with OpenShift restricted SCC
RUN chown -R  ${UID}:0 /var/cache/nginx /etc/nginx && \
    chmod -R g=u /var/cache/nginx /etc/nginx /docker-entrypoint.sh && \
    addgroup ${USER} root
# workdir
WORKDIR /usr/share/nginx/html
# copy app
COPY default.conf.template /etc/nginx/conf.d/default.conf.template
COPY --from=appbuilder /app/build /usr/share/nginx/html
# expose
EXPOSE 8080
ENV INSTANA_SERVICE_NAME=robo1-nginx
# copy Instana tracing
COPY --from=build /instana/*.so /tmp/
# Specify user by UID to ensure compatability with OpenShift
USER ${UID}
# copy nginx config
ENTRYPOINT ["/entrypoint.sh"]
