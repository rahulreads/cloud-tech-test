# Use a minimal base image
FROM python:3.10-slim

# Create a non-root user and group
RUN addgroup --system appgroup && adduser --system --group appuser

# Set the working directory
WORKDIR /app

# Copy only the requirements file first for caching
COPY requirements.txt .

# Install dependencies as root
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files
COPY . .

# Change ownership of the app directory to the non-root user
RUN chown -R appuser:appgroup /app

# Switch to the non-root user
USER appuser

# Expose the application port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
