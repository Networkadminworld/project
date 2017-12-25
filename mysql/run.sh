service mysql start
mysql -uroot -proot -e "CREATE DATABASE piwikdb";
mysql -uroot -proot -e "CREATE DATABASE activiti";
mysql -uroot -proot -e "CREATE USER admin@5.189.133.209 IDENTIFIED BY 'password'";
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON piwikdb.* TO admin@5.189.133.209";
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON * . * TO 'admin'@'5.189.133.209'";
mysql -uroot -proot -e "grant all privileges on activiti.* to admin@'%' identified by 'password'";
mysql -uroot -proot -e "grant all privileges on activiti.* to admin@localhost identified by 'password'";
mysql -uroot -proot -e "grant all privileges on piwikdb.* to admin@'%' identified by 'password'";
mysql -uroot -proot -e "grant all privileges on piwikdb.* to admin@localhost identified by 'password'";
mysql -uroot -proot -e "FLUSH PRIVILEGES";
ping localhost
