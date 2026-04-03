<!-- version: 6.2.1 -->
# Pipeline: Fix Code

## ЖЁСТКИЕ ПРАВИЛА

1. **НЕ ПРОПУСКАЙ фазы.** Проходи по ВСЕМ фазам от DIAGNOSIS до CAPTURE.
2. **НЕ ОБЪЕДИНЯЙ фазы.** DIAGNOSIS → FIX → TESTS → REVIEW → CAPTURE — каждая отдельно.
3. **REVIEW не пропускается.** Вызови минимум {lang}-reviewer-logic.
4. **CAPTURE обязательна.** Обнови issues.md перед финальным отчётом.

## Вход
- Описание бага / ошибки
- Структурированный контекст из роутера: type, affected_modules
- `.qwen/memory/facts.md`

## Phase 1: DIAGNOSIS

1. Прочитай `.qwen/memory/facts.md` → секции: Stack, Key Paths
2. Прочитай `.qwen/memory/issues.md`
3. Локализуй проблему: файл, строка, причина
4. Определи root cause
5. Проверь `.qwen/memory/decisions/` на релевантные ограничения
6. Запиши диагностику в `.qwen/output/plans/{task-slug}.md`

### Вывод диагностики
```
[DIAGNOSIS]
Файл: {path}
Root cause: {описание}
Затронутые модули: {список}
```

Покажи диагностику пользователю.

AskUserQuestion:
  question: "План исправления:"
  options:
    - {label: "Подтвердить", description: "Приступить к исправлению"}
    - {label: "Уточнить", description: "Скорректировать план"}
    - {label: "Отменить", description: "Не исправлять"}

---
**CHECKPOINT:** Phase 1 завершена. Диагностика записана. Переход к Phase 2.

## Phase 2: FIX

Task(.qwen/agents/{lang}-developer.md, subagent_type: "general-purpose"):
  Вход: прочитай `.qwen/output/plans/{task-slug}.md` + `.qwen/skills/code-style/SKILL.md`
  Выход: исправленные файлы (НЕ тесты — тесты пишутся в Phase 3)
  Верни: summary (изменённые файлы, что исправлено)

```bash
{SYNTAX_CHECK_CMD}
```

---
**CHECKPOINT:** Phase 2 завершена. Код исправлен, синтаксис проверен. Переход к Phase 3.

## Phase 3: TESTS

Task(.qwen/agents/{lang}-test-developer.md, subagent_type: "general-purpose"):
  Вход: исправленные файлы (из git diff или summary Phase 2) + описание бага + `.qwen/skills/testing/SKILL.md`
  Выход: regression test, подтверждающий исправление (НЕ код приложения — только тесты)
  Верни: summary (тесты, результат)

```bash
{TEST_CMD}
```

Если тесты fail — исправить (максимум 2 итерации).

---
**CHECKPOINT:** Phase 3 завершена. Regression тесты прошли. Переход к Phase 4.

## Phase 4: REVIEW

**НЕ ПРОПУСКАТЬ.** Вызови reviewer.

Task(.qwen/agents/{lang}-reviewer-logic.md, subagent_type: "general-purpose"):
  Вход: все изменённые файлы (git diff)
  Выход: запиши в `.qwen/output/reviews/{task-slug}-logic.md`
  Верни: summary (verdict, замечания по severity)

### Обработка результатов
- **BLOCK** → исправить и повторить Phase 4
- **PASS WITH WARNINGS** → исправить WARN, продолжить
- **PASS** → продолжить

---
**CHECKPOINT:** Phase 4 завершена. Review выполнен. Переход к Phase 5.

## Phase 5: CAPTURE

**ОБЯЗАТЕЛЬНА.** Выполни перед финальным отчётом:

1. Обнови `.qwen/memory/facts.md` по секциям:
   - "## Key Paths" → МЕРЖИТЬ: добавь новые, удали несуществующие пути
   - "## Known Issues" → максимум 10 записей, удали разрешённые
   ПРАВИЛО: перед добавлением проверь — НЕ ДУБЛИРУЙ существующие записи
2. Добавь в `.qwen/memory/issues.md` описание бага и решения
3. Обнови `.qwen/memory/patterns.md` если выявлен антипаттерн

### Итог
```
[FIX-CODE COMPLETE]
Root cause: {описание}
Исправлено файлов: {N}
Regression test: {pass/fail}
Review: {verdict}
Memory updated: issues.md + facts.md
```
