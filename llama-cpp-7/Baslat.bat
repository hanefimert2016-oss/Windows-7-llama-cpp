@echo off
title Llama-Server 512k Context (Occamy-1.0 / agent.gguf)

set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"
set "PYTHONUTF8=1"
set "OPEN_TERMINAL_KEY=BURAYA_ANAHTAR_GIRIN"

if exist "%BASE_DIR%\models\occamy-ai_occamy-1.0-Q4_K_M.gguf" (
    ren "%BASE_DIR%\models\occamy-ai_occamy-1.0-Q4_K_M.gguf" "agent.gguf"
)

taskkill /F /IM ollama.exe >nul 2>&1
taskkill /F /IM "ollama app.exe" >nul 2>&1
taskkill /F /IM llama-server.exe >nul 2>&1

:: --- 1. TERMİNAL: LLAMA-SERVER ---
cd /d "%BASE_DIR%\llama-cpp-7"
start "Llama-Server" llama-server.exe -m "%BASE_DIR%\models\agent.gguf" --alias "agent" -ngl 99 --cpu-moe -c 524288 -np 1 --rope-scaling yarn --rope-scale 2 --yarn-orig-ctx 262144 --no-reasoning-preserve -t 6 -b 1024 -ub 512 -fa on -ctk q4_0 -ctv q4_0 --temp 0.15 --repeat-penalty 1.15 --port 11434

timeout /t 5 /nobreak >nul

:: --- 2. TERMİNAL: OPEN WEBUI ---
start "openwebui" cmd /k "set PYTHONUTF8=1 && cd /d "%BASE_DIR%\OpenWebUI" && call "%BASE_DIR%\OpenWebUI\env\Scripts\open-webui.exe" serve"

:: --- 3. TERMİNAL: OPEN TERMINAL ---
if not exist "%BASE_DIR%\WORKSPACE" mkdir "%BASE_DIR%\WORKSPACE"
start "Ucuncu Terminal" cmd /k "set PYTHONUTF8=1 && cd /d "%BASE_DIR%\WORKSPACE" && call "%BASE_DIR%\OpenWebUI\env\Scripts\open-terminal.exe" run --host 127.0.0.1 --port 8000 --api-key %OPEN_TERMINAL_KEY%"
