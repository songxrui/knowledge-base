# 编码标准应用于Skill规范

> 产出方法: coding-standards (跨项目编码规范)  
> 应用: Skill创建与维护的工程标准

---

## Skill编码规范 (10条)

### 规范1: 命名规范
**规则**: `skill-name` 使用小写+连字符, 动词开头
- ✅ `audit-skill-quality`, `generate-article`, `enrich-sources`
- ❌ `SkillAudit`, `skill_audit`, `audit`

### 规范2: 文件结构
**规则**: 每个skill至少包含:
```
skill-name/
├── SKILL.md          # 核心指令 (≤2000字)
├── references/        # 原始素材
│   └── original_body.md
├── examples/          # 使用示例
│   └── example-01.md
├── tests/             # 测试用例
│   ├── test-positive.md
│   └── test-negative.md
├── CHANGELOG.md       # 版本历史
├── EVIDENCE.md        # git commit关联
└── .git/              # 版本控制
```

### 规范3: 触发词规范
**规则**: description必须包含:
- 4-8个触发词
- 2个不适用场景
- 2个正例 + 2个反例
```yaml
description: "功能描述。触发词: X/Y/Z。不适用: A→用B; C→用D。正例: 'E'→触发; 'F'→触发。反例: 'G'→不触发→用H"
```

### 规范4: 失败处理
**规则**: SKILL.md必须包含失败模式表:
```markdown
| 场景 | 原因 | 兜底 |
|------|------|------|
```

### 规范5: 禁止硬编码
**规则**: 密钥/Token一律使用环境变量
- ✅ `$env:API_KEY`
- ❌ `token: "sk-xxx"`

### 规范6: 版本号规范
**规则**: semver格式 `MAJOR.MINOR.PATCH`
```yaml
version: "1.0.0 | R3: 2026-06-08 | methodology: SkillOpt"
```

### 规范7: commit message规范
**规则**: `type: description` 格式
- `feat: 新增xxx功能`
- `fix: 修复xxx问题`
- `audit: 审计xxx`
- 禁止在commit message中写入工时数字

### 规范8: 文档完整性
**规则**: 每个skill必须可独立使用, 不依赖其他skill的上下文

### 规范9: 最小权限
**规则**: Skill只读取/写入声明的目录, 不访问敏感路径

### 规范10: 可测试性
**规则**: tests/中的每个测试用例必须有:
- 输入
- 期望输出
- 通过条件
- 执行命令

---

## 规范符合度 (本轮35+个skill)

| 规范 | 符合率 | 说明 |
|------|:---:|------|
| 命名规范 | 90% | 极少数使用下划线 |
| 文件结构 | 85% | 部分Draft级缺少tests/ |
| 触发词规范 | 25% (改进前) → 81% (改进后) | 核心skill已补 |
| 失败处理 | 60% | 大部分缺兜底 |
| 禁止硬编码 | 95% | weread token已迁移 |
| 版本号 | 50% | 部分无规范版本号 |
| commit规范 | 100% | 本轮全部遵循 |
| 文档完整 | 80% | |
| 最小权限 | 95% | |
| 可测试性 | 30% | 大部分缺测试用例 |

**平均符合率**: ~70% → 需系统性提升

---

> coding-standards: 10条Skill编码规范, 符合率审计, 改进方向标注
