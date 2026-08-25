#!/usr/bin/with-contenv bashio
# ==============================================================================
# Generates /opt/ha-telemt/web/index.html — status page served via HA Ingress.
# ==============================================================================
set -e

WEB_DIR="/opt/ha-telemt/web"
HTML="${WEB_DIR}/index.html"
STATE_FILE="/data/state.env"
mkdir -p "${WEB_DIR}"

# shellcheck disable=SC1090
source "${STATE_FILE}"

LINK="tg://webproxy?server=${HOST}&secret=dd${SECRET}"
CARRIER=$(bashio::config 'carrier')
SOCKS5="прямые подключения"
if bashio::config.has_value 'socks5_upstream'; then
    SOCKS5="socks5 $(bashio::config 'socks5_upstream')"
fi
DECOY="статика /data/public"
if bashio::config.has_value 'decoy_upstream'; then
    DECOY="http://$(bashio::config 'decoy_upstream')"
fi
GENERATED_AT=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

cat > "${HTML}" <<HTML
<!doctype html>
<html lang="ru">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Telemt — статус</title>
<style>
  :root { color-scheme: light dark; }
  body { font-family: -apple-system, system-ui, sans-serif; max-width: 960px;
         margin: 1.5rem auto; padding: 0 1rem; line-height: 1.45; }
  h1 { margin: 0 0 .25rem; font-size: 1.4rem; }
  .meta { color: #888; font-size: .85rem; margin-bottom: 1.25rem; }
  table { width: 100%; border-collapse: collapse; font-size: .9rem; }
  th, td { padding: .5rem .6rem; border-bottom: 1px solid rgba(127,127,127,.25);
           text-align: left; vertical-align: top; }
  th { font-weight: 600; background: rgba(127,127,127,.08); width: 12rem; }
  code { font-family: ui-monospace, Menlo, Consolas, monospace; font-size: .85em; }
  pre { background: rgba(127,127,127,.1); padding: .6rem; overflow-x: auto;
        border-radius: 4px; font-size: .8rem; }
  .link { word-break: break-all; }
  details { margin-top: 1rem; }
  summary { cursor: pointer; color: #888; }
</style>
</head>
<body>
<h1>Telemt WEB proxy</h1>
<div class="meta">обновлено ${GENERATED_AT}</div>

<table>
<tr><th>Ссылка для Telegram</th><td class="link"><a href="${LINK}"><code>${LINK}</code></a></td></tr>
<tr><th>Домен</th><td><code>${HOST}</code></td></tr>
<tr><th>Публичный адрес</th><td><code>${PUBLIC_IP}:443</code></td></tr>
<tr><th>Секрет</th><td><code>${SECRET}</code></td></tr>
<tr><th>Carrier</th><td><code>${CARRIER}</code></td></tr>
<tr><th>Слушает</th><td><code>0.0.0.0:18080</code> (только HTTP, за TLS-терминатором)</td></tr>
<tr><th>Выход в Telegram</th><td><code>${SOCKS5}</code></td></tr>
<tr><th>Маскировка</th><td><code>${DECOY}</code></td></tr>
</table>

<details open>
<summary>Настройка Caddy</summary>
<pre>
proxies:
  - domain: ${HOST}
    upstream: &lt;IP хоста HA&gt;:18080
    tls: true
</pre>
<p>Весь домен целиком должен идти в Telemt: маскировочный сайт отдаёт сам Telemt.
Отдельный путь (<code>/что-то*</code>) не подходит — ссылка <code>tg://webproxy</code>
не умеет путь, и это ломает маскировку.</p>
</details>

<details>
<summary>Где что лежит</summary>
<pre>
конфиг:            /etc/telemt/telemt.toml (auto-generated)
секрет:            /data/secret
маскировочный сайт: /data/public/index.html
</pre>
</details>
</body>
</html>
HTML

bashio::log.info "Proxy link: ${LINK}"
bashio::log.info "Status page generated at ${HTML}"
