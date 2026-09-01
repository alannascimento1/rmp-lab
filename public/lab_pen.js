// Caneta de marcação do lab: D liga/desliga, arraste desenha um retângulo,
// C limpa, Esc sai. Os retângulos ficam ancorados no conteúdo ao rolar.
(function () {
  var canvas = document.createElement("canvas");
  canvas.id = "lab-pen-canvas";
  canvas.style.cssText = "position:fixed;inset:0;z-index:9998;pointer-events:none;";
  var pen = document.createElement("div");
  pen.style.cssText = "position:fixed;right:14px;bottom:12px;z-index:9999;display:none;" +
    "background:#111a17;color:#2ecc9a;border:1px solid #2f6d5b;border-radius:999px;" +
    "padding:4px 12px;font:12px system-ui,sans-serif;";
  pen.textContent = "modo marcação — arraste um retângulo; D sai, C limpa";

  var ctx = canvas.getContext("2d");
  var rects = [], cur = null, drawing = false, raf = 0;

  function sizeCanvas() {
    var dpr = window.devicePixelRatio || 1;
    canvas.width = Math.round(innerWidth * dpr);
    canvas.height = Math.round(innerHeight * dpr);
    canvas.style.width = innerWidth + "px";
    canvas.style.height = innerHeight + "px";
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.strokeStyle = "#1fa87e"; ctx.lineWidth = 3;
    ctx.lineCap = "round"; ctx.lineJoin = "round";
  }
  function redraw() {
    raf = 0;
    ctx.clearRect(0, 0, innerWidth, innerHeight);
    var sx = scrollX, sy = scrollY;
    rects.forEach(function (r) {
      var x = Math.min(r.x1, r.x2) - sx, y = Math.min(r.y1, r.y2) - sy;
      var w = Math.abs(r.x2 - r.x1), h = Math.abs(r.y2 - r.y1);
      if (w < 3 && h < 3) return;
      ctx.beginPath();
      if (ctx.roundRect) ctx.roundRect(x, y, w, h, 5); else ctx.rect(x, y, w, h);
      ctx.stroke();
    });
  }
  function schedule() { if (!raf) raf = requestAnimationFrame(redraw); }
  function toggle(on) {
    drawing = (on !== undefined) ? on : !drawing;
    canvas.style.pointerEvents = drawing ? "auto" : "none";
    canvas.style.cursor = drawing ? "crosshair" : "";
    pen.style.display = drawing ? "block" : "none";
    document.body.style.userSelect = drawing ? "none" : "";
    if (drawing) { sizeCanvas(); schedule(); }
  }
  canvas.addEventListener("pointerdown", function (e) {
    if (!drawing) return;
    canvas.setPointerCapture(e.pointerId);
    cur = { x1: e.pageX, y1: e.pageY, x2: e.pageX, y2: e.pageY };
    rects.push(cur); e.preventDefault();
  });
  canvas.addEventListener("pointermove", function (e) {
    if (!drawing || !cur) return;
    cur.x2 = e.pageX; cur.y2 = e.pageY; schedule();
  });
  ["pointerup", "pointercancel"].forEach(function (ev) {
    canvas.addEventListener(ev, function () {
      if (cur && Math.abs(cur.x2 - cur.x1) < 3 && Math.abs(cur.y2 - cur.y1) < 3) rects.pop();
      cur = null; schedule();
    });
  });
  window.addEventListener("scroll", function () { if (rects.length) schedule(); }, { passive: true });
  window.addEventListener("resize", function () { sizeCanvas(); schedule(); });
  document.addEventListener("keydown", function (e) {
    if (e.target && /INPUT|TEXTAREA|SELECT/.test(e.target.tagName)) return;
    var k = e.key.toLowerCase();
    if (k === "d") { toggle(); e.preventDefault(); }
    else if (k === "c") { rects = []; cur = null; schedule(); }
    else if (e.key === "Escape" && drawing) { toggle(false); }
  });

  document.addEventListener("DOMContentLoaded", function () {
    document.body.appendChild(canvas);
    document.body.appendChild(pen);
    sizeCanvas();
  });
})();
