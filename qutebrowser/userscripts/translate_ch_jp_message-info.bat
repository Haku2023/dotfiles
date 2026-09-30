@echo off
setlocal
rem Set this to the directory where your StarDict dictionaries are installed.
rem %APPDATA% is usually C:\Users\<username>\AppData\Roaming
set "STARDICT_DATA_DIR=%APPDATA%\stardict"
rem Set this to the full path of sdcv.exe if it is not on PATH.
set "QUTE_SDCV_EXE=C:\msys64\ucrt64\bin\sdcv.exe"
set "QUTE_TRANSLATE_SCRIPT=%~f0"
powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$s = [IO.File]::ReadAllText($env:QUTE_TRANSLATE_SCRIPT, [Text.Encoding]::UTF8); & ([scriptblock]::Create(($s -split '(?m)^# POWERSHELL_START\r?$', 2)[1]))"
exit /b %errorlevel%
# POWERSHELL_START
# Requires Windows sdcv and dictionaries listed by: sdcv.exe -l
$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

if (-not $env:QUTE_FIFO) {
    [Console]::Error.WriteLine('Run this script through qutebrowser: spawn --userscript translate_ch_jp_message-info.bat')
    exit 1
}

function Send-Message([string]$kind, [string]$html) {
    # Quote the entire HTML message as one qutebrowser argument.
    $quoted = $html.Replace('\', '\\').Replace('"', '\"')
    [IO.File]::AppendAllText($env:QUTE_FIFO, ($kind + ' --rich -- "' + $quoted + '"' + "`n"), $utf8)
}

function Escape-Html([string]$value) {
    return [Net.WebUtility]::HtmlEncode($value).Replace(';;', '&#59;&#59;')
}

try {
    $word = $env:QUTE_SELECTED_TEXT
    if ([string]::IsNullOrEmpty($word)) { $word = $env:QUTE_WORD }
    if ([string]::IsNullOrEmpty($word)) {
        Send-Message 'message-warning' 'No word selected for sdcv lookup.'
        exit 0
    }

    $sdcv = Get-Command $env:QUTE_SDCV_EXE -CommandType Application -ErrorAction SilentlyContinue
    if (-not $sdcv) {
        Send-Message 'message-error' 'sdcv.exe was not found. Install Windows sdcv and set QUTE_SDCV_EXE near the top of this .bat file to its full path.'
        exit 1
    }

    # Search all dictionaries in this folder without passing Unicode booknames
    # through the Windows native command-line encoding.
    if (-not $env:STARDICT_DATA_DIR -or -not (Test-Path -LiteralPath $env:STARDICT_DATA_DIR -PathType Container)) {
        Send-Message 'message-error' 'Dictionary folder not found. Check STARDICT_DATA_DIR near the top of this .bat file.'
        exit 1
    }
    # Non-interactive mode prevents prompts from hanging the userscript.
    $lines = & $sdcv.Source --utf8-output -n --only-data-dir --data-dir $env:STARDICT_DATA_DIR -- $word
    $status = $LASTEXITCODE
    $definition = ($lines -join "`n").Trim()
    $safeWord = (Escape-Html $word) -replace '\r\n|\r|\n', ' '

    if ($status -ne 0) {
        Send-Message 'message-warning' "Dictionary lookup failed for <b>$safeWord</b>. Check STARDICT_DATA_DIR and the installed dictionary files."
        exit 1
    }
    if ([string]::IsNullOrWhiteSpace($definition)) {
        Send-Message 'message-warning' "No definition found for <b>$safeWord</b> in selected dictionaries."
        exit 0
    }

    $safeDefinition = (Escape-Html $definition) -replace '\r\n|\r|\n', '<br />'
    Send-Message 'message-info' "<html><div><b>${safeWord}:</b><br />$safeDefinition<br />(end)</div></html>"
} catch {
    $detail = (Escape-Html $_.Exception.Message) -replace '\r\n|\r|\n', ' '
    Send-Message 'message-error' "Dictionary lookup failed: $detail"
    exit 1
}
