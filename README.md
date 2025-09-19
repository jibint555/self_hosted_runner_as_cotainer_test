#GitHub Actions self-hosted runner in a container:

# self_hosted_runner_as_cotainer_test

```# Self-Hosted GitHub Actions Runner (Docker)

This repository contains a Docker-based setup for running a **self-hosted GitHub Actions runner**. It can be used to run workflows for your repository or organization, giving you full control over the environment.

---

## Features

- Runs GitHub Actions workflows in a **containerized environment**
- Supports repository-level or organization-level runners
- Automatically installs dependencies, including **.NET Core**, `libicu`, `jq`, and Docker CLI integration
- Configurable runner name and labels
- Persistent `_work` directory to retain workspace between jobs
- Automatic runner updates

---

## Prerequisites

- Docker installed on your host machine
- GitHub repository or organization where you want to register the runner
- Personal Access Token or GitHub App token for repository/organization registration

---

## Getting Started

### 1. Clone this repository

```bash
git clone https://github.com/<username>/<repo>.git
cd <repo>```
