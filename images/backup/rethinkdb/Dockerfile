FROM alpine

RUN apk update && \
  apk add py-pip && \
  pip install rethinkdb==2.3.0.post6

ADD scripts/run.sh /run.sh

CMD ["/run.sh"]
