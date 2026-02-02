---
description: Run full pre-commit workflow for Go code
allowed-tools: Bash(go:*), Bash(golangci-lint:*), Bash(git:*)
---

# Go Pre-Commit Workflow

Execute per @~/.config/agent/domain/coding/go/tooling.md

All steps are **blocking** per @~/.config/agent/domain/coding/quality.md

## Workflow

Execute in order (all must pass):

### 1. Format and Lint (with auto-fix)
```bash
golangci-lint run --new-false --fix ./...
```

### 2. Run Tests (with coverage)
```bash
go test -race -count 1 -coverprofile cover.out ./...
```

### 3. Final Lint Check
```bash
golangci-lint run --new-false ./...
```

## On Failure

Stop at first failure and investigate per @~/.config/agent/core/methodology.md
