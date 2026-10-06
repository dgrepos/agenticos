---
paths:
  - "e2e/**"
  - "**/tests/**"
  - "**/*.test.*"
---

# Testing rules

- Tests are written from acceptance criteria in the spec, before implementation (TDD). A spec criterion without a test is unfinished work.
- Test names state behavior: `test_rejects_expired_token`, not `test_token_2`.
- No sleeps; use Playwright auto-waiting / pytest fixtures. Flaky tests are fixed or deleted the same day (log in gotchas).
- E2E (Playwright, in `e2e/`) covers happy paths and critical failure paths only; edge cases belong in unit tests.
- Run Playwright headless via CLI (`npx playwright test`); use `--reporter=line` for iteration, screenshots/traces on failure only (config default).
