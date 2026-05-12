# Stage 1: Build
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Stage 2: Runtime (Limpieza de capas) [cite: 91, 129]
FROM node:18-alpine
WORKDIR /app
COPY --from=build /app ./
# Instalación solo de dependencias de producción
RUN npm prune --production 
# Uso de usuario no-root incluido en la imagen de node [cite: 91]
USER node
EXPOSE 3000
CMD ["npm", "start"]