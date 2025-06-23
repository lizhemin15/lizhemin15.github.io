#!/bin/bash

# 自动下载JavaScript库文件脚本
# 用于解决国内CDN访问问题

echo "开始下载JavaScript库文件..."

# 创建libs目录
mkdir -p libs
cd libs

# 定义下载函数
download_file() {
    local url=$1
    local filename=$2
    echo "正在下载 $filename..."
    
    # 尝试使用curl下载
    if command -v curl &> /dev/null; then
        curl -L -o "$filename" "$url"
    # 如果没有curl，尝试使用wget
    elif command -v wget &> /dev/null; then
        wget -O "$filename" "$url"
    else
        echo "错误: 未找到curl或wget命令"
        exit 1
    fi
    
    if [ $? -eq 0 ]; then
        echo "✓ $filename 下载成功"
    else
        echo "✗ $filename 下载失败"
    fi
}

# 下载所有必需文件
echo "=== 下载JavaScript库 ==="
download_file "https://cdn.bootcdn.net/ajax/libs/js-yaml/4.1.0/js-yaml.min.js" "js-yaml.min.js"
download_file "https://cdn.bootcdn.net/ajax/libs/marked/4.3.0/marked.min.js" "marked.min.js"
download_file "https://cdn.bootcdn.net/ajax/libs/highlight.js/11.8.0/highlight.min.js" "highlight.min.js"
download_file "https://cdn.bootcdn.net/ajax/libs/KaTeX/0.16.9/katex.min.js" "katex.min.js"

echo "=== 下载CSS文件 ==="
download_file "https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css" "bootstrap.min.css"
download_file "https://cdn.bootcdn.net/ajax/libs/font-awesome/6.4.0/css/all.min.css" "all.min.css"
download_file "https://cdn.bootcdn.net/ajax/libs/highlight.js/11.8.0/styles/github.min.css" "github.min.css"
download_file "https://cdn.bootcdn.net/ajax/libs/KaTeX/0.16.9/katex.min.css" "katex.min.css"

echo "=== 下载Bootstrap JavaScript ==="
download_file "https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/5.3.0/js/bootstrap.bundle.min.js" "bootstrap.bundle.min.js"

# 检查下载结果
echo ""
echo "=== 下载结果检查 ==="
files=(
    "js-yaml.min.js"
    "marked.min.js"
    "highlight.min.js"
    "katex.min.js"
    "bootstrap.min.css"
    "all.min.css"
    "github.min.css"
    "katex.min.css"
    "bootstrap.bundle.min.js"
)

success_count=0
total_count=${#files[@]}

for file in "${files[@]}"; do
    if [ -f "$file" ] && [ -s "$file" ]; then
        echo "✓ $file 存在且非空"
        ((success_count++))
    else
        echo "✗ $file 缺失或为空"
    fi
done

echo ""
echo "下载完成: $success_count/$total_count 个文件成功下载"

if [ $success_count -eq $total_count ]; then
    echo "🎉 所有文件下载成功！"
    echo ""
    echo "现在可以修改 index.html 使用本地文件："
    echo "将CDN链接替换为本地路径，例如："
    echo "  src=\"https://cdn.bootcdn.net/ajax/libs/js-yaml/4.1.0/js-yaml.min.js\""
    echo "  替换为："
    echo "  src=\"./libs/js-yaml.min.js\""
else
    echo "⚠️  部分文件下载失败，请检查网络连接后重试"
fi

cd ..
echo ""
echo "文件保存在 libs/ 目录中" 