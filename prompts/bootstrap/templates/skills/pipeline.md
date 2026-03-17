---
name: pipeline
description: "Роутер — классифицирует задачу и запускает нужный pipeline"
user-invocable: true
argument-hint: "[описание задачи]"
version: "5.4.1"
---

> **CRITICAL: Имя директории `skills/pipeline/` и файл frontmatter КОПИРОВАТЬ AS-IS.
> НЕ переименовывать в routing/, router/, или другое.
> Имя директории = имя slash-команды `/pipeline`. Изменение = система НЕ РАБОТАЕТ.**

# Pipeline — Единый роутер

Ты — оркестратор. Единый вход для всех операций с кодом.

## Фаза 0: Роутинг

### Шаг 1 — Контекст
1. Прочитай `.claude/memory/facts.md`
2. Проверь `.claude/memory/decisions/` — релевантные решения

### Шаг 1.5 — Парсинг флагов
Если `$ARGUMENTS` содержит `--no-analysis` или `--skip-analyst`:
- Установи `SKIP_ANALYSIS=true`
- Удали флаг из `$ARGUMENTS` перед классификацией

### Шаг 2 — Классификация
Проанализируй аргумент `$ARGUMENTS` и определи тип:

| Intent | Триггеры |
|--------|----------|
| **NEW-CODE** | новый, добавь, создай, фича, модуль, эндпоинт |
| **FIX-CODE** | баг, ошибка, fix, не работает, сломалось, regression |
| **REVIEW** | ревью, проверь, review, посмотри код |
| **TESTS** | тесты, покрытие, unit test, coverage |
| **API-DOCS** | документация, api docs, контракт |
| **QA-DOCS** | чеклист, QA, postman |
| **FULL-FEATURE** | полный цикл, feature, от начала до конца |
| **HOTFIX** | срочно, hotfix, prod |
| **FREE** | вопрос, обсуждение, объясни, помоги |
{CUSTOM_PIPELINE_KEYWORDS}

Приоритет: HOTFIX > FULL-FEATURE > явное имя > keyword > спросить.
Если FREE — ответь напрямую, без pipeline.
Если неоднозначно — спросить через AskUserQuestion.

### Шаг 3 — Подтверждение
```
[PIPELINE: {TYPE}] {краткое описание задачи}
Подтвердить? (или уточнить)
```

### Шаг 3.5 — Анализ задачи (только new-code / full-feature)

Если пайплайн = NEW-CODE или FULL-FEATURE и `SKIP_ANALYSIS` не установлен:

AskUserQuestion:
  question: "Запустить анализ задачи? Аналитик задаст уточняющие вопросы и сформирует ТЗ."
  options:
    - {label: "Да", description: "Аналитик изучит код, схему и сформирует ТЗ"}
    - {label: "Пропустить", description: "Сразу к архитектуре без анализа"}

Если "Пропустить" → `SKIP_ANALYSIS=true`

### Шаг 3.6 — Контекст задачи

Для NEW-CODE / FULL-FEATURE — пропустить (аналитик или architect разберутся сами).

Для FIX-CODE / HOTFIX:

AskUserQuestion:
  question: "Тип проблемы?"
  options:
    - {label: "Runtime error", description: "Ошибка при выполнении"}
    - {label: "Logic bug", description: "Неверная бизнес-логика"}
    - {label: "Data issue", description: "Проблема с данными"}
    - {label: "Performance", description: "Медленная работа"}

AskUserQuestion:
  question: "Где проявляется?"
  options: {динамически из facts.md → Key Paths + "Other"}
  multiSelect: true

Для TESTS:

AskUserQuestion:
  question: "Тип тестов?"
  options:
    - {label: "Unit", description: "Unit-тесты для классов/функций"}
    - {label: "Integration", description: "Интеграционные тесты"}
    - {label: "Coverage gap", description: "Покрыть непокрытые участки"}

AskUserQuestion:
  question: "Целевые модули?"
  options: {динамически из facts.md → Key Paths + "Other"}
  multiSelect: true

Для REVIEW / API-DOCS / QA-DOCS — без дополнительных вопросов.

### Шаг 4 — Диспатч
Прочитай `.claude/pipelines/{type}.md` и выполни ВСЕ фазы.

{если ADAPTIVE_TEAMS:}
> **Adaptive Teams:** Пайплайны new-code, review, full-feature автоматически определяют
> режим выполнения (team/sequential) в Phase 0. Отдельная классификация НЕ нужна —
> роутинг остаётся прежним.
{/если}
