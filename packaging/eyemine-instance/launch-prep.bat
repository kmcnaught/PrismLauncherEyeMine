@echo off
setlocal enabledelayedexpansion
set "MOD_SRC=C:\Program Files (x86)\SpecialEffect\EyeMineV2\ModInstaller"

set "MOD_JAR="
for /f "delims=" %%f in ('dir /b /a-d "%MOD_SRC%\eyemine*.jar" 2^>nul') do set "MOD_JAR=%MOD_SRC%\%%f"

if "!MOD_JAR!"=="" (
    echo ERROR: EyeMine mod not found at !MOD_SRC!
    echo Please ensure EyeMine is installed before launching.
    exit /b 1
)

if not exist "!INST_MC_DIR!\mods" mkdir "!INST_MC_DIR!\mods"
copy /Y "!MOD_JAR!" "!INST_MC_DIR!\mods\eyemine.jar"
