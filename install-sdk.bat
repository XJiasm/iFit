@echo off
set ANDROID_HOME=%USERPROFILE%\android_sdk
set SDKMANAGER=%ANDROID_HOME%\cmdline-tools\latest\bin\sdkmanager.bat

echo Accepting licenses...
for /L %%i in (1,1,10) do echo y

echo Installing SDK components...
%SDKMANAGER% "platforms;android-33" "build-tools;33.0.2" "platform-tools"

echo Done!
