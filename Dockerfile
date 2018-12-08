FROM debian:stretch

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

# Pull request 200 for SATOSA fixes an issue when the authenticating
# IdP does not send a <NameID>.
ENV SATOSA_SRC_URL=git+https://github.com/IdentityPython/SATOSA.git@refs/pull/200/merge

# Pull request 483 for pysaml2 adds signature checking on metadata 
# retrieved from a MDQ server.
ENV PYSAML2_SRC_URL=git+https://github.com/IdentityPython/pysaml2.git@refs/pull/483/merge

# Use the head of the master branch of the official SATOSA microservices repository.
ENV SATOSA_MICROSERVICES_SRC_URL=https://github.com/IdentityPython/satosa_microservices/archive/master.tar.gz

WORKDIR /tmp

# Download the latest pip and use it to install pysaml2,
# SATOSA and the ldap3 module.
RUN wget https://bootstrap.pypa.io/get-pip.py \
    && python3 get-pip.py \
    && rm -f get-pip.py \
    && pip install ${PYSAML2_SRC_URL} \
    && pip install ldap3 \
    && pip install ${SATOSA_SRC_URL}

# Download the SATOSA microservices.
RUN wget -O satosa_microservices.tar.gz ${SATOSA_MICROSERVICES_SRC_URL} \
    && mkdir -p /opt/satosa_microservices \
    && tar -zxf satosa_microservices.tar.gz -C /opt/satosa_microservices --strip-components=1 \
    && rm -f satosa_microservices.tar.gz

# Set PYTHONPATH appropriately for the SATOSA microservices.
ENV PYTHONPATH=/opt/satosa_microservices/src/satosa/micro_services

COPY start.sh /usr/local/sbin/satosa-start.sh
COPY proxy_conf.yaml /etc/satosa/proxy_conf.yaml
COPY internal_attributes.yaml /etc/satosa/internal_attributes.yaml
COPY attributemaps /etc/satosa/attributemaps
COPY plugins /etc/satosa/plugins
COPY mwa-metadata-signer.crt /etc/satosa/mwa-metadata-signer.crt

ENTRYPOINT ["/usr/local/sbin/satosa-start.sh"]
