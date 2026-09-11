# API设计原则应用于Skill接口

> 产出方法: api-design (REST API设计模式)  
> 应用对象: Skill的调用接口设计  
> 核心观点: Skill的description/metadata就是它的"API规范"

---

## 原则1: 资源命名清晰

**API原则**: REST资源用名词, 集合用复数 `/users/{id}`
**Skill应用**: Skill名称应该表达"做什么", 不是"是什么"
- ❌ `skill-review` (名词, 语义模糊)
- ✅ `audit-skill-quality` (动词+名词, 语义清晰)

Anthropic说: "Pay special attention to the name and description" — 名称是Agent的第一个路由信号。

---

## 原则2: 错误响应规范

**API原则**: 返回明确的错误码和可操作的错误信息
**Skill应用**: SKILL.md应包含失败模式+兜底策略

```
## 失败模式
| 场景 | 原因 | 兜底 |
|------|------|------|
| 输入内容不足600字 | 无法提取有效素材 | 提示用户补充 |
| 外部API超时 | 网络问题 | 使用本地缓存 |
| 匹配到不适用的内容 | 触发条件太宽 | 返回"不适用, 建议用X skill" |
```

SkillsBench: 19%的skill有负面效果 — 缺少失败模式处理是主要原因之一。

---

## 原则3: 版本化

**API原则**: `/v1/users` — 版本号在URL中, 不破坏旧客户端
**Skill应用**: CHANGELOG.md + git版本控制

- 每次修改description(影响路由) → 必须记录
- 每次修改核心流程(影响输出) → 必须记录+测试更新
- 大版本变更 → 考虑新skill替代旧skill(v2 directory)

.codex中3.3%的skill没有.git — 这相当于API没有版本号, 调用者永远不知道返回结果为什么变了。

---

## 原则4: 幂等性

**API原则**: 同一个请求多次调用结果相同
**Skill应用**: Skill应该是不依赖状态的纯函数

- ❌ "根据上次的结果继续优化" (依赖上次状态)
- ✅ "根据提供的输入内容进行优化" (纯函数)

纯函数式skill可并行调用、可缓存结果、可A/B测试。

---

## 原则5: 限流与成本透明

**API原则**: 返回Rate-Limit头, 让调用者知道剩余配额
**Skill应用**: TOOL_LEDGER + 调用频率统计

- 记录每次skill调用的token消耗
- 标记高消耗skill(>2000 tokens/次)
- 提供替代方案(精简版 vs 完整版)

---

## Skill的"API文档"模板

```yaml
# Skill API Spec
name: skill-name
version: 1.0.0
description: "做什么 + 触发词 + 不适用场景 + 正反例"

# 输入(Input Schema)
input:
  required: [content, target_platform]
  optional: [tone, max_length]

# 输出(Output Schema)
output:
  type: markdown
  fields: [title, body, metadata]

# 失败模式(Failure Modes)
errors:
  - code: INPUT_TOO_SHORT
    message: "内容不足600字"
    recovery: "提示用户补充"

# 性能(Performance)
cost:
  avg_tokens: 500
  max_tokens: 2000
  cacheable: true
```

---

> api-design应用: 5条REST API原则 → Skill接口设计, 核心: description是API规范, 失败模式是错误响应, 版本化是API版本管理
