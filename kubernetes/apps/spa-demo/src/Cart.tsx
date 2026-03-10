import React from "react";
import type { CartItem } from "./App";

interface Props {
  items: CartItem[];
  onUpdateQuantity: (productId: number, delta: number) => void;
  onDelete: (productId: number) => void;
}

export default function Cart({ items, onUpdateQuantity, onDelete }: Props) {
  const totalPrice = items.reduce((sum, item) => sum + item.price * item.quantity, 0);

  if (items.length === 0) {
    return <p>Your cart is empty. Go add some products!</p>;
  }

  return (
    <div>
      <h2>Your Cart</h2>
      <table style={styles.table}>
        <thead>
          <tr>
            <th style={styles.th}>Product</th>
            <th style={styles.th}>Price</th>
            <th style={styles.th}>Quantity</th>
            <th style={styles.th}>Subtotal</th>
            <th style={styles.th}>Actions</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item) => (
            <tr key={item.id}>
              <td style={styles.td}>{item.name}</td>
              <td style={styles.td}>${item.price.toFixed(2)}</td>
              <td style={styles.td}>
                <button type="button" onClick={() => onUpdateQuantity(item.id, -1)} style={styles.qtyButton}>-</button>
                <span style={styles.qty}>{item.quantity}</span>
                <button type="button" onClick={() => onUpdateQuantity(item.id, 1)} style={styles.qtyButton}>+</button>
              </td>
              <td style={styles.td}>${(item.price * item.quantity).toFixed(2)}</td>
              <td style={styles.td}>
                <button type="button" onClick={() => onDelete(item.id)} style={styles.deleteButton}>Delete</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <p style={styles.total}>Total: ${totalPrice.toFixed(2)}</p>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  table: { width: "100%", borderCollapse: "collapse", marginBottom: "1rem" },
  th: { textAlign: "left", borderBottom: "1px solid #e5e7eb", padding: "0.5rem" },
  td: { padding: "0.5rem", borderBottom: "1px solid #f3f4f6" },
  qtyButton: { padding: "0.25rem 0.5rem", margin: "0 0.25rem" },
  qty: { minWidth: "2rem", display: "inline-block", textAlign: "center" },
  deleteButton: {
    padding: "0.25rem 0.5rem",
    borderRadius: "0.25rem",
    border: "none",
    backgroundColor: "#ef4444",
    color: "#ffffff",
    cursor: "pointer",
  },
  total: { fontWeight: "bold", textAlign: "right" },
};
