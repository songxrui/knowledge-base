# Content Skill Utilization Report - 2026-06-11 Session

## Actively Used Content Skills (this session)

used = [
    ("compile-and-verify", "任务编译+交付验证", "v7全文件质检"),
    ("content-guard", "6门禁防退化", "6文件扫描零违规"),
    ("humanizer-zh", "中文去AI味", "PREFACE诊断零禁用词"),
    ("ai-taste-check", "AI味深度诊断", "PREFACE+4章诊断通过"),
    ("skill-review", "元Skill评测", "traffic-engineering 3轮优化"),
    ("traffic-engineering", "流量工程诊断", "3轮迭代→S级(12KB)"),
    ("weread-skills", "微信读书信源", "67本书架+32条高亮提取"),
    ("weread-exporter", "微信读书导出", "API gateway验证通过"),
    ("feishu", "飞书集成", "9/9文档v7全量同步(2195blocks)"),
    ("dbs-content", "内容诊断", "已集成到工作流"),
    ("dbs-hook", "钩子优化", "已集成到工作流"),
    ("dbs-ai-check", "AI特征检测", "已集成到工作流"),
    ("dbs-xhs-title", "小红书标题公式", "已集成到工作流"),
    ("khazix-writer", "卡兹克风格", "公众号文章基准"),
    ("article-writing", "长文写作", "v7全8章+统稿"),
    ("content-engine", "平台原生内容", "公众号/知乎适配"),
    ("brand-voice", "品牌语调", "v7全书语调一致性"),
    ("crosspost", "多平台分发", "已集成"),
    ("viral-writer", "自媒体引擎", "流量skill基准参考"),
]

print("## Used Skills (19)")
for name, desc, usage in used:
    print(f"| {name} | {desc} | {usage} |")

# High-value unused skills
unused_high = [
    ("baoyu-article-illustrator", "文章智能配图", "v7全书8章可视化插图"),
    ("baoyu-cover-image", "封面图生成", "答案之书封面/公众号封面"),
    ("baoyu-infographic", "信息图表生成", "核心概念信息图"),
    ("baoyu-format-markdown", "Markdown格式化", "全书格式统一优化"),
    ("baoyu-image-cards", "小红书图片卡片", "平台适配视觉内容"),
    ("baoyu-diagram", "SVG图表生成", "概念关系图/框架图"),
    ("content-research-writer", "研究型内容写作", "深度研究增强"),
    ("content-strategy", "内容策略规划", "全局策略+主题地图"),
    ("content-and-copy", "网站文案写作", "GitHub README优化"),
    ("content-repurposing", "内容跨格式改编", "长文→短视频脚本"),
    ("long-form-content-frameworks", "长内容框架", "全书架构优化"),
    ("competitive-ads-extractor", "竞品广告分析", "同赛道内容分析"),
    ("launch-tweet", "发布推文草稿", "新内容发布文案"),
    ("email-customer", "邮件/私域文案", "私域转化内容"),
    ("frontend-slides", "HTML演示文稿", "答案之书路演讲座"),
    ("wewrite", "微信公众号全流程", "发布前全流程检查"),
    ("content-alchemist", "内容炼金管线", "全链路自动化"),
    ("video-editing", "视频编辑", "短视频素材制作"),
    ("content-guard", "内容防退化", "全局质量门禁"),
]

print("\n## High-Value Unused Content Skills (19)")
for name, desc, opportunity in unused_high:
    print(f"| {name} | {desc} | {opportunity} |")

# Summary
total_skills = 247
content_skills_used = 19
content_skills_unused_high = 19
utilization = content_skills_used / (content_skills_used + content_skills_unused_high) * 100

print(f"\n## Summary")
print(f"| Metric | Value |")
print(f"|--------|-------|")
print(f"| Total global skills | {total_skills} |")
print(f"| Content skills used this session | {content_skills_used} |")
print(f"| High-value content skills unused | {content_skills_unused_high} |")
print(f"| Content skill utilization rate | {utilization:.0f}% |")
print(f"| Key gap | Visual/media skills (baoyu-* series, video-editing) |")
print(f"| Next priority | baoyu-article-illustrator → baoyu-cover-image → content-research-writer |")
