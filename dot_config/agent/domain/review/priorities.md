# Code Review Priorities

## Review Focus Areas (In Order)

Review code in this priority order, from most to least critical:

### 1. Runtime Safety

**Focus:** Will this code crash, panic, or corrupt data?

**Check for:**
- Null/nil pointer dereferences
- Array/slice out-of-bounds access
- Division by zero
- Stack overflows (deep recursion)
- Deadlocks (lock ordering issues)
- Data races (concurrent access to shared state)
- Resource leaks (unclosed files, connections, goroutines)
- Integer overflow/underflow
- Buffer overflows

**Examples:**

```go
// UNSAFE - nil pointer dereference
func getName(user *User) string {
    return user.Name  // Crashes if user is nil
}

// SAFE
func getName(user *User) string {
    if user == nil {
        return ""
    }
    return user.Name
}
```

```go
// UNSAFE - race condition
var counter int

func increment() {
    counter++  // Not atomic, causes race
}

// SAFE
var counter atomic.Int64

func increment() {
    counter.Add(1)
}
```

**Priority: CRITICAL** - These issues can crash production systems.

### 2. Code Correctness

**Focus:** Does this code do what it's supposed to do?

**Check for:**
- Logic errors
- Off-by-one errors
- Incorrect algorithms
- Wrong calculations
- Incorrect state transitions
- Broken business logic
- Missing edge case handling
- Incorrect error handling

**Examples:**

```go
// INCORRECT - off by one
func getLastElement(slice []int) int {
    return slice[len(slice)]  // Should be len-1
}

// CORRECT
func getLastElement(slice []int) int {
    if len(slice) == 0 {
        return 0  // or handle error
    }
    return slice[len(slice)-1]
}
```

```go
// INCORRECT - logic error
func applyDiscount(price float64, isPremium bool) float64 {
    if isPremium {
        return price * 1.10  // Increases price instead of discounting!
    }
    return price
}

// CORRECT
func applyDiscount(price float64, isPremium bool) float64 {
    if isPremium {
        return price * 0.90  // 10% discount
    }
    return price
}
```

**Priority: CRITICAL** - These issues cause wrong results/behavior.

### 3. Language Ecosystem Idiomaticity

**Focus:** Does this follow language conventions and best practices?

**Check for:**
- Proper error handling (language-specific patterns)
- Correct use of standard library
- Following language style guides
- Using language idioms appropriately
- Appropriate abstraction levels
- Proper resource management
- Correct concurrency patterns

**Go examples:**

```go
// NON-IDIOMATIC - ignoring errors
result, _ := doSomething()

// IDIOMATIC
result, err := doSomething()
if err != nil {
    return fmt.Errorf("failed: %w", err)
}
```

```go
// NON-IDIOMATIC - manual defer tracking
file := open("file.txt")
// ... lots of code ...
file.Close()

// IDIOMATIC
file, err := os.Open("file.txt")
if err != nil {
    return err
}
defer file.Close()
```

**Python examples:**

```python
# NON-IDIOMATIC
f = open("file.txt")
data = f.read()
f.close()

# IDIOMATIC
with open("file.txt") as f:
    data = f.read()
```

**Priority: HIGH** - Affects maintainability and future bug risk.

### 4. Runtime Performance and Efficiency

**Focus:** Is this code reasonably efficient?

**Check for:**
- Algorithmic complexity issues (O(n²) where O(n) exists)
- Unnecessary allocations
- Repeated expensive operations
- N+1 query problems
- Inefficient data structures
- Missing caching where appropriate
- Unnecessary I/O
- Resource waste

**Examples:**

```go
// INEFFICIENT - O(n²) with unnecessary allocations
func joinStrings(items []string) string {
    result := ""
    for _, item := range items {
        result += item + ","  // Allocates new string each iteration
    }
    return result
}

// EFFICIENT - O(n) with single allocation
func joinStrings(items []string) string {
    return strings.Join(items, ",")
}
```

```go
// INEFFICIENT - N+1 queries
for _, userID := range userIDs {
    user := db.Query("SELECT * FROM users WHERE id = ?", userID)
    processUser(user)
}

// EFFICIENT - single query
users := db.Query("SELECT * FROM users WHERE id IN (?)", userIDs)
for _, user := range users {
    processUser(user)
}
```

**Priority: MEDIUM** - Important but usually won't break things.

**Note:** Only flag obvious waste. Don't prematurely optimize.

### 5. Code Style

**Focus:** Does this follow formatting and naming conventions?

**Check for:**
- Consistent formatting
- Proper indentation
- Appropriate naming
- Consistent variable/function naming
- Appropriate comment placement
- Line length limits
- Whitespace usage

**Examples:**

```go
// POOR STYLE
func calc(x int,y int)int{return x+y}

// GOOD STYLE
func calculate(x int, y int) int {
    return x + y
}
```

```go
// POOR STYLE - unclear names
func p(d []int) int {
    s := 0
    for _, v := range d {
        s += v
    }
    return s
}

// GOOD STYLE - clear names
func sum(numbers []int) int {
    total := 0
    for _, num := range numbers {
        total += num
    }
    return total
}
```

**Priority: LOW** - Matters but doesn't affect functionality.

**Note:** Follow project conventions. Use automated formatters.

### 6. Local Codebase Conventions

**Focus:** Does this match the existing codebase patterns?

**Check for:**
- Consistent error handling with rest of codebase
- Same logging approach
- Same configuration patterns
- Same testing patterns
- Same file organization
- Same dependency management

**Examples:**

```go
// If codebase uses structured logging
log.WithFields(log.Fields{
    "user_id": userID,
    "action": "login",
}).Info("User logged in")

// Don't introduce different pattern
fmt.Printf("User %s logged in\n", userID)  // Inconsistent
```

**Priority: LOW** - Consistency matters but can be refactored later.

## Additional Focus Areas

### Security (Implicit in Safety & Correctness)

**Always check for:**
- SQL injection
- Command injection
- XSS vulnerabilities
- Path traversal
- Authentication bypass
- Authorization issues
- Sensitive data exposure
- Insecure cryptography

**Priority: CRITICAL** (escalates to level 1 or 2)

See `domain/coding/safety.md` for details.

### Testing Quality (Separate Review)

**Check:**
- Adequate test coverage
- Tests actually verify behavior
- Edge cases covered
- Error paths tested
- Tests are maintainable

**Priority: HIGH**

See `domain/testing/` for details.

### Documentation (When Present)

**Check:**
- Documentation matches code
- Non-obvious behavior explained
- Examples are correct
- API documentation complete

**Priority: LOW** (unless missing for public API, then MEDIUM)

## Balancing Priorities

### When to Escalate Priority

**Escalate if:**
- Issue affects production immediately
- Security vulnerability discovered
- Data loss/corruption possible
- Breaking change to public API

### When to Accept Lower Priority

**Accept if:**
- Performance impact is negligible
- Style issue can be auto-formatted
- Refactoring would be too risky
- Existing tech debt being addressed separately

## Review Checklist by Priority

### P0: Runtime Safety (Must Fix Before Merge)

- [ ] No nil pointer dereferences
- [ ] No race conditions
- [ ] No resource leaks
- [ ] No deadlocks
- [ ] No panics/crashes
- [ ] No data corruption risks
- [ ] No array out-of-bounds
- [ ] No integer overflow in critical code

### P1: Correctness (Must Fix Before Merge)

- [ ] Logic is correct
- [ ] Edge cases handled
- [ ] Error handling is correct
- [ ] Business rules implemented correctly
- [ ] State transitions are valid
- [ ] Calculations are accurate

### P2: Idiomaticity (Should Fix Before Merge)

- [ ] Follows language conventions
- [ ] Uses standard library appropriately
- [ ] Error handling is idiomatic
- [ ] Resource management is proper
- [ ] Concurrency patterns are correct
- [ ] Code is reasonably idiomatic

### P3: Performance (Fix Obvious Issues)

- [ ] No O(n²) where O(n) exists
- [ ] No N+1 query problems
- [ ] No unnecessary allocations in hot paths
- [ ] Reasonable resource usage

### P4: Style (Nice to Fix)

- [ ] Consistent formatting
- [ ] Clear naming
- [ ] Appropriate comments
- [ ] Follows project style guide

### P5: Conventions (Nice to Fix)

- [ ] Matches existing patterns
- [ ] Consistent with codebase

## Providing Feedback in Priority Order

**Start with highest priority:**
```
Critical safety issue in cache.go:45:
[explain race condition]

Would you like me to fix this now?
```

**After critical issues resolved:**
```
Correctness issue in calculateDiscount:
[explain logic error]

Would you like me to address this next?
```

**Then work down the priority list.**

**Group low-priority issues:**
```
Also found some minor style issues:
- Inconsistent indentation in handler.go
- Variable name could be clearer in service.go
- Missing comment on exported function

Would you like me to fix these, or should we address them later?
```
