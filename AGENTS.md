# AGENTS.md

## Cursor Cloud specific instructions

### What is runnable here

The runnable product is the **`apps/spa-demo`** web app: a React SPA (Vite) + a
Node.js/Express API (`server/index.ts`) backed by **PostgreSQL**. The
`terraform/`, `charts/`, and Argo CD assets provision real AWS infrastructure
(EKS, RDS, ALB, IRSA/S3) and cannot be applied from the cloud VM (no AWS
credentials, and they create live cloud resources). Treat infra as
deploy-tooling, not something to run here.

### PostgreSQL (required for the API)

PostgreSQL 16 is installed in the VM snapshot. A dev database/role already
exists: database `spa_demo`, role `spa_demo` / password `spa_demo`. The server
cluster does not auto-start — start it each session:

```bash
sudo pg_ctlcluster 16 main start   # idempotent; safe if already running
```

The API reads `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`,
`DB_SSLMODE`. Local Postgres has no TLS, so set `DB_SSLMODE=disable` (the default
is `require`, which fails locally). On first boot the server auto-creates the
`products` table and seeds 5 rows (`ensureSchema()` in `server/index.ts`), so no
manual migration is needed.

### Private dependency + registry (needed for npm install / dev / build / lint)

`apps/spa-demo` depends on `@cfallwell/rumbootstrap`, a **private** package on
**GitHub Packages** (`npm.pkg.github.com`, scoped via `apps/spa-demo/.npmrc`).
Everything else resolves from the **public** npm registry
(`registry.npmjs.org`); the lockfile no longer references Splunk's internal
`repo.splunkdev.net` Artifactory (which is not reachable here).

Provide the secret `NODE_AUTH_TOKEN` so npm can fetch the private package. Auth
is wired via a user-level `~/.npmrc` (created during setup, not tracked):
`//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}`. Token requirements:

- It MUST be a **classic** PAT (`ghp_...`) with `read:packages`.
  `npm.pkg.github.com` rejects **fine-grained** PATs (`github_pat_...`) with
  `403 ... token does not match expected scopes`.
- The token's account MUST have read access to the package. It is owned by the
  **user** `cfallwell` (not an org), so the token must belong to `cfallwell` (or
  an account it has granted access). The `git` remote's `ghs_` installation
  token does NOT have package read access.

With the token set, both `npm install` and `npm ci` work (lockfile is in sync).

Version note: `package.json` pins `@cfallwell/rumbootstrap@1.0.3` (the latest
version actually published to GitHub Packages: only `1.0.0`–`1.0.3` exist). The
previously pinned `3.0.0` was never published anywhere, so it could not install.
Building against `1.0.3` pulls the full Splunk RUM library, so the built
`dist/assets/app.js` is much larger (~1.3 MB) than the committed artifact
(~173 KB, which was produced from the unpublished lightweight `3.0.0`). The
regenerated build outputs are intentionally NOT committed here.

Note: `src/lib/rumbootstrap.tsx` is an unused local mirror of that package's API;
the source imports the real package (`@cfallwell/rumbootstrap`), not this file.

### Running the app locally

There is a committed prebuilt bundle in `apps/spa-demo/dist/` (`server.cjs` plus
`index.html`/`assets`/`images`), so you can run the app end-to-end WITHOUT
installing node_modules — only Postgres is required.

Important layout gotcha: the server resolves static files from
`path.join(__dirname, "dist")`. In the Kubernetes container the layout is
`/app/server.cjs` + `/app/dist/<site>`, i.e. the site lives in a `dist/`
subdirectory **next to** `server.cjs`. The committed `dist/` folder instead has
`server.cjs` and the site files at the same level, so running
`node dist/server.cjs` directly serves the API but not the static site. To run
correctly, mirror the container layout, e.g.:

```bash
RUN=/tmp/spa-demo-run
rm -rf "$RUN" && mkdir -p "$RUN/dist/assets" "$RUN/dist/images"
cp apps/spa-demo/dist/server.cjs "$RUN/server.cjs"
cp apps/spa-demo/dist/index.html "$RUN/dist/index.html"
cp apps/spa-demo/dist/assets/app.js "$RUN/dist/assets/app.js"
cp apps/spa-demo/dist/images/*.svg "$RUN/dist/images/"
cd "$RUN"
PORT=3000 DB_HOST=127.0.0.1 DB_PORT=5432 DB_NAME=spa_demo DB_USER=spa_demo \
  DB_PASSWORD=spa_demo DB_SSLMODE=disable node server.cjs
```

Then the API is at `GET /api/health`, `GET /api/products`, and the SPA is at `/`.
`npm start` (`node dist/server.cjs`) has the same path caveat; prefer the mirror
layout above, or rebuild with `npm run build` (needs the token) which regenerates
`dist/` and the `charts/spa-demo/files/` payload via `scripts/sync-dist.mjs`.

Vite dev (`npm run dev`, port 5173) serves only the UI — there is no proxy to the
API, so `/api/*` fetches will fail in pure dev mode. Use the bundled server above
(or run the built server alongside) for full-stack behavior.

### Lint / build

- Lint: `cd apps/spa-demo && npm run lint` (`tsc --noEmit` for `src` and
  `server`). Requires deps installed (needs `NODE_AUTH_TOKEN`).
- Build: `cd apps/spa-demo && npm run build` (Vite build + esbuild-bundled
  server + `sync-dist`). Requires deps installed.
