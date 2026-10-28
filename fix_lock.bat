@echo off
echo Membersihkan proses build dan cache yang terkunci...
powershell -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'flutter_tools|frontend_server' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"
rmdir /s /q "build" >nul 2>&1
rmdir /s /q "C:\FlutterCache\SPLIT_BILL_APP\build" >nul 2>&1
mkdir "C:\FlutterCache\SPLIT_BILL_APP\build" >nul 2>&1
mklink /J "build" "C:\FlutterCache\SPLIT_BILL_APP\build" >nul 2>&1
rmdir /s /q "windows\flutter\ephemeral" >nul 2>&1
echo Menjalankan flutter pub get...
call flutter pub get
echo Selesai! Folder build telah terhubung ke luar OneDrive tanpa mematikan Dart Analyzer.
