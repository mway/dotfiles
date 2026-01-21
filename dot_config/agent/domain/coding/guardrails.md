# Mode Guardrails

This document defines the specific guardrails, limits, and safety mechanisms for each operating mode (normal/autopilot/full-auto) in the coding skill.

---

## Overview

Guardrails prevent catastrophic mistakes and ensure safe operation across all modes. They provide:
- **Operation limits** (file counts, line counts, time limits)
- **Absolute restrictions** (never-auto operations)
- **Recovery mechanisms** (checkpoints, rollback, audit logs)

---

## Normal Mode

**Philosophy**: Maximum safety. Confirm before all modifications.

### Confirmation Required For

**ALL operations in Tier 1, 2, and 3:**
- All file modifications (create, edit, delete)
- All git operations (commit, push, merge, rebase)
- All external system interactions
- Package management operations

**Automatic:**
- Tier 4 (read-only) operations only

### UX Pattern

```
I plan to make the following changes:
1. Edit /path/to/file.go (modify lines 42-50)
2. Create new test file /path/to/file_test.go
3. Run tests with: go test -race -count 1 ./...

Would you like to:
[P]roceed  [D]iff  [S]kip  [A]bort

Choice: _
```

### Limits

- No automatic operations beyond read-only
- No file count limit (user controls via confirmation)
- No line count limit (user controls via confirmation)

---

## Autopilot Mode

**Philosophy**: Balanced autonomy. Auto-proceed for safe operations, confirm for risky ones.

### Confirmation Required For

**Tier 1 operations (always):**
- Force push to protected branches (main/master)
- Credential/secret operations
- Production deployments
- Database migrations on prod

**Tier 2 operations (always in autopilot):**
- Git commits (`git commit`, `git commit --amend`) — never auto-run
- Git operations affecting remote (`push`, `force` anything)
- File deletions
- Non-deterministic line edits (manual edits/refactors)
- Package management (`go mod tidy`, `npm install`, `pip install`, `cargo update`)
- Mass modifications (>10 files OR >100 lines per file in single operation)

### Automatic

**All Tier 3 (deterministic):**
- Code additions (new files, new functions)
- Running tests
- Formatting
- Linting
- Local builds

**All Tier 4:**
- Read-only operations

### Limits

| Limit | Value | Behavior When Exceeded |
|-------|-------|------------------------|
| Files modified | 10 | Pause and confirm before proceeding |
| Lines per file | 100 | Pause and confirm for that file |
| Operations per session | 50 | Pause and report progress |
| Time per task | 30 min | Pause and report progress |

Limits apply to auto-executed operations; exceeding a limit triggers a confirmation gate.

### Guardrails

**Pre-operation checkpoint:**
```bash
# Before any Tier 2 destructive operation
if ! git diff --quiet; then
    git stash push -m "autopilot-checkpoint-$(date +%s)"
fi
```

**Operation tracking:**
- Log all Tier 2/3 operations to the audit log
- Count operations toward session limit
- Track time spent in autopilot

### UX Pattern

```
[Autopilot] Making changes...
  ✓ Created: /path/to/new_handler.go
  ✓ Modified: /path/to/routes.go (+15 lines)
  ✓ Modified: /path/to/middleware.go (+8 lines)
  ✓ Running tests...
  ✓ Tests passing (92% coverage)

[CONFIRMATION REQUIRED]
Ready to push to origin/feature-branch. This will make changes visible to others.
Proceed? [Y/n] _
```

---

## Full-Auto Mode

**Philosophy**: Maximum autonomy. Proceed automatically for everything except Tier 1 CRITICAL.

### Confirmation Required For

**Tier 1 CRITICAL operations ONLY, plus commits (never-auto):**
- Force push to main/master
- Production database operations
- External API mutations (POST/PUT/DELETE to prod)
- Credential/secret operations
- Production deployments
- Git commits (`git commit`, `git commit --amend`)

### Automatic

**All Tier 2 (except never-auto overrides):**
- File modification and deletion
- Git operations (push, merge, rebase)
- Package management

**All Tier 3:**
- Code additions
- Tests, linting, formatting, builds

**All Tier 4:**
- Read-only operations

### Limits (Non-Blocking, Informational)

| Limit | Value | Behavior |
|-------|-------|----------|
| Operations per session | Unlimited | Report every 10 operations or 5 minutes (whichever comes first) |
| Time per task | 30 min | Pause and report, offer to continue |
| Consecutive failures | 3 | Stop and request guidance |
| Files modified | Unlimited | Report every 25 files |

### Guardrails

**Audit log (all operations):**
- Location: `~/.cache/agent/audit-log/{session-id}.log`
- Append **one line per operation** (write immediately after the operation completes)
- Record format: `[timestamp] [mode] [tier] [operation] [result]`
- Log full commands with **secrets redacted**; prefer env vars in commands when possible
- Do not log file contents or raw secrets

**Redaction rules (minimum):**
- Mask values for keys matching: `API_KEY`, `TOKEN`, `SECRET`, `PASSWORD`, `AUTH`, `PRIVATE`, `CREDENTIAL`, `BEARER`, `AWS_`, `GCP_`, `AZURE_`, `DATABASE_URL`
- Redact query params for keys like `token`, `key`, `secret`, `password`
- Redact long token-like substrings (base64/hex) when labeled as credentials

```
[12:00:01] [FULL-AUTO] [TIER-3] Created: api/handler.go [SUCCESS]
[12:00:03] [FULL-AUTO] [TIER-3] Created: api/handler_test.go [SUCCESS]
[12:00:05] [FULL-AUTO] [TIER-2] Modified: api/routes.go (+15 lines) [SUCCESS]
[12:00:10] [FULL-AUTO] [TIER-3] Ran: go test ./api [SUCCESS]
[12:00:12] [FULL-AUTO] [TIER-2] Ran: git commit -m "feat: add user login endpoint" [CONFIRM-REQUIRED]
[12:00:15] [FULL-AUTO] [TIER-2] Ran: git push origin feature-login [SUCCESS]
```

**Automatic checkpointing:**
```bash
# Before major operations (>5 files or git push)
git stash push -m "full-auto-checkpoint-$(date +%s)"
# Or create checkpoint branch
git branch full-auto-checkpoint-$(date +%s)
```

**Error handling:**
```
[FULL-AUTO] Operation failed: tests not passing after modification

Failures: 3 consecutive

Recovery options:
1. [R]evert to last checkpoint (stash@{0})
2. [D]ebug the issue (switch to systematic-debugging)
3. [C]ontinue anyway (not recommended)
4. [S]witch to normal mode

Choice: _
```

### UX Pattern

```
[FULL-AUTO] Implementing feature...
  [12:00:01] Created: api/handler.go
  [12:00:03] Created: api/handler_test.go
  [12:00:05] Modified: api/routes.go (+15 lines)
  [12:00:10] Tests passing (coverage: 92%)
  [12:00:12] Committed: "feat: add user login endpoint"
  [12:00:15] Pushed to origin/feature-login

✓ Feature implementation complete

[CRITICAL CONFIRMATION]
Ready to merge into main. This will trigger production deployment.
Impact: Production environment will be updated
Proceed? [Y/n] _
```

---

## Absolute Never-Auto Operations

**These operations ALWAYS require confirmation, even in full-auto mode:**

### Git Operations
```bash
git commit -m "message"
git commit --amend
git push --force origin main
git push --force origin master
git push --force origin develop
git branch -D main  # deleting protected branches
git reset --hard origin/main  # in main branch
```

### Credentials and Secrets
```bash
echo "API_KEY=secret" >> .env
git add .env
vim credentials.json
echo "password: secret" >> config.yml
```

### Production Systems
```bash
kubectl delete namespace production
terraform destroy
ansible-playbook deploy-prod.yml
ssh prod-server "systemctl restart app"
curl -X DELETE https://api.prod.example.com/data
```

### Database Operations
```bash
psql production -c "DROP TABLE users;"
mysql prod_db -e "DELETE FROM users WHERE 1=1;"
go run scripts/migrate-prod-db.go
python manage.py migrate --database=production
```

### Mass Destructive
```bash
rm -rf /
find . -name "*.go" -delete  # without verification
git clean -fdx  # without checking branch
```

---

## Recovery Mechanisms

### Checkpoint Strategy

**Autopilot Mode:**
- Create git stash before any Tier 2 destructive operation
- Stash message format: `autopilot-checkpoint-{timestamp}`
- Max stashes: 10 (clean up old ones)

**Full-Auto Mode:**
- Create git stash before operations affecting >5 files
- Create checkpoint branch before git push
- Branch format: `full-auto-checkpoint-{timestamp}`

### Rollback Procedure

**Manual rollback:**
```bash
# List checkpoints
git stash list | grep checkpoint

# Restore checkpoint
git stash pop stash@{N}

# Or restore branch
git reset --hard full-auto-checkpoint-{timestamp}
```

**Automatic rollback on error:**
```bash
# If operation fails and we have a checkpoint
if [ $? -ne 0 ] && git stash list | grep -q checkpoint; then
    echo "Operation failed. Rolling back to checkpoint..."
    git stash pop stash@{0}
fi
```

### Audit Log

**Location:** `~/.cache/agent/audit-log/{session-id}.log`

**Format:**
```
[timestamp] [mode] [tier] [operation] [result]
[12:00:01] [FULL-AUTO] [TIER-3] Created: api/handler.go [SUCCESS]
[12:00:03] [FULL-AUTO] [TIER-3] Created: api/handler_test.go [SUCCESS]
[12:00:05] [FULL-AUTO] [TIER-2] Modified: api/routes.go (+15 lines) [SUCCESS]
[12:00:10] [FULL-AUTO] [TIER-3] Ran: go test ./api [SUCCESS]
[12:00:12] [FULL-AUTO] [TIER-2] Committed: "feat: add user login endpoint" [SUCCESS]
[12:00:15] [FULL-AUTO] [TIER-2] Pushed: origin/feature-login [SUCCESS]
```

---

## Mode Switching Safeguards

### Escalation (Less Restrictive)

When switching to a less restrictive mode:

**normal → autopilot:**
```
Switching to autopilot mode.

Autopilot will:
  ✓ Auto-proceed for safe operations (tests, formatting, new files)
  ⚠ Confirm for risky operations (deletes, pushes)
  ✓ Create checkpoints before destructive operations

Continue? [Y/n] _
```

**normal → full-auto:**
```
⚠ WARNING: Switching to full-auto mode

Full-auto will:
  ✓ Auto-proceed for ALMOST ALL operations
  ⚠ Only confirm for CRITICAL operations (force push main, prod db, credentials)
  ✓ Create checkpoints and audit logs

This mode should only be used when you trust the agent completely.

Type 'I understand' to proceed: _
```

**autopilot → full-auto:**
```
⚠ Switching to full-auto mode

Full-auto removes most confirmations including:
  • File deletions
  • Git push operations
  • Mass modifications

Only CRITICAL operations (force push main, credentials, prod) will require confirmation.

Continue? [Y/n] _
```

### De-escalation (More Restrictive)

No confirmation needed when switching to a more restrictive mode:

**full-auto → autopilot:**
```
Switched to autopilot mode. Now requiring confirmation for:
  • File deletions
  • Git push operations
  • Mass modifications (>10 files or >100 lines/file)
```

**full-auto → normal:**
```
Switched to normal mode. Now requiring confirmation for ALL modifications.
```

---

## Best Practices

### When to Use Each Mode

**Normal Mode (default):**
- Critical bugfixes
- Security-sensitive code
- Unfamiliar codebases
- Learning/exploration
- When you want full control

**Autopilot Mode:**
- Routine refactoring
- Test additions
- Documentation updates
- Known patterns/repetitive work
- When you trust the approach but want safety checks

**Full-Auto Mode:**
- Bulk operations (adding tests to many files)
- Boilerplate generation
- Formatting/linting entire codebase
- When the operation is well-defined and reversible
- When you're actively monitoring

### Red Flags (Switch to Lower Mode)

Switch to a more restrictive mode if:
- Unexpected errors occurring
- Files being modified that shouldn't be
- Operations taking longer than expected
- You're unsure about the agent's approach
- Working in critical production code

---

## Implementation Notes

### Mode State Tracking

Sticky mode within session requires tracking:
```
# Session state (in-memory or conversation context)
current_mode: "normal" | "autopilot" | "full-auto"
checkpoint_stack: [stash_ids | branch_names]
operation_count: number
start_time: timestamp
```

### Confirmation Prompts

All confirmation prompts should:
1. Clearly state what will happen
2. Show the operation tier and risk level
3. Offer multiple options ([Y]es/[N]o/[D]iff/[A]bort)
4. Allow user to switch modes mid-task
5. Provide context for why confirmation is needed
