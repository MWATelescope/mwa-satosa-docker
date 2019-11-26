FROM debian:buster

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        python3-dev \
        build-essential \
        libffi-dev \
        libssl-dev \
        xmlsec1 \
        libyaml-dev \
        wget \
        ca-certificates

# Until PR 653 for pysaml2 is merged install from the PR.
ENV PYSAML2_SRC_URL=git+https://github.com/IdentityPython/pysaml2@refs/pull/653/merge

# Use a particular commit from the head of master on November 25, 2019
ENV SATOSA_SRC_URL=git+https://github.com/IdentityPython/SATOSA.git@933c0b923c04f106894906eddcbcdfafa032c99e

WORKDIR /tmp

# Download the latest pip and use it to install 
# SATOSA and the ldap3 module.
RUN wget https://bootstrap.pypa.io/get-pip.py \
    && python3 get-pip.py \
    && rm -f get-pip.py \
    && pip install ${PYSAML2_SRC_URL} \
    && pip install ldap3 \
    && pip install ${SATOSA_SRC_URL}

COPY start.sh /usr/local/sbin/satosa-start.sh
COPY proxy_conf.yaml /etc/satosa/proxy_conf.yaml
COPY internal_attributes.yaml /etc/satosa/internal_attributes.yaml
COPY attributemaps /etc/satosa/attributemaps
COPY plugins /etc/satosa/plugins
COPY mwa-metadata-signer.crt /etc/satosa/mwa-metadata-signer.crt

ENTRYPOINT ["/usr/local/sbin/satosa-start.sh"]
