<!-- version: 6.0.0 -->
# Pipeline: Full Feature

## Вход
- Полное описание фичи
- Структурированный контекст из роутера: scope, affected_modules
- `.qwen/memory/facts.md`

## Phase 1: NEW CODE

Выполни pipeline `.qwen/pipelines/new-code.md` полностью (все 7 фаз + Phase 6.5 CAPTURE).

## Phase 2: API DOCS

Выполни pipeline `.qwen/pipelines/api-docs.md` для созданного модуля.

Если фича не содержит API-эндпоинтов — `[SKIP]`.

## Phase 3: QA DOCS

Выполни pipeline `.qwen/pipelines/qa-docs.md` для созданного модуля.

Если фича не содержит API-эндпоинтов — `[SKIP]`.

## Phase 4: CAPTURE

1. Обнови `.qwen/memory/facts.md` по секциям:
   - "## Stack" → ЗАМЕНИТЬ секцию целиком (только если стек изменился)
   - "## Key Paths" → МЕРЖИТЬ: добавь новые, удали несуществующие пути
   - "## Active Decisions" → ЗАМЕНИТЬ: только ссылки на файлы из decisions/ (НЕ archive)
   - "## Known Issues" → максимум 10 записей, удали разрешённые
   ПРАВИЛО: перед добавлением проверь — НЕ ДУБЛИРУЙ существующие записи
2. Запиши решение в `.qwen/memory/decisions/{date}-{slug}.md`
3. Обнови `.qwen/memory/patterns.md`

## Phase 5: FINALIZATION

### Итог
```
[FULL-FEATURE COMPLETE]
Фича: {name}
Код: {N} файлов, тесты {pass}/{total}, review {verdict}
API Docs: {status}
QA Docs: {status}
```
