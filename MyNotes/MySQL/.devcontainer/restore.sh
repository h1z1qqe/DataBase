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
