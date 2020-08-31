### killer more than 1/2 hr
rm -f /var/lib/mysql-files/mysql_Qkill.txt
mysql --force -e "select concat('KILL ',id,';') from information_schema.processlist where substring_index(info,' ',1) = 'SELECT' and time>400 and user<>'root'  into outfile '/var/lib/mysql-files/mysql_Qkill.txt'; source /var/lib/mysql-files/mysql_Qkill.txt;"
