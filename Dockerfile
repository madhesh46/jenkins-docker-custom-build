# Use official Python slim image for smaller size
FROM python:3.12-slim

# Set working directory inside container
WORKDIR /app

# Copy only requirements first to leverage Docker cache
COPY requirements.txt .

# Install dependencies with no cache to reduce layer size
RUN pip install --no-cache-dir -r requirements.txt

# Copy all source code to working directory
COPY . .

# Optional: Expose port if your app runs on specific port (e.g., 8080)
# EXPOSE 8080

# Default command to run your app (adjust if needed)
CMD ["python", "app.py"]

