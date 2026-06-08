# dbs-agent-migration 工作台迁移 | 从混乱到可维护

> 使用skill: dbs-agent-migration (把混乱/半迁移/不可维护状态整理成可长期维护的结构)
> 对象: D:\KnowledgeBase\ 当前状态
> 时间: 2026-06-08

---

## 当前状态诊断

| 问题 | 症状 | 严重度 |
|------|------|--------|
| _logs目录膨胀 | 44+文件在同一层级 | 🔴 高 |
| media目录混杂 | 85文件, 含管线报告/图表/分析 | 🔴 高 |
| 根目录裸露 | INDEX.md + SKILL_INDEX.md + .git | 🟡 中 |
| 无版本隔离 | 不同session产出混在一起 | 🟡 中 |

---

## 迁移方案

### 目标结构
```
D:\KnowledgeBase\
├── INDEX.md                    # 总导航(保留)
├── articles/                   # 发布级文章(新建)
│   ├── skill-ecosystem-audit/
│   │   ├── wechat.md          # 微信版
│   │   ├── xiaohongshu.md     # 小红书版
│   │   ├── douyin.md          # 抖音版
│   │   └── twitter.md         # Twitter版
│   └── ...
├── media/                      # 保留(已有内容)
├── sessions/                   # 按日期隔离(新建)
│   ├── 2026-06-07/
│   │   └── ...                # DBS session产出
│   └── 2026-06-08_1H/
│       ├── _logs/             # 本轮分析文件
│       ├── README.md          # Session摘要
│       └── INDEX.md           # Session内索引
├── _logs/                      # 精简为全局日志
│   ├── REAL_HEARTBEAT.md
│   └── ...
└── references/                 # 共享引用(新建)
    ├── weread-data.md
    └── exa-verification.md
```

### 迁移步骤

| 步 | 操作 | 风险 | 回滚 |
|----|------|------|------|
| 1 | 创建 sessions/2026-06-08_1H/ | 低 | 删除目录 |
| 2 | 移动本轮44文件到session目录 | 低 | git checkout |
| 3 | 创建 articles/skill-ecosystem-audit/ | 低 | 删除目录 |
| 4 | 移动4个平台版到articles | 低 | git checkout |
| 5 | 更新INDEX.md链接 | 中 | git checkout |
| 6 | 清理media目录(移动管线报告到对应session) | 高⚠️ | git checkout |

---

## 建议

**不立即执行迁移**。原因:
1. media目录85个文件是前轮产出, 移动可能破坏现有引用
2. 本轮44个文件已在_logs目录, 结构清晰
3. 迁移的ROI低于继续产出内容

**什么时候执行**: 
- 累计100+文件时执行
- 或者开始新的大session时做隔离
- 迁移前先git commit -m "pre-migration snapshot"
