# Academic Homepage Configuration Guide

This is an academic personal homepage dynamically generated through YAML configuration files. You can customize all website content by modifying the `config.yml` file without needing to modify HTML code.

## 🚀 Quick Start

1. **Clone or download project files**
2. **Modify the `config.yml` configuration file**
3. **Add or modify Markdown content in the `contents/` folder**
4. **Run in a web server environment** (Web server required due to CORS restrictions)

## 📁 File Structure

```
.
├── index.html          # Main page file
├── config.yml          # Website configuration file
├── README.md           # Usage instructions
└── contents/           # Markdown content folder
    ├── news.md         # Recent news
    ├── about.md        # Personal bio
    ├── publications.md # Publications
    ├── blogs.md        # Academic blogs
    └── group-members.md # Team members
```

## ⚙️ Configuration File Description

### Basic Information Configuration

```yaml
site:
  title: "Academic Homepage"          # Website title
  language: "en-US"                   # Page language
  favicon: "/favicon.ico"             # Website icon
```

### Personal Information Configuration

```yaml
profile:
  name: "Dr. Zhang"                   # Name
  avatar: "https://example.com/avatar.jpg"  # Avatar URL
  title:                              # Position description (supports multiple lines)
    - "Ph.D. in Computer Science"
    - "AI & Machine Learning Expert"
    - "Associate Professor at Tsinghua University"
  position: "Computer Science / AI Research"   # Brief description
  bio: "Dedicated to advancing theoretical innovation in AI"     # Personal philosophy
```

### Social Links Configuration

```yaml
social:
  - name: "Google Scholar"            # Link name
    icon: "fas fa-graduation-cap"     # Font Awesome icon
    url: "https://scholar.google.com" # Link URL
    tooltip: "Google Scholar"         # Hover tooltip
```

### Navigation Menu Configuration

```yaml
navigation:
  - id: "news"                        # Unique identifier
    title: "News"                     # Display title
    icon: "fas fa-newspaper"          # Icon
    file: "news.md"                   # Corresponding Markdown file
    default: true                     # Whether it's the default page
```

### Theme Color Configuration

```yaml
theme:
  primary_color: "#2c3e50"           # Primary color
  secondary_color: "#34495e"         # Secondary color
  accent_color: "#3498db"            # Accent color
  sidebar_width: "320px"             # Sidebar width
```

## 📝 Content Management

### Adding New Pages

1. Create a new Markdown file in the `contents/` folder
2. Add a new menu item in the `navigation` section of `config.yml`

```yaml
navigation:
  - id: "new-page"
    title: "New Page"
    icon: "fas fa-star"
    file: "new-page.md"
```

### Markdown Support

All page content supports full Markdown syntax, including:
- Headers, paragraphs, lists
- Links and images
- Code blocks and syntax highlighting
- Tables and quotes
- HTML tags

### Image Handling

- Images automatically adapt responsively to different screens
- Supports both relative and absolute paths
- Automatically adds rounded corners and shadow effects

## 🎨 Custom Styling

### Color Theme

You can customize colors by modifying the `theme` section in `config.yml`:

```yaml
theme:
  primary_color: "#your-color"       # Primary color
  secondary_color: "#your-color"     # Secondary color
  accent_color: "#your-color"        # Accent color
```

### Responsive Design

The website is optimized for the following devices:
- Desktop (> 768px)
- Tablet (≤ 768px)
- Mobile (≤ 576px)

## 🔧 Deployment Instructions

### Local Development

Due to browser CORS restrictions, a web server is required:

```bash
# Using Python
python -m http.server 8000

# Using Node.js
npx http-server

# Using PHP
php -S localhost:8000
```

### Production Deployment

Can be deployed to any platform that supports static websites:
- GitHub Pages
- Netlify
- Vercel
- Alibaba Cloud OSS
- Tencent Cloud COS

#### GitHub Pages Configuration

⚠️ **Important**: When using GitHub Pages, you need to configure the deployment settings properly:

1. Go to your repository's **Settings** → **Pages**
2. Under **Source**, change from "Deploy from a branch" to **"GitHub Actions"**
3. This ensures that the website can properly process dynamic content and configuration files during the build process

Without this configuration, some features (like blog visibility control) may not work correctly as the static site generation won't process the necessary logic.

## 📋 Configuration Checklist

- [ ] Modify personal basic information
- [ ] Set correct avatar link
- [ ] Configure social media links
- [ ] Update navigation menu items
- [ ] Write Markdown content files
- [ ] Customize theme colors
- [ ] Test all page links
- [ ] Verify responsive effects

## 🐛 Common Issues

### Configuration File Not Taking Effect

1. Check if `config.yml` syntax is correct
2. Ensure running in a web server environment
3. Check browser console for error messages

### Images Not Displaying

1. Check if image links are valid
2. Ensure using HTTPS links (if website is HTTPS)
3. Consider using image hosting services

### Markdown Content Not Displaying

1. Check if file paths are correct
2. Ensure Markdown files are encoded in UTF-8
3. Verify filename in navigation configuration

## 🤝 Contributing

Welcome to submit issues and improvement suggestions!

## 📄 License

This project is licensed under the MIT License. You are free to use, modify, and distribute.

---

> 💡 **Tip**: If you encounter issues during use, please check the browser console error messages, which can usually help you quickly locate problems. 