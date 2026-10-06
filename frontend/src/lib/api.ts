// Single API client — components never call fetch directly (see .claude/rules/frontend.md).
// Base URL from env (VITE_API_BASE in .env/.env.local); defaults to the Vite dev proxy.
const BASE = import.meta.env.VITE_API_BASE ?? '/api'

export async function api<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE}${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...init,
  })
  if (!res.ok) throw new Error(`API ${res.status}: ${await res.text()}`)
  return res.json() as Promise<T>
}
