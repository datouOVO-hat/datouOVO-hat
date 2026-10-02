@echo off
chcp 65001 > nul
echo ========================================================
echo   exShop Luxury Edition - WAR Build & Package Utility
echo ========================================================
echo.

where mvn >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [INFO] Maven detected on PATH. Building WAR...
    mvn clean package
    goto done
)

echo [INFO] Maven not found in PATH.
echo [INFO] Attempting to download portable Maven for build...

set MAVEN_DIR=%USERPROFILE%\.m2\portable-maven
if not exist "%MAVEN_DIR%" (
    mkdir "%MAVEN_DIR%"
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip' -OutFile '%TEMP%\mvn.zip'; Expand-Archive -Path '%TEMP%\mvn.zip' -DestinationPath '%MAVEN_DIR%' -Force; Remove-Item '%TEMP%\mvn.zip'"
)

for /d %%D in ("%MAVEN_DIR%\apache-maven-*") do (
    set MAVEN_BIN=%%D\bin\mvn.cmd
)

if exist "%MAVEN_BIN%" (
    echo [INFO] Running Maven build...
    call "%MAVEN_BIN%" clean package
) else (
    echo [ERROR] Could not setup Maven. Please install Maven or import this project into Eclipse as an Existing Maven Project.
)

:done
if exist "target\exShop.war" (
    echo.
    echo ========================================================
    echo   BUILD SUCCESS! 
    echo   WAR File: target\exShop.war
    echo ========================================================
)
pause
