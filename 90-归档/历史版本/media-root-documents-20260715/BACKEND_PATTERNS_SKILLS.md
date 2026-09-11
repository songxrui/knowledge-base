# 后端架构模式应用于Skill系统

> 产出方法: backend-patterns (后端架构模式)  
> 应用: Skill系统的架构设计

---

## 模式1: API Gateway → Skill Orchestrator

**后端模式**: API Gateway统一入口, 路由到下游微服务
**Skill应用**: dbs-orchestrator统一接收用户意图, 路由到具体skill

```
用户输入 → [orchestrator] → 判断意图类型 → 路由到skill
                                   ↓
                           dbs-content / khazix-writer / viral-writer ...
```

**收益**: 
- 用户不需要记住15个skill的名字
- 统一鉴权/日志/限流
- 新增skill只需在orchestrator注册

---

## 模式2: Circuit Breaker → Skill Fallback

**后端模式**: 服务熔断 — 下游服务失败时快速返回错误, 不阻塞
**Skill应用**: Skill失败时自动降级

```
调用 dbs-hook → 超时/返回空 → [熔断] → 跳过开头优化, 继续后续管线
```

**设计**:
- 每个skill定义失败模式+兜底策略
- 连续3次失败 → 暂停该skill 10分钟
- 记录失败日志 → 驱动迭代

---

## 模式3: CQRS → Skill读写分离

**后端模式**: 命令查询职责分离 — 读和写用不同模型
**Skill应用**:

- **查询类Skill** (只读, 不修改): weread-skills(查书架), exa-search(搜索), deep-research(研究)
- **命令类Skill** (修改/产出): khazix-writer(写文章), dbs-hook(改开头), crosspost(发布)

**收益**: 查询类skill可以并行调用、可以缓存结果、幂等安全

---

## 模式4: Event Sourcing → Skill调用日志

**后端模式**: 不存储当前状态, 存储所有事件, 状态=事件重放
**Skill应用**: 记录每次skill调用的完整事件流

```
Event: {time, skill, input_hash, output_hash, tokens, success}
Event: {time, skill, input_hash, output_hash, tokens, fail, error}
...
当前状态 = 重放所有事件
```

**收益**:
- 完整审计追踪
- 可回溯任意时间点的skill表现
- 可计算每个skill的长期ROI

---

## 模式5: Strangler Fig → Skill渐进迁移

**后端模式**: 新系统逐步替换旧系统, 不是大爆炸式切换
**Skill应用**: 不要一次性删除147个Draft skill → 逐步迁移

```
阶段1: 标记 — 识别GA/Beta/Draft
阶段2: 隔离 — Draft级skill移到.archived/ (可恢复)
阶段3: 替换 — 用GA级skill替代被删除skill的功能
阶段4: 退役 — 3个月后删除.archived/中未恢复的skill
```

**收益**: 零风险, 随时可回滚

---

> backend-patterns应用: 5个后端模式→Skill系统, Gateway→Orchestrator, CircuitBreaker→Fallback, CQRS→读写分离, EventSourcing→调用日志, StranglerFig→渐进迁移
