# Home Assistant Add-on: Telemt

MTProto-прокси для Telegram на [Telemt](https://github.com/telemt/telemt)
в режиме **WEB**: трафик идёт обычным HTTPS через ваш существующий
[Caddy](https://github.com/ad/ha-caddy), Telemt слушает только plain HTTP
внутри сети.

```text
Telegram → HTTPS/HTTP2 :443 → Caddy → HTTP :18080 → Telemt → Telegram
```

## Установка

1. В Home Assistant: **Settings → Add-ons → Add-on Store → ⋮ → Repositories**.
2. Добавить URL этого репозитория.
3. Установить **Telemt**.
4. Во вкладке **Configuration** задать `host` (отдельный поддомен).
5. Запустить аддон, открыть его панель — там готовая ссылка `tg://webproxy?...`.

## Минимальный пример

```yaml
host: tg.example.com
```

В аддон Caddy добавить домен целиком:

```yaml
proxies:
  - domain: tg.example.com
    upstream: 10.0.1.19:18080
    tls: true
```

## Требования

- Отдельный поддомен с A-записью на ваш публичный IP.
- Проброшенный 443/tcp на хост с HA (уже нужен для Caddy).
- Статический публичный IP (или пропишите `public_ip` вручную при смене).

## На основном домене, без отдельного поддомена

Telemt слушает четыре фиксированных пути. Их можно отдать ему через
`path_routes`, а всё остальное оставить Home Assistant:

```yaml
path_routes: |
  home.example.com / 10.0.1.19:18080
  home.example.com /api/v1/session 10.0.1.19:18080
  home.example.com /api/v1/up 10.0.1.19:18080
  home.example.com /api/v1/down 10.0.1.19:18080
```

Плюс `decoy_upstream: 10.0.1.19:8123` в опциях аддона, чтобы обычный
`GET /` возвращался в HA. Компромиссы описаны в
[`telemt/DOCS.md`](telemt/DOCS.md).

Подробности — [`telemt/DOCS.md`](telemt/DOCS.md).
