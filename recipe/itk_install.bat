set BUILD_DIR=%SRC_DIR%\bld

REM Install the C++ runtime libraries AND the Python wrapping payload into a
REM single self-contained `itk` package.
for %%c in (Runtime RuntimeLibraries Libraries PythonWrappingRuntimeLibraries Unspecified libraries) do (
    cmake -DCOMPONENT=%%c -P %BUILD_DIR%\cmake_install.cmake
)

REM Verify the Python module landed.
if not exist "%LIBRARY_PREFIX%\Lib\site-packages\itk" (
    echo ERROR: no itk\ Python module under Lib\site-packages
    exit 1
)

REM Headers and CMake config are not shipped in the runtime `itk` package.
if exist "%LIBRARY_PREFIX%\include"   rmdir /S /Q "%LIBRARY_PREFIX%\include"
if exist "%LIBRARY_PREFIX%\lib\cmake" rmdir /S /Q "%LIBRARY_PREFIX%\lib\cmake"
