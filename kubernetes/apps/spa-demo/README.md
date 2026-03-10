# SPA Demo

`spa-demo` is now a real application bundle with:

- a React SPA frontend
- a Node.js API layer
- a PostgreSQL backend on Amazon RDS

## Local workflow

```bash
cd kubernetes/apps/spa-demo
npm install
npm run build
```

The build produces:

- `dist/` for local preview and runtime assets
- `app/bundle/` for Flux/Kustomize deployment payloads
