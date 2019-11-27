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

# Use a particular commit from the head of master on Novemberr 26, 2019
ENV PYSAML2_SRC_URL=git+https://github.com/IdentityPython/pysaml2.git@2dbe481104f9acc6d408bc14c054c4f46b087a97

# Until PR 313 is merged use a reference to get the code with PR 313 merged
ENV SATOSA_SRC_URL=git+https://github.com/IdentityPython/SATOSA@refs/pull/313/merge

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
