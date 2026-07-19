@echo off
cd /d "%~dp0"
node watcher.js >> watcher.log 2>&1
