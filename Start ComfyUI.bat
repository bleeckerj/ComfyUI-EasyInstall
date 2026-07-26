@Echo off&&cd /D %~dp0
Title ComfyUI-Easy-Install
.\python_embeded\python.exe -I -W ignore::FutureWarning ComfyUI\main.py --windows-standalone-build --date-based-output --listen 0.0.0.0

echo.
echo If you see this and ComfyUI did not start, [92mtry updating your Nvidia drivers.[0m
echo If you get a c10.dll error, [92minstall VC Redist: https://aka.ms/vc14/vc_redist.x64.exe[0m
echo.
echo Press any key to exit%reset%&Pause>nul

