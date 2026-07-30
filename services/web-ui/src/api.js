// API base URL: empty string = same CloudFront domain (/api/* routed to ALB)
// Override via VITE_API_BASE_URL env var for local dev pointing to a specific host
const BASE = import.meta.env.VITE_API_BASE_URL ?? ''

async function request(path, options = {}) {
  const res = await fetch(`${BASE}${path}`, {
    headers: { 'Content-Type': 'application/json', ...options.headers },
    ...options,
  })
  if (!res.ok) throw new Error(`${res.status} ${res.statusText}`)
  return res.json()
}

export const getProducts = () =>
  request('/api/products')

export const placeOrder = (order) =>
  request('/api/orders', { method: 'POST', body: JSON.stringify(order) })

export const getOrder = (id) =>
  request(`/api/orders/${id}`)
