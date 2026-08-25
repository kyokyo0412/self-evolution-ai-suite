#!/usr/bin/env bash
set -euo pipefail
# memory.sh - AI Suite Memory System

# Determine suite root
if [ -z "${SUITE_DIR:-}" ]; then
    if [ -n "${TEST_SUITE_DIR:-}" ]; then
        SUITE_DIR="$TEST_SUITE_DIR/.ai-suite"
    else
        # Fallback if not set
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        SUITE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
    fi
fi

PROJECT_MEMORY_DIR="$(cd "$SUITE_DIR/.." && pwd)/.ai-memory"
GLOBAL_MEMORY_DIR="$HOME/.ai-suite/memory"

ai_memory_init() {
    local agent_name="$1"
    if [ -z "$agent_name" ]; then
        echo "Error: agent_name is required." >&2
        return 1
    fi
    mkdir -p "$PROJECT_MEMORY_DIR/$agent_name/index"
    mkdir -p "$GLOBAL_MEMORY_DIR/$agent_name/tasks"
}

ai_memory_save_index() {
    local agent_name="$1"
    local level="$2"
    local content="$3"
    
    ai_memory_init "$agent_name"
    echo "$content" > "$PROJECT_MEMORY_DIR/$agent_name/index/${level}.md"
}

ai_memory_load_index() {
    local agent_name="$1"
    local level="$2"
    
    local mask_file="$PROJECT_MEMORY_DIR/$agent_name/.masked"
    if [ -f "$mask_file" ]; then
        return 0
    fi
    
    local file="$PROJECT_MEMORY_DIR/$agent_name/index/${level}.md"
    if [ -f "$file" ]; then
        cat "$file"
    fi
}

ai_memory_save_task() {
    local agent_name="$1"
    local task_id="$2"
    local content="$3"
    
    ai_memory_init "$agent_name"
    local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    echo "$content" > "$GLOBAL_MEMORY_DIR/$agent_name/tasks/${timestamp}_${task_id}.md"
}

ai_memory_list_tasks() {
    local agent_name="$1"
    
    local dir="$GLOBAL_MEMORY_DIR/$agent_name/tasks"
    if [ -d "$dir" ]; then
        ls -1 "$dir" | sort
    fi
}

ai_memory_load_task() {
    local agent_name="$1"
    local task_file="$2"
    
    local mask_file="$GLOBAL_MEMORY_DIR/$agent_name/.masked"
    if [ -f "$mask_file" ]; then
        return 0
    fi
    
    local file="$GLOBAL_MEMORY_DIR/$agent_name/tasks/$task_file"
    if [ -f "$file" ]; then
        cat "$file"
    fi
}

ai_memory_save_important() {
    local agent_name="$1"
    local content="$2"
    
    ai_memory_init "$agent_name"
    echo "$content" > "$PROJECT_MEMORY_DIR/$agent_name/important.md"
}

ai_memory_append_important() {
    local agent_name="$1"
    local content="$2"
    
    ai_memory_init "$agent_name"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $content" >> "$PROJECT_MEMORY_DIR/$agent_name/important.md"
}

ai_memory_load_important() {
    local agent_name="$1"
    
    local mask_file="$PROJECT_MEMORY_DIR/$agent_name/.masked"
    if [ -f "$mask_file" ]; then
        return 0
    fi
    
    local file="$PROJECT_MEMORY_DIR/$agent_name/important.md"
    if [ -f "$file" ]; then
        cat "$file"
    fi
}

ai_memory_save_layer() {
    local agent_name="$1"
    local layer_name="$2"
    local content="$3"
    
    ai_memory_init "$agent_name"
    mkdir -p "$PROJECT_MEMORY_DIR/$agent_name/layers"
    echo "$content" > "$PROJECT_MEMORY_DIR/$agent_name/layers/${layer_name}.md"
}

ai_memory_load_layer() {
    local agent_name="$1"
    local layer_name="$2"
    
    local mask_file="$PROJECT_MEMORY_DIR/$agent_name/.masked"
    if [ -f "$mask_file" ]; then
        return 0
    fi
    
    local file="$PROJECT_MEMORY_DIR/$agent_name/layers/${layer_name}.md"
    if [ -f "$file" ]; then
        cat "$file"
    fi
}

ai_memory_list_layers() {
    local agent_name="$1"
    
    local dir="$PROJECT_MEMORY_DIR/$agent_name/layers"
    if [ -d "$dir" ]; then
        ls -1 "$dir" | sed 's/\.md$//' | sort
    fi
}

ai_memory_append_timeline() {
    local agent_name="$1"
    local content="$2"
    
    ai_memory_init "$agent_name"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $content" >> "$PROJECT_MEMORY_DIR/$agent_name/timeline.md"
}

ai_memory_read_timeline() {
    local agent_name="$1"
    
    local mask_file="$PROJECT_MEMORY_DIR/$agent_name/.masked"
    if [ -f "$mask_file" ]; then
        return 0
    fi
    
    local file="$PROJECT_MEMORY_DIR/$agent_name/timeline.md"
    if [ -f "$file" ]; then
        cat "$file"
    fi
}

ai_memory_clean() {
    local agent_name="$1"
    if [ -d "$PROJECT_MEMORY_DIR/$agent_name" ]; then
        rm -rf "$PROJECT_MEMORY_DIR/${agent_name:?}"
    fi
    if [ -d "$GLOBAL_MEMORY_DIR/$agent_name" ]; then
        rm -rf "$GLOBAL_MEMORY_DIR/${agent_name:?}"
    fi
}

ai_memory_mask() {
    local agent_name="$1"
    local status="$2"
    
    ai_memory_init "$agent_name"
    local proj_mask_file="$PROJECT_MEMORY_DIR/$agent_name/.masked"
    local glob_mask_file="$GLOBAL_MEMORY_DIR/$agent_name/.masked"
    
    if [ "$status" = "on" ]; then
        touch "$proj_mask_file"
        touch "$glob_mask_file"
    else
        rm -f "$proj_mask_file"
        rm -f "$glob_mask_file"
    fi
}

ai_memory_summary() {
    local agent_name="$1"
    
    echo "=== Memory Summary for Agent: $agent_name ==="
    echo "Project Memory (.ai-memory/$agent_name/):"
    
    if [ -d "$PROJECT_MEMORY_DIR/$agent_name/index" ]; then
        echo "  - Index Files:"
        ls -1 "$PROJECT_MEMORY_DIR/$agent_name/index" 2>/dev/null | sed 's/^/      /' || true
    fi
    
    if [ -d "$PROJECT_MEMORY_DIR/$agent_name/layers" ]; then
        echo "  - Layer Files:"
        ls -1 "$PROJECT_MEMORY_DIR/$agent_name/layers" 2>/dev/null | sed 's/^/      /' || true
    fi
    
    if [ -f "$PROJECT_MEMORY_DIR/$agent_name/important.md" ]; then
        local lc
        lc=$(wc -l < "$PROJECT_MEMORY_DIR/$agent_name/important.md" | tr -d ' ')
        echo "  - important.md ($lc lines)"
    fi
    
    if [ -f "$PROJECT_MEMORY_DIR/$agent_name/timeline.md" ]; then
        local lc
        lc=$(wc -l < "$PROJECT_MEMORY_DIR/$agent_name/timeline.md" | tr -d ' ')
        echo "  - timeline.md ($lc lines)"
    fi
    
    echo "Global Memory (~/.ai-suite/memory/$agent_name/):"
    if [ -d "$GLOBAL_MEMORY_DIR/$agent_name/tasks" ]; then
        echo "  - Recent Tasks (showing last 5):"
        ls -1 "$GLOBAL_MEMORY_DIR/$agent_name/tasks" 2>/dev/null | sort | tail -n 5 | sed 's/^/      /' || true
    fi
    echo "============================================="
}

ai_memory_search() {
    local agent_name="$1"
    local keyword="$2"
    
    echo "=== Search Results for '$keyword' (Agent: $agent_name) ==="
    if [ -d "$PROJECT_MEMORY_DIR/$agent_name" ]; then
        grep -inrE "$keyword" "$PROJECT_MEMORY_DIR/$agent_name" || true
    fi
    if [ -d "$GLOBAL_MEMORY_DIR/$agent_name" ]; then
        grep -inrE "$keyword" "$GLOBAL_MEMORY_DIR/$agent_name" || true
    fi
    echo "=========================================================="
}
