---
description: Run Go tests with race detection and coverage
allowed-tools: Bash(go:*), Bash(go tool:*)
argument-hint: [package-path]
---

# Go Test Runner

Run tests per @~/.config/agent/domain/coding/go/tooling.md

## Command

```bash
go test -race -count 1 -coverprofile cover.out $ARGUMENTS
```

Default to `./...` if no arguments provided.

## Verbose Mode

If user requests verbose:
```bash
go test -v -race -count 1 -coverprofile cover.out $ARGUMENTS
```

## Coverage Report

After tests pass, offer to show coverage:
```bash
go tool cover -func=cover.out         # Text summary
go tool cover -html=cover.out         # HTML report
```
