#!/bin/bash

param_user=""
param_repo=""
param_namespace="user"
path_projects="/var/www/путь-к-синкману/data/syncman/projects"
path_project_sample="/var/www/путь-к-синкману/data/syncman/projects-example/default"
path_ssh_syncman="/var/www/путь-к-синкману/data/.ssh"

while [ $# != "0" ]
do 
     case $1 in
     "-u")
          param_user=$2
          echo "option  -u"
	  echo "argument $param_user"
	  shift
          ;;
     "-r")
          param_repo=$2
          echo "option  -r"
	  echo "argument $param_repo"
	  shift
          ;;
     *)
          echo "Unknown option  $1"
          ;;
     esac
     shift
done

echo "1: Переходим в домашний каталог пользователя /var/www/$param_user/data"
cd /var/www/$param_user/data
sudo -u $param_user mkdir .ssh
sudo -u $param_user chmod 700 .ssh
cd .ssh

echo "2: Создаём приватный ключ для доступа к веб-хосту"
sudo -u $param_user ssh-keygen -t rsa -f $param_user -N ""

echo "3: Авторизуем приватный ключ"
sudo -u $param_user cat $param_user.pub >> authorized_keys

echo "4: Удаляем лишнее (публичный ключ)"
rm -f $param_user.pub

echo "5: Создаём деплой-ключ"
sudo -u $param_user ssh-keygen -t rsa -f $param_user\_deploy -N ""

echo "6: Меняем права для приватных данных на 600"
chown $param_user:$param_user *
sudo -u $param_user chmod -R 600 *

echo "7: Перемещаем веб-ключ и деплой ключ в папку синкмана"
mv /var/www/$param_user/data/.ssh/$param_user $path_ssh_syncman/$param_user
mv /var/www/$param_user/data/.ssh/$param_user\_deploy $path_ssh_syncman/$param_user\_deploy

echo "8: Меняем для ключей владельца на syncman и права на 700"
chmod 700 $path_ssh_syncman/$param_user
chmod 700 $path_ssh_syncman/$param_user\_deploy
chown пользователь-синкман:пользователь-синкман $path_ssh_syncman/$param_user
chown пользователь-синкман:пользователь-синкман $path_ssh_syncman/$param_user\_deploy

echo "9: Добавляем в конфигурация SSH (syncman) новый хост для деплоя"
echo "" >> $path_ssh_syncman/config
echo "Host $param_repo" >> $path_ssh_syncman/config
echo "Hostname code.ваш-хост.ru" >> $path_ssh_syncman/config
echo "user git" >> $path_ssh_syncman/config
echo "IdentityFile ~/.ssh/$param_user""_deploy" >> $path_ssh_syncman/config

echo "10: Создаём конфигурацию проекта синкман из типового проекта ~/syncman/projects-example/default"

echo "10.1 Конфигурация master-ветки"
sudo -u пользователь-синкман mkdir $path_projects/$param_repo\-master
sudo -u пользователь-синкман cp $path_project_sample/settings.conf.php $path_projects/$param_repo\-master/settings.conf.php
sed -i 's/\[user\]/'$param_user'/g' $path_projects/$param_repo\-master/settings.conf.php
sed -i 's/\[branch\]/'master'/g' $path_projects/$param_repo\-master/settings.conf.php
sed -i 's/\[key\]/'$param_user'/g' $path_projects/$param_repo\-master/settings.conf.php
sed -i 's/\[site\]/'$param_user'\.ru/g' $path_projects/$param_repo\-master/settings.conf.php
sed -i 's/\[host\]/'$param_repo'/g' $path_projects/$param_repo\-master/settings.conf.php
sed -i 's/\[repo\]/'$param_repo'/g' $path_projects/$param_repo\-master/settings.conf.php

echo "10.2 Конфигурация demo-ветки"
sudo -u пользователь-синкман mkdir $path_projects/$param_repo\-demo
sudo -u пользователь-синкман cp $path_project_sample/settings.conf.php $path_projects/$param_repo\-demo/settings.conf.php
sed -i 's/\[user\]/'$param_user'/g' $path_projects/$param_repo\-demo/settings.conf.php
sed -i 's/\[branch\]/demo/g' $path_projects/$param_repo\-demo/settings.conf.php
sed -i 's/\[key\]/'$param_user'/g' $path_projects/$param_repo\-demo/settings.conf.php
sed -i 's/\[site\]/'$param_user'\.ваш-хост\.ru/g' $path_projects/$param_repo\-demo/settings.conf.php
sed -i 's/\[host\]/'$param_repo'/g' $path_projects/$param_repo\-demo/settings.conf.php
sed -i 's/\[repo\]/'$param_repo'/g' $path_projects/$param_repo\-demo/settings.conf.php

#echo "11: Создаём символическую ссылку на пользовательский гит-хук (синхронизацию по пушу) на событию post-receive"
#sudo -u git ln -s /home/git/gitlab-custom_hooks /home/git/repositories/$param_namespace/$param_repo.git/custom_hooks
