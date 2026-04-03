<!-- version: 6.2.1 -->
# Pipeline: Hotfix

## ЖЁСТКИЕ ПРАВИЛА

1. **fix-code и review выполняются целиком.** Не сокращай под-pipeline.
2. **CAPTURE обязательна.** Зафиксируй проблему и решение в issues.md.

## Вход
- Описание критичной проблемы
- Структурированный контекст из роутера: type, affected_modules
- `.qwen/memory/facts.md`

## Phase 1: FIX

Выполни pipeline `.qwen/pipelines/fix-code.md` полностью (все 5 фаз: DIAGNOSIS → FIX → TESTS → REVIEW → CAPTURE).

**НЕ сокращай.** fix-code.md содержит собственные ЖЁСТКИЕ ПРАВИЛА.

---
**CHECKPOINT:** Phase 1 завершена. fix-code выполнен полностью. Переход к Phase 2.

## Phase 2: REVIEW

Выполни pipeline `.qwen/pipelines/review.md` для всех изменённых файлов (все 3 фазы).

Если review вернул BLOCK — вернись к Phase 1 для исправления.

---
**CHECKPOINT:** Phase 2 завершена. Review выполнен. Переход к Phase 3.

## Phase 3: CAPTURE

**ОБЯЗАТЕЛЬНА.** Выполни перед финальным отчётом:

1. Обнови `.qwen/memory/facts.md` по секциям:
   - "## Key Paths" → МЕРЖИТЬ: добавь новые, удали несуществующие пути
   - "## Known Issues" → максимум 10 записей, удали разрешённые
   ПРАВИЛО: перед добавлением проверь — НЕ ДУБЛИРУЙ существующие записи
2. Добавь в `.qwen/memory/issues.md` описание проблемы и решения
3. Обнови `.qwen/memory/patterns.md` если выявлен антипаттерн

## Phase 4: FINALIZATION

### Итог
```
[HOTFIX COMPLETE]
Проблема: {описание}
Root cause: {причина}
Исправлено: {N} файлов
Regression test: {pass/fail}
Review: {verdict}
Memory updated: issues.md + facts.md
```
