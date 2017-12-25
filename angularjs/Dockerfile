FROM ubuntu
RUN apt-get update && apt-get -y upgrade && apt-get install -y curl wget
RUN curl -sL https://deb.nodesource.com/setup_4.x |   bash -
RUN apt-get install -y nodejs
RUN npm install -g generator-angular
RUN apt-get install -y build-essential vim
RUN npm install --save angular
RUN npm install -g grunt
EXPOSE 9000
 
CMD ["/usr/lib/node_modules/grunt/bin/grunt"]
