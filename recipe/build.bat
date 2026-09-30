@echo on

:: Create conda_build.sh wrapper
:: With pixi, environment is already activated - no need to source conda.sh
:: With Miniforge/conda, we need to source conda.sh and activate
echo # Conda/pixi activation wrapper                   > conda_build.sh
echo if [ -f "D:/Miniforge/etc/profile.d/conda.sh" ]; then  >> conda_build.sh
echo   source D:/Miniforge/etc/profile.d/conda.sh     >> conda_build.sh
echo   conda activate "${PREFIX}"                     >> conda_build.sh
echo   conda activate --stack "${BUILD_PREFIX}"       >> conda_build.sh
echo fi                                               >> conda_build.sh
echo CONDA_PREFIX=${CONDA_PREFIX//\\//}               >> conda_build.sh
type "%RECIPE_DIR%\build.sh"                          >> conda_build.sh

FOR /F "delims=" %%i in ('cygpath.exe -u "%PREFIX%"') DO set "PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%BUILD_PREFIX%"') DO set "BUILD_PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%CONDA_PREFIX%"') DO set "CONDA_PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%SRC_DIR%"') DO set "SRC_DIR=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%PYTHON%"') DO set "PYTHON=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%SP_DIR%"') DO set "SP_DIR=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%PERL%"') DO set "PERL=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%LUA%"') DO set "LUA=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%LUA_INCLUDE_DIR%"') DO set "LUA_INCLUDE_DIR=%%i"
set MSYSTEM=UCRT64
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
bash -lc "./conda_build.sh"
if errorlevel 1 exit 1

:: Generate MSVC-compatible import library
pushd src
FOR /F %%i in ("%LIBRARY_PREFIX%/bin/libhamlib-*.dll") DO lib /def:libhamlib.def /name:%%~ni.dll /out:hamlib.lib /machine:x64
copy "hamlib.lib" "%LIBRARY_PREFIX%/lib/hamlib.lib"
popd
if errorlevel 1 exit 1

pushd c++
FOR /F %%i in ("%LIBRARY_PREFIX%/bin/libhamlib++-*.dll") DO lib /def:libhamlib++.def /name:%%~ni.dll /out:hamlib++.lib /machine:x64
copy "hamlib++.lib" "%LIBRARY_PREFIX%/lib/hamlib++.lib"
popd
if errorlevel 1 exit 1
