FROM node:20-alpine

# SECURITY: Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Устанавливаем build tools для нативных модулей
RUN apk add --no-cache python3 make g++

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем package.json и package-lock.json
COPY --chown=appuser:appgroup package*.json ./

# Устанавливаем зависимости
RUN npm ci --production

# Копируем исходный код
COPY --chown=appuser:appgroup . .

# SECURITY: Switch to non-root user
USER appuser

# Открываем порт
EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Команда запуска
CMD ["npm", "start"]
