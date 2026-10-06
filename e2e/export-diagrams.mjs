// Export each archify HTML diagram to a self-contained SVG per theme, plus a 2x PNG.
//
// Lives in e2e/ because that workspace owns the playwright dependency.
// Usage:
//   cd e2e && node export-diagrams.mjs .. ../docs/diagrams
//
// Input:  <repo>/.archify/<type>-<slug>-<stamp>/<slug>.html  (gitignored build output)
// Output: <out>/<slug>-{light,dark}.svg  +  matching 2x PNGs
//
// The README references the SVGs through <picture media="(prefers-color-scheme: dark)">,
// which is the pattern GitHub supports for theme-aware images.
//
// Why a browser: the diagrams colour themselves with CSS custom properties declared on
// the PAGE, not inside the <svg>. Lifting the <svg> out with a regex yields an unstyled
// skeleton. Chromium resolves the cascade for us, then we freeze the resolved variables
// onto the SVG root so the file stands alone.
import { chromium } from '@playwright/test'
import { readdir, mkdir, writeFile } from 'node:fs/promises'
import { join, basename, resolve } from 'node:path'
import { pathToFileURL } from 'node:url'

// Resolved so the script works from any cwd: file:// demands an absolute path.
const ROOT = resolve(process.argv[2] ?? '..')
const OUT = resolve(process.argv[3] ?? join(ROOT, 'docs', 'diagrams'))
const THEMES = ['light', 'dark']

const sources = []
for (const dir of await readdir(join(ROOT, '.archify'))) {
  for (const f of await readdir(join(ROOT, '.archify', dir))) {
    if (f.endsWith('.html')) sources.push({ dir, file: f, slug: basename(f, '.html') })
  }
}
sources.sort((a, b) => a.slug.localeCompare(b.slug))

await mkdir(OUT, { recursive: true })
const browser = await chromium.launch()
const report = []

for (const src of sources) {
  const page = await browser.newPage({ viewport: { width: 1600, height: 1200 }, deviceScaleFactor: 2 })
  await page.goto(pathToFileURL(join(ROOT, '.archify', src.dir, src.file)).href, { waitUntil: 'networkidle' })

  for (const theme of THEMES) {
    // The page exposes theming via data-theme on <html>; set it explicitly so we never
    // depend on whatever prefers-color-scheme the headless browser reports.
    await page.evaluate((t) => {
      document.documentElement.setAttribute('data-theme', t)
      document.documentElement.style.colorScheme = t
    }, theme)
    await page.waitForTimeout(250)

    const svg = await page.evaluate(() => {
      const src = document.querySelector('svg')
      const svg = src.cloneNode(true)

      // 1. Freeze every custom property the page resolved, onto the SVG root, so the
      //    standalone file carries its own palette.
      const rootStyle = getComputedStyle(document.documentElement)
      const vars = []
      for (const sheet of document.styleSheets) {
        let rules
        try { rules = sheet.cssRules } catch { continue }
        for (const rule of rules) {
          if (!rule.style) continue
          for (const prop of rule.style) {
            if (prop.startsWith('--')) vars.push(prop)
          }
        }
      }
      const decls = [...new Set(vars)]
        .map((v) => `${v}:${rootStyle.getPropertyValue(v).trim()}`)
        .filter((d) => !d.endsWith(':'))
        .join(';')

      // 2. Carry over the stylesheet rules that target SVG content. Page chrome
      //    (toolbar, buttons, menus) is dropped: it has no meaning in a static image.
      const keep = []
      for (const sheet of document.styleSheets) {
        let rules
        try { rules = sheet.cssRules } catch { continue }
        for (const rule of rules) {
          if (!rule.selectorText || !rule.style) continue
          if (/^(html|body|\.toolbar|\.menu|\.btn|button|\[data-theme)/i.test(rule.selectorText)) continue
          keep.push(rule.cssText)
        }
      }

      const style = document.createElementNS('http://www.w3.org/2000/svg', 'style')
      style.textContent = keep.join('\n')
      svg.insertBefore(style, svg.firstChild)

      // 3. The page's <body> painted the canvas, so a lifted <svg> is transparent and
      //    a dark diagram lands on GitHub's white README. Paint it into the file.
      const vb0 = svg.getAttribute('viewBox').split(/\s+/).map(Number)
      const bgRect = document.createElementNS('http://www.w3.org/2000/svg', 'rect')
      bgRect.setAttribute('x', vb0[0])
      bgRect.setAttribute('y', vb0[1])
      bgRect.setAttribute('width', vb0[2])
      bgRect.setAttribute('height', vb0[3])
      bgRect.setAttribute('fill', getComputedStyle(document.body).backgroundColor)
      svg.insertBefore(bgRect, style.nextSibling)
      svg.setAttribute('style', decls)
      svg.setAttribute('xmlns', 'http://www.w3.org/2000/svg')
      svg.setAttribute('xmlns:xlink', 'http://www.w3.org/1999/xlink')

      const vb = svg.getAttribute('viewBox').split(/\s+/).map(Number)
      svg.setAttribute('width', vb[2])
      svg.setAttribute('height', vb[3])

      // A static export must not advertise interactive affordances.
      svg.querySelectorAll('[data-archify-interactive], script').forEach((n) => n.remove())

      return { markup: new XMLSerializer().serializeToString(svg), w: vb[2], h: vb[3] }
    })

    const name = `${src.slug}-${theme}.svg`
    await writeFile(join(OUT, name), '<?xml version="1.0" encoding="UTF-8"?>\n' + svg.markup)
    report.push({ name, bytes: svg.markup.length, w: svg.w, h: svg.h })

    // PNG fallback, 2x, element-scoped so there is no page chrome or padding.
    const el = await page.$('svg')
    await el.screenshot({ path: join(OUT, `${src.slug}-${theme}.png`) })
  }
  await page.close()
}

await browser.close()
console.log(JSON.stringify(report, null, 1))
