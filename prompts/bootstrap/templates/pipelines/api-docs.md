<!-- version: 6.2.2 -->
# Pipeline: API Docs

## ЖЁСТКИЕ ПРАВИЛА

1. **НЕ ПРОПУСКАЙ фазы.** SCAN → GENERATE → SAVE — каждая отдельно.
2. **CAPTURE через SAVE.** Сохрани контракт в output/contracts/.

## Вход
- Модуль / эндпоинты для документирования
- `.qwen/memory/facts.md`

## Phase 1: SCAN

1. Прочитай `.qwen/memory/facts.md`
2. Найди все эндпоинты целевого модуля (routes, controllers, handlers)
3. Определи request/response структуры (DTOs, schemas, models)
4. Собери middleware, guards, валидацию
5. Запиши результаты сканирования

### Вывод
```
[API SCAN]
Модуль: {name}
Эндпоинтов: {N}
```

---
**CHECKPOINT:** Phase 1 завершена. Эндпоинты найдены. Переход к Phase 2.

## Phase 2: GENERATE

Task(.qwen/agents/{lang}-developer.md, subagent_type: "general-purpose"):
  Вход: результаты сканирования + исходный код эндпоинтов
  Выход: контракт API в markdown-формате

### Формат контракта
Для каждого эндпоинта:
- Method + URL
- Headers
- Request body (JSON schema)
- Response 2xx (JSON schema)
- Response 4xx/5xx
- Пример запроса/ответа

---
**CHECKPOINT:** Phase 2 завершена. Контракт написан. Переход к Phase 3.

## Phase 3: SAVE

Сохрани в `.qwen/output/contracts/{module}.md`

### Итог
```
[API-DOCS COMPLETE]
Модуль: {name}
Эндпоинтов: {N}
Файл: .qwen/output/contracts/{module}.md
```
