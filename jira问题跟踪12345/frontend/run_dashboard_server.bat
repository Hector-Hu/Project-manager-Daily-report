@echo off
setlocal
rem 通用启动脚本：在本目录下用 PATH 中的 python 启动驾驶舱服务
cd /d "%~dp0"
python -m uvicorn src.api:app --host 0.0.0.0 --port 8000
