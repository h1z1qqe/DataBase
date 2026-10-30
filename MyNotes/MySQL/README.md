# Интерактивная работа с MySQL в изолированном окружении Docker — в GitHub Codespaces

> Руководство для новичков: от создания репозитория на GitHub до JOIN'ов и восстановления базы из дампа. Всё выполняется **в браузере** — на вашем компьютере не нужно устанавливать ни Docker, ни MySQL, ни какие-либо программы.

**InnoDB** — основной движок хранения данных MySQL (таблицы, надёжность, транзакции). Его файлы мы посмотрим своими глазами в [Части 1](#часть-1-запуск-контейнера-mysql).

**Задачи:**

- запустить «чистый» контейнер MySQL в облаке GitHub;
- подключиться к нему в интерактивном режиме;
- выполнить основные операции с базами данных (CRUD, фильтрация, агрегация, JOIN, подзапросы, ALTER);
- сделать дамп базы данных и сохранить его в репозиторий;
- восстановить базу из дампа в новом Codespaces.

**Что понадобится:**

- аккаунт GitHub (бесплатная регистрация — [github.com/signup](https://github.com/signup));
- любой современный браузер;
- минут 15 на настройку — дальше в своём темпе.

**Единственное правило, которое нужно понять до старта.** Codespaces — это временная облачная машина. Когда вы ей не пользуетесь, она останавливается, а после 30 дней бездействия удаляется целиком — вместе со всеми базами данных. Навсегда остаётся только то, что вы отправили (push) в репозиторий. Поэтому каждое занятие в этом руководстве заканчивается одинаково: **сделали дамп → отправили в репозиторий**. Тогда вашу базу можно поднять заново за минуту в любом новом Codespaces.

## Оглавление

- [Часть 0. Подготовка: репозиторий и первый запуск Codespaces](#часть-0-подготовка-репозиторий-и-первый-запуск-codespaces)
  - [0.1. Создаём репозиторий](#01-создаём-репозиторий)
  - [0.2. Файл .devcontainer/devcontainer.json](#02-файл-devcontainerdevcontainerjson)
  - [0.3. Файл my-mysql/my.cnf](#03-файл-my-mysqlmycnf)
  - [0.4. Файл .devcontainer/restore.sh](#04-файл-devcontainerrestoresh)
  - [0.5. Запускаем Codespaces](#05-запускаем-codespaces)
  - [0.6. Проверяем результат](#06-проверяем-результат)
- [Часть 1. Запуск контейнера MySQL](#часть-1-запуск-контейнера-mysql)
  - [Разбор команды docker run](#разбор-команды-docker-run)
  - [Где «физически» хранятся файлы базы данных](#где-физически-хранятся-файлы-базы-данных)
- [Часть 2. Подключение к MySQL в интерактивном режиме](#часть-2-подключение-к-mysql-в-интерактивном-режиме)
- [Часть 3. Основные операции с базами данных и таблицами](#часть-3-основные-операции-с-базами-данных-и-таблицами)
- [Часть 4. Управление контейнером и Codespaces](#часть-4-управление-контейнером-и-codespaces)
- [Практикум по основам SQL](#практикум-по-основам-sql)
  - [Шаг 1. Создание учебной базы данных sql_practice](#шаг-1-создание-учебной-базы-данных-sql_practice)
  - [Шаг 2. Создание таблиц customers и orders](#шаг-2-создание-таблиц-customers-и-orders)
  - [Шаг 3. Вставка данных (INSERT)](#шаг-3-вставка-данных-insert)
  - [Шаг 4. Выборка данных (SELECT)](#шаг-4-выборка-данных-select)
  - [Шаг 5. Агрегатные функции](#шаг-5-агрегатные-функции)
  - [Шаг 6. Группировка GROUP BY и HAVING](#шаг-6-группировка-group-by-и-having)
  - [Шаг 7. Соединения JOIN](#шаг-7-соединения-join)
  - [Шаг 8. Подзапросы и UNION](#шаг-8-подзапросы-и-union)
  - [Шаг 8.4. Дамп базы: сохраняем работу в репозиторий](#шаг-84-дамп-базы-сохраняем-работу-в-репозиторий)
  - [Шаг 9. Обновление данных (UPDATE)](#шаг-9-обновление-данных-update)
  - [Шаг 10. Удаление данных (DELETE)](#шаг-10-удаление-данных-delete)
  - [Шаг 11. Изменение структуры (ALTER TABLE)](#шаг-11-изменение-структуры-alter-table)
  - [Шаг 12. Удаление таблиц и базы](#шаг-12-удаление-таблиц-и-базы)
  - [Шаг 13. Восстановление базы данных из дампа](#шаг-13-восстановление-базы-данных-из-дампа)
- [Жизненный цикл Codespaces: что сохраняется, а что нет](#жизненный-цикл-codespaces-что-сохраняется-а-что-нет)
- [Частые ошибки и их решения](#частые-ошибки-и-их-решения)
- [Полезные команды](#полезные-команды)
- [Что дальше?](#что-дальше)

## Как читать это руководство

- Блоки с подписями `bash` — команды **обычного терминала** Codespaces (приглашение выглядит как `@имя-машины:~/mysql-practice$`). Их набирают (или вставляют) в терминале редактора.
- Блоки с подписью `sql` — команды **внутри оболочки MySQL** (приглашение `mysql>`). Они заканчиваются точкой с запятой `;`.
- Блоки без подсветки — примеры вывода, вводить их не нужно.
- В браузерном терминале вставка из буфера — правая кнопка мыши → **Paste** или `Ctrl+Shift+V`.

В конце руководства — [шпаргалка команд](#полезные-команды) и [разбор частых ошибок](#частые-ошибки-и-их-решения).

## Часть 0. Подготовка: репозиторий и первый запуск Codespaces

В этой части мы один раз всё подготовим: создадим репозиторий с тремя небольшими файлами и запустим Codespaces. После этого MySQL будет подниматься в облаке автоматически при каждом запуске.

Итоговая структура репозитория (запомните её — будем на неё ссылаться):

```
mysql-practice/                  ← ваш репозиторий (и рабочая папка Codespaces)
├── .devcontainer/
│   ├── devcontainer.json        ← конфигурация Codespaces (Docker внутри)
│   └── restore.sh               ← автозапуск MySQL при старте
├── my-mysql/
│   ├── my.cnf                   ← конфиг MySQL (utf8mb4, кириллица)
│   └── dump.sql                 ← появится после Шага 8.4 — резервная копия базы
└── README.md                    ← описание репозитория (по желанию — это руководство)
```

> 💡 По желанию: можете заменить содержимое `README.md` этим руководством — тогда оно будет открываться на главной странице вашего репозитория.

### 0.1. Создаём репозиторий

1. Откройте [github.com](https://github.com) и войдите в свой аккаунт.
2. В правом верхнем углу нажмите **`+`** → **New repository**.
3. Заполните поля:
   - **Repository name**: `mysql-practice` (латиницей, без пробелов);
   - видимость: **Private** — для практики достаточно, Codespaces работают и с приватными репозиториями бесплатно;
   - поставьте галочку **Add a README file**.
4. Нажмите зелёную кнопку **Create repository**.

Вы окажетесь на странице нового репозитория. Пока в нём только один файл `README.md` — нормально.

### 0.2. Файл .devcontainer/devcontainer.json

Это главный файл конфигурации Codespaces: он описывает, какое окружение создать (какая ОС, какие инструменты). Именно благодаря ему Docker окажется доступен внутри Codespaces.

1. На странице репозитория нажмите **Add file** → **Create new file**.
2. В поле имени файла введите **полностью**: `.devcontainer/devcontainer.json`
   - начните с точки — файлы и папки, начинающиеся с точки, в Linux «скрытые», это нормально;
   - как только введёте символ `/`, GitHub автоматически создаст папку `.devcontainer`;
   - имена файлов чувствительны к регистру — копируйте точно.
3. В большое поле вставьте содержимое:

```jsonc
{
  // Название окружения — видно в интерфейсе Codespaces
  "name": "MySQL Practice (Docker + utf8mb4)",

  // Базовый образ: Ubuntu 24.04 с настроенным пользователем codespace
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu-24.04",

  // Docker-in-Docker: ставит полноценный Docker внутрь Codespaces,
  // чтобы можно было запускать контейнеры (в том числе наш MySQL)
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {
      "enableNonRootDocker": true
    }
  },

  // Выполняется при каждом старте Codespaces:
  // ждёт Docker, поднимает контейнер MySQL, восстанавливает базу из дампа
  "postStartCommand": "bash \"${containerWorkspaceFolder}/.devcontainer/restore.sh\""
}
```

4. Нажмите зелёную кнопку **Commit changes...** → в диалоге снова **Commit changes**.

Что здесь важно понимать:

- Codespaces сам работает «внутри контейнера», и Docker по умолчанию туда не установлен. Фича **docker-in-docker** ставит полноценный Docker внутрь вашего Codespaces — поэтому дальше всё будет работать так же, как на обычном компьютере с установленным Docker.
- **postStartCommand** — команда, которая автоматически выполняется при каждом старте Codespaces. Она запускает наш скрипт `restore.sh` (создадим его в разделе 0.4): он поднимет контейнер MySQL и, если есть дамп, восстановит из него базу. То есть после этой настройки руками запускать MySQL не нужно вообще.

### 0.3. Файл my-mysql/my.cnf

Это конфигурация MySQL: она принудительно включает кодировку utf8mb4, чтобы кириллица корректно сохранялась и отображалась.

1. Снова **Add file** → **Create new file**.
2. Имя файла: `my-mysql/my.cnf` (папка `my-mysql` создастся автоматически).
3. Содержимое:

```ini
[mysqld]
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[client]
default-character-set = utf8mb4

[mysql]
default-character-set = utf8mb4
```

4. **Commit changes...** → **Commit changes**.

Расшифровка: `utf8mb4` — кодировка UTF-8 «полного» вида в MySQL (буквы любого языка, включая кириллицу), `collation` (правило сравнения строк) `utf8mb4_unicode_ci` — нечувствительно к регистру (`ci` = case insensitive). Секции `[mysqld]`, `[client]`, `[mysql]` задают настройки серверу и клиентам.

### 0.4. Файл .devcontainer/restore.sh

Скрипт, который избавит вас от ручного запуска MySQL. Не обязательно в нём разбираться — просто скопируйте (внутри есть комментарии по каждому шагу). Если интересно: он ждёт готовности Docker, создаёт контейнер `my-mysql`, ждёт готовности MySQL и восстанавливает базу `sql_practice` из дампа, если тот лежит в репозитории.

1. **Add file** → **Create new file**.
2. Имя файла: `.devcontainer/restore.sh`.
3. Содержимое — целиком скопируйте ниже:

```bash
#!/usr/bin/env bash
# ==============================================================
#  restore.sh — автозапуск MySQL в GitHub Codespaces
#
#  Этот скрипт автоматически запускается при каждом старте
#  Codespaces (см. "postStartCommand" в devcontainer.json).
#  Его можно запускать и вручную в любой момент — это безопасно.
#
#  Что делает:
#    1. ждёт готовности Docker-демона;
#    2. создаёт контейнер my-mysql (или запускает остановленный);
#    3. ждёт готовности MySQL;
#    4. если в репозитории есть my-mysql/dump.sql, а базы
#       sql_practice ещё нет — восстанавливает базу из дампа.
# ==============================================================

CONTAINER="my-mysql"
PASSWORD="123"
DB_NAME="sql_practice"

# Корень репозитория (скрипт лежит в .devcontainer/)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CNF="$REPO_DIR/my-mysql/my.cnf"
DUMP="$REPO_DIR/my-mysql/dump.sql"

if [ ! -f "$CNF" ]; then
  echo "!! Не найден файл my-mysql/my.cnf"
  echo "!! Проверьте, что вы создали его в репозитории (раздел 0.3 руководства)"
  exit 1
fi

# --- 1. Ждём готовности Docker-демона -------------------------
echo "==> [1/4] Ждём, пока Docker будет готов..."
attempt=0
until docker info >/dev/null 2>&1; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge 60 ]; then
    echo "!! Docker не поднялся за 60 секунд."
    echo "!! Откройте новый терминал и проверьте: docker version"
    exit 1
  fi
  sleep 1
done
echo "--> Docker готов."

# --- 2. Контейнер: запускаем существующий или создаём новый ---
if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  echo "==> [2/4] Контейнер $CONTAINER уже работает."
elif docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  echo "==> [2/4] Запускаем остановленный контейнер $CONTAINER..."
  docker start "$CONTAINER"
else
  echo "==> [2/4] Создаём новый контейнер $CONTAINER..."
  echo "    (при первом запуске образ MySQL скачивается 1-3 минуты)"
  docker run --name "$CONTAINER" \
    -e MYSQL_ROOT_PASSWORD="$PASSWORD" \
    -e LANG=C.UTF-8 \
    -v mysql_data:/var/lib/mysql \
    -v "$CNF":/etc/mysql/conf.d/my.cnf:ro \
    --restart unless-stopped \
    -d mysql:latest
fi

# --- 3. Ждём готовности MySQL ---------------------------------
# Первая инициализация MySQL занимает 20-30 секунд.
echo "==> [3/4] Ждём готовности MySQL..."
attempt=0
until docker exec "$CONTAINER" mysql -uroot -p"$PASSWORD" -e "SELECT 1" >/dev/null 2>&1; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge 120 ]; then
    echo "!! MySQL не ответил за 120 секунд. Смотрим логи:"
    echo "   docker logs $CONTAINER"
    exit 1
  fi
  sleep 1
done
echo "--> MySQL готов."

# --- 4. Восстановление из дампа (если нужно) ------------------
if [ -f "$DUMP" ]; then
  if docker exec "$CONTAINER" mysql -uroot -p"$PASSWORD" -e "USE $DB_NAME" >/dev/null 2>&1; then
    echo "==> [4/4] База $DB_NAME уже существует — восстановление не требуется."
  else
    echo "==> [4/4] Восстанавливаем базу $DB_NAME из my-mysql/dump.sql..."
    docker exec "$CONTAINER" mysql -uroot -p"$PASSWORD" \
      -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    docker exec -i "$CONTAINER" mysql -uroot -p"$PASSWORD" "$DB_NAME" < "$DUMP"
    echo "--> База восстановлена."
  fi
else
  echo "==> [4/4] Файла my-mysql/dump.sql нет — восстанавливать нечего."
fi

echo ""
echo "=================================================="
echo " MySQL готов к работе!"
echo " Подключиться:"
echo "   docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p"
echo " Пароль: 123"
echo "=================================================="
```

4. **Commit changes...** → **Commit changes**.

Проверьте себя: на странице репозитория должно быть видно папки `.devcontainer` и `my-mysql` (скрытую папку `.devcontainer` видно в списке файлов, она просто начинается с точки).

### 0.5. Запускаем Codespaces

1. Откройте страницу вашего репозитория `mysql-practice`.
2. Нажмите зелёную кнопку **Code**.
3. Перейдите на вкладку **Codespaces**.
4. Нажмите **Create codespace on main**.
   - Если GitHub предложит выбрать машину (machine type) — выбирайте **2-core**: для MySQL её достаточно, а бесплатных часов она расходует меньше всего.
5. Откроется редактор VS Code прямо в браузере. Первый запуск занимает 2–4 минуты — для вас собирается окружение. Подождите.

Что в это время происходит:

- создаётся ваша личная облачная машина;
- ставится Docker (фича docker-in-docker из `devcontainer.json`);
- запускается `restore.sh`: он создаёт контейнер MySQL, скачивая официальный образ `mysql:latest` (около 600 МБ — скачивается только один раз);
- скрипт ждёт готовности MySQL и, если в репозитории уже есть дамп, восстанавливает из него базу.

Прогресс скрипта виден внизу экрана: вкладка терминала с задачей и надписью «Running postStartCommand…». Дождитесь сообщения:

```
==================================================
 MySQL готов к работе!
 Подключиться:
   docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p
 Пароль: 123
==================================================
```

> 💡 Если уведомление закрылось и вы не поняли, закончился ли скрипт, — просто выполните в терминале `bash .devcontainer/restore.sh`. Скрипт можно запускать вручную сколько угодно раз — это безопасно.

### 0.6. Проверяем результат

Откройте терминал: если его не видно — меню **☰** (в левом верхнем углу) → **Terminal** → **New Terminal**, или сочетание `` Ctrl+` `` (клавиша слева от единицы, под Esc).

Проверьте, где вы находитесь:

```bash
pwd
```

Должно вывести:

```
/workspaces/mysql-practice
```

Если вы назвали репозиторий иначе — здесь будет его имя; в командах руководства подставляйте своё.

Это папка вашего репозитория, склонированная на облачную машину. Всё, что лежит в ней, можно сохранить в GitHub командой `git push` (сделаем это в [Шаге 8.4](#шаг-84-дамп-базы-сохраняем-работу-в-репозиторий)). Всё, что вне её, при пересоздании Codespaces исчезнет.

Проверьте Docker и контейнер:

```bash
docker ps
```

Вы должны увидеть таблицу примерно такого вида:

```
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS      NAMES
1a2b3c4d5e6f   mysql:latest   "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes   3306/tcp   my-mysql
```

- **IMAGE** — `mysql:latest`: официальный образ MySQL;
- **STATUS** — `Up …`: контейнер работает;
- **NAMES** — `my-mysql`: имя, которое задал скрипт.

Если вместо таблицы пусто или ошибка — загляните в раздел [«Частые ошибки и их решения»](#частые-ошибки-и-их-решения).

Поздравляем: MySQL уже работает в облаке. Дальше разберёмся, что именно скрипт за вас сделал и как работать с базой.

## Часть 1. Запуск контейнера MySQL

Ваш контейнер уже создан скриптом `restore.sh`. В этой части разберём команду, которую он выполнил, — чтобы вы понимали, что произошло, и при желании смогли запустить контейнер вручную (например, после его удаления).

### Разбор команды docker run

Команда выполняется из папки `my-mysql` вашего репозитория — там, где лежит `my.cnf`:

```bash
cd /workspaces/mysql-practice/my-mysql
```

Сама команда:

```bash
docker run --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=123 \
  -e LANG=C.UTF-8 \
  -v mysql_data:/var/lib/mysql \
  -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf:ro \
  --restart unless-stopped \
  -d mysql:latest
```

Разберём её по кусочкам:

| Фрагмент | Что делает |
|----------|------------|
| `--name my-mysql` | Присваивает контейнеру понятное имя `my-mysql`, чтобы не обращаться к нему по ID |
| `-e MYSQL_ROOT_PASSWORD=123` | Устанавливает пароль пользователя root. В учебном примере — `123`, в реальных проектах используйте надёжный пароль |
| `-e LANG=C.UTF-8` | Задаёт локаль внутри контейнера для корректной работы с UTF-8 |
| `-v mysql_data:/var/lib/mysql` | Именованный том: файлы баз данных хранятся **не в контейнере**, а в томе `mysql_data`. Контейнер можно удалить и создать заново — данные останутся |
| `-v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf:ro` | Подключает наш файл `my.cnf` внутрь контейнера (`$(pwd)` — текущая папка). MySQL прочитает его при старте — так включается utf8mb4. `:ro` (read-only) — контейнер не сможет его изменить |
| `--restart unless-stopped` | Автоперезапуск: когда Codespace просыпается и стартует Docker, контейнер MySQL поднимается сам |
| `-d` | Запускает контейнер в фоновом режиме (detached mode) |
| `mysql:latest` | Официальный образ MySQL последней версии с Docker Hub |

> 💡 В Codespaces Docker-демон работает на той же машине, что и ваш терминал, поэтому монтирование `$(pwd)/my.cnf` срабатывает корректно: демон «видит» файлы вашего репозитория.

Убедиться, что контейнер успешно запущен:

```bash
docker ps
```

Вы должны видеть `my-mysql` в списке работающих контейнеров (столбец **STATUS** — `Up …`).

**Хотите выполнить команду руками?** Удалите уже созданный скриптом контейнер и запустите его сами (данные в томе `mysql_data` при этом сохранятся):

```bash
docker rm -f my-mysql
cd /workspaces/mysql-practice/my-mysql
docker run --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=123 \
  -e LANG=C.UTF-8 \
  -v mysql_data:/var/lib/mysql \
  -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf:ro \
  --restart unless-stopped \
  -d mysql:latest
```

### Где «физически» хранятся файлы базы данных

Увидеть физические файлы баз данных внутри контейнера:

```bash
docker exec -it my-mysql ls -la /var/lib/mysql
```

Вы увидите примерно такую картину (точный набор файлов зависит от версии MySQL):

```
#innodb_redo/
#innodb_temp/
auto.cnf
binlog.000001
ibdata1
ibtmp1
mysql/
performance_schema/
sys/
undo_001
undo_002
```

- `mysql`, `performance_schema`, `sys` — системные базы данных;
- `ibdata1`, `#innodb_redo/`, `undo_*` — служебные файлы движка InnoDB;
- **каждая ваша база данных — отдельная папка**, а каждая таблица InnoDB — отдельный файл `имя_таблицы.ibd` внутри неё (увидим это на [Шаге 2](#шаг-2-создание-таблиц-customers-и-orders) практикума).

Физически этот каталог лежит в томе `mysql_data` на диске вашей облачной машины. Практический вывод для Codespaces: пока Codespace существует — данные живут; Codespace удалён — том удаляется вместе с ним. Единственная настоящая резервная копия — `dump.sql` в репозитории.

## Часть 2. Подключение к MySQL в интерактивном режиме

К работающему контейнеру подключаются командой `docker exec` — она выполняет команду внутри контейнера. Откройте интерактивную оболочку **MySQL** (это терминал Codespaces, не `mysql>`):

```bash
docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p
```

- `-it` — флаги `-i` (interactive) и `-t` (tty): вместе создают интерактивный терминал;
- `mysql` — запуск клиента MySQL внутри контейнера;
- `--default-character-set=utf8mb4` — сообщаем серверу, что работаем в utf8mb4 (иначе кириллица может превратиться в `?????`);
- `-uroot` — подключение пользователем root;
- `-p` — запросить пароль при подключении.

Появится:

```
Enter password:
```

Введите пароль `123` и нажмите Enter.

> ⚠️ При вводе пароля на экране **ничего не отображается** — ни точек, ни звёздочек. Это нормальное поведение терминала, пароль действительно вводится. Ввели — жмите Enter.

После успешного подключения вы увидите приветствие MySQL и приглашение:

```
mysql>
```

Теперь вы внутри оболочки MySQL и можете выполнять любые SQL-команды. Мини-словарик, чтобы не путаться:

| Приглашение | Где вы находитесь | Какие команды понимает |
|---|---|---|
| `$` (или `...:~/mysql-practice$`) | Обычный терминал Codespaces | `docker`, `git`, `ls`, `cd` … |
| `mysql>` | Оболочка MySQL | SQL-команды, заканчиваются `;` |

Сразу после подключения проверьте кодировку:

```sql
SHOW VARIABLES LIKE 'character_set%';
```

Если `character_set_client`, `character_set_connection` и `character_set_results` равны `utf8mb4` — всё в порядке, кириллица будет сохраняться и показываться правильно.

Выйти из оболочки MySQL можно тремя способами — `exit`, `quit` или `\q` (последний — без точки с запятой).

## Часть 3. Основные операции с базами данных и таблицами

Внутри оболочки MySQL выполняются все стандартные SQL-команды. Потренируемся на «одноразовой» базе, а полноценный практикум — ниже, в [Практикуме по основам SQL](#практикум-по-основам-sql).

**1. Просмотр существующих баз данных**

```sql
SHOW DATABASES;
```

Команда покажет список всех баз данных, включая системные: `information_schema`, `mysql`, `performance_schema`, `sys` (а позже — ваши `my_database` и `sql_practice`).

**2. Краткая справка по командам СУБД MySQL**

```sql
help
```

**3. Создание базы данных и таблицы**

Создадим базу `my_database` с таблицей `users`. Рекомендуется сразу указывать кодировку. Это инструкции, которые указывают СУБД: «создай базу», «создай таблицу», «вставь строки»:

```sql
CREATE DATABASE my_database
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE my_database;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO users (name, email) VALUES
  ('Иван Иванов', 'ivan@example.com'),
  ('Пётр Петров', 'petr@example.com'),
  ('Мария Сидорова', 'maria@example.com');

SELECT * FROM users;
```

Примерный вывод последней команды:

```
+----+----------------+-------------------+
| id | name           | email             |
+----+----------------+-------------------+
|  1 | Иван Иванов    | ivan@example.com  |
|  2 | Пётр Петров    | petr@example.com  |
|  3 | Мария Сидорова | maria@example.com |
+----+----------------+-------------------+
```

> Если вместо русских имён вы видите `??????` — см. раздел [«Частые ошибки»](#частые-ошибки-и-их-решения), пункт про кириллицу.

**4. Выбор базы данных для работы**

```sql
USE my_database;
```

Теперь все последующие команды применяются к этой базе. Посмотреть таблицы в ней:

```sql
SHOW TABLES;
```

**5. Вставка данных**

Сначала посмотрим текущие данные таблицы:

```sql
SELECT * FROM users;
```

затем добавим новые строки:

```sql
INSERT INTO users (name, email) VALUES ('Павел Иванов', 'pavel@example.com');
INSERT INTO users (name, email) VALUES ('Марк Аврелий', 'mark@example.com');
```

Проверка кодировки после вставки (опционально) — покажет, как имена хранятся «изнутри» (каждая кириллическая буква в utf8mb4 занимает два байта):

```sql
SELECT name, HEX(name) FROM users WHERE id = 1;
```

**6. Просмотр данных**

```sql
SELECT * FROM users;
```

**7. Обновление данных**

```sql
UPDATE users SET name = 'Иван Петров' WHERE id = 1;
```

просто меняем **id** в указанной записи

или

```sql
UPDATE users SET name = 'Vasya' WHERE id = 1;
```

Посмотреть все строки таблицы:

```sql
SELECT * FROM users;
```

Посмотреть одну конкретную запись (строку):

```sql
SELECT * FROM users WHERE id = 1;
```

Получить указанные поля (столбцы):

```sql
SELECT name, email FROM users;
```

или получить одно поле:

```sql
SELECT name FROM users;
```

Посмотреть нужные поля одной записи:

```sql
SELECT name, email FROM users WHERE id = 1;
```

Удобный вертикальный вывод:

```sql
SELECT * FROM users WHERE id = 1\G
```

`\G` заменяет точку с запятой и не требует `;` в конце.

**8. Удаление данных**

Сначала получим содержимое таблицы для последующего сравнения:

```sql
SELECT * FROM users;
```

затем удалим указанную запись:

```sql
DELETE FROM users WHERE id = 2;
```

> ⚠️ Если убрать `WHERE`, удалятся **все** строки таблицы.

**9. Удаление таблицы**

```sql
DROP TABLE users;
```

Получить существующие таблицы:

```sql
SHOW TABLES;
```

**10. Удаление базы данных**

```sql
DROP DATABASE my_database;
```

Просмотр существующих баз данных:

```sql
SHOW DATABASES;
```

Выйти из оболочки:

```sql
exit
```

или

```sql
quit
```

ещё вариант:

```sql
\q
```

## Часть 4. Управление контейнером и Codespaces

### Управление контейнером

Все команды — в обычном терминале Codespaces:

- **Остановка контейнера:**

  ```bash
  docker stop my-mysql
  ```

- **Запуск ранее остановленного контейнера** (данные на месте — они в томе `mysql_data`):

  ```bash
  docker start my-mysql
  ```

- **Просмотр логов** (пригодится для отладки):

  ```bash
  docker logs my-mysql
  ```

Если нужно пересоздать контейнер с сохранением данных:

```bash
docker rm -f my-mysql
cd /workspaces/mysql-practice/my-mysql
docker run --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=123 \
  -e LANG=C.UTF-8 \
  -v mysql_data:/var/lib/mysql \
  -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf:ro \
  --restart unless-stopped \
  -d mysql:latest
```

### Управление Codespaces и бесплатный лимит

Codespace — это целая машина, и её тоже можно останавливать и запускать:

- **страница управления**: [github.com/codespaces](https://github.com/codespaces) — список всех ваших Codespaces, кнопки **Stop** (остановить) и **Delete** (удалить навсегда, вместе с базами!), счётчик использованных часов;
- **остановить из редактора**: `Ctrl+Shift+P` → начните вводить `Codespaces: Stop` → выберите команду остановки текущего Codespaces;
- **простой 30 минут** — Codespace останавливается автоматически (это нормально и экономит лимит).

Лимиты бесплатного тарифа (GitHub Free, личный аккаунт; актуальные цифры проверяйте в **Settings → Billing and plans → Plans and usage**):

- **120 core-часов** вычислений в месяц — на машине 2-core это 60 часов работы;
- **15 ГБ** хранилища в месяц.

Практические следствия:

- закончили заниматься → останавливайте Codespace (или просто закройте вкладку — через 30 минут простоя он остановится сам);
- Codespace, которым вы не пользовались 30 дней, будет удалён автоматически — вместе с данными MySQL;
- единственная копия вашей работы — `dump.sql` в репозитории.

### Как правильно заканчивать занятие

Три шага — и работа в безопасности (подробно это разобрано в [Шаге 8.4](#шаг-84-дамп-базы-сохраняем-работу-в-репозиторий)):

```bash
cd /workspaces/mysql-practice/my-mysql
docker exec my-mysql mysqldump -uroot -p123 sql_practice > dump.sql
git add dump.sql && git commit -m "Дамп sql_practice" && git push
```

После этого Codespace можно останавливать или даже удалять — база восстановится из дампа в любом новом Codespaces.

## Практикум по основам SQL

Теперь — полноценная практика на учебной базе `sql_practice` с двумя связанными таблицами: `customers` (клиенты) и `orders` (заказы). Нумерация шагов сохранена такой же, как в исходном конспекте курса.

Если контейнер ещё не запущен (например, вы вернулись после перерыва), запустите его и подключитесь:

```bash
docker start my-mysql
docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p
```

Введите пароль `123`. Вы увидите приглашение `mysql>`.

> 💡 Если вы уже проходили практикум раньше и восстанавливали базу из дампа, база `sql_practice` уже существует — команда `CREATE DATABASE` ниже выдаст ошибку «database exists». В этом случае просто выполняйте `USE sql_practice;` и работайте, либо сначала удалите базу командой из [Шага 12](#шаг-12-удаление-таблиц-и-базы) и начните с чистого листа.

### Шаг 1. Создание учебной базы данных sql_practice

```sql
CREATE DATABASE sql_practice
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sql_practice;
```

Проверить, что база создана:

```sql
SHOW DATABASES;
```

### Шаг 2. Создание таблиц customers и orders

Создадим две связанные таблицы. В `orders` поле `customer_id` — внешний ключ (FOREIGN KEY) на `customers.id`: так СУБД не даст вставить заказ «несуществующему» клиенту.

```sql
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'new',
    FOREIGN KEY (customer_id) REFERENCES customers(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Получить существующие таблицы:

```sql
SHOW TABLES;
```

Проверить структуру таблиц:

```sql
DESCRIBE customers;
DESCRIBE orders;
```

Команда `CREATE TABLE customers` создаёт файл `customers.ibd` и т.п. В этом легко убедиться. Выйдите из MySQL:

```sql
exit
```

и выполните в обычном терминале Codespaces:

```bash
docker exec -it my-mysql ls -la /var/lib/mysql/sql_practice
```

Вы увидите файлы таблиц InnoDB:

```
customers.ibd
orders.ibd
```

Каждая таблица InnoDB — отдельный файл внутри папки базы данных.

### Шаг 3. Вставка данных (INSERT)

Вернёмся в оболочку MySQL:

```bash
docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p
```

Использовать указанную БД и посмотреть, что в таблицах сейчас:

```sql
USE sql_practice;
```

```sql
SHOW TABLES;
```

```sql
SELECT * FROM customers;
SELECT * FROM orders;
```

Обе таблицы пустые (`Empty set`). Вставим данные:

```sql
INSERT INTO customers (name, email, city) VALUES
  ('Иван Иванов', 'ivan@example.com', 'Москва'),
  ('Пётр Петров', 'petr@example.com', 'Санкт-Петербург'),
  ('Мария Сидорова', 'maria@example.com', 'Москва'),
  ('Алексей Смирнов', 'alex@example.com', 'Казань'),
  ('Ольга Кузнецова', 'olga@example.com', 'Новосибирск');

INSERT INTO orders (customer_id, order_date, amount, status) VALUES
  (1, '2026-10-01', 1500.00, 'paid'),
  (1, '2026-10-05', 2300.50, 'paid'),
  (2, '2026-10-03', 800.00, 'new'),
  (3, '2026-10-07', 4200.00, 'paid'),
  (3, '2026-10-10', 1100.00, 'cancelled'),
  (4, '2026-10-12', 950.00, 'new');
```

Словарик: `customers` — клиенты, `orders` — заказы, `amount` — сумма, `status` — статус, `paid` — оплачено, `new` — новый, `cancelled` — отменён.

Проверить, что данные вставились:

```sql
SELECT * FROM customers;
SELECT * FROM orders;
```

### Шаг 4. Выборка данных (SELECT)

#### 4.1. Все столбцы и все строки

```sql
SELECT * FROM customers;
```

#### 4.2. Только нужные столбцы

```sql
SELECT name, city FROM customers;
```

#### 4.3. Условие WHERE (ГДЕ)

```sql
SELECT * FROM customers WHERE city = 'Москва';
SELECT * FROM orders WHERE amount > 1000;
SELECT * FROM orders WHERE status = 'paid' AND amount > 1500;
SELECT * FROM orders WHERE status = 'new' OR status = 'cancelled';
```

#### 4.4. Сортировка ORDER BY

```sql
SELECT * FROM customers ORDER BY name;
SELECT * FROM orders ORDER BY amount DESC;
SELECT * FROM orders ORDER BY order_date DESC, amount ASC;
```

Сортировка заказов по сумме: `DESC` — от большей к меньшей, `ASC` — от меньшей к большей.

#### 4.5. Ограничение количества строк LIMIT

```sql
SELECT * FROM orders ORDER BY amount DESC LIMIT 3;
```

Три самых крупных заказа.

#### 4.6. Поиск по шаблону LIKE

```sql
SELECT * FROM customers WHERE name LIKE 'И%';      -- начинается на И
SELECT * FROM customers WHERE email LIKE '%@example.com';
```

#### 4.7. Диапазон BETWEEN, список IN

```sql
SELECT * FROM orders WHERE amount BETWEEN 1000 AND 3000;
SELECT * FROM customers WHERE city IN ('Москва', 'Казань');
```

Оператор **IN** — это логический оператор, который проверяет, входит ли значение в заданный список. Он является сокращённой формой цепочки OR (ИЛИ, дизъюнкция).

Это то же самое, что:

```sql
SELECT * FROM customers WHERE city = 'Москва' OR city = 'Казань';
```

Результат одинаковый — оба запроса вернут клиентов из Москвы и Казани. Но **IN** короче, читабельнее и удобнее, особенно если значений много.

#### 4.8. Пустые значения IS NULL

```sql
SELECT * FROM customers WHERE city IS NULL;
```

В наших данных все города заполнены, поэтому вернётся `Empty set` — это тоже результат.

### Шаг 5. Агрегатные функции

Всего заказов:

```sql
SELECT COUNT(*) AS total_orders FROM orders;
```

Общая сумма:

```sql
SELECT SUM(amount) AS total_sum FROM orders;
```

Среднее:

```sql
SELECT AVG(amount) AS avg_amount FROM orders;
```

Минимальная и максимальная сумма:

```sql
SELECT MIN(amount) AS min_amount, MAX(amount) AS max_amount FROM orders;
```

### Шаг 6. Группировка GROUP BY и HAVING

#### 6.1. Количество заказов по каждому клиенту

```sql
SELECT customer_id, COUNT(*) AS order_count, SUM(amount) AS total_amount
FROM orders
GROUP BY customer_id;
```

#### 6.2. Соединение с именами клиентов

```sql
SELECT c.name, COUNT(o.id) AS order_count, SUM(o.amount) AS total_amount
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY total_amount DESC;
```

Алиасы `c` и `o` — см. раздел 7.1 ниже.

#### 6.3. Фильтрация групп HAVING

`WHERE` фильтрует строки **до** группировки, `HAVING` — группы **после** неё:

```sql
SELECT customer_id, SUM(amount) AS total_amount
FROM orders
GROUP BY customer_id
HAVING SUM(amount) > 2000;
```

### Шаг 7. Соединения JOIN

#### 7.1. INNER JOIN — только совпадающие строки

```sql
SELECT c.name, o.order_date, o.amount, o.status
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id;
```

**INNER JOIN** и просто **JOIN** — это одно и то же. Слово **INNER** можно опускать.

Чтобы узнать имя клиента по его **id**, нужно соединить таблицы через **JOIN**.

**JOIN** — это оператор, который соединяет строки из двух или более таблиц на основе общего столбца (обычно это первичный ключ одной таблицы и внешний ключ другой). Без JOIN работать с реляционными базами данных практически невозможно: данные намеренно разнесены по таблицам, чтобы избежать дублирования.

**Алиасы в SQL**

```sql
FROM customers c
JOIN orders o ON c.id = o.customer_id;
```

Здесь:

- `customers c` — таблица **customers** получает псевдоним `c`
- `orders o` — таблица **orders** получает псевдоним `o`

Зачем нужны?

1. **Краткость.** Вместо `customers.name` пишете `c.name`. В коротком запросе это мелочь, но в запросе с 5 таблицами — существенная экономия.
2. **Разрешение неоднозначности.** В обеих таблицах есть столбец `id`. Без алиаса запрос:

   ```sql
   SELECT id FROM customers JOIN orders ON ...;
   ```

   вернёт ошибку:

   ```sql
   ERROR 1052 (23000): Column 'id' in field list is ambiguous
   ```

   т.к. MySQL не знает, какой `id` имеется в виду — из `customers` или из `orders`. С алиасом всё однозначно:

   ```sql
   SELECT c.id, o.id FROM customers c JOIN orders o ON c.id = o.customer_id;
   ```

#### 7.2. LEFT JOIN — все клиенты, даже без заказов

```sql
SELECT c.name, o.id AS order_id, o.amount
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id;
```

**LEFT JOIN** (левое внешнее соединение) — возвращает все строки из левой таблицы, даже если нет совпадений в правой. Для несовпавших строк правая таблица даёт **NULL**.

Клиенты без заказов (в наших данных это Ольга Кузнецова, `id = 5`) будут иметь `NULL` в полях заказа.

#### 7.3. RIGHT JOIN — все заказы, даже если клиент удалён (редко используется)

```sql
SELECT c.name, o.id AS order_id
FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id;
```

**RIGHT JOIN** (правое внешнее соединение) — возвращает все строки из правой таблицы, даже если нет совпадений в левой.

Результат: все строки из правой таблицы (`orders`) + совпадения из левой (`customers`). Если у заказа нет клиента — в поле `c.name` будет `NULL`.

На практике RIGHT JOIN используется редко. Почти всегда его можно переписать как LEFT JOIN, поменяв таблицы местами:

```sql
-- Эквивалент RIGHT JOIN
SELECT c.name, o.id AS order_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.id;
```

#### 7.4. JOIN и GROUP BY — соединение с агрегацией

Соединим таблицы и посчитаем агрегаты:

```sql
SELECT c.name,
       COUNT(o.id) AS order_count,
       SUM(o.amount) AS total_amount
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY total_amount DESC;
```

Чтобы вместо NULL был 0, используйте `COALESCE` (возвращает первое значение из списка, которое не NULL):

```sql
SELECT c.name,
       COUNT(o.id) AS order_count,
       COALESCE(SUM(o.amount), 0) AS total_amount
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY total_amount DESC;
```

### Шаг 8. Подзапросы и UNION

#### 8.1. Подзапросы (Subqueries)

Подзапрос — это `SELECT`-запрос, вложенный внутрь другого SQL-запроса. Подзапрос выполняется первым, а его результат используется внешним запросом.

#### Подзапрос в WHERE (с IN)

```sql
SELECT name, city
FROM customers
WHERE id IN (
    SELECT customer_id
    FROM orders
    WHERE amount > 1000
);
```

Вернёт клиентов, у которых есть хотя бы один заказ на сумму больше 1000.

#### Подзапрос в WHERE (со сравнением)

```sql
SELECT name, city
FROM customers
WHERE id = (
    SELECT customer_id
    FROM orders
    ORDER BY amount DESC
    LIMIT 1
);
```

Вернёт клиента с самым крупным заказом.

#### Подзапрос в FROM (производная таблица)

```sql
SELECT c.name, o.total
FROM customers c
JOIN (
    SELECT customer_id, SUM(amount) AS total
    FROM orders
    GROUP BY customer_id
) o ON c.id = o.customer_id
WHERE o.total > 2000;
```

Подзапрос в `FROM` формирует временную таблицу с агрегатами, которую затем соединяем с `customers`.

#### Подзапрос в SELECT (скалярный)

```sql
SELECT c.name,
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.id) AS order_count
FROM customers c;
```

Для каждого клиента считается количество его заказов.

#### EXISTS и NOT EXISTS

```sql
-- Клиенты, у которых есть хотя бы один заказ
SELECT name FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.id
);

-- Клиенты без заказов
SELECT name FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.id
);
```

`EXISTS` часто работает быстрее, чем `IN`, особенно если внешняя таблица большая, а внутренняя — маленькая.

#### 8.2. UNION и UNION ALL

`UNION` объединяет результаты двух `SELECT`-запросов в один набор строк.

#### UNION (удаляет дубликаты)

```sql
SELECT name, city FROM customers WHERE city = 'Москва'
UNION
SELECT name, city FROM customers WHERE city = 'Казань';
```

Вернёт клиентов из Москвы и Казани, при этом дубликаты строк удаляются.

#### UNION ALL (сохраняет дубликаты, работает быстрее)

```sql
SELECT city FROM customers
UNION ALL
SELECT city FROM customers;
```

Вернёт все города, включая повторы.

#### Требования к UNION

- Одинаковое количество столбцов в обоих запросах.
- Совместимые типы данных.
- Имена столбцов берутся из первого запроса.

#### 8.3. Сравнение JOIN и подзапросов

| Критерий | JOIN | Подзапрос |
|----------|------|-----------|
| Читабельность | Лучше для соединения данных | Лучше для фильтрации |
| Производительность | Обычно быстрее | Может быть медленнее |
| Когда использовать | Нужны данные из обеих таблиц | Нужна только фильтрация |
| **EXISTS** | — | Часто быстрее, чем **IN** |

### Шаг 8.4. Дамп базы: сохраняем работу в репозиторий

Это самый важный шаг для Codespaces: именно дамп переживает удаление облачной машины. Весь дальнейший путь: дамп → `git push` → в любом новом Codespaces база восстановится автоматически.

Сначала выйдем из MySQL:

```sql
\q
```

Перейдём в папку `my-mysql` (там, где `my.cnf`) — дамп положим именно туда, его ищет `restore.sh`:

```bash
cd /workspaces/mysql-practice/my-mysql
```

Делаем дамп (экспорт в `.sql`-файл):

```bash
docker exec my-mysql mysqldump -uroot -p123 sql_practice > dump.sql
```

или — вариант без «Insecure password»-предупреждения (пароль передаётся через переменную окружения):

```bash
docker exec -e MYSQL_PWD=123 my-mysql mysqldump -uroot sql_practice > dump.sql
```

> Строка `mysqldump: [Warning] Using a password on the command line interface can be insecure.` — это предупреждение, а не ошибка. Для учебного окружения это нормально.

В папке `my-mysql` появится текстовый файл `dump.sql`. Убедимся, что он не пустой, и заглянем внутрь:

```bash
ls -lh dump.sql
head -n 30 dump.sql
```

`.sql`-файл — это текстовое представление вашей БД (SQL-скрипт с командами CREATE TABLE и INSERT). Его можно хранить как резервную копию, из которой потом база восстанавливается.

Теперь **сохраняем дамп в репозиторий** — в Codespaces git уже настроен и авторизован, пароли не нужны:

```bash
git add dump.sql
git commit -m "Дамп sql_practice"
git push
```

- `git add dump.sql` — добавить файл в будущий коммит (если вы в папке `my-mysql`; из корня репозитория — `git add my-mysql/dump.sql`);
- `git commit -m "..."` — зафиксировать изменение с сообщением;
- `git push` — отправить на GitHub.

> 💡 Если git попросит «Please tell me who you are», один раз представьтесь:
>
> ```bash
> git config --global user.name "Ваше Имя"
> git config --global user.email "ваш@email.com"
> ```
>
> и повторите commit + push.

Проверьте себя: откройте репозиторий на GitHub — в папке `my-mysql` должен лежать `dump.sql`. Теперь ваша база в безопасности: даже если Codespace удалится, на [Шаге 13](#шаг-13-восстановление-базы-данных-из-дампа) вы поднимете её из этого файла за минуту.

### Шаг 9. Обновление данных (UPDATE)

```sql
UPDATE customers SET city = 'Екатеринбург' WHERE id = 4;
UPDATE orders SET status = 'paid' WHERE id = 3;
```

Проверить:

```sql
SELECT * FROM customers WHERE id = 4;
SELECT * FROM orders WHERE id = 3;
```

> ⚠️ **Важно:** всегда указывайте `WHERE`, иначе обновятся **все** строки таблицы!

### Шаг 10. Удаление данных (DELETE)

Снова зайти в контейнер с БД (если вы выходили):

```bash
docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p
```

выбрать БД и посмотреть содержимое таблиц:

```sql
USE sql_practice;
```

```sql
SHOW TABLES;
```

```sql
SELECT * FROM customers;
SELECT * FROM orders;
```

Удалить указанную запись из таблицы:

```sql
DELETE FROM orders WHERE id = 6;
```

> ⚠️ Без `WHERE` удалятся все строки: `DELETE FROM orders;`

Проверить:

```sql
SELECT * FROM orders;
```

### Шаг 11. Изменение структуры (ALTER TABLE)

Добавить столбец:

```sql
ALTER TABLE customers ADD COLUMN phone VARCHAR(20);
```

проверить:

```sql
SELECT * FROM customers;
```

Обновить данные в новом столбце:

```sql
UPDATE customers SET phone = '123-36-77' WHERE id = 4;
```

Проверить:

```sql
SELECT * FROM customers WHERE id = 4;
```

или все записи:

```sql
SELECT * FROM customers;
```

Изменить тип столбца:

```sql
ALTER TABLE customers MODIFY COLUMN phone VARCHAR(30);
```

Удалить столбец:

```sql
ALTER TABLE customers DROP COLUMN phone;
```

проверить:

```sql
SELECT * FROM customers;
```

### Шаг 12. Удаление таблиц и базы

```sql
DROP TABLE orders;
SHOW TABLES;
DROP TABLE customers;
SHOW TABLES;
DROP DATABASE sql_practice;
```

Проверить:

```sql
SHOW DATABASES;
```

выйти из MySQL:

```sql
\q
```

### Шаг 13. Восстановление базы данных из дампа

В Codespaces восстановление нужно в двух ситуациях: вы просто вернулись после перерыва (данные, скорее всего, на месте) — или у вас новый Codespace (данные придётся восстановить из дампа). Разберём оба.

**Сценарий А. Тот же Codespace (вы вернулись после паузы)**

Проверьте, что контейнер запущен:

```bash
docker ps -a
```

если не запущен — запустите:

```bash
docker start my-mysql
```

Данные живут в томе `mysql_data` и никуда не делись: подключайтесь и работайте.

```bash
docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p
```

```sql
SHOW DATABASES;
USE sql_practice;
SELECT * FROM customers;
```

**Сценарий Б. Новый Codespace (старый удалён или пересобран)**

Если вы прошли [Шаг 8.4](#шаг-84-дамп-базы-сохраняем-работу-в-репозиторий) и `dump.sql` лежит в репозитории — при запуске нового Codespaces скрипт `restore.sh` восстановит базу **автоматически**: вы увидите в его выводе строку `==> [4/4] Восстанавливаем базу sql_practice из my-mysql/dump.sql...`.

Проверить результат:

```bash
docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p
```

```sql
SHOW DATABASES;
USE sql_practice;
SHOW TABLES;
SELECT * FROM customers;
SELECT * FROM orders;
```

**Ручное восстановление (как в классическом руководстве)**

Если хочется сделать всё руками — вот полная процедура. Проверьте, что дамп на месте и не пуст:

```bash
cd /workspaces/mysql-practice/my-mysql
ls -lh dump.sql
head -n 30 dump.sql
```

> Если размер 0 байт — дамп пустой, восстанавливать нечего. Убедитесь, что вы в папке `my-mysql`, где запускали mysqldump, либо укажите полный путь.

Зайти в контейнер и создать пустую базу:

```bash
docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p
```

```sql
CREATE DATABASE sql_practice
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

проверить:

```sql
SHOW DATABASES;
```

Выйти из MySQL:

```sql
\q
```

Команда импорта выполняется не внутри mysql, а в обычном терминале Codespaces:

```bash
docker exec -i my-mysql mysql -uroot -p123 sql_practice < dump.sql
```

или (с игнорированием ошибок импорта):

```bash
docker exec -i my-mysql mysql -uroot -p123 --force sql_practice < dump.sql
```

Затем зайти в контейнер и проверить содержимое восстановленной БД:

```bash
docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p
```

```sql
SHOW DATABASES;
USE sql_practice;
SHOW TABLES;
SELECT * FROM customers;
SELECT * FROM orders;
```

## Жизненный цикл Codespaces: что сохраняется, а что нет

| Что случилось | Контейнер MySQL и данные | Что делать |
|---|---|---|
| Codespace простоял 30 минут (автостоп) или вы нажали Stop | Сохраняются (том `mysql_data` на диске Codespace) | Открыть Codespace снова; контейнер поднимется сам (`restore.sh` / `--restart unless-stopped`); проверьте `docker ps` |
| Вы останавливали сам контейнер (`docker stop`) | Сохраняются | `docker start my-mysql` |
| **Rebuild Container** (пересборка окружения) | Docker-данные стираются; файлы репозитория в `/workspaces` сохраняются | `restore.sh` создаст контейнер заново и восстановит базу из `dump.sql` |
| Codespace **удалён** (вручную или после 30 дней бездействия) | Всё стирается, включая том `mysql_data` | Создать новый Codespace — база восстановится из `dump.sql` в репозитории (Шаг 13, сценарий Б) |

Главный вывод: **репозиторий — единственное постоянное место**. Дамп + `git push` после каждого занятия — и никакая уборка Codespaces вам не страшна.

## Частые ошибки и их решения

**1. `Cannot connect to the Docker daemon`**

Docker-демон ещё не поднялся (первые секунды после старта Codespaces) либо `restore.sh` ещё работает. Подождите 15–20 секунд и повторите `docker version`. Не помогло — `Ctrl+Shift+P` → **Codespaces: Rebuild Container**.

**2. `The container name "/my-mysql" is already in use`**

Контейнер уже существует (например, его создал `restore.sh`, а вы запускаете `docker run` вручную). Посмотрите все контейнеры: `docker ps -a`. Если он остановлен — `docker start my-mysql`; если хотите создать заново — `docker rm -f my-mysql` и повторите `docker run`.

**3. `ERROR 1045 (28000): Access denied for user 'root'@'localhost'`**

Неверный пароль. Пароль — `123`; при вводе он не отображается. Проверьте раскладку клавиатуры и Caps Lock.

**4. Подключение «зависает» или `Can't connect to local MySQL server` сразу после первого запуска**

MySQL ещё инициализируется — при первом старте это занимает 20–30 секунд. Посмотрите логи и дождитесь строки `ready for connections`:

```bash
docker logs -f my-mysql
```

после чего `Ctrl+C` (выход из просмотра логов) и подключайтесь снова.

**5. `?????` вместо кириллицы**

Подключайтесь с флагом `--default-character-set=utf8mb4` и убедитесь, что `my.cnf` примонтирован в контейнер:

```bash
docker exec my-mysql cat /etc/mysql/conf.d/my.cnf
```

Если файл пуст — контейнер создавался не из папки `my-mysql`. Пересоздайте его командой из [Части 1](#часть-1-запуск-контейнера-mysql) (обязательно из `/workspaces/mysql-practice/my-mysql`).

**6. После возвращения база пропала**

Значит, Codespace был удалён (вручную или после 30 дней бездействия) либо вы делали Rebuild. Если в репозитории есть `my-mysql/dump.sql` — база восстановится автоматически при старте нового Codespaces (см. [Шаг 13](#шаг-13-восстановление-базы-данных-из-дампа)). Если дампа нет — данные, увы, не восстановить. Отсюда правило: дамп + `git push` в конце каждого занятия.

**7. Уведомление `postStartCommand failed` при запуске Codespaces**

Не найден или не исполняется `.devcontainer/restore.sh`. Проверьте точное имя и путь файла, запустите его руками: `bash .devcontainer/restore.sh` — сообщение об ошибке подскажет причину. После исправления: `Ctrl+Shift+P` → **Codespaces: Rebuild Container**.

**8. `git commit`/`git push` не работают**

- git просит «Please tell me who you are» — один раз выполните `git config --global user.name "Имя"` и `git config --global user.email "почта"`, затем повторите commit + push;
- push просит логин и пароль — вы, скорее всего, работаете не в Codespaces (например, в терминале своего компьютера). В Codespaces git уже авторизован.

**9. «Закончилась квота» / Codespace остановлен по лимиту**

Бесплатный тариф: 120 core-часов и 15 ГБ хранилища в месяц. Проверьте расход: **Settings → Billing and plans → Plans and usage**. Освободите ресурсы: остановите ненужные Codespaces на [github.com/codespaces](https://github.com/codespaces), удалите те, что не нужны (дамп уже в репозитории!), а внутри Codespaces почистите неиспользуемые образы:

```bash
docker system prune -a
```

(данные в томе `mysql_data` эта команда не трогает).

## Полезные команды

Внутри оболочки MySQL (приглашение `mysql>`):

| Команда | Что делает |
|---------|------------|
| `SHOW DATABASES;` | Список баз данных |
| `USE имя_базы;` | Переключиться на базу |
| `SHOW TABLES;` | Список таблиц в текущей базе |
| `DESCRIBE имя_таблицы;` | Структура таблицы |
| `SHOW CREATE TABLE имя_таблицы;` | SQL для создания таблицы |
| `EXIT;` или `\q` | Выйти из MySQL |
| `\G` вместо `;` | Вертикальный вывод строки |

В терминале Codespaces:

| Команда | Что делает |
|---------|------------|
| `docker ps` / `docker ps -a` | Работающие / все контейнеры |
| `docker start my-mysql` / `docker stop my-mysql` | Запустить / остановить контейнер |
| `docker logs my-mysql` | Логи контейнера |
| `docker rm -f my-mysql` | Удалить контейнер (данные в томе остаются) |
| `docker exec -it my-mysql mysql --default-character-set=utf8mb4 -uroot -p` | Открыть оболочку MySQL |
| `docker exec my-mysql mysqldump -uroot -p123 sql_practice > dump.sql` | Сделать дамп базы |
| `docker exec -i my-mysql mysql -uroot -p123 sql_practice < dump.sql` | Восстановить базу из дампа |
| `bash .devcontainer/restore.sh` | Вручную запустить автозапуск/восстановление |
| `git add …` → `git commit -m "…"` → `git push` | Сохранить изменения в репозиторий |

## Что дальше?

Когда освоите эти основы, можно переходить к:

- **представлениям** (`CREATE VIEW`);
- **индексам** (`CREATE INDEX`);
- **транзакциям** (`START TRANSACTION`, `COMMIT`, `ROLLBACK`);
- **хранимым процедурам и триггерам**;
- **оконным функциям** (`ROW_NUMBER()`, `RANK()`, `OVER`).

Идеи для развития вашей «облачной учебной площадки»:

- попробуйте переписать какой-нибудь запрос с `IN` на `EXISTS` и сравнить планы выполнения командой `EXPLAIN`;
- подключите графический клиент (DBeaver, DataGrip): для этого контейнер нужно запустить с пробросом порта `-p 3306:3306`, а порт пробросить наружу через панель **Ports** в редакторе;
- ведите в этом же репозитории собственную шпаргалку по SQL — коммит за коммитом она превратится в отличный конспект.

Полезные ссылки:

- документация MySQL — [dev.mysql.com/doc](https://dev.mysql.com/doc/);
- документация GitHub Codespaces — [docs.github.com/codespaces](https://docs.github.com/en/codespaces).

---

> Если вы обнаружили ошибку в этом тексте — сообщите, пожалуйста, автору!
