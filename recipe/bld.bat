set POST=
set PYPI_VER=%PY_VER:~0,1%%PY_VER:~2,1%

 set MPOST= ELSE set MPOST=m

FOR %%D IN (core,io,filtering,numerics,registration) DO (
  :: Python 3.8 -- this could be improved
  IF %PY_VER:~2,1% GEQ 8 %PYTHON% -m pip install --no-deps https://pypi.org/packages/cp%PYPI_VER%/i/itk-%%D/itk_%%D-%PKG_VERSION%%POST%-cp%PYPI_VER%-cp%PYPI_VER%-win_amd64.whl
  IF %PY_VER:~2,1% LSS 8 %PYTHON% -m pip install --no-deps https://pypi.org/packages/cp%PYPI_VER%/i/itk-%%D/itk_%%D-%PKG_VERSION%%POST%-cp%PYPI_VER%-cp%PYPI_VER%m-win_amd64.whl
)
if errorlevel 1 exit 1
