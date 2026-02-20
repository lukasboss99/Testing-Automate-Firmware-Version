@echo off

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install.ps1"

if %ERRORLEVEL% neq 0 (
	pause
    exit /b %ERRORLEVEL%
)
timeout /t 2 /nobreak >nul