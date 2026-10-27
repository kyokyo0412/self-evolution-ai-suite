#!/usr/bin/env bash
set -euo pipefail
# memory.sh -- Self-contained, portable AI Suite memory API (Bash 3.2+).

_memory_active_project() {
    local project
    if command -v git >/dev/null 2>&1 && project=$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null); then
        (cd -P "$project" && pwd)
    else
        pwd -P
    fi
}

_memory_layout_project() {
    local directory="$1" agent relative suffix installation home
    for agent in .cursor .claude .codex .continue .roo .opencode .config/opencode; do
        for relative in scripts meta/scripts meta/layer2-cognitive/memory; do
            suffix="/$agent/$relative"
            if [[ "$directory" == *"$suffix" ]]; then
                installation="${directory%"$suffix"}"
                home=$(cd -P "$HOME" && pwd) || return
                if [[ "$installation" == "$home" ]]; then
                    _memory_active_project
                else
                    printf '%s\n' "$installation"
                fi
                return
            fi
        done
    done
    case "$directory" in
        */.ai-suite/layer2-cognitive/memory) printf '%s\n' "${directory%/.ai-suite/layer2-cognitive/memory}" ;;
        *) _memory_active_project ;;
    esac
}

_memory_default_project_dir() {
    local project
    if [[ -n "${AI_MEMORY_PROJECT_DIR:-}" ]]; then
        printf '%s\n' "$AI_MEMORY_PROJECT_DIR"
        return
    elif [[ -n "${SUITE_DIR:-}" && "$SUITE_DIR" != "${_MEMORY_AUTODETECTED_SUITE_DIR:-}" ]]; then
        project=$(cd -P "$SUITE_DIR/.." && pwd) || return
    elif [[ -n "${TEST_SUITE_DIR:-}" ]]; then
        project=$(cd -P "$TEST_SUITE_DIR" && pwd) || return
    else
        project=$(_memory_layout_project "$_MEMORY_SCRIPT_DIR") || return
    fi
    printf '%s/.ai-memory\n' "$project"
}

_MEMORY_SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_MEMORY_DIR=$(_memory_default_project_dir)
GLOBAL_MEMORY_DIR="${AI_MEMORY_GLOBAL_DIR:-$HOME/.ai-suite/memory}"
# Keep the historical suite context variable available to callers.
if [[ -z "${SUITE_DIR:-}" || "$SUITE_DIR" == "${_MEMORY_AUTODETECTED_SUITE_DIR:-}" ]]; then
    SUITE_DIR="${TEST_SUITE_DIR:-$(cd "$_MEMORY_SCRIPT_DIR/../.." && pwd)}"
    [[ -z "${TEST_SUITE_DIR:-}" ]] || SUITE_DIR="$TEST_SUITE_DIR/.ai-suite"
    _MEMORY_AUTODETECTED_SUITE_DIR="$SUITE_DIR"
fi

_memory_error() {
    printf 'Memory error: %s\n' "$*" >&2
    return 1
}

_memory_arguments() {
    [[ "$1" -eq "$2" ]] && return 0
    _memory_error "$3 requires $1 argument(s), received $2"
}

_memory_name() {
    local value="$1" label="$2" limit="${3:-200}"
    [[ -n "$value" ]] || { _memory_error "$label is required"; return 1; }
    case "$value" in
        .|..|*[!a-zA-Z0-9_.-]*) _memory_error "invalid $label: use a single portable filename component"; return 1 ;;
    esac
    [[ "${#value}" -le "$limit" ]] || _memory_error "$label exceeds $limit characters"
}

_memory_read_name() {
    local value="$1" limit="${3:-251}"
    [[ -n "$value" ]] || { _memory_error "$2 is required"; return 1; }
    case "$value" in
        .|..|*/*|*[[:cntrl:]]*) _memory_error "invalid $2: expected a single filename component"; return 1 ;;
    esac
    [[ "${#value}" -le "$limit" ]] || _memory_error "$2 exceeds $limit characters"
}

_memory_root() {
    local path="$1" suffix='' component
    [[ "$path" == /* ]] || path="$PWD/$path"
    while [[ "$path" != / && "$path" == */ ]]; do path="${path%/}"; done
    while [[ ! -d "$path" ]]; do
        [[ ! -e "$path" && ! -L "$path" ]] || { _memory_error "memory root is not a directory"; return 1; }
        component="${path##*/}"
        [[ "$component" != . && "$component" != .. ]] || { _memory_error "invalid memory root component"; return 1; }
        suffix="/$component$suffix"
        path="${path%/*}"
        [[ -n "$path" ]] || path=/
    done
    path="$(cd -P "$path" && pwd)" || return
    path="${path%/}$suffix"
    [[ -n "$path" && "$path" != / ]] || { _memory_error "memory root must not be filesystem root"; return 1; }
    printf '%s\n' "$path"
}

_memory_guard_tree() {
    local path="$1" unsafe
    [[ ! -L "$path" ]] || { _memory_error "symlink in memory path: $path"; return 1; }
    [[ -e "$path" ]] || return 0
    [[ -d "$path" ]] || { _memory_error "memory agent path is not a directory: $path"; return 1; }
    unsafe=$(find "$path" ! -type d ! -type f -print) || return
    [[ -z "$unsafe" ]] || _memory_error "memory contains a symlink or special file: $path"
}

_memory_guard_read_tree() {
    local path="$1" depth="${2:-0}" entry
    [[ "$depth" -le 32 ]] || { _memory_error "memory directory nesting exceeds 32 levels: $path"; return 1; }
    [[ ! -L "$path" ]] || { _memory_error "symlink in memory path: $path"; return 1; }
    [[ -e "$path" ]] || return 0
    [[ -d "$path" && -r "$path" && -x "$path" ]] || {
        _memory_error "memory agent directory is not readable: $path"; return 1;
    }
    # Globs tolerate temporary regular files disappearing during atomic publication.
    for entry in "$path"/* "$path"/.[!.]* "$path"/..?*; do
        if [[ -L "$entry" ]]; then
            _memory_error "symlink in memory path: $entry"
            return 1
        elif [[ -d "$entry" ]]; then
            _memory_guard_read_tree "$entry" "$((depth + 1))" || return
        elif [[ ! -f "$entry" && -e "$entry" ]]; then
            _memory_error "special file in memory path: $entry"
            return 1
        fi
    done
}

_memory_read_operation() {
    _memory_resolve_roots || return
    _memory_guard_read_tree "$_memory_project" || return
    _memory_guard_read_tree "$_memory_global" || return
    if [[ -f "$_memory_project/.masked" || -f "$_memory_global/.masked" ]]; then return 0; fi
    "$@"
}

_memory_resolve_roots() {
    _memory_project_root=$(_memory_root "$PROJECT_MEMORY_DIR") || return
    _memory_global_root=$(_memory_root "$GLOBAL_MEMORY_DIR") || return
    case "$_memory_project_root/" in
        "$_memory_global_root/"*) _memory_error 'project and global memory roots must not overlap'; return 1 ;;
    esac
    case "$_memory_global_root/" in
        "$_memory_project_root/"*) _memory_error 'project and global memory roots must not overlap'; return 1 ;;
    esac
    _memory_project="$_memory_project_root/$_memory_agent"
    _memory_global="$_memory_global_root/$_memory_agent"
}

_memory_prepare() {
    _memory_resolve_roots || return
    mkdir -p "$_memory_global_root" || return
    [[ ! -L "$_memory_global_root/.locks" ]] || { _memory_error "symlink in memory lock path"; return 1; }
    mkdir -p "$_memory_global_root/.locks" || return
    _memory_lock_dir="$_memory_global_root/.locks/$_memory_agent"
}

_memory_lock() {
    local configured="${AI_MEMORY_LOCK_ATTEMPTS:-200}" attempt=0 limit error
    case "$configured" in
        ''|*[!0-9]*) _memory_error 'AI_MEMORY_LOCK_ATTEMPTS must be between 1 and 400'; return 1 ;;
    esac
    [[ "${#configured}" -le 3 ]] || { _memory_error 'invalid memory lock attempt limit'; return 1; }
    limit=$((10#$configured))
    [[ "$limit" -gt 0 && "$limit" -le 400 ]] || { _memory_error 'invalid memory lock attempt limit'; return 1; }
    while [[ "$attempt" -lt "$limit" ]]; do
        if error=$(mkdir "$_memory_lock_dir" 2>&1); then
            _memory_lock_held=1
            return 0
        fi
        [[ ! -L "$_memory_lock_dir" ]] || { _memory_error 'symlink in memory lock path'; return 1; }
        if [[ -e "$_memory_lock_dir" && ! -d "$_memory_lock_dir" ]]; then
            _memory_error "cannot acquire memory lock: $error"
            return 1
        fi
        attempt=$((attempt + 1))
        sleep 0.05 || return
    done
    _memory_error "memory lock timed out: $_memory_lock_dir ($error; inspect stale locks before removal)"
}

_memory_release() {
    local status=$?
    trap - EXIT HUP INT TERM
    if [[ -n "$_memory_pending" ]]; then
        rm -f -- "$_memory_pending" || status=1
    fi
    if [[ "$_memory_lock_held" -eq 1 ]]; then
        rmdir "$_memory_lock_dir" || status=1
    fi
    exit "$status"
}

_memory_run() (
    local _memory_agent="$1" mode="$2"
    local _memory_project_root _memory_global_root _memory_project _memory_global
    local _memory_lock_dir='' _memory_lock_held=0 _memory_pending=''
    shift 2
    _memory_name "$_memory_agent" agent_name || return
    [[ "$_memory_agent" != .locks ]] || { _memory_error 'agent_name .locks is reserved'; return 1; }
    if [[ "$mode" == read ]]; then
        _memory_read_operation "$@"
        return
    fi
    _memory_prepare || return
    trap _memory_release EXIT
    trap 'exit 129' HUP
    trap 'exit 130' INT
    trap 'exit 143' TERM
    _memory_lock || return
    if [[ "$mode" != global-write ]]; then _memory_guard_tree "$_memory_project" || return; fi
    _memory_guard_tree "$_memory_global" || return
    "$@"
)

_memory_ensure() {
    mkdir -p "$_memory_project/index" "$_memory_global/tasks"
}

_memory_location() {
    if [[ "$1" == project ]]; then
        printf '%s/%s\n' "$_memory_project" "$2"
    else
        printf '%s/%s\n' "$_memory_global" "$2"
    fi
}

_memory_atomic() {
    local file="$1" content="$2"
    _memory_file_target "$file" || return
    _memory_pending=$(mktemp "${file%/*}/.memory-write.XXXXXX") || return
    printf '%s\n' "$content" > "$_memory_pending" || return
    mv -f -- "$_memory_pending" "$file" || return
    _memory_pending=''
}

_memory_store() {
    local file
    _memory_ensure || return
    file=$(_memory_location "$1" "$2") || return
    mkdir -p "${file%/*}" || return
    _memory_atomic "$file" "$3"
}

_memory_load() {
    local file
    file=$(_memory_location "$1" "$2") || return
    _memory_file_target "$file" || return
    [[ -f "$file" ]] || return 0
    cat "$file"
}

_memory_file_target() {
    [[ ! -e "$1" || -f "$1" ]] || _memory_error "memory file path is not a regular file: $1"
}

_memory_task() {
    local task_id="$1" content="$2" file attempt timestamp
    _memory_ensure || return
    timestamp=$(date +'%Y-%m-%d_%H-%M-%S') || return
    for ((attempt=0; attempt<32; attempt++)); do
        _memory_pending=$(mktemp "$_memory_global/tasks/.memory-task.XXXXXX") || return
        file="$_memory_global/tasks/${timestamp}_${_memory_pending##*.}_${task_id}.md"
        if [[ ! -e "$file" ]]; then
            printf '%s\n' "$content" > "$_memory_pending" || return
            mv -- "$_memory_pending" "$file" || return
            _memory_pending=''
            return 0
        fi
        rm -- "$_memory_pending" || return
        _memory_pending=''
    done
    _memory_error 'unable to allocate a unique task filename'
}

_memory_append() {
    local file timestamp
    _memory_ensure || return
    file="$_memory_project/$1"
    _memory_file_target "$file" || return
    timestamp=$(date +'%Y-%m-%d %H:%M:%S') || return
    _memory_pending=$(mktemp "$_memory_project/.memory-write.XXXXXX") || return
    if [[ -f "$file" ]]; then cat "$file" > "$_memory_pending" || return; fi
    printf '[%s] %s\n' "$timestamp" "$2" >> "$_memory_pending" || return
    mv -f -- "$_memory_pending" "$file" || return
    _memory_pending=''
}

_memory_list() {
    local file name
    [[ -d "$1" ]] || return 0
    for file in "$1"/*.md; do
        [[ -f "$file" ]] || continue
        name="${file##*/}"
        if [[ "$2" == layers ]]; then name="${name%.md}"; fi
        printf '%s\n' "$name"
    done | LC_ALL=C sort
}

_memory_clean() {
    rm -rf -- "$_memory_project" "$_memory_global"
}

_memory_mask() {
    _memory_ensure || return
    if [[ "$1" == on ]]; then
        _memory_atomic "$_memory_project/.masked" '' || return
        _memory_atomic "$_memory_global/.masked" ''
    else
        rm -f -- "$_memory_project/.masked" "$_memory_global/.masked"
    fi
}

_memory_summary() {
    local file section lines
    printf '=== Memory Summary for Agent: %s ===\n' "$1"
    printf 'Project Memory (.ai-memory/%s/):\n' "$1"
    for section in index layers; do
        if [[ -d "$_memory_project/$section" ]]; then
            printf '  - %s Files:\n' "$section"
            _memory_list "$_memory_project/$section" tasks | sed 's/^/      /' || return
        fi
    done
    for section in important timeline; do
        file="$_memory_project/$section.md"
        if [[ -f "$file" ]]; then
            lines=$(wc -l < "$file" | tr -d ' ') || return
            printf '  - %s.md (%s lines)\n' "$section" "$lines"
        fi
    done
    printf 'Global Memory (~/.ai-suite/memory/%s/):\n' "$1"
    printf '  - Recent Tasks (showing last 5):\n'
    _memory_list "$_memory_global/tasks" tasks | tail -n 5 | sed 's/^/      /' || return
    printf '=============================================\n'
}

_memory_search() {
    local directory status
    if printf '' | grep -E -- "$1" >/dev/null; then
        :
    else
        status=$?
        [[ "$status" -eq 1 ]] || return "$status"
    fi
    printf "=== Search Results for '%s' (Agent: %s) ===\n" "$1" "$2"
    for directory in "$_memory_project" "$_memory_global"; do
        [[ -d "$directory" ]] || continue
        if grep -inrE -- "$1" "$directory"; then
            :
        else
            status=$?
            [[ "$status" -eq 1 ]] || return "$status"
        fi
    done
    printf '==========================================================\n'
}

ai_memory_init() {
    _memory_arguments 1 "$#" ai_memory_init || return
    _memory_run "$1" write _memory_ensure
}

ai_memory_validate_roots() (
    local _memory_agent="${1:-}" scope="${2:-project}" directory
    local _memory_project_root _memory_global_root _memory_project _memory_global
    [[ "$#" -ge 1 && "$#" -le 2 ]] || { _memory_error 'ai_memory_validate_roots requires agent and optional scope'; return 1; }
    _memory_name "$_memory_agent" agent_name || return
    [[ "$_memory_agent" != .locks ]] || { _memory_error 'agent_name .locks is reserved'; return 1; }
    case "$scope" in project|global) ;; *) _memory_error 'scope must be project or global'; return 1 ;; esac
    _memory_resolve_roots || return
    _memory_guard_tree "$_memory_global" || return
    if [[ "$scope" == project ]]; then _memory_guard_tree "$_memory_project" || return; fi
    for directory in "$_memory_global/tasks" "$_memory_global_root/.locks"; do
        _memory_expected_directory "$directory" || return
    done
    if [[ "$scope" == project ]]; then _memory_expected_directory "$_memory_project/index" || return; fi
    directory="$_memory_global_root/.locks/$_memory_agent"
    [[ ! -e "$directory" && ! -L "$directory" ]] || _memory_error "memory lock is present: $directory"
)

_memory_expected_directory() {
    [[ ! -L "$1" && ( ! -e "$1" || -d "$1" ) ]] || _memory_error "expected a memory directory: $1"
}

ai_memory_init_global() {
    _memory_arguments 1 "$#" ai_memory_init_global || return
    _memory_run "$1" global-write _memory_ensure_global
}

_memory_ensure_global() {
    mkdir -p "$_memory_global/tasks"
}

ai_memory_save_index() {
    _memory_arguments 3 "$#" ai_memory_save_index || return
    _memory_name "$2" level || return
    _memory_run "$1" write _memory_store project "index/$2.md" "$3"
}

ai_memory_load_index() {
    _memory_arguments 2 "$#" ai_memory_load_index || return
    _memory_read_name "$2" level || return
    _memory_run "$1" read _memory_load project "index/$2.md"
}

ai_memory_save_task() {
    _memory_arguments 3 "$#" ai_memory_save_task || return
    _memory_name "$2" task_id || return
    _memory_run "$1" write _memory_task "$2" "$3"
}

ai_memory_list_tasks() {
    _memory_arguments 1 "$#" ai_memory_list_tasks || return
    _memory_run "$1" read _memory_list_global_tasks
}

_memory_list_global_tasks() {
    _memory_list "$_memory_global/tasks" tasks
}

ai_memory_load_task() {
    _memory_arguments 2 "$#" ai_memory_load_task || return
    _memory_read_name "$2" task_file 255 || return
    _memory_run "$1" read _memory_load global "tasks/$2"
}

ai_memory_save_important() {
    _memory_arguments 2 "$#" ai_memory_save_important || return
    _memory_run "$1" write _memory_store project important.md "$2"
}

ai_memory_append_important() {
    _memory_arguments 2 "$#" ai_memory_append_important || return
    _memory_run "$1" write _memory_append important.md "$2"
}

ai_memory_load_important() {
    _memory_arguments 1 "$#" ai_memory_load_important || return
    _memory_run "$1" read _memory_load project important.md
}

ai_memory_save_layer() {
    _memory_arguments 3 "$#" ai_memory_save_layer || return
    _memory_name "$2" layer_name || return
    _memory_run "$1" write _memory_store project "layers/$2.md" "$3"
}

ai_memory_load_layer() {
    _memory_arguments 2 "$#" ai_memory_load_layer || return
    _memory_read_name "$2" layer_name || return
    _memory_run "$1" read _memory_load project "layers/$2.md"
}

ai_memory_list_layers() {
    _memory_arguments 1 "$#" ai_memory_list_layers || return
    _memory_run "$1" read _memory_list_project_layers
}

_memory_list_project_layers() {
    _memory_list "$_memory_project/layers" layers
}

ai_memory_append_timeline() {
    _memory_arguments 2 "$#" ai_memory_append_timeline || return
    _memory_run "$1" write _memory_append timeline.md "$2"
}

ai_memory_read_timeline() {
    _memory_arguments 1 "$#" ai_memory_read_timeline || return
    _memory_run "$1" read _memory_load project timeline.md
}

ai_memory_clean() {
    _memory_arguments 1 "$#" ai_memory_clean || return
    _memory_run "$1" write _memory_clean
}

ai_memory_mask() {
    _memory_arguments 2 "$#" ai_memory_mask || return
    case "$2" in on|off) ;; *) _memory_error 'mask status must be on or off'; return 1 ;; esac
    _memory_run "$1" write _memory_mask "$2"
}

ai_memory_summary() {
    _memory_arguments 1 "$#" ai_memory_summary || return
    _memory_run "$1" read _memory_summary "$1"
}

ai_memory_search() {
    _memory_arguments 2 "$#" ai_memory_search || return
    _memory_run "$1" read _memory_search "$2" "$1"
}
