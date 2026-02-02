# Go Tooling Commands

## Build Commands

### Standard Build
```bash
go build -o /dev/null ./...
```
Compiles all packages without creating output binary (fast syntax check).

### Using Just
```bash
just build-lint ./...
```
If project has Just files for build automation.

## Test Commands

### Run All Tests
```bash
go test -race -count 1 ./...
```
- `-race`: Enable race detector
- `-count 1`: Disable test caching
- `./...`: All packages recursively

### Run Specific Package
```bash
go test -race -count 1 ./path/to/package
```

### Verbose Output
```bash
go test -v -race -count 1 ./...
go test -v -race -count 1 ./path/to/package
```

### Why These Flags?

**`-race`:**
- Detects data races
- Critical for concurrent code
- Small performance overhead
- ALWAYS use for Go code

**`-count 1`:**
- Disables test caching
- Ensures fresh test run
- Prevents stale results
- Important for reliability

## Linting Commands

### Standard Lint
```bash
golangci-lint run --new-false ./...
```
- `--new-false`: Show all issues, not just new ones
- Note: Some configs use `--new=false` (same thing)

### Lint Specific Package
```bash
golangci-lint run --new-false ./path/to/package
```

### Lint with Auto-Fixes
```bash
golangci-lint run --new-false --fix ./...
golangci-lint run --new-false --fix ./path/to/package
```

**Auto-fixes apply:**
- Simple formatting issues
- Unused imports
- Some code simplifications

**But verify all changes before committing.**

## Formatting Commands

### Format Code (Recommended: golangci-lint)

**Use golangci-lint for formatting:**
```bash
golangci-lint run --fix ./...
```

**Why golangci-lint?**
- Abstracts multiple formatters (gofumpt, golines, etc.)
- Unified configuration in `.golangci.yml`
- Single command for formatting + linting
- Handles formatter orchestration automatically

**Configuration in `.golangci.yml`:**
```yaml
linters:
  enable:
    - gofumpt
    - golines
    # ... other linters

linters-settings:
  golines:
    max-len: 79
    tab-len: 4
    ignore-generated: true
    reformat-tags: false
    shorten-comments: false
```

**Note:** If project-level AGENT.md specifies different `max-len`, update the value in `.golangci.yml`.

### Manual Formatting (Fallback)

**If golangci-lint not configured, use two-step manual process:**

**Step 1: Run golines**
```bash
golines \
  --base-formatter=gofumpt \
  --ignore-generated \
  --max-len=79 \
  --tab-len=4 \
  --no-reformat-tags \
  --chain-split-dots \
  -w .
```

**Step 2: Run gofumpt**
```bash
gofumpt -w .
```

**Why two steps?**
- `golines`: Handles line length (79 chars max)
- `gofumpt`: Stricter formatting than `gofmt`
- Must run in this order

### Flags Explained (Manual Mode)

**golines flags:**
- `--base-formatter=gofumpt`: Use gofumpt for base formatting
- `--ignore-generated`: Skip generated files
- `--max-len=79`: Maximum line length (79 characters)
- `--tab-len=4`: Tab width for calculations
- `--no-reformat-tags`: Don't reformat struct tags
- `--chain-split-dots`: Better method chain formatting
- `-w`: Write changes to files

**gofumpt flags:**
- `-w`: Write changes to files

## Coverage Commands

### Generate Coverage Profile
```bash
go test -race -count 1 -coverprofile=cover.out ./...
```

### View Text Coverage Report
```bash
go tool cover -func=cover.out
```

### View HTML Coverage Report
```bash
go tool cover -html cover.out
```
Opens in browser showing covered (green) and uncovered (red) code.

### Check Total Coverage
```bash
go tool cover -func=cover.out | grep total
```

## CI Check Workflow

**Complete CI check should:**
1. Run all tests
2. Run linter
3. Verify no failures or issues

**Example:**
```bash
# Run tests
go test -race -count 1 ./...
if [ $? -ne 0 ]; then
    echo "Tests failed"
    exit 1
fi

# Run linter
golangci-lint run --new-false ./...
if [ $? -ne 0 ]; then
    echo "Lint failed"
    exit 1
fi

echo "CI check passed"
```

## Pre-Commit Workflow

**Before committing, code must:**
1. Be formatted
2. Pass all tests
3. Pass linter

**Recommended (golangci-lint handles formatting + linting):**
```bash
# 1. Format and lint with auto-fix
golangci-lint run --new-false --fix ./...

# 2. Test
go test -race -count 1 ./...
```

**Manual (if golangci-lint not configured for formatting):**
```bash
# 1. Format
golines --base-formatter=gofumpt --ignore-generated --max-len=79 --tab-len=4 --no-reformat-tags --chain-split-dots -w .
gofumpt -w .

# 2. Test
go test -race -count 1 ./...

# 3. Lint
golangci-lint run --new-false ./...
```

**All must succeed before committing.**

## GitHub Interaction

### Using gh CLI

**View status:**
```bash
gh pr status
gh pr list
gh issue list
```

**Create PR:**
```bash
gh pr create \
  --draft \
  --assignee=@me \
  --base="$(git rev-parse --abbrev-ref HEAD@{upstream})" \
  --title "feat: add feature" \
  --body "PR description"
```

**View PR details:**
```bash
gh pr view 123
gh pr diff 123
gh pr checks 123
```

## Package-Specific Testing

### Prefer Specific Packages

**Instead of:**
```bash
go test -race -count 1 ./...  # Tests everything (slow)
```

**Use:**
```bash
go test -race -count 1 ./pkg/handler  # Just what changed
```

**Why:**
- Faster feedback loop
- Less noise in output
- Easier to debug failures

**But:** Run full suite before committing.

## Debugging Failed Tests

### Show Full Output
```bash
go test -v -race -count 1 ./path/to/package
```

### Run Specific Test
```bash
go test -race -count 1 -run TestFunctionName ./path/to/package
```

### Run with More Detail
```bash
go test -v -race -count 1 -run TestFunctionName ./path/to/package 2>&1 | less
```

## Module Management

### Update Dependencies
```bash
go get -u ./...
go mod tidy
```

### Verify Dependencies
```bash
go mod verify
```

### Clean Module Cache
```bash
go clean -modcache
```

## Build Tags

### Build with Tags
```bash
go build -tags integration ./...
go test -tags integration ./...
```

### Common Tags
- `integration`: Integration tests
- `e2e`: End-to-end tests
- `unit`: Unit tests only

## Performance Profiling

### CPU Profile
```bash
go test -cpuprofile=cpu.prof -bench=. ./...
go tool pprof cpu.prof
```

### Memory Profile
```bash
go test -memprofile=mem.prof -bench=. ./...
go tool pprof mem.prof
```

### Benchmarks
```bash
go test -bench=. -benchmem ./...
```

## Quick Reference

**Most common commands:**
```bash
# Build check
go build -o /dev/null ./...

# Test
go test -race -count 1 ./...

# Format and lint (recommended)
golangci-lint run --new-false --fix ./...

# Lint only
golangci-lint run --new-false ./...

# Format manually (if golangci-lint not configured)
golines --base-formatter=gofumpt --ignore-generated --max-len=79 --tab-len=4 --no-reformat-tags --chain-split-dots -w .
gofumpt -w .

# Coverage
go test -race -count 1 -coverprofile=cover.out ./...
go tool cover -html cover.out
```
