FROM conoria/alpine-r:latest

RUN apk add --update \
    python \
    python-dev \
    py-pip \
    build-base \
  && pip install virtualenv \
  && rm -rf /var/cache/apk/*

RUN R -q -e "install.packages('rjson', repos='http://cran.rstudio.com/')" &&\
  rm -rf /tmp/*
  
RUN R -q -e "install.packages('jsonlite', dependencies=TRUE, repos='http://cran.rstudio.com/')" &&\
  rm -rf /tmp/*
# Upgrade and install basic Python dependencies
RUN apk add --no-cache bash \
 && apk add --no-cache --virtual .build-deps \
        bzip2-dev \
        gcc \
        libc-dev \
  && pip install --no-cache-dir gevent==1.1.2 flask==0.11.1 \
  && apk del .build-deps

ENV FLASK_PROXY_PORT 8080

RUN mkdir -p /actionProxy
ADD actionproxy.py /actionProxy/

RUN mkdir -p /action
ADD stub.sh /action/exec
RUN chmod +x /action/exec

CMD ["/bin/bash", "-c", "cd actionProxy && python -u actionproxy.py"]