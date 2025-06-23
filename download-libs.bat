@echo off
chcp 65001 >nul
echo 开始下载JavaScript库文件...

REM 创建libs目录
if not exist "libs" mkdir libs
cd libs

echo === 下载JavaScript库 ===
echo 正在下载 js-yaml.min.js...
powershell -Command "Invoke-WebRequest -Uri 'https://cdn.bootcdn.net/ajax/libs/js-yaml/4.1.0/js-yaml.min.js' -OutFile 'js-yaml.min.js'"
if exist "js-yaml.min.js" echo ✓ js-yaml.min.js 下载成功

echo 正在下载 marked.min.js...
powershell -Command "Invoke-WebRequest -Uri 'https://cdn.bootcdn.net/ajax/libs/marked/4.3.0/marked.min.js' -OutFile 'marked.min.js'"
if exist "marked.min.js" echo ✓ marked.min.js 下载成功

echo 正在下载 highlight.min.js...
powershell -Command "Invoke-WebRequest -Uri 'https://cdn.bootcdn.net/ajax/libs/highlight.js/11.8.0/highlight.min.js' -OutFile 'highlight.min.js'"
if exist "highlight.min.js" echo ✓ highlight.min.js 下载成功

echo 正在下载 katex.min.js...
powershell -Command "Invoke-WebRequest -Uri 'https://cdn.bootcdn.net/ajax/libs/KaTeX/0.16.9/katex.min.js' -OutFile 'katex.min.js'"
if exist "katex.min.js" echo ✓ katex.min.js 下载成功

echo === 下载CSS文件 ===
echo 正在下载 bootstrap.min.css...
powershell -Command "Invoke-WebRequest -Uri 'https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css' -OutFile 'bootstrap.min.css'"
if exist "bootstrap.min.css" echo ✓ bootstrap.min.css 下载成功

echo 正在下载 all.min.css...
powershell -Command "Invoke-WebRequest -Uri 'https://cdn.bootcdn.net/ajax/libs/font-awesome/6.4.0/css/all.min.css' -OutFile 'all.min.css'"
if exist "all.min.css" echo ✓ all.min.css 下载成功

echo 正在下载 github.min.css...
powershell -Command "Invoke-WebRequest -Uri 'https://cdn.bootcdn.net/ajax/libs/highlight.js/11.8.0/styles/github.min.css' -OutFile 'github.min.css'"
if exist "github.min.css" echo ✓ github.min.css 下载成功

echo 正在下载 katex.min.css...
powershell -Command "Invoke-WebRequest -Uri 'https://cdn.bootcdn.net/ajax/libs/KaTeX/0.16.9/katex.min.css' -OutFile 'katex.min.css'"
if exist "katex.min.css" echo ✓ katex.min.css 下载成功

echo === 下载Bootstrap JavaScript ===
echo 正在下载 bootstrap.bundle.min.js...
powershell -Command "Invoke-WebRequest -Uri 'https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/5.3.0/js/bootstrap.bundle.min.js' -OutFile 'bootstrap.bundle.min.js'"
if exist "bootstrap.bundle.min.js" echo ✓ bootstrap.bundle.min.js 下载成功

echo.
echo === 下载结果检查 ===
set success_count=0
set total_count=9

if exist "js-yaml.min.js" (
    echo ✓ js-yaml.min.js 存在
    set /a success_count+=1
) else (
    echo ✗ js-yaml.min.js 缺失
)

if exist "marked.min.js" (
    echo ✓ marked.min.js 存在
    set /a success_count+=1
) else (
    echo ✗ marked.min.js 缺失
)

if exist "highlight.min.js" (
    echo ✓ highlight.min.js 存在
    set /a success_count+=1
) else (
    echo ✗ highlight.min.js 缺失
)

if exist "katex.min.js" (
    echo ✓ katex.min.js 存在
    set /a success_count+=1
) else (
    echo ✗ katex.min.js 缺失
)

if exist "bootstrap.min.css" (
    echo ✓ bootstrap.min.css 存在
    set /a success_count+=1
) else (
    echo ✗ bootstrap.min.css 缺失
)

if exist "all.min.css" (
    echo ✓ all.min.css 存在
    set /a success_count+=1
) else (
    echo ✗ all.min.css 缺失
)

if exist "github.min.css" (
    echo ✓ github.min.css 存在
    set /a success_count+=1
) else (
    echo ✗ github.min.css 缺失
)

if exist "katex.min.css" (
    echo ✓ katex.min.css 存在
    set /a success_count+=1
) else (
    echo ✗ katex.min.css 缺失
)

if exist "bootstrap.bundle.min.js" (
    echo ✓ bootstrap.bundle.min.js 存在
    set /a success_count+=1
) else (
    echo ✗ bootstrap.bundle.min.js 缺失
)

echo.
echo 下载完成: %success_count%/%total_count% 个文件成功下载

if %success_count%==%total_count% (
    echo 🎉 所有文件下载成功！
    echo.
    echo 现在可以修改 index.html 使用本地文件：
    echo 将CDN链接替换为本地路径，例如：
    echo   src="https://cdn.bootcdn.net/ajax/libs/js-yaml/4.1.0/js-yaml.min.js"
    echo   替换为：
    echo   src="./libs/js-yaml.min.js"
) else (
    echo ⚠️  部分文件下载失败，请检查网络连接后重试
)

cd ..
echo.
echo 文件保存在 libs\ 目录中
pause 