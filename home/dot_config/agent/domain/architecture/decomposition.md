# Problem Decomposition

## Breaking Down Complex Problems

### Principles of Good Decomposition

**A well-decomposed problem has:**

1. **Atomic subproblems** - each piece is indivisible and complete
2. **Clear interfaces** - subproblems have well-defined inputs and outputs
3. **Minimal coupling** - subproblems are as independent as possible
4. **Testable units** - each subproblem can be verified in isolation
5. **Appropriate granularity** - not too coarse, not too fine

### The Decomposition Process

#### Step 1: Identify the Core Problem

**Ask:**
- What is the actual problem to solve?
- What are the desired outcomes?
- What constraints exist?

**Example:**
```
Request: "Add user authentication"

Core problem: Enable verified access control
Outcomes: Users can log in/out, protected endpoints verify identity
Constraints: Must be secure, performant, maintainable
```

#### Step 2: Break Into Major Components

**Identify high-level pieces:**

```
Authentication system:
1. Identity verification (login)
2. Session management (tokens)
3. Access control (authorization)
4. Security (password handling)
```

#### Step 3: Decompose Each Component

**Break each major piece into atomic tasks:**

```
Identity verification:
- Design credential schema
- Implement password validation
- Create login endpoint
- Handle login errors
- Add rate limiting

Session management:
- Design token format
- Implement token generation
- Implement token validation
- Add token refresh mechanism
- Handle token expiration

Access control:
- Create authorization middleware
- Define permission model
- Implement permission checks
- Add role-based access

Security:
- Hash passwords with bcrypt
- Add salt to hashes
- Implement secure token signing
- Add HTTPS requirement
- Set up CORS properly
```

#### Step 4: Identify Dependencies

**Map what must happen before what:**

```
Dependencies:
- Password hashing BEFORE login endpoint (needed by it)
- Token generation BEFORE token validation (validation needs to know format)
- Login endpoint BEFORE authorization middleware (middleware uses login)

Can parallelize:
- Password hashing || Token generation (independent)
- Login endpoint || Logout endpoint (independent)
- Unit tests (all can run concurrently)
```

#### Step 5: Order by Critical Path

**Prioritize:**
1. Foundational pieces (everything depends on these)
2. Critical path items (longest/most complex)
3. Dependent items (after their dependencies)
4. Independent items (parallelize these)

### Decomposition Patterns

#### Pattern 1: Layer by Abstraction Level

**Good for:** Architectural changes, system design

```
High-level: API layer
Mid-level: Business logic layer
Low-level: Data access layer

Break down each layer independently.
```

#### Pattern 2: Decompose by Component

**Good for:** Feature additions, modular systems

```
Component A: User management
Component B: Authentication
Component C: Authorization

Each component broken into implementation, tests, docs.
```

#### Pattern 3: Decompose by Workflow

**Good for:** End-to-end features, user stories

```
Workflow: User login
1. Present login form
2. Validate credentials
3. Generate session
4. Redirect to dashboard

Each step broken into frontend + backend + tests.
```

#### Pattern 4: Decompose by Risk/Complexity

**Good for:** Large projects, unknown scope

```
Highest risk/complexity first:
1. Novel algorithms
2. External integrations
3. Performance-critical code
4. Well-understood CRUD
```

### Testing Your Decomposition

**Good decomposition passes these checks:**

1. **Completeness:** Does it cover everything needed?
2. **Non-redundancy:** Is each task unique?
3. **Testability:** Can each piece be verified?
4. **Independence:** Can pieces be built in parallel?
5. **Clarity:** Is it obvious what each task means?

### Common Decomposition Mistakes

#### Mistake 1: Too Coarse

```
WRONG:
- Implement authentication

(What does this include? Can't track progress.)
```

#### Mistake 2: Too Fine

```
WRONG:
- Import crypto library
- Create password variable
- Call hash function
- Store result
- Return result

(Too granular, overhead exceeds value.)
```

#### Mistake 3: Mixing Abstraction Levels

```
WRONG:
- Design auth system
- Write login function
- Deploy to production

(Mixing high-level and low-level tasks.)
```

#### Mistake 4: Missing Dependencies

```
WRONG:
Parallel tasks:
- Write integration tests (needs implementation!)
- Implement feature

(Can't test what doesn't exist yet.)
```

#### Mistake 5: Non-Atomic Tasks

```
WRONG:
- Add error handling and logging and metrics

(Three separate concerns, should be three tasks.)
```

### Examples of Good Decomposition

#### Example 1: Add Caching

```
Problem: API responses are slow, add caching

Decomposition:
1. Design cache interface
   - Define cache operations (get, set, delete)
   - Determine cache key strategy
   - Decide on TTL policy

2. Implement cache backend
   - Choose backend (in-memory vs Redis)
   - Implement interface for chosen backend
   - Add connection pooling (if Redis)

3. Integrate with API
   - Add caching middleware
   - Implement cache-aside pattern
   - Handle cache misses
   - Handle cache errors gracefully

4. Add cache invalidation
   - Invalidate on updates
   - Invalidate on deletes
   - Add manual flush endpoint

5. Testing
   - Unit test cache interface
   - Unit test integration logic
   - Integration test full flow
   - Load test for performance

6. Observability
   - Add cache hit/miss metrics
   - Add cache size metrics
   - Add performance logging
```

#### Example 2: Debug Performance Issue

```
Problem: Application is slow under load

Decomposition:
1. Reproduce the issue
   - Set up load testing environment
   - Create load test script
   - Confirm issue reproduces

2. Gather data
   - Profile CPU usage
   - Profile memory usage
   - Profile database queries
   - Check network I/O

3. Analyze data
   - Identify hotspots in profiles
   - Look for memory leaks
   - Find slow queries
   - Check for N+1 queries

4. Hypothesize root cause
   - Form hypothesis from data
   - Predict what fix would help
   - Estimate impact of fix

5. Implement fix
   - Make targeted change
   - Verify in isolation
   - Benchmark improvement

6. Verify resolution
   - Re-run load tests
   - Compare before/after metrics
   - Check for regressions
   - Validate in staging
```

#### Example 3: Refactor Legacy Code

```
Problem: Monolithic function needs refactoring

Decomposition:
1. Understand current code
   - Read and document what it does
   - Identify all side effects
   - Map all dependencies
   - Find all callers

2. Add tests (if missing)
   - Write characterization tests
   - Cover all branches
   - Verify current behavior

3. Extract pure functions
   - Identify pure logic
   - Extract to separate functions
   - Test extracted functions
   - Verify original behavior unchanged

4. Separate concerns
   - Identify distinct responsibilities
   - Create focused functions for each
   - Test each concern independently
   - Integrate back together

5. Remove duplication
   - Find repeated patterns
   - Extract common logic
   - Parameterize differences
   - Test consolidated code

6. Clean up
   - Rename for clarity
   - Add documentation
   - Remove dead code
   - Final test run
```

## Integration with Planning

**Decomposition feeds directly into planning:**

1. Decompose problem → get list of atomic tasks
2. Identify dependencies → determine ordering
3. Find parallelizable work → spawn subagents
4. Create TODO list → track progress
5. Execute systematically → complete tasks one by one

**The decomposition becomes your roadmap.**
