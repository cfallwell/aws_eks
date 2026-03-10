import { useEffect, useState } from "react";
import type { CSSProperties } from "react";
import { Link, NavLink, Route, Routes } from "react-router-dom";
import ProductDetail from "./components/ProductDetail";
import ProductList from "./components/ProductList";
import Cart from "./components/Cart";
import { fetchProducts } from "./lib/api";
import type { CartItem, Product } from "./lib/types";

export default function App() {
  const [products, setProducts] = useState<Product[]>([]);
  const [cartItems, setCartItems] = useState<CartItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

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
            Products now come from a Node API backed by Amazon RDS for PostgreSQL instead of hardcoded
            frontend state.
          </p>
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

      {loading ? <p>Loading catalog...</p> : null}
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
            <Route
              path="*"
              element={
                <section>
                  <h2>Not found</h2>
                  <Link to="/">Back to catalog</Link>
                </section>
              }
            />
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
  error: {
    maxWidth: "1100px",
    margin: "0 auto 1rem",
    color: "#b91c1c",
    fontWeight: 700,
  },
};
