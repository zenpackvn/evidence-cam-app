# StampMail — Web letter viewer

Standalone, self-contained page a recipient opens from a share link (SM-017,
TD-011). **Not** Flutter Web — one light `index.html` with inline CSS/JS so it
loads fast for a first-time recipient.

## What it does

1. Parses the link id from the URL (`/letter/<id>` or `?id=<id>`).
2. Calls `GET {apiBase}/public/letter/<id>` (the backend's one-time/7-day
   `OpenLink`; the first opener wins).
3. On success: shows a sealed envelope; tapping it plays the open animation and
   reveals the letter text + stamp images, plus an install-app CTA.
4. On `410` (already opened / expired) or `404` (invalid): shows a friendly
   state + install CTA.

## Config

The page reads an optional `window.STAMPMAIL_CONFIG` set by a small inline
`<script>` injected at deploy time (or edit the defaults in `index.html`):

```html
<script>
  window.STAMPMAIL_CONFIG = {
    apiBase: 'https://api.stampmail.app',   // backend base URL ('' = same origin)
    storeUrl: 'https://stampmail.app/get'   // AppsFlyer OneLink / store URL
  };
</script>
```

Same-origin (`apiBase: ''`) works if the page is hosted behind the same domain
as the backend.

## Animation (TD-010 — needs a decision)

The open animation here is **CSS-only** (envelope flap + letter slide). It
respects `prefers-reduced-motion`. If a richer branded animation is wanted, swap
the `.envelope` block for a Rive/Lottie player (one asset reused by the app) —
see blockers.

## Deploy

Static hosting (Firebase Hosting or Cloudflare Pages). Point the letter-link
domain's `/letter/*` route at this `index.html`. Universal-link / App-Link
association files (`apple-app-site-association`, `assetlinks.json`) go alongside
so an installed app opens the letter in-app instead (TD-005a).
