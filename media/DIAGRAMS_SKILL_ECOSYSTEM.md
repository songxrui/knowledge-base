# Skill生态审计 — 可视化图表

> 产出方法: baoyu-diagram (专业SVG图表) → Mermaid文本规范  
> 用途: 配合文章使用, 可直接渲染为SVG/PNG

---

## 图表1: Skill质量金字塔

```mermaid
graph TD
    subgraph "846个Skill实例 (4目录扫描)"
        A[.agents 147] 
        B[.codex 245]
        C[.codewhale 255]
        D[.jcode 219]
    end
    
    A --> E[去重: 358个唯一名称]
    B --> E
    C --> E
    D --> E
    
    E --> F[筛选: 147个有意义]
    
    F --> G["GA级 (产品标准): 7个 (4.8%)"]
    F --> H["Beta级: 19个 (12.9%)"]
    F --> I["Alpha级: 63个 (42.9%)"]
    F --> J["Draft级: 58个 (39.5%)"]
    
    style G fill:#00d4ff,color:#000
    style H fill:#4ecdc4,color:#000
    style I fill:#ffe66d,color:#000
    style J fill:#ff6b6b,color:#fff
```

---

## 图表2: Skill管线 — 从审计到发布 (22-skill chain)

```mermaid
graph LR
    A[skill-review-master<br/>评测] --> B[dbs-content-system<br/>结构化]
    B --> C[khazix-writer<br/>长文]
    C --> D[dbs-hook<br/>开头优化]
    D --> E[brand-voice<br/>声音校准]
    E --> F[exa-search<br/>库外验证]
    F --> G[viral-writer<br/>病毒分析]
    G --> H[crosspost<br/>三平台适配]
    H --> I[quality-gatekeeper<br/>质量门禁]
    
    A --> J[weread-skills<br/>书架富集]
    A --> K[deep-research<br/>深度研究]
    C --> L[ljg-card<br/>知识卡片]
    C --> M[ljg-plain<br/>白话版]
    C --> N[ljg-read<br/>阅读伴侣]
    C --> O[ljg-learn<br/>学习序列]
    C --> P[ljg-think<br/>5层深钻]
    C --> Q[ljg-roundtable<br/>4角色圆桌]
    C --> R[ljg-qa<br/>20问题]
    
    F --> S[dbs-deconstruct<br/>第一性拆解]
    F --> T[dbs-benchmark<br/>竞争对标]
    F --> U[dbs-diagnosis<br/>商业化诊断]
    F --> V[dbs-slowisfast<br/>慢方法]
    F --> W[dbs-chatroom-austrian<br/>奥派视角]
    
    style A fill:#00d4ff,color:#000
    style I fill:#00d4ff,color:#000
```

---

## 图表3: 外部信源验证网络

```mermaid
graph TD
    CENTER[Skill生态审计<br/>核心发现]
    
    CENTER --> S1[Anthropic工程博客<br/>官方skill架构标准]
    CENTER --> S2[SkillsBench<br/>+16.2pp curated vs -1.3pp self-gen]
    CENTER --> S3[OpenSkillEval<br/>wrong skill < no skill baseline]
    CENTER --> S4[SoK: Agentic Skills<br/>skill定义+路由机制]
    CENTER --> S5[SkillRouter<br/>31-44pp routing accuracy drop]
    CENTER --> S6[weread书架<br/>37+本书阅读数据]
    
    S1 --> V1["验证: GA门禁标准<br/>(与Anthropic三层结构一致)"]
    S2 --> V2["验证: 99%草稿发现<br/>(自生成skill平均退化)"]
    S3 --> V3["验证: 删坏skill>建新skill<br/>(最差-0.28)"]
    S4 --> V4["验证: 编排层必要性<br/>(applicability conditions)"]
    S5 --> V5["验证: 74%隐身严重性<br/>(无触发词=路由精度暴跌)"]
    S6 --> V6["验证: 理论底座<br/>(认知驱动+阿德勒+非暴力沟通)"]
    
    style CENTER fill:#1a1a2e,color:#fff
    style S1 fill:#00d4ff,color:#000
    style S2 fill:#00d4ff,color:#000
    style S3 fill:#00d4ff,color:#000
    style S4 fill:#4ecdc4,color:#000
    style S5 fill:#4ecdc4,color:#000
    style S6 fill:#ffe66d,color:#000
```

---

## 图表4: Draft→GA 5步流程

```mermaid
graph LR
    START([Draft级Skill]) --> S1
    
    S1["Step1: 补触发词<br/>5min · description重写"] --> S2
    S2["Step2: git init<br/>5min · 版本控制"] --> S3
    S3["Step3: 模块精简<br/>10min · Focused>Comprehensive"] --> S4
    S4["Step4: 建验证机制<br/>5min · tests/ + 2-3用例"] --> S5
    S5["Step5: CHANGELOG+EVIDENCE<br/>5min · 可追溯"] --> END
    
    END([GA级Skill<br/>30分钟总耗时])
    
    style START fill:#ff6b6b,color:#fff
    style END fill:#00d4ff,color:#000
```

---

> baoyu-diagram规格: 4张Mermaid图 — 质量金字塔/22-skill管线/外部信源网络/Draft→GA流程
> 渲染: 复制到支持Mermaid的编辑器(Obsidian/GitHub/Notion)即可渲染
