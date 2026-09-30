## Основы Bash CLI

**Bash** - терминал, командная строка, консоль. Ещё **Bash**- это скриптовый ЯП

**CLI** - Command Line Interface

файл `bashcli.md`

### Терминал

Сдвинуть вверх лог выполненных ранее команд
```shell
Ctrl+L
```
Очистить весь экран терминала
```shell
clear
```
Сбросить текущий терминал
```shell
reset
```
Преравать выполняемый процесс
```shell
du /
```
Прервать по `Ctrl+C`

Получить историю всех ранее введённых команд
```shell
history
```
Выполнить команду по её порядковому **№**
```shell
!53
```
где 53 - это порядковый № команды из списка `history`

Выполнить последнюю команду из `history`
```shell
!!
```
Перелистывание ранее введённых команд
`Стрелки вверх/вниз ^v`

Дописывание команд и имён файлов/каталогов при помощи `Tab`

Выйти из текущего терминала
```shell
exit
```

### Linux (переходим в Ubuntu WSL)

Получить информацию по дистрибутиву
```shell
lsb_release -a
```
или красивей
```shell
fastfetch
```
или технические подробности
```shell
inxi -F
```
Системный монитор
```shell
htop
```
`Q` - выйти из `htop`

Получить t и CPU/GPU и скорость вращения Fan
```shell
sensors
```
Получить состояние оперативной памяти и подкачки (swap)
```shell
free -h
```
Получить имена текущих пользователей
```shell
w
```
Получить id текущего пользователя
```shell
id
```
Получить список групп, в которых числится текущий пользователь
```shell
groups
```

#### Софт

Показать календарь
```shell
cal
```
Получить дату и  время
```shell
date
```

### Сеть

Получить имя компьютера
```shell
hostname
```
Получить текущий `ip` копьютера
```shell
hostname -i
```
Информация по сети
```shell
ifconfig
```
или
```shell
ip -c r
```
или
```shell
ip -c a
```
Пинг адреса
```shell
ping 8.8.8.8
```
Чтобы выйти из бесконечного пинга, выполните `Ctrl+C`
```shell
ping ya.ru
```
Чтобы выйти из бесконечного пинга, выполните `Ctrl+C`

Выполнить пинг указанное количество раз
```shell
ping -c 4 ya.ru
```
Получить ин-фу по указанному домену
```shell
whois ozon.ru
```
Получить список портов
```shell
netstat -an
```
Получить маршруты
```shell
route
```

### Управление компьютером CLI

Перезагрузка
```shell
reboot
```
или
```shell
sudo shutdown -r now
```
или
```shell
sudo systemctl reboot
```
Выключение
```shell
poweroff
```
или
```shell
sudo shutdown -p now
```
или
```shell
sudo systemctl poweroff
```

### Файловые операции

Получить абсолютный путь к текущей директории
```shell
pwd
```
Получить содержимое текущей директории
```shell
ls
```
Получить структуру текущей директории
```shell
tree
```
Создать новый пустой файл
```shell
touch newFile.txt
```
Получить сведения о файле
```shell
file имя_файла
```
Получить содержимое текстового файла
```shell
cat имя_файла
```
Отредактировать текстовый файл
```shell
nano имя_файла
```
Сохранить `Ctrl+S`, выйти `Ctrl+X`

Переименовать файл
```shell
mv old_name.txt new_name.txt
```
Создать пустой каталог
```shell
mkdir NewFolder
```
Переименовать указанный каталог
```shell
mv newFolder/ newDir
```
Скопировать указанный файл в указанную папку
```shell
cp other_name.txt newDir/
```
Удалить файл
```shell
rm other_name.txt
```
Переместить файл
```shell
mv more_file.txt newDir/
```
Зайти в указанную папку
```shell
cd newDir
```
Выйти из текущей папки
```shell
cd ..
```
Вернуться в предыдушую папку
```shell
cd -
```
Удалить указанную папку
```shell
rm -rf newDir
```

### Пасхалки

Матрица
```shell
cmatrix
```
Выйти из матрицы по `Q`

Поезд
```shell
sl
```
ещё поезд
```shell
sl -a
```
и ещё поезд
```shell
sl -l
```
и ещё
```shell
sl -F
```
Огонь
```shell
cacafire
```
Попугай
```shell
curl parrot.live
```
Бегущий человек
```shell
curl ascii.live/forrest
```
Поющиё человек
```shell
curl ascii.live/can-you-hear-me
```
Аквариум
```shell
snap install asciiquarium && asciiquarium
```
Выйти из аквариума по '**Q**'

Хакерский терминал
```shell
docker run --rm -it bcbcarl/hollywood
```
Мнямка
```shell
nyancat
```
