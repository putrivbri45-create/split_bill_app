@echo off
title Patungan Split Bill App - Microsoft Edge
echo ========================================================
echo   PATUNGAN - Smart Split-Bill & Expense-Sharing App
echo   Menjalankan aplikasi pada Microsoft Edge...
echo ========================================================
echo.

cd /d "%~dp0"

echo [1/2] Memeriksa dependensi Flutter...
call flutter pub get

echo.
echo [2/2] Memulai aplikasi di browser Microsoft Edge...
echo.
echo Petunjuk interaktif:
echo  - Hot Reload  : Tekan 'r' pada jendela terminal
echo  - Hot Restart : Tekan 'R' pada jendela terminal
echo  - Keluar      : Tekan 'q' pada jendela terminal
echo ========================================================
echo.

call flutter run -d edge

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Gagal menjalankan aplikasi di Edge atau proses dihentikan.
    pause
)
