# Шаг 2: Обработка QWEN.md

## Вход
- BOOTSTRAP_MODE: fresh | validate
- LANGS, PRIMARY_LANG, FRAMEWORK, DB, FRONTEND
- Все переменные из step-1

## Выход
Верни результат:
- Статус QWEN.md: [OK] | [FIX] | [NEW]
- Вычлененные правила (для skills)

## Режим `validate` — валидация существующего QWEN.md

Если `BOOTSTRAP_MODE = "validate"` и `QWEN.md` существует:

**НЕ перезаписывать QWEN.md целиком.** Провести валидацию и исправить конкретные проблемы IN-PLACE:

### Проверка 1: ЖЁСТКОЕ ПРАВИЛО routing
- `## Rules` должен содержать первым правилом "**ЖЁСТКОЕ ПРАВИЛО — Routing:**"
- Правило должно ссылаться на `/pipeline`
→ Нет → добавить первым в `## Rules` → `[FIX] QWEN.md: добавлено ЖЁСТКОЕ ПРАВИЛО routing`

### Проверка 2: Устаревшие секции
- НЕ должно содержать секцию "Auto-Pipeline Rule" (устаревшая)
- НЕ должно содержать ссылки на `skills/routing/`
→ Найдено → удалить/заменить на актуальные → `[FIX] QWEN.md: удалена устаревшая секция`

### Проверка 3: Таблицы Agents/Skills/Pipelines
- Должны существовать секции `## Agents`, `## Skills`, `## Pipelines`
- Таблица Agents должна соответствовать реальным файлам в `.qwen/agents/`
- Таблица Skills должна соответствовать реальным директориям в `.qwen/skills/`
- Таблица Pipelines должна соответствовать реальным файлам в `.qwen/pipelines/`
→ Расхождения → обновить таблицы по реальным файлам → `[FIX] QWEN.md: обновлены таблицы`

### Проверка 4: Ссылка на /pipeline
- Секция `## Pipelines` должна содержать "Запуск: `/pipeline {имя}` или `/p {имя}`"
→ Нет → добавить → `[FIX] QWEN.md: добавлена ссылка на /pipeline`

После всех проверок: `[OK] QWEN.md` если проблем нет, или список `[FIX]` по каждому исправлению.

**Перейти к следующему шагу** (НЕ выполнять секции ниже для режима validate).

---

## Режим `fresh` — создание нового QWEN.md

## Если QWEN.md существует

1. Прочитай текущий `QWEN.md`
2. Вычлени из него:
   - **Правила кода** (стиль, именование, типизация, запреты) → будут в `skills/code-style/SKILL.md`
   - **Архитектура** (структура модулей, DI, паттерны) → будут в `skills/architecture/SKILL.md`
   - **БД паттерны** (миграции, типы, индексы) → будут в `skills/database/SKILL.md`
   - **Тест паттерны** (фреймворк, моки, структура) → будут в `skills/testing/SKILL.md`
   - **Команды** (build, test, deploy) → будут в агентах devops, developer

## Перезапиши QWEN.md по шаблону

```markdown
# QWEN.md

## Project Overview

{PROJECT_NAME} — {краткое описание из анализа}.

{для каждого lang из LANGS:}
- {LANG} {VERSION} + {FRAMEWORK_{lang}}
{/для каждого}
- {DB} + {CONTAINER}
- {FRONTEND} (frontend)

## Rules

- **ЖЁСТКОЕ ПРАВИЛО — Routing:** Каждый запрос пользователя ОБЯЗАТЕЛЬНО классифицировать.
  Если запрос связан с кодом, фиксами, ревью, тестами, рефакторингом, документацией —
  вызвать `/pipeline`. Роутер внутри определит тип действия и запустит нужный поток.
  Свободная форма допускается ТОЛЬКО для вопросов, обсуждений, не связанных с кодом.
- Кратко, по делу, без теории
- Код — только по прямому запросу
- Никаких docblock или comments в коде, если они не требуются для static analysis
- Никаких git commit или git push, если не попросят
{LANG_SPECIFIC_RULES — вычлени из старого QWEN.md или определи по стеку}

## Commands

```bash
{BUILD_CMD}
{TEST_CMD}
{LINT_CMD}
{MIGRATE_CMD}
{OTHER_CMDS}
```

## Architecture

### Module Structure
```
{ACTUAL_MODULE_STRUCTURE — сканируй src/ или app/ или lib/}
```

### Key Principles
{PRINCIPLES — вычлени из старого QWEN.md или определи по стеку}

### Main Modules
{MODULES — сканируй реальные модули проекта}

### Database
{DB_INFO}

### Services (Docker)
{DOCKER_SERVICES — из docker-compose}

## Code Style
{CODE_STYLE_SUMMARY — краткая выжимка из skills/code-style}

## Agents

Промпты: `.qwen/agents/{name}.md`

| Agent | Файл | Триггер |
|-------|------|---------|
{AGENTS_TABLE}

## Skills

Детали: `.qwen/skills/{name}/SKILL.md`

| Skill | Файл | Назначение |
|-------|------|------------|
| Code Style | `code-style/` | паттерны кода, антипаттерны |
| Architecture | `architecture/` | структура модулей, DI, routes |
| Database | `database/` | миграции, типы данных, индексы |
| Testing | `testing/` | тест-паттерны |
| Memory | `memory/` | трёхуровневая память: facts, decisions, archive |
| Pipeline | `pipeline/` | `/pipeline` — роутер пайплайнов |
| Pipeline Alias | `p/` | `/p` — быстрый вызов /pipeline |
{CUSTOM_SKILLS_ROWS}

## Pipelines

Детали: `.qwen/pipelines/{name}.md`

Запуск: `/pipeline {имя}` или `/p {имя}`

| Pipeline | Файл | Когда использовать |
|----------|------|--------------------|
| New Code | `new-code.md` | новый модуль, сервис, эндпоинт |
| Fix Code | `fix-code.md` | баг, ошибка, regression |
| Review | `review.md` | ревью кода |
| Tests | `tests.md` | написание тестов |
| API Docs | `api-docs.md` | API-контракты для фронта |
| QA Docs | `qa-docs.md` | чеклисты, Postman |
| Full Feature | `full-feature.md` | полный цикл фичи |
| Hotfix | `hotfix.md` | срочное исправление |
{CUSTOM_PIPELINES_ROWS}

{если ADAPTIVE_TEAMS:}
> **Adaptive Teams:** Пайплайны new-code, review, full-feature поддерживают
> автоматическое определение режима (Teams API / Sequential).
> Opus 4.6 → параллельная работа агентов. Другие модели → последовательный fallback.
{/если}

## Memory

- `.qwen/memory/facts.md` — текущие факты проекта (стек, пути, решения, проблемы)
- `.qwen/memory/patterns.md` — повторяющиеся паттерны кода
- `.qwen/memory/issues.md` — known issues из ревью
- `.qwen/memory/decisions/` — архитектурные решения (ADR-lite)
- `.qwen/memory/decisions/archive/` — устаревшие решения (авторотация 30 дней)
- `.qwen/memory/sessions/` — архив сессий
- `.qwen/output/` — API-контракты, QA-документация
- `.qwen/input/` — входные задачи, планы
- `.qwen/database/` — схема БД, миграции
```

## Если QWEN.md не существует

Создай по шаблону выше, заполнив из результатов анализа.

**Отчёт:** что вычленено, что создано.
