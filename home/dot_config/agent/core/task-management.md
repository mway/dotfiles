# Task Management Discipline

## TODO List Usage Requirements

### When TODO Lists are REQUIRED

**MUST create TODO list when:**
1. Task involves **3 or more distinct steps**
2. Task is **non-trivial or complex**
3. User **provides multiple tasks** (even if simple individually)
4. Working on **multi-step operations** (build, test, lint, commit)
5. Doing **planning or architecture work**
6. **Any coding task** that spans multiple files or operations

### When TODO Lists are OPTIONAL

**May skip TODO list for:**
1. Single, trivial operations ("show me file X")
2. Simple queries ("what's the git status?")
3. Straightforward one-step tasks
4. Purely informational requests

**When in doubt:** Create the TODO list. Overhead is minimal, benefits are significant.

## TODO List Discipline

### Creation Phase

**At task start, not midway through:**

```
User: "Add authentication and write tests"

IMMEDIATELY create TODO:
[pending] Design authentication approach
[pending] Implement token generation
[pending] Implement token validation
[pending] Add middleware
[pending] Write unit tests
[pending] Write integration tests
```

**Not:**
```
Start implementing, then realize complexity, then create TODO
```

### Task Breakdown Rules

**Characteristics of good TODO items:**
- **Atomic:** Each task is a single, complete unit of work
- **Actionable:** Clear what needs to be done
- **Testable:** You can verify when it's complete
- **Sized appropriately:** Meaningful but not too granular

**Both forms required:**
- **content:** Imperative form - "Run tests"
- **activeForm:** Present continuous - "Running tests"

**Example:**
```json
{
  "content": "Fix type error in handler.go",
  "status": "pending",
  "activeForm": "Fixing type error in handler.go"
}
```

### Status Management Rules

#### The Golden Rule: Exactly ONE in_progress Task

**At any given moment:**
- ✓ Exactly ONE task marked `in_progress`
- ✗ Never ZERO in_progress (if work is happening)
- ✗ Never TWO OR MORE in_progress

**Why:** Clear state tracking. Always know what's being worked on.

**Example of correct progression:**
```
[pending] Run tests
[pending] Fix errors
[pending] Run lint

↓ Start first task

[in_progress] Run tests  ← Exactly one
[pending] Fix errors
[pending] Lint code

↓ Complete first task

[completed] Run tests
[in_progress] Fix errors  ← Exactly one
[pending] Lint code

↓ Complete second task

[completed] Run tests
[completed] Fix errors
[in_progress] Lint code  ← Exactly one
```

#### Immediate Updates - No Batching

**Mark completed IMMEDIATELY after finishing:**

**Correct:**
```
Currently: [in_progress] Run tests
*runs tests, they pass*
Update: [completed] Run tests
Update: [in_progress] Fix type error
```

**WRONG - Batching:**
```
Currently: [in_progress] Run tests
*runs tests, finds 5 errors, fixes all 5*
Update:
  [completed] Run tests
  [completed] Fix error 1
  [completed] Fix error 2
  [completed] Fix error 3
  [completed] Fix error 4
  [completed] Fix error 5
```

**Why batching is bad:**
- Loses track of progress during work
- Can't see what's actively being worked on
- Makes it impossible to recover from interruptions
- Violates the "exactly one in_progress" rule

#### Status Transitions

**Valid transitions:**
```
pending → in_progress → completed
```

**When blocked:**
```
[in_progress] Fix auth bug
↓ discover need to refactor token validation first
[pending] Fix auth bug (move back to pending)
[in_progress] Refactor token validation (new task)
```

**Removing tasks:**

If task becomes irrelevant, **remove entirely** - don't mark completed or pending:

```python
# Before
todos = [
  {"content": "Test old API", "status": "pending", ...},
  {"content": "Build project", "status": "in_progress", ...}
]

# User says: "Actually, skip the old API testing"

# After - remove completely
todos = [
  {"content": "Build project", "status": "in_progress", ...}
]
```

### Completion Criteria

#### Only Mark Complete When FULLY Accomplished

**Cannot mark complete if:**
- Tests are failing
- Implementation is partial
- Unresolved errors exist
- Missing dependencies
- Work is blocked

**Must mark complete when:**
- Task is 100% done
- All verification passed
- No blockers remain
- Results are confirmed

**Example - handling failure:**

```
[in_progress] Run tests
*runs tests, 3 failures*

WRONG: [completed] Run tests  (they failed!)

CORRECT:
[completed] Run tests  (the action completed)
[in_progress] Fix test failure in handler_test.go:45
[pending] Fix test failure in auth_test.go:123
[pending] Fix test failure in db_test.go:89
```

The distinction: Running tests completed. But test failures spawned new tasks.

### Visibility and Communication

#### Proactive Display

**Show TODO list immediately after creation:**
```
User: "Add caching support"
Agent: "Creating TODO list:

[pending] Design cache interface
[pending] Implement in-memory cache
[pending] Add cache middleware
[pending] Write tests
[pending] Update documentation

Starting with cache interface design..."
```

#### Progress Announcements

**When marking complete, announce with context:**
```
"✓ Completed: Run tests [1/5 done]"
"✓ Completed: Fix type errors [2/5 done]"
"✓ Completed: Run lint [3/5 done]"
```

**When starting tasks:**
```
"Working on: Implement token validation [2/5]"
```

#### Status Summaries at Milestones

**After completing major sub-sections:**
```
Progress update:
✓ Design phase complete (2/5 tasks)
⟳ Implementation in progress (task 3/5)
○ Testing pending (2/5 tasks)
```

### Task Modification During Work

#### Adding New Tasks

**When new work is discovered:**
```
Current state:
[completed] Run tests
[in_progress] Fix type errors
[pending] Run lint

*while fixing errors, discover need to refactor*

New state:
[completed] Run tests
[completed] Fix type errors
[in_progress] Refactor cache interface  ← New task added
[pending] Re-run tests after refactor      ← New task added
[pending] Run lint
```

#### Reordering Tasks

**When priorities change or dependencies discovered:**
```
Before:
[pending] Add feature X
[pending] Write tests
[pending] Update docs

*realize tests should come first*

After:
[pending] Write tests              ← Moved up
[pending] Add feature X
[pending] Update docs
```

### Multi-Level TODOs

**For very complex work, consider hierarchical structure:**

```
[in_progress] Implement authentication

  Sub-tasks:
  [completed] Design token schema
  [in_progress] Implement token generation
    [completed] Create signing logic
    [in_progress] Add expiration handling
    [pending] Add refresh token support
  [pending] Implement token validation
  [pending] Add middleware
```

**But keep top-level flat when possible** - hierarchy adds complexity.

## Common Anti-Patterns

### 1. Multiple in_progress Tasks
```
WRONG:
[in_progress] Run tests
[in_progress] Fix errors  ← Can't work on two things at once
[pending] Lint
```

### 2. Batching Updates
```
WRONG:
*does 5 things*
*then updates all 5 at once*
```

### 3. Premature Completion
```
WRONG:
[completed] Fix bug  (but tests still failing!)
```

### 4. Not Creating TODO for Complex Work
```
User: "Implement auth, add tests, update docs, and deploy"
Agent: *starts working without TODO*
*loses track of what's done*
```

### 5. Over-Granular Tasks
```
WRONG:
[pending] Open file
[pending] Read file
[pending] Find function
[pending] Edit function
[pending] Save file
```

### 6. Under-Granular Tasks
```
WRONG:
[pending] Implement entire authentication system
```

### 7. Leaving Stale Tasks
```
WRONG:
[pending] Test old API  (user said skip this, but still in list)
```

Should be removed entirely, not marked completed or left pending.

## Examples

### Example 1: Simple Multi-Step Task

```
User: "Run tests, fix any errors, and lint the code"

Agent creates TODO:
[pending] Run tests
[pending] Fix errors (if any)
[pending] Lint code

Agent: [in_progress] Run tests
*runs tests*
Found 3 errors.

Agent updates:
[completed] Run tests
[in_progress] Fix error: undefined variable in handler.go:45
[pending] Fix error: type mismatch in auth.go:123
[pending] Fix error: missing return in db.go:89
[pending] Lint code

*fixes first error*

Agent updates:
[completed] Run tests
[completed] Fix error: undefined variable in handler.go:45
[in_progress] Fix error: type mismatch in auth.go:123
...

*fixes all errors, runs lint*

Final:
[completed] Run tests
[completed] Fix error: undefined variable in handler.go:45
[completed] Fix error: type mismatch in auth.go:123
[completed] Fix error: missing return in db.go:89
[completed] Lint code

Agent: "All tasks complete. Tests pass, errors fixed, lint clean."
```

### Example 2: Discovery of New Work

```
Initial TODO:
[pending] Add caching
[pending] Write tests

Agent: [in_progress] Add caching
*discovers cache interface needs refactoring first*

Updated TODO:
[pending] Refactor cache interface    ← Added
[pending] Add caching                  ← Blocked on above
[pending] Write tests

Agent: [in_progress] Refactor cache interface
*completes refactor*

Agent: [completed] Refactor cache interface
Agent: [in_progress] Add caching
...
```

### Example 3: Parallel Work

```
TODO for parallel execution:
[in_progress] Spawning subagents for parallel test execution
[pending] Collect and report results

Agent spawns 3 subagents:
- Subagent 1: Test package A
- Subagent 2: Test package B
- Subagent 3: Test package C

Updated TODO:
[completed] Spawning subagents for parallel test execution
[in_progress] Collect and report results

*subagents complete*

Agent:
[completed] Spawning subagents for parallel test execution
[completed] Collect and report results

All tests passed.
```
