import { expect, test } from '@playwright/test'

test('app loads and reports healthy API', async ({ page }) => {
  await page.goto('/')
  await expect(page.getByRole('heading', { name: 'AgenticOS' })).toBeVisible()
  await expect(page.getByText('API: ok')).toBeVisible()
})
