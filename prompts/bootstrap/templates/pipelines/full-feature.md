<!-- version: 6.2.2 -->
# Pipeline: Full Feature

## ЖЁСТКИЕ ПРАВИЛА

1. **НЕ ПРОПУСКАЙ фазы.** Полный цикл = new-code (все фазы) + api-docs + qa-docs + capture.
2. **new-code pipeline выполняется целиком** — со всеми фазами ANALYSIS → ARCHITECTURE → DATABASE → CODE → TESTS → REVIEW → CAPTURE.
3. **Финальный CAPTURE агрегирует результаты** всех под-pipeline.

## Вход
- Полное описание фичи
- Структурированный контекст из роутера: scope, affected_modules
- `.qwen/memory/facts.md`

## Phase 1: NEW CODE

Выполни pipeline `.qwen/pipelines/new-code.md` полностью (все фазы: ANALYSIS → ARCHITECTURE → DATABASE → CODE → TESTS → REVIEW → CAPTURE).

**НЕ сокращай.** new-code.md содержит собственные CHECKPOINT и ЖЁСТКИЕ ПРАВИЛА — следуй им.

---
**CHECKPOINT:** Phase 1 завершена. new-code выполнен полностью. Переход к Phase 2.

## Phase 2: API DOCS

Выполни pipeline `.qwen/pipelines/api-docs.md` для созданного модуля.

Если фича не содержит API-эндпоинтов — `[SKIP] Phase 2: нет API-эндпоинтов`.

---
**CHECKPOINT:** Phase 2 завершена (или пропущена обоснованно). Переход к Phase 3.

## Phase 3: QA DOCS

Выполни pipeline `.qwen/pipelines/qa-docs.md` для созданного модуля.

Если фича не содержит API-эндпоинтов — `[SKIP] Phase 3: нет API-эндпоинтов`.

---
**CHECKPOINT:** Phase 3 завершена (или пропущена обоснованно). Переход к Phase 4.

## Phase 4: CAPTURE

**ОБЯЗАТЕЛЬНА.** Агрегируй результаты всех под-pipeline:

1. Обнови `.qwen/memory/facts.md` по секциям:
   - "## Stack" → ЗАМЕНИТЬ секцию целиком (только если стек изменился)
   - "## Key Paths" → МЕРЖИТЬ: добавь новые, удали несуществующие пути
   - "## Active Decisions" → ЗАМЕНИТЬ: только ссылки на файлы из decisions/ (НЕ archive)
   - "## Known Issues" → максимум 10 записей, удали разрешённые
   ПРАВИЛО: перед добавлением проверь — НЕ ДУБЛИРУЙ существующие записи
2. Запиши решение в `.qwen/memory/decisions/{date}-{slug}.md`
3. Обнови `.qwen/memory/patterns.md`

---
**CHECKPOINT:** Phase 4 завершена. Memory обновлена. Переход к Phase 5.

## Phase 5: FINALIZATION

### Итог
```
[FULL-FEATURE COMPLETE]
Фича: {name}
Код: {N} файлов, тесты {pass}/{total}, review {verdict}
API Docs: {status}
QA Docs: {status}
Memory updated: facts.md + decisions/ + patterns.md
```
