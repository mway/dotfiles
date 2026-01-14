# mway's Go Coding Guidelines

## Scope

This guide defines Go coding guidelines for projects that adopt it. It uses the
Uber Go Style Guide (UGSG) as a baseline and adds explicit rules that supersede
or tighten UGSG where noted. The guide is the source of truth; analyzers may
enforce it but do not define it.

## Baseline: Uber Go Style Guide

Follow the [Uber Go Style Guide][ugsg] (herein referred to as UGSG) for all Go
code unless this guide explicitly outlines different guidance.

[ugsg]: https://raw.githubusercontent.com/uber-go/guide/master/style.md

## Additional Rules (Superset of UGSG)

### Organization and Type Layout

#### Types must be file-local and contiguous

- A type's full API surface must live in a single source file.
- If `type Foo` is defined in `foo.go`, then all of Foo's methods and
  constructors must be defined in `foo.go`.
- "Constructor" means any function that returns `Foo` or `*Foo` as its first
  or only return value (e.g., `NewFoo`, `ParseFoo`, `MustFoo`).
- Helper functions without Foo receivers may live elsewhere only when they are
  semantically closer to another type. If they return `Foo` or `*Foo` as the
  primary result, they are constructors and must stay with `Foo`.

Allowed exceptions (rare):

- Mutually exclusive build-tag variants. Each variant must still be complete:
  type + constructors + receivers within that tagged file.
- Generated files for generated types (same rule applies within the file).

#### Type definitions must not be interleaved

- Once a type definition begins, all of its constructors and receivers must
  appear as a single contiguous block.
- If a file contains multiple types, complete each type's block before
  starting the next type.

#### Definition ordering within a file (when applicable)

1. Package-level `const` group(s)
2. Package-level `var` group(s)
3. `init` / `main` func(s)
4. For each exported type (one type at a time, contiguous):
  - Type definition
  - Exported constructor(s)
  - Unexported constructor(s)
  - Exported receiver(s)
  - Unexported receiver(s)
5. Exported free functions
6. For each unexported type (one type at a time, contiguous):
  - Type definition
  - Exported constructor(s)
  - Unexported constructor(s)
  - Exported receiver(s)
  - Unexported receiver(s)
7. Unexported free functions

Notes:

- The type definition always precedes any constructors or receivers for that
  type.
- Const-based enums: the enum type definition immediately precedes the `const`
  block that enumerates its values (treat this block as "constructors" for
  ordering purposes).
- Ordering within a group is the author's choice (alphabetical or call-flow are
  both acceptable).

### Control Flow and Conditionals

#### Compound conditionals (fold/split)

- Prefer folding a directly preceding assignment into an `if` or `switch` init
  clause when safe and when the single-line header is within the configured
  line-length limit.
- If an `if` or `switch` init clause makes the single-line header exceed the
  line-length limit, split it into a separate assignment and conditional.
- Type switches are split-only; folding is not applicable.

#### Single-line conditional headers

Conditional headers must be on a single physical line. This includes:

- `if` / `else if` headers
- `for` headers (all clauses)
- `switch` and `type switch` headers
- `select` headers
- `case` and `default` clauses (including `select` cases)

If any part of a header spans multiple lines (including comments), it must be
rewritten to a single-line header (usually via a separate assignment).

### Declarations and Formatting

#### No compact declarations

Do not use packed types in declarations or signatures. This applies to:

- `var` and `const` declarations
- Function parameters and results
- Struct fields
- Interface method parameters and results

Examples:

```go
// BAD
var a, b int

// GOOD
var a int
var b int
```

```go
// BAD
func f(a, b int) {}

// GOOD
func f(
  a int,
  b int,
) {}
```

#### Multi-line lists: one-per-line or valid compact form

When a list spans multiple lines:

- For calls and composite literals, the list must be either:
  - One-per-line with trailing commas and closing delimiter on its own line, or
  - A valid compact form when at least one element is multi-line.
- For function signatures and struct fields, the list is strict: one-per-line
  with trailing commas and no compact form.

#### Group consecutive declarations

- Package-level consecutive `var` or `const` declarations without blank lines
  must be grouped into a single parenthesized block of the same kind.
- In function bodies, adjacent variable declarations (including compatible
  short declarations) without blank lines should be grouped into a `var (...)`
  block when safe.

### Imports

#### Import aliasing for non-stdlib packages

If a non-stdlib import's package name differs from the last path element, add
an explicit alias that matches the actual package name (underscores removed).

### Types and Structs

#### No embedding of sync.Mutex or sync.RWMutex

Do not embed `sync.Mutex` or `sync.RWMutex` (including aliases and named
wrappers). Always use a named field (e.g., `mu sync.Mutex`).

#### Interface compliance checks

Interface compliance checks must use `(*T)(nil)` rather than `T{}`:

```go
var _ io.Writer = (*MyWriter)(nil)
```

#### Struct embed ordering and spacing

In struct declarations:

- Embedded fields must appear before named fields.
- If both embedded and named fields are present, exactly one blank line must
  separate the groups.

### Initialization and Zero Values

#### Struct literal initialization

- All struct literals must use keyed fields.
- Struct literals with 2+ fields must be one-per-line with trailing commas and
  the closing brace on its own line.

#### Prefer zero-value declarations

If a variable is initialized to a zero value, prefer a zero-value declaration
without the explicit literal. This applies to `var` declarations and short
variable declarations, with standard exceptions (e.g., constants, multi-return
assignments, or init/range contexts).

### Safety and Correctness

#### Goroutine tracking with sync.WaitGroup

Prefer the simpler, modern form of `wg.Go(...)` when possible.

For every `go` statement:

- The immediately preceding statement must be `wg.Add(1)` with literal argument
  `1`.
- `wg.Add(1)` must be cuddled with the `go` statement (no blank lines between).
- The goroutine must invoke an anonymous function literal (not `go f()`),
  unless using `wg.Go` as described below.
- The first statement in the goroutine body must be `defer wg.Done()`.
- The `wg` used in `Add` and `Done` must be the same object.

For `wg.Go(func() { ... })` usage:

- Do not precede it with `wg.Add(1)`.
- Do not call `wg.Done()` manually inside the function body.

#### Unchecked type assertions

Unchecked type assertions must be rewritten to `must.As[T](x)` using
[go.mway.dev/x/must.As](https://pkg.go.dev/go.mway.dev/x/must#As):

```go
v := must.As[MyType](anyExpr)
```

Do not change assertions that capture the `ok` value (e.g., `v, ok := x.(T)`).

#### Safe pointer dereferences

Replace safe read-context dereferences with `ptr.Deref(x)`:

- Applies to RHS assignments, returns, function arguments (excluding nil-safe
  builtins), conditions, binary expressions, and channel send values.
- Does not apply to assignment targets, increment/decrement, compound
  assignments, `range`, or the `ptr` package itself.
