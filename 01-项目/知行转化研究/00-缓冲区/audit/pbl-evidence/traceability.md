# 个人工作台 0.2 需求追踪

| 需求 | 实现 | 成功证据 | 失败证据 | 状态 |
|---|---|---|---|---|
| P0-00 | `product/02-product-spec-and-validation.md`、`experiment/14天个人双条件试用记录模板.md` | Node 29/29、个人边界文档、v0.1 冻结件 | 个人试用尚未发生，不能写成效果结论 | 已验证 |
| P0-01 | `prototype/app.js`、`prototype/ui-state.js` | smoke 状态矩阵与单可见工作区 | 恢复态和退出态断言 | 已验证 |
| P0-02 | `prototype/index.html`、`prototype/app.js`、`prototype/logic.js` | 三段流程、字段错误、风险冲突断言 | 缺字段、取消修订、隐藏阶段 Enter 回归 | 已验证 |
| P0-03 | `prototype/index.html`、`prototype/app.js`、`prototype/styles.css` | 320/390/735/1024/1440、当前/历史账本和溢出 0 | 空账本、长事实、退出态列表断言 | 已验证 |
| P0-04 | `prototype/styles.css` | 深色计算样式、对比度输出、偏好截图 | 不支持 blur 的不透明降级、减少动画断言 | 已验证 |
| P0-05 | `prototype/index.html`、`prototype/app.js`、`prototype/logic.js` | 导入错误、恢复、跨标签、清空/退出取消和键盘断言 | 原状态保持和焦点回归 | 已验证 |
