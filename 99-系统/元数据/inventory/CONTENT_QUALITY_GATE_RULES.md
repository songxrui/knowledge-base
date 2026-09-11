# 内容质量门禁规则

> 版本：1.6  
> 生效日期：2026-07-19  
> 执行脚本：`99-系统/脚本/audit_content_quality.ps1`

## 范围

门禁扫描活跃 Markdown、文本、配置和脚本文件。以下内容不参与发布门禁：Git/Obsidian/Agent 运行目录、`90-归档/`、第三方依赖与构建缓存、职责区内的 `00-缓冲区/`、创作者原始素材、Notion 原始归档和冻结来源版 `book-v7`。排除不代表内容已验证；它们由来源、缓冲或归档台账治理，提升到正式层前必须单独运行人工审核。

## 严重级别

| 级别 | 行为 | 规则 |
|---|---|---|
| P0 | 脚本退出码为1，阻断进入活跃区 | 明文凭据、NUL、非法控制字符、重复 canonical id、blocked 文档进入已发布或旗舰路径 |
| P1 | 输出文件、行号和证据；需要人工处理或登记误报 | canonical 缺少稳定 id、本地断链、重复长段落、旧路径、未标记案例、无来源精确数字、绝对词 |
| P2 | 只报告，不阻断 | 预留给表达和维护提示 |

P0 为0只说明机器阻断项没有命中，不代表文档事实已经完成审核。P1 允许存在，但新增大文档必须解释命中原因并在批次记录中给出 `fix`、`accept` 或 `archive` 决定。

## 误报处理

1. 不通过修改正则来隐藏单个真实问题；先修正文档或归档错误版本。
2. 确认是误报时，在规则文档登记原因和最窄排除范围。
3. `source:`、`superseded_by:` 和纯 Wiki 索引行只是路径或导航，不作为绝对主张；正文中的同名说法仍检查。
4. `L10 元规则`、`CH1元能力` 一类标识符只删除精确的 `L/CH + 数字 + 元 + 中文词` 片段后再扫描；`ROI10%`、`USD100元` 和 `x10倍` 仍检查。
5. 文档同时具备 `status: blocked`、`canonical: false` 与 `evidence_level: unverified-product-hypothesis` 时，将多条数字压缩成一个文档级 P1；若它进入已发布或旗舰路径，立即升级为 P0。
6. `00-规则与索引/`、`04-模板/`、字段规范、用户案例规范和案例库标题不等于案例叙述；真正的案例标题仍需身份标签。
7. 前后改写证据只有同时具备 `status: retained-before-rewrite-evidence`、`canonical: false`、`duplicate_policy: intentional-before-after` 和非空 `superseded_by` 时，才不参与重复段落告警。
8. 绝对词按每个匹配项判断否定或禁写语境，不因同一行其他位置出现“不”而整体豁免。
9. Markdown 标题开头的章节编号（如 `8.2 用户案例`）不按“精确数字 + 用户”扫描；标题正文中的比例、金额和结果数字仍正常检查。
9. 精确数字的来源或身份标记按 Markdown 空行分隔的真实段落检查，不只检查单行。
10. 只有位于 `08-媒体与产品/视频/` 且同时标记 `content_role: production-design-spec` 与 `number_policy: design-parameter` 的生产规格，才把透明度、尺寸和版式比例视为设计参数。
11. 原始资料、冻结来源和归档使用目录级排除；其内容不得直接进入发布层。
12. 数字是实验参数、库存快照或版本日期时，应在同段标明身份，而不是加入全局白名单。
13. 案例身份只能是作者真实经历、可追溯公开案例、合成案例、模拟案例或寓言。
14. `canonical: true` 必须同时提供非空且稳定的 `id`；缺失 id 记 P1，重复 id 记 P0。没有 id 的 canonical 文档不得静默退出冲突检查。
15. `test-results/`、`playwright-report/` 和 `blob-report/` 是自动测试产物目录，不参与内容重复检测；人工编写的测试和项目文档仍参与扫描。
16. `docs/evidence/**/test-output.txt` 与 `failure-case-output.txt` 是原始终端证据；只在控制字符检查前移除符合 ANSI CSI 语法的着色序列。原文件字节和 `run.json` 输出哈希保持不变；NUL、非 ANSI 控制字符及其他路径中的 ESC 仍为 P0。

## 历史基线

- 旧主题地图：524 个 Wiki 链接，旧快照全部无法解析。
- 元能力高风险主张：旧计划记录341行；按 2026-07-18 可复现规则重建为343行，差异来自补入绝对效果词。
- 凭据：当前工作树已脱敏；Git 历史和服务端轮换状态见 `CREDENTIAL_ROTATION_RECORD_2026-07-17.md`。
- canonical 冲突：旧版状态已由归档映射和 `SOURCE_OF_TRUTH.md` 接管。

使用以下命令校验仍可保留的历史基线证据：旧主题地图会重新解析断链；元能力冻结台账会检查唯一 claim id 和必填字段；凭据历史只复述已登记的位置计数，不替代专用 secret scanner：

```powershell
pwsh -NoProfile -File '99-系统\脚本\audit_content_quality.ps1' -Root 'D:\KnowledgeBase' -BaselineReplay
```

## 每批验收

```powershell
pwsh -NoProfile -File '99-系统\脚本\audit_content_quality.ps1' -Root 'D:\KnowledgeBase'
```

检查 `CONTENT_QUALITY_GATE_LATEST.md` 和同名 CSV。P0 必须为0；P1 新增量必须逐项解释。
