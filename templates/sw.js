/* Scan Deck service worker: app shell offline, API always live.
   This file is served dynamically by Flask so the version can be injected.
   The cache name includes the version: each new version gets its own cache,
   and old ones are pruned during activation. Without this, an installed app
   would permanently retain the CSS and JS from its first installation. */
const VERSION = "{{ version }}";
const SHELL_CACHE = `scandeck-shell-${VERSION}`;
const SHELL_ASSETS = [
  "/",
  `/static/app.css?v=${VERSION}`,
  `/static/app.js?v=${VERSION}`,
  "/manifest.webmanifest",
  "/static/icons/icon-192.png",
  "/static/icons/icon-512.png",
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(SHELL_CACHE).then((cache) => cache.addAll(SHELL_ASSETS)).then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) => Promise.all(keys.filter((key) => key !== SHELL_CACHE).map((key) => caches.delete(key))))
      .then(() => self.clients.claim())
  );
});

/* Push: reaches the installed app even when it is closed. */
self.addEventListener("push", (event) => {
  let payload = { title: "ScanDeck", body: "Scan complete.", tag: "scandeck" };
  try {
    if (event.data) payload = { ...payload, ...event.data.json() };
  } catch {
    /* Plain text instead of JSON: keep default payload */
  }
  event.waitUntil(
    self.registration.showNotification(payload.title, {
      body: payload.body,
      tag: payload.tag,
      icon: "/static/icons/icon-192.png",
      badge: "/static/icons/icon-192.png",
      vibrate: [80, 40, 80],
      renotify: true,
    })
  );
});

/* Tapping the notification brings the app window to the front instead of reopening. */
self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  event.waitUntil(
    self.clients.matchAll({ type: "window", includeUncontrolled: true }).then((clients) => {
      const open = clients.find((client) => "focus" in client);
      if (open) return open.focus();
      return self.clients.openWindow("/");
    })
  );
});

self.addEventListener("fetch", (event) => {
  const { request } = event;
  if (request.method !== "GET") return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;
  // Live data must never be answered from a cache.
  if (url.pathname.startsWith("/api/") || url.pathname === "/health") return;

  if (request.mode === "navigate") {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const copy = response.clone();
          caches.open(SHELL_CACHE).then((cache) => cache.put("/", copy));
          return response;
        })
        .catch(() => caches.match("/"))
    );
    return;
  }

  // Stale-while-revalidate: respond from cache immediately while fetching
  // updates in the background. Changes land at the latest on the next launch,
  // even if the version number remains unchanged.
  event.respondWith(
    caches.open(SHELL_CACHE).then((cache) =>
      cache.match(request).then((cached) => {
        const network = fetch(request)
          .then((response) => {
            if (response.ok) cache.put(request, response.clone());
            return response;
          })
          .catch(() => cached);
        return cached || network;
      })
    )
  );
});
