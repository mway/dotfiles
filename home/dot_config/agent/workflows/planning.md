# Planning Workflow

## Purpose

Create standalone implementation plans that serve as executable blueprints for technical work. Plans are artifacts that:
- Survive session boundaries
- Can be executed by different agents
- Enable review before execution
- Provide clear progress tracking

## When to Create Plans

**Create a plan when:**
- Work spans multiple sessions
- Multiple people/agents will execute
- Work needs review before starting
- Complex multi-step implementation
- Architecture or design decisions needed
- User explicitly requests a plan

**Skip planning when:**
- Single, simple task
- Immediate execution requested
- Work is exploratory/investigative

## Planning Phases

### Phase 1: Requirements Gathering

**Goals:**
- Understand what is being requested
- Identify unstated requirements
- Surface constraints and assumptions

**Activities:**
1. Read and analyze the request
2. Identify explicit requirements
3. Infer implicit requirements
4. Document constraints
5. List assumptions
6. Define success criteria

**Outputs:**
- Requirements list (functional, non-functional)
- Constraints list
- Assumptions list
- Success criteria

**Quality check:**
- Are requirements specific and measurable?
- Are constraints realistic?
- Are assumptions validated or flagged?

### Phase 2: Research and Exploration

**Goals:**
- Understand current state
- Find relevant patterns
- Identify integration points

**Activities:**
1. Explore relevant codebase areas
2. Find similar implementations
3. Identify dependencies
4. Map integration points
5. Note potential conflicts

**Outputs:**
- Current state summary
- Relevant code references
- Dependency list
- Integration point map

**Quality check:**
- Is current state accurately described?
- Were patterns found (or confirmed none exist)?
- Are dependencies complete?

### Phase 3: Architecture Design

**Goals:**
- Choose implementation approach
- Design component structure
- Document trade-offs

**Activities:**
1. Consider multiple approaches
2. Evaluate trade-offs
3. Select approach
4. Design component structure
5. Define interfaces
6. Document decisions

**Outputs:**
- Approach summary
- Component design
- Interface definitions
- Decision log with rationale

**Quality check:**
- Is the approach sound?
- Were alternatives considered?
- Is rationale documented?

### Phase 4: Task Decomposition

**Goals:**
- Break work into atomic tasks
- Map dependencies
- Identify parallelization

**Activities:**
1. Identify all tasks
2. Make tasks atomic
3. Map dependencies
4. Find parallel opportunities
5. Estimate effort
6. Define acceptance criteria

**Outputs:**
- Task list with:
  - Description
  - Dependencies
  - Parallelizable flag
  - Effort estimate
  - Acceptance criteria
- Dependency graph
- Execution order

**Quality check:**
- Is each task atomic?
- Are dependencies correct?
- Is parallelization maximized?
- Are estimates reasonable?

### Phase 5: Verification Definition

**Goals:**
- Define how to validate implementation
- Specify success criteria
- Plan for failure

**Activities:**
1. Define test strategy
2. Specify success criteria
3. Define quality gates
4. Create rollback plan

**Outputs:**
- Test strategy
- Success criteria checklist
- Quality gates
- Rollback procedure

**Quality check:**
- Can success be objectively measured?
- Is rollback feasible?

### Phase 6: Document and Output

**Goals:**
- Create standalone plan document
- Ensure self-containment
- Enable execution

**Activities:**
1. Format using standard template
2. Verify completeness
3. Review for self-containment
4. Output to file or display

**Outputs:**
- Plan document

**Quality check:**
- Can someone execute this without asking questions?
- Are all sections complete?

## Plan Validation Criteria

A plan is valid when:

1. **Self-contained**: No external context required to understand
2. **Complete**: All tasks identified, no obvious gaps
3. **Executable**: Clear enough for blind execution
4. **Correct**: Actually solves the stated problem
5. **Atomic**: Tasks are single-responsibility
6. **Ordered**: Dependencies and execution order clear
7. **Parallel-aware**: Concurrent opportunities identified
8. **Verifiable**: Success criteria defined
9. **Risk-aware**: Known risks documented

## Plan Template

```markdown
# Implementation Plan: [Title]

Generated: [Date]
Author: [Agent/User]
Status: Draft | Approved | In Progress | Completed

## Overview

[1-3 sentence summary of what this plan achieves]

## Context

### Problem Statement
[What problem does this solve? Why is it needed?]

### Current State
[What exists now? What's the starting point?]

### Desired State
[What should exist after execution? What's the goal?]

## Requirements

### Functional Requirements
- [FR-1] [Requirement description]
- [FR-2] [Requirement description]

### Non-Functional Requirements
- [NFR-1] [Requirement description] (e.g., performance, security)

### Constraints
- [C-1] [Constraint description] (e.g., must use existing API)

### Assumptions
- [A-1] [Assumption description]

## Architecture/Approach

### Design Decision Summary
[High-level approach and key architectural decisions]

### Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| [Decision 1] | [Choice made] | [Why] |
| [Decision 2] | [Choice made] | [Why] |

### Component Overview
[Describe major components/modules involved]

## Implementation Tasks

### Task Dependency Graph

```
[Task-1] ──┬── [Task-2] ──── [Task-4]
           └── [Task-3] ──┘
```

### Tasks

#### [Task-1] [Task Title]
- **Status**: pending | in_progress | completed | blocked
- **Dependencies**: None | [Task-X], [Task-Y]
- **Parallelizable**: Yes | No
- **Estimated Effort**: S | M | L | XL
- **Description**: [What needs to be done]
- **Files Affected**: [list of files]
- **Acceptance Criteria**:
  - [ ] [Criterion 1]
  - [ ] [Criterion 2]

#### [Task-2] [Task Title]
[... repeat for each task ...]

### Execution Order

1. **Phase 1** (Parallel): [Task-1], [Task-2]
2. **Phase 2** (Sequential, after Phase 1): [Task-3]
3. **Phase 3** (Parallel): [Task-4], [Task-5]

## Verification

### Test Strategy
- [ ] Unit tests for [component]
- [ ] Integration tests for [flow]
- [ ] Manual verification of [feature]

### Success Criteria
- [ ] All tests pass
- [ ] Lint clean
- [ ] Requirements [FR-1, FR-2, ...] satisfied
- [ ] [Custom criterion]

### Rollback Plan
[How to undo changes if implementation fails]

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | Low/Med/High | Low/Med/High | [Mitigation strategy] |
| [Risk 2] | Low/Med/High | Low/Med/High | [Mitigation strategy] |

## Open Questions

- [ ] [Question 1] - blocking | non-blocking
- [ ] [Question 2] - blocking | non-blocking

## References

- [Link to relevant docs]
- [Link to related code]
- [Link to design discussions]
```

## Integration with Other Skills

### Relationship to `decompose`
- **decompose**: Creates TODO items for immediate session use
- **planner**: Creates persistent plan documents
- **Integration**: Planner internally uses decomposition principles

### Relationship to `problem-solving`
- **problem-solving**: Methodology for immediate work
- **planner**: Uses the methodology during planning
- **Integration**: Planner outputs a document, not immediate execution

### Relationship to `feature`
- **feature**: Executes immediately
- **planner**: Creates blueprint for later execution
- **Integration**: A plan can be executed using feature skill

## File Output Convention

Plans are stored project-locally for POLA compliance:

**Location**: `docs/plans/<name>.md` (default) or `docs/plans/<name>/` (complex)
- Aligns with ADR/RFC documentation patterns
- Visible, discoverable, version-controllable
- Always create structure with `mkdir -p` before writing

**File structure**:
- **Single file** (default): `docs/plans/<name>.md`
  - Use for most plans (simple, self-contained)
- **Directory** (complex plans): `docs/plans/<name>/`
  - Use when: plan >500 lines, has supporting artifacts, or needs to split concerns
  - Main file: `plan.md` (primary implementation plan)
  - Supporting files (optional):
    - `research.md` - Background research and analysis
    - `architecture.md` - Detailed design decisions
    - `alternatives.md` - Rejected approaches and rationale
    - `assets/` - Diagrams, mockups, prototypes

**Project root detection**:
1. Check if PWD contains `.git/`
2. If yes, use PWD as project root
3. If no, **ask user explicitly** to either:
   - Confirm PWD should be used, or
   - Provide a different directory path

**File naming**: `<kebab-case-name>.md`
- Descriptive names, no date prefix (date in metadata)
- Examples: `authentication-system.md`, `cache-layer.md`

**Gitignore consideration**:
- Plans can be committed or ignored per project preference
- Add `docs/plans/` to `.gitignore` if ephemeral
- Keep if plans serve as documentation (architecture decisions)
