<!-- version: 5.4.2 -->
# Pipeline: Review

## Вход
- Файлы для ревью (diff или список путей)
- `.claude/memory/facts.md`

{если ADAPTIVE_TEAMS: включи `templates/includes/capability-detect.md`}

## Phase 1: PARALLEL REVIEW

### Режим TEAM (если EXECUTION_MODE=team)

Создай команду из двух тиммейтов для параллельного ревью:

Teammate "reviewer-logic":
  Промпт: Прочитай .claude/agents/{lang}-reviewer-logic.md и выполни как свою роль.
  Вход: файлы для ревью + `.claude/skills/code-style/SKILL.md` + `.claude/skills/architecture/SKILL.md`
  Выход: запиши в `.claude/output/reviews/{task-slug}-logic.md`
  По завершении: отправь message лиду с summary (verdict, замечания по severity)

Teammate "reviewer-security":
  Промпт: Прочитай .claude/agents/{lang}-reviewer-security.md и выполни как свою роль.
  Вход: файлы для ревью
  Выход: запиши в `.claude/output/reviews/{task-slug}-security.md`
  По завершении: отправь message лиду с summary (verdict, замечания по severity)

Жди завершения обоих тиммейтов. Собери результаты из их messages.

### Режим SEQUENTIAL (если EXECUTION_MODE=sequential)

Запусти одновременно:

Task(.claude/agents/{lang}-reviewer-logic.md, subagent_type: "general-purpose"):
  Вход: файлы для ревью + `.claude/skills/code-style/SKILL.md` + `.claude/skills/architecture/SKILL.md`
  Выход: запиши в `.claude/output/reviews/{task-slug}-logic.md`
  Верни: summary (verdict, замечания по severity)

Task(.claude/agents/{lang}-reviewer-security.md, subagent_type: "general-purpose"):
  Вход: файлы для ревью
  Выход: запиши в `.claude/output/reviews/{task-slug}-security.md`
  Верни: summary (verdict, замечания по severity)

## Phase 2: REPORT

### Объединение результатов
1. Прочитай `.claude/output/reviews/{task-slug}-logic.md` и `{task-slug}-security.md`
2. Собери все замечания из обоих ревью
3. Отсортируй по severity: BLOCK → WARN → INFO
4. Удали дубликаты (один и тот же файл:строка)

### Сводная таблица
| # | Source | Severity | Файл:строка | Проблема | Рекомендация |
|---|--------|----------|-------------|----------|--------------|

### Verdict
- **BLOCK** — есть хотя бы один BLOCK → код требует исправлений
- **PASS WITH WARNINGS** — только WARN/INFO → рекомендовано исправить
- **PASS** — замечаний нет или только INFO

## Phase 3: CAPTURE

1. Обнови `.claude/memory/facts.md` по секциям:
   - "## Known Issues" → максимум 10 записей, удали разрешённые
   ПРАВИЛО: перед добавлением проверь — НЕ ДУБЛИРУЙ существующие записи
2. Добавь recurring issues в `.claude/memory/issues.md`
3. Обнови `.claude/memory/patterns.md` если выявлены антипаттерны

### Итог
```
[REVIEW COMPLETE]
Logic: {verdict} ({N} замечаний)
Security: {verdict} ({N} замечаний)
Overall: {verdict}
```
