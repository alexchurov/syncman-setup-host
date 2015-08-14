<?php
$conf = array(
  'server' => array(
    'host' => 'ваш-хост.ru',
    'user' => '[user]',
    'port' => 22,
    'key' => '/var/www/путь-к-синману/data/.ssh/[key]',
    'remote_dir' => '/var/www/[user]/data/www/[site]',
  ),
  'repository' => array(
    'type' => 'git',
    'path' => 'git@[host]:пространство-имён/[repo].git',
    'branch' => '[branch]',
  ),
  'type_sync' => 'rsync',
  'postsync_cmd' => 'ssh -i %key% %user%@%host% \'bash -s\' < /var/www/путь-к-синману/data/syncman/global_postsync_cmd.sh %remote_dir%',
  'history' => false,
  'category' => '',
);
