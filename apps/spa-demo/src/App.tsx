import { useEffect, useState } from "react";
import type { CSSProperties } from "react";
import { RumRouterTracker, useEnableReplayPersist } from "@cfallwell/rumbootstrap";
import { NavLink, Route, Routes } from "react-router-dom";
import Cart from "./components/Cart";
import ProductDetail from "./components/ProductDetail";
import ProductList from "./components/ProductList";
import { fetchProducts } from "./lib/api";
import type { CartItem, Product } from "./lib/types";

export default function App() {
  const [products, setProducts] = useState<Product[]>([]);
  const [cartItems, setCartItems] = useState<CartItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const enableReplay = useEnableReplayPersist();

  useEffect(() => {
    let cancelled = false;

    async function loadProducts() {
      try {
        const nextProducts = await fetchProducts();

        if (!cancelled) {
          setProducts(nextProducts);
          setError(null);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : "Failed to load products");
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    loadProducts();

    return () => {
      cancelled = true;
    };
  }, []);

  const addToCart = (product: Product) => {
    setCartItems((current) => {
      const existing = current.find((item) => item.id === product.id);

      if (existing) {
        return current.map((item) =>
          item.id === product.id ? { ...item, quantity: item.quantity + 1 } : item
        );
      }

      return [...current, { ...product, quantity: 1 }];
    });
  };

  const updateQuantity = (productId: number, delta: number) => {
    setCartItems((current) =>
      current
        .map((item) =>
          item.id === productId ? { ...item, quantity: Math.max(0, item.quantity + delta) } : item
        )
        .filter((item) => item.quantity > 0)
    );
  };

  const totalItems = cartItems.reduce((sum, item) => sum + item.quantity, 0);

  return (
    <div style={styles.page}>
      <header style={styles.hero}>
        <div>
          <p style={styles.eyebrow}>EKS + RDS + Node.js demo</p>
          <h1 style={styles.title}>SPA demo with a real PostgreSQL backend</h1>
          <p style={styles.subtitle}>
            Products are loaded through a Node.js API backed by Amazon RDS for PostgreSQL while Splunk
            RUM continues to observe client-side navigation.
          </p>
          <button type="button" onClick={enableReplay} style={styles.replayButton}>
            Enable Session Replay
          </button>
        </div>
        <nav style={styles.nav}>
          <NavLink to="/" style={navLinkStyle} end>
            Catalog
          </NavLink>
          <NavLink to="/cart" style={navLinkStyle}>
            Cart ({totalItems})
          </NavLink>
        </nav>
      </header>

      <RumRouterTracker />

      {loading ? <p style={styles.status}>Loading catalog...</p> : null}
      {error ? <p style={styles.error}>{error}</p> : null}

      {!loading && !error ? (
        <main style={styles.main}>
          <Routes>
            <Route path="/" element={<ProductList products={products} onAddToCart={addToCart} />} />
            <Route
              path="/products/:slug"
              element={<ProductDetail products={products} onAddToCart={addToCart} />}
            />
            <Route path="/cart" element={<Cart items={cartItems} onUpdateQuantity={updateQuantity} />} />
          </Routes>
        </main>
      ) : null}
    </div>
  );
}

const navLinkStyle = ({ isActive }: { isActive: boolean }): CSSProperties => ({
  textDecoration: "none",
  color: isActive ? "#0f172a" : "#2563eb",
  fontWeight: 800,
});

const styles: Record<string, CSSProperties> = {
  page: {
    minHeight: "100vh",
    padding: "2rem",
    background:
      "radial-gradient(circle at top left, rgba(14,165,233,0.16), transparent 32%), linear-gradient(180deg, #f8fafc 0%, #e2e8f0 100%)",
    color: "#0f172a",
    fontFamily: '"Segoe UI", sans-serif',
  },
  hero: {
    maxWidth: "1100px",
    margin: "0 auto 1.5rem",
    display: "flex",
    justifyContent: "space-between",
    gap: "1rem",
    flexWrap: "wrap",
    alignItems: "flex-end",
  },
  eyebrow: {
    margin: 0,
    textTransform: "uppercase",
    letterSpacing: "0.18em",
    color: "#0f766e",
    fontWeight: 800,
    fontSize: "0.78rem",
  },
  title: {
    margin: "0.4rem 0 0",
    fontSize: "clamp(2rem, 5vw, 3.5rem)",
    lineHeight: 1.05,
  },
  subtitle: {
    maxWidth: "720px",
    color: "#334155",
    lineHeight: 1.6,
    marginBottom: "0.75rem",
  },
  replayButton: {
    padding: "0.55rem 1rem",
    borderRadius: "999px",
    border: "1px solid #2563eb",
    backgroundColor: "#eff6ff",
    color: "#2563eb",
    cursor: "pointer",
    fontWeight: 700,
  },
  nav: {
    display: "flex",
    gap: "1rem",
    alignItems: "center",
  },
  main: {
    maxWidth: "1100px",
    margin: "0 auto",
  },
  status: {
    maxWidth: "1100px",
    margin: "0 auto 1rem",
  },
  error: {
    maxWidth: "1100px",
    margin: "0 auto 1rem",
    color: "#b91c1c",
    fontWeight: 700,
  },
};
