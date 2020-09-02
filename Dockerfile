FROM fedora:31

ENV NAME=rhscl-container-ci \
    RELEASE=1 \
    ARCH=x86_64 \
    HOME="/home/rhscl-container-ci"
ENV REQUESTS_CA_BUNDLE=/etc/pki/tls/certs/ca-bundle.crt

RUN dnf install -y python3-pip

WORKDIR ${HOME}

COPY ./ ${HOME}

RUN pip3 install -r requirements.txt

CMD ${HOME}/run.sh $JENKINS_CMD
