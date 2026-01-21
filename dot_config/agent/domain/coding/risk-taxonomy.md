# Operation Risk Taxonomy

This document defines the 4-tier risk classification system for operations in coding tasks. The risk tier determines what level of confirmation is required in each operating mode (normal/autopilot/full-auto).

---

## Overview

| Tier | Confirmation Behavior |
|------|----------------------|
| **Tier 1: CRITICAL** | Always confirm (even in full-auto) |
| **Tier 2: HIGH** | Confirm in normal/autopilot, auto in full-auto |
| **Tier 3: MEDIUM** | Confirm in normal, auto in autopilot/full-auto |
| **Tier 4: LOW** | Always automatic |

---

## Tier 1: CRITICAL

Operations with potential for catastrophic, irreversible damage to shared or external systems.

### Categories

| Category | Rationale | Examples |
|----------|-----------|----------|
| **Production systems** | Affects shared/external state permanently | `git push --force origin main`, `DROP DATABASE prod`, deploy to production |
| **Credentials/secrets** | Security breach potential | Writing API keys to files, committing `.env` files, modifying authentication configs |
| **Mass destructive** | Large-scale irreversible loss | `rm -rf /` (in unknown dir), `git clean -fdx` without verification, deleting multiple critical files |
| **External API mutations** | External side-effects, potential costs | POST/PUT/DELETE to production APIs, billing operations, data deletion via API |

### Language-Specific Examples

**Go:**
```bash
# CRITICAL
git push --force origin main
go run scripts/migrate-prod-db.go
echo "API_KEY=secret" >> .env && git add .env
curl -X DELETE https://api.prod.example.com/users
```

**Python (future):**
```bash
# CRITICAL
git push --force origin master
python manage.py migrate --database=production
echo "SECRET_KEY='secret'" >> settings.py && git add settings.py
```

**General:**
```bash
# CRITICAL
rm -rf /
git push --force origin main
kubectl delete namespace production
terraform destroy -target=aws_instance.production
```

---

## Tier 2: HIGH

Destructive operations that are recoverable but involve significant risk or effort to restore.

### Categories

| Category | Rationale | Examples |
|----------|-----------|----------|
| **File deletion** | Per CLAUDE.md line 373 (destructive ops) | `rm file.go`, `git rm --cached`, `git checkout -- file` (discards changes) |
| **Line modification (non-deterministic)** | Per CLAUDE.md line 373 (vs. additive ops) | Editing/removing existing code lines (not just adding new ones); excludes deterministic format/lint fixes (Tier 3) |
| **Git state changes** | Per CLAUDE.md lines 108-109 (commit without prompt) | `git commit`, `git push`, `git merge`, `git rebase` |
| **Package management** | Modifies dependency state | `go mod tidy`, `npm install`, `pip install`, `cargo update` |
| **Mass file operations** | Affects multiple files | Modifying >10 files in single operation, bulk renames, bulk deletions |

### Language-Specific Examples

**Go:**
```bash
# HIGH
rm internal/handler.go
git commit -m "refactor handlers"
git push origin feature-branch
go mod tidy
sed -i 's/oldFunc/newFunc/g' **/*.go  # mass modification
```

**Python (future):**
```bash
# HIGH
rm app/views.py
git commit -m "update views"
pip install -r requirements.txt
find . -name "*.py" -exec sed -i 's/old/new/g' {} \;
```

**General:**
```bash
# HIGH
git commit -am "changes"
git push
npm install
find . -name "test_*.go" -delete  # deleting multiple files
```

---

## Tier 3: MEDIUM

Operations that modify state but are safe and low-risk.

### Categories

| Category | Rationale | Examples |
|----------|-----------|----------|
| **Code additions** | Per CLAUDE.md line 374 (additive is OK) | Adding new functions, new files, new tests, appending to files |
| **Running tests** | Read-only execution, may modify test artifacts | `go test`, `npm test`, `pytest`, `cargo test` |
| **Build operations** | Local, reversible, produces artifacts | `go build`, `cargo build`, `npm run build`, `make` |
| **Formatting** | Deterministic, reversible, follows standards | `gofmt`, `golines`, `prettier`, `rustfmt`, `black` |
| **Linting** | Read-only analysis or deterministic fixes | `golangci-lint run`, `eslint`, `pylint`, `golangci-lint run --fix` |

### Language-Specific Examples

**Go:**
```go
# MEDIUM
// Creating new file
cat > internal/new_handler.go << 'EOF'
package internal
func NewHandler() {}
EOF

# Running tests
go test ./...

# Building
go build -o /dev/null ./...

# Formatting
gofmt -w .
golines -w .

# Linting
golangci-lint run ./...
```

**Python (future):**
```python
# MEDIUM
# Creating new file
cat > app/new_view.py << 'EOF'
def new_view():
    pass
EOF

# Running tests
pytest

# Formatting
black .
isort .

# Linting
pylint app/
```

**General:**
```bash
# MEDIUM
echo "new content" >> file.txt  # appending only
mkdir -p new/directory
touch new-file.txt
npm run build
```

---

## Tier 4: LOW

Read-only operations with no side effects.

### Categories

| Category | Examples |
|----------|----------|
| **File reading** | `cat`, `less`, `head`, `tail`, Read tool |
| **Search/navigation** | `grep`, `rg`, `find`, `fd`, Glob, Grep tools |
| **Status queries** | `git status`, `git log`, `git diff`, `ls`, `pwd`, `which` |
| **Analysis** | `go vet`, `shellcheck`, code analysis tools (read-only mode) |
| **Display** | `echo`, `printf` (when not redirecting to files) |

### Language-Specific Examples

**Go:**
```bash
# LOW
go list ./...
go doc fmt.Printf
go version
git log --oneline -10
grep -r "func.*Handler" .
```

**Python (future):**
```bash
# LOW
python --version
pip list
find . -name "*.py" | wc -l
grep -r "class.*View" app/
```

**General:**
```bash
# LOW
ls -la
cat README.md
git status
git diff
tree -L 2
rg "TODO" --files-with-matches
```

---

## Classification Algorithm

When encountering an operation, classify it using this decision tree:

1. **Does it affect production, external systems, or secrets?** → **Tier 1: CRITICAL**
2. **Does it delete files, modify existing code (non-deterministic), or change git state?** → **Tier 2: HIGH**
3. **Does it add new code, run tests, or format/build?** → **Tier 3: MEDIUM**
4. **Is it read-only?** → **Tier 4: LOW**
5. **Uncertain?** → Default to higher tier (safer)

**Deterministic transformations (formatters/linters with fixes) are Tier 3** even though they modify lines. Manual or non-deterministic edits remain Tier 2.

---

## Global Overrides (Never-Auto)

These rules override tier behavior:

- **Commits are never auto-run.** `git commit` (including `--amend`) always requires explicit user confirmation/manual action, even in full-auto.
- **Tier 1 CRITICAL** operations always require confirmation in all modes.

---

## Edge Cases

### Operations with Multiple Components

When an operation involves multiple tiers, use the **highest tier**:

```bash
# This command contains:
# - Tier 3: git add . (staging new files)
# - Tier 2: git commit (git state change)
# - Tier 2: git push (git state change)
# → Overall classification: Tier 2 (HIGH)
git add . && git commit -m "changes" && git push
```

### Language-Specific Tooling

Different languages have equivalent operations at the same tier:

| Tier | Go | Python | Rust | JavaScript |
|------|----|----|------|------------|
| 3 (Test) | `go test` | `pytest` | `cargo test` | `npm test` |
| 3 (Build) | `go build` | N/A | `cargo build` | `npm run build` |
| 3 (Format) | `gofmt` | `black` | `rustfmt` | `prettier` |
| 3 (Lint) | `golangci-lint` | `pylint` | `clippy` | `eslint` |
| 2 (Deps) | `go mod tidy` | `pip install` | `cargo update` | `npm install` |

---

## Mode Behavior Matrix

| Tier | Normal Mode | Autopilot Mode | Full-Auto Mode |
|------|-------------|----------------|----------------|
| 1: CRITICAL | **Confirm** | **Confirm** | **Confirm** |
| 2: HIGH | **Confirm** | **Confirm** | Auto |
| 3: MEDIUM | **Confirm** | Auto | Auto |
| 4: LOW | Auto | Auto | Auto |

**Key:**
- **Confirm** = Pause and ask user before proceeding
- **Auto** = Proceed automatically without confirmation
