# Sheber — тема Keycloak и локальный Keycloak

Тема страниц входа (`sheber`) на чистом FreeMarker (FTL) + CSS, без Keycloakify и PatternFly,
и `docker-compose.yml` с Keycloak для разработки темы, backend и frontend.

В репозитории тема хранится **только архивом** `sheber.tar.gz`. Папка `sheber/` — рабочая копия:
распаковали → поправили → запаковали → закоммитили архив. Папка в `.gitignore`.

## Требования

- Docker и Docker Compose v2
- `make` и `tar` (macOS/Linux; на Windows — WSL или Git Bash)

## Быстрый старт

```bash
make up        # распакует тему (если папки нет) и запустит Keycloak + Mailpit
```

| Что | Адрес | Доступ |
|---|---|---|
| Keycloak Admin Console | http://localhost:8080 | `admin` / `admin` |
| Realm `sheber` | http://localhost:8080/realms/sheber/account | тестовые пользователи ниже |
| Mailpit (письма) | http://localhost:8025 | — |

При первом старте Keycloak создаёт realm `sheber` из [realm/sheber-realm.json](realm/sheber-realm.json):
тема входа уже выбрана, языки ru/kk/en, регистрация и сброс пароля включены, письма уходят в Mailpit.

### Тестовые пользователи

Пароль у всех — `sheber`.

| Логин | Роли |
|---|---|
| `client@sheber.local` | client |
| `contractor@sheber.local` | client, contractor |
| `admin@sheber.local` | client, admin |

Каждый новый зарегистрированный пользователь получает роль `client` (default-роль realm'а).

### Клиенты realm'а

| Client ID | Тип | Для чего |
|---|---|---|
| `sheber-frontend` | public, PKCE S256 | вход во frontend (`http://localhost:5173`) и Swagger backend'а (`http://localhost:8000/api/docs`). Audience mapper добавляет в access token `aud: sheber-backend` — его проверяет backend |

## Работа с темой

### 1. Распаковать

```bash
make unpack            # = tar -xzf sheber.tar.gz
```

Получится `sheber/login/`. Keycloak запущен в `start-dev`, кэш тем выключен —
правки видны после обновления страницы, перезапуск не нужен. В контейнер смонтирован корень репозитория,
поэтому после `make pack` (папка удалена) Keycloak показывает стандартную тему, а после `make unpack` — снова нашу.

### 2. Править

```
sheber/login/
├── theme.properties          parent=base, языки, CSS-классы для базовых страниц
├── template.ftl              каркас всех страниц (макрос registrationLayout)
├── components.ftl            общие элементы: поле, кнопка, чекбокс, логотип
├── login.ftl                 вход
├── register.ftl              регистрация (поля из User Profile realm'а)
├── login-reset-password.ftl  запрос сброса пароля
├── login-update-password.ftl новый пароль
├── messages/
│   ├── messages_ru.properties
│   ├── messages_kk.properties
│   └── messages_en.properties
└── resources/
    ├── css/sheber.css        все стили темы
    ├── js/sheber.js          защита от двойной отправки форм
    ├── fonts/                Onest (woff2: cyrillic, cyrillic-ext, latin, latin-ext)
    └── img/favicon.svg
```

- Страницы, которых нет в теме (ошибки, OTP, подтверждение e-mail и т.д.), берутся из темы `base`
  и рендерятся через наш `template.ftl`. Их внешний вид задают классы в `theme.properties` + `sheber.css`.
- Нужно изменить такую страницу — скопируйте её из `base` (`org.keycloak.keycloak-themes-<версия>.jar`,
  путь `theme/base/login/`) в `sheber/login/` и правьте копию.
- Тексты: свои ключи — в `messages_ru.properties`, `messages_kk.properties` и `messages_en.properties` **одновременно**.
  Стандартные строки Keycloak переопределяются там же тем же ключом.
- Цвета, шрифт и эмблема повторяют дизайн-систему фронтенда (`frontend/src/shared/design`) — меняйте согласованно.
- Комментарии в коде темы — на английском, коротко и только по необходимости.
- Проверка: http://localhost:8080/realms/sheber/account → «Войти». Язык переключается в карточке.

### 3. Запаковать и закоммитить

```bash
make pack     # чистит мусор macOS, пакует sheber/login, проверяет архив и удаляет папку
git add sheber.tar.gz
git commit -m "feat(login): add google sign-in"
```

Архив всегда собирается из корня репозитория с относительным путём `sheber/login` — иначе Keycloak
не найдёт тему и молча покажет стандартную. `make pack` делает это сам; вручную:

```bash
COPYFILE_DISABLE=1 tar -czf sheber.tar.gz sheber/login
make check    # все пути должны начинаться с sheber/login/
```

`COPYFILE_DISABLE=1` нужен на macOS, чтобы в архив не попали служебные файлы `._*`.

## Команды

```bash
make up       # запустить (распакует тему при необходимости)
make down     # остановить
make logs     # логи Keycloak (ошибки FTL видны здесь)
make reset    # пересоздать Keycloak: realm заново импортируется из realm/sheber-realm.json
make unpack   # распаковать тему
make pack     # запаковать тему и удалить папку
make check    # проверить структуру архива
```

## Изменение realm'а

`realm/sheber-realm.json` — конфигурация **только для локальной разработки** (тестовые пароли, localhost).
Импорт срабатывает, только если realm ещё не существует, поэтому после правки файла: `make reset`.

Настроили что-то в админке и хотите сохранить — экспортируйте realm
(Realm settings → Action → Partial export) и перенесите нужные части в файл.
