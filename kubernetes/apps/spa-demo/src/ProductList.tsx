import React from "react";
import { Link } from "react-router-dom";
import type { Product } from "./App";

interface Props {
  products: Product[];
  onAddToCart: (product: Product) => void;
}

export default function ProductList({ products, onAddToCart }: Props) {
  return (
    <div style={styles.grid}>
      {products.map((product) => (
        <article key={product.id} style={styles.card}>
          <Link to={`/product/${product.id}`} style={styles.link}>
            <img src={product.image} alt={product.name} style={styles.image} />
            <h2 style={styles.title}>{product.name}</h2>
          </Link>

          <p style={styles.price}>${product.price.toFixed(2)}</p>

          <div style={styles.actions}>
            <Link to={`/product/${product.id}`} style={styles.detailsLink}>
              View details
            </Link>
            <button type="button" onClick={() => onAddToCart(product)} style={styles.button}>
              Add to Cart
            </button>
          </div>
        </article>
      ))}
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  grid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
    gap: "1rem",
  },
  card: {
    backgroundColor: "#ffffff",
    borderRadius: "0.75rem",
    padding: "0.75rem",
    boxShadow: "0 1px 2px rgba(0,0,0,0.06)",
    display: "flex",
    flexDirection: "column",
    alignItems: "stretch",
  },
  link: {
    textDecoration: "none",
    color: "inherit",
  },
  image: {
    width: "100%",
    borderRadius: "0.5rem",
    marginBottom: "0.5rem",
    objectFit: "cover",
    background: "#f3f4f6",
  },
  title: {
    fontSize: "1rem",
    margin: "0.25rem 0",
  },
  price: {
    fontWeight: 700,
    margin: "0.25rem 0 0.5rem",
  },
  actions: {
    marginTop: "auto",
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    gap: "0.5rem",
  },
  detailsLink: {
    textDecoration: "none",
    color: "#2563eb",
    fontWeight: 600,
    fontSize: "0.9rem",
  },
  button: {
    padding: "0.5rem 0.75rem",
    borderRadius: "0.375rem",
    border: "none",
    backgroundColor: "#2563eb",
    color: "#ffffff",
    cursor: "pointer",
    fontWeight: 600,
    whiteSpace: "nowrap",
  },
};
