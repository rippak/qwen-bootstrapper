<!-- version: 5.4.2 -->
# Pipeline: New Code

## Вход
- Описание задачи от пользователя
- Структурированный контекст из роутера: scope, affected_modules
- `.qwen/memory/facts.md`

{если ADAPTIVE_TEAMS: включи `templates/includes/capability-detect.md`}

## Phase 1: ANALYSIS

{если SKIP_ANALYSIS: пропустить Phase 1, перейти к Phase 2}

Task(.qwen/agents/analyst.md, subagent_type: "general-purpose", mode: "plan"):
  Вход: описание задачи, {SOURCE_DIR}, memory/facts.md, memory/decisions/, database/schema.sql
  Выход: .qwen/output/plans/{task-slug}-spec.md
  Верни: краткое ТЗ (scope + затронутые модули + acceptance criteria)

Покажи пользователю краткое ТЗ (scope + модули + acceptance criteria).

AskUserQuestion:
  question: "ТЗ готово. Подтвердить?"
  options:
    - {label: "Подтвердить", description: "Передать ТЗ архитектору"}
    - {label: "Уточнить", description: "Скорректировать scope или требования"}
    - {label: "Отменить", description: "Прервать pipeline"}

→ "Уточнить": уточни и перегенерируй ТЗ → повтори AskUserQuestion
→ "Подтвердить": передай ТЗ в Phase 2

## Phase 2: ARCHITECTURE

Task(.qwen/agents/{lang}-architect.md, subagent_type: "general-purpose", mode: "plan"):
  Вход: `.qwen/output/plans/{task-slug}-spec.md` + `.qwen/skills/architecture/SKILL.md`
  Выход: запиши план в `.qwen/output/plans/{task-slug}.md`
  ОГРАНИЧЕНИЕ: агент НЕ СОЗДАЁТ и НЕ ИЗМЕНЯЕТ файлы проекта. Только анализ и план.
  Верни: summary (модули, ключевые решения, путь к плану)

Покажи план пользователю (модули, ключевые решения).

AskUserQuestion:
  question: "Архитектурный план готов. Подтвердить?"
  options:
    - {label: "Подтвердить", description: "Приступить к реализации"}
    - {label: "Уточнить", description: "Скорректировать план"}
    - {label: "Отменить", description: "Прервать pipeline"}

→ "Уточнить": скорректируй план → повтори AskUserQuestion

## Phase 3: DATABASE

Если задача затрагивает БД:

Task(.qwen/agents/db-architect.md, subagent_type: "general-purpose"):
  Вход: прочитай `.qwen/output/plans/{task-slug}.md` + `.qwen/skills/database/SKILL.md` + `.qwen/database/schema.sql`
  Выход: миграции, обновлённая схема
  Верни: summary (таблицы, миграции)

```bash
{MIGRATE_CMD}
```

Если БД не затронута — `[SKIP]`.

## Phase 4: CODE

Task(.qwen/agents/{lang}-developer.md, subagent_type: "general-purpose"):
  Вход: прочитай `.qwen/output/plans/{task-slug}.md` + `.qwen/skills/code-style/SKILL.md`
  Выход: файлы кода
  Верни: summary (созданные файлы, зависимости)

```bash
{SYNTAX_CHECK_CMD}
```

## Phase 5: TESTS

Task(.qwen/agents/{lang}-test-developer.md, subagent_type: "general-purpose"):
  Вход: реализованные файлы (из git diff или summary Phase 4) + `.qwen/skills/testing/SKILL.md`
  Выход: файлы тестов
  Верни: summary (тесты, покрытие)

```bash
{TEST_CMD}
```

Если тесты fail — исправить (максимум 2 итерации).

## Phase 6: REVIEW

### Режим TEAM (если EXECUTION_MODE=team)

Создай команду из двух тиммейтов для параллельного ревью:

Teammate "reviewer-logic":
  Промпт: Прочитай .qwen/agents/{lang}-reviewer-logic.md и выполни как свою роль.
  Вход: все изменённые файлы (git diff)
  Выход: запиши в `.qwen/output/reviews/{task-slug}-logic.md`
  По завершении: отправь message лиду с summary (verdict, замечания по severity)

Teammate "reviewer-security":
  Промпт: Прочитай .qwen/agents/{lang}-reviewer-security.md и выполни как свою роль.
  Вход: все изменённые файлы (git diff)
  Выход: запиши в `.qwen/output/reviews/{task-slug}-security.md`
  По завершении: отправь message лиду с summary (verdict, замечания по severity)

Жди завершения обоих тиммейтов. Собери результаты из их messages.

### Режим SEQUENTIAL (если EXECUTION_MODE=sequential)

Запусти одновременно:

Task(.qwen/agents/{lang}-reviewer-logic.md, subagent_type: "general-purpose"):
  Вход: все изменённые файлы (git diff)
  Выход: запиши в `.qwen/output/reviews/{task-slug}-logic.md`
  Верни: summary (verdict, замечания по severity)

Task(.qwen/agents/{lang}-reviewer-security.md, subagent_type: "general-purpose"):
  Вход: все изменённые файлы (git diff)
  Выход: запиши в `.qwen/output/reviews/{task-slug}-security.md`
  Верни: summary (verdict, замечания по severity)

### Обработка результатов (оба режима)
- **BLOCK** от любого reviewer → исправить и повторить Phase 6
- **PASS WITH WARNINGS** → исправить WARN, продолжить
- **PASS** → продолжить

## Phase 6.5: CAPTURE

1. Обнови `.qwen/memory/facts.md` по секциям:
   - "## Stack" → ЗАМЕНИТЬ секцию целиком (только если стек изменился)
   - "## Key Paths" → МЕРЖИТЬ: добавь новые, удали несуществующие пути
   - "## Active Decisions" → ЗАМЕНИТЬ: только ссылки на файлы из decisions/ (НЕ archive)
   - "## Known Issues" → максимум 10 записей, удали разрешённые
   ПРАВИЛО: перед добавлением проверь — НЕ ДУБЛИРУЙ существующие записи
2. Если были архитектурные решения → `.qwen/memory/decisions/{date}-{slug}.md`
3. Обнови `.qwen/memory/patterns.md` если выявлены новые паттерны

## Phase 7: FINALIZATION

### Итог
```
[NEW-CODE COMPLETE]
Создано файлов: {N}
Тесты: {pass}/{total}
Review: {verdict}
```

## Матрица ошибок

| Фаза | Ошибка | Действие |
|------|--------|----------|
| ANALYSIS | ТЗ отклонено | Уточнить требования → повторить Phase 1 |
| ARCHITECTURE | План отклонён | Уточнить требования → повторить Phase 2 |
| DATABASE | Миграция fail | Проверить SQL → повторить Phase 3 |
| CODE | Syntax error | Исправить → повторить проверку |
| TESTS | Тесты fail (>2 итераций) | Остановить, показать ошибки пользователю |
| REVIEW | BLOCK | Исправить замечания → повторить Phase 6 |
