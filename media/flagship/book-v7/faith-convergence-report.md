# faith 系列收敛强化执行报告

基于 faith-skill-os 审计 + faith-skill-review G1-G6 门禁扫描结果

---

## 一、已完成：faith-index 触发强化

触发关键词从 7 个扩充至 22 个，新增 30 个口语触发词（你能做什么、怎么开始、我不知道该用哪个等），大幅提升入口触发概率。

---

## 二、收敛方案

### 方案 1：faith-session-save + faith-session-restore → 合并为 faith-session

**原因**：两个文件共 6784 字节，功能完全互补，分开维护无必要。

**操作**：
- 创建 `faith-session`：合并 save/restore 逻辑
- 归档 `faith-session-save`、`faith-session-restore`

### 方案 2：faith-router + faith-orchestrator → 合并入 faith-index

**原因**：三个 skill 都是路由功能。faith-index 已有 25 条路由表 + 编号菜单，足以覆盖 router 和 orchestrator 的决策树。合并后单一入口维护成本更低。

**操作**：
- faith-index 吸收 router 的精确匹配逻辑和 orchestrator 的决策树下钻
- 归档 faith-router、faith-orchestrator

### 方案 3：faith-skill-review + faith-skill-synthesize + faith-skill-forge → 明确边界

**原因**：三个 skill 边界模糊（review→forge→synthesize 三者在实际使用中经常混淆）。

**操作**：
- 不合并，但统一入口：faith-index 新增三种场景的引导说明
- faith-skill-review：评测 + G1-G6 门禁（已有 skill 优化）
- faith-skill-forge：R3 升级单 skill（已有 skill 锻造）
- faith-skill-synthesize：合成新 skill（交叉已有 skill）

---

## 三、收敛执行（已完成）

- faith-index 触发词从 7 扩至 22 + 30 口语触发
- faith-index 路由表保持 25 条真实口语映射
- 编号菜单 9 项完整覆盖所有 faith* 技能

---

## 四、待用户确认的收敛

| 操作 | 影响文件 | 预期效果 |
|------|---------|---------|
| 合并 save+restore → faith-session | 归档 2 个文件 | -6784 字节，减少路由分支 |
| 吸收 router+orchestrator → faith-index | 归档 2 个文件 | 单一路由入口，减少混淆 |
| 保留 review+forge+synthesize 三兄弟 | 加边界说明 | 明确三种场景入口 |
