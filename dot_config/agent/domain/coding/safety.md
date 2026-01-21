# Code Safety

## Overview

Code safety encompasses two critical areas:
1. **Runtime Safety** - preventing crashes, corruption, and undefined behavior
2. **Security Safety** - preventing vulnerabilities and malicious exploitation

Both are non-negotiable. Code must be safe from both accidental failures and intentional attacks.

---

## Part 1: Runtime Safety

### Runtime Safety Mindset

**Code must not:**
- Crash or panic unexpectedly
- Corrupt data or memory
- Enter undefined behavior states
- Leak resources
- Race on shared state
- Deadlock or livelock

**Even when:**
- Inputs are unexpected
- Execution is nondeterministic
- System is under load
- Dependencies fail

### Critical Runtime Safety Issues

#### 1. Null/Nil Pointer Dereferences

**Problem:** Accessing memory through null/nil pointers crashes programs.

**Prevention:**
```go
// Bad - can panic
func getName(user *User) string {
    return user.Name  // Panics if user is nil
}

// Good - defensive
func getName(user *User) string {
    if user == nil {
        return ""
    }
    return user.Name
}
```

**Check for nil:**
- Before dereferencing pointers
- After type assertions
- When receiving from channels (check if closed)

#### 2. Array/Buffer Overflows

**Problem:** Accessing beyond array bounds causes crashes or undefined behavior.

**Prevention:**
```go
// Bad - can panic
func getElement(arr []int, idx int) int {
    return arr[idx]  // Panics if idx out of bounds
}

// Good - bounds checking
func getElement(arr []int, idx int) (int, error) {
    if idx < 0 || idx >= len(arr) {
        return 0, ErrOutOfBounds
    }
    return arr[idx], nil
}
```

**Always:**
- Validate indices before array access
- Check buffer capacity before writes
- Use safe slicing operations

#### 3. Data Races

**Problem:** Concurrent access to shared mutable state without synchronization causes corruption.

**Prevention:**
```go
// Bad - race condition
var counter int

func increment() {
    counter++  // Not atomic, causes race
}

// Good - synchronized
var (
    counter int
    mu      sync.Mutex
)

func increment() {
    mu.Lock()
    defer mu.Unlock()
    counter++
}

// Also good - atomic
var counter atomic.Int64

func increment() {
    counter.Add(1)
}
```

**Always:**
- Protect shared state with mutexes or atomics
- Run tests with race detector (`-race` flag)
- Avoid sharing mutable state when possible

#### 4. Deadlocks

**Problem:** Circular wait on locks causes permanent hang.

**Prevention:**
- Establish lock ordering and follow it consistently
- Use timeouts on lock acquisition when appropriate
- Avoid holding locks across I/O operations
- Use `defer` to ensure unlocking

```go
// Consistent lock ordering prevents deadlocks
type Account struct {
    mu      sync.Mutex
    balance int
}

func transfer(from, to *Account, amount int) {
    // Always lock in consistent order (by pointer address)
    first, second := from, to
    if uintptr(unsafe.Pointer(from)) > uintptr(unsafe.Pointer(to)) {
        first, second = to, from
    }

    first.mu.Lock()
    defer first.mu.Unlock()

    second.mu.Lock()
    defer second.mu.Unlock()

    from.balance -= amount
    to.balance += amount
}
```

#### 5. Resource Leaks

**Problem:** Not releasing resources causes memory exhaustion or resource starvation.

**Common sources:**
- File handles not closed
- Network connections not closed
- Database connections not returned to pool
- Goroutines not terminated
- Timers not stopped

**Prevention:**
```go
// Always use defer for cleanup
file, err := os.Open(filename)
if err != nil {
    return err
}
defer file.Close()

// Ensure goroutines can exit
func worker(ctx context.Context) {
    for {
        select {
        case <-ctx.Done():
            return  // Goroutine exits
        case work := <-workChan:
            process(work)
        }
    }
}
```

#### 6. Integer Overflow/Underflow

**Problem:** Arithmetic operations exceeding type bounds cause wraparound.

**Prevention:**
```go
// Check before arithmetic in critical code
func add(a, b uint32) (uint32, error) {
    if a > math.MaxUint32-b {
        return 0, ErrOverflow
    }
    return a + b, nil
}

// For sizes/allocations, check before multiplying
func allocateMatrix(rows, cols int) ([][]int, error) {
    if rows > 0 && cols > math.MaxInt/rows {
        return nil, ErrTooLarge
    }
    // Safe to allocate
}
```

#### 7. Stack Overflow

**Problem:** Excessive recursion or large stack allocations exhaust stack space.

**Prevention:**
- Limit recursion depth
- Use iteration over recursion when possible
- Allocate large buffers on heap, not stack

```go
// Bad - unbounded recursion
func fibonacci(n int) int {
    if n <= 1 {
        return n
    }
    return fibonacci(n-1) + fibonacci(n-2)
}

// Good - iterative with depth limit
func fibonacci(n int) (int, error) {
    if n > 1000 {
        return 0, ErrDepthExceeded
    }
    a, b := 0, 1
    for i := 0; i < n; i++ {
        a, b = b, a+b
    }
    return a, nil
}
```

#### 8. Use-After-Free / Dangling Pointers

**Problem:** Accessing memory after it's been freed (in languages with manual memory management).

**In Go:** Rare due to garbage collection, but can occur with unsafe code or finalizers.

**Prevention:**
- Avoid `unsafe` package unless absolutely necessary
- Be careful with finalizers
- Don't hold pointers to memory that might be reclaimed

#### 9. Uninitialized Memory

**Problem:** Reading memory before initialization yields undefined values.

**In Go:** Less common due to zero values, but can occur with:
- Uninitialized struct fields
- Channel receives before sends
- Map reads before writes (returns zero value, not error)

**Prevention:**
- Rely on zero values
- Initialize explicitly when zero value isn't appropriate
- Check map access with two-value form: `val, ok := m[key]`

### Runtime Safety Checklist

**Before marking code complete:**

- [ ] No nil pointer dereferences possible
- [ ] All array/slice accesses bounds-checked
- [ ] No data races (test with `-race`)
- [ ] No deadlock potential
- [ ] All resources properly cleaned up
- [ ] No integer overflow in critical paths
- [ ] Recursion depth limited
- [ ] No unsafe memory operations
- [ ] All error paths handled

---

## Part 2: Security Safety

### Security-First Mindset

**Always consider security implications:**
- Every user input is potentially malicious
- Every external API could return bad data
- Every file operation could be exploited
- Trust must be earned, not assumed

### Common Vulnerability Classes (OWASP Top 10)

### 1. Injection Attacks

#### SQL Injection

**Never construct queries with string concatenation:**

**DANGEROUS:**
```go
query := "SELECT * FROM users WHERE id = " + userID
db.Query(query)
```

**SAFE:**
```go
query := "SELECT * FROM users WHERE id = ?"
db.Query(query, userID)
```

```python
# DANGEROUS
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")

# SAFE
cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
```

#### Command Injection

**Never pass unsanitized input to shell:**

**DANGEROUS:**
```go
cmd := exec.Command("sh", "-c", "ls "+userPath)
```

**SAFE:**
```go
cmd := exec.Command("ls", userPath)  // No shell interpretation
```

**Better:**
```go
// Validate/sanitize userPath first
if !isValidPath(userPath) {
    return ErrInvalidPath
}
cmd := exec.Command("ls", userPath)
```

### 2. Cross-Site Scripting (XSS)

**Always escape user content in HTML:**

**DANGEROUS:**
```html
<div>{{ userInput }}</div>
```

**SAFE:**
```html
<div>{{ userInput | escape }}</div>
```

**In JavaScript:**
```javascript
// DANGEROUS
element.innerHTML = userInput;

// SAFE
element.textContent = userInput;
```

### 3. Broken Authentication

**Password handling:**
```go
// NEVER store plaintext passwords
// NEVER use weak hashing (MD5, SHA1)

// GOOD - use bcrypt or argon2
import "golang.org/x/crypto/bcrypt"

func hashPassword(password string) (string, error) {
    hash, err := bcrypt.GenerateFromPassword(
        []byte(password),
        bcrypt.DefaultCost,
    )
    return string(hash), err
}

func verifyPassword(password, hash string) bool {
    err := bcrypt.CompareHashAndPassword(
        []byte(hash),
        []byte(password),
    )
    return err == nil
}
```

**Session management:**
- Use cryptographically random session IDs
- Regenerate session ID on privilege change
- Expire sessions appropriately
- Secure session cookies (HttpOnly, Secure, SameSite)

### 4. Sensitive Data Exposure

**Never log sensitive data:**
```go
// BAD
log.Printf("User login: email=%s, password=%s", email, password)

// GOOD
log.Printf("User login: email=%s", email)
```

**Protect secrets:**
```go
// BAD - hardcoded secret
const apiKey = "sk_live_abc123"

// GOOD - from environment
apiKey := os.Getenv("API_KEY")
if apiKey == "" {
    return errors.New("API_KEY not set")
}
```

### 5. Broken Access Control

**Always verify authorization:**
```go
func deleteUser(requestUser User, targetUserID string) error {
    // BAD - no authorization check
    return db.Delete(targetUserID)

    // GOOD - verify permission
    if !requestUser.IsAdmin && requestUser.ID != targetUserID {
        return ErrUnauthorized
    }
    return db.Delete(targetUserID)
}
```

### 6. Security Misconfiguration

**Secure defaults:**
- HTTPS only in production
- Secure cookie flags
- Proper CORS configuration
- Minimal exposed services
- Least privilege principles

### 7. Cross-Site Request Forgery (CSRF)

**Protect state-changing operations:**
- Use CSRF tokens for forms
- Verify Origin/Referer headers
- Use SameSite cookie attribute

### 8. Insecure Deserialization

**Never deserialize untrusted data without validation:**

```go
// BAD
var data UserData
json.Unmarshal(untrustedInput, &data)
useData(data)

// GOOD
var data UserData
if err := json.Unmarshal(untrustedInput, &data); err != nil {
    return err
}
if err := validateUserData(data); err != nil {
    return err
}
useData(data)
```

### 9. Using Components with Known Vulnerabilities

**Keep dependencies updated:**
- Regularly update dependencies
- Monitor security advisories
- Use dependency scanning tools
- Remove unused dependencies

### 10. Insufficient Logging & Monitoring

**Log security-relevant events:**
- Authentication attempts (success and failure)
- Authorization failures
- Input validation failures
- Application errors

**But don't log sensitive data:**
- Passwords
- Session tokens
- Credit card numbers
- Personal information

## Input Validation

### Validate at System Boundaries

**Always validate:**
- HTTP request parameters
- File uploads
- API responses
- Configuration files
- Command-line arguments

### Validation Strategies

**Allowlist over blocklist:**
```go
// BAD - trying to block bad chars
func isValidUsername(s string) bool {
    badChars := []string{"<", ">", "&", "'", "\""}
    for _, char := range badChars {
        if strings.Contains(s, char) {
            return false
        }
    }
    return true
}

// GOOD - only allow good chars
func isValidUsername(s string) bool {
    match := regexp.MustCompile(`^[a-zA-Z0-9_-]{3,20}$`)
    return match.MatchString(s)
}
```

**Validate type, length, format, range:**
```go
func validateAge(age int) error {
    if age < 0 || age > 150 {
        return ErrInvalidAge
    }
    return nil
}

func validateEmail(email string) error {
    if len(email) > 254 {
        return ErrEmailTooLong
    }
    if !emailRegex.MatchString(email) {
        return ErrInvalidEmailFormat
    }
    return nil
}
```

## Path Traversal Prevention

**Never trust user-supplied file paths:**

```go
// DANGEROUS
func serveFile(userPath string) {
    http.ServeFile(w, r, userPath)
    // User could supply "../../../../etc/passwd"
}

// SAFE
func serveFile(filename string) error {
    // Validate filename has no path separators
    if strings.Contains(filename, "/") || strings.Contains(filename, "\\") {
        return ErrInvalidFilename
    }

    // Build safe path
    safePath := filepath.Join(allowedDir, filepath.Clean(filename))

    // Verify path is within allowed directory
    if !strings.HasPrefix(safePath, allowedDir) {
        return ErrPathTraversal
    }

    http.ServeFile(w, r, safePath)
    return nil
}
```

## Cryptography

### Use Standard Libraries

**Don't roll your own crypto:**
- Use established libraries (OpenSSL, Go crypto, etc.)
- Use standard algorithms (AES-GCM, ChaCha20-Poly1305)
- Use standard key derivation (PBKDF2, Argon2)

### Generate Secure Random Values

```go
// DANGEROUS - predictable
import "math/rand"
token := rand.Int()

// SAFE - cryptographically secure
import "crypto/rand"

func generateToken() (string, error) {
    b := make([]byte, 32)
    if _, err := rand.Read(b); err != nil {
        return "", err
    }
    return hex.EncodeToString(b), nil
}
```

### Proper Key Management

- Never hardcode keys
- Rotate keys periodically
- Store keys securely (HSM, key vault)
- Use different keys for different purposes

## Race Conditions & Concurrency

### Protect Shared State

```go
// DANGEROUS - race condition
var counter int

func increment() {
    counter++  // NOT atomic
}

// SAFE - mutex protection
var (
    counter int
    mu      sync.Mutex
)

func increment() {
    mu.Lock()
    defer mu.Unlock()
    counter++
}

// OR - atomic operations
var counter atomic.Int64

func increment() {
    counter.Add(1)
}
```

### Avoid TOCTOU (Time-of-Check Time-of-Use)

```go
// DANGEROUS - file could change between check and use
if fileExists(path) {
    data := readFile(path)  // File might not exist now!
}

// SAFE - handle errors from actual operation
data, err := readFile(path)
if err != nil {
    if os.IsNotExist(err) {
        // Handle missing file
    }
    return err
}
```

## Resource Limits

### Prevent Resource Exhaustion

**Limit sizes:**
```go
// HTTP handler
func upload(w http.ResponseWriter, r *http.Request) {
    // Limit request body size
    r.Body = http.MaxBytesReader(w, r.Body, 10<<20)  // 10MB max

    // ... process upload
}
```

**Set timeouts:**
```go
client := &http.Client{
    Timeout: 10 * time.Second,
}

ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()
```

**Limit concurrency:**
```go
// Limit concurrent goroutines
sem := make(chan struct{}, maxConcurrent)

for _, item := range items {
    sem <- struct{}{}  // Acquire
    go func(item Item) {
        defer func() { <-sem }()  // Release
        process(item)
    }(item)
}
```

## Error Handling

### Don't Leak Sensitive Info in Errors

```go
// BAD - leaks internal details
return fmt.Errorf("database connection failed: host=db.internal.corp, user=admin")

// GOOD - generic message
return errors.New("database connection failed")
// Log details internally, don't expose to user
```

### Fail Securely

**On error, deny access by default:**
```go
func checkAccess(user User) error {
    hasAccess, err := db.CheckPermission(user)
    if err != nil {
        // On error, DENY access (fail closed)
        return ErrAccessDenied
    }
    if !hasAccess {
        return ErrAccessDenied
    }
    return nil
}
```

## Security Checklist

**Before marking code complete, verify:**

1. ✓ No SQL injection vulnerabilities
2. ✓ No command injection vulnerabilities
3. ✓ No XSS vulnerabilities
4. ✓ No path traversal vulnerabilities
5. ✓ Input validation at boundaries
6. ✓ Output encoding/escaping
7. ✓ Authentication properly implemented
8. ✓ Authorization checks in place
9. ✓ Secrets not hardcoded
10. ✓ Sensitive data not logged
11. ✓ Secure random for security-critical values
12. ✓ Proper error handling (fail securely)
13. ✓ Resource limits in place
14. ✓ No race conditions in shared state
15. ✓ Dependencies up-to-date

**If you introduce a vulnerability, fix it immediately.**
