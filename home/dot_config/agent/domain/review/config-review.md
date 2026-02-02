# Configuration Review Protocol

When reviewing or advising on configuration files (YAML, JSON, TOML, INI, etc.):

## Mandatory Steps

1. **Read First**: ALWAYS use the Read tool before commenting on structure or content
2. **Quote Current State**: Show the user what you see with line numbers:
   ```yaml
   # Current structure (lines 47-52 in .golangci.yml):
   linters:
     settings:
       dogsled:
         max-blank-identifiers: 2
   ```
3. **Then Advise**: Base your recommendation on the actual structure
4. **Never Assume**: Don't rely on "standard" patterns - every codebase is different

## Communication Pattern

### ✅ Good Example

User: "Is it linters-settings or linters.settings?"

Response:
> Let me check your actual config...
>
> [reads .golangci.yml]
>
> Your config at lines 47-52 shows:
> ```yaml
> linters:
>   settings:
>     dogsled:
>       max-blank-identifiers: 2
> ```
>
> So for your structure, you'd use `linters.settings.custom.mwlint`.

### ❌ Bad Example

User: "Is it linters-settings or linters.settings?"

Response:
> It's linters-settings (top-level, hyphenated). The correct structure is...

**Why bad:** Answered authoritatively without reading the actual file.

## Anti-Patterns to Avoid

| ❌ Never Say | ✅ Instead Say |
|-------------|---------------|
| "The correct structure is..." | "Your current structure at lines X-Y shows... To add this, you would..." |
| "Standard golangci-lint configs use..." | "Looking at your .golangci.yml at lines X-Y, I see you use..." |
| "You should have..." | "Your current file has... If you want to add X, you would..." |
| "The documentation says..." | "Your actual config shows... [quote it], which means..." |

## File Types This Applies To

- **Configuration files**: .golangci.yml, tsconfig.json, .eslintrc, pyproject.toml, Cargo.toml, etc.
- **Build files**: Makefile, Justfile, package.json, go.mod, Cargo.toml
- **CI/CD**: .github/workflows/*.yml, .gitlab-ci.yml, .circleci/config.yml
- **Docker**: Dockerfile, docker-compose.yml
- **Infrastructure**: terraform files, k8s manifests, ansible playbooks

## When To Apply

Apply this protocol whenever:
1. User asks about structure/format of an existing file
2. User asks "where should I add X"
3. User asks "what's the correct syntax for Y"
4. You're about to give advice about modifying an existing config
5. You're unsure about the current structure

## Red Flags That You're Violating This

- You're about to type "The correct structure is..."
- You're about to type "Standard practice is..."
- You're about to type "You should use..."
- You haven't used the Read tool in the last 2-3 messages
- You're basing advice on documentation rather than the actual file
- You're describing what files "should" contain vs what they "do" contain

## Implementation Checklist

When a user asks about config:

- [ ] Read the actual file
- [ ] Identify relevant lines
- [ ] Quote those lines in response (with line numbers)
- [ ] Base advice on what's actually there
- [ ] If making recommendations, show before/after with actual context

## Recovery Pattern

If you realize you gave advice without reading the file:

1. Stop immediately
2. Say: "Actually, let me check your actual config first to give accurate advice"
3. Read the file
4. Quote what you found
5. Correct your previous advice if needed
