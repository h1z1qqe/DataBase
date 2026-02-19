# Полное руководство по Docker и команды

## 📜 Немного истории

Свой путь Docker начал в 2013 году — тогда компания dotCloud выпустила его как решение для упрощения деплоя приложений. Спустя год появилась версия 1.0, после чего Docker превратился в открытый стандарт контейнеризации. На сегодняшний день это де-факто промышленный стандарт для упаковки и доставки программного обеспечения.

---

## 🛠 Команды Docker: полный список

### Работа с контейнерами
# Запуск контейнера
docker run [ОПЦИИ] ОБРАЗ [КОМАНДА]
docker run -d -p 8080:80 --name my-nginx nginx
docker run -it ubuntu:20.04 /bin/bash

# Просмотр контейнеров
docker ps          # только активные
docker ps -a       # абсолютно все
docker ps -q       # вывести лишь ID

# Управление состоянием
docker stop КОНТЕЙНЕР      # мягкая остановка
docker start КОНТЕЙНЕР     # запуск остановленного
docker restart КОНТЕЙНЕР   # перезапуск
docker pause КОНТЕЙНЕР     # заморозить контейнер
docker unpause КОНТЕЙНЕР   # снять с паузы

# Удаление
docker rm КОНТЕЙНЕР        # обычное удаление
docker rm -f КОНТЕЙНЕР     # удалить даже работающий
docker container prune     # почистить все остановленные

---

### Работа с образами
# Поиск и загрузка
docker search ТЕРМИН        # искать на Docker Hub
docker pull ОБРАЗ:ТЕГ      # скачать образ
docker pull nginx:alpine

# Просмотр и очистка
docker images               # список всех образов
docker image ls             # то же самое, другой синтаксис
docker rmi ОБРАЗ           # удалить образ
docker image prune         # убрать неиспользуемые

# Сборка
docker build -t ИМЯ:ТЕГ .
docker build -f Dockerfile.dev .  # с указанием конкретного файла

---

### Отладка и мониторинг
# Логи
docker logs КОНТЕЙНЕР               # получить логи
docker logs -f КОНТЕЙНЕР            # следить в реальном времени
docker logs --tail 50 КОНТЕЙНЕР     # только последние 50 строк

# Выполнение команд внутри контейнера
docker exec [ОПЦИИ] КОНТЕЙНЕР КОМАНДА
docker exec -it КОНТЕЙНЕР /bin/bash    # войти в оболочку
docker exec КОНТЕЙНЕР ls -la           # разовая команда

# Инспекция и мониторинг
docker inspect КОНТЕЙНЕР    # полные сведения об объекте
docker stats               # потребление ресурсов в реальном времени
docker top КОНТЕЙНЕР       # активные процессы контейнера

---

## 📄 Пример Dockerfile для Python-приложения
# Базовый образ
FROM python:3.9-slim

# Метаданные проекта
LABEL maintainer="your.email@example.com"
LABEL version="1.0"
LABEL description="Моё Python-приложение"

# Устанавливаем рабочую директорию
WORKDIR /app

# Системные зависимости
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Сначала копируем зависимости — используем кэш слоёв
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем исходный код
COPY . .

# Переменные окружения
ENV PYTHONUNBUFFERED=1
ENV APP_PORT=8000

# Объявляем порт приложения
EXPOSE 8000

# Проверка работоспособности
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Запускаем от непривилегированного пользователя
USER 1001

# Точка входа
CMD ["python", "app.py"]