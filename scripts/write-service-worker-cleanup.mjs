import { writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const target = resolve(process.argv[2] ?? 'app/build/web/flutter_service_worker.js');
const source = `/* RENKEVIA one-release service-worker retirement shim. */
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.map((key) => caches.delete(key)));
    await self.registration.unregister();
    const clients = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    for (const client of clients) {
      const url = new URL(client.url);
      if (!url.searchParams.has('__rkv_sw_clean')) {
        url.searchParams.set('__rkv_sw_clean', '1');
        await client.navigate(url.toString());
      } else {
        client.postMessage('RENKEVIA_SW_RETIRED');
      }
    }
  })());
});
`;

writeFileSync(target, source, 'utf8');
console.log(`Wrote safe service-worker retirement shim to ${target}`);
