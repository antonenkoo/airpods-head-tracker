let indexHTML = """
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>AirPods · Осанка</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
:root{
  --bg:#121212;--card:#1e1e1e;--accent:#00ffaa;--blue:#33b5e5;
  --red:#ff4444;--warn:#ffaa00;--dim:#555;--text:#fff;
  --cs:150px; /* cube size */
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

/* 3D куб */
.scene-wrap{width:100%;display:flex;justify-content:center;
  padding:calc(var(--cs)*0.3) 0;overflow:visible}
.scene{width:var(--cs);height:var(--cs);
  perspective:calc(var(--cs)*3.5);flex-shrink:0;overflow:visible}
.cube{width:100%;height:100%;position:relative;transform-style:preserve-3d;transition:transform .05s linear}
.face{position:absolute;width:var(--cs);height:var(--cs);
  border:2px solid var(--accent);background:rgba(0,255,170,.07);
  display:flex;align-items:center;justify-content:center;
  font-weight:bold;font-size:calc(var(--cs)*0.06);border-radius:calc(var(--cs)*0.09)}
.front{transform:rotateY(0deg)   translateZ(calc(var(--cs)/2));background:rgba(0,255,170,.16);color:var(--accent)}
.back {transform:rotateY(180deg) translateZ(calc(var(--cs)/2))}
.right{transform:rotateY(90deg)  translateZ(calc(var(--cs)/2));border-color:var(--blue)}
.left {transform:rotateY(-90deg) translateZ(calc(var(--cs)/2));border-color:var(--blue)}
.top  {transform:rotateX(90deg)  translateZ(calc(var(--cs)/2))}
.bottom{transform:rotateX(-90deg)translateZ(calc(var(--cs)/2))}

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
.toggle-row input[type=checkbox]{accent-color:var(--accent);width:15px;height:15px;flex-shrink:0}
.toggle-row label{font-size:.85rem;color:#bbb;cursor:pointer}
.sub-settings{padding-left:22px;display:flex;flex-direction:column;gap:5px}
.sub-settings.hidden{display:none}

/* Настройки-сетка */
.sg{display:grid;grid-template-columns:1fr auto auto;gap:5px 8px;align-items:center}
.sg label{font-size:.8rem;color:#999}
.sg input[type=range]{width:90px;accent-color:var(--accent)}
.sg .val{font-family:monospace;font-size:.8rem;color:var(--accent);text-align:right;min-width:34px}
.sg .full{grid-column:1/-1}
.sg select{grid-column:1/-1;background:#252525;color:var(--text);
  border:1px solid #3a3a3a;border-radius:7px;padding:5px 8px;font-size:.82rem}
.sg input[type=checkbox]{accent-color:var(--accent);width:14px;height:14px}

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
  /* куб — размер управляется JS через --cs */
  :root{ --cs: 182px; }
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
      <h1>🎧 AirPods · Осанка</h1>
      <div class="subtitle">Сядь прямо → «Калибровать» → носи с AirPods в ушах</div>
    </div>
    <div class="conn warn" id="conn">Подключение…</div>
  </header>

  <div class="left-col">

    <div class="left-top">
      <div class="scene-wrap">
        <div class="scene">
          <div class="cube" id="cube">
            <div class="face front">ЛИЦО ☺</div>
            <div class="face back">ЗАТЫЛОК</div>
            <div class="face right">ПРАВО</div>
            <div class="face left">ЛЕВО</div>
            <div class="face top">ВЕРХ</div>
            <div class="face bottom">НИЗ</div>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-title">Положение головы</div>
        <div class="angles">
          <div><div class="angle-val" id="yaw">0°</div><div class="angle-lbl">Yaw Л/П</div></div>
          <div><div class="angle-val" id="pitch">0°</div><div class="angle-lbl">Pitch В/Н</div></div>
          <div><div class="angle-val" id="roll">0°</div><div class="angle-lbl">Roll крен</div></div>
        </div>
      </div>

      <div class="btn-row">
        <button class="btn-primary" id="btnCalib">Калибровать</button>
        <button class="btn-outline" id="btnCenter">Обнулить вид</button>
      </div>
    </div><!-- /left-top -->

    <div class="left-bot">
    <!-- Осанка -->
    <div class="card graph-card">
      <div class="card-title">Осанка</div>
      <div class="posture-row">
        <div class="dot idle" id="dot"></div>
        <span class="posture-lbl" id="postureLbl">Не откалибровано</span>
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
        <text x="94" y="17"  fill="#404040" font-size="7" font-family="monospace">вперёд</text>
        <text x="94" y="172" fill="#404040" font-size="7" font-family="monospace">назад</text>
        <text x="9"  y="94"  fill="#404040" font-size="7" font-family="monospace">Л</text>
        <text x="161" y="94" fill="#404040" font-size="7" font-family="monospace">П</text>
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
      <div class="card-title">Музыка</div>
      <div class="music-section">

        <div class="toggle-row">
          <input type="checkbox" id="chkTrack" checked>
          <label for="chkTrack">Переключение треков (крен головы)</label>
        </div>
        <div class="sub-settings" id="trackSub">
          <div class="sg">
            <label>Порог крена</label>
            <input type="range" id="slTrackTh" min="5" max="60" value="25">
            <span class="val" id="lblTrackTh">25°</span>
          </div>
          <div class="sg">
            <label>Задержка срабатывания</label>
            <input type="range" id="slTrackHold" min="100" max="1500" step="50" value="600">
            <span class="val" id="lblTrackHold">600мс</span>
          </div>
          <!-- live крен + статус -->
          <div class="bar-row" style="margin-top:4px">
            <span class="bar-name">Крен</span>
            <div class="bar-track"><div class="bar-fill" id="bTrackRoll" style="width:0%"></div></div>
            <span class="bar-val" id="dTrackRoll">0°</span>
          </div>
          <div class="bar-row" style="margin-top:2px">
            <span class="bar-name" style="color:#555">заряд</span>
            <div class="bar-track"><div class="bar-fill" id="bTrackHold" style="width:0%;background:var(--accent)"></div></div>
            <span id="trackStatus" style="font-size:.7rem;color:var(--accent);font-family:monospace;min-width:38px;text-align:right"></span>
          </div>
          <div style="font-size:.7rem;color:#444;margin-top:2px">⚠ При первом запуске macOS попросит разрешение — разреши</div>
        </div>

        <div class="toggle-row" style="margin-top:4px">
          <input type="checkbox" id="chkPitchVol">
          <label for="chkPitchVol">Громкость ↓ при наклоне головы (Pitch)</label>
        </div>
        <div class="sub-settings hidden" id="pitchVolSub">
          <div class="sg">
            <label>Порог наклона</label>
            <input type="range" id="slPitchVolTh" min="5" max="60" value="20">
            <span class="val" id="lblPitchVolTh">20°</span>
            <label>Задержка срабатывания</label>
            <input type="range" id="slPitchVolHold" min="100" max="1500" step="50" value="400">
            <span class="val" id="lblPitchVolHold">400мс</span>
          </div>
          <div class="bar-row" style="margin-top:4px">
            <span class="bar-name">Наклон</span>
            <div class="bar-track"><div class="bar-fill" id="bPitchVol" style="width:0%"></div></div>
            <span class="bar-val" id="dPitchVol">0°</span>
          </div>
          <div class="bar-row" style="margin-top:2px">
            <span class="bar-name" style="color:#555">заряд</span>
            <div class="bar-track"><div class="bar-fill" id="bPitchVolHold" style="width:0%;background:var(--blue)"></div></div>
            <span id="pitchVolStatus" style="font-size:.7rem;font-family:monospace;min-width:38px;text-align:right"></span>
          </div>
          <div style="font-size:.7rem;color:#555;margin-top:2px">Уровни снижения и фейд — общие с Yaw</div>
        </div>

        <div class="toggle-row" style="margin-top:4px">
          <input type="checkbox" id="chkYawVol" checked>
          <label for="chkYawVol">Громкость ↓ при повороте головы (Yaw)</label>
        </div>
        <div class="sub-settings" id="yawSub">
          <div class="sg">
            <label>Порог поворота</label>
            <input type="range" id="slYawTh" min="5" max="90" value="20">
            <span class="val" id="lblYawTh">20°</span>
            <label>Задержка срабатывания</label>
            <input type="range" id="slYawHold" min="100" max="1500" step="50" value="400">
            <span class="val" id="lblYawHold">400мс</span>
            <label>Снижение громкости</label>
            <input type="range" id="slYawRed" min="10" max="100" value="70">
            <span class="val" id="lblYawRed">70%</span>
            <label>Нормальная громкость</label>
            <input type="range" id="slNormVol" min="0" max="100" value="70">
            <span class="val" id="lblNormVol">70%</span>
            <label>Фейд громкости</label>
            <input type="range" id="slFade" min="1" max="10" value="3">
            <span class="val" id="lblFade">3 с</span>
          </div>
          <!-- live yaw -->
          <div class="bar-row" style="margin-top:4px">
            <span class="bar-name">Поворот</span>
            <div class="bar-track"><div class="bar-fill" id="bYaw" style="width:0%"></div></div>
            <span class="bar-val" id="dYaw">0°</span>
          </div>
          <div class="bar-row" style="margin-top:2px">
            <span class="bar-name" style="color:#555">заряд</span>
            <div class="bar-track"><div class="bar-fill" id="bYawHold" style="width:0%;background:var(--blue)"></div></div>
            <span id="yawStatus" style="font-size:.7rem;font-family:monospace;min-width:38px;text-align:right"></span>
          </div>
        </div>

      </div>
    </div>

    <!-- Настройки осанки + звук -->
    <div class="card">
      <div class="card-title">Настройки осанки и звука</div>
      <div class="sg">
        <label>Порог наклона вперёд (Pitch)</label>
        <input type="range" id="slPitch" min="3" max="90" value="15">
        <span class="val" id="lblPitch">15°</span>

        <label>Порог крена (Roll)</label>
        <input type="range" id="slRoll" min="3" max="60" value="10">
        <span class="val" id="lblRoll">10°</span>

        <label>Задержка перед сигналом</label>
        <input type="range" id="slDelay" min="0" max="30" value="5">
        <span class="val" id="lblDelay">5 с</span>

        <label>Пауза между сигналами</label>
        <input type="range" id="slCooldown" min="5" max="300" value="60">
        <span class="val" id="lblCooldown">60 с</span>

        <label>Звук</label>
        <input type="checkbox" id="chkSound" checked>
        <span></span>

        <label>Громкость сигнала</label>
        <input type="range" id="slVol" min="0" max="100" value="70">
        <span class="val" id="lblVol">70%</span>

        <label class="full">Тип сигнала</label>
        <select id="selSound" class="full">
          <option value="double">Двойной тон</option>
          <option value="triple">Три коротких</option>
          <option value="rising">Нарастающий</option>
          <option value="ping">Одиночный пинг</option>
          <option value="low">Низкий гул</option>
          <option value="alarm">Тревога (агрессивный)</option>
          <option value="siren">Сирена</option>
          <option value="rapid">Бипер (быстрый)</option>
          <option value="harsh">Жёсткий гудок</option>
          <option value="klaxon">Клаксон</option>
        </select>
      </div>
    </div>

    <div class="btn-row">
      <button class="btn-muted" id="btnTestSound">🔊 Тест звука</button>
    </div>

  </div><!-- /right-col -->

</div><!-- /page -->

<div class="track-flash" id="trackFlash"></div>

<script>
// ── DOM refs ────────────────────────────────────────────────────────────
const cube       = document.getElementById('cube');
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

// ── Слайдеры ────────────────────────────────────────────────────────────
function bind(id, lblId, suffix) {
  const el  = document.getElementById(id);
  const lbl = document.getElementById(lblId);
  const upd = () => lbl.textContent = el.value + suffix;
  el.addEventListener('input', upd); upd();
  return el;
}
function bindMs(id, lblId) {
  const el  = document.getElementById(id);
  const lbl = document.getElementById(lblId);
  const upd = () => {
    const ms = Number(el.value);
    lbl.textContent = ms < 1000 ? ms + 'мс' : (ms/1000).toFixed(1) + 'с';
  };
  el.addEventListener('input', upd); upd();
  return el;
}
const slPitch      = bind('slPitch',      'lblPitch',     '°');
const slRoll       = bind('slRoll',       'lblRoll',      '°');
const slDelay      = bind('slDelay',      'lblDelay',     ' с');
const slCooldown   = bind('slCooldown',   'lblCooldown',  ' с');
const slVol        = bind('slVol',        'lblVol',       '%');
const slTrackTh      = bind('slTrackTh',      'lblTrackTh',     '°');
const slTrackHold    = bindMs('slTrackHold',  'lblTrackHold');
const slPitchVolTh   = bind('slPitchVolTh',   'lblPitchVolTh',  '°');
const slPitchVolHold = bindMs('slPitchVolHold','lblPitchVolHold');
const slYawTh        = bind('slYawTh',        'lblYawTh',       '°');
const slYawHold    = bindMs('slYawHold',  'lblYawHold');
const slYawRed     = bind('slYawRed',     'lblYawRed',    '%');
const slNormVol    = bind('slNormVol',    'lblNormVol',   '%');
const slFade       = bind('slFade',       'lblFade',      ' с');

const chkSound     = document.getElementById('chkSound');
const chkTrack     = document.getElementById('chkTrack');
const chkPitchVol  = document.getElementById('chkPitchVol');
const chkYawVol    = document.getElementById('chkYawVol');
const selSound   = document.getElementById('selSound');

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

// ── Калибровка ─────────────────────────────────────────────────────────
document.getElementById('btnCenter').addEventListener('click', () => {
  viewOff = {yaw:last.yaw, pitch:last.pitch, roll:last.roll};
});

document.getElementById('btnCalib').addEventListener('click', () => {
  if (!gotData) { postureLbl.textContent = 'Нет данных с AirPods'; return; }
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
  postureLbl.textContent = 'Откалибровано — сиди прямо!';
  postureTimer.textContent = '';
  setTimeout(() => { if (postureLbl.textContent.startsWith('Откалибровано')) postureLbl.textContent='Осанка OK'; }, 2000);
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
  const cx = Math.max(6, Math.min(154, GRAPH_CX - dr * scale)); // roll → X (inverted to match)
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

  // dot
  postureDot2d.setAttribute('cx', cx.toFixed(1));
  postureDot2d.setAttribute('cy', cy.toFixed(1));
  postureDot2d.setAttribute('fill', isBad ? 'var(--red)' : 'var(--accent)');

  graphVals.textContent = `P:${dp.toFixed(1)}° R:${dr.toFixed(1)}°`;
}

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
        if (dRollVal > 0) {
          fetch('/api/media?action=next').catch(() => {});
          showFlash('▶▶ NEXT');
        } else {
          fetch('/api/media?action=prev').catch(() => {});
          showFlash('◀◀ PREV');
        }
      }
    }
    if (trackStatus) trackStatus.textContent = recovering ? '⏳ пауза' : (trackState === 'held' ? 'держи…' : '');
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
      trackStatus.textContent = recLeft > 0 ? '⏳ пауза' : (baseline ? 'готов' : '');
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
    if (yawStatus) { yawStatus.textContent = yawActive ? '🔇 тихо' : ''; yawStatus.style.color = 'var(--blue)'; }
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
    if (pitchVolStatus) { pitchVolStatus.textContent = pitchVolActive ? '🔇 тихо' : ''; pitchVolStatus.style.color = 'var(--blue)'; }
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
    postureLbl.textContent = held >= delay ? '⚠ Выправи осанку!' : 'Проверяю…';
    postureTimer.textContent = held >= delay
      ? Math.round(held/1000) + 'с'
      : left > 0 ? '-' + Math.round(left/1000) + 'с' : '';
    if (held >= delay && now - lastAlert > cooldown) {
      lastAlert = now; playAlert();
    }
  } else {
    badSince = null;
    dot.className = 'dot good';
    postureLbl.textContent = 'Осанка OK';
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
      last = {yaw:d.yaw, pitch:d.pitch, roll:d.roll};
      const y = norm(d.yaw   - viewOff.yaw);
      const p = norm(d.pitch - viewOff.pitch);
      const r = norm(d.roll  - viewOff.roll);
      yawEl.textContent   = y.toFixed(1) + '°';
      pitchEl.textContent = p.toFixed(1) + '°';
      rollEl.textContent  = r.toFixed(1) + '°';
      cube.style.transform = `rotateY(${y}deg) rotateX(${-p}deg) rotateZ(${-r}deg)`;
      connEl.className = 'conn ok'; connEl.textContent = 'AirPods активны ✔';
      checkPosture(Date.now());
      checkTrack();
      checkPitchVol();
      checkYawVol();
    } else {
      connEl.className = 'conn warn';
      connEl.textContent = gotData ? 'AirPods потеряны…' : 'Жду AirPods — надень наушники';
    }
  } catch(e) {
    connEl.className = 'conn err';
    connEl.textContent = 'Нет связи: ' + e.message;
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
poll();
</script>
</body>
</html>
"""
