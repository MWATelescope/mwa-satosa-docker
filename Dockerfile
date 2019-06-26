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

# Use a particular commit from the head of master on June 26, 2019
ENV SATOSA_SRC_URL=git+https://github.com/IdentityPython/SATOSA.git@f53bbd45faeb35b3db5007186e911150e9192e1e

WORKDIR /tmp

# Download the latest pip and use it to install 
# SATOSA and the ldap3 module.
RUN wget https://bootstrap.pypa.io/get-pip.py \
    && python3 get-pip.py \
    && rm -f get-pip.py \
    && pip install ldap3 \
    && pip install ${SATOSA_SRC_URL}

COPY start.sh /usr/local/sbin/satosa-start.sh
COPY proxy_conf.yaml /etc/satosa/proxy_conf.yaml
COPY internal_attributes.yaml /etc/satosa/internal_attributes.yaml
COPY attributemaps /etc/satosa/attributemaps
COPY plugins /etc/satosa/plugins
COPY mwa-metadata-signer.crt /etc/satosa/mwa-metadata-signer.crt

ENTRYPOINT ["/usr/local/sbin/satosa-start.sh"]
