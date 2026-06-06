# 知识库双文件夹去重与分工分析报告

> 生成: 2026-06-06 | 分析范围: `D:\KnowledgeBase\`(主库) vs `D:\KnowledgeBase\_alchemist\`(迁移副本)
> 结论: **_alchemist为历史快照·零独有文件·建议保留为只读归档**

---

## 一、去重分析

### 1.1 文件级统计

| 指标 | 数值 |
|------|:--:|
| 主库MD文件总数 | 1,425 |
| _alchemist MD文件数 | 674 |
| 两库同路径文件 | 674 (100%) |
| 字节完全一致 | 229 (34.0%) |
| 大小不同 | 445 (66.0%) |
| **_alchemist独有文件** | **0** |
| 主库独有文件 | 751+ |

### 1.2 445个差异文件分析

| 差异方向 | 数量 | 占比 |
|---------|:--:|:--:|
| _alchemist版本更新 | 412 | 92.6% |
| 主库版本更新 | 33 | 7.4% |

**差异性质**：绝大部分差异<0.5KB，属于：
- Notion导出文件的时间戳/格式差异（~350个）
- 行尾换行符差异（CRLF vs LF）
- 末尾空行差异
- 实质性内容差异极少

**需关注的实质性差异**（5个文件差>1KB）：
| 文件 | 差异 | 说明 |
|------|:--:|------|
| dankoe笔记 | +2.5KB | _alchemist版本有额外内容 |
| dankoe2 | +2.0KB | 同上 |
| spec writing | +2.0KB | 同上 |
| 全周期深度复盘报告 | -1.5KB | 主库版本稍大 |
| FINAL_SKILL_OPTIMIZATION_REPORT | -1.0KB | 主库版本稍大 |

> ⚠️ 建议：对5个实质性差异文件做手动diff确认后决定是否合并。

---

## 二、结构分工分析

### 2.1 主库 `D:\KnowledgeBase\` — 生产环境·单一真相源

```
D:\KnowledgeBase\
├── cards/          ★ 35张深度卡·均分9.39·7簇封顶
├── media/          ★ 93篇媒体稿·8平台
├── _content-system/ ★ dbs-content-system v2·5层工程骨架
├── _logs/          ★ 诊断报告·质量索引·工具账本
├── output/          ★ v2/v3/v4专属提示词·V1轮卡片
├── zettel/          ★ 原子笔记
├── notion/          Notion导出原始数据
├── 01_Projects/     项目·内容创作
├── 02_Areas/        长期领域
├── 03_Resources/    资源(含weread书籍)
├── 04_Archive/      归档(含entropy清理记录)
├── .codex/          Codex配置
└── .dbs/            DBS配置
```

**定位**：活跃生产环境。所有新内容在此创建、优化、发布。对外同步到GitHub和飞书。

### 2.2 副本 `D:\KnowledgeBase\_alchemist\` — 历史快照·只读归档

```
D:\KnowledgeBase\_alchemist\
├── cards/          (older versions of same 35 cards)
├── media/          (older versions of same 93 media)
├── _content-system/ (older version of content-system)
├── output/          (older output files)
├── output/cards/    (V2轮C1-C7系列22张·均分8.45)
├── notion/          (older Notion exports)
├── _archive/        2026-06-06-entropy清理记录
├── _deprecated/     废弃文件
└── _logs/           旧日志
```

**定位**：历史快照。原为 `D:\_alchemist\output\` 工作区，迁移至KB内作为归档。**零独有文件**——所有内容主库均已包含。

### 2.3 分工建议

| 维度 | 主库 | _alchemist |
|------|------|-----------|
| 读写权限 | ✅ 读写 | 📖 只读归档 |
| 内容创作 | ✅ 所有新内容 | ❌ 不新增 |
| 对外同步 | ✅ GitHub+飞书 | ❌ 不同步 |
| 引用路径 | ✅ 绝对/相对路径 | ❌ 不对外引用 |
| Git追踪 | ✅ 已追踪 | ⚠️ 应加入.gitignore或单独处理 |

---

## 三、引用路径更新清单

### 3.1 需更新的文件（34处引用·11个文件）

| 文件 | 引用数 | 旧路径模式 | 新路径 |
|------|:--:|------|------|
| `cards/C4-3_内容产品化.md` | 1 | `D:\_alchemist\output\cards\` | `_alchemist\output\cards\` |
| `cards/C6-4_最小可行性系统.md` | 1 | 同上 | 同上 |
| `cards/C7-3_反脆弱.md` | 1 | 同上 | 同上 |
| `cards/C7-4_反共识不是叛逆.md` | 1 | 同上 | 同上 |
| `output/知识库内容质量外科医生_专属优化提示词_v2.md` | 1 | `D:\_alchemist\output\` | `D:\KnowledgeBase\_alchemist\output\` |
| `output/...v3.md` | 1 | 同上 | 同上 |
| `output/...v4.md` | 1 | 同上 | 同上 |
| `DELIVERABLE_REPORT.md` | 1 | 同上 | 同上 |
| `PROJECT_STATE_REPORT.md` | 1 | 同上 | 同上 |
| `SKILL_REVIEW_REPORT.md` | 1 | 同上 | 同上 |
| `ENTROPY_MAP.md` | 1 | 同上 | 同上 |

### 3.2 _alchemist内部引用（6个文件·不改动·只读）

`_alchemist` 内部的自引用保持不变——因为它是只读归档，无需维护一致性。

---

## 四、操作建议

### 立即执行
1. ✅ 更新主库中11个文件34处旧路径引用
2. ✅ 在 `_alchemist/` 根放 `README.md` 注明"只读归档·主库为单一真相源"
3. ✅ 考虑将 `_alchemist/` 加入 `.gitignore`（避免重复追踪）

### 可选执行
4. 🔧 对5个实质性差异文件做手动diff→合并有价值差异到主库
5. 🗑️ 确认无价值后可删除 `_alchemist/`（释放约700个文件·约50MB）
6. 📦 或压缩为 `_alchemist.zip` 保留为历史快照

### 不建议
- ❌ 将 _alchemist 与主库合并（会引入版本混乱）
- ❌ 继续向 _alchemist 写入新内容
- ❌ 从 _alchemist 引用到外部（只读归档不应有出向引用）

---

> **一句话**：`_alchemist` 是搬家时一起搬来的旧家具——不需要扔掉（有纪念价值），但所有新生活都在主库进行。
