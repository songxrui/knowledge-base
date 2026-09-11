import { expect, test } from "@playwright/test";

async function fillSnapshot(page: import("@playwright/test").Page) {
  const values: Readonly<Record<string, string>> = {
    "可用现金缓冲（元）": "20000",
    "固定月支出（元）": "2500",
    "健康约束": "连续工作两小时后离开屏幕",
    "恢复约束": "每天保留八小时睡眠窗口",
    "每周可用容量（小时）": "40",
    "身体与恢复（小时）": "8",
    "必要责任（小时）": "6",
    "建设投入（小时）": "18",
    "关系维护（小时）": "4",
    "预留（小时）": "4",
    "平台边界": "发布前核对平台规则",
    "数据边界": "客户材料只保存在本地",
    "停止条件": "连续两天睡眠少于六小时就减载",
  };
  for (const [label, value] of Object.entries(values)) await page.getByLabel(label).fill(value);
  await page.getByRole("button", { name: "保存并确认现状" }).click();
  await expect(page.getByText("20000 元", { exact: true })).toBeVisible();
}

async function fillNorthStars(page: import("@playwright/test").Page) {
  const groups = page.locator(".product-field-pair");
  for (const [index, label] of ["可持续心力", "复利资产", "个人垄断"].entries()) {
    const group = groups.nth(index);
    await expect(group.getByRole("heading", { name: label })).toBeVisible();
    await group.getByLabel("观察事实").fill(`${label}已有一条可核对事实`);
    await group.getByLabel("不可突破的底线").fill(`${label}不能以透支恢复为代价`);
  }
  await page.getByRole("button", { name: "保存三项约束" }).click();
  await expect(page.getByText("可持续心力已有一条可核对事实")).toBeVisible();
}

test("runs the current-state through review and rule publication path", async ({ page }, testInfo) => {
  test.skip(testInfo.project.name !== "desktop", "The full write path runs once on desktop Chromium.");
  await page.goto("/");
  await expect(page.getByRole("heading", { name: "先看现实，再定交付" })).toBeVisible();
  await fillSnapshot(page);
  await fillNorthStars(page);

  await page.getByLabel("主瓶颈").selectOption("delivery");
  await page.getByLabel("选择依据").fill("最近三次咨询都重复确认交付范围");
  await page.getByRole("button", { name: "保存主瓶颈" }).click();
  await expect(page.getByText("主瓶颈：交付")).toBeVisible();

  await page.getByLabel("主要交付").fill("完成一页产品验收清单");
  await page.getByLabel("完成标准").fill("清单包含输入、输出和验收条件");
  await page.getByLabel("下一步动作").fill("列出三个交付边界");
  await page.getByLabel("容量上限（小时）").fill("2");
  await page.getByLabel("停止信号").fill("连续修改超过两小时");
  await page.getByRole("button", { name: "保存计划" }).click();
  await expect(page.getByRole("heading", { name: "完成一页产品验收清单" })).toBeVisible();
  await page.getByRole("button", { name: "开始这个工作单元" }).click();
  await expect(page.getByText("进行中").first()).toBeVisible();

  await page.getByRole("link", { name: "实验" }).click();
  await expect(page.getByText("交付").first()).toBeVisible();
  await page.getByLabel("当前事实").fill("最近三次咨询都重复确认交付范围");
  await page.getByLabel("假设").fill("书面验收物会减少范围确认次数");
  await page.getByLabel("变量名称").fill("验收物");
  await page.getByLabel("当前做法").fill("口头说明");
  await page.getByLabel("改动后的做法").fill("一页书面清单");
  await page.getByLabel("最小动作").fill("下一次咨询前发送清单");
  await page.getByLabel("时间上限（小时）").fill("2");
  await page.getByLabel("现金上限（元）").fill("0");
  await page.getByLabel("观察开始").fill("2026-07-12T09:00");
  await page.getByLabel("观察结束").fill("2026-07-13T09:00");
  await page.getByLabel("支持信号").fill("对方能复述交付输出");
  await page.getByLabel("反证信号").fill("仍需两次以上确认范围");
  await page.getByLabel("停止条件").fill("清单明显增加理解成本");
  await page.getByLabel("预期规则变化").fill("咨询前先发送验收清单");
  await page.getByRole("button", { name: "创建实验" }).click();
  await expect(page.getByText("已创建实验草稿。")).toBeVisible();
  await page.getByRole("button", { name: "开始执行" }).click();
  await expect(page.getByText("冻结实验契约")).toBeVisible();
  await expect(page.getByRole("heading", { name: "验收物: 口头说明 → 一页书面清单" })).toBeVisible();

  await page.goto("/");
  await page.getByLabel("实际输出").fill("已交付一页产品验收清单");
  await page.getByLabel("主要消耗").fill("集中工作一小时");
  await page.getByLabel("残留负荷").fill("需要确认一次范围反馈");
  await page.getByLabel("恢复或收口动作").fill("离开屏幕并记录反馈");
  await page.getByRole("button", { name: "收尾并保存" }).click();
  await expect(page.getByText("完成 · 已交付一页产品验收清单", { exact: true })).toBeVisible();

  await page.goto("/experiments");
  await page.getByLabel("完成原因").fill("观察窗口结束并完成一次交付");
  await page.getByRole("button", { name: "标记为已完成观察" }).click();
  await expect(page.getByText("实验观察已结束，请记录结果。")).toBeVisible();
  await page.getByLabel("规则决策").selectOption("adjust-parameter");
  await page.getByLabel("证据判断").selectOption("mixed");
  await page.getByLabel("观察到的结果").fill("对方一次确认了交付范围");
  await page.getByLabel("适用条件").fill("对方在咨询前阅读验收清单");
  await page.getByLabel("下一轮调整").fill("发送后补一次已读确认");
  await page.getByRole("button", { name: "保存结果" }).click();
  await expect(page.getByText("实验结果已记录，关联复盘已建立。")).toBeVisible();

  await page.goto("/reviews");
  await expect(page.getByRole("heading", { name: "实验判断" })).toBeVisible();
  await page.getByLabel("实际发生").fill("对方一次确认了交付范围");
  await page.getByLabel("主要差异").fill("确认次数下降，但仍需补一次已读确认");
  await page.getByLabel("可能原因").fill("书面清单减少了口头解释");
  await page.getByLabel("当时忽略的信号").fill("发送后没有确认对方已读");
  await page.getByLabel("下一轮准备改变什么").fill("发送清单后确认已读");
  await page.getByRole("button", { name: "保存实际结果" }).click();
  await page.getByLabel("规则标识").fill("delivery.acceptance-checklist");
  await page.getByLabel("新规则").fill("咨询前发送验收清单并确认已读");
  await page.getByLabel("变更依据").fill("已读确认是本轮缺失的关键事实");
  await page.getByRole("button", { name: "设为主规则变化" }).click();
  await page.getByRole("button", { name: "完成复盘" }).click();
  await expect(page.getByText("已完成", { exact: true }).first()).toBeVisible();
  await page.getByLabel("适用条件").fill("首次一对一咨询");
  await page.getByLabel("观察方法").fill("记录范围确认次数和已读状态");
  await page.getByLabel("撤回条件").fill("确认动作明显增加沟通成本");
  await page.getByRole("button", { name: "发布新版本" }).click();
  await expect(page.getByText("规则版本已保存")).toBeVisible();
});
