#!/bin/bash
if [ $1 ]; then   
	IPADDR=`ip -o -4 addr show up primary scope global | awk '{print $4}' | awk -F"/" '{print $1}'`
	echo "-------------------------------------------------------------------------------"
	echo -e "\n\n安装mysql server 5.7...\n\n"
	DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server-5.7
	if [ $? != 0 ]; then
	    echo -e "\n\nmysql-server-5.7安装失败！\n\n"
		exit 1
	fi
	mysql -uroot -e "grant all privileges on *.* to 'root'@'%' identified by '$1';"
	if [ $? != 0 ]; then
	    echo -e "\n\nmysql-server-5.7安装失败！\n\n"
		exit 1
	fi
	echo -e "\n\n配置mysql server 5.7...\n\n"
	mysql -uroot -e "grant all privileges on *.* to 'root'@'localhost' identified by '$1';"
	mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$1';"
	sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf 
	sed -i '40a\character_set_server=utf8' /etc/mysql/mysql.conf.d/mysqld.cnf
	service mysql restart
	if [ $? != 0 ]; then
	    echo -e "\n\nmysql配置失败！\n\n"
			exit 1
		else
			mysql -uroot -p$1 -e "show variables like 'character%';"
			mysql -uroot -p$1 -e "SELECT DISTINCT CONCAT('User: ''',user,'''@''',host,''';') AS query FROM mysql.user;"
	fi
	read -n 1 -p "按任意键继续..."
	echo "-------------------------------------------------------------------------------"
	echo -e "\n\n安装openjdk 8...\n\n"
	apt-get install -y openjdk-8-jdk vim
	if [ $? != 0 ]; then
	    echo -e "\n\njdk安装失败！\n\n"
		exit 1
	fi
	read -n 1 -p "按任意键继续..."
	echo "-------------------------------------------------------------------------------"
	echo -e "\n\n安装vim...\n\n"
	apt-get install -y vim
	if [ $? != 0 ]; then
	    echo -e "\n\nvim安装失败！\n\n"
		exit 1
	fi
	##配置高负载多并发
	#	apt-get install -y libapr1-dev libssl-dev libexpat1-dev
	#wget http://mirrors.hust.edu.cn/apache/apr/apr-1.6.5.tar.gz
	#wget http://mirrors.hust.edu.cn/apache/apr/apr-util-1.6.1.tar.gz
	#tar -zxvf apr-1.6.5.tar.gz
	#tar -zxvf apr-util-1.6.1.tar.gz
	#cd /usr/local/apr-1.6.5/
	#./configure --prefix=/usr/local/apr
	#make
	#make install
	#cd ../apr-util-1.6.1/
	#./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
	#make
	#make install

	#cd /usr/local/tomcat/bin
	#tar -zxvf tomcat-native.tar.gz
	#cd tomcat-native-1.2.21-src/native/
	#./configure --with-apr=/usr/local/apr/bin/apr-1-config --with-java-home=/usr/lib/jvm/java-1.8.0-openjdk-amd64
	#make
	#make install
	#cd ~
	
	read -n 1 -p "按任意键继续..."
	echo -e "\n\n安装tomcat 7.0.93...\n\n"
	wget http://mirrors.hust.edu.cn/apache/tomcat/tomcat-7/v7.0.93/bin/apache-tomcat-7.0.93.tar.gz
	if [ $? != 0 ]; then
	    echo -e "\n\n获取tomcat 7.0.93失败！请检查链接\n\n"
		exit 1
	fi
	tar xzf apache-tomcat-7.0.93.tar.gz -C /usr/local
	cp -r /usr/local/apache-tomcat-7.0.93 /usr/local/tomcat2
	mv /usr/local/apache-tomcat-7.0.93 /usr/local/tomcat
	rm -f apache-tomcat-7.0.93.tar.gz
	
	echo "-------------------------------------------------------------------------------"
	echo -e "\n\n配置tomcat 7.0.93...\n\n"
	
	echo -e "<tomcat-users>\n         
	<role rolename=\"manager-gui\"/>\n
	<role rolename=\"manager-script\"/>\n
	<user username=\"tomcat\" password=\"$1\" roles=\"admin,manager-gui,manager-script,manager-status\"/>\n
	</tomcat-users>" >/usr/local/tomcat/conf/tomcat-users.xml

	echo "-------------------------------------------------------------------------------"
	echo -e "\n\n配置tomcat自启动...\n\n"
	
	sed -i '2a\JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64' /usr/local/tomcat/bin/catalina.sh
	sed -i '3a\CATALINA_HOME=/usr/local/tomcat' /usr/local/tomcat/bin/catalina.sh
	#配置高负责，多并发
	#sed -i '4a\JAVA_OPTS="$JAVA_OPTS -Djava.library.path=/usr/local/apr/lib -server -Xms1024M -Xmx1024M -XX:MaxNewSize=512M"' /usr/local/tomcat/bin/catalina.sh
	#sed -i 's/SSLEngine="on"/SSLEngine="off"/g' /usr/local/tomcat/conf/server.xml
	#sed -i 's/HTTP\/1.1/org.apache.coyote.http11.Http11AprProtocol/' /usr/local/tomcat/conf/server.xml
	sed -n '1,5p' /usr/local/tomcat/bin/catalina.sh
	cp /usr/local/tomcat/bin/catalina.sh /etc/init.d/tomcat


	update-rc.d -f tomcat defaults
	if [ $? != 0 ]; then
	    echo -e "\n\n设置tomcat自启动失败！\n\n"
		exit 1
	fi
	service tomcat start
	if [ $? != 0 ]; then
	    echo -e "\n\n设置tomcat自启动失败！\n\n"
		exit 1
	fi
	read -p "是否需要安装另一个tomcat?[y/n]" input
	echo $input
	if [ $input = "y" ];then
	    echo -e "\n安装tomcat2...\n"
	    sed -i 's/8005/9005/g' /usr/local/tomcat2/conf/server.xml
		sed -i 's/8080/9090/g' /usr/local/tomcat2/conf/server.xml
		sed -i 's/8009/9009/g' /usr/local/tomcat2/conf/server.xml
	
		echo -e "<tomcat-users>\n         
			<role rolename=\"manager-gui\"/>\n
			<role rolename=\"manager-script\"/>\n
			<user username=\"tomcat\" password=\"$1\" roles=\"admin,manager-gui,manager-script,manager-status\"/>\n
			</tomcat-users>" >/usr/local/tomcat2/conf/tomcat-users.xml
			
		sed -i '2a\JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64' /usr/local/tomcat2/bin/catalina.sh
		sed -i '3a\CATALINA_HOME=/usr/local/tomcat2' /usr/local/tomcat2/bin/catalina.sh
		#配置高负载，多并发
		#sed -i '4a\JAVA_OPTS="$JAVA_OPTS -Djava.library.path=/usr/local/apr/lib -server -Xms1024M -Xmx1024M -XX:MaxNewSize=512M"' /usr/local/tomcat2/bin/catalina.sh
		#sed -i 's/SSLEngine="on"/SSLEngine="off"/g' /usr/local/tomcat2/conf/server.xml
		#sed -i 's/HTTP\/1.1/org.apache.coyote.http11.Http11AprProtocol/' /usr/local/tomcat2/conf/server.xml
		sed -n '1,5p' /usr/local/tomcat2/bin/catalina.sh
		cp /usr/local/tomcat2/bin/catalina.sh /etc/init.d/tomcat2

		
		update-rc.d -f tomcat2 defaults
		if [ $? != 0 ]; then
		    echo -e "\n\n设置tomcat2自启动失败！\n\n"
			exit 1
		fi
		service tomcat2 start
		if [ $? != 0 ]; then
		    echo -e "\n\n设置tomcat2自启动失败！\n\n"
			exit 1
		fi	
	fi
	
	
	echo "-------------------------------------------------------------------------------"
	echo -e "\n\n自动安装完成！\n\n"
	echo "请使用http://${IPADDR}:8080访问 tomcat"
	if [ $input = "y" ];then
		echo "或使用http://${IPADDR}:9090访问第2 tomcat"
	fi
	echo "-------------------------------------------------------------------------------"
	echo -e "\n\n重启系统！\n\n"
	read -n 1 -p "按任意键重新启动"
	reboot
	else
	  echo "usage: install.sh password(数据库密码)"
	  rm ~/.my.cnf
	  exit 1
fi