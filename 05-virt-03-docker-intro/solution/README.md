
# Домашнее задание к занятию 4 «Оркестрация группой Docker контейнеров на примере Docker Compose»

### Инструкция к выполению

1. Для выполнения заданий обязательно ознакомьтесь с [инструкцией](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD) по экономии облачных ресурсов. Это нужно, чтобы не расходовать средства, полученные в результате использования промокода.
2. Практические задачи выполняйте на личной рабочей станции или созданной вами ранее ВМ в облаке.
3. Своё решение к задачам оформите в вашем GitHub репозитории в формате markdown!!!
4. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.

## Решение Задачи 1
Воспользовался виртуалкой Vagrant из прошлого задания в которой уже есть docker-compose И прочие утилиты
-	vagrant ssh 
-	sudo docker pull nginx:1.21.1 #скачал образ из репозитория, значит не нужно проводить доп действий
-	Создал докер файл:
```
FROM nginx:1.21.1
RUN echo -e '<html>\n<head>\nHey, Netology\n</head>\n<body>\n<h1>I will be DevOps Engineer!</h1>\n</body>\n</html>' > /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```
Параметр _daemon off_ чтобы nginx не работал в фоновом режиме, а мы могли отслеживать логи процесса через STDOUT 
- Создал образ с тегом lobanovds/custom-nginx:1.0.0
- Проверил, что система запускается, запустив 
```
sudo docker run lobanovds/custom-nginx:1.0.0
```
-	Получил логи
```
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2025/05/17 14:22:17 [notice] 1#1: using the "epoll" event method
2025/05/17 14:22:17 [notice] 1#1: nginx/1.21.1
2025/05/17 14:22:17 [notice] 1#1: built by gcc 8.3.0 (Debian 8.3.0-6)
2025/05/17 14:22:17 [notice] 1#1: OS: Linux 6.8.0-31-generic
2025/05/17 14:22:17 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2025/05/17 14:22:17 [notice] 1#1: start worker processes
2025/05/17 14:22:17 [notice] 1#1: start worker process 31
```
- Залогинился через браузер в докерхаб и получил токен
Далее в линуксе: 
 
```docker login -u lobanovds```
- Ввел токен
- Запушил образ в регистри

```docker push lobanovds/custom-nginx:1.0.0```

- Проверил, на сайте образ появился тоже https://hub.docker.com/repository/docker/lobanovds/custom-nginx/general

## Решение Задачи 2


- Запускаю докер в фоне с портом 8080 на локалхосте и с моим именем контейнера

```sudo docker run -d --name lobanovds-custom-nginx-t2 -p 8080:80  lobanovds/custom-nginx:1.0.0```
- проверяю что всё работает: так как зашёл по SSh могу посмотреть через CURL
 
```curl 127.0.0.1:8080```

-	Переименовал
```
sudo docker rename lobanovds-custom-nginx-t2 custom-nginx-t2
sudo docker ps
CONTAINER ID   IMAGE                          COMMAND                  CREATED         STATUS         PORTS                                     NAMES
cf9efcbc8954   lobanovds/custom-nginx:1.0.0   "/docker-entrypoint.…"   5 minutes ago   Up 5 minutes   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   custom-nginx-t2
```
-	выполнил указанную команду под рутом вывод:
```
vagrant@server1:~$ sudo su
root@server1:/home/vagrant# date +"%d-%m-%Y %T.%N %Z" ; sleep 0.150 ; docker ps ; ss -tlpn | grep 127.0.0.1:8080  ; docker logs custom-nginx-t2 -n1 ; docker exec -it custom-nginx-t2 base64 /usr/share/nginx/html/index.html
17-05-2025 14:38:40.123041654 UTC
CONTAINER ID   IMAGE                          COMMAND                  CREATED         STATUS         PORTS                                     NAMES
cf9efcbc8954   lobanovds/custom-nginx:1.0.0   "/docker-entrypoint.…"   7 minutes ago   Up 7 minutes   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   custom-nginx-t2
172.17.0.1 - - [17/May/2025:14:32:01 +0000] "GET / HTTP/1.1" 200 98 "-" "curl/8.5.0" "-"
LWUgPGh0bWw+CjxoZWFkPgpIZXksIE5ldG9sb2d5CjwvaGVhZD4KPGJvZHk+CjxoMT5JIHdpbGwg
YmUgRGV2T3BzIEVuZ2luZWVyITwvaDE+CjwvYm9keT4KPC9odG1sPgo=
```
![task2.png](task2.png)


## Решение Задачи 3
- Присоединяюсь к потоку
```sudo docker attach custom-nginx-t2```
- нажимаю ctrl+c. Так как в данном режиме приложение слушает std-in а мы туда отправляем ctrl+c – приложение завершается, а значит для и контейнера нет причины работать. Он останавливается
- перезапустил контейнер
```sudo docker restart custom-nginx-t2```

- зашёл в bash 
```
sudo docker exec -it custom-nginx-t2 /bin/bash
apt update
apt install vim
```
сменил порт и перезагрузил Nginx
Суть проблемы в том, что контейнер настроен на проброс внутреннего порта 80, а Nginx перенастроился на 81, в результате 8080 смотрел в закрытый порт
По инструкции исправил порт без удаления контейнера. Правда пока не представляю ситуацию, где такое может пригодиться, но буду знать.
Удалил работающий контейнер с флагом -f

![task3.png](task3.png)

## Решение Задачи 4
![task4.png](task4.png)
В результате выполнения каждый контейнер видит содержимое данной директории

## Решение Задачи 5
![Picture5.png](Picture5.png)
![task5.png](task5.png)

Очень расстроен тем, что не было рассказано ни про портейнер, ни про то что за образ registry мы качаем ни про то, как заводить в него образы докера. 
Вместо того, чтобы быстро сделать задачу я долго думал, что неправильно раскатил образы, оказалось в регистри не было образа, 
пришлось закачивать его туда самостоятельно и разбираться с этим. Можно было хотябы намекнуть что ожидается от выполнения или что в регистри образы автоматически не подтягиваются.

## Задача 1

Сценарий выполнения задачи:
- Установите docker и docker compose plugin на свою linux рабочую станцию или ВМ.
- Если dockerhub недоступен создайте файл /etc/docker/daemon.json с содержимым: ```{"registry-mirrors": ["https://mirror.gcr.io", "https://daocloud.io", "https://c.163.com/", "https://registry.docker-cn.com"]}```
- Зарегистрируйтесь и создайте публичный репозиторий  с именем "custom-nginx" на https://hub.docker.com (ТОЛЬКО ЕСЛИ У ВАС ЕСТЬ ДОСТУП);
- скачайте образ nginx:1.21.1;
- Создайте Dockerfile и реализуйте в нем замену дефолтной индекс-страницы(/usr/share/nginx/html/index.html), на файл index.html с содержимым:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I will be DevOps Engineer!</h1>
</body>
</html>
```
- Соберите и отправьте созданный образ в свой dockerhub-репозитории c tag 1.0.0 (ТОЛЬКО ЕСЛИ ЕСТЬ ДОСТУП). 
- Предоставьте ответ в виде ссылки на https://hub.docker.com/<username_repo>/custom-nginx/general .

## Задача 2
1. Запустите ваш образ custom-nginx:1.0.0 командой docker run в соответвии с требованиями:
- имя контейнера "ФИО-custom-nginx-t2"
- контейнер работает в фоне
- контейнер опубликован на порту хост системы 127.0.0.1:8080
2. Не удаляя, переименуйте контейнер в "custom-nginx-t2"
3. Выполните команду ```date +"%d-%m-%Y %T.%N %Z" ; sleep 0.150 ; docker ps ; ss -tlpn | grep 127.0.0.1:8080  ; docker logs custom-nginx-t2 -n1 ; docker exec -it custom-nginx-t2 base64 /usr/share/nginx/html/index.html```
4. Убедитесь с помощью curl или веб браузера, что индекс-страница доступна.

В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод.


## Задача 3
1. Воспользуйтесь docker help или google, чтобы узнать как подключиться к стандартному потоку ввода/вывода/ошибок контейнера "custom-nginx-t2".
2. Подключитесь к контейнеру и нажмите комбинацию Ctrl-C.
3. Выполните ```docker ps -a``` и объясните своими словами почему контейнер остановился.
4. Перезапустите контейнер
5. Зайдите в интерактивный терминал контейнера "custom-nginx-t2" с оболочкой bash.
6. Установите любимый текстовый редактор(vim, nano итд) с помощью apt-get.
7. Отредактируйте файл "/etc/nginx/conf.d/default.conf", заменив порт "listen 80" на "listen 81".
8. Запомните(!) и выполните команду ```nginx -s reload```, а затем внутри контейнера ```curl http://127.0.0.1:80 ; curl http://127.0.0.1:81```.
9. Выйдите из контейнера, набрав в консоли  ```exit``` или Ctrl-D.
10. Проверьте вывод команд: ```ss -tlpn | grep 127.0.0.1:8080``` , ```docker port custom-nginx-t2```, ```curl http://127.0.0.1:8080```. Кратко объясните суть возникшей проблемы.
11. * Это дополнительное, необязательное задание. Попробуйте самостоятельно исправить конфигурацию контейнера, используя доступные источники в интернете. Не изменяйте конфигурацию nginx и не удаляйте контейнер. Останавливать контейнер можно. [пример источника](https://www.baeldung.com/linux/assign-port-docker-container)
12. Удалите запущенный контейнер "custom-nginx-t2", не останавливая его.(воспользуйтесь --help или google)

В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод.

## Задача 4


- Запустите первый контейнер из образа ***centos*** c любым тегом в фоновом режиме, подключив папку  текущий рабочий каталог ```$(pwd)``` на хостовой машине в ```/data``` контейнера, используя ключ -v.
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив текущий рабочий каталог ```$(pwd)``` в ```/data``` контейнера. 
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```.
- Добавьте ещё один файл в текущий каталог ```$(pwd)``` на хостовой машине.
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.


В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод.


## Задача 5

1. Создайте отдельную директорию(например /tmp/netology/docker/task5) и 2 файла внутри него.
"compose.yaml" с содержимым:
```
version: "3"
services:
  portainer:
    network_mode: host
    image: portainer/portainer-ce:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```
"docker-compose.yaml" с содержимым:
```
version: "3"
services:
  registry:
    image: registry:2

    ports:
    - "5000:5000"
```

И выполните команду "docker compose up -d". Какой из файлов был запущен и почему? (подсказка: https://docs.docker.com/compose/compose-application-model/#the-compose-file )

2. Отредактируйте файл compose.yaml так, чтобы были запущенны оба файла. (подсказка: https://docs.docker.com/compose/compose-file/14-include/)

3. Выполните в консоли вашей хостовой ОС необходимые команды чтобы залить образ custom-nginx как custom-nginx:latest в запущенное вами, локальное registry. Дополнительная документация: https://distribution.github.io/distribution/about/deploying/
4. Откройте страницу "https://127.0.0.1:9000" и произведите начальную настройку portainer.(логин и пароль адмнистратора)
5. Откройте страницу "http://127.0.0.1:9000/#!/home", выберите ваше local  окружение. Перейдите на вкладку "stacks" и в "web editor" задеплойте следующий компоуз:

```
version: '3'

services:
  nginx:
    image: 127.0.0.1:5000/custom-nginx
    ports:
      - "9090:80"
```
6. Перейдите на страницу "http://127.0.0.1:9000/#!/2/docker/containers", выберите контейнер с nginx и нажмите на кнопку "inspect". В представлении <> Tree разверните поле "Config" и сделайте скриншот от поля "AppArmorProfile" до "Driver".

7. Удалите любой из манифестов компоуза(например compose.yaml).  Выполните команду "docker compose up -d". Прочитайте warning, объясните суть предупреждения и выполните предложенное действие. Погасите compose-проект ОДНОЙ(обязательно!!) командой.

В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод, файл compose.yaml , скриншот portainer c задеплоенным компоузом.

---

### Правила приема

Домашнее задание выполните в файле readme.md в GitHub-репозитории. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.


