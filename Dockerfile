FROM golang:1.22-alpine

# Install deps
RUN apk add --no-cache  \
        bash            \
        curl            \
        gcc             \
        libc-dev        \
        make            \
        net-snmp        \
        net-snmp-tools  \
        openssl-dev     \
        python3         \
        py3-pip         \
        vim

# add new user
RUN addgroup -g 1001                \
             -S gosnmp;             \
    adduser -u 1001 -D -S           \
            -s /bin/bash            \
            -h /home/gosnmp         \
            -G gosnmp gosnmp

RUN chmod -R a+rw /etc/snmp /var/lib/net-snmp/

# Copy local branch into container
USER gosnmp
WORKDIR /go/src/github.com/gosnmp/gosnmp
COPY --chown=gosnmp . .

RUN make lint

ENV GOSNMP_TARGET=127.0.0.1
ENV GOSNMP_PORT=1024
ENV GOSNMP_TARGET_IPV4=127.0.0.1
ENV GOSNMP_PORT_IPV4=1024
ENV GOSNMP_TARGET_IPV6='::1'
ENV GOSNMP_PORT_IPV6=1024
ENV GOSNMP_SNMPD=true

ENTRYPOINT ["/go/src/github.com/gosnmp/gosnmp/build_tests.sh"]
