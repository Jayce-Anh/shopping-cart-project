# Stage 1: Build React app
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve with nginx (for local/container testing)
# Production deployment uses S3 + CloudFront instead
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html

# nginx config: redirect all routes to index.html (SPA fallback)
RUN printf 'server {\n\
  listen 80;\n\
  root /usr/share/nginx/html;\n\
  index index.html;\n\
  location / {\n\
    try_files $uri $uri/ /index.html;\n\
  }\n\
}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
