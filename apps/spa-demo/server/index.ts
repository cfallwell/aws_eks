import express from "express";
import path from "node:path";
import { Pool } from "pg";

const port = Number(process.env.PORT ?? "3000");
const distDir = path.join(__dirname, "dist");
const sslMode = (process.env.DB_SSLMODE ?? process.env.PGSSLMODE ?? "require").toLowerCase();

function getSslConfig() {
  switch (sslMode) {
    case "disable":
      return false;
    case "no-verify":
    case "allow":
    case "prefer":
    case "require":
    default:
      return { rejectUnauthorized: false };
  }
}

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT ?? "5432"),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: getSslConfig(),
});

const seedProducts = [
  {
    slug: "noise-cancelling-headphones",
    name: "Noise-Cancelling Headphones",
    description: "Wireless over-ear headphones with adaptive ANC and all-day battery life.",
    price: 199.99,
    image_url: "/images/product-1.svg",
    inventory: 18,
  },
  {
    slug: "smart-watch",
    name: "Smart Watch",
    description: "Fitness tracking, notifications, and a bright AMOLED display.",
    price: 149.99,
    image_url: "/images/product-2.svg",
    inventory: 27,
  },
  {
    slug: "wireless-mouse",
    name: "Wireless Mouse",
    description: "Ergonomic mouse with low-latency Bluetooth and USB receiver support.",
    price: 39.99,
    image_url: "/images/product-3.svg",
    inventory: 42,
  },
  {
    slug: "mechanical-keyboard",
    name: "Mechanical Keyboard",
    description: "Hot-swappable keyboard with tactile switches and per-key backlighting.",
    price: 89.99,
    image_url: "/images/product-4.svg",
    inventory: 13,
  },
  {
    slug: "4k-monitor",
    name: "4K Monitor",
    description: "27-inch display with USB-C docking and HDR-ready color reproduction.",
    price: 329.99,
    image_url: "/images/product-5.svg",
    inventory: 8,
  },
];

async function ensureSchema() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS products (
      id SERIAL PRIMARY KEY,
      slug TEXT NOT NULL UNIQUE,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      price NUMERIC(10, 2) NOT NULL,
      image_url TEXT NOT NULL,
      inventory INTEGER NOT NULL DEFAULT 0
    )
  `);

  const { rows } = await pool.query("SELECT COUNT(*)::int AS count FROM products");

  if (rows[0]?.count === 0) {
    for (const product of seedProducts) {
      await pool.query(
        `
          INSERT INTO products (slug, name, description, price, image_url, inventory)
          VALUES ($1, $2, $3, $4, $5, $6)
        `,
        [
          product.slug,
          product.name,
          product.description,
          product.price,
          product.image_url,
          product.inventory,
        ]
      );
    }
  }
}

const app = express();
app.use(express.json());

app.get("/api/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ status: "ok" });
  } catch (error) {
    res.status(500).json({ status: "error", message: (error as Error).message });
  }
});

app.get("/api/products", async (_req, res, next) => {
  try {
    const result = await pool.query(
      `
        SELECT id, slug, name, description, price::float8 AS price, image_url AS "imageUrl", inventory
        FROM products
        ORDER BY id
      `
    );

    res.json(result.rows);
  } catch (error) {
    next(error);
  }
});

app.use(express.static(distDir));
app.get("*", (_req, res) => {
  res.sendFile(path.join(distDir, "index.html"));
});

app.use((error: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error(error);
  res.status(500).json({ message: "Unexpected server error" });
});

ensureSchema()
  .then(() => {
    app.listen(port, () => {
      console.log(`spa-demo listening on ${port}`);
    });
  })
  .catch((error) => {
    console.error("Failed to initialize database", error);
    process.exit(1);
  });
