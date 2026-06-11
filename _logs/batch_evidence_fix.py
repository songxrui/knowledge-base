import os

BASE = r"D:\KnowledgeBase\media\flagship\book-v7"

# Define analysis blocks for each chapter
analyses = {
    "CH01_meta-abilities.md": """
🔗 **与CH01的连接（元能力——大脑操作系统）**：
以上划线共同揭示了一个被低估的真相：大脑不是一个"理性器官"，而是一个"三层旧楼"——底层是爬行动物脑（本能），中层是哺乳动物脑（情绪），顶层才是理性脑。CH01的核心主张——"不是让理性脑取代本能和情绪，而是让它学会驱动它们"——在周岭的"理智脑不是直接干活的"中找到了几乎一字不差的呼应。元认知不是多学一个技能，是给大脑装一个"第三方观察者"。这对董辉的意义：在Java培训和秋招全挂的最低谷，是"第三视角"让他看到"我不是失败的人，我只是在一个不适合的跑道上"。""",

    "CH03_physical-health.md": """
🔗 **与CH03的连接（身体健康——硬件基础）**：
伦布克医生的成瘾研究为CH03提供了最硬的生物学证据。本章主张"身体在用疼痛给你发信号"——多巴胺系统的精妙设计恰好解释了这个信号机制。当你用高糖高油高刺激持续轰炸多巴胺受体，身体不是"变快乐了"，而是"快乐门槛提高了"——这就是为什么垃圾食品吃得越多越不满足，为什么刷短视频越刷越空虚。董辉的蛀牙→痔疮→增肌路径，本质上是一次"多巴胺系统重置"：从追求即时的口腹之快，到投资长期的体感回报。""",

    "CH04_wealth-business.md": """
🔗 **与CH04的连接（财富商业——资源引擎）**：
这几本财富经典共同指向一个被现代消费主义遮蔽的真相：财富的本质不是"赚更多"，而是"需要的更少+复利的时间更长"。穷查理宝典的"能力圈"概念与CH04的"三重复利飞轮"形神合一——不是什么都做，是在自己能判断对的事情上持续叠加。复利效应这本书揭示了一个反直觉事实：大多数人高估了自己一年能做的事，低估了十年能做的事。董辉从Java培训班到Codex+自媒体的转型，本质上是从"技能复利"切换到了"创作复利"——前者的天花板是时薪，后者的天花板是指数。""",

    "CH06_top-humans.md": """
🔗 **与CH06的连接（顶级人类——对标灯塔）**：
穷查理宝典和游戏改变人生提供了两种截然不同但互补的"对标"方法论。芒格的路径是"找到最聪明的人，弄清楚他们怎么思考，然后偷过来"——这是CH06的"提取→内化→超越"框架。而简·麦戈尼格尔的"游戏改变人生"提供了另一种可能：不是把所有痛苦当作要解决的问题，而是把所有挑战当作可以"升级打怪"的任务。董辉把姜胡说的《价值心法》视作灯塔——不是因为他多有钱，是因为他也是码农背景、低学历出身，却走出了一条"不靠上班也能活得很好"的路。""",

    "CH07_problem-solving.md": """
🔗 **与CH07的连接（问题解决——执行引擎）**：
周岭的《认知驱动》为CH07提供了核心燃料。"只有当知识能够帮助你做实际决策的时候，它才是你的知识"——这条直接命中了CH07的第一性求解器的设计哲学：不是收集更多知识，是把已有知识转化为决策力。CH07的"拆解→匹配→输出"三步法，与周岭"享受努力奋斗的状态，却少有产出作品的意识"形成了完美的镜像——大多数人停留在拆解，少数人能做到匹配，极少数人能完成输出。""",

    "CH08_first-principles.md": """
🔗 **与CH08的连接（第一性模型——元模型）**：
穷查理宝典是CH08最硬的学术支撑。芒格的"多元思维模型"——从各学科偷核心模型来交叉验证决策——正是CH08"贝叶斯更新+二阶思维+复利不只是钱"的源头。芒格说"拿着锤子的人看什么都是钉子"，CH08的回应是"装一整个工具箱"。""",
}

for fname, analysis in analyses.items():
    fpath = os.path.join(BASE, fname)
    for enc in ['utf-8', 'gbk']:
        try:
            with open(fpath, "r", encoding=enc) as f:
                content = f.read()
            break
        except:
            pass
    
    # Find the last weread section and append analysis
    last_weread = content.rfind("微信读书证据补充")
    if last_weread < 0:
        print(fname + ": no weread section")
        continue
    
    # Find the end of the weread section (next ## or end of file)
    after_weread = content[last_weread:]
    next_section = after_weread.find("\n## ", 10)  # Skip the current ## header
    if next_section < 0:
        next_section = len(after_weread)
    
    insert_pos = last_weread + next_section
    
    # Check if already has analysis
    if "与CH0" in content[last_weread:insert_pos]:
        print(fname + ": already has analysis")
        continue
    
    # Insert analysis before the next section or at end
    content = content[:insert_pos] + "\n" + analysis + "\n" + content[insert_pos:]
    
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)
    print(fname + ": analysis added")

print("\nAll 6 chapters enriched with connective analysis")
