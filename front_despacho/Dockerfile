# =========================
# Stage 1 - Build
# =========================
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar dependencias primero para aprovechar cache
COPY package*.json ./

RUN npm install

# Copiar resto del proyecto
COPY . .

# Build producción
RUN npm run build


# =========================
# Stage 2 - Production
# =========================
FROM nginx:stable-alpine

# Instalar envsubst y bash
RUN apk add --no-cache gettext bash

# Copiar template de configuración nginx
COPY nginx.conf.template /etc/nginx/conf.d/default.conf.template

# Copiar build generado
COPY --from=builder /app/dist /usr/share/nginx/html

# Exponer puerto nginx
EXPOSE 80

# Ejecutar envsubst + nginx directamente
CMD ["/bin/bash", "-c", "envsubst '${VENTAS_BACK_HOST}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]