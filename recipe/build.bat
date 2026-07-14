set BUILD_DIR=%SRC_DIR%\bld
mkdir %BUILD_DIR%
cd %BUILD_DIR%

SET CXX_FLAGS="%CXX_FLAGS% /MP"

REM Configure Step
cmake -G "Ninja" ^
    -D BUILD_SHARED_LIBS:BOOL=ON ^
    -D BUILD_TESTING:BOOL=OFF ^
    -D BUILD_EXAMPLES:BOOL=OFF ^
    -D ITK_USE_SYSTEM_EXPAT:BOOL=OFF ^
    -D ITK_USE_SYSTEM_HDF5:BOOL=ON ^
    -D ITK_USE_SYSTEM_JPEG:BOOL=ON ^
    -D ITK_USE_SYSTEM_PNG:BOOL=OFF ^
    -D ITK_USE_SYSTEM_TIFF:BOOL=ON ^
    -D ITK_USE_SYSTEM_EIGEN:BOOL=ON ^
    -D ITK_USE_SYSTEM_ZLIB:BOOL=OFF ^
    -D ITK_USE_KWSTYLE:BOOL=OFF ^
    -D ITK_BUILD_DEFAULT_MODULES:BOOL=ON ^
    -D Module_ITKReview:BOOL=ON ^
    -D Module_SimpleITKFilters=ON ^
    -D Module_ITKTBB:BOOL=ON ^
    -D Module_MGHIO:BOOL=ON ^
    -D Module_ITKIOTransformMINC:BOOL=ON ^
    -D Module_GenericLabelInterpolator:BOOL=ON ^
    -D Module_AdaptiveDenoising:BOOL=ON ^
    -D "ITK_DEFAULT_THREADER:STRING=Pool" ^
    -D "CMAKE_SYSTEM_PREFIX_PATH:PATH=%LIBRARY_PREFIX%" ^
    -D "CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%" ^
    -D CMAKE_BUILD_TYPE:STRING=RELEASE ^
    -D ITK_WRAP_PYTHON:BOOL=ON ^
    -D ITK_USE_SYSTEM_CASTXML:BOOL=ON ^
    -D WRAP_ITK_INSTALL_COMPONENT_IDENTIFIER:STRING=PythonWrapping ^
    -D Python3_EXECUTABLE:FILEPATH="%PYTHON%" ^
    -D ITK_WRAP_unsigned_short:BOOL=ON ^
    -D ITK_WRAP_double:BOOL=ON ^
    -D ITK_WRAP_complex_double:BOOL=ON ^
    -D ITK_WRAP_IMAGE_DIMS:STRING="2;3;4" ^
    -D PY_SITE_PACKAGES_PATH:PATH="Lib/site-packages" ^
    "%SRC_DIR%"

if errorlevel 1 exit 1

REM Build step
cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1

REM --- Install phase (previously the itk_install.bat output script) ---------

REM Install the C++ runtime libraries AND the Python wrapping payload into a
REM single self-contained `itk` package.
for %%c in (Runtime RuntimeLibraries Libraries PythonWrappingRuntimeLibraries Unspecified libraries) do (
    cmake -DCOMPONENT=%%c -P %BUILD_DIR%\cmake_install.cmake
)

REM CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% lands the Python wrapping under
REM %LIBRARY_PREFIX%\Lib\site-packages, which is not on the interpreter's
REM sys.path. Relocate it to the real site-packages (%PREFIX%\Lib\site-packages)
REM so `import itk` works. conda-build did this implicitly; rattler-build does
REM not. robocopy returns exit codes < 8 on success.
if exist "%LIBRARY_PREFIX%\Lib\site-packages" (
    if not exist "%PREFIX%\Lib\site-packages" mkdir "%PREFIX%\Lib\site-packages"
    robocopy "%LIBRARY_PREFIX%\Lib\site-packages" "%PREFIX%\Lib\site-packages" /E /MOVE /NFL /NDL /NJH /NJS /NC /NS
    if errorlevel 8 exit 1
    (call )
)

REM Verify the Python module landed on sys.path.
if not exist "%PREFIX%\Lib\site-packages\itk" (
    echo ERROR: no itk\ Python module under Lib\site-packages
    exit 1
)

REM Headers and CMake config are not shipped in the runtime `itk` package.
if exist "%LIBRARY_PREFIX%\include"   rmdir /S /Q "%LIBRARY_PREFIX%\include"
if exist "%LIBRARY_PREFIX%\lib\cmake" rmdir /S /Q "%LIBRARY_PREFIX%\lib\cmake"
