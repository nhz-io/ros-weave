# Docker file for ros-weave

FROM alpine
MAINTAINER Ishi Ruy <dev@nhz.io>

RUN apk add -U docker iproute2 && curl -L git.io/weave > /usr/bin/weave && chmod a+x /usr/bin/weave

ENV IF eth+
ENV TCP_PORTS 22,80,443,6783
ENV UDP_PORTS 6783,6784
ENV HEAD_NODE localhost
ENV PEER_COUNT 3
ENV DOCKER_HOST unix:///var/run/user-docker.sock

CMD iptables -t mangle -F \
	&& iptables -t mangle -A PREROUTING -i $IF -m conntrack --ctstate NEW -m multiport -p tcp \! --dports $TCP_PORTS -j DROP \
	&& iptables -t mangle -A PREROUTING -i $IF -m conntrack --ctstate NEW -m multiport -p udp \! --dports $UDP_PORTS -j DROP; \
	weave stop; \
	weave launch-router --init-peer-count $PEER_COUNT; \
  	weave launch-plugin; \
  	weave launch-proxy -H unix:///var/run/docker.sock; \
  	weave connect $HEAD_NODE

