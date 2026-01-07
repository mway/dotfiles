# Test Coverage Standards

## Coverage Targets

### For New Code

**Target: 100% coverage** (ideal)
**Minimum: 80% coverage** (required)

**Why high coverage:**
- Catches bugs early
- Documents expected behavior
- Enables refactoring confidence
- Prevents regressions

### For Modified Code

**Update tests when behavior changes:**
- Add tests for new code paths
- Update existing tests for changed behavior
- Maintain or improve coverage percentage

### For Legacy Code

**Pragmatic approach:**
- Add tests when touching code
- Don't require 100% for unchanged legacy code
- Gradually improve coverage over time

## What Coverage Measures

### Line Coverage

**Most basic metric:**
- Percentage of lines executed during tests
- Easy to measure
- But can be gamed (execute line without asserting)

**Example:**
```go
func divide(a, b int) (int, error) {
    if b == 0 {                          // Line 1
        return 0, errors.New("div by 0") // Line 2
    }                                     // Line 3
    return a / b, nil                     // Line 4
}

// Only tests happy path - 50% line coverage
func TestDivide(t *testing.T) {
    result, err := divide(10, 2)
    require.NoError(t, err)
    require.Equal(t, 5, result)
}
```

### Branch Coverage

**Better metric:**
- Percentage of branches (if/else, switch) executed
- Ensures all code paths tested
- Harder to game

**Example:**
```go
func classify(age int) string {
    if age < 18 {        // Branch 1: true path
        return "minor"   // Branch 1: false path
    }
    return "adult"
}

// 100% branch coverage requires testing both paths
func TestClassify_Under18_ReturnsMinor(t *testing.T) {
    require.Equal(t, "minor", classify(10))
}

func TestClassify_18OrOver_ReturnsAdult(t *testing.T) {
    require.Equal(t, "adult", classify(18))
}
```

### Condition Coverage

**More thorough:**
- Each boolean sub-expression evaluated to both true and false
- Catches more complex logic bugs

**Example:**
```go
func canVote(age int, citizen bool) bool {
    return age >= 18 && citizen
}

// Need all combinations:
// age >= 18 = true, citizen = true   ✓
// age >= 18 = true, citizen = false  ✓
// age >= 18 = false, citizen = true  ✓
// age >= 18 = false, citizen = false ✓
```

## Measuring Coverage

### Go Coverage

**Generate coverage report:**
```bash
go test -race -count 1 -coverprofile=cover.out ./...
```

**View coverage in terminal:**
```bash
go tool cover -func=cover.out
```

**View coverage in browser:**
```bash
go tool cover -html=cover.out
```

**Check coverage percentage:**
```bash
go tool cover -func=cover.out | grep total
```

### Coverage by Package

**See which packages need work:**
```bash
go test -cover ./...

# Output:
ok      myapp/pkg/auth    0.123s  coverage: 95.2% of statements
ok      myapp/pkg/cache   0.045s  coverage: 87.5% of statements
ok      myapp/pkg/db      0.234s  coverage: 45.3% of statements  ← Needs work
```

## What to Cover

### Must Cover

**Critical paths:**
- Business logic
- Data transformations
- Validation functions
- Error handling
- Edge cases
- Boundary conditions

**Example:**
```go
func calculateDiscount(total float64, membershipYears int) float64 {
    // Must test:
    // - Normal case (total=100, years=2)
    // - Zero total (total=0, years=2)
    // - Negative total (total=-10, years=2)
    // - Zero years (total=100, years=0)
    // - High years (total=100, years=20)
    // - Boundary (total=100, years=5 vs years=6 if threshold)

    if total <= 0 {
        return 0
    }

    discount := 0.05 // Base 5%
    if membershipYears >= 5 {
        discount = 0.10 // 10% for long-term members
    }
    if membershipYears >= 10 {
        discount = 0.15 // 15% for very long-term
    }

    return total * discount
}
```

### Can Skip

**Trivial code:**
```go
// No need to test - trivial getter
func (u *User) GetName() string {
    return u.Name
}

// No need to test - simple constructor
func NewUser(name string) *User {
    return &User{Name: name}
}
```

**External dependencies:**
```go
// Don't test HTTP library behavior
resp, err := http.Get(url)  // Mock this instead
```

## Coverage Anti-Patterns

### Anti-Pattern 1: Gaming Coverage

**Bad - executes code but doesn't verify:**
```go
func TestProcess(t *testing.T) {
    process(data)
    // 100% line coverage, but tests nothing!
}
```

**Good - actually tests behavior:**
```go
func TestProcess_ValidData_ReturnsExpectedResult(t *testing.T) {
    result := process(data)
    require.Equal(t, expected, result)
}
```

### Anti-Pattern 2: Redundant Tests

**Bad - same test repeated:**
```go
func TestAdd_TwoPlusTwo_ReturnsFour(t *testing.T) {
    require.Equal(t, 4, add(2, 2))
}

func TestAdd_ThreePlusThree_ReturnsSix(t *testing.T) {
    require.Equal(t, 6, add(3, 3))
}
// Both test the same code path!
```

**Good - test different paths:**
```go
func TestAdd_PositiveNumbers_ReturnsSum(t *testing.T) {
    require.Equal(t, 4, add(2, 2))
}

func TestAdd_NegativeNumbers_ReturnsSum(t *testing.T) {
    require.Equal(t, -4, add(-2, -2))
}

func TestAdd_MixedSign_ReturnsSum(t *testing.T) {
    require.Equal(t, 0, add(-2, 2))
}
```

### Anti-Pattern 3: Untested Error Paths

**Bad - only tests success:**
```go
func TestSaveUser_ValidUser_Succeeds(t *testing.T) {
    err := saveUser(validUser)
    require.NoError(t, err)
}
// Error paths at 0% coverage!
```

**Good - tests both success and failures:**
```go
func TestSaveUser_ValidUser_Succeeds(t *testing.T) {
    err := saveUser(validUser)
    require.NoError(t, err)
}

func TestSaveUser_InvalidEmail_ReturnsError(t *testing.T) {
    user := User{Email: "invalid"}
    err := saveUser(user)
    require.Error(t, err)
}

func TestSaveUser_DatabaseError_ReturnsError(t *testing.T) {
    mockDB.SetError(errors.New("db error"))
    err := saveUser(validUser)
    require.Error(t, err)
}
```

## Improving Coverage

### 1. Identify Uncovered Code

**Use coverage tools to find gaps:**
```bash
go tool cover -html=cover.out
# Opens browser showing covered (green) and uncovered (red) lines
```

### 2. Write Tests for Uncovered Paths

**Focus on:**
- Red lines in coverage report
- Error handling paths
- Edge cases
- Rare branches

### 3. Refactor for Testability

**If code is hard to test, refactor it:**

**Before (hard to test):**
```go
func processOrder(orderID string) error {
    // Direct database access - hard to test
    db := sql.Open("postgres", "...")
    row := db.QueryRow("SELECT * FROM orders WHERE id = ?", orderID)

    var order Order
    if err := row.Scan(&order.ID, &order.Amount); err != nil {
        return err
    }

    // Direct email - hard to test
    smtp.SendMail("server", nil, "from", []string{"to"}, []byte("email"))

    return nil
}
```

**After (testable):**
```go
type OrderProcessor struct {
    db    Database      // Interface, can be mocked
    email EmailSender   // Interface, can be mocked
}

func (p *OrderProcessor) ProcessOrder(orderID string) error {
    order, err := p.db.GetOrder(orderID)
    if err != nil {
        return err
    }

    return p.email.SendConfirmation(order)
}

// Now easy to test with mocks
```

## Coverage in CI/CD

### Enforce Minimum Coverage

**Fail builds if coverage drops:**
```bash
#!/bin/bash
go test -coverprofile=cover.out ./...

coverage=$(go tool cover -func=cover.out | grep total | awk '{print $3}' | sed 's/%//')

if (( $(echo "$coverage < 80" | bc -l) )); then
    echo "Coverage $coverage% is below minimum 80%"
    exit 1
fi

echo "Coverage $coverage% meets requirements"
```

### Track Coverage Over Time

**Monitor trends:**
- Coverage should not decrease
- New code should maintain high coverage
- Gradual improvement in legacy areas

## Coverage vs. Quality

### Coverage ≠ Quality

**High coverage doesn't guarantee:**
- Tests are meaningful
- Tests verify correct behavior
- Tests catch bugs
- Code is correct

**But it does indicate:**
- Code is executed during tests
- Baseline safety net exists
- Regressions more likely caught

### Quality Tests with Good Coverage

**Aim for both:**
1. **High coverage** (80%+ minimum, 100% ideal)
2. **Meaningful tests** (verify behavior, not just execute code)
3. **Edge case testing** (boundaries, errors, unusual inputs)
4. **Clear test names** (document expected behavior)
5. **Fast execution** (tests run frequently)

## Summary Checklist

**For every new code:**

1. ✓ Write tests before/during implementation
2. ✓ Cover happy path
3. ✓ Cover error paths
4. ✓ Cover edge cases
5. ✓ Cover boundary conditions
6. ✓ Check coverage report
7. ✓ Aim for 100%, accept 80%+
8. ✓ Verify tests are meaningful
9. ✓ Ensure tests are fast
10. ✓ Verify tests are independent
