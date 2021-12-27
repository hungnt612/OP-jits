#!/bin/bash

# REMOVE !!!!!!!!
# sudo yum remove -y mariadb mariadb-server && sudo rm -rf /var/lib/mysql /etc/my.cnf 

echo hihi
 
echo "Installing and configiring mariadb..."
 
sudo dnf module install mariadb -y
sudo systemctl enable mariadb
sudo systemctl start mariadb
 
rootpasswd=th61
 
yum -y install expect
echo"Configiring mariadb.."
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQL\r\"
expect \"Set root password?\"
send \"y\r\"
expect \"New password:\"
send \"$rootpasswd\r\"
expect \"Re-enter new password:\"
send \"$rootpasswd\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"n\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL"

yum remove -y expect

 # Make sure that NOBODY can access the server without a password
sudo mysql -uroot -p${rootpasswd} -e "UPDATE mysql.user SET Password = PASSWORD('$root_password') WHERE User = 'root'"
 
# Kill the anonymous users
sudo mysql -uroot -p${rootpasswd} -e "DROP USER IF EXISTS ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
sudo mysql -uroot -p${rootpasswd} -e "DROP USER IF EXISTS ''@'$(hostname)'"
# Kill off the demo database
sudo mysql -uroot -p${rootpasswd} -e "DROP DATABASE IF EXISTS test"
 
 
echo "Creating staging database..."
 
sudo mysql -uroot -p${rootpasswd} -e "CREATE DATABASE IF NOT EXISTS staging"
 
echo "Creating production database..."
 
sudo mysql -uroot -p${rootpasswd} -e "CREATE DATABASE IF NOT EXISTS production"
 
echo "Creating table tasks in staging database..."
 
sudo mysql -uroot -p${rootpasswd} -e "use staging;CREATE TABLE IF NOT EXISTS tasks ( \
    task_id INT AUTO_INCREMENT PRIMARY KEY, \
    title VARCHAR(255) NOT NULL, \
    start_date DATE, \
    due_date DATE, \
    status TINYINT NOT NULL, \
    priority TINYINT NOT NULL, \
    description TEXT \
    ) ENGINE=INNODB;" \
 
echo "Table tasks created."
 
 
echo "Inserting data into tasks table..."
 
 
query1="use staging; INSERT INTO tasks (title, start_date, due_date, status, priority, description) \
        VALUES('task1', '2020-07-01', '2020-07-31', 1, 1, 'this is the first task')"
 
 
query2="use staging; INSERT INTO tasks (title, start_date, due_date, status, priority, description) \
        VALUES('task2', '2020-08-01', '2020-08-31', 2, 2, 'this is the second task')"
 
 
query3="use staging; INSERT INTO tasks (title, start_date, due_date, status, priority, description) \
        VALUES('task3', '2020-09-01', '2020-09-30', 1, 1, 'this is the third task')"
 
 
query4="use staging; INSERT INTO tasks (title, start_date, due_date, status, priority, description) \
        VALUES('task4', '2020-10-01', '2020-10-31', 1, 1, 'this is fourth task')"
 
 
 
 
 
sudo mysql -uroot -p${rootpasswd} -e "$query1"
sudo mysql -uroot -p${rootpasswd} -e "$query2"
sudo mysql -uroot -p${rootpasswd} -e "$query3"
sudo mysql -uroot -p${rootpasswd} -e "$query4"
 
 
echo "Inserting dummy data into tasks table finished"
 
 
echo "Creating table named 'completed' into production database..."
 
 
sudo mysql -uroot -p${rootpasswd} -e "use production; CREATE TABLE IF NOT EXISTS completed ( \
    task_id INT AUTO_INCREMENT PRIMARY KEY, \
    task_name VARCHAR(255) NOT NULL, \
    finished_date DATE, \
    status TEXT, \
    description TEXT \
    ) ENGINE=INNODB;" \
 
echo "Populating completed table with some dummy data..."
 
query_1="use production; INSERT INTO completed (task_name, finished_date, status, description) \
        VALUES('task1', '2020-07-31','done', 'task one finished')"
 
 
query_2="use production; INSERT INTO completed (task_name, finished_date, status, description) \
        VALUES('task2', '2020-08-31','completed', 'task two finished')"
 
query_3="use production; INSERT INTO completed (task_name, finished_date, status, description) \
        VALUES('task3', '2020-09-30','done', 'task three finished')"
 
query_4="use production; INSERT INTO completed (task_name, finished_date, status, description) \
        VALUES('task4', '2020-10-31','done', 'task four finished')"
 
sudo mysql -uroot -p${rootpasswd} -e "$query_1"
sudo mysql -uroot -p${rootpasswd} -e "$query_2"
sudo mysql -uroot -p${rootpasswd} -e "$query_3"
sudo mysql -uroot -p${rootpasswd} -e "$query_4"
 
echo "Database named 'completed' pupulated with dummy data."
 
echo "Creating staging_user and grant all permissions to staging database which password is password1..."
 
mysql -uroot -p${rootpasswd} -e "CREATE USER IF NOT EXISTS 'staging_user'@'localhost' IDENTIFIED BY 'password1'"
 
mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON staging.* to 'staging_user'@'localhost'"
 
 
echo "Creating production_user and grant all permissions to production database which password is password2..."
 
mysql -uroot -p${rootpasswd} -e "CREATE USER IF NOT EXISTS 'production_user'@'localhost' IDENTIFIED BY 'password2'"
 
mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON production.* to 'production_user'@'localhost'"
 
# # Make our changes take effect
sudo mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES"