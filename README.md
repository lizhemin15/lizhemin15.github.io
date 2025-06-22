# 学术主页配置指南

这是一个通过 YAML 配置文件动态生成的学术个人主页。您可以通过修改 `config.yml` 文件来自定义网站的所有内容，无需修改 HTML 代码。

## 🚀 快速开始

1. **克隆或下载项目文件**
2. **修改 `config.yml` 配置文件**
3. **添加或修改 `md/` 文件夹中的 Markdown 内容**
4. **在 Web 服务器中运行**（由于 CORS 限制，需要 Web 服务器环境）

## 📁 文件结构

```
.
├── index.html          # 主页面文件
├── config.yml          # 网站配置文件
├── README.md           # 使用说明
└── md/                 # Markdown 内容文件夹
    ├── news.md         # 最近动态
    ├── about.md        # 个人简介
    ├── publications.md # 发表论文
    ├── blogs.md        # 学术博客
    └── group-members.md # 团队成员
```

## ⚙️ 配置文件说明

### 基本信息配置

```yaml
site:
  title: "学术主页"                    # 网站标题
  language: "zh-CN"                   # 页面语言
  favicon: "/favicon.ico"             # 网站图标
```

### 个人信息配置

```yaml
profile:
  name: "张研究员"                     # 姓名
  avatar: "https://example.com/avatar.jpg"  # 头像URL
  title:                              # 职位描述（支持多行）
    - "计算机科学博士"
    - "人工智能与机器学习专家"
    - "清华大学副教授"
  position: "计算机科学 / 人工智能研究"   # 简短描述
  bio: "致力于推动人工智能的理论创新"     # 个人理念
```

### 社交链接配置

```yaml
social:
  - name: "Google Scholar"            # 链接名称
    icon: "fas fa-graduation-cap"     # Font Awesome 图标
    url: "https://scholar.google.com" # 链接地址
    tooltip: "Google Scholar"         # 悬停提示
```

### 导航菜单配置

```yaml
navigation:
  - id: "news"                        # 唯一标识符
    title: "News"                     # 显示标题
    icon: "fas fa-newspaper"          # 图标
    file: "news.md"                   # 对应的 Markdown 文件
    default: true                     # 是否为默认页面
```

### 主题颜色配置

```yaml
theme:
  primary_color: "#2c3e50"           # 主色调
  secondary_color: "#34495e"         # 次要颜色
  accent_color: "#3498db"            # 强调色
  sidebar_width: "320px"             # 侧边栏宽度
```

## 📝 内容管理

### 添加新页面

1. 在 `md/` 文件夹中创建新的 Markdown 文件
2. 在 `config.yml` 的 `navigation` 部分添加新的菜单项

```yaml
navigation:
  - id: "new-page"
    title: "新页面"
    icon: "fas fa-star"
    file: "new-page.md"
```

### Markdown 支持

所有页面内容支持完整的 Markdown 语法，包括：
- 标题、段落、列表
- 链接和图片
- 代码块和语法高亮
- 表格和引用
- HTML 标签

### 图片处理

- 图片会自动响应式适配不同屏幕
- 支持相对路径和绝对路径
- 自动添加圆角和阴影效果

## 🎨 自定义样式

### 颜色主题

您可以通过修改 `config.yml` 中的 `theme` 部分来自定义颜色：

```yaml
theme:
  primary_color: "#your-color"       # 主色调
  secondary_color: "#your-color"     # 次要颜色
  accent_color: "#your-color"        # 强调色
```

### 响应式设计

网站已经针对以下设备优化：
- 桌面端（> 768px）
- 平板端（≤ 768px）
- 手机端（≤ 576px）

## 🔧 部署说明

### 本地开发

由于浏览器 CORS 限制，需要使用 Web 服务器：

```bash
# 使用 Python
python -m http.server 8000

# 使用 Node.js
npx http-server

# 使用 PHP
php -S localhost:8000
```

### 生产部署

可以部署到任何支持静态网站的平台：
- GitHub Pages
- Netlify
- Vercel
- 阿里云 OSS
- 腾讯云 COS

## 📋 配置检查清单

- [ ] 修改个人基本信息
- [ ] 设置正确的头像链接
- [ ] 配置社交媒体链接
- [ ] 更新导航菜单项
- [ ] 编写 Markdown 内容文件
- [ ] 自定义主题颜色
- [ ] 测试所有页面链接
- [ ] 验证响应式效果

## 🐛 常见问题

### 配置文件不生效

1. 检查 `config.yml` 语法是否正确
2. 确保在 Web 服务器环境中运行
3. 查看浏览器控制台是否有错误信息

### 图片无法显示

1. 检查图片链接是否有效
2. 确保使用 HTTPS 链接（如果网站是 HTTPS）
3. 考虑使用图床服务

### Markdown 内容不显示

1. 检查文件路径是否正确
2. 确保 Markdown 文件编码为 UTF-8
3. 验证导航配置中的文件名

## 🤝 贡献

欢迎提交问题和改进建议！

## 📄 许可证

本项目采用 MIT 许可证。您可以自由使用、修改和分发。

---

> 💡 **提示**：如果您在使用过程中遇到问题，请检查浏览器控制台的错误信息，这通常能帮助您快速定位问题。 