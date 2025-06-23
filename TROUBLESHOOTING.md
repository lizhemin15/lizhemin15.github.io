# 故障排除指南

## 配置加载失败问题

如果您遇到 "Configuration Load Failed" 错误，请按照以下步骤进行排查：

### 1. 立即解决方案

#### 方法一：强制刷新
- **Windows/Linux**: 按 `Ctrl + F5` 或 `Ctrl + Shift + R`
- **Mac**: 按 `Cmd + Shift + R`
- **移动设备**: 长按刷新按钮，选择"强制刷新"

#### 方法二：清除浏览器缓存
1. 打开浏览器开发者工具 (F12)
2. 右键点击刷新按钮
3. 选择"清空缓存并硬性重新加载"

#### 方法三：使用测试页面
访问 `test-config.html` 页面来诊断配置问题：
```
http://your-domain.com/test-config.html
```

### 2. 常见问题排查

#### 问题1：网络连接问题
**症状**: 页面显示 "Network error: Unable to connect to server"

**解决方案**:
- 检查网络连接
- 确认网站服务器正在运行
- 尝试使用不同的网络环境

#### 问题2：配置文件路径错误
**症状**: 页面显示 "Configuration file not found"

**解决方案**:
- 确认 `config.yml` 文件存在于网站根目录
- 检查文件名大小写是否正确
- 验证文件权限设置

#### 问题3：YAML语法错误
**症状**: 页面显示 "Configuration file format error"

**解决方案**:
- 使用在线YAML验证器检查语法
- 检查缩进是否正确（必须使用空格，不能使用Tab）
- 确认引号匹配正确

#### 问题4：CDN资源加载失败
**症状**: 页面显示 "External libraries failed to load"

**解决方案**:
- 检查网络连接
- 尝试使用VPN或代理
- 等待一段时间后重试

### 3. 高级故障排除

#### 检查浏览器控制台
1. 按 `F12` 打开开发者工具
2. 切换到 "Console" 标签
3. 查看错误信息
4. 将错误信息提供给技术支持

#### 验证配置文件
使用以下命令验证YAML语法：
```bash
# 如果安装了Python
python -c "import yaml; yaml.safe_load(open('config.yml'))"

# 如果安装了Node.js
node -e "const yaml = require('js-yaml'); const fs = require('fs'); yaml.load(fs.readFileSync('config.yml', 'utf8'))"
```

#### 检查服务器配置
确保服务器正确配置了MIME类型：
```apache
# Apache (.htaccess)
AddType text/yaml .yml
AddType text/yaml .yaml

# Nginx
types {
    text/yaml yml yaml;
}
```

### 4. 预防措施

#### 定期备份
- 定期备份 `config.yml` 文件
- 使用版本控制系统（如Git）

#### 测试环境
- 在本地环境测试配置更改
- 使用 `test-config.html` 验证配置

#### 监控
- 定期检查网站可用性
- 设置错误监控和告警

### 5. 联系支持

如果问题仍然存在，请提供以下信息：
1. 错误截图
2. 浏览器控制台错误信息
3. 使用的浏览器和版本
4. 操作系统信息
5. 网络环境描述

### 6. 临时解决方案

如果配置加载持续失败，可以：
1. 使用不同的浏览器
2. 清除所有浏览器数据
3. 尝试无痕/隐私模式
4. 使用移动设备访问

---

**注意**: 大多数配置加载问题都是临时的，通常通过刷新页面或清除缓存就能解决。如果问题持续存在，可能是服务器配置或网络环境的问题。 