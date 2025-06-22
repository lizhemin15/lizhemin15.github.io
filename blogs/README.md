# Blog Articles Management Guide

This folder contains all blog articles displayed on the website. The website now automatically reads all `.md` files in this folder, eliminating the need to manually maintain file lists.

## Adding New Blog Articles

1. **Create a new `.md` file**: Create a new Markdown file in the `blogs/` folder
   - It's recommended to use meaningful English names for filenames, such as: `machine-learning-guide.md`
   - The system will automatically discover newly created files without manual configuration

2. **Add front matter metadata**: Each blog file must start with YAML front matter metadata:

```markdown
---
title: "Article Title"
date: "2024-12-19"
tags: ["tag1", "tag2", "tag3"]
keywords: ["keyword1", "keyword2"]
excerpt: "Article summary that will be displayed in the blog list"
visible: true
---

# Article Title

Article content goes here...
```

3. **Save the file**: After saving, refresh the website page, and the system will automatically detect and display the new article

## Automatic File Discovery Mechanism

The blog system uses an intelligent discovery mechanism to automatically detect new blog articles:

### How It Works
- The system automatically attempts to discover `.md` files in the `blogs/` folder
- No need to maintain file lists or run additional scripts
- Supports various common file naming patterns

### Supported File Naming
The system now supports a wide range of file naming patterns, including:
- **Simple names**: `test.md`, `demo.md`, `notes.md`, `blog.md`
- **Topic-related**: `deep-learning.md`, `pytorch-tutorial.md`
- **Functional descriptions**: `user-guide.md`, `getting-started.md`
- **Numbered series**: `post-1.md`, `article-2.md`, `test-1.md`
- **Date prefixes**: `2024-12-19-new-feature.md`
- **Single letters**: `a.md`, `b.md`, `test-a.md`
- **Pure numbers**: `1.md`, `2.md`, `3.md`

### Special Notes
- `README.md` files are automatically excluded and will not appear in the blog list
- The system will try multiple common file naming patterns
- If a file doesn't appear immediately, please check if the filename follows common patterns

## Article Sorting

The website automatically sorts articles based on the `date` field:
- **Default sorting**: By time, newest first
- **User adjustable**: Users can adjust display order through the sorting dropdown menu on the page

## Supported Sorting Options

- **Time: Newest First** - Sort by date in descending order (default)
- **Time: Oldest First** - Sort by date in ascending order
- **Title: A-Z** - Sort by title alphabetically
- **Title: Z-A** - Sort by title in reverse alphabetical order

## Metadata Field Descriptions

- `title`: Article title (required)
- `date`: Publication date in "YYYY-MM-DD" format (required)
- `tags`: Tag array for categorization and filtering (optional)
- `keywords`: Keyword array for search optimization (optional)
- `excerpt`: Article summary; if not provided, will be auto-generated (optional)
- `visible`: Whether the article is visible, defaults to `true` (optional)
  - `true` or unset: Article is visible in the blog list
  - `false`: Article is hidden and won't appear in the blog list

## Search Functionality

Users can search articles through:
- Article titles
- Article content
- Tags
- Summary text

## File Naming Recommendations

- Use meaningful filenames
- Recommend using English and hyphens, such as: `machine-learning-basics.md`
- Avoid spaces and special characters

## Article Visibility Control

The `visible` field can control whether an article appears in the blog list:

### Hidden Article Example

```markdown
---
title: "Draft Article"
date: "2024-12-19"
visible: false
---

# Draft Article

This article is still being written and is temporarily not displayed in the blog list...
```

### Use Cases

- **Draft management**: Articles being written but not yet completed
- **Temporary removal**: Published articles that need to be temporarily hidden
- **Internal documentation**: Technical documents for internal use only
- **Seasonal content**: Articles that should only be displayed during specific periods

## Important Notes

- Ensure each article file has valid YAML front matter metadata
- Date format must be "YYYY-MM-DD"
- The `visible` field defaults to `true` and can be omitted
- Hidden articles can still be accessed by directly visiting the file URL
- Article content supports full Markdown syntax, including code blocks, images, tables, etc.
- After adding new articles, no manual configuration file updates are needed; the system will automatically detect them 