FROM node:20-alpine AS builder

WORKDIR /app

# Копируем package files
COPY package*.json ./

# Устанавливаем зависимости
RUN npm install

# Копируем исходный код
COPY . .

# Устанавливаем переменную окружения для Vite
ARG VITE_API_URL=/api
ENV VITE_API_URL=$VITE_API_URL

# Собираем production build
RUN npm run build

# Production stage
FROM nginx:alpine

# SECURITY: Run as non-root
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# Копируем собранные файлы
COPY --from=builder --chown=nginx:nginx /app/dist /usr/share/nginx/html

# Копируем конфиг nginx
COPY --chown=nginx:nginx nginx.conf /etc/nginx/conf.d/default.conf

# SECURITY: Switch to non-root user
USER nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
