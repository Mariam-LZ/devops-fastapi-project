# 🚀 DevOps FastAPI Application - Local Setup

## 📌 Overview

This project is based on the Full Stack FastAPI template.  
The goal is to **run and manage the application in a DevOps context**, without modifying the core application logic.

This document explains how to run the project locally using Docker Compose.

## 🛠️ Prerequisites

Make sure you have installed:

- Docker
- Docker Compose

## ⚙️ Environment Configuration

### 1. Copy environment file

```bash
cp .env.example .env
```

### 2. Update required variables

```bash
SECRET_KEY=your_secret_key
FIRST_SUPERUSER=admin@example.com
FIRST_SUPERUSER_PASSWORD=your_password
POSTGRES_PASSWORD=your_db_password
```

### 🔑 Generate a secure SECRET_KEY

```bash
docker run --rm python:3.11 python -c "import secrets; print(secrets.token_urlsafe(32))"
```

## ▶️ Run and build the application

```bash
docker compose up -d --build
```

## 🌐 Access the services

| Service     | URL                         |
|------------|-----------------------------|
| Frontend   | http://localhost:5173       |
| Backend    | http://localhost:8000       |
| Adminer    | http://localhost:8080       |
| Traefik UI | http://localhost:8090       |

## 🔐 Default credentials

```text
Email: admin@example.com
Password: (value set in FIRST_SUPERUSER_PASSWORD)
```

## 🧪 Health check

```bash
curl http://localhost:8000/api/v1/utils/health-check/
```
Expected response: true

## 🧱 Architecture

The application runs with the following services:

- Frontend (Vite + Nginx)
- Backend (FastAPI)
- Database (PostgreSQL)
- Reverse Proxy (Traefik)
- Adminer (DB management)
- Mailcatcher (email testing)

## 🧠 DevOps Notes

- `.env` file is not committed
- `.env.example` is used as a template
- Services are containerized
- Environment is reproducible