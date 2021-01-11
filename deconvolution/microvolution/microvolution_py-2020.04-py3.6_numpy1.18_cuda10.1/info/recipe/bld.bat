"%PYTHON%" setup.py install
COPY lib\Microvolution.dll %SP_DIR%\..\..\Library\bin;
if errorlevel 1 exit 1