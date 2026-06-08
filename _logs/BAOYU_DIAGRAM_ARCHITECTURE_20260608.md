# baoyu-diagram 架构图 | Skill生态 + 内容创作管线

> 使用skill: baoyu-diagram (专业深色SVG图表/Mermaid)
> 时间: 2026-06-08

---

## 图1: Skill生态系统架构图

```mermaid
graph TB
    subgraph "用户层"
        U[用户输入]
    end
    
    subgraph "编排层"
        O[dbs-orchestrator<br/>路由中枢]
        CA[content-alchemist<br/>内容管线]
        KF[knowledge-forge<br/>知识锻造]
    end
    
    subgraph "诊断层"
        DC[dbs-content<br/>全周期诊断]
        CTA[content-auditor<br/>5关审计]
        HZ[humanizer-zh<br/>去AI味]
    end
    
    subgraph "创作层"
        KW[khazix-writer<br/>长文]
        VW[viral-writer<br/>多平台]
        LW[ljg-writes<br/>深挖]
    end
    
    subgraph "信源层"
        WR[weread-skills<br/>读书数据]
        EX[exa-search<br/>外部验证]
        NT[Notion<br/>本地笔记]
    end
    
    subgraph "验证层"
        CV[compile-and-verify<br/>编译验证]
        CTL[content-truth-lock<br/>真实性锁]
        SO[skill-overseer<br/>监工]
    end
    
    subgraph "发布层"
        CP[crosspost<br/>多平台分发]
        BW[brand-voice<br/>声音一致性]
    end
    
    U --> O
    O --> DC
    O --> WR
    WR --> KF
    KF --> DC
    DC --> KW
    DC --> VW
    KW --> HZ
    VW --> HZ
    HZ --> CTA
    CTA --> CV
    CV --> CTL
    CTL --> CP
    CP --> BW
    SO -.-> CV
    SO -.-> CTL
```

---

## 图2: 本轮Skill调用流程图

```mermaid
flowchart LR
    A[skill-overseer<br/>基线] --> B[dbs-content<br/>诊断2篇]
    B --> C[humanizer-zh<br/>AI味扫描]
    C --> D[content-auditor<br/>5关审计]
    D --> E[dbs-hook<br/>开头优化]
    E --> F[weread-skills<br/>3次API]
    F --> G[exa-search<br/>外部验证]
    G --> H[brand-voice<br/>声音画像]
    H --> I[ljg-card<br/>知识卡片]
    I --> J[knowledge-forge<br/>管线锻造]
    J --> K[viral-writer<br/>三平台]
    K --> L[dbs-chatroom<br/>4专家会诊]
    L --> M[content-alchemist<br/>全管线]
    M --> N[ljg-think<br/>6层深钻]
    N --> O[dbs-deconstruct<br/>5变量拆解]
    O --> P[content-truth-lock<br/>10主张验证]
    P --> Q[compile-and-verify<br/>终验]
    Q --> R[skill-overseer<br/>终检]
```

---

## 图3: 内容管线状态图

```mermaid
stateDiagram-v2
    [*] --> 信源提取: weread+exa
    信源提取 --> 内容结构化: dbs-content-system
    内容结构化 --> 创作: khazix-writer
    创作 --> 去AI味: humanizer-zh
    去AI味 --> 审计: content-auditor
    审计 --> 验证: compile-and-verify
    验证 --> 发布: Gate全绿
    验证 --> 返工: Gate未过
    返工 --> 创作: 修复问题
    发布 --> [*]
    
    note right of 信源提取: ✅ 已完成<br/>3次API+1次搜索
    note right of 审计: ⚠️ Gate3缺封面<br/>Gate4缺复现
```

---

## 图4: 本轮产出文件分类占比

```mermaid
pie title 32文件分类分布
    "深层分析" : 9
    "管线工作流" : 4
    "诊断审计" : 4
    "信源验证" : 3
    "内容优化" : 3
    "视觉设计" : 3
    "决策存档" : 3
    "索引报告" : 3
```
