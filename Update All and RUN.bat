@Echo off&&cd /D %~dp0
Title ComfyUI-Update All and RUN by ivo
:: Pixaroma Community Edition ::
:: Updates ComfyUI and its nodes and starts it

Echo [92m::::::::::::::: Updating ComfyUI :::::::::::::::[0m
Echo.
cd .\update&&call .\update_comfyui.bat nopause&&cd ..\
Echo.
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
Echo [92m::::::::::::::: Updating All Nodes :::::::::::::::[0m
Echo.
.\python_embeded\python.exe -I ComfyUI\custom_nodes\ComfyUI-Manager\cm-cli.py update all
Echo.
Echo [92m::::::::::::::: Done. Starting ComfyUI :::::::::::::::[0m
Echo.

call run_nvidia_gpu.bat