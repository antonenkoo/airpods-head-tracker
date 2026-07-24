// AirPods Head Tracker — landing v2
// Глобали из classic-скриптов: gsap, ScrollTrigger, Lenis, tsParticles
import * as THREE from 'three';

const $  = s => document.querySelector(s);
const $$ = s => [...document.querySelectorAll(s)];
const fine = matchMedia('(pointer:fine)').matches;
const noMotion = matchMedia('(prefers-reduced-motion: reduce)').matches;
if (noMotion) document.documentElement.classList.add('no-motion');

/* ═══ i18n ═══════════════════════════════════════════════════════════ */
const L = {
  en: {
    ghBtn:'GitHub ↗',
    chip:'v1.5 · free & open source · sensor link ready',
    h1a:'Your head', h1b:'is the interface',
    sub:'The AirPods in your ears already track every move of your head — Apple just never let that data out. This app does: live 3D tracking, a posture guardian and gesture music control, running natively on your Mac.',
    dl:'⬇ Download for Mac', dlNote:'macOS 14+ · 1.8 MB · no accounts, no cloud',
    faceFront:'FACE ☺',
    mq:['real head tracking','posture guardian','gesture control','100% offline','open source','60 fps'],
    tagFeat:'01 — capabilities', featH:'A sensor you already own',
    featLead:'Spatial-audio motion sensors sit idle in your AirPods every day. We turned them into an interface.',
    f1h:'Live 3D tracking', f1p:'Yaw, pitch and roll stream from your ears at 60 fps and drive a cube that mirrors your head in real time.',
    f2h:'Posture guardian', f2p:'Slouching towards the screen? The app notices the drift and reminds you with a sound before your neck does.',
    f3h:'Gesture music', f3p:'Tilt your head — the track switches in Spotify or Apple Music. Hands never leave the keyboard.',
    f4h:'Adaptive volume', f4p:'Turn away from the screen and the volume ducks; look back and it fades in. Fully configurable.',
    tagDemo:'02 — live demo', demoH:'Now you try — grab the cube',
    demoNote:'here your mouse does the job — in the app the cube follows <b>your head</b> at 60 fps',
    tagApp:'03 — inside the app', appH:'One window. Everything live.',
    appLead:'No dashboards, no setup wizards. You open it — it tracks. Every control you see reacts in real time.',
    co1:'the cube mirrors your head', co2:'posture map with motion trail', co3:'gestures & volume — all configurable',
    tagStory:'04 — origin story', storyH:'Born at 3 a.m. in Tokyo',
    s1m:'Tokyo · winter · deadline',
    s1:'A rented desk in Nakameguro. Our developer was shipping a 3 a.m. build, folded over the laptop like a question mark, when a thought arrived through the AirPods: <b>these things track my head for spatial audio — and nobody ever uses that data.</b>',
    s2m:'11 countries · 18 months',
    s2:'The first prototype was written before sunrise. Then it travelled: debugged on night trains to Kyoto, calibrated in Lisbon cafés, stress-tested on a ferry crossing the Bosphorus. One obsession the whole way: <b>your posture deserves a guardian that lives in your ears.</b>',
    s3m:'Seoul · the sound & the color',
    s3:'In a Seoul PC-bang the posture guardian found its voice — a synth chirp borrowed from an arcade cabinet two seats away. And the green? That is the exact shade of a pharmacy cross reflected in the wet asphalt of Shibuya crossing at midnight. <b>Some colors you don’t pick. They pick you.</b>',
    s4m:'Home · release day',
    s4:'Eighteen months later the app came home weighing 1.8 megabytes. No investors, no analytics, no launch party. Just one metric that mattered: <b>the developer’s neck stopped hurting. Yours can too.</b>',
    q:'No servers. No subscriptions. Just physics, math and a small <em>green cube</em>.',
    tagWhy:'05 — philosophy', whyH:'Why it matters',
    neonSub:'posture is the shape of the mind',
    why1:'You will spend roughly 80,000 hours of your life in front of a screen. The way you sit through them quietly becomes the way you feel — focus, energy, even mood follow the spine.',
    why2:'We can’t make you sit straight. But we can make <b>your own ears watch over you</b> — gently, offline, with a small green cube that never judges. It only reminds.',
    tagTech:'06 — under the hood', techH:'Ahead of its time — on purpose',
    st1:'render & sensor stream', st2:'offline — nothing leaves your Mac', st3:'accounts, clouds, trackers', st4:'the whole app',
    tagCalc:'07 — reality check', calcH:'How long will you actually sit?',
    calcLead:'Move the slider to your average screen time. The math is honest — that’s the point.',
    calcLbl:'hours at a screen per day',
    calcY:'years of your remaining life — seated at a screen',
    calcD:'full 24-hour days every single year',
    calcNote:'You can’t skip those hours. But you can sit through them well — the guardian is free.',
    tagFaq:'08 — faq', faqH:'Questions, answered like a changelog',
    a1:'AirPods Pro (1st & 2nd gen), AirPods Max and AirPods 3+ — anything with Spatial Audio head tracking. Regular AirPods 2 don’t carry the motion sensor.',
    a2:'The motion sensors already run for Spatial Audio whenever your AirPods are on. Reading their stream adds nothing measurable — neither to the AirPods nor to your Mac.',
    a3:'Everything runs on localhost. No accounts, no analytics, no network calls. The only thing that ever leaves your Mac is sound from your speakers.',
    a4:'Because posture shouldn’t be a subscription. The code is open under MIT — read it, fork it, break it, fix it.',
    a5:'macOS 14 Sonoma or newer, Apple Silicon or Intel. AirPods must be connected as the audio output of the Mac.',
    guardMsg:'You’ve been here a while — straighten up ◯',
    baseTitle:'AirPods Head Tracker — your head is the interface',
    awayTitle:'⚠ sit up straight →',
    tagInstall:'09 — install', installH:'Running in a minute',
    i1:'Download the DMG and drag <b>AirPodsTracker</b> into <b>Applications</b>.',
    i2:'First launch: <b>right-click → Open → Open</b>. On macOS 15 also allow it in System Settings → Privacy & Security.',
    i3:'Allow <b>Motion & Fitness</b> access — that is the head-tracking sensor permission.',
    i4:'Put your AirPods on, look straight and press <b>Calibrate</b>. Done.',
    noteB:'Why the warning on first launch?', noteT:'The app is open source and signed without a paid Apple Developer ID, so Gatekeeper shows a one-time warning. If right-click → Open doesn’t help, run:',
    r1:'macOS 14 Sonoma+', r2:'AirPods Pro / Max / 3+', r3:'AirPods as audio output', r4:'Apple Silicon & Intel',
    colTitle:'theme --neon-color', colLbl:'pick your neon', colHint:'you typed «col» — that’s how you got here',
    colHintTouch:'you tapped the neon sign — that’s how you got here',
    footMade:'Built with CMHeadphoneMotionManager · MIT license',
  },
  ru: {
    ghBtn:'GitHub ↗',
    chip:'v1.5 · бесплатно и открыто · датчики на связи',
    h1a:'Голова —', h1b:'это интерфейс',
    sub:'AirPods в твоих ушах уже отслеживают каждое движение головы — Apple просто не выпускала эти данные наружу. Это приложение выпускает: живой 3D-трекинг, страж осанки и управление музыкой жестами, нативно на твоём Mac.',
    dl:'⬇ Скачать для Mac', dlNote:'macOS 14+ · 1.8 МБ · без аккаунтов и облаков',
    faceFront:'ЛИЦО ☺',
    mq:['настоящий head-tracking','страж осанки','управление жестами','100% офлайн','открытый код','60 fps'],
    tagFeat:'01 — возможности', featH:'Датчик, который у тебя уже есть',
    featLead:'Сенсоры пространственного аудио простаивают в AirPods каждый день. Мы превратили их в интерфейс.',
    f1h:'Живой 3D-трекинг', f1p:'Yaw, pitch и roll идут из твоих ушей на 60 fps и вращают куб, который зеркалит голову в реальном времени.',
    f2h:'Страж осанки', f2p:'Сутулишься к экрану? Приложение замечает наклон и напоминает звуком раньше, чем шея.',
    f3h:'Музыка жестами', f3p:'Наклони голову — трек переключится в Spotify или Apple Music. Руки не покидают клавиатуру.',
    f4h:'Адаптивная громкость', f4p:'Отвернулся от экрана — громкость приглушается; вернулся — плавно возвращается. Всё настраивается.',
    tagDemo:'02 — живое демо', demoH:'Теперь сам — схвати куб',
    demoNote:'здесь работает мышка — в приложении куб повторяет <b>твою голову</b> на 60 fps',
    tagApp:'03 — внутри приложения', appH:'Одно окно. Всё живое.',
    appLead:'Никаких дашбордов и мастеров настройки. Открыл — оно трекает. Каждый элемент реагирует в реальном времени.',
    co1:'куб зеркалит твою голову', co2:'карта осанки со шлейфом', co3:'жесты и громкость — всё настраивается',
    tagStory:'04 — история', storyH:'Родился в 3 часа ночи в Токио',
    s1m:'Токио · зима · дедлайн',
    s1:'Съёмный стол в Накамегуро. Наш разработчик выкатывал ночной билд, согнувшись над ноутбуком знаком вопроса, когда сквозь AirPods пришла мысль: <b>эти штуки отслеживают мою голову ради spatial audio — и никто не использует эти данные.</b>',
    s2m:'11 стран · 18 месяцев',
    s2:'Первый прототип был написан до рассвета. Потом он поехал по миру: отладка в ночных поездах до Киото, калибровка в кофейнях Лиссабона, стресс-тест на пароме через Босфор. Всю дорогу одна одержимость: <b>у твоей осанки должен быть страж, живущий в ушах.</b>',
    s3m:'Сеул · звук и цвет',
    s3:'В сеульском PC-бане страж осанки обрёл голос — синтезаторный чирп, подслушанный у аркадного автомата через два места. А зелёный? Это точный оттенок аптечного креста, отражённого в мокром асфальте перекрёстка Сибуя в полночь. <b>Некоторые цвета не выбирают. Они выбирают тебя.</b>',
    s4m:'Дом · день релиза',
    s4:'Через восемнадцать месяцев приложение вернулось домой, весом 1.8 мегабайта. Без инвесторов, без аналитики, без запусковой вечеринки. Только одна метрика имела значение: <b>шея разработчика перестала болеть. Твоя тоже может.</b>',
    q:'Без серверов. Без подписок. Только физика, математика и маленький <em>зелёный куб</em>.',
    tagWhy:'05 — философия', whyH:'Почему это важно',
    neonSub:'осанка — форма души',
    why1:'Ты проведёшь около 80 000 часов жизни перед экраном. То, как ты сидишь эти часы, незаметно становится тем, как ты себя чувствуешь — фокус, энергия и даже настроение следуют за позвоночником.',
    why2:'Мы не можем заставить тебя сидеть прямо. Но можем сделать так, чтобы <b>твои собственные уши присматривали за тобой</b> — мягко, офлайн, с маленьким зелёным кубом, который не осуждает. Только напоминает.',
    tagTech:'06 — под капотом', techH:'Опережая время — намеренно',
    st1:'рендер и поток датчиков', st2:'офлайн — ничего не покидает Mac', st3:'аккаунтов, облаков, трекеров', st4:'всё приложение целиком',
    tagCalc:'07 — проверка реальностью', calcH:'Сколько ты на самом деле просидишь?',
    calcLead:'Подвинь слайдер под свой экранный день. Математика честная — в этом и смысл.',
    calcLbl:'часов за экраном в день',
    calcY:'лет оставшейся жизни — сидя у экрана',
    calcD:'полных суток каждый год',
    calcNote:'Эти часы не пропустить. Но их можно просидеть правильно — страж бесплатный.',
    tagFaq:'08 — faq', faqH:'Вопросы — ответами, как ченджлог',
    a1:'AirPods Pro (1-го и 2-го поколения), AirPods Max и AirPods 3+ — всё, где есть head-tracking для Spatial Audio. В обычных AirPods 2 датчика движения нет.',
    a2:'Датчики движения и так работают ради Spatial Audio, пока AirPods в ушах. Чтение их потока не добавляет ничего измеримого — ни наушникам, ни Mac.',
    a3:'Всё крутится на localhost. Ни аккаунтов, ни аналитики, ни сетевых запросов. Единственное, что покидает твой Mac — звук из динамиков.',
    a4:'Потому что осанка не должна быть подпиской. Код открыт под MIT — читай, форкай, ломай, чини.',
    a5:'macOS 14 Sonoma или новее, Apple Silicon или Intel. AirPods должны быть подключены как аудиовыход Mac.',
    guardMsg:'Ты здесь уже давно — выпрямись ◯',
    baseTitle:'AirPods Head Tracker — голова это интерфейс',
    awayTitle:'⚠ сядь прямо →',
    tagInstall:'09 — установка', installH:'Запуск за минуту',
    i1:'Скачай DMG и перетащи <b>AirPodsTracker</b> в <b>Applications</b>.',
    i2:'Первый запуск: <b>правый клик → Open → Open</b>. На macOS 15 дополнительно разреши в System Settings → Privacy & Security.',
    i3:'Разреши доступ к <b>«Движение и фитнес»</b> — это разрешение на датчики head-tracking.',
    i4:'Надень AirPods, посмотри прямо и нажми <b>«Калибровать»</b>. Готово.',
    noteB:'Почему предупреждение при первом запуске?', noteT:'Приложение с открытым кодом и подписано без платного Apple Developer ID, поэтому Gatekeeper один раз покажет предупреждение. Если правый клик → Open не помог, выполни:',
    r1:'macOS 14 Sonoma+', r2:'AirPods Pro / Max / 3+', r3:'AirPods как аудиовыход', r4:'Apple Silicon и Intel',
    colTitle:'theme --neon-color', colLbl:'выбери свой неон', colHint:'ты набрал «col» — так сюда и попадают',
    colHintTouch:'ты тапнул по вывеске — так сюда и попадают',
    footMade:'Работает на CMHeadphoneMotionManager · Лицензия MIT',
  },
};
let lang = localStorage.getItem('lang') ||
  (navigator.language.startsWith('ru') ? 'ru' : 'en');
const t = k => L[lang][k] ?? k;

function setLang(l) {
  lang = l; localStorage.setItem('lang', l);
  document.documentElement.lang = l;
  $$('[data-i18n]').forEach(el => {
    const s = L[lang][el.dataset.i18n];
    if (s !== undefined) el.innerHTML = s;
  });
  // бегущие строки собираются из массива
  const mq = t('mq').map(w => `<span>${w} <b>///</b></span>`).join('');
  $$('.marquee-track').forEach(el => el.innerHTML = mq + mq);
  drawFace?.(t('faceFront'));
  $('#langEn').classList.toggle('on', l === 'en');
  $('#langRu').classList.toggle('on', l === 'ru');
}
$('#langEn').addEventListener('click', () => setLang('en'));
$('#langRu').addEventListener('click', () => setLang('ru'));

/* ═══ Прелоадер ══════════════════════════════════════════════════════ */
(function preloader() {
  const num = $('#preloader .pl-num'), bar = $('#preloader .pl-bar i');
  let p = 0;
  const iv = setInterval(() => {
    p = Math.min(100, p + Math.random() * 13 + 3);
    num.textContent = Math.floor(p).toString().padStart(3, '0');
    bar.style.width = p + '%';
    if (p >= 100) {
      clearInterval(iv);
      setTimeout(() => {
        $('#preloader').classList.add('done');
        startHeroIntro();
      }, 250);
    }
  }, noMotion ? 30 : 110);
})();

/* ═══ Lenis + GSAP ═══════════════════════════════════════════════════ */
gsap.registerPlugin(ScrollTrigger);
let lenis = null;
if (!noMotion) {
  lenis = new Lenis({ lerp: 0.09, smoothWheel: true });
  lenis.on('scroll', ScrollTrigger.update);
  gsap.ticker.add(time => lenis.raf(time * 1000));
  gsap.ticker.lagSmoothing(0);
}

/* прогресс-бар + автоскрытие навбара */
let lastY = 0;
const nav = $('nav');
function onScrollY(y) {
  const h = document.documentElement.scrollHeight - innerHeight;
  $('#progress').style.transform = `scaleX(${h ? y / h : 0})`;
  nav.classList.toggle('hide', y > 140 && y > lastY);
  lastY = y;
}
if (lenis) lenis.on('scroll', e => onScrollY(e.scroll));
else addEventListener('scroll', () => onScrollY(scrollY), { passive: true });

/* ═══ Кастомный курсор ═══════════════════════════════════════════════ */
if (fine && !noMotion) {
  document.body.classList.add('cursor-on');
  const dot = $('.cursor-dot'), cc = $('.cursor-cube');
  let mx = innerWidth / 2, my = innerHeight / 2, rx = mx, ry = my;
  addEventListener('mousemove', e => { mx = e.clientX; my = e.clientY; });
  gsap.ticker.add(() => {
    rx += (mx - rx) * 0.16; ry += (my - ry) * 0.16;
    dot.style.left = mx + 'px'; dot.style.top = my + 'px';
    cc.style.left  = rx + 'px'; cc.style.top  = ry + 'px';
  });
  document.addEventListener('mouseover', e => {
    cc.classList.toggle('hover', !!e.target.closest('a,button,.card,.lang,#demoCube'));
  });
}

/* ═══ Частицы (multiplex-эффект) ═════════════════════════════════════ */
let particlesContainer = null;
function particleOptions(accent, second) {
  return {
    fullScreen: { enable: false },
    fpsLimit: 60,
    detectRetina: true,
    background: { color: 'transparent' },
    particles: {
      number: { value: 70, density: { enable: true, width: 1400 } },
      color: { value: [accent, second] },
      opacity: { value: { min: 0.15, max: 0.5 } },
      size: { value: { min: 1, max: 2.4 } },
      links: { enable: true, distance: 150, color: accent, opacity: 0.16, width: 1 },
      move: { enable: true, speed: 0.7, outModes: 'bounce' },
    },
    interactivity: {
      events: { onHover: { enable: true, mode: 'grab' } },
      modes: { grab: { distance: 190, links: { opacity: 0.45 } } },
    },
  };
}
async function loadParticles(accent, second) {
  if (noMotion) return;
  if (particlesContainer) { particlesContainer.destroy(); particlesContainer = null; }
  particlesContainer = await tsParticles.load({
    id: 'particles', options: particleOptions(accent, second),
  });
}
loadParticles('#00ffaa', '#33b5e5');

/* ═══ WebGL-кубы (модель из приложения, пресет v1.5.1) ══════════════ */
const ACCENT = 0x00ffaa, SIZE = 1.6;
let drawFace = null;
let themeAccentHex = 0x00ffaa;           // для three.js-материалов
let themeAccentCss = '#00ffaa';          // для canvas-текстур
const themeMats = [];                    // материалы, перекрашиваемые темой

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

function makeCubeScene(canvas, { withLabel = false } = {}) {
  const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
  renderer.setPixelRatio(Math.min(2, devicePixelRatio));
  renderer.setClearColor(0x000000, 0);
  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(38, 1, 0.1, 20);
  camera.position.set(0, 0, 4.5);
  camera.lookAt(0, 0, 0);
  scene.add(new THREE.AmbientLight(0xffffff, 0.5));
  const key = new THREE.DirectionalLight(0xffffff, 1.5);
  key.position.set(2.5, 3, 2); scene.add(key);
  const rim = new THREE.DirectionalLight(0x66ffcc, 0.5);
  rim.position.set(-3, -1, -2); scene.add(rim);

  const group = new THREE.Group();
  const core = new THREE.MeshPhysicalMaterial({ color: themeAccentHex, roughness: 0.32, metalness: 0 });
  group.add(roundedFrame(0.01, 0.03, core));
  const glassMat = new THREE.MeshPhysicalMaterial({
    color: themeAccentHex, transparent: true, opacity: 0.09,
    roughness: 0.2, side: THREE.DoubleSide, depthWrite: false,
  });
  const glass = new THREE.Mesh(new THREE.BoxGeometry(SIZE, SIZE, SIZE), glassMat);
  glass.renderOrder = 1;
  group.add(glass);
  themeMats.push(core, glassMat);

  if (withLabel) {
    const lc = document.createElement('canvas'); lc.width = lc.height = 256;
    const lctx = lc.getContext('2d');
    const tex = new THREE.CanvasTexture(lc);
    let lastFaceText = t('faceFront');
    drawFace = text => {
      if (text) lastFaceText = text;
      lctx.clearRect(0, 0, 256, 256);
      lctx.font = 'bold 38px -apple-system, Arial';
      lctx.textAlign = 'center'; lctx.textBaseline = 'middle';
      lctx.fillStyle = themeAccentCss;
      lctx.fillText(lastFaceText, 128, 128);
      tex.needsUpdate = true;
    };
    const label = new THREE.Mesh(
      new THREE.PlaneGeometry(SIZE * 0.92, SIZE * 0.92),
      new THREE.MeshBasicMaterial({ map: tex, transparent: true }));
    label.position.z = SIZE / 2 + 0.003;
    label.renderOrder = 2;
    group.add(label);
    drawFace(t('faceFront'));
  }
  scene.add(group);

  const resize = () => {
    const w = canvas.clientWidth, h = canvas.clientHeight;
    if (w && h) { renderer.setSize(w, h, false); camera.aspect = w / h; camera.updateProjectionMatrix(); }
  };
  new ResizeObserver(resize).observe(canvas);
  resize();
  return { renderer, scene, camera, group };
}

/* hero-куб: медленное вращение + параллакс за мышью */
const hero3d = makeCubeScene($('#cube3d'), { withLabel: true });
let heroMX = 0, heroMY = 0;
if (fine) addEventListener('mousemove', e => {
  heroMX = (e.clientX / innerWidth - 0.5) * 2;
  heroMY = (e.clientY / innerHeight - 0.5) * 2;
});
const t0 = performance.now();
(function heroLoop() {
  const tt = (performance.now() - t0) / 1000;
  const g = hero3d.group;
  g.rotation.y = tt * 0.35 + heroMX * 0.45;
  g.rotation.x = Math.sin(tt * 0.5) * 0.22 + heroMY * 0.3;
  g.rotation.z = Math.sin(tt * 0.33) * 0.1;
  hero3d.renderer.render(hero3d.scene, hero3d.camera);
  requestAnimationFrame(heroLoop);
})();

/* демо-куб: пользователь вращает мышью (drag + инерция), в простое — лёгкое кружение */
const demoCanvas = $('#demoCube');
const demo3d = makeCubeScene(demoCanvas);
const dYaw = $('#dYaw'), dPitch = $('#dPitch'), dRoll = $('#dRoll');
{
  const g = demo3d.group;
  g.rotation.order = 'YXZ';
  let dragging = false, lastX = 0, lastY = 0;
  let vx = 0, vy = 0;                 // инерция после отпускания
  let idleSince = performance.now();  // когда пользователь оставил куб в покое

  demoCanvas.addEventListener('pointerdown', e => {
    dragging = true; lastX = e.clientX; lastY = e.clientY;
    vx = vy = 0;
    demoCanvas.classList.add('dragging');
    demoCanvas.setPointerCapture(e.pointerId);
  });
  demoCanvas.addEventListener('pointermove', e => {
    if (!dragging) return;
    const dx = e.clientX - lastX, dy = e.clientY - lastY;
    lastX = e.clientX; lastY = e.clientY;
    g.rotation.y += dx * 0.007;
    g.rotation.x += dy * 0.007;
    vx = dx * 0.007; vy = dy * 0.007;
    idleSince = performance.now();
  });
  const endDrag = () => {
    dragging = false;
    demoCanvas.classList.remove('dragging');
    idleSince = performance.now();
  };
  demoCanvas.addEventListener('pointerup', endDrag);
  demoCanvas.addEventListener('pointercancel', endDrag);

  (function demoLoop() {
    const idle = !dragging && performance.now() - idleSince > 2500;
    if (!dragging) {
      // инерция затухает…
      g.rotation.y += vx; g.rotation.x += vy;
      vx *= 0.95; vy *= 0.95;
      // …а после 2.5с покоя куб начинает лениво кружиться сам
      if (idle) {
        g.rotation.y += 0.004;
        g.rotation.x += Math.sin(performance.now() / 2400) * 0.0016;
      }
    }
    // roll: «банковка» — куб кренится в сторону вращения (как самолёт в вираже),
    // в простое легонько покачивается, чтобы значение жило
    const bankTarget = idle
      ? Math.sin(performance.now() / 2100) * 0.09
      : Math.max(-0.5, Math.min(0.5, -vx * 22));
    g.rotation.z += (bankTarget - g.rotation.z) * 0.06;
    const R = Math.PI / 180;
    const norm180 = v => { while (v > 180) v -= 360; while (v < -180) v += 360; return v; };
    if (dYaw) {
      dYaw.textContent   = norm180(-g.rotation.y / R).toFixed(1) + '°';
      dPitch.textContent = norm180(-g.rotation.x / R).toFixed(1) + '°';
      dRoll.textContent  = norm180( g.rotation.z / R).toFixed(1) + '°';
    }
    demo3d.renderer.render(demo3d.scene, demo3d.camera);
    requestAnimationFrame(demoLoop);
  })();
}

/* hero-HUD: живые псевдопоказания */
setInterval(() => {
  const r = () => (Math.random() * 4 - 2).toFixed(1);
  const el = $('#hudVals');
  if (el) el.innerHTML = `YAW <b>${r()}°</b>&nbsp; PITCH <b>${r()}°</b>&nbsp; ROLL <b>${r()}°</b>`;
}, 600);

/* ═══ Scramble-заголовки ═════════════════════════════════════════════ */
const CHARS = '!<>-_\\/[]{}—=+*^?#________';
function scramble(el, finalText, dur = 900) {
  if (noMotion) { el.textContent = finalText; return; }
  const len = finalText.length;
  const start = performance.now();
  (function frame(now) {
    const p = Math.min(1, (now - start) / dur);
    const solid = Math.floor(p * len);
    let out = finalText.slice(0, solid);
    for (let i = solid; i < len; i++)
      out += finalText[i] === ' ' ? ' ' : CHARS[(Math.random() * CHARS.length) | 0];
    el.textContent = out;
    if (p < 1) requestAnimationFrame(frame);
  })(start);
}
function startHeroIntro() {
  scramble($('#h1a'), t('h1a'), 700);
  setTimeout(() => scramble($('#h1b'), t('h1b'), 900), 250);
  gsap.fromTo('.hero-sub,.hero-cta,.hero-chip',
    { opacity: 0, y: 26 }, { opacity: 1, y: 0, duration: .9, stagger: .12, ease: 'power3.out', delay: .3 });
}

/* заголовки секций — scramble при появлении */
$$('h2[data-i18n]').forEach(h => {
  ScrollTrigger.create({
    trigger: h, start: 'top 88%', once: true,
    onEnter: () => scramble(h, t(h.dataset.i18n), 800),
  });
});

/* ═══ Магнитная кнопка ═══════════════════════════════════════════════ */
if (fine && !noMotion) {
  const btn = $('.btn-dl');
  const strength = 26;
  btn.parentElement.addEventListener('mousemove', e => {
    const b = btn.getBoundingClientRect();
    const dx = e.clientX - (b.left + b.width / 2);
    const dy = e.clientY - (b.top + b.height / 2);
    gsap.to(btn, { x: dx / b.width * strength, y: dy / b.height * strength, duration: .4 });
  });
  btn.parentElement.addEventListener('mouseleave', () =>
    gsap.to(btn, { x: 0, y: 0, duration: .5, ease: 'elastic.out(1,.5)' }));
}

/* ═══ Tilt-карточки ══════════════════════════════════════════════════ */
if (fine && !noMotion) $$('.card').forEach(card => {
  card.addEventListener('mousemove', e => {
    const b = card.getBoundingClientRect();
    const px = (e.clientX - b.left) / b.width, py = (e.clientY - b.top) / b.height;
    card.style.setProperty('--mx', px * 100 + '%');
    card.style.setProperty('--my', py * 100 + '%');
    gsap.to(card, { rotateY: (px - .5) * 10, rotateX: (0.5 - py) * 10,
      transformPerspective: 700, duration: .35 });
  });
  card.addEventListener('mouseleave', () =>
    gsap.to(card, { rotateX: 0, rotateY: 0, duration: .6, ease: 'power3.out' }));
});

/* ═══ Reveal-анимации ════════════════════════════════════════════════ */
if (!noMotion) $$('[data-reveal]').forEach(el => {
  gsap.fromTo(el, { opacity: 0, y: 46 }, {
    opacity: 1, y: 0, duration: .95, ease: 'power3.out',
    scrollTrigger: { trigger: el, start: 'top 87%', once: true },
    delay: (Number(el.dataset.reveal) || 0) * 0.1,
  });
});

/* параллакс декоративных глифов */
if (!noMotion) $$('[data-speed]').forEach(el => {
  gsap.to(el, { yPercent: Number(el.dataset.speed) * 30, ease: 'none',
    scrollTrigger: { trigger: el.closest('section'), start: 'top bottom', end: 'bottom top', scrub: true } });
});

/* ═══ Счётчики ═══════════════════════════════════════════════════════ */
$$('.stat .n b').forEach(n => {
  const target = parseFloat(n.dataset.to);
  ScrollTrigger.create({
    trigger: n, start: 'top 88%', once: true,
    onEnter: () => {
      const o = { v: 0 };
      gsap.to(o, { v: target, duration: 1.6, ease: 'power2.out',
        onUpdate: () => n.textContent = (target % 1 ? o.v.toFixed(1) : Math.round(o.v)) });
    },
  });
});

/* ═══ Терминал с печатью ═════════════════════════════════════════════ */
const TERM_LINES = [
  ['$ airpods-tracker --start', ''],
  ['> CMHeadphoneMotionManager ....... ', 'LINKED'],
  ['> sensor stream @ 60 Hz .......... ', 'OK'],
  ['> localhost:8765 ................. ', 'SERVING'],
  ['> WebGL cube ..................... ', 'RENDERING'],
  ['> posture guardian ............... ', 'WATCHING'],
  ['> cloud connection ............... ', 'NOT NEEDED'],
];
ScrollTrigger.create({
  trigger: '.terminal', start: 'top 80%', once: true,
  onEnter: () => {
    const body = $('.term-body');
    body.innerHTML = '';
    let li = 0;
    (function typeLine() {
      if (li >= TERM_LINES.length) {
        body.insertAdjacentHTML('beforeend', '<span class="ln dim">_ ready. put your airpods on.<i class="term-caret"></i></span>');
        return;
      }
      const [text, status] = TERM_LINES[li++];
      const ln = document.createElement('span');
      ln.className = 'ln';
      body.appendChild(ln);
      let ci = 0;
      const iv = setInterval(() => {
        ln.textContent = text.slice(0, ++ci);
        if (ci >= text.length) {
          clearInterval(iv);
          if (status) ln.insertAdjacentHTML('beforeend', `<i class="ok">${status}</i>`);
          setTimeout(typeLine, 140);
        }
      }, noMotion ? 1 : 14);
    })();
  },
});

/* ═══ Неоновые темы (модалка по комбинации «col») ═══════════════════ */
const THEMES = {
  green:  { label: 'Shibuya Green', hex: 0x00ffaa, css: '#00ffaa', second: '#33b5e5' },
  rain:   { label: 'Tokyo Rain',    hex: 0xff5ad1, css: '#ff5ad1', second: '#8f6bff' },
  cyan:   { label: 'Hong Kong Ice', hex: 0x00e5ff, css: '#00e5ff', second: '#4d8dff' },
  violet: { label: 'Ultraviolet',   hex: 0xb44dff, css: '#b44dff', second: '#ff5ad1' },
  amber:  { label: 'Osaka Amber',   hex: 0xffb300, css: '#ffb300', second: '#ff6a3d' },
  red:    { label: 'Kabukicho Red', hex: 0xff3d5a, css: '#ff3d5a', second: '#ff8a00' },
};
const colModal = $('#colModal'), colSelect = $('#colSelect'), colSwatches = $('#colSwatches');
Object.entries(THEMES).forEach(([name, th]) => {
  const opt = document.createElement('option');
  opt.value = name; opt.textContent = th.label;
  colSelect.appendChild(opt);
  const sw = document.createElement('button');
  sw.dataset.theme = name; sw.title = th.label;
  sw.style.setProperty('--c', th.css);
  sw.addEventListener('click', () => applyTheme(name));
  colSwatches.appendChild(sw);
});
function applyTheme(name) {
  if (!THEMES[name]) name = 'green';
  const th = THEMES[name];
  Object.keys(THEMES).forEach(k =>
    document.body.classList.toggle('theme-' + k, k === name && k !== 'green'));
  themeAccentHex = th.hex; themeAccentCss = th.css;
  themeMats.forEach(m => m.color.set(th.hex));
  if (drawFace) drawFace();               // перерисовать FACE в новом цвете
  loadParticles(th.css, th.second);
  localStorage.setItem('theme', name);
  colSelect.value = name;
  $$('#colSwatches button').forEach(b => b.classList.toggle('on', b.dataset.theme === name));
  $('#themeBtn').classList.toggle('on', name !== 'green');
}
colSelect.addEventListener('change', () => applyTheme(colSelect.value));
const openColorModal  = () => { colModal.classList.add('show'); colSelect.focus(); };
const closeColorModal = () => colModal.classList.remove('show');
$('#colClose').addEventListener('click', closeColorModal);
colModal.addEventListener('click', e => { if (e.target === colModal) closeColorModal(); });
addEventListener('keydown', e => { if (e.key === 'Escape') closeColorModal(); });
$('#themeBtn').addEventListener('click', openColorModal);
/* на телефоне клавиатуры нет — модалку открывает тап по неоновой вывеске */
if (!fine) {
  $('.neon-jp').addEventListener('click', openColorModal);
  $('.col-hint').dataset.i18n = 'colHintTouch';   // setLang подставит текст про тап
}
/* комбинация «col» открывает модалку — как «sit», только про цвет */
{
  let buf = '';
  addEventListener('keydown', e => {
    if (e.metaKey || e.ctrlKey || e.altKey) return;
    buf = (buf + e.key.toLowerCase()).slice(-3);
    if (buf !== 'col') return;
    buf = '';
    openColorModal();
  });
}
/* восстановить сохранённую тему (green уже применён по умолчанию) */
{
  const saved = localStorage.getItem('theme');
  if (saved && saved !== 'green' && THEMES[saved]) applyTheme(saved);
  else { colSelect.value = 'green'; $('#colSwatches button')?.classList.add('on'); }
}

/* ═══ Витрина приложения: tilt + вынос-подписи ═══════════════════════ */
const shot = $('#shotFrame');
if (shot && fine && !noMotion) {
  shot.addEventListener('mousemove', e => {
    const b = shot.getBoundingClientRect();
    const px = (e.clientX - b.left) / b.width, py = (e.clientY - b.top) / b.height;
    gsap.to(shot, { rotateY: (px - .5) * 7, rotateX: (0.5 - py) * 7,
      transformPerspective: 1200, duration: .4 });
  });
  shot.addEventListener('mouseleave', () =>
    gsap.to(shot, { rotateX: 0, rotateY: 0, duration: .7, ease: 'power3.out' }));
}
if (!noMotion) gsap.fromTo('.callout', { opacity: 0, scale: .7 }, {
  opacity: 1, scale: 1, duration: .55, stagger: .18, ease: 'back.out(1.8)',
  scrollTrigger: { trigger: '#shotFrame', start: 'top 70%', once: true },
});

/* ═══ Карта маршрута: рисуется по мере скролла ═══════════════════════ */
const route = $('.route');
if (route && !noMotion) {
  gsap.set(route.querySelector('svg'), { clipPath: 'inset(0 100% 0 0)' });
  gsap.set('.route-pt', { opacity: 0 });
  ScrollTrigger.create({
    trigger: route, start: 'top 90%', end: 'top 35%', scrub: true,
    onUpdate: self => {
      gsap.set(route.querySelector('svg'),
        { clipPath: `inset(0 ${100 - self.progress * 100}% 0 0)` });
      $$('.route-pt').forEach(pt => {
        const d = Number(pt.style.getPropertyValue('--d'));
        gsap.set(pt, { opacity: self.progress > (d + 0.5) / 5.5 ? 1 : 0 });
      });
    },
  });
}

/* ═══ Калькулятор экранных часов ═════════════════════════════════════ */
const calcRange = $('#calcRange');
if (calcRange) {
  const yEl = $('#calcYears'), dEl = $('#calcDays'), hEl = $('#calcHVal');
  const state = { y: 0, d: 0 };
  const update = () => {
    const h = Number(calcRange.value);
    hEl.textContent = h;
    // ~45 оставшихся активных лет жизни
    gsap.to(state, {
      y: 45 * h / 24, d: h * 365 / 24, duration: .6, ease: 'power2.out',
      onUpdate: () => {
        yEl.textContent = state.y.toFixed(1);
        dEl.textContent = Math.round(state.d);
      },
    });
  };
  calcRange.addEventListener('input', update);
  ScrollTrigger.create({ trigger: '#calc', start: 'top 75%', once: true, onEnter: update });
}

/* ═══ FAQ-аккордеон ══════════════════════════════════════════════════ */
$$('.faq-item').forEach(item => {
  item.querySelector('.faq-q').addEventListener('click', () => {
    const wasOpen = item.classList.contains('open');
    $$('.faq-item.open').forEach(o => o.classList.remove('open'));
    if (!wasOpen) item.classList.add('open');
  });
});

/* ═══ Мета-страж осанки ══════════════════════════════════════════════ */
const guard = $('#guardToast');
if (guard) {
  const showGuard = () => {
    if (document.hidden) return;
    guard.classList.add('show');
    setTimeout(() => guard.classList.remove('show'), 9000);
  };
  guard.addEventListener('click', () => guard.classList.remove('show'));
  setTimeout(showGuard, 120000);                       // первый раз — через 2 минуты
  setInterval(showGuard, 240000);                      // потом каждые 4
}

/* ═══ Пасхалка: набери «sit» ═════════════════════════════════════════ */
{
  const flash = document.createElement('div');
  flash.className = 'sit-flash';
  document.body.appendChild(flash);
  let buf = '';
  addEventListener('keydown', e => {
    if (e.metaKey || e.ctrlKey || e.altKey) return;
    buf = (buf + e.key.toLowerCase()).slice(-3);
    if (buf !== 'sit') return;
    buf = '';
    flash.classList.remove('go'); void flash.offsetWidth; flash.classList.add('go');
    // вывеска на 4 секунды меняет текст
    const jp = $('.neon-jp');
    if (jp) {
      const orig = jp.textContent;
      jp.textContent = 'まっすぐ座れ!';
      setTimeout(() => { jp.textContent = orig; }, 4000);
    }
    // конфетти из мини-кубов
    for (let i = 0; i < 22; i++) {
      const c = document.createElement('div');
      c.className = 'sit-cube';
      c.style.left = Math.random() * 100 + 'vw';
      c.style.top = '-30px';
      document.body.appendChild(c);
      gsap.to(c, {
        y: innerHeight + 80, rotation: (Math.random() - .5) * 720,
        x: (Math.random() - .5) * 200,
        duration: 1.4 + Math.random() * 1.4, ease: 'power1.in',
        onComplete: () => c.remove(),
      });
    }
  });
}

/* ═══ Динамический title вкладки ═════════════════════════════════════ */
document.addEventListener('visibilitychange', () => {
  document.title = document.hidden ? t('awayTitle') : t('baseTitle');
});

/* ═══ ASCII-куб в tech-секции ════════════════════════════════════════ */
const asciiEl = $('#ascii');
if (asciiEl) {
  const W = 40, H = 21, SC = 8.5;
  const V = [-1, 1].flatMap(x => [-1, 1].flatMap(y => [-1, 1].map(z => [x, y, z])));
  const E = [[0,1],[0,2],[0,4],[1,3],[1,5],[2,3],[2,6],[3,7],[4,5],[4,6],[5,7],[6,7]];
  let visible = false, angle = 0;
  new IntersectionObserver(en => { visible = en[0].isIntersecting; },
    { threshold: 0.1 }).observe(asciiEl);
  setInterval(() => {
    if (!visible) return;
    angle += 0.06;
    const ca = Math.cos(angle), sa = Math.sin(angle);
    const cb = Math.cos(angle * 0.6), sb = Math.sin(angle * 0.6);
    const pts = V.map(([x, y, z]) => {
      let X = x * ca + z * sa, Z = -x * sa + z * ca;          // вокруг Y
      let Y = y * cb - Z * sb; Z = y * sb + Z * cb;            // вокруг X
      return [Math.round(W / 2 + X * SC * 1.9), Math.round(H / 2 - Y * SC * 0.95)];
    });
    const grid = Array.from({ length: H }, () => Array(W).fill(' '));
    const put = (x, y, ch) => { if (x >= 0 && x < W && y >= 0 && y < H) grid[y][x] = ch; };
    for (const [a, b] of E) {
      const [x0, y0] = pts[a], [x1, y1] = pts[b];
      const steps = Math.max(Math.abs(x1 - x0), Math.abs(y1 - y0), 1);
      const dx = Math.abs(x1 - x0), dy = Math.abs(y1 - y0);
      const ch = dx > dy * 2 ? '─' : dy > dx * 2 ? '│' : ((x1 - x0) * (y1 - y0) > 0 ? '╲' : '╱');
      for (let s = 0; s <= steps; s++)
        put(Math.round(x0 + (x1 - x0) * s / steps), Math.round(y0 + (y1 - y0) * s / steps), ch);
    }
    pts.forEach(([x, y]) => put(x, y, '●'));
    asciiEl.textContent = grid.map(r => r.join('')).join('\n');
  }, 90);
}


/* ═══ Токийский дождь ════════════════════════════════════════════════ */
/* канвас-оверлей на весь экран: отвесные капли в цвет активной неоновой
   темы, три слоя глубины, вид сбоку. Наведи курсор на карточку или
   кнопку: вокруг неё загорится тонкая рамка, и капли начнут отбиваться
   от её верхней грани брызгами, как в 2D-платформере. Нижняя кромка
   экрана работает как пол. Набери «rain» — морось станет ливнем */
if (!noMotion) {
  const cv = $('#rain'), ctx = cv.getContext('2d');
  const DPR = Math.min(2, devicePixelRatio);
  let W = 0, H = 0;
  const resizeRain = () => {
    W = cv.width  = Math.ceil(innerWidth  * DPR);
    H = cv.height = Math.ceil(innerHeight * DPR);
  };
  resizeRain();
  addEventListener('resize', resizeRain);

  // дальний слой: тонкий и медленный; ближний: жирный и быстрый
  const LAYERS = [
    { n: 0.024, speed: 11, len: 14, w: 1.0, a: 0.22 },
    { n: 0.018, speed: 17, len: 24, w: 1.4, a: 0.40 },
    { n: 0.011, speed: 24, len: 36, w: 1.8, a: 0.62, splash: true },
  ];
  let storm = false;
  const drops = [], droplets = [];
  const spawn = (l, anywhere) => ({
    l,
    x: Math.random() * W,
    y: anywhere ? Math.random() * H : -(l.len + Math.random() * 40) * DPR,
    v: (l.speed + Math.random() * 6) * DPR,
  });
  const fill = () => {
    drops.length = 0; droplets.length = 0;
    const mul = storm ? 3.2 : 1;
    LAYERS.forEach(l => {
      const count = Math.round(innerWidth * l.n * mul);
      for (let i = 0; i < count; i++) drops.push(spawn(l, true));
    });
  };
  fill();
  addEventListener('resize', fill);

  /* блок под курсором становится препятствием: рамка на отступе PAD,
     капли бьются о её верхнюю грань */
  const PAD = 3;
  const HOVERABLE = '.card, .btn-dl, .hero-chip, .stat, .step, .faq-item, ' +
    '.note, .story-block, .terminal, .ascii-box, .calc-box, .shot-frame, .neon-sign';
  let hoverEl = null;
  if (fine) document.addEventListener('pointerover', e => {
    const el = e.target.closest(HOVERABLE);
    if (el === hoverEl) return;
    hoverEl?.classList.remove('rain-hover');
    hoverEl = el;
    hoverEl?.classList.add('rain-hover');
  });

  // удар: капля разлетается брызгами-бусинами, дугой вверх и обратно
  function impact(x, y, l) {
    const n = l.splash ? 4 : 2 + (Math.random() < 0.5 ? 1 : 0);
    for (let i = 0; i < n && droplets.length < 220; i++) {
      droplets.push({
        x, y,
        vx: (Math.random() - 0.5) * 3.6 * DPR,
        vy: -(1.8 + Math.random() * 2.6) * DPR,
        life: 1.1,
      });
    }
  }

  let prev = performance.now();
  (function rainLoop(now) {
    requestAnimationFrame(rainLoop);
    const dt = Math.min(3, (now - prev) / 16.7); prev = now;
    if (document.hidden) return;
    let ob = null;
    if (hoverEl) {
      const r = hoverEl.getBoundingClientRect();
      ob = { left: r.left - PAD, right: r.right + PAD, top: r.top - PAD };
    }
    ctx.clearRect(0, 0, W, H);
    ctx.lineCap = 'round';
    ctx.strokeStyle = themeAccentCss;
    ctx.fillStyle = themeAccentCss;
    const vMul = storm ? 1.5 : 1;
    for (const d of drops) {
      const vy = d.v * vMul * dt;
      d.y += vy;
      if (ob) {
        const px = d.x / DPR, prevY = (d.y - vy) / DPR, curY = d.y / DPR;
        if (px >= ob.left && px <= ob.right && prevY <= ob.top && curY >= ob.top) {
          impact(d.x, ob.top * DPR, d.l);
          Object.assign(d, spawn(d.l, false));
          continue;
        }
      }
      if (d.y - d.l.len * DPR > H) {
        if (Math.random() < 0.5) impact(d.x, H, d.l);
        Object.assign(d, spawn(d.l, false));
        continue;
      }
      ctx.globalAlpha = d.l.a;
      ctx.lineWidth = d.l.w * DPR;
      ctx.beginPath();
      ctx.moveTo(d.x, d.y);
      ctx.lineTo(d.x, d.y - d.l.len * DPR);
      ctx.stroke();
    }
    for (let i = droplets.length - 1; i >= 0; i--) {
      const p = droplets[i];
      p.vy += 0.22 * DPR * dt;
      const prevPy = p.y;
      p.x += p.vx * dt; p.y += p.vy * dt;
      // брызги тоже физические: отбиваются от рамки и от пола
      if (ob && p.vy > 0 && p.x >= ob.left * DPR && p.x <= ob.right * DPR &&
          prevPy <= ob.top * DPR && p.y >= ob.top * DPR) {
        p.y = ob.top * DPR; p.vy = -p.vy * 0.45; p.vx *= 0.92;
      }
      if (p.vy > 0 && p.y >= H) { p.y = H; p.vy = -p.vy * 0.45; p.vx *= 0.92; }
      p.life -= 0.03 * dt;
      if (p.life <= 0) { droplets.splice(i, 1); continue; }
      ctx.globalAlpha = p.life * 0.7;
      ctx.beginPath();
      ctx.arc(p.x, p.y, 1.4 * DPR, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;
  })(prev);

  // пасхалка: «rain» включает и выключает ливень
  let buf = '';
  addEventListener('keydown', e => {
    if (e.metaKey || e.ctrlKey || e.altKey) return;
    buf = (buf + e.key.toLowerCase()).slice(-4);
    if (buf !== 'rain') return;
    buf = '';
    storm = !storm;
    fill();
  });
}

/* ═══ Инициализация текстов ══════════════════════════════════════════ */
setLang(lang);
document.title = t('baseTitle');
// h1 заполняем сразу (scramble перепишет при интро)
$('#h1a').textContent = t('h1a');
$('#h1b').textContent = t('h1b');
