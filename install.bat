@echo off
REM Agent Manager CLI Installation Script for Windows
REM This script installs agent-manager to a permanent location and adds it to PATH
REM Detects Java version and installs the appropriate module (Java 8 or Java 21)

setlocal enabledelayedexpansion

echo ========================================
echo Agent Manager CLI Installation
echo ========================================
echo.

REM Check if Java is available
where java >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Java is not installed or not in PATH.
    echo Please install Java 8 or later and ensure it's in your system PATH.
    echo.
    pause
    exit /b 1
)

REM Check Java version
for /f "tokens=3" %%g in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    set JAVA_VERSION_RAW=%%g
    set JAVA_VERSION_RAW=!JAVA_VERSION_RAW:"=!
    goto :parse_version
)
:parse_version

REM Extract major version number
for /f "tokens=1 delims=." %%a in ("!JAVA_VERSION_RAW!") do set JAVA_MAJOR=%%a
for /f "tokens=2 delims=." %%b in ("!JAVA_VERSION_RAW!") do set JAVA_MINOR=%%b

REM Determine which module to use
set MODULE_NAME=
set JAR_NAME=

REM Check if Java 8 (1.8.x) or Java 9+ (9, 10, 11, etc.) or Java 21+
if "!JAVA_MAJOR!"=="1" (
    REM Java 8 or earlier
    if "!JAVA_MINOR!"=="8" (
        set MODULE_NAME=agent-manager-java8
        set JAR_NAME=agent-manager-java8.jar
        set JAVA_REQUIRED=Java 8
    ) else (
        echo [ERROR] Java version !JAVA_VERSION_RAW! is not supported.
        echo Please install Java 8 or Java 21 or later.
        echo.
        pause
        exit /b 1
    )
) else (
    REM Java 9 or later
    set /a JAVA_MAJOR_NUM=!JAVA_MAJOR!
    if !JAVA_MAJOR_NUM! LSS 8 (
        echo [ERROR] Java version !JAVA_VERSION_RAW! is not supported.
        echo Please install Java 8 or Java 21 or later.
        echo.
        pause
        exit /b 1
    ) else if !JAVA_MAJOR_NUM! GEQ 21 (
        set MODULE_NAME=agent-manager-java21
        set JAR_NAME=agent-manager-java21.jar
        set JAVA_REQUIRED=Java 21
    ) else (
        REM Java 9-20, use Java 8 version
        set MODULE_NAME=agent-manager-java8
        set JAR_NAME=agent-manager-java8.jar
        set JAVA_REQUIRED=Java 8
    )
)

echo [INFO] Found Java version: !JAVA_VERSION_RAW!
echo [INFO] Using module: !MODULE_NAME!
echo [INFO] JAR file: !JAR_NAME!
echo.

REM Set installation directory (user's home directory)
set "INSTALL_DIR=%USERPROFILE%\.agent-manager"
set "BIN_DIR=%USERPROFILE%\bin"

REM Check if target JAR exists
set "JAR_PATH=!MODULE_NAME!\target\!JAR_NAME!"
if not exist "!JAR_PATH!" (
    echo [INFO] JAR not found. Building project...
    echo.
    call mvn clean package -pl !MODULE_NAME! -am
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Build failed. Please check the error messages above.
        echo.
        pause
        exit /b 1
    )
    echo.
    echo [OK] Build completed successfully
    echo.
)

if not exist "!JAR_PATH!" (
    echo [ERROR] !JAR_NAME! not found at !JAR_PATH!
    echo Please build the project first by running: mvn clean package
    echo.
    pause
    exit /b 1
)

echo [INFO] Installation directory: %INSTALL_DIR%
echo [INFO] Binary directory: %BIN_DIR%
echo.

REM Create directories
echo [INFO] Creating directories...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"
echo [OK] Directories created
echo.

REM Copy JAR file
echo [INFO] Copying !JAR_NAME!...
copy /Y "!JAR_PATH!" "%INSTALL_DIR%\!JAR_NAME!" >nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to copy JAR file.
    pause
    exit /b 1
)
echo [OK] JAR file copied
echo.

REM Create wrapper script
echo [INFO] Creating wrapper script...
(
echo @echo off
echo REM Agent Manager CLI Wrapper Script
echo setlocal
echo set "JAR_PATH=%INSTALL_DIR%\!JAR_NAME!"
echo if not exist "%%JAR_PATH%%" ^(
echo     echo Error: !JAR_NAME! not found at %%JAR_PATH%%
echo     exit /b 1
echo ^)
echo where java ^>nul 2^>^&1
echo if %%ERRORLEVEL%% NEQ 0 ^(
echo     echo Error: Java is not installed or not in PATH.
echo     exit /b 1
echo ^)
echo java -jar "%%JAR_PATH%%" %%*
echo endlocal
) > "%BIN_DIR%\agent-manager.bat"
echo [OK] Wrapper script created
echo.

REM Check if BIN_DIR is in PATH
echo [INFO] Checking PATH configuration...
echo %PATH% | findstr /C:"%BIN_DIR%" >nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] %BIN_DIR% is not in your PATH.
    echo.
    echo To use 'agent-manager' command from anywhere, you need to add %BIN_DIR% to your PATH.
    echo.
    set /p ADD_TO_PATH="Do you want to add %BIN_DIR% to your user PATH? (Y/N): "
    if /i "!ADD_TO_PATH!"=="Y" (
        echo.
        echo [INFO] Adding %BIN_DIR% to user PATH...
        for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "USER_PATH=%%B"
        if defined USER_PATH (
            setx PATH "!USER_PATH!;%BIN_DIR%" >nul
        ) else (
            setx PATH "%BIN_DIR%" >nul
        )
        echo [OK] PATH updated. Please restart your terminal for changes to take effect.
        echo.
    ) else (
        echo.
        echo [INFO] You can manually add %BIN_DIR% to your PATH:
        echo   1. Open System Properties ^(Win + Pause^)
        echo   2. Click "Environment Variables"
        echo   3. Edit "Path" under "User variables"
        echo   4. Add: %BIN_DIR%
        echo.
    )
) else (
    echo [OK] %BIN_DIR% is already in your PATH.
    echo.
)

echo ========================================
echo Installation completed successfully!
echo ========================================
echo.
echo You can now use 'agent-manager' command from anywhere.
echo Installed version: !MODULE_NAME! ^(!JAVA_REQUIRED!^)
echo.
echo If you just added the PATH, please restart your terminal.
echo Otherwise, you can test it now:
echo   agent-manager --version
echo.
pause
