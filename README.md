# Docker cfssl image

This Dockerfile produces a minimal cfssl image, based on the awesome work over at https://github.com/cloudflare/cfssl

Built on alpine linux, this produces a nice small image (~50 MB)

**Warning** This image doesn't offer any access control - anyone who can
connect to the service can sign certs, so you should only use this by
linking it to another container that does do access control.

# Usage:

* Set up your config:

```bash
sudo mkdir /etc/cfssl
sudo bash -c 'cat << EOF > /etc/cfssl/config.json
{
    "signing": {
        "default": {
            "expiry": "87600h"
        },
        "profiles": {
            "client": {
                    "usages": [
                            "signing",
                            "key encipherment",
                            "client auth"
                    ],
                    "expiry": "87600h"
            },
            "server": {
                    "usages": [
                            "signing",
                            "key encipherment",
                            "server auth",
                            "client auth"
                    ],
                    "expiry": "87600h"
            }
        }
    }
}
EOF'
```

* Set up your Root CA config

```bash
sudo bash -c 'cat << EOF > /etc/cfssl/ca.json
{
    "key": {
        "algo": "rsa",
        "size": 4096
    },
    "CN": "My root CA"
}
EOF'
```

* Now generate the root CA

```bash
docker run --rm -v /etc/cfssl:/etc/cfssl dhiltgen/cfssl genkey -initca ca.json | \
docker run --rm -i -v /etc/cfssl:/etc/cfssl --entrypoint cfssljson dhiltgen/cfssl -bare ca
```

# Running Server
* **WARNING** Rember, don't expose these ports on the open network, just use linking!

```bash
docker run -d -v /etc/cfssl:/etc/cfssl --name cfssl dhiltgen/cfssl serve -address=0.0.0.0 -config=config.json
```

At this point you can now link this container to other **TRUSTED** containers and sign certs

# Testing it out:

```bash
mkdir testCert
cd testCert
cat << EOF > mycert.json
{
    "hosts": [
        "127.0.0.1"
    ],
    "key": {
        "algo": "rsa",
        "size": 4096
    },
    "CN": "My Server"
}
EOF
docker run --rm --link=cfssl -v $(pwd):/etc/cfssl --entrypoint=/bin/sh dhiltgen/cfssl -c \
    'cfssl gencert -remote $CFSSL_PORT_8888_TCP_ADDR -profile=server mycert.json' | \
    docker run --rm -i -v $(pwd):/etc/cfssl --entrypoint cfssljson dhiltgen/cfssl -bare mycert
```


# Building

```bash
docker build -t dhiltgen/cfssl .
```
