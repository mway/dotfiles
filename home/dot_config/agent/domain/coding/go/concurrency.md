# Go Concurrency Patterns

## Mutex Usage

**Always use defer:**
```go
// Good
func (c *Cache) Get(key string) (string, bool) {
    c.mu.Lock()
    defer c.mu.Unlock()
    val, ok := c.data[key]
    return val, ok
}
```

**Exception:** Performance-critical code where early unlock needed.

## Goroutine Management

**Always ensure goroutines can exit:**
```go
// Good - can be stopped
func (w *Worker) Start(ctx context.Context) {
    go func() {
        for {
            select {
            case <-ctx.Done():
                return  // Goroutine exits
            case work := <-w.workChan:
                w.process(work)
            }
        }
    }()
}
```

## Channel Patterns

**Producer-consumer:**
```go
func producer(ch chan<- int) {
    defer close(ch)
    for i := 0; i < 10; i++ {
        ch <- i
    }
}

func consumer(ch <-chan int) {
    for value := range ch {
        process(value)
    }
}
```

**Fan-out/fan-in:**
```go
func fanOut(input <-chan int, workers int) []<-chan int {
    outputs := make([]<-chan int, workers)
    for i := 0; i < workers; i++ {
        outputs[i] = worker(input)
    }
    return outputs
}

func fanIn(inputs ...<-chan int) <-chan int {
    out := make(chan int)
    var wg sync.WaitGroup
    for _, input := range inputs {
        wg.Go(func() {
            for v := range input {
                out <- v
            }
        })
    }
    go func() {
        wg.Wait()
        close(out)
    }()
    return out
}
```

## Context Usage

**Always pass context:**
```go
func ProcessRequest(ctx context.Context, req *Request) error {
    // Pass context to sub-calls
    if err := validateRequest(ctx, req); err != nil {
        return err
    }
    return storeRequest(ctx, req)
}
```

**Check cancellation:**
```go
func longOperation(ctx context.Context) error {
    for i := 0; i < 1000; i++ {
        select {
        case <-ctx.Done():
            return ctx.Err()
        default:
        }
        // Do work
    }
    return nil
}
```

## Standard Library Helpers

**Use slices and maps packages:**
```go
import (
    "maps"
    "slices"
)

// Clone map
newMap := maps.Clone(oldMap)

// Clone slice
newSlice := slices.Clone(oldSlice)

// Iterate
for k, v := range maps.All(myMap) {
    // ...
}
```

## Atomic Operations

**For simple counters:**
```go
import "sync/atomic"

var counter atomic.Int64

func increment() {
    counter.Add(1)
}

func get() int64 {
    return counter.Load()
}
```

## Common Concurrency Bugs

**Data race:**
```go
// Bad
var counter int
go func() { counter++ }()
go func() { counter++ }()

// Good
var counter atomic.Int64
go func() { counter.Add(1) }()
go func() { counter.Add(1) }()
```

**Always test with `-race` flag!**
