FROM golang:1.7.5 as build

RUN mkdir -p /go/src/github.com/alexellis/derek
WORKDIR /go/src/github.com/alexellis/derek
COPY	.	.
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o derek .

FROM alpine:3.5

RUN apk --no-cache add curl ca-certificates \ 
    && echo "Pulling watchdog binary from Github." \
    && curl -sSL https://github.com/alexellis/faas/releases/download/0.6.5/fwatchdog > /usr/bin/fwatchdog \
    && chmod +x /usr/bin/fwatchdog \
    && apk del curl --no-cache

WORKDIR /root/
COPY --from=build /go/src/github.com/alexellis/derek/derek derek

# Replace this with a Swarm secret, so that the image can be pushed remotely.
COPY derek.pem	.

ENV cgi_headers="true"
ENV validate_hmac="true"
ENV fprocess="./derek"

EXPOSE 8080
CMD ["fwatchdog"]
