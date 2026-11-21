@echo off
chcp 65001 >nul
title Otomatik Kurulum ve Baslatici - Temiz Windows 7 / 10 / 11

:: 1. Yonetici Yetkisi Kontrolu
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [HATA] Lutfen bu dosyaya sag tiklayip "Yonetici olarak calistir" secin!
    pause
    exit /b
)

set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"
cd /d "%BASE_DIR%"

set "MODEL_URL=https://huggingface.co/bartowski/occamy-ai_occamy-1.0-GGUF/resolve/main/occamy-ai_occamy-1.0-Q4_K_M.gguf"
set "OPEN_TERMINAL_KEY=BURAYA_ANAHTAR_GIRIN"

if not exist "%BASE_DIR%\WORKSPACE" mkdir "%BASE_DIR%\WORKSPACE"
if not exist "%BASE_DIR%\models" mkdir "%BASE_DIR%\models"
if not exist "%BASE_DIR%\OpenWebUI" mkdir "%BASE_DIR%\OpenWebUI"

:: 2. Temiz Windows 7 icin TLS 1.2 ve Sistem Gereksinimleri
ver | findstr /i "6.1." >nul
if %errorlevel% equ 0 (
    echo [WIN7] TLS 1.2 guvenli baglanti ayarlari etkinlestiriliyor...
    reg add "HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" /v SchUseStrongCrypto /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" /v SchUseStrongCrypto /t REG_DWORD /d 1 /f >nul 2>&1

    :: Visual C++ 2015-2022 x64 Kontrolu (llama-server ve Python icin sart)
    if not exist "%SystemRoot%\System32\vcruntime140.dll" (
        echo [INDIRILIYOR] Visual C++ 2015-2022 Redistributable kuruluyor...
        bitsadmin /transfer "VCRedist" /download /priority normal "https://aka.ms" "%TEMP%\vc_redist.x64.exe" >nul
        "%TEMP%\vc_redist.x64.exe" /install /quiet /norestart
    )

    :: VxKex Kontrolu ve Kurulumu
    if not exist "C:\Program Files\VxKex\KexCfg.exe" (
        echo [INDIRILIYOR] VxKex indiriliyor ve kuruluyor...
        bitsadmin /transfer "VxKex" /download /priority normal "https://github.com" "%TEMP%\VxKexSetup.exe" >nul
        "%TEMP%\VxKexSetup.exe" /S
        echo [UYARI] VxKex kuruldu. Bilgisayari yeniden baslatip bu dosyayi tekrar calistirin!
        pause
        exit /b
    )
)

:: 3. Python 3.11 Kontrolu ve Kurulumu
set "SYS_PYTHON="
if exist "%LocalAppData%\Programs\Python\Python311\python.exe" set "SYS_PYTHON=%LocalAppData%\Programs\Python\Python311\python.exe"
if exist "C:\Python311\python.exe" set "SYS_PYTHON=C:\Python311\python.exe"

if "%SYS_PYTHON%"=="" (
    echo [INDIRILIYOR] Python 3.11.18 indiriliyor...
    bitsadmin /transfer "Python311" /download /priority normal "https://github.com" "%TEMP%\python311.exe" >nul
    echo [KURULUYOR] Python 3.11 sessiz kurulum yapiliyor...
    "%TEMP%\python311.exe" /quiet InstallAllUsers=0 PrependPath=1 TargetDir="C:\Python311"
    set "SYS_PYTHON=C:\Python311\python.exe"
)

:: Turkce Windows cp1254 platform.py yamasi (Her zaman uygula)
"%SYS_PYTHON%" -X utf8 -c "import os; p=os.path.join(os.path.dirname(r'%SYS_PYTHON%'),'Lib','platform.py'); d=open(p,encoding='utf-8').read() if os.path.exists(p) else ''; q=chr(34); open(p,'w',encoding='utf-8').write(d.replace(',errors='+q+'ignore'+q,'').replace('text=True','text=True,errors='+q+'ignore'+q)) if d else None"

:: 4. OpenWebUI\env Sanal Ortam Kontrolu ve Onarimi
if not exist "%BASE_DIR%\OpenWebUI\env\Scripts\python.exe" (
    echo [OLUSTURULUYOR] Sanal ortam kuruluyor (bu islem birkac dakika surebilir)...
    "%SYS_PYTHON%" -m venv "%BASE_DIR%\OpenWebUI\env"
    "%BASE_DIR%\OpenWebUI\env\Scripts\python.exe" -X utf8 -m pip install --upgrade pip
    "%BASE_DIR%\OpenWebUI\env\Scripts\python.exe" -X utf8 -m pip install open-webui open-terminal
) else (
    echo [ONARILIYOR] Hazir env klasoru yeni bilgisayara uyarlaniyor...
    "%SYS_PYTHON%" -X utf8 -c "import os, re; p=r'%BASE_DIR%\OpenWebUI\env\pyvenv.cfg'; py_dir=os.path.dirname(r'%SYS_PYTHON%'); s=open(p,encoding='utf-8',errors='ignore').read() if os.path.exists(p) else ''; s=re.sub(r'home\s*=.*', 'home = '+py_dir, s); s=re.sub(r'executable\s*=.*', 'executable = '+r'%SYS_PYTHON%', s); s=re.sub(r'command\s*=.*', 'command = '+r'%SYS_PYTHON% -m venv %BASE_DIR%\OpenWebUI\env', s); open(p,'w',encoding='utf-8').write(s) if s else None"
    "%BASE_DIR%\OpenWebUI\env\Scripts\python.exe" -X utf8 -m pip install --force-reinstall --no-deps open-webui open-terminal >nul 2>&1
)

:: 5. Windows 7 ise VxKex Kayit Defteri Aktivasyonu
ver | findstr /i "6.1." >nul
if %errorlevel% equ 0 (
    echo [AYARLANIYOR] VxKex tum calistirilabilir dosyalar icin etkinlestiriliyor...
    for %%F in (
        "%SYS_PYTHON%"
        "%BASE_DIR%\OpenWebUI\env\Scripts\python.exe"
        "%BASE_DIR%\OpenWebUI\env\Scripts\open-webui.exe"
        "%BASE_DIR%\OpenWebUI\env\Scripts\open-terminal.exe"
        "%BASE_DIR%\llama-cpp-7\llama-server.exe"
    ) do (
        if exist %%F (
            reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %%F /t REG_SZ /d "VXKEX" /f >nul 2>&1
        )
    )
)

:: 6. Model Indirme (bitsadmin Windows 7'de yerlesiktir ve yarida kalirsa devam eder)
if exist "%BASE_DIR%\models\occamy-ai_occamy-1.0-Q4_K_M.gguf" ren "%BASE_DIR%\models\occamy-ai_occamy-1.0-Q4_K_M.gguf" "agent.gguf"
if not exist "%BASE_DIR%\models\agent.gguf" (
    echo [INDIRILIYOR] agent.gguf (21.4 GB) indiriliyor, lutfen bekleyin...
    bitsadmin /transfer "OccamyModel" /download /priority high "%MODEL_URL%" "%BASE_DIR%\models\agent.gguf"
)

echo [TAMAM] Kurulum tamamlandi, sistem baslatiliyor...
call "%BASE_DIR%\Baslat.bat"
