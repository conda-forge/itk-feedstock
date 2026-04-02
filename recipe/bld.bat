@echo off
setlocal

REM This script mirrors the Unix logic on Windows

REM Python 3.11 ABI is "cp311"
set PYPI_VER=311

REM ITK version from environment variable set by conda-build
set ITK_VERSION=%PKG_VERSION%

REM List of ITK modules to install
set "ITK_MODULES=core io filtering numerics registration segmentation"

REM Determine architecture for wheels
if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
    set "PLATFORM_GREP=win_arm64.whl"
) else (
    set "PLATFORM_GREP=win_amd64.whl"
)

REM Loop over each ITK module
for %%D in (%ITK_MODULES%) do (
    echo Processing itk-%%D...

    REM Retrieve a list of URLs for the specified ITK version via PyPI
    curl -s "https://pypi.org/pypi/itk-%%D/json" ^
        | jq.exe -r ".releases[\"%ITK_VERSION%\"][] | .url" > candidate_urls.txt

    REM Find the first URL matching "cp%PYPI_VER%" and the platform
    set "MATCHED_URL="
    for /f "usebackq delims=" %%U in (`type candidate_urls.txt`) do (
        echo %%U | findstr /i "cp%PYPI_VER%" >nul && (
            echo %%U | findstr /i "%PLATFORM_GREP%" >nul
        ) && (
            if not defined MATCHED_URL (
                set "MATCHED_URL=%%U"
            )
        )
    )
    del candidate_urls.txt

    if not defined MATCHED_URL (
        echo ERROR: No matching wheel found for itk-%%D, Python cp%PYPI_VER%, platform %PLATFORM_GREP%.
        exit /b 1
    )

    echo Matched URL for itk-%%D: %MATCHED_URL%

    REM Install the matched wheel file without dependencies
    %PYTHON% -m pip install --no-deps "%MATCHED_URL%"
)

echo All specified ITK modules have been installed successfully.

endlocal
exit /b 0