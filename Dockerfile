# Usar imagen base de Python 3.11 slim
FROM python:3.11-slim

# Establecer el directorio de trabajo
WORKDIR /app

# Crear usuario no-root para seguridad
RUN useradd --create-home --shell /bin/bash app

# Copiar archivos de dependencias
COPY requirements.txt .

# Instalar dependencias del sistema y Python
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir -r requirements.txt

# Copiar el código de la aplicación
COPY . .

# Crear directorio para archivos estáticos si no existe
RUN mkdir -p static

# Cambiar permisos y propietario
RUN chown -R app:app /app
USER app

# Exponer el puerto
EXPOSE 5000

# Variables de entorno por defecto
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PYTHONPATH=/app

# Comando de salud para Docker
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Comando por defecto usando Gunicorn para producción
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "--timeout", "60", "--access-logfile", "-", "--error-logfile", "-", "app:app"]