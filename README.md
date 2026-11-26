# nomad-canary

A demo service that deploys to Nomad as a canary and rolls back by itself when its health check fails.

Push to `main` -> GitHub Actions builds and pushes the image -> a self-hosted runner deploys it to Nomad -> Nomad starts a canary, waits for it to be healthy, promotes it, or rolls back.

## What is in the repo

| Path | What it is |
|---|---|
| `app/` | The demo service (nginx with a `/health` page) and its Dockerfile |
| `nomad/demo.nomad.hcl` | The Nomad job: canary, auto revert, Consul health check |
| `.github/workflows/ci.yml` | Build, test, push the image, then deploy |
| `scripts/setup.sh` | One-command lab setup |
| `docs/runbook.md` | A deploy went bad, what do I do |
| `docs/update-checklist.md` | Questions for reviewing any Nomad job's `update` settings |
| `evidence/` | Screenshots from the lab demo: the broken deploy, the rollback and the CI result |

## You need

- Linux or WSL2, with Docker, Nomad and Consul installed (the lab used Nomad 2.1.1 and Consul 2.1.0)
- A GitHub repo with Actions on, and its own container registry (the lab used GHCR)

## One-command setup

```bash
scripts/setup.sh <image-tag>
```

This starts Consul and Nomad in dev mode if they are not running, waits until they are ready, and deploys the job. The image tag is a commit ID that CI has already built and pushed (for example `git rev-parse HEAD` on `main`).

If you use your own registry, change the image name in `nomad/demo.nomad.hcl`.

## Connect the pipeline (once)

## Try a broken deploy

1. In the repo: Settings > Secrets and variables > Actions > Variables. Add `HEALTH_PATH` with the value `/missing`.
2. Re-run the latest workflow run. The health check now asks for a page that does not exist.
3. Watch: `nomad job status demo` and `nomad job deployments demo`. The deployment fails, Nomad rolls back by itself, and the `deploy` job turns red.
4. To roll back by hand instead: see `docs/runbook.md`.
5. Delete the `HEALTH_PATH` variable when you are done.

In my lab, the automatic rollback took about 10 minutes and a manual `nomad job revert` took about 14 seconds.
