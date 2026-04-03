# Шаг 5: Верификация

## Вход
- BOOTSTRAP_MODE: fresh | validate
- Все отчёты из step-4, step-4b, step-4c, step-4-settings

## Выход
Верни результат:
- Результат верификации: все [OK] или список проблем
- .bootstrap-version создан

## 5.1 Запуск верификации

Прочитай шаблон `templates/verify-bootstrap.sh` → запиши в `.qwen/scripts/verify-bootstrap.sh` (если ещё не создан на шаге 4).

Запусти скрипт верификации одной командой:

```bash
bash .qwen/scripts/verify-bootstrap.sh
```

## 5.2 Version Tracking

Сгенерируй файл `.qwen/.bootstrap-version`:

```bash
HASHES="{}"
for f in .qwen/agents/*.md .qwen/commands/*.md .qwen/skills/*/SKILL.md .qwen/pipelines/*.md .qwen/scripts/hooks/*.sh .qwen/scripts/verify-bootstrap.sh; do
    [ -f "$f" ] || continue
    REL=$(echo "$f" | sed 's|^.qwen/||')
    HASH=$(sha256sum "$f" | cut -d' ' -f1)
    HASHES=$(echo "$HASHES" | jq --arg k "$REL" --arg v "sha256:$HASH" '. + {($k): $v}')
done

jq -n \
    --arg date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg version "6.2.3" \
    --argjson hashes "$HASHES" \
    '{
        version: $version,
        generated: $date,
        hashes: $hashes
    }' > .qwen/.bootstrap-version
```

Поле `version` — версия бутстрапера. Используется при `validate` для сравнения с версиями в шаблонах скиллов/пайплайнов.

## 5.3 Итоговый отчёт

Покажи:
- Количество агентов, скиллов, пайплайнов
- Стек проекта
- Что было вычленено из QWEN.md (если было)
- Список всех созданных файлов
- Результат верификации (все [OK] или есть [MISS]/[ERR])

## ФИНАЛ

После завершения всех шагов выведи:

```
╔══════════════════════════════════════════════╗
║  Qwen Code Automation — Bootstrap Complete ║
╠══════════════════════════════════════════════╣
║  Project: {PROJECT_NAME}                     ║
║  Stack: {LANGS} + {FRONTEND}                  ║
║  DB: {DB}                                    ║
║                                              ║
║  Agents: {N_BASE + N_CUSTOM}                 ║
║  Skills: {7 + N_CUSTOM_SKILLS}               ║
║  Pipelines: {8 + N_CUSTOM_PIPELINES}         ║
║  Hooks: 5                                    ║
║  Memory: facts + patterns + issues + decisions║
║  MCP: {gitlab | none}                        ║
║  Quick start:                                ║
║  /pipeline new-code  или  /p new-code        ║
╚══════════════════════════════════════════════╝
```
