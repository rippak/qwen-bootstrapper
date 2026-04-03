<!-- version: 6.2.2 -->
# Pipeline: New Code

## ЖЁСТКИЕ ПРАВИЛА

1. **НЕ ПРОПУСКАЙ фазы.** Проходи по ВСЕМ фазам от ANALYSIS до CAPTURE. Даже если задача кажется элементарной — используй сокращённый формат, но выполни каждую фазу.
2. **НЕ ОБЪЕДИНЯЙ фазы.** Каждая фаза — отдельный Task(). Не создай код в фазе DATABASE, не пиши тесты в фазе CODE.
3. **Используй правильных агентов.** Для DATABASE — db-architect, для CODE — {lang}-developer, для TESTS — {lang}-test-developer, для REVIEW — оба reviewer-а.
4. **REVIEW не пропускается.** Даже для одной строки кода — вызови минимум одного reviewer.
5. **CAPTURE обязательна.** Обнови memory перед финальным отчётом.

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

---
**CHECKPOINT:** Phase 1 завершена. Файл `.qwen/output/plans/{task-slug}-spec.md` записан. Переход к Phase 2.

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

---
**CHECKPOINT:** Phase 2 завершена. Файл `.qwen/output/plans/{task-slug}.md` записан. Переход к Phase 3.

## Phase 3: DATABASE

Если задача затрагивает БД:

Task(.qwen/agents/db-architect.md, subagent_type: "general-purpose"):
  Вход: прочитай `.qwen/output/plans/{task-slug}.md` + `.qwen/skills/database/SKILL.md` + `.qwen/database/schema.sql`
  Выход: миграции, обновлённая схема (ТОЛЬКО миграции — НЕ пиши код приложения)
  Верни: summary (таблицы, миграции)

```bash
{MIGRATE_CMD}
```

Если БД не затронута — `[SKIP] Phase 3: не затрагивает БД`.

---
**CHECKPOINT:** Phase 3 завершена (или пропущена обоснованно). Переход к Phase 4.

## Phase 4: CODE

Task(.qwen/agents/{lang}-developer.md, subagent_type: "general-purpose"):
  Вход: прочитай `.qwen/output/plans/{task-slug}.md` + `.qwen/skills/code-style/SKILL.md`
  Выход: файлы кода (НЕ тесты — тесты пишутся в Phase 5)
  Верни: summary (созданные файлы, зависимости)

```bash
{SYNTAX_CHECK_CMD}
```

---
**CHECKPOINT:** Phase 4 завершена. Код написан, синтаксис проверен. Переход к Phase 5.

## Phase 5: TESTS

Task(.qwen/agents/{lang}-test-developer.md, subagent_type: "general-purpose"):
  Вход: реализованные файлы (из git diff или summary Phase 4) + `.qwen/skills/testing/SKILL.md`
  Выход: файлы тестов (НЕ код приложения — только тесты)
  Верни: summary (тесты, покрытие)

```bash
{TEST_CMD}
```

Если тесты fail — исправить (максимум 2 итерации).

---
**CHECKPOINT:** Phase 5 завершена. Тесты написаны и прошли. Переход к Phase 6.

## Phase 6: REVIEW

**ЗАПРЕЩЕНО ПРОПУСКАТЬ.** Вызови ОБА reviewer-а.

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

---
**CHECKPOINT:** Phase 6 завершена. Оба reviewer отработали. Переход к Phase 6.5.

## Phase 6.5: CAPTURE

**ОБЯЗАТЕЛЬНА.** Выполни перед FINALIZATION:

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
Memory updated: facts.md + decisions/ + patterns.md
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
