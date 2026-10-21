"""Capture app evidence using Playwright + installed Chromium (documentation only).

Run a local server serving build/web on port 8080 first.
The Flutter app itself does not depend on Python or Playwright.
"""

import os
from pathlib import Path
import re
from urllib.parse import urlsplit

from playwright.sync_api import sync_playwright


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'docs/screenshots'
OUTPUT.mkdir(parents=True, exist_ok=True)


def enable_semantics(page):
    placeholder = page.locator('flt-semantics-placeholder')
    placeholder.wait_for(state='attached', timeout=30000)
    placeholder.evaluate('(element) => element.click()')


def capture(page, name):
    page.screenshot(path=str(OUTPUT / name), full_page=True)


def main():
    proxy_url = os.environ.get('HTTPS_PROXY') or os.environ.get('https_proxy')
    proxy = None
    if proxy_url:
        parsed = urlsplit(proxy_url)
        if parsed.username or parsed.password:
            raise RuntimeError('Use platform browser proxy configuration for authenticated proxies.')
        proxy = {
            'server': f'{parsed.scheme}://{parsed.hostname}:{parsed.port or 80}',
            'bypass': '127.0.0.1,localhost',
        }
    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(
            executable_path='/usr/bin/chromium',
            headless=True,
            proxy=proxy,
            args=['--no-sandbox'],
        )
        errors = []
        page = browser.new_page(viewport={'width': 390, 'height': 844})
        page.on('pageerror', lambda error: errors.append(str(error)))
        with page.expect_response(lambda response: response.url.startswith('https://dummyjson.com/products')) as api_response:
            page.goto('http://127.0.0.1:8080', wait_until='networkidle')
        assert api_response.value.status == 200
        count = len(api_response.value.json()['products'])
        enable_semantics(page)
        page.get_by_text(f'{count} produk', exact=True).wait_for()
        capture(page, '01-katalog.png')

        # Type actual keyboard events to exercise Flutter web's text input.
        field = page.get_by_role('textbox')
        field.click()
        field.press_sequentially('mascara', delay=80)
        page.get_by_text('1 produk', exact=True).wait_for()
        capture(page, '02-pencarian.png')

        page.get_by_role('button', name='Tambah favorit', exact=True).first.click()
        page.mouse.click(195, 804)
        page.get_by_text('Pilihan favoritmu.', exact=True).wait_for()
        capture(page, '03-favorit.png')

        # Tap the first product's photo, which is always within this viewport.
        page.mouse.click(100, 430)
        page.mouse.wheel(0, 450)
        page.get_by_text('Tentang produk', exact=True).wait_for()
        capture(page, '04-detail.png')
        page.get_by_role('button', name='Tambah ke keranjang', exact=True).click()
        page.mouse.click(325, 804)
        page.get_by_text('Total (USD)', exact=True).wait_for()
        capture(page, '05-keranjang.png')

        # Simulate a slow request so the FutureBuilder loading UI is observable.
        loading = browser.new_page(viewport={'width': 390, 'height': 844})
        held = []
        loading.route(re.compile(r'https://dummyjson\.com/products.*'), lambda route: held.append(route))
        loading.goto('http://127.0.0.1:8080', wait_until='domcontentloaded')
        enable_semantics(loading)
        loading.get_by_text('Mengambil produk…', exact=True).wait_for()
        capture(loading, '06-loading.png')
        for route in held:
            route.abort('failed')
        loading.unroute_all(behavior='wait')
        loading.close()

        # Intentionally abort only the API request to demonstrate error + retry.
        failed = browser.new_page(viewport={'width': 390, 'height': 844})
        failed.route(re.compile(r'https://dummyjson\.com/products.*'), lambda route: route.abort('failed'))
        failed.goto('http://127.0.0.1:8080', wait_until='networkidle')
        enable_semantics(failed)
        failed.get_by_text('Produk belum bisa dimuat', exact=True).wait_for()
        failed.get_by_role('button', name='Coba lagi', exact=True).wait_for()
        capture(failed, '07-error.png')
        failed.unroute_all()
        failed.get_by_role('button', name='Coba lagi', exact=True).click()
        failed.get_by_text(f'{count} produk', exact=True).wait_for()
        assert not errors, errors
        browser.close()
    print(f'Browser OK: {count} live products, search, favorites, details, cart, loading, error and retry.')
    print('Screenshots: 7; JavaScript errors on normal flow: 0.')


if __name__ == '__main__':
    main()
