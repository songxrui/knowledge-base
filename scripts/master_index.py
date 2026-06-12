import os, json

KB = r"D:\KnowledgeBase"

# Scan all major directories
def count_files(path):
    if not os.path.exists(path):
        return 0
    count = 0
    for root, dirs, files in os.walk(path):
        count += len([f for f in files if f.endswith('.md')])
    return count

sections = {
    "v7 答案之书": (r"media\flagship\book-v7", [
        "FULL_MANUSCRIPT.md (260K, 8章统稿)",
        "CH01-CH08_*.md (8章 + 微信读书证据)",
        "PREFACE.md (序言 + 成长路径)",
        "ARCHITECTURE_DIAGRAM.md (Mermaid架构图)",
        "CONTENT_ROADMAP.md (三平台发布策略)",
        "EVIDENCE_AUDIT.md (证据质量审计)",
        "HEALTH_CHECK.md (全量健康检查)",
        "PUBLISH_CHECKLIST.md (23项发布清单)",
        "presentation.html (HTML路演稿)",
        "EVIDENCE_LEDGER.md (1,416条证据台账)",
    ]),
    "深度知识卡": (r"cards", [
        "77张主题卡片 (topics/)",
        "T1-T10 母题簇覆盖",
    ]),
    "公众号文章": (r"media\wechat_2026-06-07", [
        "316篇结构化文章",
        "零禁用词通过率 100%",
        "30%含书籍引用",
    ]),
    "微信读书提取": (r"_alchemist\weread_extracts", [
        "Batch1: 32条 (认知觉醒/驱动/成瘾/少有人走的路)",
        "Batch2: 30条 (复利/穷查理/游戏/致富/复利课)",
        "10本书, 68条高亮, 零污染",
    ]),
    "DBS内容系统": (r"_content-system", [
        "235源→1,543内容单元",
        "305装配稿 + 8主题地图",
        "1,720条显式关联",
    ]),
    "飞书同步": (None, [
        "9/9文档v7全量同步 (2,195 blocks)",
        "空间: jcn1crrvstv9",
    ]),
    "Skills生态": (r"C:\Users\董辉\.codex\skills", [
        "247个全局skill",
        "核心8个版本化 (v1.0.0)",
        "7个dbskill同步",
        "29个已审计评级",
    ]),
}

index = """# 知识库全局导航索引 (MASTER INDEX)

> 董辉知识库 · songxrui/knowledge-base · 997 commits · 2026-06-11

## 快速入口

| 入口 | 路径 | 说明 |
|------|------|------|
| 📖 全书统稿 | `media/flagship/book-v7/FULL_MANUSCRIPT.md` | 答案之书 v7 完整版 |
| 🎬 路演文稿 | `media/flagship/book-v7/presentation.html` | 浏览器打开 |
| 📊 健康面板 | `media/flagship/book-v7/HEALTH_CHECK.md` | 全量质量审计 |
| ✅ 发布清单 | `media/flagship/book-v7/PUBLISH_CHECKLIST.md` | 23项发布前检查 |
| 🔗 飞书空间 | https://jcn1crrvstv9.feishu.cn/drive/ | 9文档已同步 |

---

## 一、内容资产全景

"""

for section_name, (path, items) in sections.items():
    file_count = count_files(os.path.join(KB, path)) if path else "N/A"
    index += "### " + section_name + "\n\n"
    if path:
        index += "**路径**: `" + path + "` | **文件数**: " + str(file_count) + "\n\n"
    for item in items:
        index += "- " + item + "\n"
    index += "\n"

# Tool chain
index += """## 二、工具链状态

| 工具 | 状态 | 备注 |
|------|------|------|
| GitHub CLI | ✅ 已配置 | Push阻塞 (SSL_ERROR) |
| 飞书 CLI | ✅ 已配置 | feishu-codex-bridge@0.1.5 |
| 微信读书 API | ✅ 已接通 | 67本书架, 20本有笔记 |
| Exa Search MCP | ✅ 已配置 | Token就绪 |
| Headroom MCP | ✅ 已配置 | v0.20.15 |
| Tolaria 桌面 | ✅ 已安装 | 知识库可视化 |

## 三、质量指标

| 指标 | 当前值 | 目标 |
|------|--------|------|
| v7禁用词 | 0 | 0 |
| v7 AI味 | 0 | 0 |
| 微信读书覆盖率 | 8/8章 (100%) | 100% |
| 证据强连接率 | 53+条 | >80% |
| 公众号引用率 | 30% | >50% |
| 知识卡禁用词 | 0 (已修复13) | 0 |
| 飞书同步率 | 100% | 100% |

## 四、待优化队列

1. 🔴 GitHub push (8 commits 待push) — 网络问题
2. 🟡 公众号95篇零引用文章批量补充微信读书
3. 🟡 深度知识卡证据连接强化（对标v7标准）
4. 🟢 baoyu-cover-image 封面生成
5. 🟢 frontend-slides 演讲版PPT
6. 🔵 微信读书PDF书籍Playwright导出

---

> 生成: content-alchemist 全链路模式 | 997 commits | 8 commits pending push
"""

out = os.path.join(KB, "MASTER_INDEX.md")
with open(out, "w", encoding="utf-8") as f:
    f.write(index)

print("MASTER_INDEX.md generated")
