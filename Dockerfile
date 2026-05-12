FROM alpine:3.18

WORKDIR /app

COPY hello.sh alytest.sh ./

RUN chmod +x hello.sh alytest.sh

CMD ["sh", "hello.sh"]
