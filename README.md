# SuiteCRM Docker Wrapper

Containerized wrapper for running and customizing SuiteCRM locally. Core is fetched on demand; you commit only your custom/ overrides and tooling.

## Repo Layout

```text
/script/
  download_suitecrm        # fetch SuiteCRM into public/legacy/
/scripts/
  start                    # start services
  stop                     # stop services
/public/legacy/            # SuiteCRM core (generated)
/public/legacy/custom/     # your overrides (commit this)
/.devcontainer/            # VS Code Dev Container
docker-compose.yml         # stack definition
```

## Prerequisites

- Docker + Docker Compose

- VS Code + Dev Containers extension

## Quick Start

### 1) Download SuiteCRM core

- run `./script/download_suitecrm`

#### 2) Open in Dev Container

- VS Code → “Reopen in Container”

### 3) Start services

- run `./scripts/start`
