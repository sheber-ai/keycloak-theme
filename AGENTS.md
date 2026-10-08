# Sheber Keycloak Theme — правила для разработчиков и ИИ-агентов

Тема страниц входа Keycloak для Sheber и локальный Keycloak для разработки. Подробности — [README.md](README.md).

## Главное

- Тема пишется на **чистом FTL + CSS**. Без Keycloakify, без сборщиков, без PatternFly и CSS-фреймворков.
- В git хранится **только `sheber.tar.gz`**. Папка `sheber/` — рабочая копия, она в `.gitignore`.
- Порядок работы: `make unpack` → правки в `sheber/login/` → проверка в браузере → `make pack` → коммит архива.
- Задача не завершена, пока не выполнен `make pack`: правки в папке без архива потеряются.
- Keycloak: 26.8 (`docker-compose.yml`). Тема наследует `base` (`parent=base`).

## Правила темы

- Все страницы используют макрос `registrationLayout` из `template.ftl`. Его сигнатура и набор секций
  (`header`, `show-username`, `form`, `socialProviders`, `info`) должны оставаться совместимыми с
  `base/login/template.ftl` — через него рендерятся и базовые страницы.
- Повторяющуюся разметку выносите в макросы `components.ftl` (`<@ui.field>`, `<@ui.button>`, `<@ui.checkbox>`).
- Переопределяйте страницу (`*.ftl`), только если её нельзя оформить через `theme.properties` + CSS.
  Переопределённую страницу копируйте из `base` той же версии Keycloak и сохраняйте её логику
  (имена полей формы, `url.loginAction`, проверки `messagesPerField`).
- Ошибки полей — через `messagesPerField`, весь пользовательский HTML — через `kcSanitize(...)?no_esc`.
- Классы — с префиксом `sh-` (`sh-field`, `sh-btn--primary`). Цвета — только CSS-переменные `--sh-*`
  из начала `sheber.css`. Их значения — копия `frontend/src/shared/design/tokens.css`: меняется палитра там —
  меняйте и здесь. Шрифт — Onest из `resources/fonts` (те же файлы, что во фронтенде). Эмблема — макрос
  `<@ui.logo/>`, тот же SVG, что `frontend/src/shared/design/logo.tsx`.
- Никаких внешних ресурсов (CDN, Google Fonts): всё из `resources/`.
- Тексты — только через `msg("ключ")`. Языки: ru, kk (en переводится, но в realm пока не включён). Новый ключ добавляйте в `messages_ru.properties`,
  `messages_kk.properties` и `messages_en.properties` одновременно.
- Комментарии (FTL `<#-- -->`, CSS, JS, properties, Makefile) — **только на английском**, коротко и только
  когда без них непонятно. Не пересказывайте разметку.
- Адаптивность обязательна: вёрстка работает на любой ширине от 320px до 2560px, без горизонтального скролла. Проверяйте вход, регистрацию (в т.ч. с ошибками), сброс пароля и оба языка.

## Realm

- `realm/sheber-realm.json` — только для локальной разработки. Клиенты, роли и тестовые пользователи
  описаны в README. После правки — `make reset`.
- Имена realm'а (`sheber`), клиента (`sheber-frontend`), аудитории (`sheber-backend`) и ролей
  (`client`, `contractor`, `admin`) используются в `../backend` и `../frontend` — меняйте согласованно.

## Git

Conventional Commits, описание **на английском**, в повелительном наклонении, с маленькой буквы, без точки:
`feat(login): add google sign-in`, `fix(register): fix mobile spacing`,
`chore(realm): add test contractor`. Scope: `login`, `register`, `reset-password`, `styles`, `i18n`, `realm`.

## Для ИИ-агентов

- Не коммитьте и не пушьте без явной просьбы пользователя.
- Перед правкой темы проверьте, что папка распакована из актуального архива (`make unpack`).
- После правок — `make pack` и `make check`; в ответе укажите, что архив пересобран.
- Ошибки шаблонов смотрите в `make logs` (FreeMarker пишет файл и строку).
