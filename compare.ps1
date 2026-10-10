\$MY_MODS = "C:\games\Prisma_launcher\instances\fluing to the skies\minecraft\mods"

# 1. Собираем имена файлов, которые уже есть в packwiz
\$packwiz_files = @()
if (Test-Path "mods") {
    foreach (\$file in (Get-ChildItem "mods\*.toml")) {
        content = Get-Content file.FullName
        foreach (line in content) {
            if (\$line -match '^filename\s*=\s*"(.*)"') {
                \(packwiz_files +=\)Matches[1]
            }
        }
    }
}

# 2. Получаем список всех .jar файлов из лаунчера
\(local_mods = Get-ChildItem "\)MY_MODS\*.jar"

Write-Host "--- ЖЕСТКИЙ ПЕРЕНОС ТОЧНЫХ ВЕРСИЙ ФАЙЛОВ В PACKWIZ ---"

foreach (mod in local_mods) {
    # Если этого конкретного файла (.jar) нет в packwiz, то жестко прописываем его
    if (mod.Name -notin packwiz_files) {
        Write-Host "Вписываю точную версию: (mod.Name)"
        
        # Считаем SHA1 хэш
        sha1 = (Get-FileHash mod.FullName -Algorithm SHA1).Hash.ToLower()
        
        # Создаем безопасное имя для .toml
        \(toml_name =\)mod.Name.ToLower() -replace '\.jar\(', '' -replace '[^a-z0-9_-]', '-'\)toml_path = "mods\$toml_name.toml"
        
        # Формируем структуру файла
        \$toml_content = "name = `"$($mod.Name -replace '\.jar$', '')`"`r`n"
        \$toml_content += "filename = `"$($mod.Name)`"`r`n"
        \$toml_content += "side = `"both`"`r`n`r`n"
        \$toml_content += "[download]`r`nhash-format = `"sha1`"`r`n"
        \$toml_content += "hash = `"$sha1`"`r`nmode = `"lite`""
        
        # Сохраняем файл
        Set-Content -Path \(toml_path -Value\)toml_content -Encoding UTF8
        Write-Host "Успешно внесено в \$toml_path"
        Write-Host "----------------------------------------"
    }
}

Write-Host "Готово! Все версии файлов из лаунчера успешно перенесены в packwiz."
