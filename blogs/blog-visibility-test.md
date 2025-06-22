---
title: "Blog Visibility Feature Usage Guide"
date: "2024-12-19"
tags: ["Feature Guide", "Usage Instructions"]
keywords: ["visibility", "blog management"]
excerpt: "Introducing the new visibility control feature in the blog system to help better manage article display."
visible: true
---

# Blog Visibility Feature Usage Guide

The blog system now supports controlling article visibility through the `visible` field, providing more flexibility for content management.

## Feature Characteristics

### Default Behavior
- All articles are visible by default (`visible: true`)
- If the `visible` field is not set, articles will display normally
- Only articles explicitly set to `visible: false` will be hidden

### Hiding Mechanism
When an article is set to `visible: false`:
- ✅ Will not appear on the blog list page
- ✅ Will not appear in search results
- ✅ Will not appear in tag filtering
- ✅ Tags from this article will not appear in the tag selector
- ⚠️ Can still be accessed through direct URL

## Usage Examples

### Display Article (Default)
```yaml
---
title: "My Blog Post"
date: "2024-12-19"
# visible: true  # Can be omitted, defaults to true
---
```

### Hide Article
```yaml
---
title: "Draft Article"
date: "2024-12-19"
visible: false  # Explicitly set to false
---
```

## Application Scenarios

### 1. Draft Management
```yaml
---
title: "Research Notes in Progress"
date: "2024-12-19"
visible: false
tags: ["draft", "research"]
---
```

### 2. Temporary Offline
```yaml
---
title: "Technical Article Needing Corrections"
date: "2024-12-15"
visible: false
tags: ["technical", "pending-fix"]
---
```

### 3. Seasonal Content
```yaml
---
title: "2024 Annual Meeting Summary"
date: "2024-01-15"
visible: false  # Can be hidden after the meeting ends
tags: ["annual-meeting", "summary"]
---
```

## Management Recommendations

1. **Version Control**: Hidden articles are still saved in the code repository for version management
2. **Backup Integrity**: All articles will be backed up and won't be lost due to being hidden
3. **URL Access**: Note that hidden articles can still be accessed via URL, this is not complete access control
4. **SEO Impact**: Hidden articles won't appear in site search, but search engines may still index them

---

*This feature makes blog management more flexible, whether handling drafts, temporarily taking content offline, or managing seasonal articles, everything becomes more convenient.* 