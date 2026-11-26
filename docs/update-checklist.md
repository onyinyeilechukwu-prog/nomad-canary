# Checklist: reviewing the `update` settings of a Nomad job

1. Is there an `update` block at all?
2. Is `auto_revert = true`?
3. Does the job have a real health check (`check` in the `service` block)?
4. Does the health check test the page or port that proves the app works?
5. Is `canary` set (a count, not a percent)?
6. If `canary` is set, is `auto_promote` decided on purpose?
7. Is `healthy_deadline` longer than the app's real start time?
8. Is `min_healthy_time` long enough to catch a copy that starts and then breaks?
9. Is `progress_deadline` a time the team is willing to wait for a bad deploy to roll back?
10. Is `max_parallel` sensible for the size of the group?
11. Do `restart` and `reschedule` fit with the deadlines?
12. Does the CI deploy step fail when the deploy fails?
13. Was the rollback tested with a deliberately broken deploy, and was the time written down?
