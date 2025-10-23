param (
    [string]$SourceIsoPath,
    [string]$ExportIsoPath
)

if ((-not $SourceIsoPath) -or (-not $ExportIsoPath)) {
    Write-Host "�g�p���@: .\00_CreateCustomMedia.ps1 -SourceIsoPath <�\�[�XISO�̃p�X> -ExportIsoPath <�G�N�X�|�[�g��t�H���_�̃p�X>" -ForegroundColor Yellow
    exit 1
}

### �ϐ�
# �쐬�����擾
$WorkDir = Get-Location
$CurrentDate = Get-Date -Format "yyyyMMdd"
# Autounattend.xml�̃p�X
$AutounattendPath = Join-Path -Path "${WorkDir}\config" -ChildPath "Autounattend.xml"

## ISO �𓀗p�ϐ�
# ISO �W�J�p�̈ꎞ�t�H���_��ݒ�
$TempPath = $SourceIsoPath.Replace('.iso', '')

## �J�X�^��ISO�쐬�p�ϐ�
# �쐬���� ISO �t�@�C���̖��O��ݒ�
$ExportIsoFile = "custom_windows11_25H2_x64_${CurrentDate}.iso"
# ISO �t�@�C���̃t���p�X��ݒ�
$IsoFile = Join-Path -Path $ExportIsoPath -ChildPath $ExportIsoFile
# ISO �ɂ���t�H���_ (�J�����g�f�B���N�g��) ��ݒ�
$IsoBaseDir = "."
# oscdimg.exe �̃p�X��ݒ� (Windows ADK �̃c�[�����g�p)
# �A�[�L�e�N�`�����������Ŏ擾
$arch = $env:PROCESSOR_ARCHITECTURE.ToLower()
$ExecFile = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\${arch}\Oscdimg\oscdimg.exe"
# ISO �̃u�[�g�Z�N�^�[�p�̃t�@�C����ݒ�
$IsoEtfsboot = "boot\etfsboot.com"
# UEFI �u�[�g�p�̃t�@�C����ݒ�
$IsoEfisys = "efi\microsoft\boot\efisys.bin"
# ISO �쐬�R�}���h���\�z
$CommandOptions = "-m -o -u2 -udfver102 -bootdata:2#p0,e,b${IsoEtfsboot}#pEF,e,b${IsoEfisys}"

### Main
if (!(Test-Path $ExecFile)) {
    Write-Host "�G���[: oscdimg.exe ��������܂���B�p�X���m�F���Ă��������B" -ForegroundColor Red
    Write-Host "�w�肳�ꂽ�p�X: $ExecFile" -ForegroundColor Red
    exit 1
}

if (!(Test-Path $SourceIsoPath)) {
    Write-Host "�G���[: �\�[�X ISO �t�@�C����������܂���B�p�X���m�F���Ă��������B" -ForegroundColor Red
    Write-Host "�w�肳�ꂽ�p�X: $SourceIsoPath" -ForegroundColor Red
    exit 1
}

if (!(Test-Path $ExportIsoPath)) {
    Write-Host "�x��: �G�N�X�|�[�g��t�H���_�����݂��܂���B�t�H���_���쐬���܂�: $ExportIsoPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ExportIsoPath | Out-Null
}

Write-Host ""
Start-Sleep -Seconds 5

# ISO �W�J�p�̈ꎞ�t�H���_���쐬
try {
    Write-Host "���: ISO ��W�J��: $SourceIsoPath" -ForegroundColor Green
    Start-Process -FilePath "7z.exe" -ArgumentList "x -bso0 -spf -o`"${TempPath}`" `"$SourceIsoPath`"" -NoNewWindow -Wait > $null
}
catch {
    Write-Host "�G���[: ISO �̓W�J�Ɏ��s���܂����B : $_" -ForegroundColor Red
    exit 1
}

if (Test-Path $AutounattendPath) {
    try {
        Copy-Item -Path $AutounattendPath -Destination (Join-Path -Path $TempPath -ChildPath "Autounattend.xml") -Force
        Write-Host "���: �����t�@�C�����R�s�[���܂����B: Autounattend.xml" -ForegroundColor Green
    }
    catch {
        Write-Host "�G���[: �����t�@�C���̃R�s�[�Ɏ��s���܂����B : $_" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "�x��: Autounattend.xml ��������܂���B�J�X�^���ݒ�͓K�p����܂���B" -ForegroundColor Yellow
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
        Write-Host "�G���[: �X�N���v�g�̃R�s�[�Ɏ��s���܂���: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host "���: �X�N���v�g���R�s�[���܂���: $script" -ForegroundColor Green
}

Write-Host ""
Start-Sleep -Seconds 5

# ISO �쐬�R�}���h�����s
try {
    Write-Host "���: �J�X�^�� ISO ���쐬��: $IsoFile" -ForegroundColor Green
    Start-Process -FilePath $ExecFile -ArgumentList "$CommandOptions `"$IsoBaseDir`" `"$IsoFile`"" -WorkingDirectory $TempPath -NoNewWindow -Wait
}
catch {
    Write-Host "�G���[: �J�X�^�� ISO �̍쐬�Ɏ��s���܂����B : $_" -ForegroundColor Red
    exit 1
}

if (Test-Path $IsoFile) {
    Write-Host "���: �J�X�^�� ISO ������ɍ쐬����܂���: $IsoFile" -ForegroundColor Green
    Remove-Item -Path $TempPath -Recurse -Force
}
else {
    Write-Host "�G���[: �J�X�^�� ISO �̍쐬�Ɏ��s���܂����B" -ForegroundColor Red
    exit 1
}

# �������I���������Ƃ��m�F���邽�߁A�ꎞ��~
Read-Host -Prompt "�������������܂����BEnter�L�[�������ďI�����܂�"
