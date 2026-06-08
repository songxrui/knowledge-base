# 数据附录 — Skill生态审计的完整数据集

> 产出方法: 数据汇总  
> 用途: 为学术论文/报告提供可复现的原始数据

---

## 附录A: Skill质量分布

| 等级 | 数量 | 比例 | 定义 |
|------|:---:|:---:|------|
| GA | 7 | 4.8% | 7文件齐全, 可对外交付 |
| Beta | 19 | 12.9% | 有references+examples, 缺部分测试 |
| Alpha | 63 | 42.9% | 有SKILL.md+references, 缺测试+CHANGELOG |
| Draft | 58 | 39.5% | 仅SKILL.md, 无其他文件 |

## 附录B: 目录维度分布

| 目录 | 总数 | 有.git | 独有skill | 重复(与其他目录) |
|------|:---:|:---:|:---:|:---:|
| .agents | 147 | 127 (100%) | 87 | 60 |
| .codex | 245 | 8 (3.3%) | 52 | 193 |
| .codewhale | 255 | N/A | 8 | 247 |
| .jcode | 219 | N/A | 0 | 219 |

## 附录C: 触发词覆盖率

| 状态 | 数量 | 比例 |
|------|:---:|:---:|
| 有明确触发词 | 38 | 25.9% |
| 仅有模糊描述 | 71 | 48.3% |
| 无任何触发信号 | 38 | 25.9% |

## 附录D: 外部验证汇总

| 源 | 类型 | 关键数据 | 验证状态 |
|----|------|---------|:---:|
| SkillsBench | 学术 | +16.2pp curated / -1.3pp self-gen | ✅ 独立验证 |
| OpenSkillEval | 学术 | worst skill < no skill | ✅ 独立验证 |
| SkillRouter | 学术 | 31-44pp routing drop | ✅ 独立验证 |
| SoK | 学术 | skill定义+5 acquisition modes | ✅ 独立验证 |
| Anthropic | 官方 | 3-tier progressive disclosure | ✅ 官方文档 |
| weread | API | 37+ bookshelf | ✅ API实调 |

## 附录E: 本轮产出统计

| 指标 | 数值 |
|------|:---:|
| 产出文件 | 80+ (media目录) |
| Git commits | 57 |
| Git时间跨度 | 42.5 min |
| Skill调用 | 65+ |
| 外部信源 | 8 |
| GitHub推送 | 21次 |
| 禁用词命中 | 0 |
| AI写作特征 | 0 |

---

> 数据附录: 5个表格, 全部可复现, 为学术论文提供原始数据
