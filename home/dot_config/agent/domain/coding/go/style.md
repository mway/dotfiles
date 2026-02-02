# Go Style Guide

## General Guidance

**Primary reference:** [Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md)

**Fundamentals:**
- [Effective Go](https://go.dev/doc/effective_go)
- [Go Language Spec](https://tip.golang.org/ref/spec)
- [Go Memory Model](https://tip.golang.org/ref/mem)

## Import Organization

### Import Grouping (Three Groups)

```go
import (
    // Group 1: Standard library
    "context"
    "fmt"
    "sync"
    "time"

    // Group 2: Third-party packages
    "github.com/pkg/errors"
    "github.com/spf13/cobra"
    zlog "github.com/rs/zerolog/log"

    // Group 3: Local packages (github.com/user/repo/...)
    "github.com/this/repo/internal/auth"
    "github.com/this/repo/internal/cache"
    "github.com/this/repo/pkg/utils"
)
```

**Rules:**
1. Standard library first
2. Then third-party (grouped together)
3. Then local packages (github.com/user/repo/...)
4. Blank line between groups
5. Alphabetical within each group

**Import alias for zerolog:**
```go
zlog "github.com/rs/zerolog/log"
```

Always use `zlog` as the alias for `github.com/rs/zerolog/log`.

## Go Version

**Target: Go 1.25.x**

Use modern Go features including:
- `sync.WaitGroup.Go()` for goroutine management (Go 1.25+)
- Loop variable scoping fix - no more reassignment needed to avoid shadowing bugs (Go 1.23+)
- Range over integers: `for i := range 10` works as it reads (Go 1.23+)
- Other quality-of-life improvements from recent releases

## Line Length

**Maximum: 79 characters** (applies to ALL languages, not just Go)

Enforced by `golines` formatter.

**Note:** If project-level AGENT.md specifies different line length, use that instead and update golines `--max-len` parameter.

### Breaking Long Lines

**Function calls:**
```go
// Each argument on its own line, including closing paren
result := myLongFunctionName(
    firstArgument,
    secondArgument,
    thirdArgument,
)
```

**Struct literals:**
```go
user := User{
    ID:        "123",
    Name:      "Alice",
    Email:     "alice@example.com",
    CreatedAt: time.Now(),
}
```

**Slice/map literals:**
```go
items := []string{
    "first",
    "second",
    "third",
}

config := map[string]interface{}{
    "timeout":  30,
    "retries":  3,
    "endpoint": "https://api.example.com",
}
```

## Naming Conventions

### Exported Identifiers (CamelCase)

```go
// Types
type UserService struct { }
type HTTPHandler struct { }

// Functions
func ProcessOrder() { }
func ValidateEmail() { }

// Constants
const MaxRetries = 3
const DefaultTimeout = 30 * time.Second

// Variables
var GlobalConfig Config
```

### Unexported Identifiers (_camelCase with leading underscore)

```go
// Functions
func _processInternal() { }
func _validateToken() { }

// Variables
var _cache Cache
var _defaultConfig Config

// Types (if truly internal)
type _cacheImpl struct { }
```

### Descriptive Names

**Variables:**
```go
// Good
var userCount int
var isAuthenticated bool
var requestTimeout time.Duration

// Bad
var uc int
var auth bool
var t time.Duration
```

**Functions:**
```go
// Good (verb + noun)
func calculateTotalPrice()
func validateEmailAddress()
func sendNotification()

// Bad (vague)
func process()
func handle()
func do()
```

## Error Handling

### Early Returns

```go
// Good
func process(user *User) error {
    if user == nil {
        return ErrNilUser
    }
    if !user.IsActive {
        return ErrInactiveUser
    }

    return doProcessing(user)
}

// Bad
func process(user *User) error {
    if user != nil {
        if user.IsActive {
            return doProcessing(user)
        } else {
            return ErrInactiveUser
        }
    } else {
        return ErrNilUser
    }
}
```

### Error Wrapping

**Use `fmt.Errorf` with `%w` verb:**
```go
result, err := doSomething()
if err != nil {
    return fmt.Errorf("failed to do something: %w", err)
}
```

**Custom error types:**
```go
type HTTPError struct {
    Code    int
    Message string
    Err     error
}

func (e *HTTPError) Error() string {
    return fmt.Sprintf("HTTP %d: %s", e.Code, e.Message)
}

func (e *HTTPError) Unwrap() error {
    return e.Err
}
```

## JSON Tags

**Use snake_case with omitempty:**
```go
type User struct {
    ID        string    `json:"id"`
    FirstName string    `json:"first_name,omitempty"`
    LastName  string    `json:"last_name,omitempty"`
    Email     string    `json:"email"`
    CreatedAt time.Time `json:"created_at"`
}
```

## Struct Tags (General)

**Use snake_case for json/yaml/mapstructure:**
```go
type Config struct {
    ServerPort int    `json:"server_port" yaml:"server_port" mapstructure:"server_port"`
    DBHost     string `json:"db_host" yaml:"db_host" mapstructure:"db_host"`
}
```

## Constants

**Use TitleCase for exported constants:**
```go
const (
    MaxConnections     = 100
    DefaultTimeout     = 30 * time.Second
    APIVersion         = "v1"
)

const (
    StatusPending  = "pending"
    StatusApproved = "approved"
    StatusRejected = "rejected"
)
```

## Variable Declarations

### Group in var Blocks

**Good:**
```go
var (
    timeout       = 30 * time.Second
    maxRetries    = 3
    enableLogging = true
)
```

**Exception: Cuddling**

Don't use `var` blocks when cuddling with usage:

```go
// Good - cuddled with usage
err := doSomething()
if err != nil {
    return err
}

// Bad - separated from usage
var err error
err = doSomething()

if err != nil {
    return err
}
```

### Variable Cuddling

**Cuddle (attach) variables to their usage blocks:**

```go
// Good
items := make([]string, 0, 10)
for i := 0; i < 10; i++ {
    items = append(items, fmt.Sprintf("item%d", i))
}

// Bad - unnecessary blank line
items := make([]string, 0, 10)

for i := 0; i < 10; i++ {
    items = append(items, fmt.Sprintf("item%d", i))
}
```

## Conditionals

### Prefer Compound Conditionals When They Fit

**If an assignment can be scoped to a conditional AND the result fits on one line (≤79 chars), use compound form:**

**Good:**
```go
if err := doSomething(); err != nil {
    return err
}
// err not accessible after this block
```

**Bad (when compound would fit):**
```go
err := doSomething()
if err != nil {
    return err
}
// err still in scope unnecessarily
```

**Good (when compound wouldn't fit on one line):**
```go
err := doSomethingWithLongName(
    param1,
    param2,
    param3,
    param4,
)
if err != nil {
    return err
}
```

**Rule:** If compound form would be valid and well-styled, use it. Otherwise, split it.

### NEVER Use Multiline Conditionals

**Multiline conditionals are completely banned:**

**Bad:**
```go
if err := doSomethingThatDoesntFitOnOneLine(
    param1,
    param2,
    param3,
); err != nil {
    return err
}
```

**Bad:**
```go
if foo(
    bar,
    baz,
    bat,
) {
    // ...
}
```

**Always separate the assignment from the conditional when it doesn't fit:**
```go
err := doSomethingThatDoesntFitOnOneLine(
    param1,
    param2,
    param3,
)
if err != nil {
    return err
}
```

## Zero Values

### Use var for Zero Values

**Good:**
```go
var users []User           // nil slice (useful zero value)
var count int               // 0
var enabled bool            // false
var config Config           // zero-valued struct
```

**Bad:**
```go
users := []User{}           // Empty slice, not nil
users := make([]User, 0)    // Empty slice, not nil
```

**Exception: Maps**

Maps don't have useful zero values:
```go
// Good
cache := make(map[string]string)

// Bad
var cache map[string]string  // nil map, can't write to it
```

## Line Breaks

**When breaking into multiple lines, ALWAYS use one item per line (including closing paren/brace):**

This applies to:
- Function calls
- Function signatures
- Struct literals
- Slice/map literals
- All parameterized constructs

**Good:**
```go
result := myMultiLineFunctionCall(
    foo,
    bar,
    baz,
)

func wrappedSignature(
    foo string,
    bar string,
    baz string,
) {
    // ...
}
```

**Bad:**
```go
result := myMultilineFunctionCall(foo,
    bar, baz)

// Bad - multiple items on one line
func poorlyWrappedSignature(
    bar string, baz string,
)

// Bad - closing paren not on own line
result := myMultilineFunctionCall(
    foo,
    bar,
    baz)

// Bad - first item on signature line
func poorlyWrappedSignature(foo string,
    bar string,
    baz string)
```

## Switch Statements

### Always Include default Case

```go
switch status {
case "pending":
    return processPending()
case "approved":
    return processApproved()
case "rejected":
    return processRejected()
default:
    return fmt.Errorf("unknown status: %s", status)
}
```

### Prefer Switch for Multiple Conditions

**Good:**
```go
switch {
case age < 13:
    return "child"
case age < 18:
    return "teen"
case age < 65:
    return "adult"
default:
    return "senior"
}
```

**Bad:**
```go
if age < 13 {
    return "child"
} else if age < 18 {
    return "teen"
} else if age < 65 {
    return "adult"
} else {
    return "senior"
}
```

## Parameter and Field Types

### NEVER Omit Types (No "Packing")

**Packing is completely banned:**

**Bad:**
```go
func foo(a, b, c string) {  // BANNED - types must be explicit
}

type Foo struct {
    a, b, c string  // BANNED - types must be explicit
}
```

**Good:**
```go
func foo(a string, b string, c string) {
}

type Foo struct {
    a string
    b string
    c string
}
```

## Struct Initialization

### Always Initialize by Name

**Positional field initialization is banned:**

**Bad:**
```go
user := User{"123", "Alice", "alice@example.com"}  // BANNED
```

**Good:**
```go
user := User{
    ID:    "123",
    Name:  "Alice",
    Email: "alice@example.com",
}
```

### Always One Field Per Line

**Each field on its own line, even for simple structs:**

**Bad:**
```go
point := Point{X: 0, Y: 0}  // BANNED - fields must be on separate lines
```

**Good:**
```go
point := Point{
    X: 0,
    Y: 0,
}
```

### Prefer Literals Over Zero Values + Assignments

**Good:**
```go
user := User{
    ID:    "123",
    Name:  "Alice",
    Email: "alice@example.com",
}
```

**Bad (when literal would work):**
```go
var user User
user.ID = "123"
user.Name = "Alice"
user.Email = "alice@example.com"
```

## Branching and Nesting

### Minimize Nesting

**Prefer early returns:**

```go
// Good
func validate(user *User) error {
    if user == nil {
        return ErrNilUser
    }
    if user.Email == "" {
        return ErrMissingEmail
    }
    if !validEmailFormat(user.Email) {
        return ErrInvalidEmail
    }
    return nil
}

// Bad
func validate(user *User) error {
    if user != nil {
        if user.Email != "" {
            if validEmailFormat(user.Email) {
                return nil
            } else {
                return ErrInvalidEmail
            }
        } else {
            return ErrMissingEmail
        }
    } else {
        return ErrNilUser
    }
}
```

## Comments

### When to Comment

**Comment non-obvious code:**
```go
// Hash must be computed before verification because the signature
// is calculated over the hash, not the raw data.
hash := computeHash(data)
verified := verifySignature(hash, signature, publicKey)
```

**Don't comment obvious code:**
```go
// BAD - comment adds nothing
// Set the user name
user.Name = name

// Increment the counter
counter++
```

### Package Comments

**Every package should have a package comment:**
```go
// Package auth provides authentication and authorization functionality.
//
// It supports JWT tokens, session management, and role-based access control.
package auth
```

### Exported Function Comments

**Document exported functions:**
```go
// ProcessOrder validates and processes a customer order.
//
// Returns ErrInvalidOrder if the order fails validation.
// Returns ErrInsufficientInventory if items are out of stock.
func ProcessOrder(order *Order) error {
    // ...
}
```

## Goroutine Management

### Always Track and Clean Up Goroutines

**All goroutines MUST be tracked and cleaned up.**

**Fire-and-forget is banned except in special circumstances.**

**Prefer `sync.WaitGroup.Go()` (Go 1.25+):**
```go
var wg sync.WaitGroup

wg.Go(func() {
    processItem(item)
})

wg.Wait()  // Ensures all goroutines complete
```

**Alternative with traditional WaitGroup:**
```go
var wg sync.WaitGroup

wg.Add(1)
go func() {
    defer wg.Done()
    processItem(item)
}()

wg.Wait()
```

**Use better situational options when appropriate:**
- `errgroup.Group` for error propagation
- Channels for producer/consumer patterns
- Context for cancellation

## Cancellation and Signal Propagation

### Prefer Context Over Raw Channels

**For cancel signal propagation, prefer `context.Context` + `context.CancelFunc`:**

**Good:**
```go
ctx, cancel := context.WithCancel(parentCtx)
defer cancel()

go worker(ctx)

// Later...
cancel()  // Propagates cancellation
```

**Good (when select is useful):**
```go
func worker(ctx context.Context) {
    for {
        select {
        case <-ctx.Done():
            return
        case work := <-workCh:
            process(work)
        }
    }
}
```

**Avoid (unless context not feasible):**
```go
var (
    mu   sync.Mutex
    stop bool
)

// Polling pattern - avoid when context would work
for {
    mu.Lock()
    if stop {
        mu.Unlock()
        return
    }
    mu.Unlock()
    // ...
}
```

**Use context when:**
- Propagation is possible
- `select` is useful rather than polling
- Standard cancellation patterns apply
