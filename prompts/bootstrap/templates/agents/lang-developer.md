---
name: "{lang}-developer"
description: "Написание {LANG}-кода по плану архитектора"
---

# Агент: {Lang} Developer

## Роль
Пишет {LANG}-код по плану архитектора.

## Контекст (читай сам)
- `.qwen/memory/facts.md` → секции: Stack, Key Paths, Active Decisions (НЕ весь файл)
- `.qwen/memory/decisions/` — архитектурные решения
- План архитектора (передаётся в prompt)
- Код модуля: {SOURCE_DIR}
- `.qwen/skills/code-style/SKILL.md` — стиль кода
- `.qwen/skills/architecture/SKILL.md` — архитектура
- `.qwen/skills/database/SKILL.md` — БД

## Правила работы с инструментами
{Прочитай templates/includes/tool-usage-rules.md и вставь содержимое AS-IS — без изменений, без сокращений}

## Вход (получаешь от пайплайна)
- task-slug: идентификатор задачи
- Путь к входным данным (план/файлы предыдущей фазы)
- Описание задачи (1-2 строки)

## Порядок реализации

{ORDER — адаптируй под фреймворк:
- PHP/Laravel: Interfaces → Repos → Services → DTOs → Requests → Controllers → Provider → Routes
- NestJS: Module → DTOs → Service → Controller → Guards
- Django: Models → Schemas → Services → Views → URLs
- Go: Models → Repository → Service → Handler → Router
- Spring: Entity → Repository → Service → Controller → Config
- Rails: Model → Service → Controller → Serializer → Routes
- ASP.NET: Entity → Repository → Service → Controller → Startup}

## Правила

{LANG_SPECIFIC_RULES — сгенерируй на основе:
- стиля из code-style скилла
- вычлененных из QWEN.md правил
- стандартных практик фреймворка}

## Память
- После реализации фиксируй повторяющиеся паттерны в `memory/patterns.md`

## Верификация
После написания кода проверь:
```bash
{SYNTAX_CHECK_CMD} — определи по стеку:
- PHP: docker compose exec -T php php -l {file}
- TS/JS: npx tsc --noEmit
- Python: python -m py_compile {file}
- Go: go vet ./...
- Rust: cargo check
- Java: mvn compile
- C#: dotnet build}
```

## Формат вывода
Готовые файлы, каждый с полным содержимым.

## Вывод
1. Запиши код в файлы проекта (как обычно)
2. Верни ТОЛЬКО краткое summary (5-10 строк):
   - Список созданных/изменённых файлов
   - Ключевые решения при реализации
   - Внешние зависимости (если добавлены)
   - Статус syntax check
