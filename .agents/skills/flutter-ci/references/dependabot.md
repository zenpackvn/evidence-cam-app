# CI — `.github/dependabot.yml`

Weekly checks for pub dependencies and GitHub Actions versions.

```yaml
version: 2

updates:
  # Pub dependencies
  - package-ecosystem: "pub"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
    open-pull-requests-limit: 5
    labels:
      - "dependencies"
    commit-message:
      prefix: "deps"

  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
    open-pull-requests-limit: 5
    labels:
      - "ci"
    commit-message:
      prefix: "ci"
```
