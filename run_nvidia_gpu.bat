@Echo off&&cd /D %~dp0
Title ComfyUI-Easy-Install
.\python_embeded\python.exe -I ComfyUI\main.py --windows-standalone-build
pause
