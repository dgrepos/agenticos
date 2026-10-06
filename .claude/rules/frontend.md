---
paths:
  - "frontend/**"
---

# Frontend rules (React + Vite + TypeScript)

- Function components + hooks only; no class components.
- Strict TypeScript: no `any`, no `@ts-ignore` without an inline reason.
- Structure: `src/components/` (shared), `src/features/<feature>/` (feature-scoped components + hooks + api), `src/lib/` (utilities, API client).
- Server state via TanStack Query through the shared API client in `src/lib/api.ts`; never `fetch` directly in components.
- Styling: Tailwind utility classes; extract a component when a class list is repeated 3+ times.
- Component tests with Vitest + Testing Library next to the file (`X.test.tsx`); user-visible flows belong in `e2e/`, not unit tests.
