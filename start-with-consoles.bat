@echo off
chcp 65001 >nul
title AgiCraft Server Startup

echo ══════════════════════════════════════════════════════
echo   AGICRAFT MINECRAFT SERVER - STARTUP
echo ══════════════════════════════════════════════════════
echo.
echo Starting all services...
echo.

:: Запускаем все контейнеры
docker-compose up -d

echo.
echo Waiting for services to start...
timeout /t 5 /nobreak >nul

echo.
echo Opening console windows for each service...
echo.

:: Открываем консоль для PostgreSQL
start "PostgreSQL Database" cmd /k "docker logs -f minecraft_postgres"

:: Ждем 1 секунду между открытиями окон
timeout /t 1 /nobreak >nul

:: Открываем консоль для Backend
start "Backend API" cmd /k "docker logs -f agicraft_backend"

timeout /t 1 /nobreak >nul

:: Открываем консоль для Velocity Proxy
start "Velocity Proxy" cmd /k "docker logs -f minecraft_velocity"

timeout /t 1 /nobreak >nul

:: Открываем консоль для Lobby Server
start "Lobby Server" cmd /k "docker logs -f minecraft_lobby"

timeout /t 1 /nobreak >nul

:: Открываем консоль для Survival Server
start "Survival Server" cmd /k "docker logs -f minecraft_survival"

timeout /t 1 /nobreak >nul

:: Открываем консоль для AI Research Server
start "AI Research Server" cmd /k "docker logs -f minecraft_airesearch"

timeout /t 1 /nobreak >nul

:: Открываем консоль для Caddy (Web Server)
start "Caddy Web Server" cmd /k "docker logs -f agicraft_caddy"

echo.
echo ══════════════════════════════════════════════════════
echo   ALL SERVICES STARTED
echo ══════════════════════════════════════════════════════
echo.
echo Console windows opened for:
echo   - PostgreSQL Database
echo   - Backend API
echo   - Velocity Proxy
echo   - Lobby Server
echo   - Survival Server
echo   - AI Research Server
echo   - Caddy Web Server
echo.
echo Connection addresses:
echo   Main entry: localhost:25565 (Velocity Proxy)
echo   AI Research: localhost:25570 (direct)
echo   Website: http://localhost (Caddy)
echo.
echo To stop all services, run: docker-compose down
echo.
pause
