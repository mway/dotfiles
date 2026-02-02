# Engineering Principles

## Overview

These are foundational software engineering principles that guide decision-making across all contexts - not just coding, but problem-solving, task decomposition, communication, and agent behavior.

**Universal application:**
- These principles apply to writing code
- They also apply to designing solutions
- They guide how to break down problems
- They inform communication and interaction patterns
- They shape how work is organized and executed

## Core Principles

### Single Responsibility Principle (SRP)

**Definition:** Each unit (function, class, module, task) should have one and only one reason to change. Do one thing, do it well.

**In code:**
```go
// Bad - multiple responsibilities
func ProcessUserAndSendEmail(user User) error {
    if err := validateUser(user); err != nil {
        return err
    }
    if err := saveUser(user); err != nil {
        return err
    }
    return sendWelcomeEmail(user)
}

// Good - single responsibilities
func ProcessUser(user User) error {
    if err := validateUser(user); err != nil {
        return err
    }
    return saveUser(user)
}

func SendWelcomeEmail(user User) error {
    return sendEmail(user.Email, "Welcome!")
}
```

**In agent behavior:**
- Each TODO item should address one specific task
- Don't combine "run tests AND fix errors" into one task
- Break work into focused, single-purpose units
- Each subagent should have one clear objective

**Reference:** https://en.wikipedia.org/wiki/Single-responsibility_principle

### Separation of Concerns (SoC)

**Definition:** Separate a system into distinct sections, each addressing a separate concern. Minimize overlap between responsibilities.

**In code:**
```go
// Bad - mixed concerns
func HandleRequest(w http.ResponseWriter, r *http.Request) {
    // Validation
    if r.Method != "POST" { ... }
    // Business logic
    result := processData(data)
    // Database access
    db.Exec("INSERT ...")
    // Logging
    log.Println("Request processed")
}

// Good - separated concerns
func HandleRequest(w http.ResponseWriter, r *http.Request) {
    if err := validateRequest(r); err != nil {
        return err
    }
    result := service.Process(data)
    return repository.Save(result)
}
```

**In agent behavior:**
- Separate planning from execution
- Don't mix requirements gathering with implementation
- Keep different types of work in different tasks
- Organize modules by concern (core/, domain/, languages/)

**Reference:** https://en.wikipedia.org/wiki/Separation_of_concerns

### Unix Philosophy

**Definition:**
1. Make each program do one thing well
2. Expect output to be input to another program
3. Design and build for composability
4. Favor simplicity over complexity

**In code:**
```bash
# Unix way - compose simple tools
cat file.txt | grep "error" | wc -l

# Not Unix way - monolithic tool that does everything
mega-tool --read file.txt --filter "error" --count
```

**In agent behavior:**
- Each module does one thing well (core/behavior.md, not core/everything.md)
- Modules compose together via profiles
- Keep TODO items focused and composable
- Build simple solutions that chain together

**Reference:** https://en.wikipedia.org/wiki/Unix_philosophy

### Principle of Least Astonishment (POLA)

**Definition:** The system should behave in a way that most users expect it to behave. Minimize surprises.

**In code:**
```go
// Bad - surprising behavior
func GetUser(id string) *User {
    user := db.Find(id)
    user.LastAccessed = time.Now()  // Surprising side effect!
    db.Save(user)
    return user
}

// Good - no surprises
func GetUser(id string) *User {
    return db.Find(id)
}
```

**In agent behavior:**
- Don't make destructive changes without asking
- Communicate clearly what will happen before doing it
- Follow established patterns consistently
- Match user's mental model of how things should work

**Reference:** https://en.wikipedia.org/wiki/Principle_of_least_astonishment

### Robustness Principle (Postel's Law)

**Definition:** "Be conservative in what you do, be liberal in what you accept from others."

**In code:**
```go
// Liberal in accepting input
func ParseDate(input string) (time.Time, error) {
    // Accept multiple formats
    for _, format := range []string{"2006-01-02", "01/02/2006", "Jan 2, 2006"} {
        if t, err := time.Parse(format, input); err == nil {
            return t, nil
        }
    }
    return time.Time{}, ErrInvalidFormat
}

// Conservative in output
func FormatDate(t time.Time) string {
    return t.Format("2006-01-02")  // Always use ISO format
}
```

**In agent behavior:**
- Accept user input in various forms (casual language, technical terms)
- Interpret requests generously
- Provide output in consistent, predictable format
- Handle edge cases gracefully

**Reference:** https://en.wikipedia.org/wiki/Robustness_principle

### Boy Scout Rule

**Definition:** "Always leave the campground cleaner than you found it." - Robert C. Martin (Clean Code)

**In code:**
```go
// When touching code, improve it
func processOrder(order Order) error {
    // Found this code with poor naming
    // Fixed it while here:
    // OLD: var o = validateO(order)
    // NEW:
    isValid := validateOrder(order)
    if !isValid {
        return ErrInvalidOrder
    }

    return saveOrder(order)
}
```

**In agent behavior:**
- Fix nearby issues when working in an area
- Improve documentation when you read it
- Clean up code style when making changes
- But don't let scope creep - stay focused on primary task

### Principle of Least Privilege (POLP)

**Definition:** Grant only the minimum access/permissions necessary to complete a task.

**In code:**
```go
// Bad - too much access
func GetUserName(db *Database) string {
    // Has full database access but only needs to read users
    return db.Query("SELECT name FROM users WHERE id = 1")
}

// Good - minimal access
type UserReader interface {
    GetUserName(id string) (string, error)
}

func GetUserName(reader UserReader, id string) (string, error) {
    return reader.GetUserName(id)
}
```

**In agent behavior:**
- Request only necessary permissions
- Don't read files you won't use
- Don't access systems you don't need
- Minimize scope of changes

**Reference:** https://en.wikipedia.org/wiki/Principle_of_least_privilege

### Law of Demeter (LoD) - Principle of Least Knowledge

**Definition:** A unit should only talk to its immediate neighbors. Don't reach through objects.

**In code:**
```go
// Bad - violates LoD (reaches through multiple objects)
func ProcessOrder(order *Order) {
    street := order.Customer.Address.Street  // Reaches too far
}

// Good - respects LoD
func ProcessOrder(order *Order) {
    street := order.GetShippingStreet()  // Ask, don't reach
}

func (o *Order) GetShippingStreet() string {
    return o.Customer.GetAddressStreet()
}
```

**In agent behavior:**
- Work with appropriate abstractions
- Don't bypass layers
- Use proper interfaces
- Minimize coupling between components

**Reference:** https://en.wikipedia.org/wiki/Law_of_Demeter

### Well-Defined API Boundaries and Contracts

**Definition:** Clear interfaces, explicit contracts, minimal assumptions about internals.

**In code:**
```go
// Good - clear contract
type Cache interface {
    Get(key string) (value string, found bool)
    Set(key string, value string) error
    Delete(key string) error
}

// Contract is explicit:
// - Get returns found=false if key doesn't exist
// - Set returns error if operation fails
// - Delete is idempotent
```

**In agent behavior:**
- Clear task boundaries (what's in scope, what's not)
- Explicit success/failure criteria
- Well-defined inputs and outputs
- Document assumptions and constraints

### Defensive Design

**Definition:** Design systems to be resilient to misuse, errors, and unexpected input.

**In code:**
```go
// Defensive design
func Divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, ErrDivisionByZero
    }
    return a / b, nil
}

func ProcessUser(user *User) error {
    if user == nil {
        return ErrNilUser
    }
    if user.Email == "" {
        return ErrMissingEmail
    }
    return process(user)
}
```

**In agent behavior:**
- Validate inputs before processing
- Handle edge cases explicitly
- Anticipate failure modes
- Provide helpful error messages

**Reference:** https://en.wikipedia.org/wiki/Defensive_design

### Defensive Programming

**Definition:** Write code that handles errors and unexpected conditions gracefully.

**In code:**
```go
// Defensive programming
file, err := os.Open(filename)
if err != nil {
    return fmt.Errorf("failed to open %s: %w", filename, err)
}
defer file.Close()

data := make([]byte, 0, expectedSize)
// Check bounds before access
if index < len(data) {
    value := data[index]
}
```

**In agent behavior:**
- Check preconditions before acting
- Verify assumptions with data
- Handle failures gracefully
- Provide recovery paths

**Reference:** https://en.wikipedia.org/wiki/Defensive_programming

### Single Source of Truth (SSOT)

**Definition:** Information should be stored in exactly one place. Avoid duplication.

**In code:**
```go
// Bad - duplicated constants
const MaxRetries = 3
const MaxAttempts = 3  // Duplication!

// Good - single source
const MaxRetries = 3
```

**In agent behavior:**
- Don't repeat information unnecessarily
- Reference existing documentation rather than duplicating
- Maintain TODO list in one place
- Avoid redundant explanations

**Reference:** https://en.wikipedia.org/wiki/Single_source_of_truth

### You Aren't Gonna Need It (YAGNI)

**Definition:** Don't add functionality until it's actually needed. Avoid speculative generality.

**In code:**
```go
// Bad - premature generalization
type Processor interface {
    Process(data interface{}) interface{}
    ProcessBatch(data []interface{}) []interface{}
    ProcessAsync(data interface{}) <-chan interface{}
    // ... methods we might need someday
}

// Good - implement what's needed now
type Processor interface {
    Process(data Data) (Result, error)
}
```

**In agent behavior:**
- Don't over-plan solutions
- Implement what's requested, not what might be needed
- Avoid adding unrequested features
- Focus on current requirements

**Reference:** https://en.wikipedia.org/wiki/You_aren%27t_gonna_need_it

## Clean Code Principles

**Source:** [Clean Code Summary](https://gist.githubusercontent.com/mway/b439796e644d448bdf48e0395dbdff5b/raw/d154f8584e018e4c9fe48c1ede286ce58eb48aca/clean-code-summary.md)

### Central Philosophy
"Clean code can be read and enhanced by a developer other than its original author."

Goals: understandability, readability, changeability, maintainability.

### Key Guidelines

**Simplicity:**
- Reduce complexity wherever possible
- Simple solutions over complex ones
- Clear over clever

**Naming:**
- Descriptive, unambiguous, pronounceable names
- Named constants over magic numbers
- Avoid type encodings and Hungarian notation

**Functions:**
- Small and focused
- Single responsibility
- Minimal arguments (0-2 ideal, 3 acceptable, 4+ reconsider)
- No side effects
- No flag parameters (split into separate functions)

**Structure:**
- Related code stays together vertically
- Variables declared near usage
- Proper indentation and line length
- Logical organization

**Testing:**
- Readable, fast, independent tests
- One assertion per test (generally)
- Test names describe behavior

**Comments:**
- Prefer self-documenting code
- Comment intent, not mechanics
- Explain why, not what
- Update or remove stale comments

**Code Smells to Avoid:**
- Rigidity (hard to change)
- Fragility (breaks in unexpected places)
- Immobility (hard to reuse)
- Needless complexity
- Duplication

## When Principles Conflict

**Priority order when principles conflict:**

1. **Correctness** - code must work correctly
2. **Safety** - no vulnerabilities or data loss
3. **Simplicity** - YAGNI and SRP over premature abstraction
4. **Readability** - Clean Code over cleverness
5. **Performance** - only when measured and necessary

**Common conflicts:**

**DRY vs. YAGNI:**
- YAGNI wins - don't abstract until you have 3+ instances
- Some duplication is better than wrong abstraction

**POLA vs. Robustness:**
- Be liberal in accepting input (Robustness)
- But remain predictable in behavior (POLA)
- Balance: accept varied input, normalize internally, produce consistent output

**Performance vs. Clean Code:**
- Clean Code wins by default
- Optimize only measured bottlenecks
- Keep optimizations localized and documented

**Defensive Programming vs. YAGNI:**
- Defend at system boundaries (user input, external APIs)
- Trust internal code (YAGNI for impossible error cases)

## Application Checklist

**When designing:**
- [ ] Does this follow SRP? (one responsibility)
- [ ] Are concerns separated appropriately?
- [ ] Is this the simplest solution? (YAGNI)
- [ ] Will behavior surprise users? (POLA)
- [ ] Are boundaries and contracts clear?

**When implementing:**
- [ ] Is code defensive at boundaries?
- [ ] Does it follow Law of Demeter?
- [ ] Am I leaving it better than I found it? (Boy Scout)
- [ ] Is this composable? (Unix Philosophy)
- [ ] Am I duplicating information? (SSOT)

**When reviewing:**
- [ ] Is it clean and readable?
- [ ] Does each function do one thing?
- [ ] Are names clear and descriptive?
- [ ] Is complexity justified?
- [ ] Are there code smells?
