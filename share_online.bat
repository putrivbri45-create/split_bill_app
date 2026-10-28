@echo off
title Patungan - Share Online Tunnel
echo ========================================================
echo   PATUNGAN - Share Online via Cloudflare Tunnel
echo ========================================================
echo.

cd /d "%~dp0"

echo [1/2] Menjalankan server web lokal di port 8765...
start /b python -m http.server 8765 --directory build\web

echo [2/2] Menghubungkan ke Cloudflare Tunnel publik...
echo.
echo Link publik HTTPS akan muncul di bawah ini dalam beberapa detik:
echo ========================================================
cloudflared.exe tunnel --url http://localhost:8765
