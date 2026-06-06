# ENTROPY_MAP.md — 两库全量文件熵减分类

> 2026-06-06 | D:\KnowledgeBase (736files, 56.7MB) + D:\_alchemist\output (658files, ~55MB)
> 分类: PROTECT(不动) / MERGEABLE(合并) / DELETABLE(过程垃圾) / PENDING(待定)

---

## 📊 总览

| 类别 | KB库 | AL库 | 说明 |
|------|:--:|:--:|------|
| PROTECT | ~500 | ~500 | 证据/文章/卡片/来源 |
| MERGEABLE | ~15 | ~10 | 重复/多版本/同内容副本 |
| DELETABLE | ~120 | ~50 | 零字节/过期/存根/临时 |
| PENDING | ~100 | ~90 | 大文件/图片/不确定 |

---

## 🔴 PROTECT 保护清单（绝对不动）

### 地基文件（8）
| 文件 | 大小 | 理由 |
|------|------|------|
| DENOMINATOR_LOCK.md | 1.9KB | 分母冻结基准 |
| BASELINE_AUDIT.md | 2.8KB | 全核实测基线 |
| PUBLISHABLE_TREND.md | ~30KB+ | 五轮爬坡记录 |
| CROSSREF_PURGE.md | 1.5KB | 交叉引用降级记录 |
| LEDGER_RECONCILE.md | ~1KB | 267vs42口径 |
| REMEDIATION_COST.md | ~1KB | 吞吐自洽 |
| DOD_AUDIT.md | ~4KB | 最终验收 |
| FINAL_AUDIT.md | ~3KB | 终审报告 |

### 证据账本（5）
| 文件 | 大小 | 理由 |
|------|------|------|
| VERIFICATION_LEDGER.md | 27.4KB | 全断言溯源台账 |
| REVIEW_LOG.md | ~8KB | 修复日志 |
| REVIEW_LOG_R2.md | 4.2KB | 第二轮日志 |
| FRAUD_AUDIT.md | 4.2KB | 冒充审计 |
| SELF_INSPECTION_REPORT.md | 4.6KB | 自查报告 |

### 状态文件（3）
| 文件 | 大小 | 理由 |
|------|------|------|
| BACKLOG.md | 1.5KB | 待修清单 |
| BLOCKED_CMDS.md | ~1KB | 阻塞记录 |
| PROGRESS.md | ~2KB | 进度追踪 |

### 证据源（SOURCES/ + _logs/）
| 目录 | 文件数 | 理由 |
|------|:--:|------|
| SOURCES/cards/ | 5 | 原始卡片证据 |
| SOURCES/diffs/ | 20 | before→after差异 |
| _logs/*.md | 16 | 验证/部署日志 |
| _logs/weread_raw.json | 266KB | 微读原始数据 |

### 媒体成品（media/）— 全部保护
| 子目录 | 文件数 | 说明 |
|------|:--:|------|
| media/scripts/ | 7 | SC1-SC7 视频脚本 |
| media/threads/ | 7 | TC1-TC7 X/Twitter |
| media/xiaohongshu/ | 21 | XC1a-XC7c 小红书 |
| media/jike/ | 14 | JC1a-JC7b 即刻 |
| media/flagship/ | 3 | F1-F3 旗舰长文 |
| media/zhihu/ | 7 | Z1-Z7 知乎 |
| media/newsletter/ | 2 | N1-N2 通讯 |
| media/longform/ | 1 | 长篇 |
| media/M01-M12.md | 12 | 装配稿 |

### 知识卡（cards/）— 全部保护
| 目录 | 文件数 | 说明 |
|------|:--:|------|
| cards/ | 35 | C1-C7簇 35张深度卡 |

### 内容系统（_content-system/）— 全部保护
| 子目录 | 文件数 | 说明 |
|------|:--:|------|
| 01-规则层 | 3 | 系统规则 |
| 02-素材副本 | 0 | 空目录 |
| 03-内容单元 | 4 | 内容模板 |
| 04-主题地图 | 7 | 主题索引 |
| 05-装配稿 | 10 | 合成稿 |
| 06-关系与去重 | 3 | 重复检测 |
| 07-处理状态 | 3 | 处理追踪 |
| 08-学习序列 | 17 | 学习路径 |
| 09-技能增强 | 9 | 技能增强 |

### 知识卡片/笔记
| 目录/文件 | 说明 |
|------|------|
| zettel/ (11) | Zettelkasten原子笔记 |
| 01_Projects/ (~130) | 项目内容草稿（health/cognition/wealth等） |
| 03_Resources/weread/ (21) | 微读书籍导出笔记 |
| 03_Resources/traffic-engineering/ (5) | 流量工程参考 |
| 03_Resources/feishu-dontbesilent/ (0) | 飞书社群参考（空） |
| notion/ (~80) | Notion导出原始笔记 |

### 配置/系统
| 文件 | 理由 |
|------|------|
| .codex/ | Codex配置 |
| .gitignore | Git配置 |
| README.md | 仓库说明 |
| INDEX.md | 导航索引 |

---

## 🟡 MERGEABLE 可合并

### 重复/多版本
| 文件A | 文件B | 判定依据 | 处置 |
|------|------|---------|------|
| 知识库内容质量外科医生_专属优化提示词.md (23.5KB) | output/知识库内容质量外科医生_专属优化提示词_v2.md (22.8KB) | 同内容v1→v2·v2为升级版 | 保留v2·v1归档 |
| output/cards/ (42 files, 108.7KB) | cards/ (35 files, 290KB) | output/cards为卡片副本 | 对比去重·保留cards/为主 |
| _logs/SC3_VERIFICATION.md等8个 | root/VERIFICATION_LEDGER.md | 验证日志已整合入LEDGER | 保留两者·日志为详细记录 |
| 01_Projects/.../publishing/ (~20空壳) | media/中对应成品 | publishing目录为发布占位符·内容为空壳(100-130B) | 见DELETABLE |

### 同内容不同格式
| 文件 | 说明 | 处置 |
|------|------|------|
| output/feishu-nodes.json (0B) | 空文件 | →DELETABLE |
| _logs/weread_*.json (3个0B) | 空JSON | →DELETABLE |
| notion/*.zip (799KB) | 已解压的Notion导出包 | →DELETABLE (源已解压) |

---

## 🟢 DELETABLE 过程垃圾

### 零字节文件（4）
| 文件 | 理由 |
|------|------|
| output/feishu-nodes.json | 0B·空文件 |
| _logs/weread_少有人走的路.json | 0B·空JSON |
| _logs/weread_成瘾.json | 0B·空JSON |
| _logs/weread_低碳水.json | 0B·空JSON |

### 发布占位符/空壳（~20）
这些是`01_Projects/content-creation/publishing/`下的文件，内容仅为模板占位符（100-130B）：
| 目录 | 文件数 | 示例内容 |
|------|:--:|------|
| publishing/wechat/ | 5 | "长文73-代谢综合征..." (127B) |
| publishing/x-threads/ | 3 | "长文12-第一性原理思考入门" (127B) |

内容示例：`# 长文73-代谢综合征不是一种病\n\n待生成` — 纯占位符

### 已弃用/过期
| 文件 | 理由 |
|------|------|
| _deprecated/G2-G7.md (6 files) | 已明确标记废弃·已有新版本 |
| BATCH_REVIEW_41.md | 批处理审查·已被FRAUD_AUDIT取代 |
| FIX_PLAN.md + FIX_REPORT.md | 早期修复计划·已被R15-R19取代 |
| AUDIT_COST.md | 早期成本·已被REMEDIATION_COST取代 |
| INSPECTION_COST.md | 早期检查·已整合 |
| L4_UPGRADE.md | 单次升级记录·已整合入REVIEW_LOG |
| ROUND_AUDIT.md | 单轮审计·已整合入PUBLISHABLE_TREND |
| QUALITY_TREND.md | 旧版质量趋势·已被PUBLISHABLE_TREND取代 |

### 可重生成的中间输出
| 文件/目录 | 理由 |
|------|------|
| output/skill-reports/ (9 files, 40KB) | 技能评测中间报告·可由skill-review重新生成 |
| output/cards/ (42 files) | 卡片副本·与cards/重复 |

---

## ⚪ PENDING 待定（需人工裁定）

### 大文件（可能非知识内容）
| 文件 | 大小 | 问题 |
|------|------|------|
| zhanshimian/本人/ (9 files) | 51.1MB | 个人形象照/照片·非知识内容 |
| zhanshimian/他人学习参考/ (5 files) | 2.0MB | 参考图片·非知识内容 |

→ 建议：移至独立目录或外部存储·不属知识库内容

### 空目录
| 目录 | 处置建议 |
|------|---------|
| 00_Inbox/ | 保留（Inbox功能目录） |
| 04_Archive/ | 保留（归档功能目录） |
| _content-system/02-素材副本/ | 保留（系统功能目录） |
| 03_Resources/feishu-dontbesilent/ | 保留（待填充） |

### Notion导出
| 文件 | 大小 | 建议 |
|------|------|------|
| notion/*.zip | 799KB | 已解压·可删 |
| notion/hui2737/.../ (~80 files) | 1.4MB | 原始笔记源·保留 |

---

## 📋 处置汇总

| 类别 | KB库数量 | AL库数量 | 预计操作 |
|------|:--:|:--:|------|
| PROTECT | ~500 | ~500 | 不动 |
| MERGEABLE→归档 | ~60 | ~52 | git mv → _archive/ |
| DELETABLE→归档 | ~90 | ~5 | git mv → _archive/ |
| PENDING | ~86 | ~91 | 标记待定 |
| **操作后预计** | **~500** | **~500** | 减少~150文件 |

---

## ⚠️ D:\_alchemist\output 待处理重复（20组）

以下文件组存在2-3个副本跨目录分布，需确定canonical版本后合并：

| 文件 | 副本数 | 分布目录 |
|------|:--:|------|
| 长文02-三重大脑与元认知.md | 3 | cards/, output/cards/, 01_Projects/ |
| 长文12-第一性原理思考入门.md | 3 | 同上 |
| 长文15-复利思维在生活中的迁移应用.md | 3 | 同上 |
| 长文27-内容创作的100篇定律.md | 3 | 同上 |
| 长文57-焦虑的数学公式.md | 3 | 同上 |
| 长文73-代谢综合征不是一种病.md | 3 | 同上 |
| 长文81-价值投资的认知基础.md | 3 | 同上 |
| 长文94-人类误判心理学的25个Bug.md | 3 | 同上 |
| 长文100-达利欧的机器视角.md | 3 | 同上 |
| 长文03-资产vs负债.md | 3 | 同上 |
| NIGHT_LOG.md | 2 | root/, _logs/ |
| SKILL.md | 2 | .codex/skills/, root/ |
| 00-07.md | 2ea | 学习序列副本 |

**处置建议**：逐组确定canonical（通常cards/为主），合并后归档副本。需人工确认内容一致性后执行。
