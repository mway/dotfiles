# Agent Configuration System

Hierarchical, modular configuration system for AI coding agents.

## Overview

This directory contains composable configuration modules that define agent behavior, coding standards, workflows, and language-specific guidance.

## Structure

```
~/.config/agent/
├── core/                # Universal agent behaviors
├── domain/              # Domain-specific guidance
│   ├── architecture/   # System design
│   ├── coding/         # Universal + language-specific coding guidance
│   │   └── go/         # Go-specific modules
│   ├── testing/        # Testing strategies
│   └── review/         # Code review
├── workflows/           # Task-specific workflows
├── profiles/            # Composable profiles
└── README.md           # This file
```

## Quick Start

**For Claude Code:**
Create or update `~/CLAUDE.md`:

```markdown
# Claude Configuration

Load configuration from: `~/.config/agent/profiles/go-dev.yaml`

(See ~/.config/agent/README.md for details)
```

**For Codex:**
Update `~/.config/codex/config.toml`:

```toml
[profiles.default.prompts]
developer = """
Load configuration from: @~/.config/agent/profiles/go-dev.yaml

(See ~/.config/agent/README.md for details)
"""
```

## Profiles

Profiles are YAML files in `profiles/` that compose multiple modules:

- `go-dev.yaml` - Full Go development
- `minimal.yaml` - Core behaviors only

## Module Categories

### Core (`core/`)
Universal behaviors for all agents:
- `behavior.md` - Critical thinking, objectivity
- `communication.md` - Tone, style, conciseness
- `methodology.md` - 5-phase problem-solving
- `efficiency.md` - Parallelization, throughput
- `task-management.md` - TODO list discipline

### Domain (`domain/`)
Domain-specific guidance:
- `architecture/` - Decomposition, parallelization
- `coding/` - Workflow, quality, safety
- `testing/` - Unit tests, coverage
- `review/` - Code review process

### Coding (`domain/coding/`)
Universal coding guidance plus language-specific rules:
- `workflow.md` - Universal coding workflow
- `quality.md` - Code quality standards
- `safety.md` - Runtime and security safety
- `go/` - Go style, idioms, tooling, etc.

### Workflows (`workflows/`)
Task-specific workflows:
- `feature.md` - Feature implementation

## Usage

Agents load the specified profile which automatically includes all referenced modules.

## Adding New Modules

1. Create new `.md` file in appropriate directory
2. Add to relevant profile's `includes` list
3. Test with both agents

## Project-Specific Overrides

Create `AGENTS.md` (or `AGENT.md`) in project root:

```markdown
# Project-Specific Configuration

**Profile:** go-dev

**Line Length Override:** 100 characters

**Custom Commands:**
- Build: `make build`
- Test: `make test`
```

Both agents will respect project-specific overrides.
