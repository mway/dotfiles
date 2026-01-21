# Go Code Organization

## File Organization

### Declaration Order Within Files

**Order:**
1. Package-level constants (exported first, separated from unexported)
2. Package-level variables (exported first, separated from unexported)
   - Errors separated from other vars
   - Interface assertions last (e.g., `var _ Foo = (*bar)(nil)`)
3. Exported types + their methods
4. Exported free functions
5. Unexported types + their methods
6. Unexported free functions

**For each type:**
1. Type definition
2. Exported constructors
3. Unexported constructors
4. Exported receivers
5. Unexported receivers

**Example:**
```go
package service

import (...)

// Constants - exported first
const (
    MaxRetries     = 3
    DefaultTimeout = 30 * time.Second
)

// Constants - unexported
const (
    _bufferSize = 1024
    _maxWorkers = 10
)

// Variables - exported
var (
    DefaultConfig = Config{...}
)

// Variables - unexported (regular)
var (
    _globalCache Cache
)

// Variables - errors
var (
    ErrNotFound = errors.New("not found")
    ErrInvalid  = errors.New("invalid")
)

// Variables - interface assertions
var (
    _ Service = (*serviceImpl)(nil)
)

// Exported type
type Service interface {
    Process(ctx context.Context) error
}

// Exported constructor
func NewService(cfg Config) Service {
    return &serviceImpl{cfg: cfg}
}

// Unexported type
type serviceImpl struct {
    cfg Config
}

// Exported methods
func (s *serviceImpl) Process(ctx context.Context) error {
    return s._processInternal(ctx)
}

// Unexported methods
func (s *serviceImpl) _processInternal(ctx context.Context) error {
    // ...
}

// Exported free functions
func ValidateConfig(cfg Config) error {
    // ...
}

// Unexported free functions
func _helper() {
    // ...
}
```

## Logical Block Organization

**Within functions, separate logical blocks:**
1. Variable declarations and setup
2. Core logic/operations
3. Return statements

**Example:**
```go
func ProcessOrder(order *Order) error {
    // Variable declarations and setup
    var (
        total    float64
        discount float64
        tax      float64
    )

    // Core logic
    for _, item := range order.Items {
        total += item.Price * float64(item.Quantity)
    }
    discount = calculateDiscount(total, order.CustomerTier)
    tax = calculateTax(total - discount)
    finalTotal := total - discount + tax

    // Update and return
    order.Total = finalTotal
    return saveOrder(order)
}
```

## Package Organization

### Standard Layout

```
myproject/
├── cmd/
│   └── myapp/
│       └── main.go
├── internal/
│   ├── auth/
│   ├── cache/
│   └── db/
├── pkg/
│   └── api/
├── go.mod
└── go.sum
```

- `cmd/`: Application entry points
- `internal/`: Private application code
- `pkg/`: Public libraries (reusable by other projects)

### Internal Packages

Code in `internal/` cannot be imported by external projects.

### File Naming

- `user.go` - main implementation
- `user_test.go` - tests
- Lowercase, underscore-separated for multi-word

## Spacing

**Use blank lines to separate:**
- Different logical blocks within functions
- Different sections of declarations
- Groups of related functions

**Don't add excessive spacing:**
```go
// Bad - too much spacing
func process() {


    doSomething()


    doSomethingElse()


}

// Good
func process() {
    doSomething()

    doSomethingElse()
}
```
