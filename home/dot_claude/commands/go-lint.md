---
description: Lint and format Go code via golangci-lint
allowed-tools: Bash(golangci-lint:*)
argument-hint: [package-path]
---

# Go Linter

Lint and format per @~/.config/agent/domain/coding/go/tooling.md

## Command (with auto-fix)

```bash
golangci-lint run --new-false --fix $ARGUMENTS
```

Default to `./...` if no arguments provided.

## Lint Only (no fixes)

If user wants to see issues without fixing:
```bash
golangci-lint run --new-false $ARGUMENTS
```
