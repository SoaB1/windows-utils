param (
    [string]$SourceIsoPath,
    [string]$ExportIsoPath
)

if ((-not $SourceIsoPath) -or (-not $ExportIsoPath)) {
    Write-Host "使用方法: .\00_CreateCustomMedia.ps1 -SourceIsoPath <ソースISOのパス> -ExportIsoPath <エクスポート先フォルダのパス>" -ForegroundColor Yellow
    exit 1
}

### 変数
# 作成日を取得
$WorkDir = Get-Location
$CurrentDate = Get-Date -Format "yyyyMMdd"
# Autounattend.xmlのパス
$AutounattendPath = Join-Path -Path "${WorkDir}\config" -ChildPath "Autounattend.xml"

## ISO 解凍用変数
# ISO 展開用の一時フォルダを設定
$TempPath = $SourceIsoPath.Replace('.iso', '')

## カスタムISO作成用変数
# 作成する ISO ファイルの名前を設定
$ExportIsoFile = "custom_windows11_25H2_x64_${CurrentDate}.iso"
# ISO ファイルのフルパスを設定
$IsoFile = Join-Path -Path $ExportIsoPath -ChildPath $ExportIsoFile
# ISO にするフォルダ (カレントディレクトリ) を設定
$IsoBaseDir = "."
# oscdimg.exe のパスを設定 (Windows ADK のツールを使用)
# アーキテクチャを小文字で取得
$arch = $env:PROCESSOR_ARCHITECTURE.ToLower()
$ExecFile = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\${arch}\Oscdimg\oscdimg.exe"
# ISO のブートセクター用のファイルを設定
$IsoEtfsboot = "boot\etfsboot.com"
# UEFI ブート用のファイルを設定
$IsoEfisys = "efi\microsoft\boot\efisys.bin"
# ISO 作成コマンドを構築
$CommandOptions = "-m -o -u2 -udfver102 -bootdata:2#p0,e,b${IsoEtfsboot}#pEF,e,b${IsoEfisys}"

### Main
if (!(Test-Path $ExecFile)) {
    Write-Host "エラー: oscdimg.exe が見つかりません。パスを確認してください。" -ForegroundColor Red
    Write-Host "指定されたパス: $ExecFile" -ForegroundColor Red
    exit 1
}

if (!(Test-Path $SourceIsoPath)) {
    Write-Host "エラー: ソース ISO ファイルが見つかりません。パスを確認してください。" -ForegroundColor Red
    Write-Host "指定されたパス: $SourceIsoPath" -ForegroundColor Red
    exit 1
}

if (!(Test-Path $ExportIsoPath)) {
    Write-Host "警告: エクスポート先フォルダが存在しません。フォルダを作成します: $ExportIsoPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ExportIsoPath | Out-Null
}

Write-Host ""
Start-Sleep -Seconds 5

# ISO 展開用の一時フォルダを作成
try {
    Write-Host "情報: ISO を展開中: $SourceIsoPath" -ForegroundColor Green
    Start-Process -FilePath "7z.exe" -ArgumentList "x -bso0 -spf -o`"${TempPath}`" `"$SourceIsoPath`"" -NoNewWindow -Wait > $null
}
catch {
    Write-Host "エラー: ISO の展開に失敗しました。 : $_" -ForegroundColor Red
    exit 1
}

if (Test-Path $AutounattendPath) {
    try {
        Copy-Item -Path $AutounattendPath -Destination (Join-Path -Path $TempPath -ChildPath "Autounattend.xml") -Force
        Write-Host "情報: 応答ファイルをコピーしました。: Autounattend.xml" -ForegroundColor Green
    }
    catch {
        Write-Host "エラー: 応答ファイルのコピーに失敗しました。 : $_" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "警告: Autounattend.xml が見つかりません。カスタム設定は適用されません。" -ForegroundColor Yellow
}

$ScriptArry = @(
    "01_ConfigureNetwork.ps1"
    "config\01_ConfigureNetwork.json"
)

if (!(Test-Path -Path "$TempPath\scripts\config")) {
    New-Item -ItemType Directory -Path "$TempPath\scripts\config" | Out-Null
}

foreach ($script in $ScriptArry) {
    try {
        Copy-Item -Path (Join-Path -Path "$WorkDir" -ChildPath $script) -Destination (Join-Path -Path "$TempPath\scripts" -ChildPath $script) -Force
    }
    catch {
        Write-Host "エラー: スクリプトのコピーに失敗しました: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host "情報: スクリプトをコピーしました: $script" -ForegroundColor Green
}

Write-Host ""
Start-Sleep -Seconds 5

# ISO 作成コマンドを実行
try {
    Write-Host "情報: カスタム ISO を作成中: $IsoFile" -ForegroundColor Green
    Start-Process -FilePath $ExecFile -ArgumentList "$CommandOptions `"$IsoBaseDir`" `"$IsoFile`"" -WorkingDirectory $TempPath -NoNewWindow -Wait
}
catch {
    Write-Host "エラー: カスタム ISO の作成に失敗しました。 : $_" -ForegroundColor Red
    exit 1
}

if (Test-Path $IsoFile) {
    Write-Host "情報: カスタム ISO が正常に作成されました: $IsoFile" -ForegroundColor Green
    Remove-Item -Path $TempPath -Recurse -Force
}
else {
    Write-Host "エラー: カスタム ISO の作成に失敗しました。" -ForegroundColor Red
    exit 1
}

# 処理が終了したことを確認するため、一時停止
Read-Host -Prompt "処理が完了しました。Enterキーを押して終了します"
