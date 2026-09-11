import { expect, test } from "@playwright/test";

const bannedCopy = /赋能|解锁|重塑|智能洞察|改变一切/u;

test("keeps navigation, focus and copy usable across viewports", async ({ page, isMobile }) => {
  await page.emulateMedia({ reducedMotion: "reduce" });
  await page.goto("/");

  const navigation = page.getByRole("navigation", { name: "主要导航" });
  await expect(navigation).toBeVisible();
  await expect(navigation.getByRole("link")).toHaveCount(8);
  await expect(page.locator("body")).not.toContainText(bannedCopy);

  await page.keyboard.press("Tab");
  const focusedTag = await page.evaluate(() => document.activeElement?.tagName);
  expect(["A", "BUTTON", "INPUT", "SELECT", "TEXTAREA"]).toContain(focusedTag);

  for (const route of ["/experiments", "/projects", "/assets", "/reviews", "/business", "/risks", "/settings"]) {
    await page.goto(route);
    await expect(page.locator("h1")).toBeVisible();
    await expect(page.locator("body")).not.toContainText(bannedCopy);
    const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
    expect(overflow).toBeLessThanOrEqual(1);
  }

  if (isMobile) {
    const columns = await navigation.evaluate((element) => getComputedStyle(element).gridTemplateColumns.split(" ").length);
    expect(columns).toBe(4);
  }
});


test("opens from the PWA cache after the first online visit", async ({ context, page }, testInfo) => {
  test.skip(testInfo.project.name !== "desktop", "One offline cache check is sufficient.");
  await page.goto("/");
  await expect(page.getByRole("heading", { name: "先看现实，再定交付" })).toBeVisible();
  await page.evaluate(async () => navigator.serviceWorker.ready);
  await context.setOffline(true);
  try {
    await page.reload({ waitUntil: "domcontentloaded" });
    await expect(page.getByRole("heading", { name: "先看现实，再定交付" })).toBeVisible();
  } finally {
    await context.setOffline(false);
  }
});


test("protects an inspected import from accidental mobile navigation", async ({ page }, testInfo) => {
  test.skip(testInfo.project.name !== "android", "This covers the Android-sized navigation surface.");
  await page.goto("/settings");

  const downloadPromise = page.waitForEvent("download");
  await page.getByRole("button", { name: "导出本地数据" }).click();
  const download = await downloadPromise;
  const exportPath = await download.path();
  expect(exportPath).not.toBeNull();

  const chooserPromise = page.waitForEvent("filechooser");
  await page.getByRole("button", { name: "选择 JSON 文件" }).click();
  const chooser = await chooserPromise;
  await chooser.setFiles(exportPath ?? "");
  await expect(page.getByText("合并预览")).toBeVisible();

  page.once("dialog", async (dialog) => {
    expect(dialog.message()).toContain("放弃当前导入预览");
    await dialog.dismiss();
  });
  await page.getByRole("link", { name: "今日" }).click();
  await expect(page).toHaveURL(/\/settings$/u);
});