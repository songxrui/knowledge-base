import { AppShell as Shell, Button } from "@northstar/design-system";
import { NavLink, Outlet } from "react-router-dom";

import { useProduct } from "../providers.js";

const navigation = [
  ["/", "今日"],
  ["/experiments", "实验"],
  ["/projects", "项目"],
  ["/assets", "资产"],
  ["/reviews", "复盘"],
  ["/business", "经营"],
  ["/risks", "风险"],
  ["/settings", "设置"],
] as const;

export function ProductAppShell() {
  const { services, theme, setTheme } = useProduct();
  return (
    <Shell
      navigation={
        <div className="product-navigation">
          <div className="product-brand"><span aria-hidden="true">N</span><strong>Northstar</strong></div>
          <nav aria-label="主要导航">
            {navigation.map(([to, label]) => <NavLink key={to} to={to} end={to === "/"}>{label}</NavLink>)}
          </nav>
        </div>
      }
      header={
        <div className="product-topbar">
          <span>{services.platform.kind === "pwa" ? "本地浏览器" : services.platform.kind === "tauri-android" ? "Android" : "Windows"}</span>
          <Button tone="quiet" onPress={() => setTheme(theme === "light" ? "dark" : "light")}>{theme === "light" ? "深色" : "浅色"}</Button>
        </div>
      }
    >
      <Outlet />
    </Shell>
  );
}
