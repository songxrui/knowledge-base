# 抖音发布SOP v1.0 (HyperFrames不露脸知识视频)

## Stage 1: 选题 (5分钟)
- [ ] 从选题池认领或从内容单元库选取
- [ ] 确认选题在5域17主题内
- [ ] 确认有>=1个可直接引用的来源

## Stage 2: 脚本撰写 (15分钟)
- [ ] 写30-90秒口播脚本 (300-500字)
- [ ] 开头采用6种Hook公式之一
- [ ] 核心信息点 <=3个
- [ ] 结尾行动号召 (关注/私信/看主页)
- [ ] 口播检测：念一遍不拗口

## Stage 3: HyperFrames制作 (10分钟)
- [ ] 保存脚本到 capture/extracted/visible-text.txt
- [ ] 运行 `npx hyperframes init "videos/{项目名}"`
- [ ] 生成STORYBOARD.md + SCRIPT.md
- [ ] 运行音频: `node scripts/audio.mjs --request audio_request.json`
- [ ] 如果需要封面图: 触发 baoyu-cover-image (9:16竖版)

## Stage 4: 质检 (5分钟)
- [ ] 预览: `npx hyperframes preview`
- [ ] 检查: 文字同步、音频清晰、视觉不散乱
- [ ] 渲染: `npx hyperframes render --quality high`

## Stage 5: 发布 (5分钟)
- [ ] 标题 <=20字, Hook前置
- [ ] 标签 5-10个
- [ ] 话题标签 #知识分享 #商业思维 #个人成长
- [ ] 发布后记录数据到CSV

## 数据追踪字段
| 日期 | 选题 | 播放量 | 点赞 | 评论 | 分享 | 新增关注 |