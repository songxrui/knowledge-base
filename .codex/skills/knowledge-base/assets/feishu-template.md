# 飞书发布格式模板

> 从本地 zettel 笔记精选后，按此格式发布至飞书 Wiki。

---

## 发布规范

### 标题格式
```
[领域标签] 核心结论（≤30汉字）
```
示例：`[认知] 多巴胺不是快乐分子，是欲望分子`

### 正文结构
```markdown
## 一句话摘要
<用一句话说清这篇内容的核心论点，让读者3秒内决定是否继续读>

## 核心内容
<2-5段精简版正文，每段 ≤200 字>
<保留最核心的论证链条，删除次要细节>

## 关联阅读
- `关联笔记1`（请替换为实际笔记链接）
- `关联笔记2`（请替换为实际笔记链接）
```

### 标签规范
- 领域标签：`#认知` `#健康` `#财富` `#生产力` `#自媒体` `#心理学` `#关系` `#历史社会`
- 类型标签：`#概念` `#方法` `#案例` `#工具` `#反思`
- 成熟度：`#seedling` `#evergreen`

---

## 发布检查清单

- [ ] 标题 ≤30 字且有领域标签
- [ ] 摘要能在3秒内传达核心价值
- [ ] 正文已删除本地笔记的草稿痕迹（`TODO`、`待补充`、`[推断]`标记如非必要应删除）
- [ ] 关联链接 ≥2 条
- [ ] 来源已标注（如有引用）
- [ ] 已用 `humanizer-zh` 去 AI 痕迹（如适用）

---

## CLI 发布命令

```bash
# 列出当前Wiki节点
lark-cli wiki +node-list --space-id <YOUR_SPACE_ID> --as user

# 创建新节点
lark-cli wiki +node-create --space-id <YOUR_SPACE_ID> \
  --title "[认知] 多巴胺不是快乐分子" \
  --parent-node <PARENT_NODE_TOKEN> \
  --as user

# 更新已有节点（获取obj_token后）
lark-cli wiki +node-update <node_token> --title "新标题" --as user
```

---

## 节点映射参考

> 具体映射见 `references/collaboration.md`

| 本地 | 飞书节点 | 发布频率 |
|------|---------|---------|
| zettel (精选) | 🧠 Zettel 精选 | 每周 1-3 篇 |
| 01_Projects 产出 | 📂 01_Projects | 项目完成时 |
| 02_Areas 领域总结 | 📂 02_Areas | 月度 |
