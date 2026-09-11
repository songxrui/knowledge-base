# 答案之书 Crosspost 分发配置

> 基于 crosspost skill + traffic-engineering | 2026-06-11

## 核心原则
1. 不跨平台复制粘贴同一内容
2. 每平台保留作者语调（教练型个人叙事者）
3. 适配平台约束，不做刻板印象式改写

## 三平台分发矩阵

| 平台 | 源文件 | 适配策略 | 发布形态 |
|------|--------|---------|---------|
| 公众号 | platforms/wechat.md | 长文叙事+证据链+CTA | 全文推送 |
| 小红书 | platforms/xiaohongshu.md | 3张反共识卡片+emoji | 图文笔记 |
| 知乎 | platforms/zhihu.md | 学术引用+深度论证+表格 | 回答/文章 |

## 发布前自检

### 公众号
- [ ] 标题含数字/反差
- [ ] 开头3行有钩子
- [ ] 禁用词扫描PASS

### 小红书
- [ ] 标题20字内+emoji
- [ ] 3张卡片排版
- [ ] 话题标签5个

### 知乎
- [ ] 匹配高流量问题
- [ ] 回答1000字
- [ ] 3处学术引用

## 分发流水线

```
FULL_MANUSCRIPT.md
  +-> humanizer -> 公众号版 -> baoyu-post-to-wechat
  +-> viral-writer -> 小红书版 -> baoyu-xhs-images
  +-> content-reverse -> 知乎版 -> 手动发布
```

## 进度
| 平台 | 版本 | 状态 |
|------|------|------|
| 公众号 | wechat.md (2,056字) | DONE |
| 小红书 | xiaohongshu.md (723字) | DONE |
| 知乎 | zhihu.md (1,558字) | DONE |
| 飞书 | 9/9文档 | DONE |
