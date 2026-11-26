# Runbook: a deploy went bad, what do I do

Service: `demo` on Nomad. Deploys run from GitHub Actions (job `deploy`, on the self-hosted runner labelled `nomad-lab`).

## 1. How you know a deploy went bad

- The `deploy` job in GitHub Actions is red. `nomad job run` exits with an error when the deployment does not succeed.
- Or: `nomad job status demo` shows a latest deployment with `Unhealthy` above 0, or a status of `failed`.

## 2. Check for more information

```bash

| Command | What it tells you |
|---|---|
| `nomad job status demo` | The latest deployment and the running copies |
| `nomad job deployments demo` | Every deployment and why it failed |
| `nomad job history demo` | Every version. `Stable = true` means that version was healthy |

## 3. If Nomad is already rolling back

If the  job has `auto_revert = true`. When a deployment fails, Nomad creates a new version with the last good settings by itself.
Do nothing and wait, unless the progress time is way past and nothing has happeed.

## 4. Roll back by hand (faster)

1. Find the last stable version number (the newest one with `Stable = true`) from the history command above.
2. Run:

```bash
time nomad job revert demo <version>
```


3. Check: `nomad job status demo` shows a successful latest deployment and one running copy.

Notes:
- A revert creates a new version number (reverting to 4 created version 6). It does not delete the broken one.
- If you revert while a deploy is still running, that deployment is cancelled and the `deploy` job in GitHub turns red. That is expected.

## 5. Find the cause (after the service is safe)

```bash
nomad alloc status <alloc-id>
```

Look at `Recent Events` and the health check. Not tried in the lab: `nomad alloc logs <alloc-id>` for the app's own output.
Common causes to check: wrong health check path, wrong image tag, app not listening on the expected port.



