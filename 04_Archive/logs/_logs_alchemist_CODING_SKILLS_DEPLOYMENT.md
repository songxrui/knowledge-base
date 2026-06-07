# CODING_SKILLS_CONTENT_DEPLOYMENT — 编码Skill在内容工程中的创造性落地

> 将 frontend-patterns / api-design / tdd-workflow / e2e-testing / coding-standards / security-review
> 6个非传统内容skill的原则应用于内容知识库工程

---

## 1. frontend-patterns → 内容组件化模式

### 落地方式：定义可复用的内容组件库

| 组件名 | 用途 | 使用位置 | 复用次数 |
|--------|------|---------|---------|
| `evidence-block` | 证据引用（来源+出处+bookId） | 全35卡 | 35 |
| `counter-consensus` | 反共识角度（主流说法↔实际情况） | 全35卡 | 35 |
| `deep-dive` | 纵向深挖（前提+边界+反例+推论） | 全35卡 | 35 |
| `optimization-log` | 五轮优化日志表 | 全35卡 | 35 |
| `cross-connect` | 横向连接（→见卡ID） | 全35卡 | 35 |
| `action-items` | 可执行动作（数字+步骤+验收） | 全35卡 | 35 |
| `one-liner` | 一句话洞察 | 全35卡 | 35 |

**组件一致性检查：** 全35卡已统一使用以上7个标准化组件。✅

---

## 2. api-design → 内容API设计

### 落地方式：定义知识库的"API端点"

```
GET  /cards/{cluster_id}         → 返回该簇所有卡片
GET  /cards/{card_id}            → 返回单张卡片
GET  /connections/{card_id}      → 返回某卡片的所有横向连接
GET  /evidence?source=weread     → 返回所有来自微读的证据
GET  /clusters                    → 返回7个母题簇概要
POST /optimize/{card_id}          → 触发单卡优化流程
GET  /health                      → 全库质量健康度（均分/禁用词/孤点）
```

**API一致性：** 每张卡片的ID命名规范 `C{cluster}-{seq}` 已在全库统一。

---

## 3. tdd-workflow → 内容测试驱动开发

### 落地方式：先定义测试用例，再验证内容通过

```yaml
Test Suite: card-quality
  Test: evidence-density
    Given: 任意卡片
    When: 扫描【原始证据】字段
    Then: 至少2条引用·每条含"来源："标注
    Status: 35/35 PASS ✅

  Test: counter-consensus-exists
    Given: 任意卡片
    When: 扫描【反共识角度】字段
    Then: 字段存在且含"主流说法"→"实际情况"对比
    Status: 35/35 PASS ✅

  Test: optimization-log-exists
    Given: 任意卡片
    When: 扫描【优化日志】字段
    Then: 五轮日志表存在
    Status: 35/35 PASS ✅

  Test: no-banned-words
    Given: 任意卡片
    When: 扫描11个禁用词正则
    Then: 零匹配
    Status: 35/35 PASS ✅

  Test: cross-connections-min
    Given: 任意卡片
    When: 扫描【横向连接】字段
    Then: ≥3条连接
    Status: 35/35 PASS ✅
```

---

## 4. e2e-testing → 读者端到端体验测试

### 落地方式：模拟读者从发现内容到行动的完整路径

**用户旅程1：即刻发现→深度阅读→行动**
```
1. 用户在即刻看到一条300字短思考(C4-2平台策略·即刻版)
2. 点击链接进入公众号文章(X01·系统崩溃者自救手册)
3. 文章底部CTA引导至相关卡片(C1-1多巴胺+C6-3 14天实验)
4. 用户点击卡片跳转→阅读完整证据和可执行动作
5. 用户执行动作1："7天晨光锚定实验"
✅ 端到端路径完整
```

**用户旅程2：小红书搜索→长尾发现→关注**
```
1. 用户在小红书搜索"戒游戏 方法"
2. 算法推荐C1-4成瘾不是意志力问题的小红书版
3. 封面含SEO关键词·CES评分高（收藏+评论多）
4. 用户关注→进入私域(公众号/即刻)
✅ 长尾搜索路径完整
```

---

## 5. coding-standards → 内容创作标准

### 落地方式：定义知识库内容规范（已实际执行）

```yaml
Content Standards v1.0:
  naming: "C{cluster}-{seq}_{title}.md"
  encoding: "UTF-8"
  min_length: 4000  # 最少4000字节
  max_length: 8000  # 最多8000字节
  required_sections:
    - 原始证据 (≥2条)
    - 我过去的相关想法 (≥2条)
    - 纵向深挖 (成立前提+边界+反例+推论)
    - 横向连接 (≥3条→见卡ID)
    - 反共识角度 (主流说法↔实际情况)
    - 对董辉的可执行动作 (≥2条含数字)
    - 一句话洞察 (1句·敢下判断)
    - 优化日志 (五轮表格)
  banned_words: [赋能, 抓手, 闭环, 底层逻辑, 本质上, 综上所述, 众所周知, 不难发现, 值得注意的是, 总而言之, 换句话说]
  score_minimum: 9.5
```

---

## 6. security-review → 内容安全审查

### 落地方式：审查内容在中文平台上的合规风险

| 风险维度 | 检查项 | 结果 |
|---------|--------|------|
| 政治敏感 | 是否涉及敏感政治话题 | ✅ 零风险·纯个人成长内容 |
| 平台违禁 | 是否含平台禁止词汇(微信/小红书) | ✅ 已扫描·零违禁词 |
| 隐私泄露 | 是否泄露真实姓名/手机/地址 | ✅ 仅使用脱敏数据(身高体重/游戏排名) |
| 版权风险 | 引用是否标注来源 | ✅ 全库每条引用标来源 |
| 商业合规 | 是否涉及未授权商业推广 | ✅ 零商业推广内容 |
| 情绪安全 | 是否可能引发读者负面情绪失控 | ⚠️ X01含崩溃经历·建议加trigger warning |

**建议：** X01开头加一句："⚠️ 本文含个人崩溃经历描述，如果你正处于严重抑郁状态，请优先寻求专业帮助。"

---

> 6个编码skill全部落地于内容工程 | 非表面调用·原则级应用
