---
name: skill-creator
description: Meta-skill for creating new Claude Code skills, subagents, slash commands, and output styles with rigor and consistency. Use when asked to create new agent capabilities or extend the configuration system.
---

# Skill Creator

Guide for creating new Claude Code capabilities (skills, subagents, slash commands, output styles) with the same rigor as existing ones.

## Core Principle: Reference Only

**Never summarize guidance documents.** Always use `@` includes to reference the full document, allowing all guidance to apply.

**Bad:**
```markdown
Per @~/.config/agent/core/methodology.md:
- 5-phase approach
- Evidence-based reasoning
```

**Good:**
```markdown
Apply all guidance from:
- @~/.config/agent/core/methodology.md
```

## File Locations

All files in chezmoi source: `~/.local/share/chezmoi/home/`

| Type | Location | Extension |
|------|----------|-----------|
| Slash Commands | `dot_claude/commands/` | `.md` |
| Skills | `dot_claude/skills/<name>/` | `SKILL.md` |
| Subagents | `dot_claude/agents/<name>/` | `AGENT.md` |
| Output Styles | `dot_claude/output-styles/` | `.md` |

## Creating a Slash Command

**Template:**
```markdown
---
description: <Clear description of what this command does>
allowed-tools: <Tool restrictions, comma-separated>
argument-hint: [optional-arg-name]
---

# <Command Name>

Apply all guidance from:
- @~/.config/agent/<relevant-module>.md
- @~/.config/agent/<relevant-module>.md

<Minimal command-specific logic if needed>

Target: $ARGUMENTS
```

**Examples:** See existing commands in `dot_claude/commands/`

## Creating a Skill

**Template:**
```markdown
---
name: <skill-name>
description: <What this skill does and when it activates. Be specific about trigger conditions.>
---

# <Skill Name>

Apply all guidance from:
- @~/.config/agent/<relevant-module>.md
- @~/.config/agent/<relevant-module>.md
```

**Key points:**
- `description` field triggers auto-activation
- Keep it focused - one clear purpose
- Reference ALL relevant guidance modules
- No summaries or excerpts

**Examples:** See `dot_claude/skills/`

## Creating a Subagent

**Template:**
```markdown
---
name: <agent-name>
description: <What this agent specializes in. When to use it.>
tools: <Tool allowlist>
model: sonnet|opus|haiku
---

You are <role description>.

Apply all guidance from:
- @~/.config/agent/<relevant-module>.md
- @~/.config/agent/<relevant-module>.md
```

**Tool restrictions:**
- Read-only agents: `Read, Grep, Glob`
- Full agents: `Read, Grep, Glob, Edit, Write, Bash`
- Specific bash: `Bash(go:*), Bash(git:*)`

**Examples:** See `dot_claude/agents/`

## Creating an Output Style

**Template:**
```markdown
---
name: <style-name>
description: <Communication style description>
keep-coding-instructions: true
---

# <Style Name>

<Brief style description>

Apply all guidance from:
- @~/.config/agent/<relevant-module>.md
- @~/.config/agent/<relevant-module>.md

<Style-specific instructions if needed>
```

**Examples:** See `dot_claude/output-styles/`

## Workflow for Creating New Capabilities

### 1. Identify Purpose
- What problem does this solve?
- When should it activate (skills) or be invoked (commands)?
- What scope does it need (tools, model)?

### 2. Identify Relevant Guidance
- Which modules from `~/.config/agent/` apply?
  - `core/` - Universal behaviors
  - `domain/` - Domain-specific (architecture, coding, testing, review)
  - `workflows/` - Task workflows

### 3. Choose Mechanism
- **Slash Command** - User explicitly invokes
- **Skill** - Auto-activates based on context
- **Subagent** - Delegated work with isolated context
- **Output Style** - Changes persona/communication mode

### 4. Write File
- Use reference-only approach
- List ALL relevant guidance modules
- Minimal additional content
- No summaries or duplication

### 5. Test
- Apply with `chezmoi apply -v`
- Test invocation/activation
- Verify guidance is being applied

## Existing Guidance Modules

Reference these as needed:

**Core:**
- `core/behavior.md` - Critical thinking, evidence-based reasoning
- `core/communication.md` - Tone, style, conciseness
- `core/methodology.md` - 5-phase problem-solving
- `core/efficiency.md` - Parallelization, throughput
- `core/task-management.md` - TODO discipline
- `core/principles.md` - Engineering principles

**Architecture:**
- `domain/architecture/decomposition.md` - Problem breakdown
- `domain/architecture/parallelization.md` - Concurrent execution

**Coding:**
- `domain/coding/workflow.md` - Universal coding workflow
- `domain/coding/quality.md` - Quality priorities
- `domain/coding/safety.md` - Runtime + security safety
- `domain/coding/go/style.md` - Go code style
- `domain/coding/go/idioms.md` - Go conventions
- `domain/coding/go/concurrency.md` - Go thread safety
- `domain/coding/go/testing.md` - Go test practices
- `domain/coding/go/tooling.md` - Go commands
- `domain/coding/go/organization.md` - Go code structure
- `domain/coding/go/performance.md` - Go optimization

**Testing:**
- `domain/testing/unit.md` - Unit test strategies
- `domain/testing/coverage.md` - Coverage requirements

**Review:**
- `domain/review/process.md` - Review workflow
- `domain/review/priorities.md` - Review focus areas

**Workflows:**
- `workflows/feature.md` - Feature implementation

## Anti-Patterns to Avoid

❌ **Summarizing guidance**
```markdown
Per @file.md:
- Point 1
- Point 2
```

❌ **Duplicating content**
```markdown
From @file.md, the priority order is:
1. Correctness
2. Safety
...
```

❌ **Selective quoting**
```markdown
Key rules from @file.md:
- Rule A
- Rule B
```

✅ **Reference only**
```markdown
Apply all guidance from:
- @~/.config/agent/path/to/file.md
```

## Examples

See existing implementations:
- Commands: `dot_claude/commands/go-review.md`
- Skills: `dot_claude/skills/go-development/SKILL.md`
- Subagents: `dot_claude/agents/go-reviewer/AGENT.md`
- Styles: `dot_claude/output-styles/methodical.md`
