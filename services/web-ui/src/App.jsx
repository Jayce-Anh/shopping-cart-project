import { useState, useEffect, useMemo } from 'react'
import { getProducts, placeOrder, getOrder } from './api'

const PRODUCT_IMAGES = {
  P001: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80',
  P002: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
  P003: 'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?auto=format&fit=crop&w=800&q=80',
  P004: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=800&q=80',
  P005: 'https://images.unsplash.com/photo-1590874103328-eac38a67437e?auto=format&fit=crop&w=800&q=80',
  P006: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80',
}

function money(value) {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    maximumFractionDigits: 0,
  }).format(value)
}

function productImage(code) {
  return PRODUCT_IMAGES[code] || 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=800&q=80'
}

export default function App() {
  const [products, setProducts] = useState([])
  const [cart, setCart] = useState({ customerEmail: '', customerAddress: '', items: [] })
  const [orderStatus, setOrderStatus] = useState('')
  const [searchId, setSearchId] = useState('')
  const [order, setOrder] = useState(null)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    getProducts()
      .then((data) => setProducts(Array.isArray(data) ? data : []))
      .catch(() => setError('Failed to load products.'))
      .finally(() => setLoading(false))
  }, [])

  const productsById = useMemo(() => {
    const map = {}
    products.forEach((p) => {
      map[p.id] = p
    })
    return map
  }, [products])

  const cartCount = cart.items.reduce((sum, item) => sum + item.quantity, 0)
  const cartTotal = cart.items.reduce((sum, item) => sum + item.quantity * item.productPrice, 0)

  function addToCart(product) {
    if (product.inStock === false) return
    setCart((prev) => {
      const exists = prev.items.find((i) => i.productId === product.id)
      const items = exists
        ? prev.items.map((i) =>
            i.productId === product.id ? { ...i, quantity: i.quantity + 1 } : i
          )
        : [...prev.items, { productId: product.id, quantity: 1, productPrice: product.price }]
      return { ...prev, items }
    })
  }

  function removeFromCart(productId) {
    setCart((prev) => ({ ...prev, items: prev.items.filter((i) => i.productId !== productId) }))
  }

  async function handlePlaceOrder() {
    setOrderStatus('')
    setError('')
    try {
      const data = await placeOrder(cart)
      setOrderStatus(`Order placed — ID ${data.id}`)
      setCart({ customerEmail: '', customerAddress: '', items: [] })
    } catch (e) {
      setError(`Failed to place order: ${e.message}`)
    }
  }

  async function handleSearchOrder() {
    setOrder(null)
    setError('')
    try {
      const data = await getOrder(searchId)
      setOrder(data)
    } catch (e) {
      setError(`Order not found: ${e.message}`)
    }
  }

  return (
    <div className="app">
      <header className="topbar">
        <div className="brand">
          <div className="brand-mark">
            Shelf<span>.</span>
          </div>
          <div className="brand-tag">Everyday essentials</div>
          <div className="brand-credit">— created by Jayce</div>
        </div>
        <div className="nav-actions">
          <a className="nav-link" href="#catalog">
            Catalog
          </a>
          <a className="nav-link" href="#checkout">
            Checkout
          </a>
          <a className="cart-chip" href="#checkout">
            Cart
            <span className="count">{cartCount}</span>
          </a>
        </div>
      </header>

      <section className="hero">
        <div className="hero-copy">
          <h1>Objects that earn their place.</h1>
          <p>
            Curated everyday gear — headphones, brew kits, bags, and more — ready to ship from the
            Shelf catalog.
          </p>
          <div className="hero-actions">
            <a className="btn btn-primary" href="#catalog">
              Browse catalog
            </a>
            <a className="btn btn-ghost" href="#checkout">
              View cart
            </a>
          </div>
        </div>
        <div className="hero-visual" aria-hidden="true">
          <div className="hero-badge">New season edit</div>
        </div>
      </section>

      <div className="shell">
        <main id="catalog">
          <div className="section-head">
            <div>
              <h2>Catalog</h2>
              <p>{products.length ? `${products.length} items in stock today` : 'Loading shelf…'}</p>
            </div>
          </div>

          {loading ? (
            <div className="loading">Loading products…</div>
          ) : (
            <div className="product-grid">
              {products.map((p, index) => {
                const inStock = p.inStock !== false
                return (
                  <article
                    key={p.id}
                    className="product"
                    style={{ animationDelay: `${Math.min(index, 6) * 0.06}s` }}
                  >
                    <div
                      className="product-media"
                      style={{ backgroundImage: `url(${productImage(p.code)})` }}
                    >
                      <span className={`stock-pill ${inStock ? 'in' : 'out'}`}>
                        {inStock ? 'In stock' : 'Sold out'}
                      </span>
                    </div>
                    <div className="product-body">
                      <div className="product-code">{p.code}</div>
                      <h3>{p.name}</h3>
                      <p>{p.description}</p>
                      <div className="product-foot">
                        <div className="price">{money(p.price)}</div>
                        <button
                          className="btn btn-primary btn-sm"
                          disabled={!inStock}
                          onClick={() => addToCart(p)}
                        >
                          {inStock ? 'Add to cart' : 'Unavailable'}
                        </button>
                      </div>
                    </div>
                  </article>
                )
              })}
            </div>
          )}
        </main>

        <aside className="side-stack" id="checkout">
          <section className="panel">
            <h2>Your cart</h2>
            <p className="panel-sub">Checkout with email and delivery address.</p>

            <div className="field">
              <label htmlFor="email">Customer email</label>
              <input
                id="email"
                type="email"
                placeholder="you@example.com"
                value={cart.customerEmail}
                onChange={(e) => setCart((prev) => ({ ...prev, customerEmail: e.target.value }))}
              />
            </div>
            <div className="field">
              <label htmlFor="address">Delivery address</label>
              <input
                id="address"
                placeholder="Street, city, postal code"
                value={cart.customerAddress}
                onChange={(e) => setCart((prev) => ({ ...prev, customerAddress: e.target.value }))}
              />
            </div>

            {cart.items.length === 0 ? (
              <div className="empty-cart">Your cart is empty. Add something from the catalog.</div>
            ) : (
              <ul className="cart-list">
                {cart.items.map((item) => {
                  const product = productsById[item.productId]
                  const name = product?.name || `Product #${item.productId}`
                  const code = product?.code
                  return (
                    <li key={item.productId}>
                      <div
                        className="cart-thumb"
                        style={{ backgroundImage: code ? `url(${productImage(code)})` : undefined }}
                      />
                      <div className="cart-meta">
                        <strong>{name}</strong>
                        <span>
                          {money(item.productPrice)} × {item.quantity}
                        </span>
                      </div>
                      <div className="cart-right">
                        <span className="line-total">{money(item.productPrice * item.quantity)}</span>
                        <button className="btn-danger" onClick={() => removeFromCart(item.productId)}>
                          Remove
                        </button>
                      </div>
                    </li>
                  )
                })}
              </ul>
            )}

            <div className="cart-total">
              <span>Total</span>
              <strong>{money(cartTotal)}</strong>
            </div>

            <button
              className="btn btn-primary"
              style={{ width: '100%' }}
              disabled={cart.items.length === 0 || !cart.customerEmail}
              onClick={handlePlaceOrder}
            >
              Place order
            </button>

            {orderStatus && <div className="order-result">{orderStatus}</div>}
          </section>

          <section className="panel">
            <h2>Find an order</h2>
            <p className="panel-sub">Look up a previous order by ID.</p>
            <div className="search-row">
              <div className="field">
                <label htmlFor="orderId">Order ID</label>
                <input
                  id="orderId"
                  placeholder="e.g. 42"
                  value={searchId}
                  onChange={(e) => setSearchId(e.target.value)}
                />
              </div>
              <button
                className="btn btn-ghost"
                style={{ alignSelf: 'end' }}
                onClick={handleSearchOrder}
                disabled={!searchId}
              >
                Search
              </button>
            </div>

            {order && (
              <div className="order-card">
                <dl>
                  <div>
                    <dt>Order</dt>
                    <dd>#{order.id}</dd>
                  </div>
                  <div>
                    <dt>Customer</dt>
                    <dd>{order.customerEmail || '—'}</dd>
                  </div>
                  <div>
                    <dt>Address</dt>
                    <dd>{order.customerAddress || '—'}</dd>
                  </div>
                  <div>
                    <dt>Status</dt>
                    <dd>{order.status || 'CREATED'}</dd>
                  </div>
                </dl>
                {Array.isArray(order.items) && order.items.length > 0 && (
                  <ul className="order-items">
                    {order.items.map((item, idx) => {
                      const product = productsById[item.productId]
                      return (
                        <li key={`${item.productId}-${idx}`}>
                          <span>
                            {product?.name || `Product #${item.productId}`} × {item.quantity}
                          </span>
                          <span>{money((item.productPrice ?? 0) * item.quantity)}</span>
                        </li>
                      )
                    })}
                  </ul>
                )}
              </div>
            )}
          </section>
        </aside>
      </div>

      {error && (
        <div className="toast" role="alert">
          <span>{error}</span>
          <button onClick={() => setError('')}>Dismiss</button>
        </div>
      )}
    </div>
  )
}
