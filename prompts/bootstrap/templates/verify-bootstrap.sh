#!/bin/bash

PROJECT_DIR="${QWEN_PROJECT_DIR:-.}"
EXIT_CODE=0

echo "=== Checking .qwen/ structure ==="
for dir in agents skills pipelines scripts/hooks memory memory/sessions memory/decisions memory/decisions/archive output output/contracts output/qa input database; do
    if [ -d "$PROJECT_DIR/.qwen/$dir" ]; then
        echo "[OK] .qwen/$dir/"
    else
        echo "[MISS] .qwen/$dir/"
        EXIT_CODE=1
    fi
done

echo ""
echo "=== Checking agents ==="
for f in "$PROJECT_DIR"/.qwen/agents/*.md; do
    [ -f "$f" ] && echo "[OK] $(basename "$f")"
done

echo ""
echo "=== Checking skills ==="
for f in "$PROJECT_DIR"/.qwen/skills/*/SKILL.md; do
    [ -f "$f" ] && echo "[OK] $f"
done

echo ""
echo "=== Pipeline Command ==="
[ -f "$PROJECT_DIR/.qwen/commands/pipeline.md" ] && echo "[OK] commands/pipeline" || { echo "[ERR] commands/pipeline NOT FOUND"; EXIT_CODE=1; }
[ -d "$PROJECT_DIR/.qwen/skills/routing" ] && echo "[ERR] skills/routing/ — устаревшее имя, переименуй в pipeline/"
head -5 "$PROJECT_DIR/.qwen/commands/pipeline.md" 2>/dev/null | grep -q "user-invocable: true" && echo "[OK] frontmatter" || { echo "[ERR] Missing user-invocable: true in commands/pipeline.md"; EXIT_CODE=1; }

[ -f "$PROJECT_DIR/.qwen/commands/p.md" ] && echo "[OK] commands/p" || echo "[WARN] commands/p not found"

grep -q "/pipeline" "$PROJECT_DIR/QWEN.md" 2>/dev/null && echo "[OK] /pipeline reference in QWEN.md" || { echo "[ERR] QWEN.md missing /pipeline reference"; EXIT_CODE=1; }

echo ""
echo "=== Checking pipelines ==="
for f in "$PROJECT_DIR"/.qwen/pipelines/*.md; do
    [ -f "$f" ] && echo "[OK] $(basename "$f")"
done

echo ""
echo "=== Checking hooks ==="
for f in "$PROJECT_DIR"/.qwen/scripts/hooks/*.sh; do
    if [ ! -f "$f" ]; then continue; fi
    if [ -x "$f" ]; then
        echo "[OK] $(basename "$f") (executable)"
    else
        echo "[WARN] $(basename "$f") (not executable)"
        chmod +x "$f"
        echo "[FIXED] $(basename "$f")"
    fi
    bash -n "$f" 2>/dev/null && echo "  [OK] syntax" || echo "  [ERR] syntax error"
done

echo ""
echo "=== Checking settings ==="
for f in "$PROJECT_DIR"/.qwen/settings.json; do
    if [ -f "$f" ]; then
        if jq empty "$f" 2>/dev/null; then
            echo "[OK] $(basename "$f") (valid JSON)"
        else
            echo "[ERR] $(basename "$f") (invalid JSON)"
            EXIT_CODE=1
        fi
    else
        echo "[MISS] $(basename "$f")"
    fi
done

echo ""
echo "=== Checking QWEN.md ==="
if [ -f "$PROJECT_DIR/QWEN.md" ]; then
    echo "[OK] QWEN.md exists"
    for section in "## Agents" "## Skills" "## Pipelines" "## Commands" "## Architecture"; do
        if grep -q "$section" "$PROJECT_DIR/QWEN.md"; then
            echo "  [OK] $section"
        else
            echo "  [WARN] Missing: $section"
        fi
    done
else
    echo "[ERR] QWEN.md not found"
    EXIT_CODE=1
fi

echo ""
echo "=== Checking memory ==="
for f in "$PROJECT_DIR"/.qwen/memory/facts.md "$PROJECT_DIR"/.qwen/memory/patterns.md "$PROJECT_DIR"/.qwen/memory/issues.md "$PROJECT_DIR"/.qwen/skills/memory/SKILL.md; do
    if [ -f "$f" ]; then
        echo "[OK] $(basename "$f")"
    else
        echo "[MISS] $(basename "$f")"
    fi
done
[ -d "$PROJECT_DIR/.qwen/memory/decisions" ] && echo "[OK] memory/decisions/" || echo "[MISS] memory/decisions/"

echo ""
echo "=== Summary ==="
echo "Agents: $(ls -1 "$PROJECT_DIR"/.qwen/agents/*.md 2>/dev/null | wc -l)"
echo "Skills: $(ls -1d "$PROJECT_DIR"/.qwen/skills/*/SKILL.md 2>/dev/null | wc -l)"
echo "Pipelines: $(ls -1 "$PROJECT_DIR"/.qwen/pipelines/*.md 2>/dev/null | wc -l)"
echo "Hooks: $(ls -1 "$PROJECT_DIR"/.qwen/scripts/hooks/*.sh 2>/dev/null | wc -l)"

exit $EXIT_CODE
