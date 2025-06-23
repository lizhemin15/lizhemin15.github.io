# 本地库文件

这个文件夹用于存放本地版本的JavaScript库，以防CDN无法访问时使用。

## 下载说明

如果遇到CDN访问问题，可以下载以下文件到 `libs/` 文件夹：

### 必需文件

1. **js-yaml.min.js** - YAML解析库
   - 下载地址: https://cdn.bootcdn.net/ajax/libs/js-yaml/4.1.0/js-yaml.min.js
   - 备用地址: https://unpkg.com/js-yaml@4.1.0/dist/js-yaml.min.js

2. **marked.min.js** - Markdown解析库
   - 下载地址: https://cdn.bootcdn.net/ajax/libs/marked/4.3.0/marked.min.js
   - 备用地址: https://unpkg.com/marked@4.3.0/marked.min.js

3. **highlight.min.js** - 代码高亮库
   - 下载地址: https://cdn.bootcdn.net/ajax/libs/highlight.js/11.8.0/highlight.min.js
   - 备用地址: https://unpkg.com/highlight.js@11.8.0/lib/highlight.min.js

4. **katex.min.js** - 数学公式渲染库
   - 下载地址: https://cdn.bootcdn.net/ajax/libs/KaTeX/0.16.9/katex.min.js
   - 备用地址: https://unpkg.com/katex@0.16.9/dist/katex.min.js

5. **bootstrap.min.css** - Bootstrap样式
   - 下载地址: https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css

6. **bootstrap.bundle.min.js** - Bootstrap脚本
   - 下载地址: https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/5.3.0/js/bootstrap.bundle.min.js

7. **all.min.css** - Font Awesome图标
   - 下载地址: https://cdn.bootcdn.net/ajax/libs/font-awesome/6.4.0/css/all.min.css

## 使用方法

下载文件后，在 `index.html` 中将CDN链接替换为本地路径：

```html
<!-- 替换前 -->
<script src="https://cdn.bootcdn.net/ajax/libs/js-yaml/4.1.0/js-yaml.min.js"></script>

<!-- 替换后 -->
<script src="./libs/js-yaml.min.js"></script>
```

## 自动化下载脚本

可以使用以下脚本自动下载所有必需文件：

```bash
#!/bin/bash
mkdir -p libs
cd libs

# 下载所有必需文件
wget https://cdn.bootcdn.net/ajax/libs/js-yaml/4.1.0/js-yaml.min.js
wget https://cdn.bootcdn.net/ajax/libs/marked/4.3.0/marked.min.js
wget https://cdn.bootcdn.net/ajax/libs/highlight.js/11.8.0/highlight.min.js
wget https://cdn.bootcdn.net/ajax/libs/KaTeX/0.16.9/katex.min.js
wget https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css
wget https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/5.3.0/js/bootstrap.bundle.min.js
wget https://cdn.bootcdn.net/ajax/libs/font-awesome/6.4.0/css/all.min.css

echo "所有文件下载完成！"
```

## 注意事项

1. 确保下载的文件版本与CDN版本一致
2. 定期更新本地文件以获取安全补丁
3. 本地文件会增加网站加载时间，但提供更好的稳定性 