# Skill 生态系统全景连接图 v1.0
> 基于 270+ skill 的深度模式合成

## 生态层

`
┌─────────────────────────────────────────────────────────────┐
│                    skill-os (操作系统)                        │
│                   skill-auditor (审计)                        │
├─────────────────────────────────────────────────────────────┤
│ 诊断层              工程层              内容层               │
│ dbs-orchestrator    agentic-engineering  content-alchemist   │
│ dbs-agent-mesh      ai-first-engineering content-diffusion   │
│ 15 dbs skills       3 ECC skills        8 content skills     │
├─────────────────────────────────────────────────────────────┤
│ 平台层              基础设施层          方法论层              │
│ feishu/documents     skill-forge         r3-playbook         │
│ spreadsheets/ppt     skill-creator       compile-and-verify  │
│ baoyu-* (8)         skill-deployer      eval-harness        │
│ crosspost           release-skills      v4-best-practices   │
├─────────────────────────────────────────────────────────────┤
│ 持久化层            安全层              多媒体层             │
│ dbs-save/restore    security-review     baoyu-image-gen      │
│ session-memory      security-scan       fal-ai-media         │
│ nanoclaw-repl       security-threat     video-editing        │
└─────────────────────────────────────────────────────────────┘
`

## 关系类型

- → 调用/路由
- ↔ 双向配合
- ↑ 产出到上层
- ↓ 为下层提供基础

## 核心链路

1. **内容生产链路**: dbs-content-system → content-diffusion-engine → 平台skills
2. **诊断决策链路**: dbs-orchestrator → dbs-diagnosis → dbs-decision → dbs-action
3. **Skill 进化链路**: skill-review → skill-forge → skill-deployer → release-skills
4. **工程执行链路**: agentic-engineering → compile-and-verify → continuous-agent-loop