# frontend/

React 18 + Vite + TypeScript strict + Tailwind + TanStack Query.

- Test: `npm test -- --run` · Typecheck: `npx tsc --noEmit` · Dev: `npm run dev` (proxies `/api` → backend :8000)
- API calls only via `src/lib/api.ts`. Feature code in `src/features/<name>/`.
- Full conventions: `.claude/rules/frontend.md` (auto-loads when editing files here).
