# Diagrams

Generated assets. Each diagram ships as two self-contained SVGs, `-light` and `-dark`,
referenced from the root README through `<picture>`:

```html
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/diagrams/NAME-dark.svg">
  <img alt="describe the diagram in a sentence" src="docs/diagrams/NAME-light.svg">
</picture>
```

GitHub strips `<script>`, `<style>` and inline `<svg>` from markdown, so a diagram has to
be a committed image file. It keeps `<picture>` and `<source>`, which is what makes the
theme switch work; the fallback `<img>` is what every other renderer (npm, PyPI, VS Code,
raw text) will use, so the light variant must be the one in `src`.

| File | Type | Shows |
|---|---|---|
| `agenticos-stack` | architecture | How a request travels from the browser through Vite to FastAPI, and what Playwright boots |
| `delivery-pipeline` | workflow | The six pipeline stages, their sign-off gates, the rework loop, and the files each stage writes |
| `backlog-item` | lifecycle | The statuses a backlog row moves through, including rework and dropped |
| `memory-pipeline` | dataflow | How source files and session work become repo memory, and what the next session reads |
| `health-request` | sequence | The seeded health check end to end, including the proxy rewrite |

## Regenerating

The SVGs are exported from the interactive HTML in `.archify/` (build output, gitignored).
With that present:

```bash
cd e2e && node export-diagrams.mjs .. ../docs/diagrams
```

The exporter uses a headless browser on purpose. The diagrams colour themselves with CSS
custom properties declared on the *page*, so lifting the `<svg>` out with a regex yields an
unstyled skeleton. Chromium resolves the cascade, then the script freezes the resolved
variables onto the SVG root and paints the canvas background into the file, which is what
makes each export stand alone.
