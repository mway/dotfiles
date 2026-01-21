# Go Testing Specifics

## Test Libraries

**Assertions:** `github.com/stretchr/testify`
- Use `require` subpackage (stops test on failure)
- NOT `assert` subpackage (continues after failure, can cause panics)

**Mocking:** `go.uber.org/mock`
- DO NOT use `github.com/golang/mock` (deprecated)
- Use `mockgen` for generating mocks

## Test File Organization

**File naming:**
- Code: `user.go`
- Tests: `user_test.go`
- Place tests next to code they test

**Package naming:**
```go
// Black-box testing (test exported API only)
package user_test

// White-box testing (can test internals)
package user
```

## Test Function Naming

**Format:** `Test<Function>_<Scenario>_<ExpectedResult>`

**Examples:**
```go
func TestCalculateTotal_WithDiscount_AppliesCorrectly(t *testing.T)
func TestValidateEmail_EmptyString_ReturnsError(t *testing.T)
func TestProcessOrder_Success_UpdatesInventory(t *testing.T)
```

## Test Structure (AAA Pattern)

```go
func TestFunction(t *testing.T) {
    // Arrange - setup
    input := setupTestData()

    // Act - execute
    result, err := function(input)

    // Assert - verify
    require.NoError(t, err)
    require.Equal(t, expected, result)
}
```

## Common Assertions

```go
require.NoError(t, err)
require.Error(t, err)
require.Equal(t, expected, actual)
require.NotEqual(t, value1, value2)
require.True(t, condition)
require.False(t, condition)
require.Nil(t, value)
require.NotNil(t, value)
require.Empty(t, collection)
require.NotEmpty(t, collection)
require.Len(t, collection, expectedLen)
require.Contains(t, haystack, needle)
require.ErrorIs(t, err, expectedErr)
```

## Table-Driven Tests

```go
func TestValidate(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        wantErr bool
    }{
        {
            name:    "valid input",
            input:   "valid",
            wantErr: false,
        },
        {
            name:    "empty string",
            input:   "",
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := validate(tt.input)
            if tt.wantErr {
                require.Error(t, err)
            } else {
                require.NoError(t, err)
            }
        })
    }
}
```

## Mocking with go.uber.org/mock

```go
// Generate mock
//go:generate mockgen -destination=mock_database.go -package=service Database

type Database interface {
    GetUser(id string) (*User, error)
}

// Use in test
func TestService(t *testing.T) {
    ctrl := gomock.NewController(t)
    defer ctrl.Finish()

    mockDB := NewMockDatabase(ctrl)
    mockDB.EXPECT().GetUser("123").Return(&User{ID: "123"}, nil)

    svc := NewService(mockDB)
    user, err := svc.GetUser("123")

    require.NoError(t, err)
    require.Equal(t, "123", user.ID)
}
```

## Test Helpers

```go
func setupTest(t *testing.T) func() {
    // Setup
    db := openTestDB()

    // Return cleanup function
    return func() {
        db.Close()
    }
}

func TestSomething(t *testing.T) {
    cleanup := setupTest(t)
    defer cleanup()

    // Test code
}
```

## Running Tests

```bash
# All tests
go test -race -count 1 ./...

# Specific package
go test -race -count 1 ./pkg/service

# Specific test
go test -race -count 1 -run TestFunctionName ./pkg/service

# Verbose
go test -v -race -count 1 ./...

# With coverage
go test -race -count 1 -coverprofile=cover.out ./...
```
