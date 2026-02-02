# Chezmoi Agent Notes

## Source Layout
- Source root is `home/` (per `.chezmoiroot`).
- Keep local-only files outside `home/` (e.g., this file).
- Do not template this file.

## Definitions
- Source: files under the chezmoi source directory (`home/` here).
- Target: rendered/templated output from source.
- Destination: the actual filesystem (e.g., `$HOME`).

## File Naming Conventions
Source files use prefixes/suffixes that control target behavior.

**Common prefixes (non-exhaustive):**
- `dot_` → Dotfile (e.g., `dot_gitconfig` → `~/.gitconfig`)
- `private_` → File with mode 0600
- `symlink_` → Create symlink instead of regular file
- `exact_` → Directory: remove entries not in source

**Suffixes:**
- `.tmpl` → Process as Go template before applying

**Examples:**
- `dot_gitconfig.tmpl` → `~/.gitconfig` (templated)
- `private_dot_ssh/config` → `~/.ssh/config` (mode 0600)
- `symlink_CLAUDE.md` → `~/CLAUDE.md` (symlink)

## Before Adding Files
Check file status before adding:
- `chezmoi managed` → List all managed files
- `chezmoi managed <path>` → Check if path is managed (exit 0 if yes)
- `chezmoi unmanaged <path>` → List unmanaged files under path
- `chezmoi ignored` → List files excluded by `.chezmoiignore`

## Drift Control (Destination vs Source)
- Always run `chezmoi status`, then review with `chezmoi diff`.
- If destination changes should be kept:
  - Unmanaged files: `chezmoi add <path>`
  - Managed files: `chezmoi re-add <path>`
  - Conflicts: `chezmoi merge <path>` (interactive 3-way merge)
- If destination changes should be discarded, use `chezmoi apply`
  (use `--dry-run` first when unsure).
- Prefer `chezmoi apply --interactive` when you want confirmation before
  overwriting destination changes.
- Do not leave destination-only changes unresolved.
- Enforce "no drift" with `chezmoi verify` after apply.

## Common Operations
- Edit source: `chezmoi edit <path>` or edit files under `home/`.
- Apply source: `chezmoi apply`.
- Update from git + apply: `chezmoi update` (only when repo is git-backed).
- Stop managing a target: `chezmoi forget <path>` (keeps destination file).
- Remove from source + destination: `chezmoi destroy <path>` (destructive).

## Version Pin Updates
- **Goal:** Keep pins "commensurate" (bump within the same specificity) only
  when a newer version is being blocked.
- **Rule:** Do not increase pin specificity (keep major/minor/patch granularity
  as-is).
- **Workflow:**
  1) Read `data.versions` from `.chezmoi.yaml.tmpl`.
  2) Check upstream latests for each tool.
  3) If a pin blocks a newer version, bump within the same specificity:
     - major-only -> bump major
     - major.minor -> bump minor
     - major.minor.patch -> bump patch
  4) Leave pins unchanged if already current.
  5) Apply: `chezmoi init --apply` (re-reads config with new versions).
- **Note:** Externals reference these via `{{ .versions.<tool> }}` in their URL
  templates.
- **Note:** For routine external refresh without version changes, use
  `chezmoi apply --refresh-externals=always` instead.

## External Dependencies
- Definitions live in `home/.chezmoiexternals/<name>.toml.tmpl`.
- Reference version pins via `{{ .versions.<tool> }}`.
- To add: create `<name>.toml.tmpl` with `type`, `url`, and optional
  `stripComponents`.
- After adding, run `chezmoi apply` to fetch.
- Refresh externals: `chezmoi apply --refresh-externals=always`.

## Lifecycle Scripts
- Scripts live in `home/.chezmoiscripts/`.
- Naming pattern: `run_{once_,}{before_,after_}<NN>_<name>.sh{.tmpl,}`.
- Execution order: numeric prefix (`00`, `10`, etc.).
- `run_once_*` scripts only run once per machine (state tracked).
- `run_before_*` runs before apply; `run_after_*` runs after.

## Templating
- Files ending in `.tmpl` are templated before apply.
- Available data: `.chezmoi.*`, `.tenancy.*`, `.versions.*`, `.path.*`.
- Use `chezmoi execute-template < file.tmpl` to test templates.
- Inspect template data: `chezmoi data`.

## Machine-Specific Config
Tenancy is determined by hostname prefix match in `.chezmoi.yaml.tmpl`:

- **Map location:** `$tenancyMap` in `.chezmoi.yaml.tmpl`
- **Matching:** Case-insensitive prefix match (e.g., `mway-m4` matches `mway-m4.local`)
- **Resolved values:** `.tenancy.personal`, `.tenancy.work`
- **Usage:** `{{ if .tenancy.personal }}...{{ end }}` in templates
- **Adding a machine:** Add entry to `$tenancyMap` with hostname prefix as key
- **Unknown hosts:** Default to `personal: false, work: false`

## Exclusion Guidelines
Do NOT add these to source:
- **Generated files:** Build artifacts, compiled binaries, language caches
- **Ephemeral state:** Logs, history files, PIDs, session state
- **Large binaries:** Use `.chezmoiexternals/` instead (see External Dependencies)
- **Ignored patterns:** Anything matching `.chezmoiignore.tmpl` ignore patterns

## Troubleshooting
- Diagnose setup: `chezmoi doctor`.
- Inspect state: `chezmoi state dump`.
- Re-initialize: `chezmoi init --apply`.
- Force re-run of "run_once" script:
  `chezmoi state delete-bucket --bucket=scriptState`.
