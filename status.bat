@echo off
chcp 65001 >nul
title Server Status

echo ══════════════════════════════════════════════════════
echo   AGICRAFT SERVER STATUS
echo ══════════════════════════════════════════════════════
echo.

docker-compose ps

echo.
echo ══════════════════════════════════════════════════════
echo.
pause
