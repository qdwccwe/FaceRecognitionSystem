@REM ----------------------------------------------------------------------------
@REM Maven Wrapper startup script for Windows
@REM ----------------------------------------------------------------------------

@echo off
setlocal

set "MAVEN_PROJECTBASEDIR=%~dp0"
set "MVNW_VERBOSE=false"

set "MAVEN_USER_HOME=%USERPROFILE%\.m2"
set "MAVEN_CONFIG=%USERPROFILE%\.m2\wrapper"

if not defined M2_HOME (
    if exist "%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.6-bin" (
        set "M2_HOME=%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.6-bin\apache-maven-3.9.6"
    )
)

if not defined M2_HOME (
    echo Downloading Maven 3.9.6...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.6/apache-maven-3.9.6-bin.zip' -OutFile '%TEMP%\maven-3.9.6.zip'}" 2>nul
    if %ERRORLEVEL% NEQ 0 (
        curl -L -o "%TEMP%\maven-3.9.6.zip" "https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.6/apache-maven-3.9.6-bin.zip" 2>nul
    )
    if exist "%TEMP%\maven-3.9.6.zip" (
        mkdir "%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.6-bin" 2>nul
        powershell -Command "Expand-Archive -Path '%TEMP%\maven-3.9.6.zip' -DestinationPath '%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.6-bin'" 2>nul
        del "%TEMP%\maven-3.9.6.zip" 2>nul
    )
    set "M2_HOME=%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.6-bin\apache-maven-3.9.6"
)

if not exist "%M2_HOME%\bin\mvn.cmd" (
    echo Failed to download Maven. Trying to use system Maven...
    where mvn.cmd >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        for /f "delims=" %%i in ('where mvn.cmd') do set "MVN_CMD=%%i"
        goto :run
    )
    echo ERROR: Maven not found. Please install Maven or check your internet connection.
    exit /b 1
)

set "MVN_CMD=%M2_HOME%\bin\mvn.cmd"

:run
:: Set JAVA_HOME if not set
if not defined JAVA_HOME (
    if exist "C:\Program Files\Java\jdk-1.8" (
        set "JAVA_HOME=C:\Program Files\Java\jdk-1.8"
    )
)

if defined JAVA_HOME (
    echo Using JAVA_HOME: %JAVA_HOME%
)

:: Run Maven
"%MVN_CMD%" %* -Dmaven.multiModuleProjectDirectory="%MAVEN_PROJECTBASEDIR%"
exit /b %ERRORLEVEL%
