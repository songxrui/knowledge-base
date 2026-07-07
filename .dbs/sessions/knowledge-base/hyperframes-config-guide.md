# HyperFrames 不露脸知识口播实操配置手册

> 适用场景：董辉抖音口播，脚本 → HyperFrames → 不露脸知识视频
> 对标风格：dontbesilent（白板/简洁/知识讲解型）
> 创建日期：2026-07-02 | 基于 HyperFrames CLI v2.x + faceless-explainer skill

---

## 1. HyperFrames CLI 快速上手

### 环境要求

| 依赖 | 版本要求 | 检查命令 |
|------|---------|---------|
| Node.js | >= 22 | 
ode -v |
| FFmpeg | 最新稳定版 | fmpeg -version |
| Chrome | 用于 headless 渲染 | 自动检测 |

`powershell
# 环境自检
npx hyperframes doctor --json
`

### 安装与初始化

`powershell
# 方式1：从零创建项目
npx hyperframes init "videos/<项目名>" --non-interactive --example=blank

# 方式2：从 URL 捕获（不适用于口播场景，口播用方式1）
# npx hyperframes capture <url> --output "videos/<项目名>"
`

> **项目命名规范**：使用 kebab-case，如 shangye-siwei-jinjiemoshi，不要用日期或中文命名。

### 核心工作流（6 步）

`
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│ 1. init  │ → │ 2. lint  │ → │3.validate│ → │4.inspect │ → │5.preview │ → │6.render  │
└──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘
     ↓              ↓              ↓               ↓              ↓              ↓
  项目脚手架    静态检查      运行时验证     视觉布局检查    Studio编辑      MP4输出
`

### 常用命令速查表

| 命令 | 用途 | 使用时机 |
|------|------|---------|
| 
px hyperframes init "videos/<name>" | 创建项目 | 每个新视频开始 |
| 
px hyperframes lint | 静态语法检查 | 每次修改 HTML 后 |
| 
px hyperframes validate | 运行时错误+对比度检查 | lint 通过后 |
| 
px hyperframes inspect | 文字溢出/布局检查 | validate 通过后 |
| 
px hyperframes preview | 打开 Studio 时间轴编辑器 | 所有检查通过，人工审查 |
| 
px hyperframes render --quality draft | 快速草稿渲染 | 迭代阶段 |
| 
px hyperframes render --quality high --output out.mp4 | 高质量最终渲染 | 交付阶段 |
| 
px hyperframes snapshot --frames 9 | 抽帧快照（秒级验证） | 多子合成时验证挂载 |
| 
px hyperframes doctor --json | 环境诊断 | 出问题时 |

**竖屏口播配置**（抖音专用）：

`powershell
# 渲染 1080x1920 竖屏视频
npx hyperframes render --quality high --output renders/video.mp4 -- --width=1080 --height=1920
`

---

## 2. 董辉专属视频模板配置

### 模板选择策略

根据脚本类型选择对应模板，同一批脚本可混用三个模板以保持账号视觉多样性。

---

### 模板A：白板讲解型

**对标 dontbesilent 核心风格：白底+黑字+箭头+关键概念浮现**

| 属性 | 配置 |
|------|------|
| **适用脚本** | 方法论类、商业思维、模型拆解、认知升级 |
| **Frame Preset** | lockframe（干净块状布局）/ cartesian（理性几何感） |
| **核心 Blueprint** | kinetic-type-beats（文字即运动）、dataviz-countup（数字论证）、grid-card-assemble（要点罗列） |
| **画面比例** | 1080×1920（竖屏） |
| **背景** | 纯白 #FFFFFF 或极浅灰 #F5F5F5 |
| **字体** | 系统无衬线黑体（思源黑体/阿里巴巴普惠体），标题 48-64px，正文 28-36px |
| **配色** | 主色 #1A1A1A（黑）、强调色 #FF4444（红）用于箭头/圈注/关键词 |
| **动效** | per-word reveal（逐词浮现）、layer-reveal（层级揭示）、count-up（数字跳动） |

**画面节奏建议：**

`
0:00-0:03 开头3秒：【核心问题/反常识观点】
  - 全屏大字抛出痛点问题
  - 使用 ticker-takeover 蓝图：文字碰撞式进入
  - 动画：spring-pop，0.5s 入场 + 2.5s 停留

0:03-0:25 中段：【论点展开 3-4 层】
  - 每层用 kinetic-type-beats：一个概念 → 解释 → 过渡到下一个
  - 箭头/线条逐段画出，跟随语音节奏
  - 动画：layer-reveal，每层 0.6s 入场 + 字句停留

0:25-0:30 结尾：【金句总结 + CTA】
  - 标题卡收尾：核心金句居中 + 关注引导
  - 使用 titlecard-reveal 蓝图：干净切入 + 静止停留
  - 动画：slide-up crossfade，1s 入场 + 3s 停留
`

---

### 模板B：故事叙述型

**场景切换 + 文字叠加 + 叙事节奏**

| 属性 | 配置 |
|------|------|
| **适用脚本** | 个人经历、创业故事、案例复盘、情感共鸣 |
| **Frame Preset** | editorial-forest（编辑感深色）/ roadside（宽幅叙事感） |
| **核心 Blueprint** | spatial-pan-stations（时间线推进）、	ypewriter-reveal（打字机悬念）、	itlecard-reveal（章节切换） |
| **画面比例** | 1080×1920（竖屏） |
| **背景** | 深色渐变 #1A1A2E → #16213E 或暖色暗调 #2D2424 |
| **字体** | 标题加粗字重 700+，正文常规字重 400，章节标题 56px |
| **配色** | 主色 #FFFFFF（白字）、柔和金 #C9A96E 用于关键数字/人名/转折 |
| **动效** | ade-up（渐显上升）、	ypewriter（打字机敲入）、crossfade（场景溶解过渡） |

**画面节奏建议：**

`
0:00-0:03 开头3秒：【悬念钩子】
  - 深色背景 + 一行打字机文字逐字出现
  - 使用 typewriter-reveal 蓝图
  - "我曾以为..." 类句式制造好奇

0:03-0:25 中段：【故事推进 3 个阶段】
  - 每个阶段一个场景切换（spatial-pan-stations 蓝图）
  - 阶段1：困境 — 文字叠加在暗背景上，轻微推入
  - 阶段2：转折 — 亮度提升，关键数字弹跳（dataviz-countup）
  - 阶段3：结果 — 表格/card组合揭示（grid-card-assemble）
  - 每阶段 6-8s，过渡用 crossfade 0.5s

0:25-0:30 结尾：【价值提炼】
  - 故事收束为一句金句
  - 使用 titlecard-reveal 干净落地
`

---

### 模板C：数据论证型

**图表 + 数字动画 + 对比冲击**

| 属性 | 配置 |
|------|------|
| **适用脚本** | 案例分析、行业数据、趋势解读、对比拆解 |
| **Frame Preset** | cobalt-grid（科技蓝网格）/ lue-professional（商务蓝） |
| **核心 Blueprint** | dataviz-countup（核心数据）、comparison-split（A/B 对比）、grid-card-assemble（多维度展开） |
| **画面比例** | 1080×1920（竖屏） |
| **背景** | 深蓝 #0A1628 配合网格线 / 纯黑 #000000 |
| **字体** | 数字用等宽字体（JetBrains Mono / SF Mono），标题 40-52px，数字 64-80px |
| **配色** | 主色 #00D4FF（科技蓝）、对比色 #FF6B35（橙）/ #00FF88（绿）、灰色 #8899AA 辅助 |
| **动效** | count-up（数字从 0 跳动到目标值）、comparison-split（两边同时入场）+ staggered-reveal（交错揭示） |

**画面节奏建议：**

`
0:00-0:03 开头3秒：【震撼数字开场】
  - 全屏大数据 + count-up 动画
  - 使用 dataviz-countup 蓝图：数字 0→目标值跳动
  - 数值 >1000 时带千位分隔符逗号动画

0:03-0:20 中段：【数据展开 3-4 维度】
  - 维度1-2：comparison-split 蓝图 — A/B 两列对比
  - 维度3-4：grid-card-assemble 蓝图 — 2×2 网格卡片逐个弹出
  - 每个维度 4-5s，伴随语音讲解

0:20-0:30 结尾：【结论 + 行动】
  - 数据汇总为 1 个结论性数字或比率
  - 使用 constellation-hub 蓝图：核心结论居中，卫星数据环绕
  - 最终收敛到单条金句
`

---

### 模板参数快速对照

| 维度 | 模板A 白板 | 模板B 故事 | 模板C 数据 |
|------|-----------|-----------|-----------|
| 背景色 | #FFFFFF 白 | #1A1A2E 深 | #0A1628 蓝黑 |
| 文字色 | #1A1A1A 黑 | #FFFFFF 白 | #00D4FF 蓝 |
| 强调色 | #FF4444 红 | #C9A96E 金 | #FF6B35 橙 |
| 主字体 | 黑体 sans | 黑体 sans | 等宽 mono |
| 主蓝图 | kinetic-type-beats | typewriter-reveal | dataviz-countup |
| 动效风格 | 线性浮现 | 打字机+溶解 | 数字跳动 |
| 节奏感 | 快-稳-收 | 慢-紧-爆 | 冲-展-聚 |

---

## 3. 批量生产流程

### 单条视频制作耗时估算

| 阶段 | 耗时 | 说明 |
|------|------|------|
| 脚本准备 | 已有（60+ 条就绪） | 假设单条 150-300 字，30-60s 口播 |
| HyperFrames 初始化 | 30s | init 命令自动拉取最新 skills |
| 设计系统（frame.md） | 首次 10min，后续复用模板 | 同一模板批量化时只需一次 |
| STORYBOARD + SCRIPT | 5min/条 | 脚本 → 分帧 → 配音标注 |
| TTS 配音生成 | 1min/条 | hyperframes-media 自动处理 |
| 视觉设计（per frame） | 10-15min/条 | 3-5 个 frame，每 frame 3-5min |
| 帧编码（frame worker） | 5-10min/条 | 并行生成每帧 HTML |
| 检查链（lint+validate+inspect） | 1min/条 | 自动化 |
| 渲染 | 1-3min/条 | draft 更快，high 更慢 |
| **合计** | **首次约 40min，复刻约 20min/条** | 同模板批量时大幅缩减 |

### 批量生产文件夹组织

`
D:\videos\douyin\
├── templates\                    # 模板库（一次创建，反复使用）
│   ├── template-a-baiban\       # 模板A：白板讲解型
│   │   ├── hyperframes.json
│   │   ├── frame.md             # 设计系统（字体/颜色/间距）
│   │   └── STORYBOARD.md.tmpl   # 故事板模板
│   ├── template-b-gushi\        # 模板B：故事叙述型
│   │   └── ...
│   └── template-c-shuju\        # 模板C：数据论证型
│       └── ...
│
├── projects\                     # 每期视频独立项目
│   ├── 2026-07-02-jinjiemoshi\   # 命名：日期-主题名
│   │   ├── hyperframes.json
│   │   ├── frame.md              # 从模板复制并调整
│   │   ├── STORYBOARD.md
│   │   ├── SCRIPT.md
│   │   ├── capture\extracted\
│   │   │   ├── visible-text.txt  # 原始脚本全文
│   │   │   └── tokens.json       # 标题/描述/配色
│   │   ├── compositions\
│   │   │   ├── frames\           # 每帧 HTML
│   │   │   └── index.html        # 主合成文件
│   │   └── renders\
│   │       └── video.mp4
│   ├── 2026-07-03-xxxxx\
│   └── ...
│
├── scripts\                      # 本地辅助脚本
│   ├── batch-init.ps1            # 批量初始化项目
│   ├── copy-template.ps1         # 从模板复制设计系统
│   └── batch-render.ps1          # 批量渲染（适合 overnight）
│
└── README.md                     # 当前进度和待办
`

### 脚本 → 视频命名规范

| 环节 | 命名格式 | 示例 |
|------|---------|------|
| 项目文件夹 | YYYY-MM-DD-<主题拼音> | 2026-07-02-shangye-moshi |
| STORYBOARD | STORYBOARD.md | 含分帧+视觉设计 |
| SCRIPT | SCRIPT.md | 锁定的配音文案 |
| 原始脚本 | capture/extracted/visible-text.txt | 完整脚本内容 |
| 最终视频 | enders/<主题拼音>_<模板>_v<版本>.mp4 | shangye-moshi_baiban_v1.mp4 |
| 发布用 | douyin_<日期>_<序号>.mp4 | douyin_0702_01.mp4 |

---

## 4. 质量检查清单

### 每期视频渲染前必查

`powershell
# 自动化检查链
npx hyperframes lint        # 静态：data-attribute 遗漏、track 重叠
npx hyperframes validate    # 运行时：console error、WCAG 对比度
npx hyperframes inspect     # 视觉：文字溢出、motion 意图校验
`

### 人工审查清单

#### 口播节奏
- [ ] **念一遍不拗口**：SCRIPT.md 朗读一遍，卡顿处改文案
- [ ] **信息密度适中**：每 10s 不超过 2 个新概念，留 1-2s 消化间隙
- [ ] **无废话填充词**：删掉"就是说"、"然后"、"那个" 等口头禅
- [ ] **语速控制在 180-220 字/分钟**：口播视频偏快，保持紧凑

#### 字幕准确性
- [ ] **TTS 输出字字对应**：用 hyperframes transcribe 校验
- [ ] **标点不影响断句**：中文句号/逗号处 TTS 自然停顿
- [ ] **关键术语无误**：人名、数字、英文词二次校对
- [ ] **字幕出现时机**：与语音 ≤0.1s 偏差

#### 画面与内容匹配度
- [ ] **每一帧有且仅有一个焦点**：focal 元素 40-60% 画幅
- [ ] **画面节奏跟随语音**：每句话揭示一个视觉元素，不提前铺满
- [ ] **模板风格统一**：整条视频用同一 preset，不混搭
- [ ] **无 PowerPoint 感**：没有"一次性铺满然后静止"的帧

#### 片头 3 秒吸引力
- [ ] **前 3 秒有视觉动作**：不是静止标题卡
- [ ] **钩子信息明确**：观众 3 秒内知道这条讲什么
- [ ] **无黑屏/加载过渡**：第一帧直接开讲

#### 技术质量
- [ ] **分辨率 1080×1920**：竖屏满屏无黑边
- [ ] **帧率 ≥25fps**：字体动画无卡顿
- [ ] **音频清晰无杂音**：TTS 输出无明显机械感
- [ ] **文件大小 <100MB**：1 分钟竖屏视频合理范围

---

## 5. 发布配置

### 抖音标题规范

| 规则 | 说明 | 示例 |
|------|------|------|
| ≤20 字 | 标题在信息流显示完整 | "你赚不到钱是因为太努力了" |
| 前 8 字即钩子 | 前 8 字决定点击率 | "一个人开始变强的 3 个信号" |
| 包含关键词 | SEO + 推荐算法识别 | "商业思维"、"创业"、"认知" |
| 避免标题党 | 内容必须兑付标题承诺 | ❌ "看完我沉默了…" |
| 用疑问/数字/对比 | 提高打开率 | "为什么越聪明的人越沉默？" |

### 标题模板库

`
【模板A 白板类】
- <核心概念>：大多数人都理解错了
- 一张图讲清楚<主题>
- <数字>个让你变强的<领域>思维

【模板B 故事类】
- 我从<经历>中学到的<数字>件事
- <时间>前我做了一个决定…
- 那个<人物>教会我的事

【模板C 数据类】
- <数字>%的人不知道的<领域>真相
- 一组数据看懂<行业>
- <A> vs <B>：差距到底有多大
`

### 标签策略（5-10 个）

| 层级 | 标签类型 | 示例 | 数量 |
|------|---------|------|------|
| 一级 | 领域大词 | #商业思维 #个人成长 #认知升级 | 2-3 |
| 二级 | 内容细分类 | #商业模式 #创业干货 #搞钱思维 | 2-3 |
| 三级 | 热点/趋势 | #抖音知识 #2026趋势 | 1-2 |
| 补充 | 账号标签 | #董辉 #不露脸口播 | 1-2 |

### 话题选择

`
必选话题（2-3个）：
#知识分享  → 基础流量池
#商业思维  → 垂直领域
#个人成长  → 泛知识流量

配合话题（按内容选 1-2 个）：
#创业    → 商业/搞钱类
#职场    → 效率/晋升类
#搞钱    → 收入/副业类
#认知    → 深度思考类
#干货    → 方法论类
#复盘    → 案例拆解类
`

### 最佳发布时间建议

| 时段 | 推荐度 | 说明 |
|------|--------|------|
| 07:30-08:30 | ⭐⭐⭐⭐⭐ | 早通勤，知识类内容消费高峰 |
| 12:00-13:00 | ⭐⭐⭐⭐ | 午休碎片时间 |
| 18:00-19:00 | ⭐⭐⭐⭐ | 晚通勤/等餐时间 |
| 21:00-22:00 | ⭐⭐⭐⭐⭐ | 睡前深度学习时段 |
| 周五/周六晚 | ⭐⭐⭐ | 周末放松，轻松内容更优 |

> **固定发布时间**：选择一个固定时段（如每天 07:30 或 21:00），培养观众预期。测试 2 周数据后调整。

---

## 附录 A：HyperFrames 完整工作流脚本

`powershell
# === 一条视频的完整生命周期 ===

# Step 0: 确认环境
npx hyperframes doctor --json

# Step 1: 创建项目
npx hyperframes init "videos/douyin/<项目名>" --non-interactive --example=blank

# Step 2: 放入脚本
# 将脚本全文写入 capture/extracted/visible-text.txt
# 编辑 capture/extracted/tokens.json（标题/描述）

# Step 3: 从模板复制设计系统
Copy-Item "D:\videos\douyin\templates\template-a-baiban\frame.md" 
          "videos/douyin/<项目名>\frame.md"

# Step 4: 编写 STORYBOARD.md 和 SCRIPT.md
# 按照 faceless-explainer skill 规范编写分帧脚本

# Step 5: 生成 TTS 配音
# hyperframes-media 自动处理（选择 HeyGen 或本地引擎）

# Step 6: 构建帧 HTML（每帧一个 composition）
# 使用 frame-worker 子代理并行生成

# Step 7: 检查链
npx hyperframes lint
npx hyperframes validate
npx hyperframes inspect

# Step 8: 抽帧快照验证
npx hyperframes snapshot --frames 9

# Step 9: Studio 人工审查
npx hyperframes preview

# Step 10: 渲染输出
npx hyperframes render --skill=faceless-explainer --quality high 
    --output renders/douyin_<日期>_<序号>.mp4 
    -- --width=1080 --height=1920
`

---

## 附录 B：可用 Frame Presets 速查

| Preset | 风格 | 推荐模板 | 特征 |
|--------|------|---------|------|
| lockframe | 干净块状 | 模板A 白板 | 清晰几何分区，理性克制 |
| cartesian | 理性几何 | 模板A 白板 | 网格/坐标感，逻辑感强 |
| old-poster | 大胆海报 | 模板A/B | 大字体冲击，适合钩子帧 |
| editorial-forest | 编辑感深色 | 模板B 故事 | 深绿调，叙事氛围 |
| roadside | 宽幅叙事 | 模板B 故事 | 横向延展，适合时间线 |
| cobalt-grid | 科技蓝网格 | 模板C 数据 | 网格线+蓝调，数据感 |
| lue-professional | 商务蓝 | 模板C 数据 | 专业商务，图表友好 |
| capsule | 药丸卡片 | 通用 | 圆角卡片风格，轻量 |
| claude | 克劳德风 | 通用 | 人文+科技平衡 |
| creative-mode | 创意模式 | 通用 | 活泼多彩 |

---

## 附录 C：15 个 Blueprint 在口播场景的适用性

| Blueprint | 抖音口播适用度 | 推荐模板 | 用途 |
|-----------|:--:|---------|------|
| kinetic-type-beats | ⭐⭐⭐⭐⭐ | A/B | 核心工作马，文字即运动 |
| dataviz-countup | ⭐⭐⭐⭐⭐ | C | 数据可视化+数字跳动 |
| 	itlecard-reveal | ⭐⭐⭐⭐⭐ | A/B/C | 章节切换/金句收尾 |
| 	ypewriter-reveal | ⭐⭐⭐⭐ | B | 打字机悬念钩子 |
| grid-card-assemble | ⭐⭐⭐⭐ | A/C | 要点/维度罗列 |
| comparison-split | ⭐⭐⭐⭐ | C | A/B 对比论证 |
| spatial-pan-stations | ⭐⭐⭐ | B | 时间线/叙事推进 |
| 	icker-takeover | ⭐⭐⭐ | A | 暴力开场钩子 |
| constellation-hub | ⭐⭐⭐ | C | 核心观点+卫星论据 |
| logo-assemble-lockup | ⭐⭐ | A | 品牌收尾（少用） |
| cursor-ui-demo | ⭐ | — | 产品演示，不适用口播 |
| device-surface-showcase | ⭐ | — | 产品展示，不适用口播 |
| overwhelm-surround | ⭐⭐ | B | 困境堆积感 |
| ideo-text-pivot | ⭐⭐ | C | 视频+数据联动（需素材） |
| cta-morph-press | ⭐⭐ | A | 行动号召收尾 |

---

## 附录 D：快速开始 — 你的第一条视频

`powershell
# 1. 进入工作目录
cd D:\videos\douyin

# 2. 初始化第一个项目
npx hyperframes init "projects/2026-07-02-ceshi" --non-interactive --example=blank

# 3. 把你的脚本放进去
# 编辑 projects/2026-07-02-ceshi/capture/extracted/visible-text.txt，粘贴脚本全文

# 4. 选择模板 A（白板型）作为起点
Copy-Item "templates/template-a-baiban/frame.md" "projects/2026-07-02-ceshi/frame.md"

# 5. 编写分帧 + 配音脚本
# 格式参考：hyperframes-core/references/storyboard-format.md
# 格式参考：faceless-explainer/references/visual-design.md

# 6. 完成后渲染预览
npx hyperframes preview
`

> **建议**：先用 1 条脚本完整跑通全流程，确认模板参数（颜色/字体/节奏）满意后，再批量复用模板制作其余 59+ 条。

---

*本手册基于 HyperFrames CLI v2.x、faceless-explainer skill、hyperframes-core composition contract 编写。*
*命令在 Node.js >= 22 + FFmpeg 环境下验证。*
