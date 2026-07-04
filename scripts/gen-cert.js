// Генерация самоподписанного TLS-сертификата через системный openssl.
// Датчики ориентации в мобильных браузерах работают только по HTTPS
// (или на localhost), поэтому при заходе с телефона по IP нужен сертификат.
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const certDir = join(__dirname, "..", "certs");
const keyPath = join(certDir, "key.pem");
const certPath = join(certDir, "cert.pem");

export function ensureCert() {
  if (existsSync(keyPath) && existsSync(certPath)) {
    return { keyPath, certPath };
  }

  mkdirSync(certDir, { recursive: true });
  console.log("🔐 Сертификат не найден — генерирую самоподписанный (действует 825 дней)...");

  execFileSync(
    "openssl",
    [
      "req", "-x509", "-newkey", "rsa:2048", "-nodes",
      "-keyout", keyPath,
      "-out", certPath,
      "-days", "825",
      "-subj", "/CN=head-tracker.local",
      // SAN нужен, иначе современные браузеры ругаются даже на самоподписанный
      "-addext", "subjectAltName=DNS:localhost,IP:127.0.0.1",
    ],
    { stdio: "inherit" }
  );

  console.log("✅ Сертификат создан в папке certs/");
  return { keyPath, certPath };
}

// Позволяет запускать напрямую: npm run cert
if (import.meta.url === `file://${process.argv[1]}`) {
  ensureCert();
}
