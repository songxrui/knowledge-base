/* ============================================================================
   hui · 叙事层
   ---------------------------------------------------------------------------
   结构参考 2019.makemepulse.com「Nomadic Tribe」的交互架构（已抓取其线上代码核对）：
     · 竖条装载量规 + transform 滑出，单一缓动 cubic-bezier(.215,.61,.355,1)
     · 一个「进入」门槛（真实手势，顺带取得音频许可）
     · 逐章手势解锁：长按 / 拖拽 / 点击 —— 每一步都要读者亲手推一下
     · 三片式按钮（左 / 中 / 右 + 前景滚动层），只动 transform
     · 150px 带状态光标：默认 / 悬停 / 拖拽 / 长按，按住时收起文字
     · 终章逐字落位
   我方差异（不照搬）：不使用其字体、贴图与美术资产；颜色仍只有深墨与信号青；
   所有内容在没有脚本时完整可读 —— 交互只负责"揭示"，不负责"存在"。
   ========================================================================== */
(() => {
  "use strict";

  const doc = document;
  const root = doc.documentElement;
  const body = doc.body;
  const qs = new URLSearchParams(location.search);
  const isStatic = qs.has("static") || qs.has("lite");
  const reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const calm = isStatic || reduce;
  const fine = matchMedia("(hover: hover) and (pointer: fine)").matches;

  const state = {
    ready: false,
    entered: false,
    audio: false,
    cursorLabel: "",
    chapters: { book: false, ledger: false, tools: false },
  };
  window.__story = state;

  const EASE = "cubic-bezier(.215,.61,.355,1)";
  const clamp = (v, a = 0, b = 1) => Math.min(b, Math.max(a, v));

  /* ── 装载量规 ────────────────────────────────────────────────────────── */

  const loader = doc.getElementById("loader");
  const fill = doc.getElementById("loader-fill");
  const num = doc.getElementById("loader-num");
  const gate = doc.getElementById("gate");

  let progress = 0;
  let shown = 0;
  const paint = () => {
    if (fill) fill.style.transform = `scaleY(${shown.toFixed(4)})`;
    if (num) num.textContent = String(Math.round(shown * 100)).padStart(3, "0");
  };
  const chase = () => {
    if (shown === progress) return;
    shown += (progress - shown) * (calm ? 1 : 0.18);
    if (Math.abs(progress - shown) < 0.002) shown = progress;
    paint();
    if (shown !== progress) requestAnimationFrame(chase);
  };
  const setProgress = (v) => {
    progress = clamp(v);
    chase();
  };
  paint();

  const tasks = [
    { label: "等字体", run: () => doc.fonts?.ready ?? Promise.resolve() },
    {
      label: "装配着色器",
      run: () =>
        new Promise((done) => requestAnimationFrame(() => requestAnimationFrame(done))),
    },
    {
      label: "对齐版面",
      run: () =>
        new Promise((done) =>
          doc.readyState === "complete" ? done() : addEventListener("load", done, { once: true }),
        ),
    },
  ];

  (async () => {
    if (calm) {
      setProgress(1);
      const what = doc.getElementById("loader-what");
      if (what) what.textContent = "就绪";
      finish(true);
      return;
    }
    for (let i = 0; i < tasks.length; i++) {
      const what = doc.getElementById("loader-what");
      if (what) what.textContent = tasks[i].label;
      try {
        await tasks[i].run();
      } catch {
        /* 单步失败不阻塞：装载只是等待，不是校验 */
      }
      setProgress((i + 1) / tasks.length);
    }
    finish(false);
  })();

  function finish(instant) {
    progress = 1;
    shown = 1;
    paint();
    loader?.classList.add("is-done");
    state.ready = true;
    if (instant) {
      enter(true);
    } else {
      if (gate) {
        gate.hidden = false;
        requestAnimationFrame(() => {
          gate.classList.add("is-on");
          // 门槛可键盘进入：焦点直接落在按钮上
          doc.getElementById("enter")?.focus({ preventScroll: true });
        });
      }
    }
  }

  function enter(instant) {
    if (state.entered) return;
    state.entered = true;
    body.classList.add("is-entered");
    body.classList.remove("is-loading");
    gate?.classList.remove("is-on");
    if (gate) {
      if (instant) gate.hidden = true;
      else setTimeout(() => (gate.hidden = true), 820);
    }
    if (loader) setTimeout(() => (loader.hidden = true), 900);

    const hero = doc.getElementById("top");
    hero?.querySelectorAll(".panel__body > *").forEach((el, i) => {
      el.style.setProperty("--i", `${i * 90}ms`);
    });
    hero?.classList.add("is-in");
    doc.querySelector(".kinetic")?.classList.add("is-in");
    setActiveChapter("top");
    if (!calm) audio?.set(true);
  }

  doc.getElementById("enter")?.addEventListener("click", () => enter(false));

  /* ── 章节：手势解锁 ──────────────────────────────────────────────────── */

  const chapters = [...doc.querySelectorAll("[data-chapter]")];

  // 有脚本且非静止模式时，才把"待解锁"的材料遮蔽起来；
  // 没有脚本时这些内容原样可读（交互只负责揭示，不负责存在）。
  const lockables = [];
  if (!calm) {
    chapters.forEach((section) => {
      section.querySelectorAll(".preview--locked").forEach((fig) => {
        fig.classList.add("is-locked");
        lockables.push(fig);
      });
    });
  }

  function unlock(section) {
    const id = section.dataset.chapter;
    if (!id || state.chapters[id]) return;
    state.chapters[id] = true;
    section.dataset.done = "1";
    section.querySelectorAll(".preview--locked").forEach((fig) => fig.classList.remove("is-locked"));
    section.querySelectorAll(".gesture").forEach((card) => card.classList.add("is-done"));
    setActiveChapter(id);
  }

  function setActiveChapter(id) {
    doc.querySelectorAll("[data-chapter-dot]").forEach((dot) => {
      dot.classList.toggle("is-on", dot.dataset.chapterDot === id);
    });
  }

  /* 长按：按住不放，序言逐句浮现 */
  function wireHold(section) {
    const holdTarget = section.querySelector("[data-hold]");
    const card = section.querySelector('[data-gesture-card="hold"]');
    const track = card?.querySelector(".gesture__track i");
    if (!holdTarget) return;
    const lines = [...holdTarget.querySelectorAll("[data-line]")];
    const DURATION = 2000;
    let value = 0;
    let holding = false;
    let frame = 0;
    let last = 0;
    let done = false;

    const render = () => {
      const span = lines.length;
      lines.forEach((el, i) => {
        const at = (i + 0.6) / span;
        el.classList.toggle("is-on", value >= at);
      });
      if (track) track.style.transform = `scaleX(${value.toFixed(4)})`;
    };

    const step = (now) => {
      const dt = last ? now - last : 16;
      last = now;
      if (holding) value = clamp(value + dt / DURATION);
      render();
      if (value >= 1 && !done) {
        done = true;
        unlock(section);
      }
      if (holding || value !== 1) frame = requestAnimationFrame(step);
      else frame = 0;
    };

    const start = () => {
      if (done) return;
      holding = true;
      cursorHold(true);
      if (!frame) {
        last = 0;
        frame = requestAnimationFrame(step);
      }
    };
    const stop = () => {
      holding = false;
      cursorHold(false);
    };

    holdTarget.addEventListener("pointerdown", (e) => {
      e.preventDefault();
      start();
    });
    addEventListener("pointerup", stop, { passive: true });
    addEventListener("pointercancel", stop, { passive: true });
    holdTarget.addEventListener("pointerleave", stop);

    if (calm) {
      value = 1;
      render();
      unlock(section);
    }
  }

  /* 拖拽：左右扫过十五周节律，同时逐行扫开卡片元数据 */
  function wireDrag(section) {
    const scrub = section.querySelector("[data-scrub]");
    const head = doc.getElementById("pulse-head");
    const read = doc.getElementById("pulse-read");
    if (!scrub) return;
    const bars = [...scrub.querySelectorAll("span[data-week]")];
    const pre = section.querySelector("[data-scan]");

    let scanLines = [];
    if (pre) {
      const text = pre.textContent ?? "";
      pre.textContent = "";
      scanLines = text.split("\n").map((line) => {
        const span = doc.createElement("span");
        span.className = "artifact__line";
        span.textContent = line.length ? line : " ";
        pre.append(span, doc.createTextNode("\n"));
        return span;
      });
      pre.classList.add("is-scannable");
    }

    let swept = 0;
    let dragging = false;
    let done = false;

    const apply = (ratio) => {
      const r = clamp(ratio);
      swept = Math.max(swept, r);
      if (head) head.style.transform = `translate3d(${(r * 100).toFixed(2)}%, 0, 0)`;
      const index = Math.min(bars.length - 1, Math.floor(r * bars.length));
      const bar = bars[index];
      bars.forEach((b, i) => b.classList.toggle("is-live", i === index));
      if (bar && read) read.textContent = `第 ${bar.dataset.week} 周 · ${bar.dataset.v} 次`;
      scanLines.forEach((span, i) => {
        span.classList.toggle("is-on", r * (scanLines.length + 1) >= i + 1);
      });
      if (swept > 0.9 && !done) {
        done = true;
        unlock(section);
      }
    };

    const ratioFrom = (clientX) => {
      const rect = scrub.getBoundingClientRect();
      return (clientX - rect.left) / Math.max(1, rect.width);
    };

    scrub.addEventListener("pointerdown", (e) => {
      dragging = true;
      cursorHold(true);
      scrub.setPointerCapture?.(e.pointerId);
      apply(ratioFrom(e.clientX));
    });
    scrub.addEventListener("pointermove", (e) => {
      if (dragging) apply(ratioFrom(e.clientX));
    });
    const end = () => {
      dragging = false;
      cursorHold(false);
    };
    scrub.addEventListener("pointerup", end);
    scrub.addEventListener("pointercancel", end);
    // 键盘同样可用
    scrub.addEventListener("keydown", (e) => {
      const stepRatio = (e.shiftKey ? 0.2 : 0.07) * (e.key === "ArrowLeft" ? -1 : 1);
      if (e.key === "ArrowLeft" || e.key === "ArrowRight") {
        e.preventDefault();
        apply((dragging ? swept : 0.04) + stepRatio);
      }
    });

    if (calm) {
      apply(1);
      unlock(section);
    }
  }

  /* 点击：跑一遍红线门判决，逐行输出 */
  const REPORT = [
    { t: "FAIL  05-内容生产/进行中/能力越小，先承担的责任越小-研究扩展稿.md", c: "fail" },
    { t: "      L1  禁「不是…而是…」对仗替代因果    11 处", c: "hit" },
    { t: "      P1  80% 段落应 ≥120 字              25/57 段不足", c: "hit" },
    { t: "", c: "" },
    { t: "18 篇 · 通过 1 · 拦截 17 · 红线命中 47", c: "sum" },
  ];

  function wireRun(section) {
    const target = section.querySelector("[data-run]");
    const card = section.querySelector('[data-gesture-card="tap"]');
    if (!target) return;

    // 内容先写进 DOM（SEO 与无脚本可读），脚本再把它们按行藏起来
    const source = target.textContent?.trim()
      ? target.textContent.trim().split("\n")
      : REPORT.map((r) => r.t);
    target.textContent = "";
    const rows = source.map((line) => {
      const span = doc.createElement("span");
      span.className = "artifact__line";
      span.textContent = line.length ? line : " ";
      target.append(span, doc.createTextNode("\n"));
      return span;
    });

    let done = false;
    const run = () => {
      if (done) return;
      done = true;
      rows.forEach((span, i) => {
        const delay = calm ? 0 : 90 + i * 150;
        setTimeout(() => span.classList.add("is-on"), delay);
      });
      if (card) card.classList.add("is-done");
      unlock(section);
    };

    target.addEventListener("pointerdown", run);
    target.addEventListener("click", run);
    section.querySelector(".gesture")?.addEventListener("click", run);
    if (calm) {
      rows.forEach((span) => span.classList.add("is-on"));
      unlock(section);
    }
  }

  chapters.forEach((section) => {
    const gesture = section.dataset.gesture;
    if (gesture === "hold") wireHold(section);
    else if (gesture === "drag") wireDrag(section);
    else if (gesture === "tap") wireRun(section);
  });

  /* ── 光标：150px，带状态与文字 ───────────────────────────────────────── */

  let cursorHoldState = false;
  function cursorHold(on) {
    cursorHoldState = on;
    const el = doc.getElementById("cursor");
    if (el) el.dataset.holding = on ? "1" : "0";
  }

  function wireCursor() {
    const el = doc.getElementById("cursor");
    const label = doc.getElementById("cursor-label");
    const read = doc.getElementById("cursor-read");
    if (!el) return;
    if (!fine || isStatic) return;

    root.classList.add("has-cursor");

    let x = 0;
    let y = 0;
    let cx = 0;
    let cy = 0;
    let on = false;

    addEventListener(
      "pointermove",
      (e) => {
        x = e.clientX;
        y = e.clientY;
        if (!on) {
          on = true;
          el.dataset.on = "1";
        }
        const target = e.target instanceof Element ? e.target.closest("[data-cursor],[data-hold],[data-scrub],[data-run]") : null;
        const text =
          target?.getAttribute("data-cursor") ??
          (target?.hasAttribute("data-hold")
            ? "长按"
            : target?.hasAttribute("data-scrub")
              ? "拖拽"
              : target?.hasAttribute("data-run")
                ? "点击"
                : "");
        if (text !== state.cursorLabel) {
          state.cursorLabel = text;
          if (label) label.textContent = text;
          el.dataset.hot = text ? "1" : "0";
        }
      },
      { passive: true },
    );
    addEventListener("pointerleave", () => {
      on = false;
      el.dataset.on = "0";
    });

    (function follow() {
      cx += (x - cx) * 0.32;
      cy += (y - cy) * 0.32;
      el.style.transform = `translate3d(${cx.toFixed(2)}px, ${cy.toFixed(2)}px, 0)`;
      if (read && (Math.abs(x - cx) > 0.4 || Math.abs(y - cy) > 0.4)) {
        read.textContent = `${Math.round(cx)},${Math.round(cy)}`;
      }
      requestAnimationFrame(follow);
    })();
  }
  wireCursor();

  /* ── 声音：合成环境音，不放任何音频文件 ─────────────────────────────── */

  const audio = (() => {
    const btn = doc.getElementById("audio");
    if (!btn) return null;
    let ctx = null;
    let master = null;
    let on = false;

    const build = () => {
      const Ctx = window.AudioContext || window.webkitAudioContext;
      if (!Ctx) return false;
      ctx = new Ctx();
      master = ctx.createGain();
      master.gain.value = 0;
      master.connect(ctx.destination);

      const filter = ctx.createBiquadFilter();
      filter.type = "lowpass";
      filter.frequency.value = 380;
      filter.Q.value = 0.7;
      filter.connect(master);

      const low = ctx.createOscillator();
      low.type = "sine";
      low.frequency.value = 55;
      low.connect(filter);

      const mid = ctx.createOscillator();
      mid.type = "triangle";
      mid.frequency.value = 82.5;
      mid.detune.value = 7;
      const midGain = ctx.createGain();
      midGain.gain.value = 0.34;
      mid.connect(midGain);
      midGain.connect(filter);

      const lfo = ctx.createOscillator();
      lfo.frequency.value = 0.045;
      const lfoGain = ctx.createGain();
      lfoGain.gain.value = 170;
      lfo.connect(lfoGain);
      lfoGain.connect(filter.frequency);

      // 噪声层：棕色噪声，只给一点空气感
      const length = ctx.sampleRate * 2;
      const buffer = ctx.createBuffer(1, length, ctx.sampleRate);
      const data = buffer.getChannelData(0);
      let last = 0;
      for (let i = 0; i < length; i++) {
        const white = Math.random() * 2 - 1;
        last = (last + 0.02 * white) / 1.02;
        data[i] = last * 3.2;
      }
      const noise = ctx.createBufferSource();
      noise.buffer = buffer;
      noise.loop = true;
      const noiseGain = ctx.createGain();
      noiseGain.gain.value = 0.05;
      noise.connect(noiseGain);
      noiseGain.connect(filter);

      low.start();
      mid.start();
      lfo.start();
      noise.start();
      return true;
    };

    const set = (next) => {
      if (next && !ctx && !build()) return;
      if (!ctx) return;
      on = next;
      if (on && ctx.state === "suspended") ctx.resume();
      const t = ctx.currentTime;
      master.gain.cancelScheduledValues(t);
      master.gain.setValueAtTime(master.gain.value, t);
      master.gain.linearRampToValueAtTime(on ? 0.07 : 0, t + 1.2);
      btn.setAttribute("aria-pressed", String(on));
      btn.setAttribute("aria-label", on ? "关闭声音" : "打开声音");
      btn.classList.toggle("is-on", on);
      state.audio = on;
    };

    btn.addEventListener("click", () => set(!on));
    return { set, get on() { return on; } };
  })();

  /* ── 终章：逐字落位 ─────────────────────────────────────────────────── */

  const finale = doc.querySelector("[data-split]");
  if (finale) {
    const source = finale.querySelector(".finale__src");
    const text = finale.dataset.split ?? "";
    const frag = doc.createDocumentFragment();
    [...text].forEach((ch, i) => {
      const span = doc.createElement("span");
      span.className = "finale__g";
      span.textContent = ch;
      span.style.setProperty("--d", `${i * 60}ms`);
      frag.append(span);
    });
    source?.after(frag);
    source?.remove();
  }

  if (calm) {
    doc.querySelectorAll(".finale__g").forEach((g) => g.classList.add("is-on"));
  }

  /* ── 章节点与终章：进入视口时点亮 ───────────────────────────────────── */

  const watcher = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue;
        const id = entry.target.id;
        if (id && entry.target.dataset.chapter) {
          doc.querySelectorAll("[data-chapter-dot]").forEach((dot) =>
            dot.classList.toggle("is-on", dot.dataset.chapterDot === id),
          );
        }
        if (id === "contact") {
          doc.querySelectorAll(".finale__g").forEach((g, i) => {
            setTimeout(() => g.classList.add("is-on"), calm ? 0 : i * 60);
          });
        }
      }
    },
    { rootMargin: "-45% 0px -50% 0px" },
  );
  [...chapters, doc.getElementById("contact")].forEach((el) => el && watcher.observe(el));

  // 终章在窄屏或不支持观察器时也要能落位
  if (!("IntersectionObserver" in window)) {
    doc.querySelectorAll(".finale__g").forEach((g) => g.classList.add("is-on"));
  }

  /* 供验收脚本读取内部状态 */
  window.__story.enter = enter;
  window.__story.unlockAll = () => chapters.forEach((s) => unlock(s));
  window.__story.ease = EASE;
})();
