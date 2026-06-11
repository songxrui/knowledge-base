# 内容结构化系统 — 主题连接图

> 1,543内容单元 → 8主题地图 → 答案之书8章

\\\mermaid
graph TB
    subgraph 内容单元库["内容单元库 (1,543 units)"]
        QST["问题 QST (307)"]
        CON["概念 CON (309)"]
        OPI["观点 OPI (311)"]
        CAS["案例 CAS (309)"]
        SOL["方案 SOL (315)"]
    end

    subgraph 主题地图["主题地图 (8 maps)"]
        TM1["多巴胺+流量+认知+创作"]
        TM2["健康饮食+风险管理"]
        TM3["一人企业+AI杠杆"]
        TM4["习惯+环境设计"]
        TM5["关系+反依赖"]
        TM6["第一性原理+决策"]
        TM7["内容创作+dbs工程"]
        TM8["深度卡综合 (182 nodes)"]
    end

    subgraph 答案之书v7["答案之书 v7"]
        CH02["CH02 心理健康"]
        CH03["CH03 身体健康"]
        CH04["CH04 财富事业"]
        CH05["CH05 关系网络"]
        CH07["CH07 问题解决"]
        CH08["CH08 第一性原理"]
    end

    subgraph 发布["发布层"]
        WX["公众号"]
        XHS["小红书"]
        ZH["知乎"]
        FS["飞书"]
    end

    QST --> TM1
    CON --> TM1
    OPI --> TM1
    CAS --> TM1
    SOL --> TM1

    TM1 --> CH02
    TM2 --> CH03
    TM3 --> CH04
    TM4 --> CH02
    TM5 --> CH05
    TM6 --> CH07
    TM6 --> CH08
    TM7 --> CH04
    TM8 --> CH02
    TM8 --> CH07

    CH02 --> WX
    CH03 --> WX
    CH04 --> WX
    CH02 --> XHS
    CH04 --> XHS
    CH02 --> ZH
    CH07 --> ZH
    CH02 --> FS
    CH03 --> FS
    CH04 --> FS
    CH05 --> FS
    CH07 --> FS
    CH08 --> FS

    style 内容单元库 fill:#1a1a3e,stroke:#d4a574,color:#e0e0e0
    style 主题地图 fill:#16213e,stroke:#f0a500,color:#e0e0e0
    style 答案之书v7 fill:#0f3460,stroke:#00b4d8,color:#e0e0e0
    style 发布 fill:#1a1a2e,stroke:#e94560,color:#e0e0e0
\\\

## 连接统计

| 从 | 到 | 连接数 |
|----|-----|--------|
| 内容单元 | 主题地图 | 5→8 (全映射) |
| 主题地图 | 答案之书 | 9条直接关联 |
| 答案之书 | 发布 | 12条平台分发 |

## 调用路径示例

要写一篇"多巴胺与成瘾"的公众号文章:
1. 检索 QST(问题) → 找到"为什么我总是控制不住刷手机?"
2. 匹配 CON(概念) → 多巴胺天平/即时奖励vs延迟满足
3. 调用 OPI(观点) → "多巴胺戒断不是禁欲，是重建敏感度"
4. 引用 CAS(案例) → 个人经历: 戒游戏后专注力恢复
5. 执行 SOL(方案) → 14天多巴胺实验SOP
6. 走 content-pipeline-orchestrator → 公众号/小红书/知乎三版
