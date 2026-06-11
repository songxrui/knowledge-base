// DS SessionInit — validates DS optimization state at session start
const fs = require("fs"), path = require("path"), os = require("os");
let buf = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (c) => { buf += c; });
process.stdin.on("end", () => {
  try {
    const input = JSON.parse(buf);
    const home = os.homedir();
    const configPath = path.join(home, ".codex", "config.toml");
    const agentsPath = path.join(home, ".codex", "AGENTS.md");
    
    const checks = [];
    
    // Check 1: Model is deepseek-v4-pro
    const config = fs.readFileSync(configPath, "utf8");
    if (config.includes("deepseek-v4-pro")) checks.push("✅ model=DSv4Pro");
    else checks.push("❌ model not DS");
    
    // Check 2: Retry >= 3
    if (config.includes("max_retries = 3")) checks.push("✅ retry=3");
    else checks.push("⚠️ retry<3");
    
    // Check 3: Multi-agent enabled
    if (config.includes("multi_agent = true")) checks.push("✅ multi_agent");
    else checks.push("⚠️ multi_agent off");
    
    // Check 4: AGENTS.md has DS profile
    const agents = fs.readFileSync(agentsPath, "utf8");
    if (agents.includes("DS v4 Pro")) checks.push("✅ DS profile in AGENTS.md");
    else checks.push("❌ DS profile missing");
    
    // Check 5: Headroom MCP
    if (config.includes("[mcp_servers.headroom]")) checks.push("✅ headroom MCP");
    else checks.push("⚠️ headroom not configured");
    
    // Log
    const logDir = path.join(home, ".codex");
    fs.appendFileSync(
      path.join(logDir, "ds-session-check.log"),
      `[${new Date().toISOString()}] ${input.session_id || "?"} | ${checks.join(" | ")}\n`,
      "utf8"
    );
    
    // Inject DS mode env
    process.env.CODEX_DS_MODE = "1";
    process.env.CODEX_DS_VERIFY = "true";
  } catch (e) { /* never fail the hook */ }
});
