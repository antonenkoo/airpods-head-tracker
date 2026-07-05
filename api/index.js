// AirPods Head Tracker — feedback API
// Принимает фидбеки из приложения/лендинга, кладёт в Mongo и создаёт GitHub issue.
import express from 'express';
import { MongoClient } from 'mongodb';

const PORT = process.env.PORT || 3000;
const MONGO_URL = process.env.MONGO_URL || '';
const GITHUB_TOKEN = process.env.GITHUB_TOKEN || '';
const GITHUB_REPO = process.env.GITHUB_REPO || 'antonenkoo/airpods-head-tracker';

const app = express();
app.use(express.json({ limit: '32kb' }));

// CORS: токенов на клиенте нет, куки не используются — «*» безопасен
app.use((req, res, next) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.sendStatus(204);
  next();
});

let db = null;
if (MONGO_URL) {
  try {
    const client = new MongoClient(MONGO_URL);
    await client.connect();
    db = client.db('aht');
    console.log('mongo: connected');
  } catch (e) {
    console.error('mongo: connection failed —', e.message);
  }
}

const TYPES = new Set(['bug', 'feature', 'idea']);
const LABELS = { bug: ['bug', 'from-app'], feature: ['enhancement', 'from-app'], idea: ['idea', 'from-app'] };

app.post('/feedback', async (req, res) => {
  const { type, message, satisfaction, version, locale } = req.body || {};
  if (!TYPES.has(type)) return res.status(400).json({ error: 'bad type' });
  const text = String(message || '').trim();
  if (text.length < 3 || text.length > 4000) return res.status(400).json({ error: 'bad message' });
  const sat = satisfaction === null || satisfaction === undefined
    ? null : Math.max(0, Math.min(100, Number(satisfaction) || 0));

  const doc = {
    type, message: text, satisfaction: sat,
    version: String(version || '').slice(0, 20),
    locale: String(locale || '').slice(0, 10),
    ua: String(req.headers['user-agent'] || '').slice(0, 200),
    createdAt: new Date(),
  };

  let saved = false, issueUrl = null;
  if (db) {
    try { await db.collection('feedback').insertOne(doc); saved = true; }
    catch (e) { console.error('mongo insert:', e.message); }
  }

  if (GITHUB_TOKEN) {
    try {
      const title = `[${type}] ${text.slice(0, 64)}${text.length > 64 ? '…' : ''}`;
      const body = [
        text, '',
        '---',
        `- **Type:** ${type}`,
        sat !== null ? `- **Satisfaction:** ${sat}%` : null,
        doc.version ? `- **App version:** ${doc.version}` : null,
        doc.locale ? `- **Locale:** ${doc.locale}` : null,
        `- **Source:** in-app feedback form`,
      ].filter(l => l !== null).join('\n');
      const r = await fetch(`https://api.github.com/repos/${GITHUB_REPO}/issues`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${GITHUB_TOKEN}`,
          'Accept': 'application/vnd.github+json',
          'Content-Type': 'application/json',
          'User-Agent': 'aht-feedback-api',
        },
        body: JSON.stringify({ title, body, labels: LABELS[type] }),
      });
      if (r.ok) issueUrl = (await r.json()).html_url;
      else console.error('github issue:', r.status, await r.text());
    } catch (e) { console.error('github issue:', e.message); }
  }

  if (!saved && !issueUrl) return res.status(502).json({ error: 'storage unavailable' });
  res.json({ ok: true, saved, issue: issueUrl });
});

// Прокси последнего релиза (кэш 5 минут) — для проверки обновлений без лимитов GitHub
let relCache = { at: 0, data: null };
app.get('/version', async (_req, res) => {
  if (Date.now() - relCache.at < 300000 && relCache.data) return res.json(relCache.data);
  try {
    const r = await fetch(`https://api.github.com/repos/${GITHUB_REPO}/releases/latest`,
      { headers: { 'User-Agent': 'aht-feedback-api' } });
    const j = await r.json();
    relCache = { at: Date.now(), data: {
      tag: j.tag_name, name: j.name, notes: j.body, publishedAt: j.published_at,
    } };
    res.json(relCache.data);
  } catch (e) { res.status(502).json({ error: e.message }); }
});

app.get('/health', (_req, res) => res.json({ ok: true, mongo: !!db }));

app.listen(PORT, () => console.log(`aht-api on :${PORT}`));
