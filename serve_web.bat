@echo off
title Patungan Production Web Preview
echo ========================================================
echo   PATUNGAN - Production Web Bundle Preview
echo   Menjalankan server lokal pada http://localhost:8765 ...
echo ========================================================
echo.

cd /d "%~dp0build\web"

if not exist index.html (
    echo [ERROR] Folder build\web belum dibuat atau index.html tidak ditemukan.
    echo Jalankan 'flutter build web --release' terlebih dahulu.
    pause
    exit /b 1
)

echo Membuka browser pada http://localhost:8765 ...
echo Akses dari HP Android (Wi-Fi sama): http://192.168.1.9:8765
start http://localhost:8765

echo.
echo Server berjalan. Tekan Ctrl+C untuk menghentikan server.
echo ========================================================
python -m http.server 8765
