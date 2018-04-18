FROM quay.io/kwiksand/cryptocoin-base:latest

RUN useradd -m paccoin

#ENV DAEMON_RELEASE="v1.9.9"
ENV DAEMON_RELEASE="v0.12.3.0"
#ENV GIT_COMMIT="cabbdc220a6d35fb4b00d9c4655b217b2a4d62b3"
ENV PACCOIN_DATA=/home/paccoin/.paccoin

USER paccoin
RUN cd /home/paccoin

RUN cd /home/paccoin && \
    mkdir /home/paccoin/bin && \
    mkdir .ssh && \
    chmod 700 .ssh && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts && \
    git clone --branch $DAEMON_RELEASE https://github.com/pacCommunity/pac.git paccoind && \
    cd /home/paccoin/paccoind && \
#    git checkout $GIT_COMMIT && \
    chmod 777 autogen.sh src/leveldb/build_detect_platform && \
#    sed -i 's/<const\ CScriptID\&/<CScriptID/' rpcrawtransaction.cpp && \
#    make -f makefile.unix && \a
    ./autogen.sh && \
    ./configure LDFLAGS="-L/home/paccoin/db4/lib/" CPPFLAGS="-I/home/paccoin/db4/include/" && \
    make && \
    cd src/ && \
    strip paccoind && \
    strip paccoin-tx && \
    strip paccoin-cli && \
    mv paccoind paccoin-cli paccoin-tx /home/paccoin/bin && \
    chmod 755 /home/paccoin/bin/paccoind && \
    chmod 755 /home/paccoin/bin/paccoin-cli && \
    chmod 755 /home/paccoin/bin/paccoin-tx && \
    rm -rf /home/paccoin/paccoind
    
EXPOSE 22348 9999

USER root

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh && \
    mv /home/paccoin/bin/* /usr/bin && \
    echo "\n# Some aliases to make the paccoin clients/tools easier to access\nalias paccoind='/usr/bin/paccoind -conf=/home/paccoin/.paccoin/paccoin.conf'\nalias paccoin-cli='/usr/bin/paccoin-cli -conf=/home/paccoin/.paccoin/paccoin.conf'\n\n[ ! -z \"\$TERM\" -a -r /etc/motd ] && cat /etc/motd" >> /etc/bash.bashrc && \
    echo "paccoin ($PAC) Cryptocoin Daemon\n\nUsage:\n paccoin-cli help - List help options\n paccoin-cli listtransactions - List Transactions\n\n" > /etc/motd

ENTRYPOINT ["/entrypoint.sh"]

CMD ["paccoind"]
