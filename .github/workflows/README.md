# GitHub Actions Workflows

This directory contains CI/CD workflows for the Opal-Vite project.

## Workflows

### `test.yml` - Continuous Integration

Runs on every push and pull request to ensure code quality.

**Jobs:**
1. **test-plugin** - Tests the vite-plugin-opal package
2. **test-practical-app** - Runs E2E tests for practical-app example
3. **test-chart-app** - Runs E2E tests for chart-app example (when enabled)
4. **build-examples** - Builds all example applications to verify they compile

**Triggers:**
- Push to `main` or `master` branch
- Pull requests to `main` or `master` branch

### `deploy.yml` - Deployment

Deploys documentation and examples to hosting platforms.

**Jobs:**
1. **deploy-docs** - Deploys documentation to GitHub Pages
2. **deploy-examples** - Deploys example apps to Vercel/Netlify

**Triggers:**
- Push to `main` or `master` branch
- Manual trigger via GitHub UI (`workflow_dispatch`)

**Required Secrets:**
- `VERCEL_TOKEN` - Vercel authentication token
- `VERCEL_ORG_ID` - Vercel organization ID
- `VERCEL_PROJECT_ID` - Vercel project ID
- `NETLIFY_AUTH_TOKEN` - Netlify authentication token
- `NETLIFY_SITE_ID` - Netlify site ID

### `release.yml` - Release Automation

Publishes new versions to npm and RubyGems.

**Jobs:**
1. **release** - Publishes vite-plugin-opal to npm
2. **publish-gem** - Publishes opal-vite gem to RubyGems

**Triggers:**
- Push of version tags (e.g., `v1.0.0`, `v2.1.3`)

**Required Secrets:**
- `NPM_TOKEN` - npm authentication token
- `RUBYGEMS_API_KEY` - RubyGems API key

## Setup Instructions

### 1. Enable GitHub Actions

GitHub Actions is enabled by default for public repositories. For private repositories:

1. Go to repository Settings → Actions → General
2. Enable "Allow all actions and reusable workflows"

### 2. Configure Secrets

Add required secrets in repository Settings → Secrets and variables → Actions:

#### For npm Publishing
```bash
# Generate npm token at https://www.npmjs.com/settings/{username}/tokens
NPM_TOKEN=npm_xxxxxxxxxxxx
```

#### For RubyGems Publishing
```bash
# Get API key from https://rubygems.org/profile/api_keys
RUBYGEMS_API_KEY=rubygems_xxxxxxxx
```

#### For Vercel Deployment
```bash
# Get from Vercel dashboard
VERCEL_TOKEN=xxxxxx
VERCEL_ORG_ID=team_xxxxxx
VERCEL_PROJECT_ID=prj_xxxxxx
```

#### For Netlify Deployment
```bash
# Get from Netlify dashboard
NETLIFY_AUTH_TOKEN=xxxxxx
NETLIFY_SITE_ID=xxxxxx
```

### 3. Customize Workflows

Edit the workflow files to match your needs:

**Change Node.js version:**
```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '20'  # Change to desired version
```

**Change Ruby version:**
```yaml
- name: Setup Ruby
  uses: ruby/setup-ruby@v1
  with:
    ruby-version: '3.3'  # Change to desired version
```

**Add/remove examples:**
```yaml
strategy:
  matrix:
    example:
      - stimulus-app
      - practical-app
      # Add your new example here
```

### 4. Local Testing

Test workflows locally using [act](https://github.com/nektos/act):

```bash
# Install act
brew install act  # macOS
# or
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Run a specific workflow
act -W .github/workflows/test.yml

# Run a specific job
act -j test-practical-app

# Use specific secrets
act -s NPM_TOKEN=xxx -W .github/workflows/release.yml
```

## Workflow Status Badges

Add status badges to your README.md:

```markdown
![Tests](https://github.com/yourusername/opal-vite/workflows/Tests/badge.svg)
![Deploy](https://github.com/yourusername/opal-vite/workflows/Deploy/badge.svg)
```

## Best Practices

### 1. Cache Dependencies

All workflows use pnpm caching to speed up builds:

```yaml
- name: Setup pnpm cache
  uses: actions/cache@v3
  with:
    path: ${{ steps.pnpm-cache.outputs.STORE_PATH }}
    key: ${{ runner.os }}-pnpm-store-${{ hashFiles('**/pnpm-lock.yaml') }}
```

### 2. Parallel Jobs

Tests run in parallel using matrix strategy:

```yaml
strategy:
  matrix:
    example: [app1, app2, app3]
```

### 3. Artifact Upload

Test results and build artifacts are preserved:

```yaml
- name: Upload test results
  if: always()
  uses: actions/upload-artifact@v3
  with:
    name: playwright-report
    path: playwright-report/
    retention-days: 30
```

### 4. Conditional Execution

Jobs run only when needed:

```yaml
if: github.event_name == 'push' && github.ref == 'refs/heads/master'
```

### 5. Manual Triggers

Allow manual workflow execution:

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        type: choice
        options:
          - staging
          - production
```

## Troubleshooting

### Workflow not running

**Check:**
- Workflow file is in `.github/workflows/`
- Workflow has correct trigger (`on:` section)
- Branch protection rules allow Actions

### Tests failing

**Check:**
- Tests pass locally: `pnpm test`
- Dependencies are installed: Check "Install dependencies" step
- Browsers are installed: Check "Install Playwright" step
- Ports are available: Use different ports if needed

### Deployment failing

**Check:**
- Secrets are configured correctly
- API tokens are valid and not expired
- Target platform (Vercel/Netlify) is accessible
- Build output is in correct directory

### Cache issues

Clear cache manually:

1. Go to Actions tab
2. Click "Caches" in left sidebar
3. Delete problematic caches

Or disable caching temporarily:

```yaml
# Comment out or remove the cache step
# - name: Setup pnpm cache
#   uses: actions/cache@v3
#   ...
```

## Advanced Configuration

### Run tests on schedule

```yaml
on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight
```

### Deploy to multiple environments

```yaml
strategy:
  matrix:
    environment:
      - staging
      - production
```

### Slack notifications

```yaml
- name: Notify Slack
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Code coverage

```yaml
- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
```

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Available Actions](https://github.com/marketplace?type=actions)
- [GitHub Actions Community](https://github.community/c/code-to-cloud/github-actions)
