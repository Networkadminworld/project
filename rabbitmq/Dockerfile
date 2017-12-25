#
# RabbitMQ Dockerfile
#
# https://github.com/dockerfile/rabbitmq
#

# Pull base image.
FROM ubuntu

RUN apt-get update && apt-get install wget curl -y
# Install Erlang
WORKDIR /root
RUN \
  wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
  dpkg -i erlang-solutions_1.0_all.deb
RUN apt-get update && apt-get install erlang erlang-nox -y
#Install RabbitMQ Server
RUN echo 'deb http://www.rabbitmq.com/debian/ testing main' | tee /etc/apt/sources.list.d/rabbitmq.list
RUN wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | apt-key add -
RUN apt-get update && apt-get upgrade -y
RUN apt-get install rabbitmq-server -y
# Add files
ADD rabbitmq-start /usr/local/bin/
# Manage RabbitMQ Service
RUN rm -rf /var/lib/apt/lists/* && \
  echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config && \
  chmod +x /usr/local/bin/rabbitmq-start
# Define environment variables.
ENV RABBITMQ_LOG_BASE /data/log
ENV RABBITMQ_MNESIA_BASE /data/mnesia
RUN apt-get clean
# Define mount points.
VOLUME ["/data/log", "/data/mnesia"]
# Define working directory.
WORKDIR /data
# Define default command.
CMD rabbitmq-start

# Expose ports.
EXPOSE 5672
EXPOSE 15672
