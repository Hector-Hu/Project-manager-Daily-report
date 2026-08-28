@echo off
REM ============================================
REM  启动本地 Outlook MCP server（HTTP 模式，端口 8765）
REM  前端/后端发信将走 /api/outlook/send-email -> 本服务 -> 本机 Outlook
REM  以 chongren1.zhang@tcl.com 名义发送
REM ============================================
set VENV=C:\Users\chongren1.zhang\.workbuddy\outlook_mcp_venv\Scripts\python.exe
set SERVER=C:\Users\chongren1.zhang\Desktop\ai_report_intranet\tools\outlook_mcp_server.py

"%VENV%" "%SERVER%" --port 8765
