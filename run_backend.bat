@echo off
cd /d %~dp0
echo Starting PHP Backend Server on port 8000...
echo Access API at http://127.0.0.1:8000/api
"d:\xamp\php\php.exe" -S 127.0.0.1:8000 -t backend backend/router.php
pause
