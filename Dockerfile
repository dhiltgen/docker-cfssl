FROM gliderlabs/alpine:3.2

MAINTAINER Daniel Hiltgen "<daniel.hiltgen@docker.com>"

# Try hard to get a minimal image to reduce footprint
RUN apk update && \
    apk add go git gcc libc-dev libltdl libtool libgcc && \
    export GOPATH=/go && \
    go get -u github.com/cloudflare/cfssl/cmd/... && \
    apk del go git gcc libc-dev libtool libgcc && \
    mv /go/bin/* /bin/ && \
    rm -rf /go/src/golang.org && \
    rm -rf /go/src/github.com/GeertJohan && \
    rm -rf /go/src/github.com/daaku && \
    rm -rf /go/src/github.com/dgryski && \
    rm -rf /go/src/github.com/kardianos && \
    rm -rf /go/src/github.com/miekg

VOLUME [ "/etc/cfssl" ]
WORKDIR /etc/cfssl
EXPOSE 8888
ENTRYPOINT ["/bin/cfssl"]
