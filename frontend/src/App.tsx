import { useQuery } from '@tanstack/react-query'
import { api } from './lib/api'

interface Health {
  status: string
  version: string
}

export function App() {
  const { data, isLoading } = useQuery<Health>({
    queryKey: ['health'],
    queryFn: () => api('/health'),
  })

  return (
    <main className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-2xl font-semibold">AgenticOS</h1>
        <p className="text-sm text-gray-500">
          API: {isLoading ? 'checking…' : (data?.status ?? 'down')}
        </p>
      </div>
    </main>
  )
}
