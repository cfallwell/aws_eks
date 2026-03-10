import type { CSSProperties } from "react";
import { Link, useParams } from "react-router-dom";
import type { Product } from "../lib/types";

interface ProductDetailProps {
  products: Product[];
  onAddToCart: (product: Product) => void;
}

export default function ProductDetail({ products, onAddToCart }: ProductDetailProps) {
  const { slug } = useParams();
  const product = products.find((item) => item.slug === slug);

  if (!product) {
    return (
      <section>
        <h2>Product not found</h2>
        <Link to="/">Back to catalog</Link>
      </section>
    );
  }

  return (
    <section style={styles.layout}>
      <img src={product.imageUrl} alt={product.name} style={styles.image} />
      <div style={styles.panel}>
        <Link to="/" style={styles.backLink}>
          Back to catalog
        </Link>
        <h2 style={styles.title}>{product.name}</h2>
        <p style={styles.price}>${product.price.toFixed(2)}</p>
        <p style={styles.copy}>{product.description}</p>
        <p style={styles.stock}>Inventory available: {product.inventory}</p>
        <button type="button" onClick={() => onAddToCart(product)} style={styles.button}>
          Add to cart
        </button>
      </div>
    </section>
  );
}

const styles: Record<string, CSSProperties> = {
  layout: {
    display: "grid",
    gridTemplateColumns: "minmax(260px, 420px) 1fr",
    gap: "1.5rem",
    alignItems: "start",
  },
  image: {
    width: "100%",
    borderRadius: "1rem",
    backgroundColor: "#e2e8f0",
  },
  panel: {
    backgroundColor: "#ffffff",
    borderRadius: "1rem",
    padding: "1.25rem",
    boxShadow: "0 12px 32px rgba(15, 23, 42, 0.08)",
  },
  backLink: {
    color: "#2563eb",
    textDecoration: "none",
    fontWeight: 700,
  },
  title: {
    marginBottom: "0.5rem",
    color: "#0f172a",
  },
  price: {
    fontSize: "1.25rem",
    fontWeight: 700,
    color: "#0f172a",
  },
  copy: {
    color: "#475569",
    lineHeight: 1.6,
  },
  stock: {
    color: "#0f766e",
    fontWeight: 700,
  },
  button: {
    marginTop: "0.75rem",
    border: "none",
    borderRadius: "999px",
    backgroundColor: "#0f172a",
    color: "#ffffff",
    padding: "0.75rem 1.25rem",
    fontWeight: 700,
    cursor: "pointer",
  },
};
