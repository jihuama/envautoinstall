#!/bin/bash
echo -e "\n彻底删除mysql5.7...\n"
apt -y purge mysql-*
rm -rf /etc/mysql/ /var/lib/mysql
apt -y autoremove
apt autoclean
echo -e "\n删除mysql5.7完成\n\n"
echo -e "\n彻底删除jdk...\n"
apt -y purge openjdk-*
apt -y autoremove
apt autoclean
echo -e "\n删除jdk完成\n\n"
echo -e "\n彻底删除tomcat...\n"
service tomcat stop
service tomcat2 stop
rm /etc/init.d/tomcat
rm /etc/init.d/tomcat2
update-rc.d -f tomcat remove
update-rc.d -f tomcat2 remove
rm -rf /usr/local/tomcat
rm -rf /usr/local/tomcat2
echo -e "\n彻底删除tomcat完成\n"
echo "-------------------------------------------------------------------------------"
echo -e "\n\n重启系统！\n\n"
read -n 1 -p "按任意键重新启动"
reboot
