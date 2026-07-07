# HyperFrames 工具链验证清单

> 在发布第一条视频之前，先把工具链跑通
> 目标：从文稿到可发布视频，全流程无卡点

---

## Phase 1：环境确认

### 1.1 Node.js 环境
```powershell
node --version  # 需要 ≥18.0
npm --version
```

### 1.2 HyperFrames 安装
```powershell
# 检查是否已安装
npx hyperframes --version

# 如果未安装
npm install -g hyperframes
```

### 1.3 技能确认
```powershell
# 列出可用技能
npx hyperframes skills list

# 确认 faceless-explainer 可用
npx hyperframes skills info faceless-explainer
```

---

## Phase 2：第一条测试视频

### 2.1 准备测试文稿
创建 `test-script.txt`：
```
22岁那年，我亏了5300块。不是做生意亏的，是交易。
一个月，什么都不懂，冲进去，5300块没了。
那是我全部积蓄的三分之一。
但现在回头看，这是我最值的学费。
```

### 2.2 生成视频
```powershell
npx hyperframes render --skill faceless-explainer --input test-script.txt --style minimal-knowledge --output test-video.mp4
```

### 2.3 检查输出
- [ ] 视频能正常播放
- [ ] 字幕显示正确
- [ ] 时长与文稿匹配
- [ ] 画质清晰（≥1080p）
- [ ] 文件大小合理（<50MB 适合抖音上传）

---

## Phase 3：风格调优

### 3.1 颜色方案
```yaml
# hyperframes.config.yaml 或命令行参数
colors:
  primary: "#1A3A5C"      # 深蓝
  secondary: "#E8E0D9"    # 暖灰
  accent: "#D4A843"       # 金色
  text: "#FFFFFF"         # 白色字幕
  background: "#0D1B2A"   # 深色背景
```

### 3.2 字体选择
- 中文字幕：思源黑体 / 阿里巴巴普惠体（清晰易读）
- 英文数字：Inter / SF Pro（现代感）

### 3.3 字幕样式
- 位置：底部居中
- 大小：适中（手机屏幕可清晰阅读）
- 动画：逐字显示（可选，看效果）

---

## Phase 4：批量生产流程

### 4.1 单条生产
```powershell
# 1. 写脚本 → scripts/day01.txt
# 2. 生成视频
npx hyperframes render -s faceless-explainer -i scripts/day01.txt -o output/day01.mp4
# 3. 检查 → 发布
```

### 4.2 批量生产（5条一批）
```powershell
# PowerShell 脚本
$scripts = Get-ChildItem "scripts/day*.txt" | Sort-Object Name
foreach ($s in $scripts) {
    $out = "output/" + $s.BaseName + ".mp4"
    Write-Output "Rendering: $($s.Name) -> $out"
    npx hyperframes render -s faceless-explainer -i $s.FullName -o $out
}
```

### 4.3 发布前检查每一条
- [ ] 视频能播放
- [ ] 字幕无错别字
- [ ] 时长 60-90 秒
- [ ] 封面图已准备
- [ ] 标题已写好

---

## Phase 5：常见问题

| 问题 | 解决 |
|------|------|
| `hyperframes: command not found` | `npm install -g hyperframes` |
| 视频无声音 | faceless-explainer 默认无配音，需额外添加 TTS |
| 字幕位置偏移 | 调整 subtitles.position 参数 |
| 生成速度慢 | 短视频（<500字）通常在 30 秒内完成 |
| 文件太大 | 调整 bitrate 参数降低文件大小 |

---

## Phase 6：发布到抖音

### 6.1 上传要求
- 格式：MP4
- 分辨率：1080×1920（竖屏 9:16）
- 大小：≤4GB（通常几十MB没问题）
- 时长：15秒-30分钟

### 6.2 发布流程
1. 打开抖音创作者中心（电脑版）或 APP
2. 上传视频
3. 填写标题（从选题池取）
4. 添加话题标签
5. 选择封面（或自动截取）
6. 定时发布（工作日晚7-9点最佳）
7. 记录到 CSV 数据表

---

## ✅ 验证完成标准

- [ ] 成功生成 1 条测试视频
- [ ] 视频在手机上播放正常
- [ ] 从写稿到发布全流程跑通一次
- [ ] 批量生成脚本可用
- [ ] CSV 数据记录正常
