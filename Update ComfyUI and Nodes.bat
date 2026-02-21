@Echo off&&cd /D %~dp0
Title ComfyUI-Update All and RUN by ivo
:: Pixaroma Community Edition ::
:: Updates ComfyUI and its nodes and starts it

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
echo.

:: Erasing ~* folders ::
if exist ".\python_embeded\Lib\site-packages\~*" (powershell -ExecutionPolicy Bypass -Command "Get-ChildItem '.\python_embeded\Lib\site-packages\' -Directory | Where-Object {$_.Name -like '~*'} | Remove-Item -Recurse -Force")

Echo [92m::::::::::::::: Updating All Nodes :::::::::::::::[0m
Echo.
.\python_embeded\python.exe -I ComfyUI\custom_nodes\ComfyUI-Manager\cm-cli.py update all
Echo.

:: Restoring Numpy 1.26.4 ::
echo [92m::::::::::::::: Restoring[93m Numpy 1.26.4 [92m:::::::::::::::[0m
echo.
.\python_embeded\python.exe -I -m pip install --force-reinstall numpy==1.26.4 --no-deps --no-cache-dir --no-warn-script-location --timeout=1000 --retries 200
echo.

Echo [92m::::::::::::::: Done. Starting ComfyUI :::::::::::::::[0m
Echo.

call "Start ComfyUI.bat"