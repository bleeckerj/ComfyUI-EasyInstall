@echo off&&cd /D %~dp0
Title ComfyUI-Update Comfy and RUN by ivo
:: Pixaroma Community Edition ::
:: Updates only ComfyUI and starts it

echo [92m::::::::::::::: Updating ComfyUI :::::::::::::::[0m
echo.
cd .\ComfyUI&&git.exe checkout master -q&&cd ..\

:: Install working version of av!!! ::
.\python_embeded\python.exe -I -m uv pip install av==16.0.1 %UVargs%

cd .\update&&call .\update_comfyui.bat nopause&&cd ..\
echo.
:: Re-apply custom patches after update ::
echo [93m::::::::::::::: Applying server-info patch :::::::::::::::[0m
echo.
cd .\ComfyUI
git apply ..\server-info.patch --whitespace=fix 2>nul && (
    echo [92mPatch applied successfully.[0m
) || (
    echo [93mPatch already applied or not needed.[0m
)
cd ..\
echo.echo [92m:::::::::::: Done. Starting ComfyUI ::::::::::::[0m
echo.

call "Start ComfyUI.bat"
