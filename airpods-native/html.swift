let indexHTML = """
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>AirPods · Posture</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
:root{
  --bg:#121212;--card:#1e1e1e;--accent:#00ffaa;--blue:#33b5e5;
  --red:#ff4444;--warn:#ffaa00;--dim:#555;--text:#fff;
  /* cube size: масштабируется от вьюпорта, чтобы куб всегда влезал */
  --cs:clamp(80px, min(34vw, 26vh), 150px);
}
body{background:var(--bg);color:var(--text);
  font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Arial,sans-serif;
  min-height:100vh}

/* ── Мобильный layout (по умолчанию) ── */
.page{display:flex;flex-direction:column;align-items:center;
  padding:20px 14px 36px;gap:14px}
header{text-align:center;width:100%;max-width:400px}
h1{font-size:1.4rem;color:var(--accent);margin-bottom:3px}
.subtitle{font-size:.8rem;color:var(--dim);margin-bottom:6px}
.left-col,.right-col{display:contents}
.left-top,.left-bot{display:contents}

/* 3D куб (WebGL) */
.scene-wrap{width:100%;display:flex;justify-content:center;overflow:visible}
.scene{width:calc(var(--cs)*1.85);height:calc(var(--cs)*1.85);flex-shrink:0}
#cube3d{width:100%;height:100%;display:block}

/* Track-switch flash */
.track-flash{position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);
  font-size:2.5rem;font-weight:900;color:var(--accent);
  text-shadow:0 0 20px var(--accent);pointer-events:none;
  opacity:0;transition:opacity .15s;z-index:999}
.track-flash.show{opacity:1}

/* Карточки */
.card{background:var(--card);border-radius:12px;padding:14px;width:100%;max-width:400px}
.card-title{font-size:.7rem;text-transform:uppercase;letter-spacing:.08em;color:var(--dim);margin-bottom:10px}

/* Углы */
.angles{display:grid;grid-template-columns:1fr 1fr 1fr;gap:8px;text-align:center}
.angle-val{font-family:monospace;font-size:1.2rem;font-weight:bold}
.angle-lbl{font-size:.65rem;color:var(--dim);margin-top:2px}

/* Осанка */
.posture-row{display:flex;align-items:center;gap:10px;margin-bottom:10px}
.dot{width:16px;height:16px;border-radius:50%;flex-shrink:0;transition:background .3s}
.dot.good{background:var(--accent);box-shadow:0 0 7px #00ffaa66}
.dot.bad{background:var(--red);box-shadow:0 0 7px #ff444466;animation:pulse .6s infinite alternate}
.dot.idle{background:#333}
@keyframes pulse{to{box-shadow:0 0 14px #ff444499}}
.posture-lbl{font-size:.95rem;font-weight:bold;flex:1}
.posture-timer{font-family:monospace;font-size:.8rem;color:var(--dim)}
.bar-row{display:flex;align-items:center;gap:8px;margin-bottom:6px}
#postureGraph{width:200px;height:auto}
.bar-name{font-size:.7rem;color:#777;width:42px;flex-shrink:0}
.bar-track{flex:1;height:5px;background:#282828;border-radius:3px;overflow:hidden}
.bar-fill{height:100%;border-radius:3px;transition:width .1s,background .2s}
.bar-val{font-family:monospace;font-size:.7rem;color:var(--dim);width:38px;text-align:right;flex-shrink:0}

/* Музыка */
.music-section{display:flex;flex-direction:column;gap:8px}
.toggle-row{display:flex;align-items:center;gap:8px}
.toggle-row label{font-size:.85rem;color:#bbb;cursor:pointer}

/* Тоглы-свитчи вместо чекбоксов */
.toggle-row input[type=checkbox],.sg input[type=checkbox]{
  -webkit-appearance:none;appearance:none;margin:0;flex-shrink:0;
  width:34px;height:20px;border-radius:10px;background:#333;
  position:relative;cursor:pointer;outline:none;
  transition:background .2s ease}
.toggle-row input[type=checkbox]::before,.sg input[type=checkbox]::before{
  content:"";position:absolute;top:2px;left:2px;width:16px;height:16px;
  border-radius:50%;background:#8a8a8a;
  transition:transform .2s ease,background .2s ease}
.toggle-row input[type=checkbox]:checked,.sg input[type=checkbox]:checked{
  background:var(--accent)}
.toggle-row input[type=checkbox]:checked::before,.sg input[type=checkbox]:checked::before{
  transform:translateX(14px);background:#111}
.sub-settings{padding-left:22px;display:flex;flex-direction:column;gap:5px;
  overflow:hidden;max-height:400px;opacity:1;
  transition:max-height .35s ease,opacity .28s ease,margin .35s ease}
.sub-settings.hidden{max-height:0;opacity:0;margin-top:-8px;pointer-events:none}

/* Переключатель языка */
.lang-sw{display:flex;gap:2px;background:#1e1e1e;border:1px solid #333;
  border-radius:14px;padding:2px;flex-shrink:0}
.lang-sw button{flex:none;min-width:0;background:none;border:none;color:var(--dim);
  font-size:.7rem;font-weight:700;padding:3px 10px;border-radius:11px;cursor:pointer}
.lang-sw button.on{background:var(--accent);color:#111}

/* Чип версии и кнопка фидбека в шапке */
.ver-chip,.fb-open{flex:none;min-width:0;background:#1e1e1e;border:1px solid #333;
  border-radius:14px;padding:4px 12px;font-family:monospace;font-size:.7rem;
  color:var(--dim);cursor:pointer;transition:.2s}
.ver-chip:hover,.fb-open:hover{color:var(--accent);border-color:var(--accent)}

/* Модалки (релиз-ноуты, фидбек) */
.am-overlay{position:fixed;inset:0;z-index:60;background:rgba(0,0,0,.6);
  backdrop-filter:blur(4px);display:flex;align-items:center;justify-content:center;
  opacity:0;pointer-events:none;transition:opacity .25s}
.am-overlay.show{opacity:1;pointer-events:auto}
.am-panel{width:min(520px,92vw);max-height:82vh;overflow-y:auto;background:#181818;
  border:1px solid #333;border-radius:16px;padding:20px 22px;
  transform:translateY(14px);transition:transform .25s}
.am-overlay.show .am-panel{transform:none}
.am-head{display:flex;align-items:center;justify-content:space-between;
  font-weight:700;font-size:1rem;color:var(--accent);margin-bottom:14px}
.am-close{background:none;border:none;color:var(--dim);font-size:1.3rem;
  cursor:pointer;padding:0 4px;flex:none;min-width:0}
.am-close:hover{color:var(--accent)}

/* Релиз-ноуты */
.rel{border-bottom:1px solid #262626;padding:12px 0}
.rel:last-child{border-bottom:none}
.rel-head{display:flex;justify-content:space-between;align-items:baseline;margin-bottom:6px}
.rel-head b{color:var(--accent);font-family:monospace}
.rel-head span{font-size:.7rem;color:var(--dim);font-family:monospace}
.rel-notes{font-size:.82rem;color:#b5b5b5;line-height:1.6}

/* Фидбек-форма */
.fb-types{display:flex;gap:8px;margin-bottom:12px}
.fb-types button{flex:1;background:#222;border:1px solid #3a3a3a;border-radius:10px;
  padding:9px 6px;font-size:.8rem;color:#999;cursor:pointer;transition:.2s;min-width:0}
.fb-types button.on{background:rgba(0,255,170,.12);border-color:var(--accent);color:var(--accent)}
#fbText{width:100%;background:#141414;border:1px solid #333;border-radius:10px;
  color:var(--text);font-family:inherit;font-size:.86rem;padding:10px 12px;
  resize:vertical;min-height:96px;margin-bottom:14px}
#fbText:focus{outline:none;border-color:var(--accent)}
.fb-sat{margin-bottom:16px}
.fb-sat-head{display:flex;align-items:center;gap:10px;margin-bottom:6px}
.fb-sat-head label{font-size:.78rem;color:#999;flex:1}
#fbSatVal{font-family:monospace;font-size:.85rem;color:var(--accent);font-weight:700}
#fbSatEmo{font-size:1.1rem}
#fbSatRange{width:100%;accent-color:var(--accent)}
.fb-skip{display:flex;align-items:center;gap:7px;margin-top:8px;font-size:.72rem;
  color:var(--dim);cursor:pointer}
.fb-skip input{accent-color:var(--accent);width:13px;height:13px;
  -webkit-appearance:checkbox;appearance:checkbox}
.fb-send{width:100%}
.fb-status{font-size:.78rem;font-family:monospace;text-align:center;margin-top:10px;min-height:1.2em}
.fb-status.ok{color:var(--accent)}
.fb-status.err{color:var(--red)}

/* Карточка обновления */
.upd-card{position:fixed;right:18px;bottom:18px;z-index:55;width:250px;
  background:#181818;border:1px solid rgba(0,255,170,.5);border-radius:14px;
  padding:14px 16px;box-shadow:0 10px 40px rgba(0,0,0,.5);
  transform:translateY(140%);opacity:0;transition:transform .5s,opacity .4s}
.upd-card.show{transform:none;opacity:1}
.upd-txt{font-size:.82rem;color:#ccc;margin-bottom:10px}
.upd-txt b{color:var(--accent);font-family:monospace}
.upd-btn{width:100%;margin-bottom:6px}
.upd-later{width:100%;background:none;border:none;color:var(--dim);font-size:.72rem;
  cursor:pointer;min-width:0;padding:4px}
.upd-state{font-family:monospace;font-size:.7rem;color:var(--accent);
  text-align:center;min-height:1em;margin-top:4px}

/* Настройки-сетка */
.sg{display:grid;grid-template-columns:1fr auto auto;gap:5px 8px;align-items:center}
.sg label{font-size:.8rem;color:#999}
.sg input[type=range]{width:90px;accent-color:var(--accent)}
.sg .val{font-family:monospace;font-size:.8rem;color:var(--accent);text-align:right;min-width:34px}
.sg .full{grid-column:1/-1}

/* Кастомный селект */
.cselect{grid-column:1/-1;position:relative;user-select:none;-webkit-user-select:none;font-size:.82rem}
.cselect-btn{display:flex;align-items:center;justify-content:space-between;gap:8px;
  background:#252525;border:1px solid #3a3a3a;border-radius:9px;
  padding:7px 12px;cursor:pointer;color:var(--text);transition:border-color .15s}
.cselect-btn:hover,.cselect.open .cselect-btn{border-color:var(--accent)}
.cselect-arr{color:var(--accent);font-size:.65rem;transition:transform .2s}
.cselect.open .cselect-arr{transform:rotate(180deg)}
.cselect-list{max-height:0;overflow:hidden;transition:max-height .22s ease;
  background:#1a1a1a;border-radius:9px;margin-top:4px;border:1px solid transparent}
.cselect.open .cselect-list{max-height:240px;overflow-y:auto;border-color:#333}
.cselect-opt{padding:7px 12px;cursor:pointer;color:#bbb;transition:background .1s}
.cselect-opt:hover{background:#252525;color:var(--text)}
.cselect-opt.sel{color:var(--accent);background:rgba(0,255,170,.08)}
.cselect-opt.sel::after{content:"✓";float:right}

/* Предупреждение «плеер не запущен» */
.warn-note{display:flex;align-items:flex-start;gap:8px;
  background:rgba(255,170,0,.07);border:1px solid rgba(255,170,0,.3);
  border-left:3px solid var(--warn);border-radius:8px;
  padding:8px 10px;font-size:.74rem;line-height:1.35;color:#e8c890;
  overflow:hidden;max-height:80px;opacity:1;
  transition:max-height .3s ease,opacity .25s ease,margin .3s ease,padding .3s ease}
.warn-note.hidden{max-height:0;opacity:0;margin-top:-5px;padding-top:0;padding-bottom:0;
  border-width:0;pointer-events:none}
.warn-note .wi{flex-shrink:0;color:var(--warn);font-size:.85rem;line-height:1.2}

/* Кнопки */
.btn-row{display:flex;gap:8px;width:100%;max-width:400px;flex-wrap:wrap}
button{flex:1;border:none;padding:11px 8px;font-size:.85rem;font-weight:600;
  border-radius:20px;cursor:pointer;transition:opacity .15s;min-width:80px}
button:active{opacity:.65}
.btn-primary{background:var(--accent);color:#111}
.btn-outline{background:#252525;color:var(--accent);border:1px solid var(--accent)}
.btn-muted{background:#252525;color:#777;border:1px solid #3a3a3a;font-size:.8rem}

/* Статус соединения */
.conn{font-size:.75rem;text-align:center;padding:4px 0}
.conn.ok{color:var(--accent)}.conn.warn{color:var(--warn)}.conn.err{color:var(--red)}

/* ── Desktop layout (≥900px) ── */
@media(min-width:900px){
  html,body{height:100%;overflow:hidden}

  /* страница: шапка + две равные колонки */
  .page{
    height:100vh;overflow:hidden;
    display:grid;
    grid-template:
      "hd   hd"    auto
      "left right" 1fr
      / 1fr 1fr;
    max-width:1400px;margin:0 auto;
    padding:10px 18px 10px;gap:8px;
  }
  header{
    grid-area:hd;display:flex;align-items:baseline;gap:16px;
    justify-content:space-between;
  }
  h1{font-size:1.2rem;margin-bottom:0}
  .subtitle{display:none}

  /* левая колонка: верх (куб) и низ (граф) поровну */
  .left-col{
    grid-area:left;
    display:flex;flex-direction:column;
    height:100%;min-height:0;
    gap:8px;overflow:visible;
    padding-right:12px;
  }
  /* куб — пропорционально вьюпорту, максимум 190px */
  :root{ --cs: clamp(80px, min(16vw, 18vh), 190px); }
  .left-top{
    flex:1;min-height:0;
    display:flex;flex-direction:column;align-items:center;justify-content:flex-end;
    gap:6px;overflow:visible;
  }
  .left-bot{
    flex:1;min-height:0;
    display:flex;flex-direction:column;overflow:hidden;
  }
  /* карточка графика тянется на всю нижнюю половину */
  .graph-card{
    flex:1;min-height:0;
    display:flex;flex-direction:column;padding:8px 10px;
    background:#121212;
  }
  /* граф заполняет карточку */
  #postureGraph{
    flex:1;min-height:0;width:100%;height:100%;display:block;
  }
  .posture-row{flex-shrink:0;margin-bottom:3px}
  .posture-lbl{font-size:.8rem}

  /* куб масштабируется через --cs (задан выше) */
  .scene-wrap{flex-shrink:0}

  /* карточки */
  .card{max-width:none;padding:7px 10px}
  .card-title{margin-bottom:4px;font-size:.6rem}
  .btn-row{max-width:none;flex-shrink:0}
  button{padding:6px 6px;font-size:.75rem}
  .angle-val{font-size:.9rem}
  .angle-lbl{font-size:.6rem}
  .angles{gap:4px}

  /* правая колонка */
  .right-col{
    grid-area:right;display:flex;flex-direction:column;
    gap:8px;overflow-y:auto;padding-left:14px;
    border-left:1px solid #222;min-height:0;
  }
  .sg input[type=range]{width:90px}
  .sg label{font-size:.75rem}
  .sg .val{font-size:.75rem;min-width:30px}
  .sub-settings{gap:3px}
  .toggle-row label{font-size:.8rem}
  .bar-row{margin-bottom:3px}
}
</style>
</head>
<body>
<div class="page">

  <header>
    <div>
      <h1>🎧 <span data-i18n="title">AirPods · Posture</span></h1>
      <div class="subtitle" data-i18n="subtitle">Sit straight → “Calibrate” → wear your AirPods</div>
    </div>
    <div style="display:flex;align-items:center;gap:12px">
      <div class="conn warn" id="conn">Connecting…</div>
      <button class="ver-chip" id="verChip" title="Release notes">v—</button>
      <button class="fb-open" id="fbOpen" data-i18n="fbOpen">Feedback</button>
      <div class="lang-sw">
        <button id="langEn" class="on">EN</button>
        <button id="langRu">RU</button>
      </div>
    </div>
  </header>

  <div class="left-col">

    <div class="left-top">
      <div class="scene-wrap">
        <div class="scene"><canvas id="cube3d"></canvas></div>
      </div>

      <div class="card">
        <div class="card-title" data-i18n="cardHead">Head position</div>
        <div class="angles">
          <div><div class="angle-val" id="yaw">0°</div><div class="angle-lbl" data-i18n="lblYaw">Yaw L/R</div></div>
          <div><div class="angle-val" id="pitch">0°</div><div class="angle-lbl" data-i18n="lblPitch">Pitch U/D</div></div>
          <div><div class="angle-val" id="roll">0°</div><div class="angle-lbl" data-i18n="lblRoll">Roll tilt</div></div>
        </div>
      </div>
    </div><!-- /left-top -->

    <div class="left-bot">
    <!-- Осанка -->
    <div class="card graph-card">
      <div class="card-title" data-i18n="cardPosture">Posture</div>
      <div class="posture-row">
        <div class="dot idle" id="dot"></div>
        <span class="posture-lbl" id="postureLbl">Not calibrated</span>
        <span class="posture-timer" id="postureTimer"></span>
      </div>
      <svg id="postureGraph" viewBox="0 0 180 186"
           style="display:block;margin:4px auto;overflow:visible">
        <defs>
          <filter id="glow" x="-60%" y="-60%" width="220%" height="220%">
            <feGaussianBlur stdDeviation="3.5" result="blur"/>
            <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
          </filter>
        </defs>
        <!-- bg -->
        <rect x="6" y="6" width="168" height="168" rx="8" fill="#121212"/>
        <!-- quarter-grid lines -->
        <line x1="90" y1="6" x2="90" y2="51"  stroke="#2a2a2a" stroke-width="1"/>
        <line x1="90" y1="129" x2="90" y2="174" stroke="#2a2a2a" stroke-width="1"/>
        <line x1="6"  y1="90" x2="51"  y2="90" stroke="#2a2a2a" stroke-width="1"/>
        <line x1="129" y1="90" x2="174" y2="90" stroke="#2a2a2a" stroke-width="1"/>
        <!-- main cross -->
        <line x1="90" y1="6"  x2="90"  y2="174" stroke="#303030" stroke-width="1.5"/>
        <line x1="6"  y1="90" x2="174" y2="90"  stroke="#303030" stroke-width="1.5"/>
        <!-- axis labels -->
        <text x="94" y="17"  fill="#404040" font-size="7" font-family="monospace" data-i18n="axFwd">fwd</text>
        <text x="94" y="172" fill="#404040" font-size="7" font-family="monospace" data-i18n="axBack">back</text>
        <text x="9"  y="94"  fill="#404040" font-size="7" font-family="monospace" data-i18n="axL">L</text>
        <text x="161" y="94" fill="#404040" font-size="7" font-family="monospace" data-i18n="axR">R</text>
        <!-- safe-zone ellipse -->
        <ellipse id="thEllipse" cx="90" cy="90" rx="38" ry="38"
          fill="rgba(0,255,170,0.05)" stroke="#00ffaa44" stroke-width="1.5" stroke-dasharray="5,3"/>
        <!-- trail -->
        <g id="dotTrail"></g>
        <!-- dot -->
        <circle id="postureDot2d" cx="90" cy="90" r="4.5"
          fill="var(--accent)" filter="url(#glow)"/>
        <!-- readout -->
        <text id="graphVals" x="90" y="184" fill="#444" font-size="7"
          font-family="monospace" text-anchor="middle">P:0.0° R:0.0°</text>
      </svg>
    </div>
    </div><!-- /left-bot -->

  </div><!-- /left-col -->

  <div class="right-col">

    <!-- Музыка -->
    <div class="card">
      <div class="card-title" data-i18n="cardMusic">Music</div>
      <div class="music-section">

        <div class="toggle-row">
          <input type="checkbox" id="chkTrack">
          <label for="chkTrack" data-i18n="chkTrackLbl">Track switching (head tilt)</label>
        </div>
        <div class="sub-settings hidden" id="trackSub">
          <div class="sg">
            <label data-i18n="thTilt">Tilt threshold</label>
            <input type="range" id="slTrackTh" min="5" max="60" value="25">
            <span class="val" id="lblTrackTh">25°</span>
          </div>
          <div class="sg">
            <label data-i18n="holdDelay">Hold delay</label>
            <input type="range" id="slTrackHold" min="100" max="1500" step="50" value="600">
            <span class="val" id="lblTrackHold">600ms</span>
          </div>
          <!-- live крен + статус -->
          <div class="bar-row" style="margin-top:4px">
            <span class="bar-name" data-i18n="barTilt">Tilt</span>
            <div class="bar-track"><div class="bar-fill" id="bTrackRoll" style="width:0%"></div></div>
            <span class="bar-val" id="dTrackRoll">0°</span>
          </div>
          <div class="bar-row" style="margin-top:2px">
            <span class="bar-name" style="color:#555" data-i18n="charge">charge</span>
            <div class="bar-track"><div class="bar-fill" id="bTrackHold" style="width:0%;background:var(--accent)"></div></div>
            <span id="trackStatus" style="font-size:.7rem;color:var(--accent);font-family:monospace;min-width:38px;text-align:right"></span>
          </div>
          <div class="warn-note hidden" id="trackWarn" style="margin-top:4px">
            <span class="wi">●</span>
            <span data-i18n="noPlayer">Spotify or Music isn’t running — open one of them to switch tracks with head gestures.</span>
          </div>
          <div style="font-size:.7rem;color:#444;margin-top:2px" data-i18n="permNote">⚠ On first use macOS will ask for permission — allow it</div>
        </div>

        <div class="toggle-row" style="margin-top:4px">
          <input type="checkbox" id="chkPitchVol">
          <label for="chkPitchVol" data-i18n="chkPitchVolLbl">Volume ↓ on head pitch</label>
        </div>
        <div class="sub-settings hidden" id="pitchVolSub">
          <div class="sg">
            <label data-i18n="thPitch">Pitch threshold</label>
            <input type="range" id="slPitchVolTh" min="5" max="60" value="20">
            <span class="val" id="lblPitchVolTh">20°</span>
            <label data-i18n="holdDelay">Hold delay</label>
            <input type="range" id="slPitchVolHold" min="100" max="1500" step="50" value="400">
            <span class="val" id="lblPitchVolHold">400ms</span>
          </div>
          <div class="bar-row" style="margin-top:4px">
            <span class="bar-name" data-i18n="barPitch">Pitch</span>
            <div class="bar-track"><div class="bar-fill" id="bPitchVol" style="width:0%"></div></div>
            <span class="bar-val" id="dPitchVol">0°</span>
          </div>
          <div class="bar-row" style="margin-top:2px">
            <span class="bar-name" style="color:#555" data-i18n="charge">charge</span>
            <div class="bar-track"><div class="bar-fill" id="bPitchVolHold" style="width:0%;background:var(--blue)"></div></div>
            <span id="pitchVolStatus" style="font-size:.7rem;font-family:monospace;min-width:38px;text-align:right"></span>
          </div>
          <div style="font-size:.7rem;color:#555;margin-top:2px" data-i18n="sharedNote">Reduction and fade settings are shared with Yaw</div>
        </div>

        <div class="toggle-row" style="margin-top:4px">
          <input type="checkbox" id="chkYawVol">
          <label for="chkYawVol" data-i18n="chkYawVolLbl">Volume ↓ on head turn (Yaw)</label>
        </div>
        <div class="sub-settings hidden" id="yawSub">
          <div class="sg">
            <label data-i18n="thTurn">Turn threshold</label>
            <input type="range" id="slYawTh" min="5" max="90" value="20">
            <span class="val" id="lblYawTh">20°</span>
            <label data-i18n="holdDelay">Hold delay</label>
            <input type="range" id="slYawHold" min="100" max="1500" step="50" value="400">
            <span class="val" id="lblYawHold">400ms</span>
            <label data-i18n="volReduction">Volume reduction</label>
            <input type="range" id="slYawRed" min="10" max="100" value="70">
            <span class="val" id="lblYawRed">70%</span>
            <label data-i18n="normalVolume">Normal volume</label>
            <input type="range" id="slNormVol" min="0" max="100" value="70">
            <span class="val" id="lblNormVol">70%</span>
            <label data-i18n="volumeFade">Volume fade</label>
            <input type="range" id="slFade" min="1" max="10" value="3">
            <span class="val" id="lblFade">3 s</span>
          </div>
          <!-- live yaw -->
          <div class="bar-row" style="margin-top:4px">
            <span class="bar-name" data-i18n="barTurn">Turn</span>
            <div class="bar-track"><div class="bar-fill" id="bYaw" style="width:0%"></div></div>
            <span class="bar-val" id="dYaw">0°</span>
          </div>
          <div class="bar-row" style="margin-top:2px">
            <span class="bar-name" style="color:#555" data-i18n="charge">charge</span>
            <div class="bar-track"><div class="bar-fill" id="bYawHold" style="width:0%;background:var(--blue)"></div></div>
            <span id="yawStatus" style="font-size:.7rem;font-family:monospace;min-width:38px;text-align:right"></span>
          </div>
        </div>

      </div>
    </div>

    <!-- Настройки осанки + звук -->
    <div class="card">
      <div class="card-title" data-i18n="cardSettings">Posture & sound settings</div>
      <div class="sg">
        <label data-i18n="thForward">Forward lean threshold (Pitch)</label>
        <input type="range" id="slPitch" min="3" max="90" value="15">
        <span class="val" id="lblPitch">15°</span>

        <label data-i18n="thRoll">Tilt threshold (Roll)</label>
        <input type="range" id="slRoll" min="3" max="60" value="10">
        <span class="val" id="lblRoll">10°</span>

        <label data-i18n="alertDelay">Delay before alert</label>
        <input type="range" id="slDelay" min="0" max="30" value="5">
        <span class="val" id="lblDelay">5 s</span>

        <label data-i18n="alertCooldown">Pause between alerts</label>
        <input type="range" id="slCooldown" min="5" max="300" value="60">
        <span class="val" id="lblCooldown">60 s</span>

        <label data-i18n="soundLbl">Sound</label>
        <input type="checkbox" id="chkSound" checked>
        <span></span>

        <label data-i18n="alertVolume">Alert volume</label>
        <input type="range" id="slVol" min="0" max="100" value="70">
        <span class="val" id="lblVol">70%</span>

        <label class="full" data-i18n="alertType">Alert sound</label>
        <div class="cselect" id="selSoundBox">
          <div class="cselect-btn">
            <span id="selSoundLbl">Double tone</span>
            <span class="cselect-arr">▼</span>
          </div>
          <div class="cselect-list" id="selSoundList"></div>
        </div>

        <button class="btn-muted full" id="btnTestSound" data-i18n="btnTest">Test sound</button>
      </div>
    </div>

    <div class="btn-row">
      <button class="btn-primary" id="btnCalib" data-i18n="btnCalib">Calibrate</button>
    </div>

  </div><!-- /right-col -->

</div><!-- /page -->

<div class="track-flash" id="trackFlash"></div>

<!-- Релиз-ноуты -->
<div class="am-overlay" id="notesModal">
  <div class="am-panel">
    <div class="am-head"><span data-i18n="notesTitle">What’s new</span>
      <button class="am-close" data-close="notesModal">×</button></div>
    <div id="notesBody"><div class="rel-notes">…</div></div>
  </div>
</div>

<!-- Фидбек -->
<div class="am-overlay" id="fbModal">
  <div class="am-panel">
    <div class="am-head"><span data-i18n="fbTitle">Feedback</span>
      <button class="am-close" data-close="fbModal">×</button></div>
    <div class="fb-types" id="fbTypes">
      <button data-type="bug" class="on" data-i18n="fbBug">🐛 Bug</button>
      <button data-type="feature" data-i18n="fbFeat">✨ Feature</button>
      <button data-type="idea" data-i18n="fbIdea">💡 Idea</button>
    </div>
    <textarea id="fbText" data-i18n-ph="fbPh" placeholder="What happened? What would make the app better?"></textarea>
    <div class="fb-sat">
      <div class="fb-sat-head">
        <label data-i18n="fbSat">Satisfaction meter</label>
        <span id="fbSatVal">80%</span><span id="fbSatEmo">🙂</span>
      </div>
      <input type="range" id="fbSatRange" min="0" max="100" value="80">
      <label class="fb-skip"><input type="checkbox" id="fbSatSkip">
        <span data-i18n="fbSkip">don’t include the rating</span></label>
    </div>
    <button class="btn-primary fb-send" id="fbSend" data-i18n="fbSend">Send</button>
    <div class="fb-status" id="fbStatus"></div>
  </div>
</div>

<!-- Доступно обновление -->
<div class="upd-card" id="updCard">
  <div class="upd-txt"><b id="updVer">v?.?.?</b> <span data-i18n="updAvail">is available</span></div>
  <button class="btn-primary upd-btn" id="updGo" data-i18n="updGo">Update &amp; restart</button>
  <button class="upd-later" id="updLater" data-i18n="updLater">later</button>
  <div class="upd-state" id="updState"></div>
</div>

<script>
// ── i18n ────────────────────────────────────────────────────────────────
const L = {
  en: {
    title:'AirPods · Posture',
    subtitle:'Sit straight → “Calibrate” → wear your AirPods',
    faceFront:'FACE ☺',
    cardHead:'Head position', lblYaw:'Yaw L/R', lblPitch:'Pitch U/D', lblRoll:'Roll tilt',
    cardPosture:'Posture', notCalibrated:'Not calibrated',
    axFwd:'fwd', axBack:'back', axL:'L', axR:'R',
    cardMusic:'Music',
    chkTrackLbl:'Track switching (head tilt)',
    thTilt:'Tilt threshold', holdDelay:'Hold delay', barTilt:'Tilt', charge:'charge',
    permNote:'⚠ On first use macOS will ask for permission — allow it',
    chkPitchVolLbl:'Volume ↓ on head pitch', thPitch:'Pitch threshold', barPitch:'Pitch',
    sharedNote:'Reduction and fade settings are shared with Yaw',
    chkYawVolLbl:'Volume ↓ on head turn (Yaw)', thTurn:'Turn threshold',
    volReduction:'Volume reduction', normalVolume:'Normal volume', volumeFade:'Volume fade', barTurn:'Turn',
    cardSettings:'Posture & sound settings',
    thForward:'Forward lean threshold (Pitch)', thRoll:'Tilt threshold (Roll)',
    alertDelay:'Delay before alert', alertCooldown:'Pause between alerts',
    soundLbl:'Sound', alertVolume:'Alert volume', alertType:'Alert sound',
    btnTest:'Test sound', btnCalib:'Calibrate',
    noData:'No data from AirPods', calibrated:'Calibrated — sit straight!',
    postureOk:'Posture OK', checking:'Checking…', fixPosture:'⚠ Fix your posture!',
    pause:'⏳ pause', hold:'hold…', ready:'ready', quiet:'🔇 quiet',
    connOk:'AirPods active ✔', connLost:'AirPods lost…',
    connWait:'Waiting for AirPods — put them in', connErr:'No connection: ',
    noPlayer:'Spotify or Music isn’t running — open one of them to switch tracks with head gestures.',
    fbOpen:'Feedback', fbTitle:'Feedback',
    fbBug:'🐛 Bug', fbFeat:'✨ Feature', fbIdea:'💡 Idea',
    fbPh:'What happened? What would make the app better?',
    fbSat:'Satisfaction meter', fbSkip:'don’t include the rating',
    fbSend:'Send', fbSending:'sending…', fbDone:'✓ sent — thank you!',
    fbErr:'✗ failed to send, try later', fbShort:'✗ describe it in a few more words',
    notesTitle:'What’s new', notesErr:'Couldn’t load release notes (offline?)',
    updAvail:'is available', updGo:'Update & restart', updLater:'later',
    upd_downloading:'downloading…', upd_installing:'installing…',
    upd_relaunching:'restarting…', updErr:'update failed — try later',
    u_deg:'°', u_pct:'%', u_s:' s', u_ms:'ms', u_sec:'s',
    snd_double:'Double tone', snd_triple:'Three short', snd_rising:'Rising',
    snd_ping:'Single ping', snd_low:'Low hum', snd_alarm:'Alarm (aggressive)',
    snd_siren:'Siren', snd_rapid:'Rapid beeper', snd_harsh:'Harsh horn', snd_klaxon:'Klaxon',
  },
  ru: {
    title:'AirPods · Осанка',
    subtitle:'Сядь прямо → «Калибровать» → носи с AirPods в ушах',
    faceFront:'ЛИЦО ☺',
    cardHead:'Положение головы', lblYaw:'Yaw Л/П', lblPitch:'Pitch В/Н', lblRoll:'Roll крен',
    cardPosture:'Осанка', notCalibrated:'Не откалибровано',
    axFwd:'вперёд', axBack:'назад', axL:'Л', axR:'П',
    cardMusic:'Музыка',
    chkTrackLbl:'Переключение треков (крен головы)',
    thTilt:'Порог крена', holdDelay:'Задержка срабатывания', barTilt:'Крен', charge:'заряд',
    permNote:'⚠ При первом запуске macOS попросит разрешение — разреши',
    chkPitchVolLbl:'Громкость ↓ при наклоне головы (Pitch)', thPitch:'Порог наклона', barPitch:'Наклон',
    sharedNote:'Уровни снижения и фейд — общие с Yaw',
    chkYawVolLbl:'Громкость ↓ при повороте головы (Yaw)', thTurn:'Порог поворота',
    volReduction:'Снижение громкости', normalVolume:'Нормальная громкость', volumeFade:'Фейд громкости', barTurn:'Поворот',
    cardSettings:'Настройки осанки и звука',
    thForward:'Порог наклона вперёд (Pitch)', thRoll:'Порог крена (Roll)',
    alertDelay:'Задержка перед сигналом', alertCooldown:'Пауза между сигналами',
    soundLbl:'Звук', alertVolume:'Громкость сигнала', alertType:'Тип сигнала',
    btnTest:'Тест звука', btnCalib:'Калибровать',
    noData:'Нет данных с AirPods', calibrated:'Откалибровано — сиди прямо!',
    postureOk:'Осанка OK', checking:'Проверяю…', fixPosture:'⚠ Выправи осанку!',
    pause:'⏳ пауза', hold:'держи…', ready:'готов', quiet:'🔇 тихо',
    connOk:'AirPods активны ✔', connLost:'AirPods потеряны…',
    connWait:'Жду AirPods — надень наушники', connErr:'Нет связи: ',
    noPlayer:'Spotify или Музыка не запущены — открой один из плееров, чтобы переключать треки жестами головы.',
    fbOpen:'Фидбек', fbTitle:'Обратная связь',
    fbBug:'🐛 Баг', fbFeat:'✨ Фича', fbIdea:'💡 Идея',
    fbPh:'Что случилось? Что сделало бы приложение лучше?',
    fbSat:'Шкала удовлетворённости', fbSkip:'не включать оценку',
    fbSend:'Отправить', fbSending:'отправляю…', fbDone:'✓ отправлено — спасибо!',
    fbErr:'✗ не отправилось, попробуй позже', fbShort:'✗ опиши чуть подробнее',
    notesTitle:'Что нового', notesErr:'Не удалось загрузить релиз-ноуты (офлайн?)',
    updAvail:'уже доступна', updGo:'Обновить и перезапустить', updLater:'позже',
    upd_downloading:'скачиваю…', upd_installing:'устанавливаю…',
    upd_relaunching:'перезапускаюсь…', updErr:'обновление не удалось — попробуй позже',
    u_deg:'°', u_pct:'%', u_s:' с', u_ms:'мс', u_sec:'с',
    snd_double:'Двойной тон', snd_triple:'Три коротких', snd_rising:'Нарастающий',
    snd_ping:'Одиночный пинг', snd_low:'Низкий гул', snd_alarm:'Тревога (агрессивный)',
    snd_siren:'Сирена', snd_rapid:'Бипер (быстрый)', snd_harsh:'Жёсткий гудок', snd_klaxon:'Клаксон',
  },
};
let lang = localStorage.getItem('lang') || 'en';
const t = k => L[lang][k] ?? k;

// ── DOM refs ────────────────────────────────────────────────────────────
const yawEl      = document.getElementById('yaw');
const pitchEl    = document.getElementById('pitch');
const rollEl     = document.getElementById('roll');
const connEl     = document.getElementById('conn');
const dot        = document.getElementById('dot');
const postureLbl = document.getElementById('postureLbl');
const postureTimer = document.getElementById('postureTimer');
const postureDot2d = document.getElementById('postureDot2d');
const thEllipse    = document.getElementById('thEllipse');
const graphVals    = document.getElementById('graphVals');
const dotTrail     = document.getElementById('dotTrail');
const GRAPH_CX = 90, GRAPH_CY = 90, GRAPH_HALF = 78, GRAPH_MAX_DEG = 55;
const TRAIL_LEN = 18;
let trailPts = [];
const trackFlash  = document.getElementById('trackFlash');
const bTrackRoll  = document.getElementById('bTrackRoll');
const dTrackRoll  = document.getElementById('dTrackRoll');
const trackStatus = document.getElementById('trackStatus');
const bYaw        = document.getElementById('bYaw');
const dYaw        = document.getElementById('dYaw');
const yawStatus   = document.getElementById('yawStatus');

// ── Слайдеры (суффиксы — ключи i18n, обновляются при смене языка) ──────
const sliderUpds = [];
function bind(id, lblId, unitKey) {
  const el  = document.getElementById(id);
  const lbl = document.getElementById(lblId);
  const upd = () => lbl.textContent = el.value + t(unitKey);
  el.addEventListener('input', upd); upd();
  sliderUpds.push(upd);
  return el;
}
function bindMs(id, lblId) {
  const el  = document.getElementById(id);
  const lbl = document.getElementById(lblId);
  const upd = () => {
    const ms = Number(el.value);
    lbl.textContent = ms < 1000 ? ms + t('u_ms') : (ms/1000).toFixed(1) + t('u_sec');
  };
  el.addEventListener('input', upd); upd();
  sliderUpds.push(upd);
  return el;
}
const slPitch      = bind('slPitch',      'lblPitch',     'u_deg');
const slRoll       = bind('slRoll',       'lblRoll',      'u_deg');
const slDelay      = bind('slDelay',      'lblDelay',     'u_s');
const slCooldown   = bind('slCooldown',   'lblCooldown',  'u_s');
const slVol        = bind('slVol',        'lblVol',       'u_pct');
const slTrackTh      = bind('slTrackTh',      'lblTrackTh',     'u_deg');
const slTrackHold    = bindMs('slTrackHold',  'lblTrackHold');
const slPitchVolTh   = bind('slPitchVolTh',   'lblPitchVolTh',  'u_deg');
const slPitchVolHold = bindMs('slPitchVolHold','lblPitchVolHold');
const slYawTh        = bind('slYawTh',        'lblYawTh',       'u_deg');
const slYawHold    = bindMs('slYawHold',  'lblYawHold');
const slYawRed     = bind('slYawRed',     'lblYawRed',    'u_pct');
const slNormVol    = bind('slNormVol',    'lblNormVol',   'u_pct');
const slFade       = bind('slFade',       'lblFade',      'u_s');

const chkSound     = document.getElementById('chkSound');
const chkTrack     = document.getElementById('chkTrack');
const chkPitchVol  = document.getElementById('chkPitchVol');
const chkYawVol    = document.getElementById('chkYawVol');

// ── Кастомный селект типа сигнала ──────────────────────────────────────
const SOUND_KEYS = ['double','triple','rising','ping','low','alarm','siren','rapid','harsh','klaxon'];
const selSound = { value: 'double' };   // тот же интерфейс, что у <select>
const selSoundBox  = document.getElementById('selSoundBox');
const selSoundLbl  = document.getElementById('selSoundLbl');
const selSoundList = document.getElementById('selSoundList');
const soundOptEls  = new Map();
for (const val of SOUND_KEYS) {
  const opt = document.createElement('div');
  opt.className = 'cselect-opt' + (val === selSound.value ? ' sel' : '');
  opt.textContent = t('snd_' + val);
  opt.addEventListener('click', e => {
    e.stopPropagation();
    selSound.value = val;
    selSoundLbl.textContent = t('snd_' + val);
    selSoundList.querySelectorAll('.sel').forEach(o => o.classList.remove('sel'));
    opt.classList.add('sel');
    selSoundBox.classList.remove('open');
    playAlert(); // сразу дать послушать выбранный сигнал
    saveSettings();
  });
  soundOptEls.set(val, opt);
  selSoundList.appendChild(opt);
}
selSoundBox.querySelector('.cselect-btn').addEventListener('click', () =>
  selSoundBox.classList.toggle('open'));
document.addEventListener('click', e => {
  if (!selSoundBox.contains(e.target)) selSoundBox.classList.remove('open');
});

// ── Переключение языка ─────────────────────────────────────────────────
const langEnBtn = document.getElementById('langEn');
const langRuBtn = document.getElementById('langRu');
function setLang(l) {
  lang = l; localStorage.setItem('lang', l);
  document.documentElement.lang = l;
  document.title = t('title');
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const s = L[lang][el.dataset.i18n];
    if (s !== undefined) el.textContent = s;
  });
  document.querySelectorAll('[data-i18n-ph]').forEach(el => {
    const s = L[lang][el.dataset.i18nPh];
    if (s !== undefined) el.placeholder = s;
  });
  soundOptEls.forEach((el, val) => el.textContent = t('snd_' + val));
  selSoundLbl.textContent = t('snd_' + selSound.value);
  sliderUpds.forEach(f => f());
  if (window.__setFaceText) window.__setFaceText(t('faceFront'));
  if (!baseline) postureLbl.textContent = t('notCalibrated');
  langEnBtn.classList.toggle('on', l === 'en');
  langRuBtn.classList.toggle('on', l === 'ru');
}
langEnBtn.addEventListener('click', () => setLang('en'));
langRuBtn.addEventListener('click', () => setLang('ru'));

// показывать/скрывать sub-settings
function syncSub(chk, sub) {
  document.getElementById(sub).classList.toggle('hidden', !chk.checked);
}
chkPitchVol.addEventListener('change', () => {
  syncSub(chkPitchVol, 'pitchVolSub');
  if (!chkPitchVol.checked) {
    clearInterval(fadeTimer); fadeTimer = null; fadeTarget = null;
    pitchVolHoldStart = null;
    if (pitchVolActive) { pitchVolActive = false; applyVol(); }
    if (bPitchVolHoldEl) bPitchVolHoldEl.style.width = '0%';
    if (pitchVolStatus) pitchVolStatus.textContent = '';
  }
});
chkTrack.addEventListener('change', () => {
  syncSub(chkTrack, 'trackSub');
  if (!chkTrack.checked) {
    trackState = 'neutral'; trackHoldStart = null;
    trackRecoverUntil = 0; trackGapStart = null;
    if (bTrackHoldEl) bTrackHoldEl.style.width = '0%';
    if (trackStatus) trackStatus.textContent = '';
  }
});
chkYawVol.addEventListener('change', () => {
  syncSub(chkYawVol, 'yawSub');
  if (!chkYawVol.checked) {
    fadeTarget = null; yawHoldStart = null;
    if (yawActive) { yawActive = false; applyVol(); }
    if (bYawHoldEl) bYawHoldEl.style.width = '0%';
    if (yawStatus) yawStatus.textContent = '';
  }
});
syncSub(chkTrack, 'trackSub');
syncSub(chkPitchVol, 'pitchVolSub');
syncSub(chkYawVol, 'yawSub');

// ── Состояние ──────────────────────────────────────────────────────────
let last        = {yaw:0, pitch:0, roll:0};
let viewOff     = {yaw:0, pitch:0, roll:0};
let baseline    = null;   // {yaw,pitch,roll} — после калибровки
let gotData     = false;

// осанка
let badSince    = null;
let lastAlert   = -Infinity;

// музыка — переключение треков: state machine + hold-timer + recovery
let trackState        = 'neutral'; // 'neutral' | 'held'
let trackHoldStart    = null;      // когда угол впервые превысил порог
let trackRecoverUntil = 0;         // заблокировано до этого timestamp (после срабатывания)
let trackGapStart     = null;      // момент когда угол дропнулся ниже порога (grace период)

// музыка — громкость: yaw + pitch
let yawActive         = false;
let yawHoldStart      = null;
let pitchVolActive    = false;
let pitchVolHoldStart = null;
let currentVol        = null;
let fadeTimer         = null;
let fadeTarget        = null;

// ── Звук ───────────────────────────────────────────────────────────────
let audioCtx = null;
function ctx() {
  return audioCtx || (audioCtx = new (window.AudioContext || window.webkitAudioContext)());
}

function tone(ac, freq, t, dur, vol, type) {
  const o = ac.createOscillator(), g = ac.createGain();
  o.connect(g); g.connect(ac.destination);
  o.type = type || 'sine';
  o.frequency.value = freq;
  g.gain.setValueAtTime(0, t);
  g.gain.linearRampToValueAtTime(vol, t + .018);
  g.gain.exponentialRampToValueAtTime(.0001, t + dur);
  o.start(t); o.stop(t + dur + .04);
}

const SOUNDS = {
  double:  (ac, t, v) => { tone(ac,660,t,.18,v); tone(ac,520,t+.22,.14,v); },
  triple:  (ac, t, v) => [0,.16,.32].forEach(d => tone(ac,600,t+d,.1,v)),
  rising:  (ac, t, v) => {
    const o=ac.createOscillator(),g=ac.createGain();
    o.connect(g); g.connect(ac.destination); o.type='sine';
    o.frequency.setValueAtTime(250,t); o.frequency.linearRampToValueAtTime(1000,t+.55);
    g.gain.setValueAtTime(0,t); g.gain.linearRampToValueAtTime(v,t+.04);
    g.gain.exponentialRampToValueAtTime(.0001,t+.58);
    o.start(t); o.stop(t+.62);
  },
  ping:    (ac, t, v) => tone(ac,1046,t,.35,v),
  low:     (ac, t, v) => { tone(ac,100,t,.45,v,'sawtooth'); tone(ac,200,t,.45,v*.5,'sine'); },
  alarm:   (ac, t, v) => {
    for(let i=0;i<8;i++) tone(ac,i%2?880:1100,t+i*.1,.08,v,'square');
  },
  siren:   (ac, t, v) => {
    const o=ac.createOscillator(),g=ac.createGain();
    o.connect(g); g.connect(ac.destination); o.type='sawtooth';
    o.frequency.setValueAtTime(300,t); o.frequency.linearRampToValueAtTime(1400,t+.45);
    o.frequency.linearRampToValueAtTime(300,t+.9);
    g.gain.setValueAtTime(v,t); g.gain.setValueAtTime(v,t+.8);
    g.gain.linearRampToValueAtTime(0,t+.95);
    o.start(t); o.stop(t+1);
  },
  rapid:   (ac, t, v) => {
    for(let i=0;i<7;i++) tone(ac,1200,t+i*.07,.05,v,'square');
  },
  harsh:   (ac, t, v) => {
    tone(ac,150,t,.5,v,'sawtooth');
    tone(ac,300,t,.5,v*.6,'sawtooth');
    tone(ac,600,t,.25,v*.3,'square');
  },
  klaxon:  (ac, t, v) => {
    const o=ac.createOscillator(),lfo=ac.createOscillator(),lfoG=ac.createGain(),g=ac.createGain();
    o.connect(g); g.connect(ac.destination); o.type='sawtooth';
    lfo.connect(lfoG); lfoG.connect(o.frequency);
    o.frequency.value=450; lfo.frequency.value=7; lfoG.gain.value=120;
    g.gain.setValueAtTime(0,t); g.gain.linearRampToValueAtTime(v,t+.03);
    g.gain.setValueAtTime(v,t+.55); g.gain.linearRampToValueAtTime(0,t+.6);
    lfo.start(t); o.start(t); o.stop(t+.65); lfo.stop(t+.65);
  },
};

function playAlert() {
  if (!chkSound.checked) return;
  const ac  = ctx();
  const vol = Math.min(0.95, Number(slVol.value) / 100);
  (SOUNDS[selSound.value] || SOUNDS.double)(ac, ac.currentTime, vol);
}

document.getElementById('btnTestSound').addEventListener('click', playAlert);

// ── Калибровка (заодно обнуляет вид куба) ──────────────────────────────
document.getElementById('btnCalib').addEventListener('click', () => {
  if (!gotData) { postureLbl.textContent = t('noData'); return; }
  viewOff  = {yaw:last.yaw, pitch:last.pitch, roll:last.roll};
  baseline = {yaw:last.yaw, pitch:last.pitch, roll:last.roll};
  badSince = null; lastAlert = -Infinity;
  // сбросить состояние музыкальных жестов
  trackState = 'neutral'; trackHoldStart = null; trackRecoverUntil = 0; trackGapStart = null;
  const bTrackHold = document.getElementById('bTrackHold');
  if (bTrackHold) bTrackHold.style.width = '0%';
  if (yawActive || pitchVolActive || fadeTimer) {
    clearInterval(fadeTimer); fadeTimer = null; fadeTarget = null;
    yawActive = false; yawHoldStart = null;
    pitchVolActive = false; pitchVolHoldStart = null;
    const normVol = Number(slNormVol.value);
    currentVol = normVol;
    fetch('/api/media?action=vol&level=' + normVol).catch(() => {});
  }
  const bYawHold = document.getElementById('bYawHold');
  if (bYawHold) bYawHold.style.width = '0%';
  dot.className = 'dot good';
  postureLbl.textContent = t('calibrated');
  postureTimer.textContent = '';
  setTimeout(() => { if (postureLbl.textContent === t('calibrated')) postureLbl.textContent = t('postureOk'); }, 2000);
});

// ── Утилиты ────────────────────────────────────────────────────────────
function norm(v) { while(v>180)v-=360; while(v<-180)v+=360; return v; }

function updateBar(fillEl, valEl, dev, threshold) {
  if (!fillEl) return;
  const pct = Math.min(100, Math.abs(dev) / threshold * 100);
  const bad = Math.abs(dev) > threshold;
  fillEl.style.width = pct + '%';
  fillEl.style.background = bad ? 'var(--red)' : pct > 60 ? 'var(--warn)' : 'var(--accent)';
  if (valEl) { valEl.textContent = dev.toFixed(1) + '°'; valEl.style.color = bad ? 'var(--red)' : 'var(--dim)'; }
}

function updatePostureGraph(dp, dr, thP, thR, isBad) {
  const scale = GRAPH_HALF / GRAPH_MAX_DEG;
  const cx = Math.max(6, Math.min(154, GRAPH_CX - dr * scale)); // roll → X: наклон влево → точка влево
  const cy = Math.max(6, Math.min(154, GRAPH_CY - dp * scale)); // pitch forward → Y up (вниз на экране)

  // threshold ellipse
  thEllipse.setAttribute('rx', Math.min(GRAPH_HALF, thR * scale));
  thEllipse.setAttribute('ry', Math.min(GRAPH_HALF, thP * scale));

  // trail
  trailPts.push({cx, cy});
  if (trailPts.length > TRAIL_LEN) trailPts.shift();
  dotTrail.innerHTML = trailPts.slice(0, -1).map((p, i) => {
    const op = ((i + 1) / TRAIL_LEN * 0.45).toFixed(2);
    const r  = (1.5 + i / TRAIL_LEN * 2.5).toFixed(1);
    return `<circle cx="${p.cx.toFixed(1)}" cy="${p.cy.toFixed(1)}" r="${r}" fill="${isBad?'var(--red)':'var(--accent)'}" opacity="${op}"/>`;
  }).join('');

  // позиция точки лерпится в rAF-цикле, здесь только цель и цвет
  dotTarget = {x: cx, y: cy};
  postureDot2d.setAttribute('fill', isBad ? 'var(--red)' : 'var(--accent)');

  graphVals.textContent = `P:${dp.toFixed(1)}° R:${dr.toFixed(1)}°`;
}

// ── Плавный рендер (60 fps, лерп к последним данным с датчика) ─────────
let view      = null;                          // текущие углы куба на экране
let viewTarget = {y:0, p:0, r:0};              // цель из последнего poll
let dotPos    = {x:GRAPH_CX, y:GRAPH_CY};      // текущая точка графика
let dotTarget = {x:GRAPH_CX, y:GRAPH_CY};
const LERP = 0.25;

function renderFrame() {
  if (gotData) {
    if (view === null) view = {...viewTarget};
    // кратчайший путь по углу — чтобы не крутило через 360° на границе ±180
    view.y = norm(view.y + norm(viewTarget.y - view.y) * LERP);
    view.p = norm(view.p + norm(viewTarget.p - view.p) * LERP);
    view.r = norm(view.r + norm(viewTarget.r - view.r) * LERP);
    // куб (WebGL-модуль) зеркалит движения головы по горизонтали и вертикали
    if (window.__setCubeRotation) window.__setCubeRotation(view.y, view.p, view.r);
  }
  dotPos.x += (dotTarget.x - dotPos.x) * LERP;
  dotPos.y += (dotTarget.y - dotPos.y) * LERP;
  postureDot2d.setAttribute('cx', dotPos.x.toFixed(2));
  postureDot2d.setAttribute('cy', dotPos.y.toFixed(2));
  requestAnimationFrame(renderFrame);
}
requestAnimationFrame(renderFrame);

// ── Плавный фейд громкости ─────────────────────────────────────────────
function startFade(from, to, durationMs) {
  if (to === fadeTarget) return; // уже едем к этой цели
  fadeTarget = to;
  clearInterval(fadeTimer); fadeTimer = null;
  from = Math.round(from ?? to);
  if (from === to || durationMs <= 0) {
    currentVol = to;
    fetch('/api/media?action=vol&level=' + to).catch(() => {});
    return;
  }
  const intervalMs = 150;
  const totalSteps = Math.max(1, Math.round(durationMs / intervalMs));
  const delta = (to - from) / totalSteps;
  let s = 0;
  fadeTimer = setInterval(() => {
    s++;
    const vol = s >= totalSteps ? to : Math.round(from + delta * s);
    currentVol = vol;
    fetch('/api/media?action=vol&level=' + vol).catch(() => {});
    if (s >= totalSteps) { clearInterval(fadeTimer); fadeTimer = null; }
  }, intervalMs);
}

function applyVol() {
  const normVol = Number(slNormVol.value);
  const red     = Number(slYawRed.value) / 100;
  const reduced = Math.round(normVol * (1 - red));
  const fadeDur = Number(slFade.value) * 1000;
  if (currentVol === null) currentVol = normVol;
  startFade(currentVol, (yawActive || pitchVolActive) ? reduced : normVol, fadeDur);
}

// ── Переключение трека ─────────────────────────────────────────────────
function showFlash(label) {
  trackFlash.textContent = label;
  trackFlash.classList.add('show');
  setTimeout(() => trackFlash.classList.remove('show'), 900);
}

const bTrackHoldEl = document.getElementById('bTrackHold');
const trackWarn    = document.getElementById('trackWarn');

// Переключение треков работает только с уже запущенным плеером —
// AppleScript иначе сам открывает Spotify/Music, что неожиданно для пользователя
let playerAvailable = false;
async function pollPlayers() {
  if (!chkTrack.checked) return;
  try {
    const p = await fetch('/api/players', {cache:'no-store'}).then(r => r.json());
    playerAvailable = !!(p.spotify || p.music);
  } catch (e) { playerAvailable = false; }
  trackWarn.classList.toggle('hidden', playerAvailable);
}
setInterval(pollPlayers, 3000);
chkTrack.addEventListener('change', () => {
  if (chkTrack.checked) pollPlayers();
});

function checkTrack() {
  if (!chkTrack.checked || !baseline) return;

  const dRollVal = norm(last.roll - baseline.roll);
  const th     = Number(slTrackTh.value);
  const holdMs = Number(slTrackHold.value);
  const gapMs  = Math.min(200, holdMs * 0.3); // grace: дроп ниже порога на < gapMs не сбрасывает
  const now    = Date.now();

  // live-бар крена
  const pct = Math.min(100, Math.abs(dRollVal) / th * 100);
  const over = Math.abs(dRollVal) > th;
  bTrackRoll.style.width = pct + '%';
  bTrackRoll.style.background = over ? 'var(--accent)' : pct > 70 ? 'var(--warn)' : '#444';
  dTrackRoll.textContent = dRollVal.toFixed(1) + '°';

  // Recovery: после срабатывания блокируем новые триггеры
  const recovering = now < trackRecoverUntil;

  if (over) {
    trackGapStart = null; // угол снова над порогом — gap сброшен
    if (trackState === 'neutral' && !recovering) {
      if (trackHoldStart === null) trackHoldStart = now;
      const held = now - trackHoldStart;
      if (bTrackHoldEl) bTrackHoldEl.style.width = Math.min(100, held / holdMs * 100) + '%';
      if (held >= holdMs) {
        trackState = 'held'; trackHoldStart = null;
        // recovery = hold + 500мс чтобы пережить обратное движение
        trackRecoverUntil = now + holdMs + 500;
        if (bTrackHoldEl) bTrackHoldEl.style.width = '0%';
        if (playerAvailable) {
          if (dRollVal > 0) {
            fetch('/api/media?action=next').catch(() => {});
            showFlash('▶▶ NEXT');
          } else {
            fetch('/api/media?action=prev').catch(() => {});
            showFlash('◀◀ PREV');
          }
        }
      }
    }
    if (trackStatus) trackStatus.textContent = recovering ? t('pause') : (trackState === 'held' ? t('hold') : '');
  } else {
    if (trackState === 'neutral') {
      // grace window: кратковременный дроп не сбрасывает hold timer
      if (trackHoldStart !== null) {
        if (trackGapStart === null) trackGapStart = now;
        if (now - trackGapStart > gapMs) {
          // дроп слишком долгий — сброс
          trackHoldStart = null; trackGapStart = null;
          if (bTrackHoldEl) bTrackHoldEl.style.width = '0%';
        }
        // иначе — ждём, держим hold timer
      }
    } else {
      // 'held' → возврат в нейтраль
      trackState = 'neutral'; trackHoldStart = null; trackGapStart = null;
      if (bTrackHoldEl) bTrackHoldEl.style.width = '0%';
    }
    if (trackStatus) {
      const recLeft = trackRecoverUntil - now;
      trackStatus.textContent = recLeft > 0 ? t('pause') : (baseline ? t('ready') : '');
    }
  }
}

// ── Громкость на yaw ───────────────────────────────────────────────────
const bYawHoldEl = document.getElementById('bYawHold');

function checkYawVol() {
  if (!chkYawVol.checked || !baseline) return;
  const dYawVal = Math.abs(norm(last.yaw - baseline.yaw));
  const th      = Number(slYawTh.value);
  const normVol = Number(slNormVol.value);
  const red     = Number(slYawRed.value) / 100;
  const reduced = Math.round(normVol * (1 - red));
  const holdMs  = Number(slYawHold.value);
  const fadeDur = Number(slFade.value) * 1000;
  const now     = Date.now();

  // live-бар поворота
  const pct = Math.min(100, dYawVal / th * 100);
  const over = dYawVal > th;
  bYaw.style.width = pct + '%';
  bYaw.style.background = over ? 'var(--blue)' : pct > 70 ? 'var(--warn)' : '#444';
  dYaw.textContent = dYawVal.toFixed(1) + '°';

  if (over) {
    if (!yawActive) {
      if (yawHoldStart === null) yawHoldStart = now;
      const held = now - yawHoldStart;
      if (bYawHoldEl) bYawHoldEl.style.width = Math.min(100, held / holdMs * 100) + '%';
      if (held >= holdMs) {
        yawActive = true; yawHoldStart = null;
        if (bYawHoldEl) bYawHoldEl.style.width = '0%';
        applyVol();
      }
    }
    if (yawStatus) { yawStatus.textContent = yawActive ? t('quiet') : ''; yawStatus.style.color = 'var(--blue)'; }
  } else {
    yawHoldStart = null;
    if (bYawHoldEl) bYawHoldEl.style.width = '0%';
    if (yawActive) { yawActive = false; applyVol(); }
    if (yawStatus) yawStatus.textContent = '';
  }
}

// ── Громкость на pitch ─────────────────────────────────────────────────
const bPitchVolEl     = document.getElementById('bPitchVol');
const dPitchVolEl     = document.getElementById('dPitchVol');
const bPitchVolHoldEl = document.getElementById('bPitchVolHold');
const pitchVolStatus  = document.getElementById('pitchVolStatus');

function checkPitchVol() {
  if (!chkPitchVol.checked || !baseline) return;
  const dPitchVal = Math.abs(norm(last.pitch - baseline.pitch));
  const th     = Number(slPitchVolTh.value);
  const holdMs = Number(slPitchVolHold.value);
  const now    = Date.now();

  if (bPitchVolEl) {
    const pct = Math.min(100, dPitchVal / th * 100);
    bPitchVolEl.style.width = pct + '%';
    bPitchVolEl.style.background = dPitchVal > th ? 'var(--blue)' : pct > 70 ? 'var(--warn)' : '#444';
    if (dPitchVolEl) dPitchVolEl.textContent = dPitchVal.toFixed(1) + '°';
  }

  if (dPitchVal > th) {
    if (!pitchVolActive) {
      if (pitchVolHoldStart === null) pitchVolHoldStart = now;
      const held = now - pitchVolHoldStart;
      if (bPitchVolHoldEl) bPitchVolHoldEl.style.width = Math.min(100, held / holdMs * 100) + '%';
      if (held >= holdMs) {
        pitchVolActive = true; pitchVolHoldStart = null;
        if (bPitchVolHoldEl) bPitchVolHoldEl.style.width = '0%';
        applyVol();
      }
    }
    if (pitchVolStatus) { pitchVolStatus.textContent = pitchVolActive ? t('quiet') : ''; pitchVolStatus.style.color = 'var(--blue)'; }
  } else {
    pitchVolHoldStart = null;
    if (bPitchVolHoldEl) bPitchVolHoldEl.style.width = '0%';
    if (pitchVolActive) { pitchVolActive = false; applyVol(); }
    if (pitchVolStatus) pitchVolStatus.textContent = '';
  }
}

// ── Осанка ─────────────────────────────────────────────────────────────
function checkPosture(now) {
  if (!baseline) return;
  const dp = norm(last.pitch - baseline.pitch);
  const dr = norm(last.roll  - baseline.roll);
  const dy = norm(last.yaw   - baseline.yaw);
  const thP = Number(slPitch.value), thR = Number(slRoll.value);
  const delay    = Number(slDelay.value) * 1000;
  const cooldown = Number(slCooldown.value) * 1000;
  const isBad = Math.abs(dp) > thP || Math.abs(dr) > thR;

  updatePostureGraph(dp, dr, thP, thR, isBad);

  if (isBad) {
    if (!badSince) badSince = now;
    const held = now - badSince;
    const left = Math.max(0, delay - held);
    dot.className = held >= delay ? 'dot bad' : 'dot idle';
    postureLbl.textContent = held >= delay ? t('fixPosture') : t('checking');
    postureTimer.textContent = held >= delay
      ? Math.round(held/1000) + t('u_sec')
      : left > 0 ? '-' + Math.round(left/1000) + t('u_sec') : '';
    if (held >= delay && now - lastAlert > cooldown) {
      lastAlert = now; playAlert();
    }
  } else {
    badSince = null;
    dot.className = 'dot good';
    postureLbl.textContent = t('postureOk');
    postureTimer.textContent = '';
  }
}

// ── Polling ────────────────────────────────────────────────────────────
// pollRunning-guard гарантирует ровно один активный цикл.
// kickPoll сбрасывает отложенный таймер и стартует немедленно —
// нужно при возврате фокуса после диалога Automation macOS.
let pollTimer   = null;
let pollRunning = false;

async function poll() {
  if (pollRunning) return;  // уже работает — не запускаем второй
  pollRunning = true;
  try {
    const d = await fetch('/orientation', {cache:'no-store'}).then(r => r.json());
    if (d.connected) {
      gotData = true;
      // roll с датчика приходит инвертированным — переворачиваем на входе,
      // чтобы показания, график и жесты совпадали с реальным наклоном головы
      last = {yaw:d.yaw, pitch:d.pitch, roll:-d.roll};
      const y = norm(last.yaw   - viewOff.yaw);
      const p = norm(last.pitch - viewOff.pitch);
      const r = norm(last.roll  - viewOff.roll);
      yawEl.textContent   = y.toFixed(1) + '°';
      pitchEl.textContent = p.toFixed(1) + '°';
      rollEl.textContent  = r.toFixed(1) + '°';
      // рендер куба — в rAF-цикле с лерпом, здесь только цель
      viewTarget = {y, p, r};
      connEl.className = 'conn ok'; connEl.textContent = t('connOk');
      checkPosture(Date.now());
      checkTrack();
      checkPitchVol();
      checkYawVol();
    } else {
      connEl.className = 'conn warn';
      connEl.textContent = gotData ? t('connLost') : t('connWait');
    }
  } catch(e) {
    connEl.className = 'conn err';
    connEl.textContent = t('connErr') + e.message;
  }
  pollRunning = false;
  pollTimer = setTimeout(poll, 50);
}

function kickPoll() {
  clearTimeout(pollTimer); pollTimer = null;
  poll();
}

document.addEventListener('visibilitychange', () => {
  if (document.visibilityState === 'visible') kickPoll();
});
window.addEventListener('focus', kickPoll);

// ── Персист настроек между запусками ───────────────────────────────────
const PERSIST_RANGES = ['slPitch','slRoll','slDelay','slCooldown','slVol',
  'slTrackTh','slTrackHold','slPitchVolTh','slPitchVolHold',
  'slYawTh','slYawHold','slYawRed','slNormVol','slFade'];
const PERSIST_CHECKS = ['chkSound','chkTrack','chkPitchVol','chkYawVol'];

function saveSettings() {
  const s = { sound: selSound.value };
  PERSIST_RANGES.forEach(id => s[id] = document.getElementById(id).value);
  PERSIST_CHECKS.forEach(id => s[id] = document.getElementById(id).checked);
  localStorage.setItem('settings.v1', JSON.stringify(s));
}
(function restoreSettings() {
  let s = null;
  try { s = JSON.parse(localStorage.getItem('settings.v1')); } catch (e) {}
  if (s) {
    PERSIST_RANGES.forEach(id => {
      if (s[id] === undefined) return;
      const el = document.getElementById(id);
      el.value = s[id];
      el.dispatchEvent(new Event('input'));   // обновить подпись значения
    });
    PERSIST_CHECKS.forEach(id => {
      if (s[id] === undefined) return;
      const el = document.getElementById(id);
      el.checked = s[id];
      el.dispatchEvent(new Event('change'));  // показать/скрыть sub-настройки
    });
    if (s.sound && SOUND_KEYS.includes(s.sound)) {
      selSound.value = s.sound;
      selSoundLbl.textContent = t('snd_' + s.sound);
      selSoundList.querySelectorAll('.sel').forEach(o => o.classList.remove('sel'));
      soundOptEls.get(s.sound)?.classList.add('sel');
    }
  }
  [...PERSIST_RANGES, ...PERSIST_CHECKS].forEach(id => {
    const el = document.getElementById(id);
    el.addEventListener('input', saveSettings);
    el.addEventListener('change', saveSettings);
  });
})();

// ── Модалки: открыть/закрыть ───────────────────────────────────────────
function openModal(id)  { document.getElementById(id).classList.add('show'); }
function closeModal(id) { document.getElementById(id).classList.remove('show'); }
document.querySelectorAll('.am-close').forEach(b =>
  b.addEventListener('click', () => closeModal(b.dataset.close)));
document.querySelectorAll('.am-overlay').forEach(ov =>
  ov.addEventListener('click', e => { if (e.target === ov) ov.classList.remove('show'); }));
document.addEventListener('keydown', e => {
  if (e.key === 'Escape')
    document.querySelectorAll('.am-overlay.show').forEach(ov => ov.classList.remove('show'));
});

// ── Версия и релиз-ноуты ───────────────────────────────────────────────
const REPO = 'antonenkoo/airpods-head-tracker';
const verChip = document.getElementById('verChip');
let appVersion = '0.0.0';
fetch('/api/app-info').then(r => r.json()).then(j => {
  appVersion = j.version;
  verChip.textContent = 'v' + appVersion;
  checkUpdate();
}).catch(() => {});

const escHtml = s => s.replace(/[&<>]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;'}[c]));
let notesLoaded = false;
verChip.addEventListener('click', async () => {
  openModal('notesModal');
  if (notesLoaded) return;
  const body = document.getElementById('notesBody');
  try {
    const rels = await fetch('https://api.github.com/repos/' + REPO + '/releases?per_page=6')
      .then(r => r.json());
    body.innerHTML = rels.map(r => `
      <div class="rel">
        <div class="rel-head"><b>${escHtml(r.tag_name || '')}</b>
          <span>${new Date(r.published_at).toLocaleDateString()}</span></div>
        <div class="rel-notes">${escHtml(r.body || '').replace(/\\r?\\n/g, '<br>')}</div>
      </div>`).join('');
    notesLoaded = true;
  } catch (e) {
    body.innerHTML = '<div class="rel-notes">' + t('notesErr') + '</div>';
  }
});

// ── Проверка обновлений + self-update ──────────────────────────────────
function cmpVer(a, b) {
  const pa = a.split('.').map(Number), pb = b.split('.').map(Number);
  for (let i = 0; i < 3; i++) {
    if ((pa[i] || 0) > (pb[i] || 0)) return 1;
    if ((pa[i] || 0) < (pb[i] || 0)) return -1;
  }
  return 0;
}
async function checkUpdate() {
  try {
    const rel = await fetch('https://api.github.com/repos/' + REPO + '/releases/latest')
      .then(r => r.json());
    const tag = (rel.tag_name || '').replace(/^v/, '');
    if (tag && cmpVer(tag, appVersion) === 1 &&
        localStorage.getItem('skipVer') !== tag) {
      document.getElementById('updVer').textContent = 'v' + tag;
      document.getElementById('updCard').dataset.tag = tag;
      document.getElementById('updCard').classList.add('show');
    }
  } catch (e) {}
}
document.getElementById('updLater').addEventListener('click', () => {
  const card = document.getElementById('updCard');
  localStorage.setItem('skipVer', card.dataset.tag || '');
  card.classList.remove('show');
});
document.getElementById('updGo').addEventListener('click', async () => {
  const stateEl = document.getElementById('updState');
  document.getElementById('updGo').disabled = true;
  try { await fetch('/api/update-start'); } catch (e) {}
  const timer = setInterval(async () => {
    let st = '';
    try { st = (await fetch('/api/update-status').then(r => r.json())).state; }
    catch (e) { st = 'relaunching'; }   // сервер умер = перезапуск идёт
    if (st.startsWith('error')) {
      clearInterval(timer);
      stateEl.textContent = t('updErr');
      document.getElementById('updGo').disabled = false;
      return;
    }
    stateEl.textContent = t('upd_' + st) !== 'upd_' + st ? t('upd_' + st) : st;
  }, 700);
});

// ── Фидбек ─────────────────────────────────────────────────────────────
const FEEDBACK_API = 'https://api-production-d023.up.railway.app';
let fbType = 'bug';
document.getElementById('fbOpen').addEventListener('click', () => openModal('fbModal'));
document.querySelectorAll('#fbTypes button').forEach(b =>
  b.addEventListener('click', () => {
    fbType = b.dataset.type;
    document.querySelectorAll('#fbTypes button').forEach(x => x.classList.toggle('on', x === b));
  }));
const fbSatRange = document.getElementById('fbSatRange');
const fbSatSync = () => {
  const v = Number(fbSatRange.value);
  document.getElementById('fbSatVal').textContent = v + '%';
  document.getElementById('fbSatEmo').textContent =
    v < 20 ? '💀' : v < 40 ? '😖' : v < 60 ? '😐' : v < 80 ? '🙂' : '🤩';
};
fbSatRange.addEventListener('input', fbSatSync);
fbSatSync();
document.getElementById('fbSend').addEventListener('click', async () => {
  const status = document.getElementById('fbStatus');
  const text = document.getElementById('fbText').value.trim();
  if (text.length < 3) { status.className = 'fb-status err'; status.textContent = t('fbShort'); return; }
  status.className = 'fb-status'; status.textContent = t('fbSending');
  const skip = document.getElementById('fbSatSkip').checked;
  try {
    const r = await fetch(FEEDBACK_API + '/feedback', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        type: fbType, message: text,
        satisfaction: skip ? null : Number(fbSatRange.value),
        version: appVersion, locale: lang,
      }),
    });
    if (!r.ok) throw new Error('http ' + r.status);
    status.className = 'fb-status ok'; status.textContent = t('fbDone');
    document.getElementById('fbText').value = '';
    setTimeout(() => { closeModal('fbModal'); status.textContent = ''; }, 1600);
  } catch (e) {
    status.className = 'fb-status err'; status.textContent = t('fbErr');
  }
});

setLang(lang);
poll();
</script>

<script type="importmap">
{"imports":{"three":"/three.module.min.js"}}
</script>
<script type="module">
// ── WebGL-куб: цельный тонкий каркас со скруглёнными углами + стеклянные грани.
// Параметры подобраны в конфигураторе (пресет Марка).
import * as THREE from 'three';

const P = {
  tubeR: 0.01, cornerR: 0.03,
  glass: 0.09, roughness: 0.32, clearcoat: 0, emissive: 0,
};
const ACCENT = 0x00ffaa;
const SIZE = 1.6;

const canvas = document.getElementById('cube3d');
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
renderer.setPixelRatio(Math.min(2, window.devicePixelRatio));
renderer.setClearColor(0x000000, 0);

const scene = new THREE.Scene();
// Дистанция такая, чтобы ограничивающая сфера куба (r = h·√3) целиком
// помещалась в кадр при любом повороте головы: d ≥ r / sin(fov/2)
const camera = new THREE.PerspectiveCamera(38, 1, 0.1, 20);
camera.position.set(0, 0, 4.5);
camera.lookAt(0, 0, 0);

scene.add(new THREE.AmbientLight(0xffffff, 0.5));
const key = new THREE.DirectionalLight(0xffffff, 1.5);
key.position.set(2.5, 3, 2);
scene.add(key);
const rim = new THREE.DirectionalLight(0x66ffcc, 0.5);
rim.position.set(-3, -1, -2);
scene.add(rim);

// Каркас: 12 цилиндров-рёбер + 24 четверть-дуги на углах
function roundedFrame(tubeR, cornerR, material) {
  const g = new THREE.Group();
  const h = SIZE / 2;
  const cyl = new THREE.CylinderGeometry(tubeR, tubeR, SIZE - cornerR * 2, 20);
  const arc = new THREE.TorusGeometry(cornerR, tubeR, 14, 16, Math.PI / 2);

  const edge = (axis, a, b) => {
    const m = new THREE.Mesh(cyl, material);
    if (axis === 'x') { m.rotation.z = Math.PI / 2; m.position.set(0, a, b); }
    if (axis === 'y') { m.position.set(a, 0, b); }
    if (axis === 'z') { m.rotation.x = Math.PI / 2; m.position.set(a, b, 0); }
    g.add(m);
  };
  for (const a of [-h, h]) for (const b of [-h, h]) {
    edge('x', a, b); edge('y', a, b); edge('z', a, b);
  }

  const quad = (sx, sy) => (sx > 0 ? (sy > 0 ? 0 : -Math.PI / 2) : (sy > 0 ? Math.PI / 2 : Math.PI));
  for (const sx of [-1, 1]) for (const sy of [-1, 1]) for (const sz of [-1, 1]) {
    let m = new THREE.Mesh(arc, material);
    m.rotation.z = quad(sx, sy);
    m.position.set(sx * (h - cornerR), sy * (h - cornerR), sz * h);
    g.add(m);
    m = new THREE.Mesh(arc, material);
    m.rotation.x = Math.PI / 2;
    m.rotateZ(quad(sx, sz));
    m.position.set(sx * (h - cornerR), sy * h, sz * (h - cornerR));
    g.add(m);
    m = new THREE.Mesh(arc, material);
    m.rotation.y = -Math.PI / 2;
    m.rotateZ(quad(sz, sy));
    m.position.set(sx * h, sy * (h - cornerR), sz * (h - cornerR));
    g.add(m);
  }
  return g;
}

const cubeGroup = new THREE.Group();
const coreMat = new THREE.MeshPhysicalMaterial({
  color: ACCENT, roughness: P.roughness, metalness: 0,
  clearcoat: P.clearcoat, clearcoatRoughness: 0.3,
  emissive: ACCENT, emissiveIntensity: P.emissive,
});
cubeGroup.add(roundedFrame(P.tubeR, P.cornerR, coreMat));

// Стеклянные грани
const glass = new THREE.Mesh(
  new THREE.BoxGeometry(SIZE, SIZE, SIZE),
  new THREE.MeshPhysicalMaterial({
    color: ACCENT, transparent: true, opacity: P.glass,
    roughness: 0.2, side: THREE.DoubleSide, depthWrite: false,
  })
);
glass.renderOrder = 1;
cubeGroup.add(glass);

// Надпись FACE на передней грани (canvas-текстура, обновляется при смене языка)
const labelCanvas = document.createElement('canvas');
labelCanvas.width = labelCanvas.height = 256;
const labelCtx = labelCanvas.getContext('2d');
const labelTex = new THREE.CanvasTexture(labelCanvas);
function drawFace(text) {
  labelCtx.clearRect(0, 0, 256, 256);
  labelCtx.font = 'bold 38px -apple-system, Arial';
  labelCtx.textAlign = 'center';
  labelCtx.textBaseline = 'middle';
  labelCtx.fillStyle = '#00ffaa';
  labelCtx.fillText(text, 128, 128);
  labelTex.needsUpdate = true;
}
const label = new THREE.Mesh(
  new THREE.PlaneGeometry(SIZE * 0.92, SIZE * 0.92),
  new THREE.MeshBasicMaterial({ map: labelTex, transparent: true })
);
label.position.z = SIZE / 2 + 0.003;
label.renderOrder = 2;
cubeGroup.add(label);

scene.add(cubeGroup);

// Мост в основной скрипт: он лерпит углы, мы применяем.
// Порядок 'YXZ' повторяет CSS rotateY·rotateX·rotateZ; знаки — перевод
// из CSS-пространства (Y вниз) в three (Y вверх): rotateY(-y) rotateX(p) rotateZ(-r)
// эквивалентно rotation.set(-p, -y, +r).
const RAD = Math.PI / 180;
cubeGroup.rotation.order = 'YXZ';
window.__setCubeRotation = (y, p, r) => {
  cubeGroup.rotation.set(-p * RAD, -y * RAD, r * RAD);
};
window.__setFaceText = drawFace;
drawFace(t('faceFront'));

function resize() {
  const w = canvas.clientWidth, h = canvas.clientHeight;
  if (w && h) {
    renderer.setSize(w, h, false);
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
  }
}
new ResizeObserver(resize).observe(canvas);
resize();

(function loop() {
  renderer.render(scene, camera);
  requestAnimationFrame(loop);
})();
</script>
</body>
</html>
"""
