# 可执行摘要 — 给只想看这一篇的人

> 产出方法: 极限压缩 (1页)  
> 对象: 没有时间看75个文件的人

---

# 我审计了846个AI Skill。99%是草稿。

**一句话**: 846个skill实例 → 去重后147个 → 产品级7个。74%在Agent面前隐身。3.3%有版本控制。选错一个skill比不用更差。

## 三个数字

| 数字 | 含义 | 来源 |
|:---:|------|------|
| 4.8% | GA级skill比例 | 本地审计 |
| 31-44pp | 路由精度下降(缺触发词) | SkillRouter论文 |
| -0.28 | 最差skill的拖累 | OpenSkillEval |

## 三个动作

1. **补触发词**(5min/skill): description加4-8个词 → 匹配率47%→81%
2. **删坏skill**(1h): 识别Δ<0的 → 移到.archived/
3. **建编排层**(3h): orchestrator统一路由 → 用户不直接面对50个skill

## 外部验证

- Anthropic官方: Skill需三层结构(metadata+body+references)
- SkillsBench: 精选skill +16.2pp / 自生成 -1.3pp
- OpenSkillEval: 选错skill < 不用skill (Data领域6个skill无一超基线)

## 这篇文章就是证明

22-skill协同产出75个文件。不是你"想想就写" — 是每个skill留下了可追溯的证据链。

**下一步**: 清理Draft → 建orchestrator → 并行管线

---
> 完整版: MASTER_INDEX.md | GitHub: songxrui/knowledge-base
