<!-- version: 6.2.3 -->
# Pipeline: QA Docs

## ЖЁСТКИЕ ПРАВИЛА

1. **НЕ ПРОПУСКАЙ фазы.** INPUT → CHECKLIST → POSTMAN → SAVE — каждая отдельно.
2. **Если нет контракта API — скажи пользователю** и предложи сначала запустить API Docs.

## Вход
- Модуль / фича для QA-документации
- `.qwen/memory/facts.md`

## Phase 1: INPUT

1. Прочитай `.qwen/memory/facts.md`
2. Найди контракт API: `.qwen/output/contracts/{module}.md`
3. Изучи бизнес-логику модуля (сервисы, валидация, edge cases)
4. Если контракта нет — сообщи пользователю и предложи запустить pipeline API Docs

---
**CHECKPOINT:** Phase 1 завершена. Контракт найден. Переход к Phase 2.

## Phase 2: CHECKLIST

Task(.qwen/agents/qa-engineer.md, subagent_type: "general-purpose"):
  Вход: контракт API + исходный код модуля
  Выход: чеклист тестирования

### Формат чеклиста
Для каждого эндпоинта:
- Позитивные сценарии
- Негативные сценарии (невалидные данные, 401, 403, 404)
- Граничные случаи
- Интеграционные проверки (зависимости между модулями)

---
**CHECKPOINT:** Phase 2 завершена. Чеклист написан. Переход к Phase 3.

## Phase 3: POSTMAN

Task(.qwen/agents/qa-engineer.md, subagent_type: "general-purpose"):
  Вход: контракт API + чеклист
  Выход: Postman-коллекция (JSON)

### Содержание коллекции
- Папки по эндпоинтам
- Pre-request scripts (auth, переменные)
- Tests (assertions на status, body, headers)
- Environment variables

---
**CHECKPOINT:** Phase 3 завершена. Коллекция создана. Переход к Phase 4.

## Phase 4: SAVE

1. Сохрани чеклист в `.qwen/output/qa/{module}-checklist.md`
2. Сохрани коллекцию в `.qwen/output/qa/{module}-postman.json`

### Итог
```
[QA-DOCS COMPLETE]
Модуль: {name}
Сценариев: {N}
Файлы:
  - .qwen/output/qa/{module}-checklist.md
  - .qwen/output/qa/{module}-postman.json
```
