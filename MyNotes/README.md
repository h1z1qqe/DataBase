# 🐳 Полное руководство по Docker и его командам

## 📜 Немного истории

Docker появился в 2013 году благодаря компании dotCloud как инструмент для упрощения деплоя приложений.  
Уже в 2014 году вышла версия Docker 1.0, после чего контейнеризация стала массовым явлением.

Сегодня Docker — это:
- де-факто стандарт контейнеризации,
- фундамент DevOps-подхода,
- основа для Kubernetes и облачных платформ.

---

## 🧠 Основные понятия

- Образ (image) — шаблон приложения (как ISO-файл).
- Контейнер (container) — запущенный экземпляр образа.
- Dockerfile — инструкция по сборке образа.
- Volume — механизм хранения данных вне контейнера.
- Network — виртуальная сеть для контейнеров.

---

## 🛠 Команды Docker: полный список

### ▶️ Работа с контейнерами

#### Запуск
docker run [ОПЦИИ] ОБРАЗ [КОМАНДА]
docker run -d -p 8080:80 --name my-nginx nginx
docker run -it ubuntu:20.04 /bin/bash

#### Просмотр
docker ps
docker ps -a
docker ps -q

#### Управление
docker stop КОНТЕЙНЕР
docker start КОНТЕЙНЕР
docker restart КОНТЕЙНЕР
docker pause КОНТЕЙНЕР
docker unpause КОНТЕЙНЕР

#### Удаление
docker rm КОНТЕЙНЕР
docker rm -f КОНТЕЙНЕР
docker container prune

---

### 🖼 Работа с образами
docker search ТЕРМИН
docker pull ОБРАЗ:ТЕГ
docker images
docker rmi ОБРАЗ
docker build -t ИМЯ:ТЕГ .

---

### 🐞 Отладка
docker logs КОНТЕЙНЕР
docker exec -it КОНТЕЙНЕР /bin/bash
docker inspect КОНТЕЙНЕР
docker stats

---

## 💾 Volumes
docker volume create mydata
docker volume ls
docker volume rm mydata

---

## 🌐 Networks
docker network create mynet
docker network ls
docker network rm mynet

---

## 🧩 Docker Compose
version: "3.9"
services:
  web:
    image: nginx
    ports:
      - "8080:80"
docker compose up
docker compose down

---

## 📄 Пример Dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]

---

## 🚫 .dockerignore
__pycache__/
.env
.git
node_modules

---

## 🏆 Лучшие практики

- Используй slim образы
- Не запускай от root
- Один контейнер = один сервис
- Минимизируй слои

---

## 🧠 Итог

Docker ускоряет разработку, устраняет проблему "работает у меня", и делает деплой стабильным.