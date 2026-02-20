@echo off

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install Git.ps1"

if %ERRORLEVEL% neq 0 (
	pause
    exit /b %ERRORLEVEL%
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install Githooks.ps1"

if %ERRORLEVEL% neq 0 (
	pause
    exit /b %ERRORLEVEL%
)

timeout /t 3 /nobreak >nul