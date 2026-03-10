# SPA Demo

Self-contained React SPA that is built into `dist/` and served in-cluster by nginx.

## Run locally

From the repo root:

```bash
cd kubernetes/apps/spa-demo
npm install
npm run dev
```

## Build for Flux

```bash
cd kubernetes/apps/spa-demo
npm install
npm run build
```

## Routes for testing

Includes extra routes (About/Support/Terms) and `/product/:id` to validate client-side route-change tracking.
