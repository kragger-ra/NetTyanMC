@echo off
chcp 65001 >nul
title Reset PostgreSQL Database

echo ══════════════════════════════════════════════════════
echo   RESET POSTGRESQL DATABASE
echo ══════════════════════════════════════════════════════
echo.
echo WARNING: This will DELETE all data in the database!
echo.
pause

echo.
echo Stopping all containers...
docker-compose down

echo.
echo Removing PostgreSQL volume...
docker volume rm minecraftserver_postgres_data

echo.
echo Done! The database will be recreated on next startup.
echo Run start-with-consoles.bat to start the server.
echo.
pause
