@echo off
REM Agent Manager CLI Wrapper Script for Windows
REM This script allows running agent-manager without typing 'java -jar'
REM Detects Java version and uses the appropriate JAR (Java 8 or Java 21)

setlocal enabledelayedexpansion

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"

REM Check if Java is available
where java >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: Java is not installed or not in PATH.
    echo Please install Java 8 or later and ensure it's in your system PATH.
    exit /b 1
)

REM Get Java version
for /f "tokens=3" %%g in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    set JAVA_VERSION_RAW=%%g
    set JAVA_VERSION_RAW=!JAVA_VERSION_RAW:"=!
    goto :parse_version
)
:parse_version

REM Extract major version number
set JAR_NAME=
for /f "tokens=1 delims=." %%a in ("!JAVA_VERSION_RAW!") do set JAVA_MAJOR=%%a
for /f "tokens=2 delims=." %%b in ("!JAVA_VERSION_RAW!") do set JAVA_MINOR=%%b

REM Determine which JAR to use
if "!JAVA_MAJOR!"=="1" (
    REM Java 8 or earlier (1.8.x)
    if "!JAVA_MINOR!"=="8" (
        set JAR_NAME=agent-manager-java8.jar
    ) else (
        echo Error: Java version !JAVA_VERSION_RAW! is not supported.
        echo Please install Java 8 or Java 21 or later.
        exit /b 1
    )
) else (
    REM Java 9 or later
    set /a JAVA_MAJOR_NUM=!JAVA_MAJOR!
    if !JAVA_MAJOR_NUM! LSS 8 (
        echo Error: Java version !JAVA_VERSION_RAW! is not supported.
        echo Please install Java 8 or Java 21 or later.
        exit /b 1
    ) else if !JAVA_MAJOR_NUM! GEQ 21 (
        set JAR_NAME=agent-manager-java21.jar
    ) else (
        REM Java 9-20, use Java 8 version
        set JAR_NAME=agent-manager-java8.jar
    )
)

REM Fallback if version detection failed
if not defined JAR_NAME (
    if exist "!SCRIPT_DIR!agent-manager-java8.jar" (
        set JAR_NAME=agent-manager-java8.jar
    ) else if exist "!SCRIPT_DIR!agent-manager-java21.jar" (
        set JAR_NAME=agent-manager-java21.jar
    ) else (
        set JAR_NAME=agent-manager.jar
    )
)

set "JAR_PATH=!SCRIPT_DIR!!JAR_NAME!"

REM Check if JAR exists
if not exist "!JAR_PATH!" (
    echo Error: !JAR_NAME! not found at !JAR_PATH!
    echo Please run install.bat first or ensure the JAR is in the same directory as this script.
    exit /b 1
)

REM Execute the JAR with all passed arguments
java -jar "!JAR_PATH!" %*

endlocal
