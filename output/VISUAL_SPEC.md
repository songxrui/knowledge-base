# 内容封面视觉方案规格书

> Skill: fal-ai-media | 模式：规格文档（MCP未配置·生成规格供后续执行）
> 目标：3篇装配稿封面 + 品牌视觉系统
> 可用生成工具：fal.ai Nano Banana / baoyu-cover-image skill / Canva

---

## 一、品牌视觉基础

### 色彩系统
| 角色 | 色值 | 用途 |
|------|------|------|
| 主色 | #1A1A2E（深蓝黑） | 背景底色·严肃内容 |
| 强调色 | #E94560（珊瑚红） | 标题·关键数字·CTA |
| 辅助色 | #0F3460（中蓝） | 副标题·连接线·图标 |
| 文字色 | #FFFFFF / #F0F0F0 | 白字·大标题 |
| 灰阶 | #333333 / #666666 / #999999 | 正文·辅助信息 |

### 字体选择
| 用途 | 推荐字体 | 备选 |
|------|----------|------|
| 大标题 | 思源黑体 Bold / 阿里巴巴普惠体 | Impact |
| 副标题 | 思源黑体 Regular | — |
| 正文 | 思源宋体 / 霞鹜文楷 | — |
| 英文/数字 | Inter / Space Grotesk | — |

### 统一模板要素
- 尺寸：公众号封面 900×383px / 小红书 1080×1440px
- 布局：左文右图或上文下图·留白≥30%
- 必须元素：标题大字 + 副标题小字 + 作者标识
- 禁止：过度装饰 / 无意义图标 / 多色混杂 / 低对比度

---

## 二、X01 "系统崩溃者自救手册" 封面

### 公众号版（900×383）
**Prompt for AI generation（中英双语）**：
```
A minimalist editorial cover design. Dark navy blue background (#1A1A2E). 
Large bold white Chinese text centered: "你不是懒". 
Below it, smaller text in coral red (#E94560): "系统崩溃者的自救手册".
Bottom right: small text "22岁·长沙·系统设计".
Style: clean, modern, typography-focused, high contrast.
No people, no icons, no decorations.
Negative space: 40%.
```

**视觉关键词**：极简·高对比·大字·无装饰·冷静·学术但不冷漠

### 小红书版（1080×1440）
**Prompt**：
```
Vertical poster. Dark gradient background from #1A1A2E(top) to #0F3460(bottom).
Top third: large white Chinese text "你不是懒".
Middle: bullet points in small white text — "多巴胺基线崩塌" "环境设计缺失" "系统崩溃循环".
Bottom: coral red (#E94560) call-to-action "本周做3件事".
Minimal design, editorial style, no photos.
```

---

## 三、X02 "一人企业100篇内容启动" 封面

### 公众号版（900×383）
**Prompt**：
```
A minimalist tech-creator cover. Navy-dark background.
Center: large number "100" in white bold, slightly transparent.
Overlay: "一人企业启动手册" in coral red.
Below: "22岁·0成本·每天300字" in small gray text.
Style: clean tech, almost like a startup landing page hero.
No decorations, pure typography.
```

### 即刻配图（正方形·可文字卡片）
用纯文字卡片：白底 + "#1A1A2E"深蓝文字。
标题："100篇免费内容 → 一人企业"
副标题："先写100篇，再谈产品"

---

## 四、X03 "代际错位" 封面

### 公众号版（900×383）
**Prompt**：
```
A split composition editorial cover. 
Left half: warm beige tone, blurred family photo silhouette (no faces visible).
Right half: dark navy, clean modern typography.
Right side text in white: "代际错位".
Subtitle in coral: "从精神负担到IP差异化引擎".
Bottom: "22岁拒绝考公 × AI创业" in small text.
Style: emotional but intellectual, split-screen duality.
```

**视觉关键词**：分裂构图·冷暖对比·情感但理性·代际张力

---

## 五、通用封面模板（可复用）

### 模板A：知识卡系列（适合簇综述·单张卡）
```
Background: Solid #1A1A2E
Title: 白色大字·顶部居中
Tag: 珊瑚红小标签·标题下方（如"簇1·健康底盘"）
Quote: 一句话洞察·灰色小字·底部
Author: "董辉 × Codex" · 右下角极小
```

### 模板B：深度长文系列（适合装配稿）
```
Background: 渐变 #1A1A2E → #0F3460
Title: 白色大字·上部1/3
Subtitle: 珊瑚红·中部
Stats line: 灰色数字·"3500字·7簇·34条连接"
Footer: 发布时间·平台
```

### 模板C：即刻短内容系列（纯文字卡片）
```
Background: White #FFFFFF
Text: #1A1A2E 深蓝
Accent: #E94560 珊瑚红用于关键词
格式：标题(大) + 一句话(小) + #标签(灰)
```

---

## 六、执行建议

| 优先级 | 行动 | 工具 |
|--------|------|------|
| P0 | 为X01生成公众号封面 | fal.ai Nano Banana 或 baoyu-cover-image |
| P1 | 为X02/X03生成封面 | 同上 |
| P2 | 建立Canva模板（模板A/B/C） | Canva免费版 |
| P3 | 统一所有历史卡片封面风格 | 批量工具 |

---

## Skill调用记录

| Skill | 用途 | 输出 |
|-------|------|------|
| fal-ai-media | 封面视觉方案规格（MCP未配置·规格文档模式） | 本规格书 |

> 注意：fal-ai MCP server未在Codex中配置。本规格书可直接复制Prompt到fal.ai网页端或使用baoyu-cover-image skill生成。baoyu-cover-image skill路径：C:\Users\董辉\.agents\skills\baoyu-cover-image\
