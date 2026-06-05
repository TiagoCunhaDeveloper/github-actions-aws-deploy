# github-actions-aws-deploy

Minimal [NestJS](https://nestjs.com/) service exposing a single healthcheck
endpoint. It is intentionally small — its purpose is to be the base application
for a complete CI/CD pipeline that builds a Docker image and deploys to
**AWS ECS Fargate** via **GitHub Actions**.

## Stack

- NestJS 11 (Express) + TypeScript
- `@nestjs/terminus` for health checks
- Multi-stage Docker build, runs as a non-root user
- Node.js 20

## Endpoints

| Method | Path      | Description                                         |
| ------ | --------- | --------------------------------------------------- |
| `GET`  | `/health` | Terminus healthcheck (heap memory). Returns `200` when healthy. |

Example response:

```json
{
  "status": "ok",
  "info": { "memory_heap": { "status": "up" } },
  "error": {},
  "details": { "memory_heap": { "status": "up" } }
}
```

## Getting started

```bash
npm install
cp .env.example .env      # optional, only to override PORT
npm run start:dev         # http://localhost:3000/health
```

## Useful scripts

| Script                | What it does                          |
| --------------------- | ------------------------------------- |
| `npm run start:dev`   | Run in watch mode                     |
| `npm run build`       | Compile to `dist/`                    |
| `npm run start:prod`  | Run the compiled build                |
| `npm test`            | Unit tests                            |
| `npm run lint`        | Lint & autofix                        |

## Docker

```bash
docker build -t github-actions-aws-deploy .
docker run --rm -p 3000:3000 github-actions-aws-deploy
curl http://localhost:3000/health
```

The image is multi-stage (build deps are dropped), runs as the unprivileged
`node` user, and declares a `HEALTHCHECK` against `/health`.

## Next step: the pipeline

This repo is ready to be wired to a GitHub Actions workflow that:

1. Installs deps, lints and tests.
2. Builds the Docker image and pushes it to **Amazon ECR**.
3. Renders a new **ECS task definition** and deploys it to **Fargate**.

Authentication to AWS should use **OIDC** (GitHub → IAM role), not long-lived
access keys.
