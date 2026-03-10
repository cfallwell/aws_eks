import React from "react";
import { Link, useParams } from "react-router-dom";
import type { Product } from "./App";

interface Props {
  products: Product[];
  onAddToCart: (product: Product) => void;
}

const LOREM = `Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. 
Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris.`;

export default function ProductDetail({ products, onAddToCart }: Props) {
  const params = useParams();
  const id = Number(params.id);
  const product = products.find((p) => p.id === id);

  if (!product) {
    return (
      <div>
        <h2>Product not found</h2>
        <p>
          <Link to="/">Back to products</Link>
        </p>
      </div>
    );
  }

  return (
    <div style={styles.wrapper}>
      <p style={{ marginTop: 0 }}>
        <Link to="/">← Back to products</Link>
      </p>

      <div style={styles.card}>
        <img src={product.image} alt={product.name} style={styles.image} />
        <div style={styles.content}>
          <h2 style={{ marginTop: 0 }}>{product.name}</h2>
          <p style={styles.price}>${product.price.toFixed(2)}</p>
          <p>{LOREM}</p>
          <p>{LOREM}</p>

          <button type="button" onClick={() => onAddToCart(product)} style={styles.button}>
            Add to Cart
          </button>
        </div>
      </div>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  wrapper: {
    display: "flex",
    flexDirection: "column",
    gap: "1rem",
  },
  card: {
    display: "grid",
    gridTemplateColumns: "minmax(220px, 360px) 1fr",
    gap: "1rem",
    backgroundColor: "#ffffff",
    borderRadius: "0.75rem",
    padding: "1rem",
    boxShadow: "0 1px 2px rgba(0,0,0,0.06)",
  },
  image: {
    width: "100%",
    borderRadius: "0.5rem",
    objectFit: "cover",
  },
  content: {},
  price: {
    fontWeight: "bold",
    marginTop: "0.25rem",
  },
  button: {
    marginTop: "0.75rem",
    padding: "0.5rem 0.75rem",
    borderRadius: "0.375rem",
    border: "none",
    backgroundColor: "#2563eb",
    color: "#ffffff",
    cursor: "pointer",
    fontWeight: 600,
  },
};
