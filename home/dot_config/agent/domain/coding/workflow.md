# Coding Workflow

## General Principles

### Read Before Writing

**NEVER propose changes to code you haven't read.**

**Required sequence:**
1. Read the file(s) you'll modify
2. Understand existing patterns and style
3. Identify what needs to change
4. Make targeted modifications

**Why:**
- Understand context and existing patterns
- Avoid breaking existing functionality
- Match existing code style
- Identify related code that needs updating

### Understand Before Modifying

**Before making changes:**

1. **Read the target file**
2. **Understand dependencies** (what does this file use?)
3. **Find references** (what uses this file?)
4. **Check tests** (what behavior is expected?)
5. **Verify assumptions** (does it work how I think?)

### Make Minimal, Targeted Changes

**Avoid over-engineering:**
- Only change what's directly requested
- Don't add unrequested features
- Don't refactor surrounding code (unless necessary)
- Don't add "improvements" beyond the scope

**Examples:**

**Task: "Fix the null pointer bug in handler.go:42"**

**Good:**
```go
// handler.go:42
if user == nil {
    return fmt.Errorf("user is nil")
}
return user.Name
```

**Bad:**
```go
// Also refactored the entire function
// Also added logging
// Also added metrics
// Also renamed variables
// Also extracted helper functions
(All unrequested, scope creep)
```

### Avoid Unnecessary Additions

**Don't add without request:**
- Comments (unless code is non-obvious)
- Docstrings (unless you wrote the function)
- Type annotations (unless necessary)
- Error handling for impossible scenarios
- Feature flags for simple changes
- Abstractions for one-time use

**Add when appropriate:**
- Required for correctness
- Required for safety
- Makes non-obvious code clear
- Part of existing codebase pattern

## Step-by-Step Workflow

### 1. Understand the Request

**Clarify if needed:**
- What exactly needs to change?
- Are there constraints or requirements?
- Are there existing patterns to follow?
- Should this match a specific style?

### 2. Gather Context

**Read relevant files:**
- Files to be modified
- Related/dependent files
- Tests for these files
- Documentation

**Search when needed:**
- Find similar patterns in codebase
- Locate all references to symbols
- Identify related functionality

### 3. Plan the Changes

**Before coding:**
- What files need modification?
- What's the high-level approach?
- Are there edge cases to handle?
- Will this break existing code?
- Do tests need updating?

**Create TODO if multi-step.**

### 4. Implement

**Make changes systematically:**
- Follow the plan
- One logical change at a time
- Test incrementally if possible
- Update related code (tests, docs)

**Match existing style:**
- Use same patterns as surrounding code
- Follow same naming conventions
- Match same error handling approach
- Maintain same level of abstraction

### 5. Write Tests

**For new code:**
- Write tests for new functionality
- Cover happy path and edge cases
- Test error conditions
- Aim for high coverage

**For modified code:**
- Update existing tests if behavior changed
- Add tests if previously untested
- Verify no regressions

### 6. Verify

**Before considering done:**
- Run tests (all pass?)
- Run linter (no issues?)
- Format code (style compliant?)
- Manually verify (does it work?)

## Language-Specific Workflows

**See language-specific modules for details:**
- `languages/go/` for Go workflow
- `languages/python/` for Python workflow
- `languages/cpp/` for C++ workflow

## Testing Requirements

### Always Test New Functional Code

**"Functional code" means:**
- Business logic
- Data transformations
- Algorithms
- API handlers
- Database operations

**Not:**
- Simple getters/setters
- Trivial wrappers
- Code that can't be tested in isolation

### If Modifying Untested Code, Add Tests

**When changing existing code:**
- If no tests exist, write them first (characterization tests)
- If tests exist, update them for new behavior
- Don't leave modified code untested

### Test Coverage Expectations

**Target:**
- **100% coverage** for new code (ideal)
- **Minimum 80%** for new code (required)
- Cover all branches and edge cases

**Pragmatic:**
- Don't test trivial code
- Don't test external dependencies
- Focus on testing logic and behavior

## Code Organization

**Follow existing patterns:**
- If codebase groups by feature, group by feature
- If codebase groups by layer, group by layer
- If codebase has specific file naming, follow it
- Match the existing architecture

**Don't impose new patterns without discussion.**

## Error Handling

### Handle Errors Properly

**Don't ignore errors:**
```go
// BAD
result, _ := doSomething()

// GOOD
result, err := doSomething()
if err != nil {
    return fmt.Errorf("failed to do something: %w", err)
}
```

### But Don't Over-Handle

**Don't add error handling for:**
- Scenarios that can't happen
- Already-validated inputs
- Internal-only functions with guarantees

**Do add error handling for:**
- External inputs (user data, API calls)
- File/network operations
- Anything that can realistically fail

## Documentation

### When to Document

**Add documentation when:**
- Public APIs (always)
- Complex algorithms (non-obvious logic)
- Non-intuitive behavior (surprising edge cases)
- Required by language/ecosystem (e.g., Python docstrings)

**Don't add documentation for:**
- Obvious code (the code is the documentation)
- Private implementation details
- Code you didn't write (unless fixing existing docs)

### How to Document

**Good documentation:**
- Explains *why*, not *what*
- Describes edge cases and gotchas
- Includes examples when helpful
- Is concise and maintainable

**Poor documentation:**
```go
// Add adds two numbers
func Add(a, b int) int {
    return a + b  // Return the sum
}
```

**Good documentation:**
```go
// processToken validates and decodes a JWT token.
// Returns ErrInvalidToken if signature verification fails.
// Returns ErrExpiredToken if token is past its expiration.
func processToken(token string) (*Claims, error) {
    // ...
}
```

## Security Considerations

**Always check for:**
- SQL injection vulnerabilities
- Command injection vulnerabilities
- XSS vulnerabilities
- Path traversal vulnerabilities
- CSRF vulnerabilities
- Authentication/authorization bypasses

**If you introduce a vulnerability, fix it immediately.**

## Performance Considerations

**Default: prioritize correctness over performance.**

**Optimize when:**
- Performance is explicitly requested
- Code is in a hot path (measured)
- Obvious waste exists (O(n²) → O(n))

**Don't optimize:**
- Prematurely (before measuring)
- Speculatively (might need it faster later)
- At the cost of clarity (unless necessary)

## Confirmation and Communication

### When to Ask for Confirmation

**Always ask before:**
- Destructive operations
- Significant refactoring
- Changing public APIs
- Removing functionality
- Making architectural decisions

**Don't ask for trivial:**
- Adding a null check
- Fixing a typo
- Running tests
- Reading files

### Presenting Changes

**When showing planned changes:**
- Explain the approach clearly
- Highlight trade-offs made
- Note any assumptions
- Ask if approach is acceptable

**Before implementing, get buy-in on the plan.**

## Common Mistakes to Avoid

1. **Coding without reading existing code first**
2. **Over-engineering simple changes**
3. **Adding unrequested features**
4. **Ignoring existing patterns**
5. **Skipping tests**
6. **Not running verification before claiming done**
7. **Changing code style gratuitously**
8. **Breaking existing functionality**
9. **Introducing security vulnerabilities**
10. **Making assumptions without validation**
