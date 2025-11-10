@echo off
echo Включаем выполнение PowerShell скриптов...
PowerShell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
echo Готово! Теперь можно запускать Mass-Installer.ps1
pause