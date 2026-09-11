# 执行前安全审查 — Skill生态建设计划的安全性

> 产出方法: preflight-reviewer (执行前计划边界+风险审查)  
> 审查对象: Skill生态优化计划 (G1-G5)  
> 规则: BLOCKER立即阻断, WARNING批量输出

---

## 计划审查

### G1: 补齐30个核心skill触发词

**边界检查**: ✅ 在现有文件内修改, 不新建目录
**命令权限**: ✅ 纯文本编辑, 无shell危险操作
**数据风险**: ⚠️ WARNING — description修改可能改变Agent行为, 建议先在3个skill上测试

### G2: .codex skill git初始化

**边界检查**: ✅ 在.codex目录内
**命令权限**: ✅ git init + commit
**数据风险**: ✅ 无风险, git init不修改文件内容

### G3: 清理有害skill

**边界检查**: ⚠️ WARNING — 删除/移动文件, 可能影响现有Agent配置
**命令权限**: ✅ git mv操作 (可回滚)
**数据风险**: ⚠️ WARNING — 建议先移到.archived/而非直接删除, 观察1个月再决定

### G4: 建编排层

**边界检查**: ✅ 新建文件, 不影响现有skill
**命令权限**: ✅ 纯文本编辑
**数据风险**: ✅ 无风险, orchestrator是新增文件

### G5: 管线稳定性验证

**边界检查**: ✅ 只读测试, 不修改现有文件
**命令权限**: ✅ 纯文本编辑
**数据风险**: ✅ 无风险

---

## 整体风险评估

**BLOCKER**: 0项
**WARNING**: 2项 (G1 description变更需测试, G3 删除需先归档)

**结论**: 计划可执行。G1和G3各加一步安全措施后即可启动。

---

## 执行前checklist

- [ ] G1: 先在3个skill上测试description修改效果
- [ ] G3: 所有删除操作使用 `git mv → .archived/`, 不直接 `rm`
- [ ] G2: .gitignore配置(排除node_modules等)
- [ ] G4: orchestrator SKILL.md需要标注测试状态
- [ ] G5: 测试结果记录在EVIDENCE.md

---

> preflight-reviewer方法: 计划边界→命令权限→数据风险→BLOCKER/WARNING→执行前checklist
