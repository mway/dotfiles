# Code Quality Standards

## Correctness First

**Priority order (default):**
1. **Correctness** - code must work as intended (always first)
2. **Safety** - encompasses BOTH:
   - **Runtime safety**: no crashes, panics, data races, memory corruption, resource leaks
   - **Security safety**: no vulnerabilities, injection attacks, data exposure
3. **Maintainability** - code must be understandable and changeable
4. **Performance** - code should be reasonably efficient
5. **Style** - code should follow conventions

**Priority order (performance-critical sections):**
1. **Correctness** - still always first
2. **Safety** - runtime and security safety (still always second)
3. **Performance** - when measured bottleneck with substantial gains available
4. **Maintainability** - can be traded for performance when justified
5. **Style** - lowest priority

**Safety definition:**
Code must behave as designed without known defects (modulo any accepted risks/defects), remain free of runtime errors even in nondeterministic scenarios, and contain no security vulnerabilities.

**Performance over maintainability when:**
- Measured bottleneck in performance-critical path
- Substantial gains are achievable (not micro-optimizations)
- Gains can be reasonably leveraged or provide prudent buffer/higher ceiling
- Optimization is localized and documented
- Trade-off is intentional and understood

**Never sacrifice correctness or safety for anything else.**

## Code Clarity

### Prioritize Readability

**Clear code is better than clever code.**

**Good:**
```go
func isEligibleForDiscount(user User) bool {
    return user.IsPremium && user.AccountAge > 30
}
```

**Bad:**
```go
func check(u User) bool {
    return u.P && u.A > 30
}
```

### Use Descriptive Names

**Variables:**
- Use full words, not abbreviations (unless standard)
- Name describes what it contains
- Scope determines length (short in small scopes OK)

**Functions:**
- Name describes what it does (verb + noun)
- Clear intent from name alone
- No misleading names

**Examples:**

**Good:**
```go
func calculateTotalPrice(items []Item) float64
func validateEmail(email string) error
var userCount int
var isAuthenticated bool
```

**Bad:**
```go
func calc(x []Item) float64  // calc what?
func check(s string) error   // check what?
var cnt int                   // count of what?
var flag bool                 // flag for what?
```

### Avoid Deep Nesting

**Prefer early returns:**

**Good:**
```go
func process(user User) error {
    if user == nil {
        return ErrNilUser
    }
    if !user.IsActive {
        return ErrInactiveUser
    }
    if user.Balance < 0 {
        return ErrNegativeBalance
    }

    return user.Process()
}
```

**Bad:**
```go
func process(user User) error {
    if user != nil {
        if user.IsActive {
            if user.Balance >= 0 {
                return user.Process()
            } else {
                return ErrNegativeBalance
            }
        } else {
            return ErrInactiveUser
        }
    } else {
        return ErrNilUser
    }
}
```

## Simplicity

### Avoid Over-Engineering

**Don't add complexity that isn't needed:**

**Unnecessary abstractions:**
```go
// BAD - abstraction for one use
type Adder interface {
    Add(a, b int) int
}
type IntAdder struct{}
func (IntAdder) Add(a, b int) int { return a + b }

// GOOD - just use the operation
result := a + b
```

**Unnecessary indirection:**
```go
// BAD - helper function for one line
func getUserName(user User) string {
    return user.Name
}
name := getUserName(user)

// GOOD - direct access
name := user.Name
```

**Unnecessary configuration:**
```go
// BAD - configurable for one scenario
type Config struct {
    MaxRetries int
    Timeout time.Duration
    EnableLogging bool
    // ... 20 more options
}

// GOOD - sane defaults, configure what matters
client := NewClient(timeout)
```

### Keep Functions Focused

**Single Responsibility:**
- Each function does one thing
- One level of abstraction per function
- Easy to name (if hard to name, probably doing too much)

**Good:**
```go
func validateUser(user User) error
func saveUser(user User) error
func notifyUser(user User) error
```

**Bad:**
```go
func validateAndSaveAndNotifyUser(user User) error {
    // Does three things
}
```

## Consistency

### Follow Existing Patterns

**When adding to existing codebase:**
- Use same error handling approach
- Use same logging approach
- Use same naming conventions
- Use same file organization

**Don't introduce new patterns without discussion.**

### Maintain Style Consistency

**Within a file:**
- Consistent indentation
- Consistent spacing
- Consistent ordering
- Consistent structure

**Across the codebase:**
- Follow project style guide
- Use project's formatters
- Match existing code style

## Defensive Programming

### Validate Inputs at Boundaries

**System boundaries (must validate):**
- User input (HTTP handlers, CLI args)
- External APIs
- File/database reads
- Configuration

**Internal boundaries (trust when safe):**
- Private functions with preconditions
- Package-internal functions
- Code you control

**Example:**

```go
// Public API - must validate
func (s *Server) CreateUser(email string) error {
    if email == "" {
        return ErrEmptyEmail
    }
    if !isValidEmail(email) {
        return ErrInvalidEmail
    }
    return s.store.Save(email)
}

// Internal function - can trust caller
func (s *store) save(email string) error {
    // email already validated, no need to re-check
    return s.db.Insert(email)
}
```

### Handle Errors Explicitly

**Don't ignore errors:**
```go
// BAD
result, _ := doSomething()

// GOOD
result, err := doSomething()
if err != nil {
    return fmt.Errorf("operation failed: %w", err)
}
```

**Don't panic in library code:**
```go
// BAD
if err != nil {
    panic(err)
}

// GOOD
if err != nil {
    return fmt.Errorf("failed: %w", err)
}
```

## Resource Management

### Clean Up Resources

**Always clean up:**
- File handles
- Network connections
- Database connections
- Locks
- Timers/tickers

**Use appropriate cleanup mechanism:**

**Go:**
```go
f, err := os.Open(filename)
if err != nil {
    return err
}
defer f.Close()
```

**Python:**
```python
with open(filename) as f:
    # file automatically closed
```

**C++:**
```cpp
{
    std::lock_guard<std::mutex> lock(mutex);
    // lock automatically released
}
```

### Avoid Resource Leaks

**Common leak sources:**
- Not closing connections
- Not cancelling contexts
- Not stopping goroutines/threads
- Not freeing allocated memory

## Testing Quality

### Write Testable Code

**Testable code is usually good code:**
- Small, focused functions
- Minimal dependencies
- Clear interfaces
- Deterministic behavior

### Test What Matters

**Focus testing on:**
- Business logic
- Edge cases
- Error conditions
- Complex algorithms

**Don't over-test:**
- Trivial getters/setters
- Third-party library behavior
- Framework internals

## Performance Quality

### Avoid Obvious Waste

**Common wasteful patterns:**
```go
// BAD - unnecessary allocations
for i := 0; i < n; i++ {
    s := fmt.Sprintf("item%d", i)  // allocates every iteration
}

// GOOD - preallocate or use builder
var b strings.Builder
for i := 0; i < n; i++ {
    b.WriteString("item")
    b.WriteString(strconv.Itoa(i))
}
```

```go
// BAD - reading file in loop
for _, id := range ids {
    data, _ := ioutil.ReadFile(filename)  // reads same file repeatedly
    process(data, id)
}

// GOOD - read once
data, err := ioutil.ReadFile(filename)
if err != nil {
    return err
}
for _, id := range ids {
    process(data, id)
}
```

### Don't Prematurely Optimize

**Optimize when:**
- Measured bottleneck
- Hot path (called frequently)
- User-requested performance improvement

**Don't optimize when:**
- No measurement
- Speculative ("might be slow")
- At cost of clarity (unless necessary)

## Code Organization Quality

### Logical Grouping

**Group related code:**
- Related functions together
- Related types together
- Clear separation between components

### Clear Dependencies

**Make dependencies explicit:**
- Import what you use
- Don't hide dependencies
- Minimize coupling
- Use dependency injection where appropriate

### Appropriate Abstraction Levels

**Don't mix levels:**

**Bad:**
```go
func processOrder(order Order) error {
    // High-level logic
    if err := validateOrder(order); err != nil {
        return err
    }

    // Low-level SQL (abstraction leak)
    db.Exec("INSERT INTO orders (id, amount) VALUES (?, ?)", order.ID, order.Amount)
}
```

**Good:**
```go
func processOrder(order Order) error {
    // High-level logic only
    if err := validateOrder(order); err != nil {
        return err
    }
    return saveOrder(order)
}

func saveOrder(order Order) error {
    // Low-level persistence logic
    return db.Exec("INSERT INTO orders (id, amount) VALUES (?, ?)", order.ID, order.Amount)
}
```

## Documentation Quality

### Document Non-Obvious Code

**When code is clear, don't document:**
```go
// BAD - comment adds nothing
// Set user name
user.Name = name
```

**When code is complex, do document:**
```go
// GOOD - explains non-obvious behavior
// Hash must be computed before signature verification because
// the signature is calculated over the hash, not the raw data.
hash := computeHash(data)
if !verify(hash, signature, publicKey) {
    return ErrInvalidSignature
}
```

### Keep Documentation Current

**Documentation must match code:**
- Update docs when changing behavior
- Remove docs for removed code
- Fix incorrect documentation immediately

**Stale documentation is worse than no documentation.**

## Quality Gates

**Before considering code complete:**

1. ✓ Code compiles/runs
2. ✓ Tests pass
3. ✓ Linter passes
4. ✓ Formatter passes
5. ✓ Solves the actual problem
6. ✓ Handles errors properly
7. ✓ No obvious security issues
8. ✓ Follows project conventions
9. ✓ Reasonably efficient
10. ✓ Adequately tested

## Language-Specific Standards

For language-specific quality standards and conventions:

- **Go**: See `domain/coding/go/` for comprehensive Go-specific guidance
  - Style conventions
  - Idioms and best practices
  - Performance optimization
  - Concurrency patterns
  - Testing standards
  - Code organization
  - Tooling and commands
