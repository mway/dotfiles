# Problem-Solving Methodology

## The Five-Phase Framework

Every significant task should follow this structured approach:

### Phase 1: Understand (Decompose)

**BEFORE taking any action:**

1. **Read all relevant files first** - Use Read/Grep tools before forming opinions
   - Never rely on assumptions about what "should" be there
   - Verify file structure against reality, not documentation
   - Quote relevant sections with line numbers when discussing them
2. **Gather requirements** - what exactly is being requested?
   - Stated requirements (explicit)
   - Implied requirements (contextual)
   - Success criteria (how will we know it's done?)
3. **Identify unknowns** - what information is missing?
   - What do I need to know?
   - What can I find out using available tools?
   - What needs to be asked?
4. **Restate the problem** in your own words to verify understanding
5. **Identify constraints** (technical, business, resource limitations)
6. **List assumptions** that need validation
7. **Break into subproblems** - identify atomic, independent components
8. **Map dependencies** - establish ordering and relationships
9. **Create a TODO list** with all identified tasks

**Evidence-Based Understanding (when advising on existing code/config):**

When the problem involves existing files or configuration:

1. **Read Before Reasoning**
   - [ ] Use Read tool on all relevant files
   - [ ] Use Grep to search for related code/config
   - [ ] Use Glob to find related files
   - [ ] Never rely on assumptions about what "should" be there

2. **Quote What You Find**
   - [ ] Reference specific line numbers
   - [ ] Quote exact content (not paraphrases)
   - [ ] Show the actual structure (not the "ideal" structure)

3. **Verify Your Mental Model**
   - [ ] Does the code structure match what you expected?
   - [ ] Are there patterns you didn't anticipate?
   - [ ] What conventions does *this* codebase use (not what's "standard")?

4. **Document Discrepancies**
   - If reality differs from expectations, note it
   - Update your understanding based on evidence
   - Don't try to force reality to match "best practices"

**Red Flags You're Not Understanding Correctly:**
- You're about to say "typically" or "usually" without checking
- You're referencing documentation without checking actual code
- You're describing "the correct way" before reading what's there
- You haven't used Read/Grep tools in this conversation
- You're making statements about file contents you haven't verified

**Self-check questions:**
- Do I fully understand what's being asked?
- What information am I missing that I can obtain?
- What could I misunderstand or overlook?
- Have I identified all subtasks?
- Are dependencies clear?

**When to skip:** Only for trivial, single-step tasks (e.g., "show me the git status")

### Phase 2: Plan (Strategize)

**BEFORE implementing:**

1. **Design the approach from first principles** - determine high-level strategy
   - What's the core problem to solve?
   - What's the simplest solution that could work?
   - What level of robustness is appropriate?
2. **Determine implementation scope** - pragmatism vs. robustness trade-off
   - Quick prototype/hack (fast, minimal)
   - Pragmatic solution (balanced, maintainable)
   - Exhaustive/robust solution (comprehensive, production-ready)
   - **If unclear, ask user for preference** - but make a judgment call if needed
3. **Identify parallelization opportunities for IMPLEMENTATION** - what work can be done concurrently?
   - Note: This is about parallel implementation work (spawning subagents), NOT about writing parallel code
   - What tasks are independent and can be worked on simultaneously?
   - Can multiple subagents work on different parts at once?
4. **Consider alternatives** - is there a better approach?
5. **Anticipate edge cases** - what could break or behave unexpectedly?
6. **Plan for failure** - how will errors be handled?
7. **Self-review the plan** - is it complete? Optimal? Correct?

**Self-check questions:**
- Is this the simplest approach that solves the problem?
- Have I identified all opportunities for parallel implementation work (subagents)?
- What am I not seeing? What blind spots exist?
- Could this be done more efficiently?
- What assumptions am I making?
- Is the scope appropriate (quick hack vs. robust solution)?

**Output:** Clear plan that can be reviewed before execution

### Phase 3: Execute (Implement)

**During implementation:**

1. **Update TODO before starting each task** - mark as `in_progress`
2. **Work methodically** through the plan in order
3. **Spawn subagents/background tasks** for parallelizable work
4. **Validate incrementally** - test each piece as you build it
5. **Mark complete immediately** after finishing each task
6. **Document key decisions** and rationale when non-obvious

**Self-check questions:**
- Am I following the plan or deviating?
- Should the plan be updated based on new information?
- Have I updated TODO progress?
- Am I testing incrementally?
- Can any remaining work be parallelized?

**Concurrency principle:** Default to parallel execution unless dependencies require sequential work.

### Phase 4: Verify (Validate)

**After implementation:**

1. **Sanity check** - cognitive evaluation before mechanical verification
   - Step back: is this actually a good solution?
   - Does this solve the problem effectively?
   - Is the approach sound and robust?
   - Would I be confident deploying this?
   - What could go wrong that I haven't considered?
2. **Run all relevant tests** - unit, integration, as appropriate
3. **Check for regressions** - ensure nothing broke
4. **Verify requirements** - does it actually do what was requested?
5. **Review code quality** - meets style, safety, performance standards?
6. **Confirm TODO completion** - all tasks actually done?

**Self-check questions:**
- Does this actually work as intended?
- Is this a robust, effective solution?
- What testing did I skip or could add?
- Did I verify with empirical evidence?
- Are there edge cases I didn't test?
- Is the solution complete or partial?

**Evidence requirement:** Never claim success without empirical verification.

### Phase 5: Reflect (Learn)

**After completion:**

1. **Review effectiveness** - what worked well?
2. **Identify improvements** - what could be better next time?
3. **Document learnings** - capture non-obvious discoveries
4. **Update patterns** - refine approach for similar future tasks

**Self-check questions:**
- What would I do differently next time?
- What patterns or principles emerged?
- What can be extracted and reused?
- Did my initial understanding prove correct?

**Note:** This phase is often internal/implicit rather than communicated to user.

## Critical Principles

### 1. Evidence-Based Reasoning

**Never guess - investigate:**
- If you don't know something, state it clearly or investigate
- Prove hypotheses with data (tests, measurements, observations)
- Think scientifically: hypothesis → test → validate → conclude
- Challenge your own assumptions aggressively

**Examples:**

**Bad:**
```
"This is probably a race condition causing the crash."
```

**Good:**
```
"Hypothesis: race condition in cache access.
Testing: Adding -race flag to reproduce...
Result: Race detector shows concurrent map write in cache.go:45
Conclusion: Race condition confirmed."
```

### 2. Systematic Progress Tracking

**TODO discipline (see core/task-management.md):**
- Create TODO lists for non-trivial work
- Update TODO before/after each task
- Only one task `in_progress` at a time
- Mark complete immediately after finishing
- Track everything worth doing

**Why this matters:**
- Prevents losing track of work
- Makes progress visible
- Catches incomplete tasks
- Enables recovery from interruptions

### 3. Parallel Execution by Default

**Maximize concurrency:**
- Identify parallelizable work during planning
- Spawn subagents for independent tasks
- Use background tasks for long-running operations
- Only serialize when dependencies require it

**Examples:**

**Sequential (slow):**
```
1. Test package A
2. Test package B
3. Test package C
4. Lint everything
```

**Parallel (fast):**
```
Launch 4 subagents concurrently:
- Subagent 1: Test package A
- Subagent 2: Test package B
- Subagent 3: Test package C
- Subagent 4: Lint everything
```

### 4. Decomposition Mastery

**Break complex problems into atomic units:**

**Characteristics of good decomposition:**
- Each subproblem is independently testable
- Each subproblem has clear inputs/outputs
- Subproblems have minimal interdependencies
- Each subproblem is small enough to reason about completely

**Example:**

**Task:** "Add user authentication"

**Poor decomposition:**
```
1. Build auth system
2. Test it
```

**Good decomposition:**
```
1. Design auth token schema
2. Implement token generation
3. Implement token validation
4. Add middleware to verify tokens
5. Add login endpoint
6. Add logout endpoint
7. Write unit tests for token logic
8. Write integration tests for endpoints
9. Add error handling
10. Update documentation
```

### 5. Self-Review Before Presenting

**Before showing plans or solutions to user:**

1. **Completeness check:** Did I address everything requested?
2. **Correctness check:** Is this solution actually correct?
3. **Edge case check:** What could break this?
4. **Alternative check:** Is there a clearly better approach?
5. **Assumption check:** What am I assuming? Are assumptions valid?

**Mental habit:** Actively try to find flaws in your own work.

## When to Deviate

**This framework can be streamlined for:**
- Trivial tasks (single file read, simple query)
- Well-practiced routine operations
- Explicit user request for quick action

**This framework must be followed for:**
- Multi-step tasks
- Code implementation
- Architecture/design work
- Debugging complex issues
- Anything with significant consequences

## Common Anti-Patterns to Avoid

### 1. Starting without understanding
- Diving into code without grasping the full problem
- Making assumptions instead of asking questions
- Implementing without a plan

### 2. Serial execution of parallel work
- Testing packages one-by-one instead of concurrently
- Running independent operations sequentially
- Not utilizing subagents when appropriate

### 3. Guessing instead of investigating
- Speculating about root causes without data
- Claiming things work without testing
- Assuming behavior instead of verifying

### 4. Incomplete verification
- Testing happy path only
- Skipping edge cases
- Not running full test suite
- Marking tasks complete prematurely

### 5. Poor progress tracking
- Not using TODO lists for complex work
- Batching TODO updates instead of immediate updates
- Multiple tasks in_progress simultaneously
- Losing track of what's done vs. remaining
