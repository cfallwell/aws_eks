export interface Product {
  id: number;
  slug: string;
  name: string;
  description: string;
  price: number;
  imageUrl: string;
  inventory: number;
}

export interface CartItem extends Product {
  quantity: number;
}
