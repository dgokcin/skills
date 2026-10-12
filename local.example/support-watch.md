# Support Watch Config

## Channels

| Channel ID | Name |
|------------|------|
| `C0XXXXXXXXX` | `#team-help` |

## People

| Constant | Value |
|----------|-------|
| **My Slack ID** | `U0XXXXXXXXX` |
| **Teammate Slack IDs** | `U0AAAAAAAAA`, `U0BBBBBBBBB` |
| **Bots treated as alerts** | (none) |

## Team ownership

What the team owns. Triage matches requests against this list.

- Kubernetes clusters, ingress, autoscaling
- AWS accounts, IAM, networking
- CI/CD pipelines, ArgoCD, deploys
- Observability (Datadog agents, monitors)

Not ours (skip unless someone tags the team):

- product feature questions
- frontend bugs

## Notification

| Setting | Value |
|---------|-------|
| **Sound** | `/System/Library/Sounds/Glass.aiff` |
| **speak** | `false` |
| **First-run lookback** | `60m` |
