# Skill 删除计划 — 先想后动

> 2026-06-12 | 基于依赖分析 | 风险最小化原则

---

## 一、删除原则

1. 零交叉引用（无其他 Skill 引用它）
2. 领域无关（与用户董辉的内容创作/知识库/Skill工程工作流无关）
3. 体积大（>10KB）优先删除（释放更多上下文空间）
4. 删除前备份到 `.archived/`，可随时恢复

---

## 二、安全删除清单（13 个 Skill，零引用，319KB）

| # | Skill | 大小 | 领域 | 为什么安全 |
|---|-------|------|------|-----------|
| 1 | hatch-pet | 36.6KB | 宠物相关 | 无引用，用户无宠物业务 |
| 2 | playwright-interactive | 31.1KB | Playwright交互 | 无引用，用户不做E2E交互测试 |
| 3 | windows-desktop-e2e | 30.9KB | Windows桌面测试 | 无引用，用户不做桌面E2E |
| 4 | quality-nonconformance | 30.1KB | 制造业质量 | 无引用，行业完全无关 |
| 5 | energy-procurement | 29.8KB | 能源采购 | 无引用，行业完全无关 |
| 6 | customs-trade-compliance | 28.8KB | 海关贸易 | 无引用，行业完全无关 |
| 7 | returns-reverse-logistics | 24.5KB | 逆向物流 | 无引用，行业完全无关 |
| 8 | inventory-demand-planning | 24.4KB | 库存计划 | 无引用，行业完全无关 |
| 9 | carrier-relationship-management | 23.6KB | 承运商管理 | 无引用，行业完全无关 |
| 10 | chatgpt-apps | 19.3KB | ChatGPT Apps | 无引用，内容过时 |
| 11 | logistics-exception-management | 16.9KB | 物流异常 | 无引用，行业完全无关 |
| 12 | mysql-patterns | 12.4KB | MySQL | 无引用，用户不用MySQL |
| 13 | winui-app | 11.2KB | WinUI桌面开发 | 无引用，用户不做WinUI |

**释放总量：319KB（0.31MB）上下文空间。**

---

## 三、暂不删除（7 个 Skill，有交叉引用）

| # | Skill | 大小 | 引用者数 | 保留原因 |
|---|-------|------|---------|---------|
| 1 | continuous-learning-v2 | 13.4KB | 4 | agent-introspection-debugging/configure-ecc/skill-stocktake/strategic-compact 引用 |
| 2 | continuous-learning | 4.7KB | 5 | iterative-retrieval/连续学习v2/skill-stocktake/strategic-compact 引用 |
| 3 | perl-security | 14.1KB | 1 | prompt-optimizer 引用 |
| 4 | quarkus-security | 12.5KB | 2 | configure-ecc/prompt-optimizer 引用 |
| 5 | django-security | 16.2KB | 2 | configure-ecc/prompt-optimizer 引用 |
| 6 | clickhouse-io | 10.8KB | 3 | configure-ecc/postgres-patterns/mle-workflow 引用 |
| 7 | videodb | 14.3KB | 2 | fal-ai-media/video-editing 引用 |

**处理方案**：先更新引用者 Skill，移除对这些 Skill 的引用，再删除。本轮暂不处理。

---

## 四、执行步骤

### Step 1：备份（防误删）
```powershell
# 创建归档目录
New-Item -ItemType Directory "C:\Users\董辉\.codex\skills\.archived" -Force
# 移动每个 Skill 到归档
Move-Item "C:\Users\董辉\.codex\skills\<name>" "C:\Users\董辉\.codex\skills\.archived\"
```

### Step 2：验证
- 确认归档目录中存在备份
- 确认原位置已删除
- 扫描其他 Skill 无断裂引用

### Step 3：Git 提交
- 知识库仓库记录变更
- 标注删除原因和可恢复路径

### 回滚方案
```powershell
Move-Item "C:\Users\董辉\.codex\skills\.archived\<name>" "C:\Users\董辉\.codex\skills\"
```

---

## 五、不执行的删除类型

- **重复 Skill 去重**：需要比较版本再决定保留哪个，本轮不做
- **有引用的 Skill**：需要级联更新引用者，风险较高，本轮不做
- **小体积 Skill（<10KB）**：删除收益低，投入产出比差，本轮不做

---

## 六、预期效果

| 指标 | 删除前 | 删除后 | 改善 |
|------|--------|--------|------|
| Skill 总数 | 413 | 400 | -13 |
| 总 SKILL.md 体积 | ~3.2MB（估） | ~2.9MB | -319KB |
| 零引用行业 Skill | 13 | 0 | 清零 |
| 断裂引用 | 0 | 0 | 无影响 |

---

> 分析依据：交叉引用全量扫描（413 Skill × 20 候选）
> 风险评级：全绿（13 个候选均为零引用 × 领域无关 × 可回滚）