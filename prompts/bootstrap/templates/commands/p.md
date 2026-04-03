---
name: p
description: "Алиас для /pipeline"
user-invocable: true
argument-hint: "[описание задачи]"
version: "6.2.2"
---

> **CRITICAL: Имя файла `commands/p.md` КОПИРОВАТЬ AS-IS.**

# Command: Pipeline Alias

Быстрый вызов `/pipeline`.

## Выполнение

Task(.qwen/commands/pipeline.md, subagent_type: "invocable"):
  Вход: $ARGUMENTS

## Примеры

- `/p review` = `/pipeline review`
- `/p срочно исправить баг` = `/pipeline срочно исправить баг`
- `/p` = `/pipeline` (без аргументов)
