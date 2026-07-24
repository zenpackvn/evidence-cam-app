# CI — Branch Protection Guidance

Configure these settings in **GitHub > Settings > Branches > Branch protection rules** for `main`:

- **Require a pull request before merging** — at least 1 approving review.
- **Require status checks to pass before merging** — select:
  - `Analyze & Format`
  - `Test & Coverage`
  - `Build Check`
- **Require branches to be up to date before merging** — prevents merging stale PRs.
- **Do not allow bypassing the above settings** — applies to admins too.
