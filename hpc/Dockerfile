## pkg
# docker build --rm=true -t hpcer/hpcdev:0.2.0 .
FROM genshen/mpich:3.2.1

# Copy only build result from previous step to new lightweight image
ADD --chown=root:root https://github.com/genshen/pkg/releases/download/v0.2.0/pkg-linux-amd64 /usr/local/bin/pkg

RUN sudo chmod 755 /usr/local/bin/pkg \
   && sudo apk add --no-cache cmake python3 \
   && sudo pip3 install gcovr

CMD ["/bin/ash"]
