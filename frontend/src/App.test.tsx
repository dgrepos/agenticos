import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen } from '@testing-library/react'
import { App } from './App'

test('renders the app title', () => {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  render(
    <QueryClientProvider client={qc}>
      <App />
    </QueryClientProvider>,
  )
  expect(screen.getByText('AgenticOS')).toBeInTheDocument()
})
