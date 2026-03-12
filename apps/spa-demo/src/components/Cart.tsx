import type { CSSProperties } from "react";
import type { CartItem } from "../lib/types";

interface CartProps {
  items: CartItem[];
  onUpdateQuantity: (productId: number, delta: number) => void;
}

export default function Cart({ items, onUpdateQuantity }: CartProps) {
  if (items.length === 0) {
    return <p style={{ margin: 0 }}>Your cart is empty.</p>;
  }

  const total = items.reduce((sum, item) => sum + item.quantity * item.price, 0);

  return (
    <section style={styles.wrap}>
      {items.map((item) => (
        <div key={item.id} style={styles.row}>
          <div>
            <strong>{item.name}</strong>
            <p style={styles.meta}>${item.price.toFixed(2)} each</p>
          </div>
          <div style={styles.controls}>
            <button type="button" onClick={() => onUpdateQuantity(item.id, -1)} style={styles.button}>
              -
            </button>
            <span>{item.quantity}</span>
            <button type="button" onClick={() => onUpdateQuantity(item.id, 1)} style={styles.button}>
              +
            </button>
          </div>
        </div>
      ))}
      <div style={styles.total}>Total: ${total.toFixed(2)}</div>
    </section>
  );
}

const styles: Record<string, CSSProperties> = {
  wrap: {
    display: "flex",
    flexDirection: "column",
    gap: "0.75rem",
  },
  row: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    gap: "1rem",
    padding: "0.75rem 0",
    borderBottom: "1px solid #e2e8f0",
  },
  meta: {
    margin: "0.25rem 0 0",
    color: "#64748b",
  },
  controls: {
    display: "flex",
    alignItems: "center",
    gap: "0.75rem",
  },
  button: {
    width: "2rem",
    height: "2rem",
    borderRadius: "999px",
    border: "1px solid #cbd5e1",
    backgroundColor: "#ffffff",
    cursor: "pointer",
  },
  total: {
    marginTop: "0.5rem",
    fontWeight: 800,
    textAlign: "right",
  },
};
