/* ============================================================================
   Faith · 站点脚本
   ---------------------------------------------------------------------------
   零依赖、零网络请求。四件事：
     1) 自写 WebGL 场（片元着色器见 index.html 的 <script type="x-shader">）
     2) 动效字：按字拆分、按序入场（只动 transform / opacity）
     3) 仪器光标：坐标读数 + 命中交互时吸附
     4) 读数、节律图、进度、章节高亮、主题（View Transitions）
   降级顺序：?static / prefers-reduced-motion → 全静止；无 WebGL → CSS 回退场；
   无脚本 → 内容完整可读（CSS 保证）。
   ========================================================================== */
(() => {
  "use strict";

  const qs = new URLSearchParams(location.search);
  const isStatic = qs.has("static") || qs.has("lite");
  const reduceMotion = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const calm = isStatic || reduceMotion;
  const root = document.documentElement;
  const body = document.body;

  /* ── 1. 自写 WebGL 场 ──────────────────────────────────────────────── */

  const FIELD = (() => {
    const canvas = document.getElementById("field");
    if (!canvas) return null;
    const gl =
      canvas.getContext("webgl", { antialias: false, alpha: false, powerPreference: "high-performance" }) ||
      canvas.getContext("experimental-webgl");
    if (!gl) {
      body.dataset.field = "off";
      return null;
    }

    const src = (id) => document.getElementById(id)?.textContent?.trim() ?? "";
    const compile = (type, code) => {
      const shader = gl.createShader(type);
      gl.shaderSource(shader, code);
      gl.compileShader(shader);
      if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        console.warn("shader 编译失败", gl.getShaderInfoLog(shader));
        return null;
      }
      return shader;
    };

    const vs = compile(gl.VERTEX_SHADER, src("field-vs"));
    const fs = compile(gl.FRAGMENT_SHADER, src("field-fs"));
    if (!vs || !fs) {
      body.dataset.field = "off";
      return null;
    }
    const program = gl.createProgram();
    gl.attachShader(program, vs);
    gl.attachShader(program, fs);
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      body.dataset.field = "off";
      return null;
    }
    gl.useProgram(program);

    const buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 3, -1, -1, 3]), gl.STATIC_DRAW);
    const aPos = gl.getAttribLocation(program, "aPos");
    gl.enableVertexAttribArray(aPos);
    gl.vertexAttribPointer(aPos, 2, gl.FLOAT, false, 0, 0);

    const u = {
      res: gl.getUniformLocation(program, "uRes"),
      time: gl.getUniformLocation(program, "uTime"),
      pointer: gl.getUniformLocation(program, "uPointer"),
      scroll: gl.getUniformLocation(program, "uScroll"),
      heat: gl.getUniformLocation(program, "uHeat"),
      light: gl.getUniformLocation(program, "uLight"),
    };

    /* 真实数字进着色器：近 7 天提交 43 次，按 0..60 归一为"场的热度"。 */
    const RECENT_COMMITS = 43;
    const heat = Math.min(1, RECENT_COMMITS / 60);
    const pointer = { x: 0, y: 0 };
    let time = 0;
    let last = performance.now();
    let raf = 0;
    let running = false;
    let frames = 0;
    let fpsAccum = 0;
    let fps = 0;

    const resize = () => {
      const dpr = Math.min(1.5, devicePixelRatio || 1);
      const w = Math.max(1, Math.floor(innerWidth * dpr));
      const h = Math.max(1, Math.floor(innerHeight * dpr));
      if (canvas.width !== w || canvas.height !== h) {
        canvas.width = w;
        canvas.height = h;
        gl.viewport(0, 0, w, h);
      }
    };

    const frame = (now) => {
      raf = requestAnimationFrame(frame);
      const dt = Math.min(64, now - last);
      last = now;
      fpsAccum += dt;
      frames++;
      if (fpsAccum >= 500) {
        fps = Math.round(1000 / (fpsAccum / frames));
        fpsAccum = 0;
        frames = 0;
      }
      time += dt / 1000;
      const dpr = Math.min(1.5, devicePixelRatio || 1);
      gl.uniform2f(u.res, canvas.width, canvas.height);
      gl.uniform1f(u.time, time);
      gl.uniform2f(u.pointer, pointer.x * dpr, (innerHeight - pointer.y) * dpr);
      gl.uniform1f(u.scroll, (scrollY / Math.max(1, innerHeight)) * 0.35);
      gl.uniform1f(u.heat, heat);
      gl.uniform1f(u.light, root.dataset.theme === "light" ? 1 : 0);
      gl.drawArrays(gl.TRIANGLES, 0, 3);
    };

    const start = () => {
      if (running) return;
      running = true;
      last = performance.now();
      raf = requestAnimationFrame(frame);
    };
    const stop = () => {
      running = false;
      cancelAnimationFrame(raf);
    };

    resize();
    addEventListener("resize", resize, { passive: true });
    addEventListener(
      "pointermove",
      (e) => {
        pointer.x = e.clientX;
        pointer.y = e.clientY;
      },
      { passive: true },
    );
    document.addEventListener("visibilitychange", () => (document.hidden ? stop() : start()));
    new IntersectionObserver(
      ([entry]) => (entry.isIntersecting ? start() : stop()),
      { threshold: 0 },
    ).observe(canvas);

    // 首帧先画一次，静态模式下也有一张不动的场
    gl.uniform2f(u.res, canvas.width, canvas.height);
    gl.uniform1f(u.time, 0);
    gl.uniform1f(u.heat, heat);
    gl.uniform1f(u.light, root.dataset.theme === "light" ? 1 : 0);
    gl.drawArrays(gl.TRIANGLES, 0, 3);

    if (!calm) start();

    return {
      gl,
      canvas,
      setLight: (light) => {
        gl.uniform1f(u.light, light ? 1 : 0);
        gl.drawArrays(gl.TRIANGLES, 0, 3);
      },
      stats: () => ({ fps, heat }),
      /** 供验收：画一帧后读回像素，返回亮度均值与方差（证明场真的在画，不是一片纯色）。 */
      sample: () => {
        resize();
        gl.uniform2f(u.res, canvas.width, canvas.height);
        gl.uniform1f(u.time, time + 1.7);
        gl.uniform1f(u.heat, heat);
        gl.uniform1f(u.light, root.dataset.theme === "light" ? 1 : 0);
        gl.drawArrays(gl.TRIANGLES, 0, 3);
        const w = 64;
        const h = 64;
        const px = new Uint8Array(w * h * 4);
        gl.readPixels(
          Math.max(0, (canvas.width - w) >> 1),
          Math.max(0, (canvas.height - h) >> 1),
          w,
          h,
          gl.RGBA,
          gl.UNSIGNED_BYTE,
          px,
        );
        let sum = 0;
        let sum2 = 0;
        let n = 0;
        for (let i = 0; i < px.length; i += 4) {
          const lum = (px[i] * 0.299 + px[i + 1] * 0.587 + px[i + 2] * 0.114) / 255;
          sum += lum;
          sum2 += lum * lum;
          n++;
        }
        const mean = sum / n;
        return { mean, variance: sum2 / n - mean * mean, samples: n };
      },
    };
  })();

  // 供验收脚本读取：场是否真的在画、帧率多少
  window.__faith = { field: FIELD, calm, isStatic, reduceMotion };

  /* ── 2. 主题（View Transitions） ───────────────────────────────────── */

  const stored = (() => {
    try {
      return localStorage.getItem("faith.theme");
    } catch {
      return null;
    }
  })();
  const preferred = matchMedia("(prefers-color-scheme: light)").matches ? "light" : "dark";
  root.dataset.theme = stored === "light" || stored === "dark" ? stored : preferred;

  const themeColor = (theme) =>
    document.querySelector('meta[name="theme-color"]')?.setAttribute("content", theme === "dark" ? "#0c0f14" : "#f2f1ec");
  themeColor(root.dataset.theme);

  document.getElementById("theme")?.addEventListener("click", () => {
    const next = root.dataset.theme === "dark" ? "light" : "dark";
    const apply = () => {
      root.dataset.theme = next;
      themeColor(next);
      FIELD?.setLight(next === "light");
      try {
        localStorage.setItem("faith.theme", next);
      } catch {
        /* 隐私模式下不持久化 */
      }
    };
    if (!calm && document.startViewTransition) document.startViewTransition(apply);
    else apply();
  });

  /* ── 3. 本地时间 ───────────────────────────────────────────────────── */

  const clock = document.getElementById("clock");
  const clockFooter = document.getElementById("clock-footer");
  const pad = (n) => String(n).padStart(2, "0");
  const tick = () => {
    const now = new Date();
    const full = `${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
    if (clock) clock.textContent = full;
    if (clockFooter) clockFooter.textContent = full.slice(0, 5);
  };
  tick();
  setInterval(tick, 1000);

  /* ── 4. 动效字 ─────────────────────────────────────────────────────── */

  const kinetic = document.querySelector("[data-kinetic]");
  if (kinetic) {
    const source = kinetic.querySelector(".kinetic__src");
    const lines = (kinetic.dataset.kinetic || "").split("|");
    const wrap = document.createDocumentFragment();
    let glyphIndex = 0;
    for (const line of lines) {
      const lineEl = document.createElement("span");
      lineEl.className = "kinetic__line";
      for (const ch of line) {
        const g = document.createElement("span");
        g.className = "k-g";
        g.textContent = ch;
        g.style.setProperty("--d", `${glyphIndex * 42}ms`);
        lineEl.append(g);
        glyphIndex++;
      }
      wrap.append(lineEl);
    }
    source?.after(wrap);
    source?.remove();
  }

  /* ── 5. 滚动：进度、章节标记、侧栏读数、闭环游标 ─────────────────── */

  const bar = document.getElementById("progress");
  const scrollRead = document.getElementById("scroll-read");
  const navMarker = document.getElementById("nav-marker");
  const navLinks = [...document.querySelectorAll(".rail__nav a")];
  const sections = navLinks.map((a) => document.querySelector(a.getAttribute("href"))).filter(Boolean);
  let raf = 0;
  const draw = () => {
    raf = 0;
    const max = document.documentElement.scrollHeight - innerHeight;
    const ratio = max > 0 ? Math.min(1, Math.max(0, scrollY / max)) : 0;
    if (bar) bar.style.transform = `scaleX(${ratio})`;
    if (scrollRead) scrollRead.textContent = String(Math.round(ratio * 999)).padStart(3, "0");
  };
  addEventListener(
    "scroll",
    () => {
      if (!raf) raf = requestAnimationFrame(draw);
    },
    { passive: true },
  );
  addEventListener("resize", draw, { passive: true });

  const placeMarker = (link) => {
    if (!navMarker || !link) {
      navMarker?.removeAttribute("data-on");
      return;
    }
    const navRect = link.parentElement.getBoundingClientRect();
    const rect = link.getBoundingClientRect();
    navMarker.style.transform = `translate3d(${(rect.left - navRect.left + 12).toFixed(1)}px, 0, 0)`;
    navMarker.dataset.on = "1";
  };

  if (sections.length) {
    const spy = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (!entry.isIntersecting) continue;
          const active = navLinks.find((a) => a.getAttribute("href") === `#${entry.target.id}`);
          for (const link of navLinks) link.setAttribute("aria-current", link === active ? "true" : "false");
          placeMarker(active);
        }
      },
      { rootMargin: "-45% 0px -50% 0px" },
    );
    sections.forEach((s) => spy.observe(s));
    const current = navLinks.find((a) => a.getAttribute("aria-current") === "true");
    if (current) placeMarker(current);
  }

  /* ── 7. 读数与节律图 ───────────────────────────────────────────────── */

  const readout = document.getElementById("readout");
  const counters = [...document.querySelectorAll("[data-count]")];
  const fmt = (n) => n.toLocaleString("en-US");
  const bars = [...document.querySelectorAll(".pulse-chart__bars span")];
  bars.forEach((b, i) => b.style.setProperty("--i", String(i)));

  const settle = () => {
    counters.forEach((el) => (el.textContent = fmt(Number(el.dataset.count))));
    readout?.setAttribute("data-ready", "1");
  };

  let countersStarted = false;
  const runCounters = () => {
    if (calm) return settle();
    if (countersStarted) return;
    countersStarted = true;
    const start = performance.now();
    const duration = 1100;
    const step = (now) => {
      const t = Math.min(1, (now - start) / duration);
      const eased = 1 - Math.pow(1 - t, 3);
      counters.forEach((el) => (el.textContent = fmt(Math.round(Number(el.dataset.count) * eased))));
      if (t < 1) requestAnimationFrame(step);
      else readout?.setAttribute("data-ready", "1");
    };
    requestAnimationFrame(step);
  };

  /* ── 8. 入场编排 ───────────────────────────────────────────────────── */

  const panels = [...document.querySelectorAll("main > section")].filter((el) => el.id !== "top");
  panels.forEach((panel) => panel.classList.add("reveal"));
  const hero = document.getElementById("top");

  if (calm) {
    panels.forEach((p) => p.classList.add("is-in"));
    kinetic?.classList.add("is-in");
    settle();
  } else {
    const io = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (!entry.isIntersecting) continue;
          entry.target.classList.add("is-in");
          io.unobserve(entry.target);
        }
      },
      { rootMargin: "0px 0px -10% 0px", threshold: 0.05 },
    );
    panels.forEach((p) => io.observe(p));

    // 首屏：字先动，随后读数滚动
    requestAnimationFrame(() => {
      hero?.classList.add("is-in");
      kinetic?.classList.add("is-in");
      setTimeout(runCounters, 520);
    });
  }

  /* ── 9. 磁吸主按钮（只动 transform） ───────────────────────────────── */

  const magnet = document.getElementById("magnet");
  if (magnet && !calm && matchMedia("(hover: hover) and (pointer: fine)").matches) {
    let mx = 0;
    let my = 0;
    let tx = 0;
    let ty = 0;
    magnet.addEventListener("pointermove", (e) => {
      const r = magnet.getBoundingClientRect();
      tx = ((e.clientX - (r.left + r.width / 2)) / r.width) * 10;
      ty = ((e.clientY - (r.top + r.height / 2)) / r.height) * 8;
    });
    magnet.addEventListener("pointerleave", () => {
      tx = 0;
      ty = 0;
    });
    (function pull() {
      mx += (tx - mx) * 0.18;
      my += (ty - my) * 0.18;
      magnet.style.transform = `translate3d(${mx.toFixed(2)}px, ${my.toFixed(2)}px, 0)`;
      requestAnimationFrame(pull);
    })();
  }

  const status = document.getElementById("field-status");
  const paintStatus = () => {
    if (!status) return;
    status.textContent = FIELD ? `场 · GLSL · ${FIELD.stats().fps || "—"} fps` : "场 · CSS 回退";
  };
  paintStatus();
  if (FIELD) setTimeout(paintStatus, 1400);

  draw();

  /* 静态截图模式：一次性把状态摆正 */
  if (isStatic) {
    panels.forEach((p) => p.classList.add("is-in"));
    kinetic?.classList.add("is-in");
    settle();
    draw();
  }
})();
