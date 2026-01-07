# Parallelization Strategies

## Scope

**This module is about parallelizing implementation work** - executing multiple tasks concurrently via subagents.

**This is NOT about writing parallel code** - for guidance on implementing concurrent/parallel code (goroutines, channels, etc.), see language-specific modules like `domain/coding/go/concurrency.md`.

## Default to Parallel

**Guiding principle:** If work can be done concurrently, it should be.

**Why this matters:**
- Maximize throughput and efficiency
- Reduce total time to completion
- Better utilize available resources
- Scale horizontally

## Identifying Parallelization Opportunities

### Independent Work is Parallelizable

**Work is independent when:**
- No shared mutable state
- No data dependencies between tasks
- Results don't depend on execution order
- Each task is self-contained

**Examples of independent work:**
```
✓ Testing different packages
✓ Linting and testing (different operations)
✓ Reading multiple files
✓ Searching multiple directories
✓ Running builds for different platforms
✓ Analyzing separate components
```

### Dependent Work Must Be Sequential

**Work is dependent when:**
- Task B needs Task A's output
- Shared state requires coordination
- Order affects correctness
- Results must be combined in specific way

**Examples of dependent work:**
```
✗ Compile before run tests (tests need binary)
✗ Write code before test it (need code to test)
✗ Generate code before format it (need code to format)
✗ Fix error before re-run test (test would still fail)
```

## Execution Patterns

### Pattern 1: Pure Parallel (No Dependencies)

**When:** All tasks are completely independent

**Example: Testing multiple packages**
```
Spawn 3 subagents concurrently:
- Subagent 1: go test ./pkg/auth
- Subagent 2: go test ./pkg/cache
- Subagent 3: go test ./pkg/api

Wait for all to complete, then aggregate results.
```

**Benefits:**
- Maximum parallelism
- Minimum total time
- No coordination overhead

### Pattern 2: Pipeline (Linear Dependencies)

**When:** Tasks form a dependency chain A → B → C

**Example: Build pipeline**
```
Sequential execution required:
1. Compile code
2. Run tests (needs compiled code)
3. Build container (needs tests to pass)
4. Push image (needs container built)
```

**Cannot parallelize** because each step depends on previous.

**But can still optimize:**
- Start next step immediately when previous completes
- Don't wait for human intervention between steps
- Prepare resources for next step while current runs

### Pattern 3: Fan-Out/Fan-In (Partial Dependencies)

**When:** Multiple independent tasks, then combine results

**Example: Parallel search, aggregate results**
```
Phase 1 (Fan-out): Spawn parallel searches
- Subagent 1: Search directory A
- Subagent 2: Search directory B
- Subagent 3: Search directory C

Phase 2 (Fan-in): Combine results
- Aggregate all findings
- Remove duplicates
- Sort by relevance
```

**Key:** Parallelizable fan-out, then sequential fan-in.

### Pattern 4: Hybrid (Mixed Dependencies)

**When:** Some tasks parallel, some sequential

**Example: Feature implementation**
```
Can parallelize:
├─ Subagent 1: Write backend logic
└─ Subagent 2: Write frontend UI

Then sequential:
1. Integration tests (needs both backend + frontend)
2. Documentation (needs implementation details)
```

**Strategy:**
- Identify independent clusters
- Parallelize within clusters
- Sequence between clusters

## Subagent Usage Guidelines

### When to Spawn Subagents

**Good candidates:**
- Multiple independent test suites
- Parallel file operations
- Separate analysis tasks
- Multiple builds/compilations
- Independent feature implementations
- Concurrent searches/explorations

**Poor candidates:**
- Single trivial task
- Tightly coupled operations
- Tasks requiring shared state
- Very quick operations (overhead not worth it)

### How Many Subagents?

**Reasonable limits:**
- **2-4 subagents:** Good for most parallel work
- **5-10 subagents:** Acceptable for highly independent tasks
- **10+ subagents:** Only if truly necessary and independent

**Consider:**
- Overhead of spawning/coordinating
- Resource contention
- Diminishing returns

### Coordinating Subagent Results

**Strategies:**

1. **Wait for all, then proceed:**
   ```
   Spawn N subagents
   Wait for all to complete
   Aggregate results
   Present summary
   ```

2. **Process results as they arrive:**
   ```
   Spawn N subagents
   As each completes, process its result
   Present incremental progress
   ```

3. **Fail fast:**
   ```
   Spawn N subagents
   If any fails, cancel others
   Report failure immediately
   ```

## Background Tasks

### When to Use Background Execution

**Good for:**
- Long-running builds
- Comprehensive test suites
- Large-scale searches
- Resource-intensive operations

**Pattern:**
```
Start background task for slow operation
Continue with other work
Check back when ready
```

**Example:**
```
User: "Run the full test suite and also check the linter"

Agent:
1. Start tests in background (will take 2 minutes)
2. Run linter in foreground (quick)
3. Check test results when ready
```

## Concrete Examples

### Example 1: Multi-Package Testing

**Scenario:** Test 5 packages

**Sequential (slow):**
```
go test ./pkg/a    # 30s
go test ./pkg/b    # 30s
go test ./pkg/c    # 30s
go test ./pkg/d    # 30s
go test ./pkg/e    # 30s
Total: 150s
```

**Parallel (fast):**
```
Spawn 5 subagents:
- Subagent 1: go test ./pkg/a    # 30s
- Subagent 2: go test ./pkg/b    # 30s
- Subagent 3: go test ./pkg/c    # 30s
- Subagent 4: go test ./pkg/d    # 30s
- Subagent 5: go test ./pkg/e    # 30s
Total: 30s (5x speedup)
```

### Example 2: Pre-Commit Checks

**Scenario:** Run tests, lint, and format checks

**Sequential (slow):**
```
go test ./...          # 60s
golangci-lint run      # 30s
gofumpt -l .          # 10s
Total: 100s
```

**Parallel (fast):**
```
Spawn 3 subagents:
- Subagent 1: go test ./...       # 60s
- Subagent 2: golangci-lint run   # 30s
- Subagent 3: gofumpt -l .        # 10s
Total: 60s (1.67x speedup, limited by slowest task)
```

### Example 3: Code Review

**Scenario:** Review multiple files

**Sequential (slow):**
```
Review file A
Review file B
Review file C
Present findings
```

**Parallel (fast):**
```
Spawn 3 subagents:
- Subagent 1: Review file A
- Subagent 2: Review file B
- Subagent 3: Review file C

Aggregate findings
Present consolidated review
```

### Example 4: Feature Implementation

**Scenario:** Add authentication with tests

**Poor approach (sequential):**
```
1. Implement token generation
2. Test token generation
3. Implement token validation
4. Test token validation
5. Implement middleware
6. Test middleware
```

**Better approach (hybrid):**
```
Phase 1 (parallel):
├─ Subagent 1: Implement + test token generation
└─ Subagent 2: Implement + test token validation

Phase 2 (sequential, depends on phase 1):
- Implement middleware (needs both token systems)
- Test middleware
```

## Anti-Patterns to Avoid

### Anti-Pattern 1: Serializing Independent Work

```
WRONG:
go test ./pkg/a
go test ./pkg/b
go test ./pkg/c

(These are independent, should be parallel.)
```

### Anti-Pattern 2: Parallelizing Dependent Work

```
WRONG:
Spawn parallel:
- Build code
- Run tests

(Tests need built code, this will fail.)
```

### Anti-Pattern 3: Over-Parallelization

```
WRONG:
Spawn 50 subagents to search 50 files

(Overhead exceeds benefit, 5-10 subagents sufficient.)
```

### Anti-Pattern 4: Ignoring Critical Path

```
WRONG:
Spawn parallel:
- Trivial task (1s)
- Trivial task (1s)
- Expensive task (60s)

*Wait 60s for slowest*

BETTER:
Start expensive task first/in background,
do trivial tasks while it runs.
```

## Integration with TODO Lists

**Parallelization in TODO tracking:**

```
TODO:
[in_progress] Spawn subagents for parallel testing
[pending] Collect and report test results

*Spawns subagents*

TODO:
[completed] Spawn subagents for parallel testing
[in_progress] Collect and report test results

*Subagents complete, results aggregated*

TODO:
[completed] Spawn subagents for parallel testing
[completed] Collect and report test results
```

**Note:** The spawning and collection are tracked, not individual subagent work.

## Performance Considerations

### When Parallelism Helps Most

- **CPU-bound tasks:** Multiple cores can each handle one task
- **I/O-bound tasks:** While one waits, others can work
- **Independent tasks:** No coordination overhead

### When Parallelism Helps Less

- **Very quick tasks:** Overhead dominates
- **Resource-constrained:** Not enough cores/memory
- **Highly dependent:** Coordination overhead dominates

### Measuring Impact

**Before optimizing, measure:**
- Sequential execution time
- Parallel execution time
- Speedup factor
- Resource utilization

**Example:**
```
Sequential: 150s
Parallel (5 agents): 30s
Speedup: 5x
Ideal: 5x (linear scaling achieved!)
```

## Summary Checklist

**When planning work:**

1. ✓ Break problem into atomic tasks
2. ✓ Identify all dependencies
3. ✓ Find independent task clusters
4. ✓ Parallelize independent clusters
5. ✓ Sequence dependent chains
6. ✓ Choose appropriate number of subagents
7. ✓ Plan coordination strategy
8. ✓ Track progress appropriately
