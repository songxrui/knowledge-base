# 答案之书 v7 — 发布启动包

> 所有内容已优化就绪，按此清单逐平台发布 | 2026-06-11

---

## 一、发布顺序（建议）

| 顺序 | 平台 | 文件 | 动作 |
|------|------|------|------|
| 1 | 飞书 | 9篇文档 | ✅ 已同步 (jcn1crrvstv9) |
| 2 | 公众号 | platforms/wechat.md | 复制到公众号编辑器→预览→发布 |
| 3 | 知乎 | platforms/zhihu.md | 搜索匹配问题→粘贴回答→发布 |
| 4 | 小红书 | platforms/xiaohongshu.md | 生成配图→发布图文笔记 |

---

## 二、发布前逐项检查

### 公众号
- [x] 禁用词扫描 PASS
- [x] AI味诊断 5/6 PASS
- [x] 情绪锚点 2个
- [x] 一句话核心 ≤16字
- [ ] 封面图生成（见 cover_prompt.md）
- [ ] 手机预览排版

### 知乎
- [x] 学术引用 ≥3处
- [x] 个人经历 真实可验证
- [ ] 匹配高流量问题（搜索"个人成长书籍推荐"）
- [ ] 发布时间选周末上午

### 小红书
- [x] 3张反共识卡片内容就绪
- [x] 话题标签 ≥5个
- [ ] 配图生成（见 xhs_image_prompts.md）
- [ ] 发布时间选晚8-10点

---

## 三、配图生成

`powershell
# 封面图 (需 imagegen skill 或手动)
# Prompt: D:\KnowledgeBase\media\flagship\book-v7\platforms\cover_prompt.md

# 小红书3卡片
# Prompt: D:\KnowledgeBase\media\flagship\book-v7\platforms\xhs_image_prompts.md
`

---

## 四、发布后追踪

| 指标 | 公众号 | 知乎 | 小红书 |
|------|--------|------|--------|
| 阅读量 | 目标500+ | 目标1000+ | 目标200+ |
| 互动率 | >3% | >5% | >5% |
| 新关注 | >10 | >20 | >10 |

---

## 五、内容回收

发布后7天：
1. 收集评论区高频问题
2. 更新 FULL_MANUSCRIPT.md 补充FAQ
3. 飞书同步更新
4. GitHub commit

---

## 六、完整文件索引

| 用途 | 路径 |
|------|------|
| 全稿 | media/flagship/book-v7/FULL_MANUSCRIPT.md |
| 公众号版 | media/flagship/book-v7/platforms/wechat.md |
| 知乎版 | media/flagship/book-v7/platforms/zhihu.md |
| 小红书版 | media/flagship/book-v7/platforms/xiaohongshu.md |
| 封面Prompt | media/flagship/book-v7/platforms/cover_prompt.md |
| 配图Prompt | media/flagship/book-v7/platforms/xhs_image_prompts.md |
| 诊断报告 | media/flagship/book-v7/TRAFFIC_DIAGNOSIS.md |
| 分发配置 | media/flagship/book-v7/CROSSPOST_CONFIG.md |
| 归档报告 | _meta/MEGA_DELIVERY_FINAL_2026-06-11.md |
