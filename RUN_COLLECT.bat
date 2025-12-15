@echo off
REM Host Evidence Runner (HER) - Batch wrapper for run-collector.ps1
REM Designed for quick deployment from USB or network share.
REM Derived from the archived Cado-Batch project; independently maintained.

setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-collector.ps1"
exit /b %ERRORLEVEL%
