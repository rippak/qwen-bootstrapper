<!-- version: 6.2.2 -->
# Pipeline: Tests

## ЖЁСТКИЕ ПРАВИЛА

1. **НЕ ПРОПУСКАЙ фазы.** Проходи по ВСЕМ фазам от ANALYZE до REVIEW.
2. **НЕ ОБЪЕДИНЯЙ фазы.** ANALYZE → GENERATE → VERIFY → REVIEW — каждая отдельно.
3. **CAPTURE через REVIEW.** REVIEW фаза обязательна для проверки качества тестов.

## Вход
- Файлы / модули для покрытия тестами
- Структурированный контекст из роутера: type, affected_modules
- `.qwen/memory/facts.md`

## Phase 1: ANALYZE

1. Прочитай `.qwen/memory/facts.md` → секции: Stack, Key Paths
2. Определи целевые файлы и их public API
3. Проверь существующие тесты — не дублировать
4. Составь план тестирования: класс → методы → сценарии
5. Запиши план в `.qwen/output/plans/{task-slug}.md`

### Вывод
```
[TEST PLAN]
Целевые файлы: {список}
Сценариев: {N}
Существующих тестов: {M}
```

AskUserQuestion:
  question: "План тестирования:"
  options:
    - {label: "Подтвердить", description: "Начать генерацию тестов"}
    - {label: "Уточнить", description: "Скорректировать план"}
    - {label: "Отменить", description: "Не генерировать"}

---
**CHECKPOINT:** Phase 1 завершена. План тестирования записан. Переход к Phase 2.

## Phase 2: GENERATE

Task(.qwen/agents/{lang}-test-developer.md, subagent_type: "general-purpose"):
  Вход: прочитай `.qwen/output/plans/{task-slug}.md` + целевые файлы + `.qwen/skills/testing/SKILL.md`
  Выход: файлы тестов (НЕ код приложения — только тесты)
  Верни: summary (файлы тестов, количество кейсов)

---
**CHECKPOINT:** Phase 2 завершена. Тесты написаны. Переход к Phase 3.

## Phase 3: VERIFY

```bash
{TEST_CMD}
```

Если тесты fail — исправить (максимум 2 итерации). Исправления выполняет тот же {lang}-test-developer.

```bash
{SYNTAX_CHECK_CMD}
```

---
**CHECKPOINT:** Phase 3 завершена. Тесты прошли. Переход к Phase 4.

## Phase 4: REVIEW

**НЕ ПРОПУСКАТЬ.** Вызови reviewer для оценки качества тестов.

Task(.qwen/agents/{lang}-reviewer-logic.md, subagent_type: "general-purpose"):
  Вход: файлы тестов (git diff)
  Выход: запиши в `.qwen/output/reviews/{task-slug}-tests.md`
  Верни: summary (verdict, качество тестов, покрытие граничных случаев)

### Обработка результатов
- **BLOCK** → исправить и повторить Phase 4
- **PASS WITH WARNINGS** → исправить WARN, продолжить
- **PASS** → продолжить

---
**CHECKPOINT:** Phase 4 завершена. Review тестов выполнен.

### Итог
```
[TESTS COMPLETE]
Создано тестов: {N}
Результат: {pass}/{total}
Review: {verdict}
```
