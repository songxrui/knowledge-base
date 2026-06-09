# 答案之书 v3 — 全书框架总图

## 8章核心框架 (Mermaid Mindmap)

""mermaid
mindmap
  root((答案之书 v3<br/>~137K字/117本名著))
    第1章 元能力
      检索练习
      间隔重复
      交叉练习
      刻意练习
      心流
      注意力经济学
        Newport深度工作
        Castelo手机RCT
        AMS成瘾支架
    第2章 心理健康
      Adler九柱模型
      Frankl意义治疗
      ACT接纳承诺
      斯多葛派操作系统
      Taleb反脆弱
      课题分离
    第3章 身体健康
      阿提亚医学3.0
      五层健康金字塔
      夏萌饮食革命
      Shanahan深度营养
      Clear原子习惯
      睡眠神经科学
        胶状淋巴清除
        Cell2025 NE振荡
        安眠药隐藏代价
    第4章 财富商业
      Naval三种杠杆
      Housel金钱心理
      AI一人企业堆栈
      FIRE数学模型
        4%规则更新
        储蓄率→自由年限
      定价心理学
      Taleb杠铃策略
    第5章 人际关系
      Gottman爱情实验室
      非暴力沟通NVC
      Bowen自我分化
      Buss进化心理学
      社交网络科学
        Dunbar 7层结构
        交友软件双重效应
    第6章 顶级人类
      Musk五步算法
      Munger清单系统
      Naval/Dan Koe
      Buffett长期主义
      建造vs投资双模
      中国人模仿路径
    第7章 问题解决
      Polya四步法
      Grant科学家模式
      预验尸Premortem
      Cynefin五域框架
      双环学习
      Agent工程实践
        Fairy RGR/OCA/EMA
        CODESIM调试
    第8章 第一性模型
      熵增定律
      演化论
      复利
      系统1/2
      Meadows系统动力学
      帕累托80/20
      贝叶斯更新
      二阶思维
""

## 跨章连接图 (Mermaid Graph)

""mermaid
graph TD
    subgraph 地基["地基: 思维操作系统"]
        CH01[CH01 元能力<br/>学会如何学习]
        CH07[CH07 问题解决<br/>学会如何思考]
        CH08[CH08 第一性模型<br/>学会用什么模型]
    end

    subgraph 向内["向内: 个人系统"]
        CH02[CH02 心理健康<br/>反脆弱与自愈]
        CH03[CH03 身体健康<br/>循证长寿方案]
    end

    subgraph 向外["向外: 世界交互"]
        CH04[CH04 财富商业<br/>AI时代自由]
        CH05[CH05 人际关系<br/>科学社交]
        CH06[CH06 顶级人类<br/>模仿路径]
    end

    CH01 -->|注意力是前提| CH03
    CH01 -->|深度工作→| CH04
    CH02 -->|课题分离→| CH05
    CH02 -->|反脆弱→| CH06
    CH03 -->|身体是载体→| CH04
    CH04 -->|财富自由→| CH06
    CH05 -->|Dunbar数→| CH01
    CH07 -->|决策框架→| CH04
    CH07 -->|Polya四步→| CH06
    CH08 -->|贝叶斯→| CH07
    CH08 -->|复利→| CH04
    CH08 -->|演化→| CH01
""

## 全书信源分布

""mermaid
pie title ~117本去重名著来源分布
    "weread在架" : 66
    "exa实搜补充" : 51
""

## 各章字数对比

| 章 | 字数 | 名著 | 深度增强轮次 |
|----|------|------|------------|
| CH01 | 16K | 16 | R10 |
| CH02 | 15K | 17 | R8 |
| CH03 | 18K | 13 | R11 |
| CH04 | 16K | 18 | R11 |
| CH05 | 15K | 16 | R10 |
| CH06 | 18K | 18 | R12 |
| CH07 | 15K | 13 | R9 |
| CH08 | 17K | 14 | R12 |

---

> 上图可在支持Mermaid的Markdown阅读器(GitHub/Obsidian/Tolaria)中直接渲染为可视化图表。