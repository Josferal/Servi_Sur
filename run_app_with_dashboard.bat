@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\run_app_with_dashboard.ps1" %*
