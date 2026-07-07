
import re, os, json

BASE = r'D:\KnowledgeBase\01-内容生产\进行中'
OUTPUT = r'D:\KnowledgeBase\.dbs\assembly\douyin\_personalized-phase3.md'

# Read source scripts
def read_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

# Define injections for each day
# Format: (day_num, existing_elements, new_element, ending_change, change_level)
injections = {
    1:  {'existing': 'E1/E2/E6', 'add': None, 'ending': '微调', 'level': '轻'},
    2:  {'existing': 'E2/E6', 'add': 'E5', 'ending': '微调', 'level': '轻'},
    3:  {'existing': 'E1/E2/E6', 'add': 'E4', 'ending': '微调', 'level': '轻'},
    4:  {'existing': 'E1(轻)', 'add': 'E2', 'ending': '全新', 'level': '中'},
    5:  {'existing': 'E1', 'add': 'E3', 'ending': '全新', 'level': '中'},
    6:  {'existing': 'E1(轻)', 'add': 'E2', 'ending': '微调', 'level': '轻'},
    7:  {'existing': 'E2(隐)', 'add': 'E1+E4+E5', 'ending': '全新', 'level': '中'},
    8:  {'existing': 'E1', 'add': 'E5', 'ending': '微调', 'level': '轻'},
    9:  {'existing': '弱', 'add': 'E1+E3', 'ending': '全新', 'level': '中'},
    10: {'existing': 'E2/E6', 'add': 'E5', 'ending': '保留', 'level': '轻'},
    11: {'existing': 'E2', 'add': 'E1', 'ending': '微调', 'level': '轻'},
    12: {'existing': 'E2(隐)', 'add': 'E1+E4', 'ending': '全新', 'level': '中'},
    13: {'existing': 'E2/E6', 'add': 'E1', 'ending': '微调', 'level': '轻'},
    14: {'existing': 'E2', 'add': 'E5', 'ending': '保留', 'level': '轻'},
    15: {'existing': 'E2', 'add': 'E5', 'ending': '微调', 'level': '轻'},
    16: {'existing': 'E1/E3/E4', 'add': None, 'ending': '保留', 'level': '轻'},
    17: {'existing': 'E2', 'add': 'E1', 'ending': '微调', 'level': '轻'},
    18: {'existing': 'E1/E3/E4/E2', 'add': None, 'ending': '微调', 'level': '轻'},
    19: {'existing': 'E2', 'add': 'E1+E5', 'ending': '保留', 'level': '轻'},
    20: {'existing': 'E1/E2', 'add': 'E5', 'ending': '保留', 'level': '轻'},
    21: {'existing': '弱', 'add': 'E2+E1', 'ending': '全新', 'level': '中'},
    22: {'existing': 'E2/E6', 'add': 'E1', 'ending': '保留', 'level': '轻'},
    23: {'existing': 'E2', 'add': 'E4', 'ending': '保留', 'level': '轻'},
    24: {'existing': 'E2', 'add': 'E1', 'ending': '保留', 'level': '轻'},
    25: {'existing': 'E2', 'add': 'E4', 'ending': '保留', 'level': '轻'},
    26: {'existing': 'E2/E1', 'add': 'E3', 'ending': '微调', 'level': '轻'},
    27: {'existing': 'E2', 'add': 'E4', 'ending': '微调', 'level': '轻'},
    28: {'existing': 'E2/E4', 'add': None, 'ending': '微调', 'level': '轻'},
    29: {'existing': 'E2/E1', 'add': None, 'ending': '保留', 'level': '轻'},
    30: {'existing': 'E1/E2/E3/E4', 'add': None, 'ending': '保留', 'level': '轻'},
}

print(f'Injection map loaded: {len(injections)} days')
print('Script template ready')
