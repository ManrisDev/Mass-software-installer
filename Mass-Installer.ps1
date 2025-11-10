# Mass-Installer.ps1
# Утилита для массовой установки ПО на Windows

# Приветствие
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Массовый установщик ПО для Windows" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Следующие программы будут установлены:" -ForegroundColor Yellow
Write-Host "  - Notepad++ (текстовый редактор)" -ForegroundColor White
Write-Host "  - 7-Zip (архиватор)" -ForegroundColor White
Write-Host "  - VLC (медиаплеер)" -ForegroundColor White
Write-Host "  - Git (система контроля версий)" -ForegroundColor White
Write-Host "  - SumatraPDF (PDF-просмотрщик)" -ForegroundColor White
Write-Host ""
Write-Host "Для установки требуются права администратора." -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Проверка прав администратора
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "ОШИБКА: Скрипт должен быть запущен с правами администратора!" -ForegroundColor Red
    Write-Host "Запустите PowerShell от имени администратора и повторите попытку." -ForegroundColor Red
    exit 1
}

# Проверка и установка Chocolatey если необходимо
function Test-Chocolatey {
    try {
        $chocoVersion = choco --version
        return $true
    }
    catch {
        return $false
    }
}

Write-Host "Проверка наличия Chocolatey..." -ForegroundColor Yellow
if (-not (Test-Chocolatey)) {
    Write-Host "Chocolatey не найден. Установка..." -ForegroundColor Yellow
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "Chocolatey успешно установлен." -ForegroundColor Green
    }
    catch {
        Write-Host "ОШИБКА: Не удалось установить Chocolatey." -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "Chocolatey найден." -ForegroundColor Green
}

# Запрос подтверждения
$confirmation = Read-Host "Продолжить установку? (Y/N)"
if ($confirmation -notmatch '^[Yy]$') {
    Write-Host "Установка отменена пользователем." -ForegroundColor Yellow
    exit 0
}
Write-Host ""

# Список программ для установки
$SoftwareList = @(
    @{Name = "notepadplusplus"; DisplayName = "Notepad++" },
    @{Name = "7zip"; DisplayName = "7-Zip" },
    @{Name = "vlc"; DisplayName = "VLC Media Player" },
    @{Name = "git"; DisplayName = "Git" },
    @{Name = "sumatrapdf"; DisplayName = "Sumatra PDF" }
)

Write-Host "Начинается установка программ..." -ForegroundColor Green
Write-Host ""

# Установка программ
$LogFile = "installation_log.txt"
"=== Лог установки от $(Get-Date) ===" | Out-File -FilePath $LogFile
$SuccessCount = 0
$ErrorCount = 0

foreach ($software in $SoftwareList) {
    $packageName = $software.Name
    $displayName = $software.DisplayName
    
    Write-Host "Установка: $displayName" -ForegroundColor Cyan
    
    # Проверка, установлен ли пакет уже
    $isInstalled = choco list --local-only | Where-Object { $_ -match "^$packageName " }
    
    if ($isInstalled) {
        Write-Host "[OK] $displayName уже установлен. Пропускаем." -ForegroundColor Yellow
        "Пакет '$displayName' уже установлен." | Out-File -FilePath $LogFile -Append
        $SuccessCount++
        continue
    }
    
    # Попытка установки
    try {
        choco install $packageName -y --no-progress
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] УСПЕХ: $displayName установлен." -ForegroundColor Green
            "УСПЕХ: $displayName установлен." | Out-File -FilePath $LogFile -Append
            $SuccessCount++
        }
        else {
            Write-Host "[ERROR] ОШИБКА: Не удалось установить $displayName (код: $LASTEXITCODE)" -ForegroundColor Red
            "ОШИБКА: Не удалось установить $displayName (код: $LASTEXITCODE)" | Out-File -FilePath $LogFile -Append
            $ErrorCount++
        }
    }
    catch {
        Write-Host "[ERROR] ОШИБКА: Не удалось установить $displayName" -ForegroundColor Red
        "ОШИБКА: Не удалось установить $displayName - $($_.Exception.Message)" | Out-File -FilePath $LogFile -Append
        $ErrorCount++
    }
    
    Start-Sleep -Seconds 2  # Небольшая пауза между установками
}

# Итоговый отчет
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "           УСТАНОВКА ЗАВЕРШЕНА" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Успешно установлено: $SuccessCount" -ForegroundColor Green
Write-Host "С ошибками: $ErrorCount" -ForegroundColor Red
Write-Host "Лог сохранен в: $LogFile" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan