# Go Performance Best Practices

## Priority

1. Reduce CPU cycles
2. Minimize memory allocations
3. Reduce memory pressure

## Avoid Unnecessary Allocations

**String concatenation:**
```go
// Bad - allocates on every iteration
result := ""
for _, s := range strings {
    result += s  // New allocation each time
}

// Good - single allocation
var b strings.Builder
for _, s := range strings {
    b.WriteString(s)
}
result := b.String()
```

**Preallocate slices:**
```go
// Bad - grows dynamically
var items []string
for i := 0; i < 1000; i++ {
    items = append(items, fmt.Sprintf("item%d", i))
}

// Good - preallocated
items := make([]string, 0, 1000)
for i := 0; i < 1000; i++ {
    items = append(items, fmt.Sprintf("item%d", i))
}
```

## Leverage Zero Values

**Zero values are free:**
```go
// Good - zero value is useful
var users []User  // nil slice, no allocation
var count int     // 0, no allocation

// Unnecessary
users := make([]User, 0)  // Allocates empty slice
count := 0                // Same as zero value
```

## Object Pooling

**For frequently allocated objects:**
```go
var bufferPool = sync.Pool{
    New: func() interface{} {
        return new(bytes.Buffer)
    },
}

func process(data []byte) {
    buf := bufferPool.Get().(*bytes.Buffer)
    defer bufferPool.Put(buf)
    buf.Reset()

    // Use buf
}
```

## Efficient Error Handling

**Avoid allocation in hot paths:**
```go
// Bad - allocates error every call
if value < 0 {
    return fmt.Errorf("value must be positive")
}

// Good - sentinel error, allocated once
var ErrNegativeValue = errors.New("value must be positive")

if value < 0 {
    return ErrNegativeValue
}
```

## Profiling

```bash
# CPU profile
go test -cpuprofile=cpu.prof -bench=.
go tool pprof cpu.prof

# Memory profile
go test -memprofile=mem.prof -bench=.
go tool pprof mem.prof

# Benchmarks
go test -bench=. -benchmem ./...
```

## When to Optimize

**Do optimize:**
- Measured bottlenecks
- Hot paths (frequently called)
- Obvious waste (O(n²) → O(n))

**Don't optimize:**
- Without measurement
- Before correctness
- Speculatively
