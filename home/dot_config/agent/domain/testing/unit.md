# Unit Testing Principles

## What is a Unit Test?

**Unit test characteristics:**
- Tests a single unit of code in isolation
- No external dependencies (databases, network, files)
- Fast execution (milliseconds)
- Deterministic (same input → same output)
- Independent (can run in any order)

## When to Write Unit Tests

### Always Test New Functional Code

**Write tests for:**
- Business logic
- Data transformations
- Algorithms
- Validation logic
- Utility functions
- Error handling paths

**Don't test:**
- Trivial getters/setters
- Simple constructors
- External library behavior
- Framework internals
- Configuration files

### Test Modified Code

**When changing existing code:**
- If tests exist → update them
- If no tests exist → write them first (characterization tests)
- Don't leave modified code untested

## Test Structure

### Arrange-Act-Assert (AAA) Pattern

```go
func TestCalculateTotalPrice(t *testing.T) {
    // Arrange - set up test data
    items := []Item{
        {Price: 10.00, Quantity: 2},
        {Price: 5.50, Quantity: 1},
    }

    // Act - execute the code under test
    total := calculateTotalPrice(items)

    // Assert - verify the result
    expected := 25.50
    if total != expected {
        t.Errorf("got %v, want %v", total, expected)
    }
}
```

### Clear Test Names

**Good test names describe what they test:**

```go
// GOOD - descriptive
func TestCalculateTotalPrice_WithMultipleItems_ReturnsSumOfPrices(t *testing.T)
func TestValidateEmail_WithInvalidFormat_ReturnsError(t *testing.T)
func TestProcessOrder_WhenInventoryInsufficient_ReturnsOutOfStockError(t *testing.T)

// BAD - vague
func TestCalculate(t *testing.T)
func TestValidate(t *testing.T)
func Test1(t *testing.T)
```

## Test Coverage

### Coverage Targets

**For new code:**
- **Target: 100%** (ideal)
- **Minimum: 80%** (required)

**Coverage means:**
- All branches tested (if/else, switch cases)
- All error paths tested
- All edge cases covered

**But don't game coverage:**
```go
// BAD - calls function but doesn't verify anything
func TestProcess(t *testing.T) {
    process(data)  // No assertions!
}

// GOOD - actually verifies behavior
func TestProcess(t *testing.T) {
    result := process(data)
    if result.Status != "success" {
        t.Error("expected successful processing")
    }
}
```

### What to Cover

**Test these scenarios:**
1. **Happy path** - normal, expected inputs
2. **Edge cases** - boundary values, empty inputs, maximums
3. **Error cases** - invalid inputs, error conditions
4. **Business rules** - all stated requirements
5. **Regressions** - previously found bugs

## Isolation and Mocking

### Isolate Units

**Unit tests should not depend on:**
- Databases
- File systems
- Network calls
- External APIs
- System time
- Random values

### Use Mocks/Stubs for Dependencies

```go
// Code under test
type UserService struct {
    db Database
}

func (s *UserService) GetUser(id string) (*User, error) {
    return s.db.FindUser(id)
}

// Test with mock
type MockDatabase struct {
    FindUserFn func(id string) (*User, error)
}

func (m *MockDatabase) FindUser(id string) (*User, error) {
    return m.FindUserFn(id)
}

func TestGetUser_Found_ReturnsUser(t *testing.T) {
    // Arrange
    expectedUser := &User{ID: "123", Name: "Alice"}
    mockDB := &MockDatabase{
        FindUserFn: func(id string) (*User, error) {
            return expectedUser, nil
        },
    }
    service := &UserService{db: mockDB}

    // Act
    user, err := service.GetUser("123")

    // Assert
    require.NoError(t, err)
    require.Equal(t, expectedUser, user)
}
```

## Table-Driven Tests

**For testing multiple scenarios:**

```go
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name    string
        email   string
        wantErr bool
    }{
        {
            name:    "valid email",
            email:   "user@example.com",
            wantErr: false,
        },
        {
            name:    "missing @",
            email:   "userexample.com",
            wantErr: true,
        },
        {
            name:    "missing domain",
            email:   "user@",
            wantErr: true,
        },
        {
            name:    "empty string",
            email:   "",
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := validateEmail(tt.email)
            if (err != nil) != tt.wantErr {
                t.Errorf("validateEmail() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}
```

## Assertions

### Use Testing Libraries

**Prefer assertion libraries for clarity:**

```go
import "github.com/stretchr/testify/require"

// GOOD - clear, concise
require.NoError(t, err)
require.Equal(t, expected, actual)
require.True(t, condition)
require.Nil(t, value)

// Acceptable but more verbose
if err != nil {
    t.Fatalf("unexpected error: %v", err)
}
if expected != actual {
    t.Fatalf("got %v, want %v", actual, expected)
}
```

**Prefer `require` over `assert`:**
```go
// GOOD - stops test on failure
require.NoError(t, err)      // Stops here if error
result := useValue(value)    // Safe to continue

// BAD - continues after failure
assert.NoError(t, err)       // Logs failure but continues
result := useValue(value)    // Might panic if value is nil!
```

## Error Testing

**Test error conditions explicitly:**

```go
func TestDivide_ByZero_ReturnsError(t *testing.T) {
    _, err := divide(10, 0)
    require.Error(t, err)
    require.Contains(t, err.Error(), "division by zero")
}

func TestProcessOrder_InsufficientInventory_ReturnsSpecificError(t *testing.T) {
    err := processOrder(order)
    require.Error(t, err)
    require.ErrorIs(t, err, ErrOutOfStock)
}
```

## Testing Best Practices

### 1. Tests Should Be Readable

**Clarity over cleverness:**
```go
// GOOD - clear what's being tested
func TestUserAge_Under18_IsMinor(t *testing.T) {
    user := User{Age: 15}
    require.True(t, user.IsMinor())
}

// BAD - unclear
func TestUser(t *testing.T) {
    u := User{Age: 15}
    if !u.IsMinor() {
        t.Error("fail")
    }
}
```

### 2. Tests Should Be Independent

**No test should depend on another:**
```go
// BAD - tests depend on order
var sharedState *User

func TestCreateUser(t *testing.T) {
    sharedState = createUser()  // Sets global state
}

func TestUpdateUser(t *testing.T) {
    updateUser(sharedState)  // Depends on previous test!
}

// GOOD - each test independent
func TestCreateUser(t *testing.T) {
    user := createUser()
    require.NotNil(t, user)
}

func TestUpdateUser(t *testing.T) {
    user := createUser()  // Create own test data
    updateUser(user)
    require.Equal(t, "updated", user.Status)
}
```

### 3. Tests Should Be Fast

**Slow tests won't be run:**
- Mock external dependencies
- Use in-memory databases if needed
- Avoid sleeps/waits
- Keep scope focused

### 4. One Assertion Per Test (Generally)

**Focus on one behavior:**
```go
// GOOD - tests one thing
func TestCalculateTotal_WithDiscount_AppliesDiscount(t *testing.T) {
    total := calculateTotal(100, 0.1)
    require.Equal(t, 90.0, total)
}

// GOOD - tests one thing
func TestCalculateTotal_WithoutDiscount_ReturnsFullPrice(t *testing.T) {
    total := calculateTotal(100, 0)
    require.Equal(t, 100.0, total)
}

// ACCEPTABLE - related assertions for same scenario
func TestCreateUser_ValidInput_ReturnsUserWithCorrectFields(t *testing.T) {
    user := createUser("alice", "alice@example.com")
    require.Equal(t, "alice", user.Name)
    require.Equal(t, "alice@example.com", user.Email)
    require.NotEmpty(t, user.ID)
}

// BAD - testing multiple unrelated behaviors
func TestUser(t *testing.T) {
    user := createUser("alice", "alice@example.com")
    require.NotNil(t, user)

    updateUser(user)
    require.Equal(t, "updated", user.Status)

    deleteUser(user)
    _, err := getUser(user.ID)
    require.Error(t, err)
}
```

### 5. Setup and Teardown

**Use setup/teardown when appropriate:**

```go
func TestMain(m *testing.M) {
    // Setup
    setup()

    // Run tests
    code := m.Run()

    // Teardown
    teardown()

    os.Exit(code)
}

func TestSomething(t *testing.T) {
    // Per-test setup
    cleanup := setupTest()
    defer cleanup()

    // Test code
}
```

## Common Mistakes

### Mistake 1: Testing Implementation, Not Behavior

```go
// BAD - tests internal implementation
func TestSort_UsesQuickSort(t *testing.T) {
    // Checks that quicksort algorithm is used
}

// GOOD - tests behavior
func TestSort_ReturnsSortedSlice(t *testing.T) {
    input := []int{3, 1, 2}
    result := sort(input)
    require.Equal(t, []int{1, 2, 3}, result)
}
```

### Mistake 2: Brittle Tests

**Don't test irrelevant details:**
```go
// BAD - breaks if log format changes
func TestProcess(t *testing.T) {
    log := captureLog()
    process()
    require.Equal(t, "[INFO] Processing started at 2024-01-01 12:00:00", log)
}

// GOOD - tests relevant behavior only
func TestProcess(t *testing.T) {
    log := captureLog()
    process()
    require.Contains(t, log, "Processing started")
}
```

### Mistake 3: Insufficient Test Data

**Test realistic scenarios:**
```go
// BAD - trivial test data
func TestCalculateDiscount(t *testing.T) {
    discount := calculateDiscount(0, 0)
    require.Equal(t, 0.0, discount)
}

// GOOD - realistic test data
func TestCalculateDiscount_PremiumUser_Gets20Percent(t *testing.T) {
    user := User{IsPremium: true}
    order := Order{Total: 100.00}
    discount := calculateDiscount(user, order)
    require.Equal(t, 20.00, discount)
}
```

### Mistake 4: Not Testing Error Paths

**Test failure cases:**
```go
// Incomplete - only tests happy path
func TestProcessOrder(t *testing.T) {
    order := validOrder()
    err := processOrder(order)
    require.NoError(t, err)
}

// Complete - tests both success and failure
func TestProcessOrder_ValidOrder_Succeeds(t *testing.T) {
    order := validOrder()
    err := processOrder(order)
    require.NoError(t, err)
}

func TestProcessOrder_InvalidOrder_ReturnsError(t *testing.T) {
    order := invalidOrder()
    err := processOrder(order)
    require.Error(t, err)
}
```

## Test Organization

**File naming:**
- `code.go` → `code_test.go`
- Place test file next to code it tests
- Use `_test` package for black-box testing

**Function naming:**
- `Test<FunctionName>_<Scenario>_<ExpectedResult>`
- Examples:
  - `TestCalculateTotal_WithDiscount_AppliesDiscount`
  - `TestValidateEmail_EmptyString_ReturnsError`
  - `TestProcessOrder_Success_UpdatesInventory`
