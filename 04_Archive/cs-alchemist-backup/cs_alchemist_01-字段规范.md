# 内容单元字段规范

## 必填字段

| 字段 | 类型 | 说明 | 示例 |
|---|---|---|---|
| id | string | 唯一标识 `{域}-{序号}-{类型}` | `cog-001-concept` |
| title | string | 内容单元标题（一句话核心观点） | "元认知是观察自己思维的能力" |
| source_file | string | 来源文件相对路径 | `cognition/长文02-三重大脑与元认知.md` |
| domain | string | 所属内容域 | `cognition` |
| type | enum | concept/opinion/case/solution/question/quote/data | `concept` |
| core_claim | string | 核心主张（一句话） | — |
| created | date | 抽取日期 | `2026-06-05` |

## 可选字段

| 字段 | 类型 | 说明 |
|---|---|---|
| tags | list | 标签 |
| related_units | list | 关联内容单元ID |
| evidence_level | enum | source_attributed/inferred/personal_experience/assumed |
| publishability | enum | ready/needs_factcheck/needs_rewrite/draft_only |
| platform_fit | list | xiaohongshu/douyin/gongzhonghao/x |
| persona | enum | teacher/explorer/friend/challenger/curator |

## 内容类型定义

- **concept**: 概念/定义/理论解释
- **opinion**: 主观观点/判断/立场
- **case**: 案例/故事/实例
- **solution**: 方法/步骤/框架/解决方案
- **question**: 好问题/引导性问题
- **quote**: 引用/名言
- **data**: 数据/统计/研究结果
