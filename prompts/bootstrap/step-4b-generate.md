# Шаг 4b: Генерация (Скиллы + Пайплайны)

## Вход
- BOOTSTRAP_MODE: fresh | validate
- LANGS, PRIMARY_LANG, FRAMEWORK_{lang}
- CUSTOM_SKILLS, CUSTOM_PIPELINES
- ADAPTIVE_TEAMS: true | false

## Выход
Верни результат:
- Список созданных/обновлённых скиллов с статусами
- Список созданных/обновлённых пайплайнов с статусами

> Продолжение шага 4. Правила записи файлов и стек-адаптации — см. `step-4-generate.md`.

## Правила записи (краткое напоминание)
- `fresh`: записывать без проверок
- `validate`: файл есть → валидация → `[OK]`/`[FIX]`/`[REGEN]`; файла нет → `[NEW]`

## Версионирование шаблонов

Все шаблоны (скиллы и пайплайны) содержат версию бутстрапера:
- **Скиллы**: поле `version` в YAML frontmatter (например `version: "5.4.2"`)
- **Пайплайны**: HTML-комментарий в первой строке (например `<!-- version: 5.4.2 -->`)

При валидации (`validate` режим):
- Извлеки версию из локального файла и из шаблона
- Нет версии или версия < шаблона → `[REGEN] {path}: version outdated`
- Версия совпадает → продолжить остальные проверки

---

## 4.3 Скиллы

### Валидация (режим `validate`)

#### Все скиллы (.qwen/skills/*/SKILL.md)
- Начинается с YAML frontmatter (`---` блок) с полями `name`, `description`, `version`
- `description` — ОДНА строка (критичное ограничение Qwen Code)
- `version` — совпадает с версией шаблона (см. «Версионирование шаблонов»)
- Для pipeline и p: `user-invocable: true`
- Для остальных скиллов: `user-invocable: false`
→ Нет frontmatter → добавить из шаблона → `[FIX] {path}: добавлен frontmatter`
→ Нет `version` или version < шаблона → перегенерировать из шаблона → `[REGEN] {path}: version outdated`

#### commands/pipeline.md (CRITICAL)
- Файл расположен в `commands/pipeline.md`
- Содержит frontmatter с `user-invocable: true`
- Содержит `name: pipeline` в frontmatter
- Содержит `version: N` в frontmatter — сравнить с шаблоном (`templates/skills/pipeline.md`)
- Содержит таблицу Intent → Триггеры
- Содержит Шаг 4 — Диспатч с ссылкой на `.qwen/pipelines/`
→ Нет frontmatter → добавить → `[FIX] добавлен frontmatter`
→ Нет таблицы → перегенерировать из шаблона → `[REGEN] pipeline.md`
→ Нет `version` или version < шаблона → перегенерировать из шаблона → `[REGEN] pipeline.md: version outdated`

#### commands/p.md
- Содержит frontmatter с `user-invocable: true`
- Ссылается на `/pipeline`
→ Нет → создать из шаблона → `[NEW] commands/p.md`

---

### Генерация

Для каждого скилла прочитай шаблон из `templates/skills/` → подставь переменные → запиши в `.qwen/skills/{name}/SKILL.md`:

  `templates/skills/code-style.md` → `.qwen/skills/code-style/SKILL.md`
  `templates/skills/architecture.md` → `.qwen/skills/architecture/SKILL.md`
  `templates/skills/database.md` → `.qwen/skills/database/SKILL.md`
  `templates/skills/testing.md` → `.qwen/skills/testing/SKILL.md`
  `templates/skills/memory.md` → `.qwen/skills/memory/SKILL.md`

Для каждой команды прочитай шаблон из `templates/commands/` → подставь переменные → запиши в `.qwen/commands/{name}.md`:
  `templates/commands/pipeline.md` → `.qwen/commands/pipeline.md`
  `templates/commands/p.md` → `.qwen/commands/p.md`

### 4.3.1 Кастомные скиллы

Для каждого скилла из CUSTOM_SKILLS сгенерируй файл `.qwen/skills/{name}/SKILL.md` по шаблону:

```markdown
---
name: "{name}"
description: "{DESCRIPTION — краткое описание, одна строка}"
user-invocable: false
---

# Skill: {Name} — {DESCRIPTION}

## Паттерны
{Сгенерируй на основе назначения скилла и стека проекта}

## Антипаттерны
{Типичные ошибки}

## Примеры
{Конкретные примеры для стека}
```

---

## 4.4 Пайплайны

### Валидация (режим `validate`)

#### Пайплайны (.qwen/pipelines/*.md)

**Приоритет 1 — версия (проверяй ПЕРВЫМ для КАЖДОГО пайплайна без исключений):**
- Первая строка содержит `<!-- version: X.Y.Z -->` — сравнить с версией в шаблоне
- Нет version или version < шаблона → `[REGEN] {path}: version outdated`
- ВАЖНО: это касается ВСЕХ пайплайнов, включая композитные (full-feature, hotfix), которые не содержат Task()

**Приоритет 2 — структура (только если версия совпала):**
- Task()-пайплайны (new-code, fix-code, review, tests, api-docs, qa-docs): содержат Task() pseudo-syntax
- Композитные пайплайны (full-feature, hotfix): ссылаются на другие пайплайны через «Выполни pipeline», Task() НЕ требуется
- НЕ содержит устаревших текстовых инструкций типа "Прочитай .qwen/agents/X.md"
- Параллельные агенты помечены "Запусти одновременно:"
→ Task()-пайплайн без Task() → `[REGEN] {path}`
  (при перегенерации сохранять кастомные секции, специфичные для проекта)

### Cleanup легаси
- Task()-пайплайны без Task() syntax → перегенерировать с сохранением проектной специфики → `[REGEN] {path}`

---

### Генерация

**Правило выбора языка в мульти-язычных проектах:**
- `{lang}` в пайплайне = язык, релевантный текущей задаче
- Если задача затрагивает конкретный модуль — определи язык по модулю
- Если неоднозначно — используй `PRIMARY_LANG`
- Для задач, затрагивающих несколько языков — фазы CODE, TESTS, REVIEW повторяются для каждого затронутого языка с соответствующими агентами

Для каждого пайплайна прочитай шаблон из `templates/pipelines/` → подставь переменные → запиши в `.qwen/pipelines/{name}.md`:

  `templates/pipelines/new-code.md` → `.qwen/pipelines/new-code.md`
  `templates/pipelines/fix-code.md` → `.qwen/pipelines/fix-code.md`
  `templates/pipelines/review.md` → `.qwen/pipelines/review.md`
  `templates/pipelines/tests.md` → `.qwen/pipelines/tests.md`
  `templates/pipelines/api-docs.md` → `.qwen/pipelines/api-docs.md`
  `templates/pipelines/qa-docs.md` → `.qwen/pipelines/qa-docs.md`
  `templates/pipelines/full-feature.md` → `.qwen/pipelines/full-feature.md`
  `templates/pipelines/hotfix.md` → `.qwen/pipelines/hotfix.md`

### 4.4.1 Кастомные пайплайны

Для каждого пайплайна из CUSTOM_PIPELINES сгенерируй файл `.qwen/pipelines/{name}.md` по шаблону:

```markdown
# Pipeline: {Name}

## Фазы

{Сгенерируй фазы на основе описания и указанных агентов. Минимум 2 фазы, максимум 5.
Используй Task() pseudo-syntax для вызова агентов.}

## Матрица ошибок

| Проблема | Действие | Откат |
|----------|----------|-------|
```

### 4.4.2 Adaptive Teams

Если `ADAPTIVE_TEAMS=true`:

Для пайплайнов **new-code**, **review**:
1. Прочитай `templates/includes/capability-detect.md`
2. Вставь содержимое как Phase 0: CAPABILITY DETECT перед Phase 1
3. Добавь adaptive-секции (Режим TEAM / Режим SEQUENTIAL) в фазы с параллелизацией
4. Удали директиву `{если ADAPTIVE_TEAMS: включи ...}` — она заменена реальным содержимым

Для **full-feature**:
- Наследует adaptive через ссылку на new-code.md (Phase 1 = "Выполни pipeline new-code.md")
- Без собственных изменений

Если `ADAPTIVE_TEAMS=false`:
- Удали директивы `{если ADAPTIVE_TEAMS: ...}` из шаблонов
- Оставь только SEQUENTIAL-логику (текущий формат с Task() и "Запусти одновременно:")

**Валидация:**
- Каждая adaptive-фаза содержит ОБА режима (TEAM + SEQUENTIAL)
- Секции "Режим TEAM" используют Teammate-синтаксис (НЕ устаревший TeamCreate/Spawn/Shutdown)
- Task() только в секциях "Режим SEQUENTIAL"
- Phase 0 CAPABILITY DETECT проверяет env `QWEN_CODE_EXPERIMENTAL_AGENT_TEAMS` (НЕ наличие инструмента TeamCreate)
