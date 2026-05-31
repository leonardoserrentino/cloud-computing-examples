# Stage 1: Build and isolate dependencies
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Create the minimal runtime image
FROM python:3.11-slim
WORKDIR /app
# Copy installed dependencies from the builder stage
COPY --from=builder /root/.local /root/.local
COPY app.py .

# Update PATH to include user-installed python binaries
ENV PATH=/root/.local/bin:$PATH
EXPOSE 5000

CMD ["python", "app.py"]
