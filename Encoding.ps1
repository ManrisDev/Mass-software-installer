try {
    # Попытка установить UTF-8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
}
catch {
    # Если UTF-8 не работает, пробуем cp866
    try {
        [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
        $OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
    }
    catch {
        Write-Warning "Не удалось установить корректную кодировку для кириллицы"
    }
}