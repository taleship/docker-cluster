FROM ubuntu:xenial

RUN apt-get update && apt-get install -y wget
ENV DOCKERIZE_VERSION v0.4.0
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 6.10.2
ENV PYTHONPATH $PYTHONPATH:/opt/app/taleship/

RUN apt-get update && \
    apt-get install python3-pip curl git build-essential python3-dev wget -y && \
    pip3 install -U pip setuptools && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm install $NODE_VERSION 

RUN mkdir -p /opt/app
WORKDIR /opt/app

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Begin copy stage. Pick one.
RUN git clone https://github.com/taleship/taleship
# COPY . /opt/app/taleship

RUN cd taleship && \
    pip3 install -r ./requirements.txt && \
    npm install && \
    npm run build_prod && \
    python3 manage.py collectstatic --noinput && \
    ls taleship

RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz