@echo off 
setlocal enabledelayedexpansion
set /A b=0
for /l %%i in (1,5,277) do (
  copy "D:\tmp\youli\progress-%%i.png" progress-!b!.png
  set /A b+=1
)
