# Multi-stage build for combined frontend + backend
FROM python:3.9-slim AS backend-stage
WORKDIR /backend
COPY backend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/ ./

FROM node:18-alpine AS frontend-stage
WORKDIR /frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./

# Final combined image
FROM python:3.9-slim
WORKDIR /app

# Install Node.js
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs supervisor && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy backend
COPY --from=backend-stage /backend /app/backend
COPY --from=backend-stage /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages

# Copy frontend
COPY --from=frontend-stage /frontend /app/frontend

# Create supervisor config
RUN echo '[supervisord]\n\
nodaemon=true\n\
\n\
[program:backend]\n\
command=python3 /app/backend/app.py\n\
directory=/app/backend\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
\n\
[program:frontend]\n\
command=node /app/frontend/server.js\n\
directory=/app/frontend\n\
autostart=true\n\
autorestart=true\n\
environment=API_URL="http://localhost:5000"\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0' > /etc/supervisor/supervisord.conf

EXPOSE 3000 5000

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
