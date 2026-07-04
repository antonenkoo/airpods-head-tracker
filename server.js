// Локальный HTTPS-сервер для трекера положения головы/телефона.
// Отдаёт статику из public/ и печатает адрес для захода с телефона в той же Wi-Fi сети.
import https from "node:https";
import { readFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join, normalize, extname } from "node:path";
import { networkInterfaces } from "node:os";
import { ensureCert } from "./scripts/gen-cert.js";

const __dirname = dirname(fileURLToPath(import.meta.url));
const publicDir = join(__dirname, "public");
const PORT = process.env.PORT || 8443;

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
};

const { keyPath, certPath } = ensureCert();
const options = {
  key: readFileSync(keyPath),
  cert: readFileSync(certPath),
};

const server = https.createServer(options, (req, res) => {
  // Простой безопасный роутинг статики
  let urlPath = decodeURIComponent(new URL(req.url, "https://x").pathname);
  if (urlPath === "/") urlPath = "/index.html";

  const filePath = normalize(join(publicDir, urlPath));
  if (!filePath.startsWith(publicDir) || !existsSync(filePath)) {
    res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
    res.end("404 — не найдено");
    return;
  }

  const type = MIME[extname(filePath)] || "application/octet-stream";
  res.writeHead(200, { "Content-Type": type });
  res.end(readFileSync(filePath));
});

function localIPs() {
  const nets = networkInterfaces();
  const ips = [];
  for (const list of Object.values(nets)) {
    for (const net of list || []) {
      if (net.family === "IPv4" && !net.internal) ips.push(net.address);
    }
  }
  return ips;
}

server.listen(PORT, "0.0.0.0", () => {
  console.log("\n📡 Head Tracker запущен по HTTPS\n");
  console.log(`   На этом компьютере:  https://localhost:${PORT}`);
  for (const ip of localIPs()) {
    console.log(`   С телефона (Wi-Fi):  https://${ip}:${PORT}`);
  }
  console.log(
    "\n⚠️  Сертификат самоподписанный — браузер покажет предупреждение.\n" +
      "   Нажмите «Дополнительно» → «Всё равно перейти» (Advanced → Proceed).\n" +
      "   На iPhone нажмите зелёную кнопку «Включить датчики» и разрешите доступ.\n"
  );
});
