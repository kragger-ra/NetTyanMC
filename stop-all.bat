@echo off
chcp 65001 >nul
title Stop All Services

echo ══════════════════════════════════════════════════════
echo   STOPPING ALL SERVICES
echo ══════════════════════════════════════════════════════
echo.

docker-compose down

echo.
echo ══════════════════════════════════════════════════════
echo   ALL SERVICES STOPPED
echo ══════════════════════════════════════════════════════
echo.
pause
