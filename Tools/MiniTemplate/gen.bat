set WORKSPACE=..\..\Assets\Config
set LUBAN_DLL=Luban\Luban.dll
set CONF_ROOT=.

dotnet %LUBAN_DLL% ^
    -t all ^
    -c cs-simple-json ^
    -d json ^
    --conf %CONF_ROOT%\luban.conf ^
    -x outputDataDir=%WORKSPACE%\output\data ^
    -x outputCodeDir=%WORKSPACE%\output\code

pause