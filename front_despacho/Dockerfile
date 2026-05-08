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

# Copiar configuración nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar build generado
COPY --from=builder /app/dist /usr/share/nginx/html

# Exponer puerto nginx
EXPOSE 80

# Ejecutar nginx
CMD ["nginx", "-g", "daemon off;"]