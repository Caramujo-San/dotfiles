# source https://github.com/rodolphocastro/dotfiles/blob/master/powershell/misc/vscode_store_extensions.ps1

$codeExtensions = code --list-extensions
$codeExtensions | ForEach-Object -Process { &code --install-extension $_ --force }