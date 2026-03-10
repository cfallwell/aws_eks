import type { Product } from "./types";

export async function fetchProducts(): Promise<Product[]> {
  const response = await fetch("/api/products");

  if (!response.ok) {
    throw new Error(`Failed to load products (${response.status})`);
  }

  return (await response.json()) as Product[];
}
