import os

skill_path = r"C:\Users\董辉\.codex\skills\traffic-engineering"
skill_file = os.path.join(skill_path, "SKILL.md")

with open(skill_file, "r", encoding="utf-8") as f:
    content = f.read()

# Round 1 fixes:
# 1. D5: Add PowerShell/Codex/Windows constraints
# 2. D2: Verify agents/openai.yaml exists, if not create
# 3. D9: Check for any AI-flavor issues

# Check agents/openai.yaml
agents_dir = os.path.join(skill_path, "agents")
agents_file = os.path.join(agents_dir, "openai.yaml")
os.makedirs(agents_dir, exist_ok=True)

if not os.path.exists(agents_file):
    yaml_content = """name: traffic-engineering
description: |
  底层流量工程skill。控制内容传播力——注意力第一性、21个心理学触发器、
  小红书/抖音/公众号/X平台算法。为Codex CLI/DeepSeek v4 Pro优化。
tools: []
model: deepseek-v4-pro
"""
    with open(agents_file, "w", encoding="utf-8") as f:
        f.write(yaml_content)
    print("Created agents/openai.yaml")
else:
    print("agents/openai.yaml exists")

# Count improvements
improvements = 0

# Fix: Add DS/Windows/PowerShell section to SKILL.md
env_section = """

## 环境适配（Codex CLI + DeepSeek v4 Pro + Windows PowerShell）

本skill为以下环境优化：
- **CLI**: Codex CLI（非Claude Code，无hooks）
- **模型**: DeepSeek v4 Pro（context_window=1M, compact=64K, reasoning_effort=high）
- **OS**: Windows + PowerShell（分隔符用 `;` 不用 `&&`）

DS适配规则：
1. 单次诊断输出 >3000字符 → 触发 `headroom_compress` 压缩
2. 批量处理 ≥3 篇内容 → 每篇独立commit，禁止批量
3. 不确定的判断 → 标注 `[推断]` 而非伪造确定
4. 工具调用参数格式 → 优先JSON，失败换form格式重试
"""

if "环境适配" not in content:
    # Insert before "## 核心哲学"
    content = content.replace("## 核心哲学", env_section + "\n## 核心哲学")
    improvements += 1
    print("Added environment adaptation section")

# Fix: Add DS-specific commands
ds_section = """
**DS专用检测命令** (PowerShell):
```powershell
# 触发器验证
Select-String -Path <file> -Pattern "好奇心|损失厌恶|社会认同|框架|稀缺"
# 平台适配验证
Select-String -Path <file> -Pattern "完播率|封面驱动|搜索流量|收藏价值"
# 黑名单词检查
Select-String -Path <file> -Pattern "赋能|抓手|闭环|综上所述|值得注意的是"
```
"""

if "DS专用检测命令" not in content:
    content = content.replace("**检测命令**：`rg", ds_section + "\n**检测命令**：`rg")
    improvements += 1
    print("Added DS-specific detection commands")

# Fix: Add confidence tier to the 10-dim scoring
confidence_note = """
**DS评分说明**：10维度评分中，S1/S2/S5/S6 为 `[确认]`（有明确来源支撑），S3/S4/S7 为 `[推断]`（基于Berger&Milkman 2012框架推演），S8/S9/S10 为 `[经验]`（来自内容运营通用实践）。不确定项目明确标注，不做盖章式全绿。
"""
if "DS评分说明" not in content:
    content = content.replace("**使用**：每篇内容发布前打分", confidence_note + "\n**使用**：每篇内容发布前打分")
    improvements += 1
    print("Added DS scoring confidence note")

# Write back
with open(skill_file, "w", encoding="utf-8") as f:
    f.write(content)

print(f"R1 complete: {improvements} improvements made")
print(f"New size: {len(content.encode('utf-8'))} bytes")
