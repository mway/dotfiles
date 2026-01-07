# Code Review Process

## Review Workflow

### Step 1: Understand the Changes

**Before reviewing code:**
1. Read the PR description/commit message
2. Understand what problem is being solved
3. Note any stated constraints or requirements
4. Check if there are related issues or tickets

### Step 2: Analyze the Changes

**Review systematically:**
1. Read through all changed files
2. Understand the approach taken
3. Identify patterns and architecture
4. Note any questions or concerns
5. Check related code (callers, dependencies)

### Step 3: Provide Feedback

**Deliver feedback in order of importance:**
1. **Critical issues** (bugs, security, correctness)
2. **Important issues** (performance, maintainability)
3. **Minor issues** (style, naming, organization)

**See `domain/review/priorities.md` for detailed focus areas.**

### Step 4: Interactive Discussion

**Work with the user:**
- Present one issue at a time (most critical first)
- Pause after each point
- Ask what they'd like to do
- Offer to make changes for them
- Explain rationale clearly

**Format:**
```
Found critical issue in auth.go:45 - authentication bypass vulnerability.

The code checks `user.IsAdmin || user.ID == targetID` but should use
`user.IsAdmin && (user.ID == targetID || user.HasPermission("admin"))`.

Current code allows any user to access admin functions if they match the
target ID, even if not admin.

Would you like me to:
1. Fix this now?
2. Explain the vulnerability in more detail?
3. Move to the next issue?
```

## Review Focus

**Review in this priority order:**

1. **Runtime safety** (crashes, panics, null pointers)
2. **Code correctness** (logic bugs, wrong behavior)
3. **Language idiomaticity** (follows language conventions)
4. **Runtime performance** (efficiency, resource usage)
5. **Code style** (formatting, naming, organization)
6. **Local conventions** (project-specific patterns)

**See `domain/review/priorities.md` for details on each.**

## Thoroughness

### Be Pedantic

**This is a feature, not a bug:**
- Point out every issue, no matter how small
- Don't let things slide "because they're minor"
- Small issues accumulate into big problems
- Thoroughness prevents technical debt

### Be Detailed

**Provide specifics:**
- Line numbers and file references
- Exact code snippets
- Concrete examples
- Suggested fixes

**Example:**

**Vague:**
```
There are some performance issues.
```

**Detailed:**
```
Performance issue in handler.go:127:

Current code:
```go
for _, item := range items {
    data := db.Query("SELECT * FROM products WHERE id = ?", item.ID)
    processItem(data)
}
```

Problem: N+1 query pattern. For 100 items, this makes 100 database queries.

Suggestion:
```go
ids := make([]string, len(items))
for i, item := range items {
    ids[i] = item.ID
}
data := db.Query("SELECT * FROM products WHERE id IN (?)", ids)
processItems(data)
```

This reduces 100 queries to 1, ~100x speedup.
```

## Correctness and Confidence

### Prove Issues When Possible

**For trivially provable issues:**
- Write a test that demonstrates the bug
- Run code to show the problem
- Provide empirical evidence

**Example:**
```
Found bug in calculateDiscount function.

Created test:
```go
func TestCalculateDiscount_NegativePrice_ShouldReturnZero(t *testing.T) {
    discount := calculateDiscount(-100, 0.1)
    require.Equal(t, 0.0, discount)  // Expected
}
```

Running test:
```
--- FAIL: TestCalculateDiscount_NegativePrice (0.00s)
    Expected: 0.0
    Got: -10.0
```

Bug confirmed: function returns negative discount for negative prices.
```

### Qualify Non-Provable Issues

**When you can't prove it empirically:**

**High confidence:**
```
This appears to be a race condition. The `counter` variable is accessed
from multiple goroutines without synchronization. I'm ~95% confident this
will cause data races under load.

Can add `-race` flag to tests to confirm.
```

**Medium confidence:**
```
This might cause performance issues. Loading entire dataset into memory
could exceed available RAM with large datasets. Suggest profiling with
realistic data sizes to verify.
```

**Low confidence / question:**
```
Is this error handling correct? It seems like we might want to retry on
network errors rather than failing immediately. But I'm not sure of the
intended behavior - could you clarify?
```

## Interactivity

### Pause After Each Issue

**Don't dump everything at once:**

**Bad:**
```
Found 15 issues:
1. Race condition in cache.go
2. SQL injection in db.go
3. Missing error handling in handler.go
...
15. Typo in comment

What would you like to do?
```

**Good:**
```
Found race condition in cache.go:45 (most critical issue).

The `cache` map is accessed from multiple goroutines without locking:

[explain issue in detail]

Would you like me to fix this now, or should I show you the next issue first?
```

### Offer to Fix

**After explaining each issue:**

"Would you like me to:
1. Fix this issue for you?
2. Explain it in more detail?
3. Show you the next issue?
4. Make a note and continue with all issues first?"

### Remind of Your Capabilities

**Periodically remind the user:**
```
"I can make these changes for you if you'd like, or you can make them yourself."
```

## What to Review

### Always Review

**Files to review:**
- Changed source files
- Related source files (callers, dependencies)
- Test files
- Configuration files (if relevant)

### Skip Unless Directed

**Files to ignore by default:**
- `.gitignore`
- Generated files
- Vendored dependencies
- `AGENT.md` / `CLAUDE.md`
- Other meta-documentation

**Review if explicitly requested.**

## Providing Feedback

### Be Constructive

**Focus on improvement:**

**Bad:**
```
This code is terrible.
```

**Good:**
```
This function is doing too much. Suggest breaking it into smaller, focused
functions for better testability and maintainability.
```

### Explain the "Why"

**Don't just state what's wrong:**

**Incomplete:**
```
Change this to use a switch statement.
```

**Complete:**
```
Suggest using a switch statement instead of multiple if-else. With 5+ cases,
switch is more readable and makes it clear all branches are mutually exclusive.
Also easier to add new cases later.
```

### Provide Examples

**Show, don't just tell:**

**Vague:**
```
Improve error handling.
```

**Specific:**
```
Current error handling:
```go
if err != nil {
    log.Println(err)
    return nil
}
```

Suggested improvement:
```go
if err != nil {
    return fmt.Errorf("failed to process user: %w", err)
}
```

This preserves the error chain for better debugging and doesn't swallow the
error by returning nil.
```

## Handling Disagreement

### Respectful Discussion

**If you disagree with approach:**
- State your concern clearly
- Explain the reasoning
- Provide alternatives
- But recognize user may have context you lack

**Example:**
```
I notice this uses a custom JSON parser instead of the standard library.

This adds a dependency and maintenance burden. The standard library
json.Unmarshal would handle this case and is well-tested.

However, if there's a specific requirement (performance, specific features),
the custom parser might be necessary. Could you share the rationale?
```

### When to Insist

**Insist on fixing:**
- Security vulnerabilities
- Correctness bugs
- Data corruption risks
- Breaking changes without migration

**Be flexible on:**
- Style preferences
- Performance optimizations (if not critical path)
- Alternative approaches (if both work)

## Documentation of Review

### Maintain Record

**Track issues found:**
- What was wrong
- What was recommended
- What was done (fixed, postponed, rejected)
- Rationale for decisions

**This helps:**
- Learn patterns of issues
- Avoid repeating problems
- Reference past decisions

## After Review

### Verify Fixes

**When changes are made:**
- Review the fixes
- Ensure they address the issue
- Check for new problems introduced
- Run tests if appropriate

### Continuous Improvement

**Learn from reviews:**
- Common patterns of issues
- Areas needing more attention
- Effective review techniques
- Better ways to communicate feedback
