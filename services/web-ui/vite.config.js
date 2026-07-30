import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    // Local dev proxy: forwards /api/* to services directly
    proxy: {
      '/api/products':  'http://localhost:4000',
      '/api/inventory': 'http://localhost:5000',
      '/api/orders':    'http://localhost:6000',
    }
  },
  build: {
    outDir: 'dist',
  }
})
