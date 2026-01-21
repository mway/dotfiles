# Go Idioms and Best Practices

## Accept Interfaces, Return Structs

```go
// Good
func ProcessData(r io.Reader) (*Result, error) {
    // Accepts interface (flexible)
    // Returns concrete type (clear)
}

// Less flexible
func ProcessData(f *os.File) (*Result, error) {
    // Requires specific type
}
```

## Error Handling

**Check errors explicitly:**
```go
// Good
result, err := doSomething()
if err != nil {
    return err
}

// Bad - ignoring error
result, _ := doSomething()
```

**Wrap errors for context:**
```go
if err := saveUser(user); err != nil {
    return fmt.Errorf("failed to save user %s: %w", user.ID, err)
}
```

## Prefer Explicit Over Implicit

```go
// Good - explicit
if user != nil {
    process(user)
}

// Bad - relying on zero value behavior
if user.ID != "" {  // Assumes uninitialized struct
    process(&user)
}
```

## Keep the Happy Path Left

**Minimize indentation:**
```go
// Good
func validate(user *User) error {
    if user == nil {
        return ErrNilUser
    }
    if user.Email == "" {
        return ErrMissingEmail
    }
    return nil
}

// Bad
func validate(user *User) error {
    if user != nil {
        if user.Email != "" {
            return nil
        }
        return ErrMissingEmail
    }
    return ErrNilUser
}
```

## Use defer for Cleanup

```go
f, err := os.Open(filename)
if err != nil {
    return err
}
defer f.Close()

// Use f safely
```

## Functional Options Pattern

**For complex constructors:**
```go
type Option func(*Server)

func WithTimeout(d time.Duration) Option {
    return func(s *Server) {
        s.timeout = d
    }
}

func NewServer(opts ...Option) *Server {
    s := &Server{
        timeout: 30 * time.Second,  // default
    }
    for _, opt := range opts {
        opt(s)
    }
    return s
}

// Usage
server := NewServer(
    WithTimeout(60*time.Second),
    WithMaxConns(100),
)
```

## Interfaces

**Small interfaces:**
```go
// Good - focused
type Reader interface {
    Read(p []byte) (n int, err error)
}

// Less good - kitchen sink
type FileHandler interface {
    Read() error
    Write() error
    Close() error
    Seek() error
    // ... many more
}
```

## Empty Interface Usage

**Avoid `interface{}` when possible:**
```go
// Bad - loses type safety
func Process(data interface{}) {
    // Need type assertions
}

// Good - use generics (Go 1.18+)
func Process[T any](data T) {
    // Type-safe
}
```

## Named Return Values

**Use sparingly:**
```go
// Good - when it improves clarity
func divmod(a int, b int) (quotient int, remainder int) {
    return a / b, a % b
}

// Bad - adds noise
func add(a int, b int) (result int) {
    return a + b  // "result" name adds nothing
}
```

## Init Functions

**Use sparingly:**
```go
// Acceptable
func init() {
    // Register with a global registry
    // Set up logging
    // Validate build-time constants
}

// Avoid heavy work in init
// Prefer explicit initialization
```

## Go Proverbs

- Don't communicate by sharing memory, share memory by communicating
- Concurrency is not parallelism
- Channels orchestrate; mutexes serialize
- The bigger the interface, the weaker the abstraction
- Make the zero value useful
- A little copying is better than a little dependency
- Clear is better than clever
- Errors are values
- Don't just check errors, handle them gracefully
