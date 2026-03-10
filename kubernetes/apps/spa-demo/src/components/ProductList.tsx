import type { CSSProperties } from "react";
import { Link } from "react-router-dom";
import type { Product } from "../lib/types";

interface ProductListProps {
  products: Product[];
  onAddToCart: (product: Product) => void;
}

export default function ProductList({ products, onAddToCart }: ProductListProps) {
  return (
    <section style={styles.grid}>
      {products.map((product) => (
        <article key={product.id} style={styles.card}>
          <img src={product.imageUrl} alt={product.name} style={styles.image} />
          <h2 style={styles.title}>{product.name}</h2>
          <p style={styles.copy}>{product.description}</p>
          <p style={styles.stock}>Inventory: {product.inventory}</p>
          <div style={styles.footer}>
            <strong>${product.price.toFixed(2)}</strong>
            <div style={styles.actions}>
              <Link to={`/products/${product.slug}`} style={styles.link}>
                Details
              </Link>
              <button type="button" onClick={() => onAddToCart(product)} style={styles.button}>
                Add
              </button>
            </div>
          </div>
        </article>
      ))}
    </section>
  );
}

const styles: Record<string, CSSProperties> = {
  grid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))",
    gap: "1rem",
  },
  card: {
    backgroundColor: "#ffffff",
    borderRadius: "1rem",
    padding: "1rem",
    boxShadow: "0 12px 32px rgba(15, 23, 42, 0.08)",
    display: "flex",
    flexDirection: "column",
    gap: "0.75rem",
  },
  image: {
    width: "100%",
    aspectRatio: "4 / 3",
    objectFit: "cover",
    borderRadius: "0.75rem",
    backgroundColor: "#e2e8f0",
  },
  title: {
    margin: 0,
    color: "#0f172a",
  },
  copy: {
    margin: 0,
    color: "#475569",
    lineHeight: 1.5,
  },
  stock: {
    margin: 0,
    color: "#0f766e",
    fontWeight: 600,
  },
  footer: {
    marginTop: "auto",
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    gap: "0.75rem",
  },
  actions: {
    display: "flex",
    gap: "0.5rem",
    alignItems: "center",
  },
  link: {
    textDecoration: "none",
    color: "#2563eb",
    fontWeight: 700,
  },
  button: {
    border: "none",
    borderRadius: "999px",
    backgroundColor: "#0f172a",
    color: "#ffffff",
    padding: "0.6rem 1rem",
    fontWeight: 700,
    cursor: "pointer",
  },
};
