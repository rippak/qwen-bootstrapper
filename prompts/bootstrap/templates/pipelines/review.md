<!-- version: 6.2.3 -->
# Pipeline: Review

## ЖЁСТКИЕ ПРАВИЛА

1. **Оба reviewer обязательны.** Вызывай И {lang}-reviewer-logic, И {lang}-reviewer-security. Без исключений.
2. **Не пропускай Phase 2: REPORT.** Объедини результаты перед выводом пользователю.
3. **CAPTURE через фиксацию issues.** Запиши recurring issues в issues.md.

## Вход
- Файлы для ревью (diff или список путей)
- `.qwen/memory/facts.md`

{если ADAPTIVE_TEAMS: включи `templates/includes/capability-detect.md`}

## Phase 1: PARALLEL REVIEW

### Режим TEAM (если EXECUTION_MODE=team)

Создай команду из двух тиммейтов для параллельного ревью:

Teammate "reviewer-logic":
  Промпт: Прочитай .qwen/agents/{lang}-reviewer-logic.md и выполни как свою роль.
  Вход: файлы для ревью + `.qwen/skills/code-style/SKILL.md` + `.qwen/skills/architecture/SKILL.md`
  Выход: запиши в `.qwen/output/reviews/{task-slug}-logic.md`
  По завершении: отправь message лиду с summary (verdict, замечания по severity)

Teammate "reviewer-security":
  Промпт: Прочитай .qwen/agents/{lang}-reviewer-security.md и выполни как свою роль.
  Вход: файлы для ревью
  Выход: запиши в `.qwen/output/reviews/{task-slug}-security.md`
  По завершении: отправь message лиду с summary (verdict, замечания по severity)

Жди завершения обоих тиммейтов. Собери результаты из их messages.

### Режим SEQUENTIAL (если EXECUTION_MODE=sequential)

Запусти одновременно:

Task(.qwen/agents/{lang}-reviewer-logic.md, subagent_type: "general-purpose"):
  Вход: файлы для ревью + `.qwen/skills/code-style/SKILL.md` + `.qwen/skills/architecture/SKILL.md`
  Выход: запиши в `.qwen/output/reviews/{task-slug}-logic.md`
  Верни: summary (verdict, замечания по severity)

Task(.qwen/agents/{lang}-reviewer-security.md, subagent_type: "general-purpose"):
  Вход: файлы для ревью
  Выход: запиши в `.qwen/output/reviews/{task-slug}-security.md`
  Верни: summary (verdict, замечания по severity)

**НЕ ПЕРЕХОДИ К Phase 2,** пока оба reviewer не завершены.

---
**CHECKPOINT:** Phase 1 завершена. Оба reviewer отработали. Переход к Phase 2.

## Phase 2: REPORT

### Объединение результатов
1. Прочитай `.qwen/output/reviews/{task-slug}-logic.md` и `{task-slug}-security.md`
2. Собери все замечания из обоих ревью
3. Отсортируй по severity: BLOCK → WARN → INFO
4. Удали дубликаты (один и тот же файл:строка)

### Сводная таблица
| # | Source | Severity | Файл:строка | Проблема | Рекомендация |
|---|--------|----------|-------------|----------|--------------|

### Verdict
- **BLOCK** — есть хотя бы один BLOCK → код требует исправлений
- **PASS WITH WARNINGS** — только WARN/INFO → рекомендовано исправить
- **PASS** — замечаний нет или только INFO

Покажи пользователю сводную таблицу и verdict.

---
**CHECKPOINT:** Phase 2 завершена. Отчёт показан. Переход к Phase 3.

## Phase 3: CAPTURE

1. Обнови `.qwen/memory/facts.md` по секциям:
   - "## Known Issues" → максимум 10 записей, удали разрешённые
   ПРАВИЛО: перед добавлением проверь — НЕ ДУБЛИРУЙ существующие записи
2. Добавь recurring issues в `.qwen/memory/issues.md`
3. Обнови `.qwen/memory/patterns.md` если выявлены антипаттерны

### Итог
```
[REVIEW COMPLETE]
Logic: {verdict} ({N} замечаний)
Security: {verdict} ({N} замечаний)
Overall: {verdict}
Memory updated: issues.md + patterns.md
```
