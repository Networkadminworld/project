#
# Ubuntu 14.04 with activiti Dockerfile
#
# Pull base image.
### http://blog.docker.com/2015/03/updates-available-to-popular-repos-update-your-images/
# dockerfile/java renamed to java
### 
FROM ubuntu:16.04
MAINTAINER vikas chennybirru@gmail.com

EXPOSE 8080

ENV TOMCAT_VERSION 8.0.48
ENV ACTIVITI_VERSION 5.22.0
ENV MYSQL_CONNECTOR_JAVA_VERSION 5.1.40
RUN apt-get update && apt-get install openjdk-8-jdk wget curl  unzip -y
# Tomcat
#RUN wget http://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tar.gz && \
RUN wget http://www-us.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz  -O /tmp/tomcat.tar.gz && \
	tar xzf /tmp/tomcat.tar.gz -C /opt && \
	ln -s /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
	rm /tmp/tomcat.tar.gz && \
	rm -rf /opt/tomcat/webapps/examples && \
	rm -rf /opt/tomcat/webapps/docs

# To install jar files first we need to deploy war files manually
RUN wget https://github.com/Activiti/Activiti/releases/download/activiti-${ACTIVITI_VERSION}/activiti-${ACTIVITI_VERSION}.zip -O /tmp/activiti.zip && \
 	unzip /tmp/activiti.zip -d /opt/activiti && \
	unzip /opt/activiti/activiti-${ACTIVITI_VERSION}/wars/activiti-explorer.war -d /opt/tomcat/webapps/activiti-explorer && \
	unzip /opt/activiti/activiti-${ACTIVITI_VERSION}/wars/activiti-rest.war -d /opt/tomcat/webapps/activiti-rest && \
	rm -f /tmp/activiti.zip

# Add mysql connector to application
RUN wget http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}.zip -O /tmp/mysql-connector-java.zip && \
	unzip /tmp/mysql-connector-java.zip -d /tmp && \
	cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}-bin.jar /opt/tomcat/webapps/activiti-rest/WEB-INF/lib/ && \
	cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}-bin.jar /opt/tomcat/webapps/activiti-explorer/WEB-INF/lib/ && \
	rm -rf /tmp/mysql-connector-java.zip /tmp/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}

# Add roles
ADD assets /assets
RUN cp /assets/config/tomcat/tomcat-users.xml /opt/apache-tomcat-${TOMCAT_VERSION}/conf/
RUN cp /assets/config/db.properties /opt/tomcat/webapps/activiti-explorer/WEB-INF/classes/
RUN cp /assets/config/db.properties /opt/tomcat/webapps/activiti-explorer/WEB-INF/classes/
CMD /opt/tomcat/bin/catalina.sh run
