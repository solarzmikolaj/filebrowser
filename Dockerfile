FROM node:24-alpine AS frontend-builder

WORKDIR /src/frontend

COPY frontend/package.json frontend/pnpm-lock.yaml ./
RUN corepack enable && corepack prepare pnpm@10.32.1 --activate && pnpm install --no-frozen-lockfile

COPY frontend/ ./
RUN pnpm run build

FROM golang:1.26-alpine AS backend-builder

WORKDIR /src

RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod download

COPY . .
COPY --from=frontend-builder /src/frontend/dist ./frontend/dist

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/filebrowser .

FROM alpine:3.23 AS fetcher

RUN apk update && \
    apk --no-cache add ca-certificates mailcap tini-static && \
    wget -O /JSON.sh https://raw.githubusercontent.com/dominictarr/JSON.sh/0d5e5c77365f63809bf6e77ef44a1f34b0e05840/JSON.sh

FROM busybox:1.37.0-musl

ENV UID=1000
ENV GID=1000

RUN addgroup -g $GID user && \
    adduser -D -u $UID -G user user

COPY --chown=user:user --from=backend-builder /out/filebrowser /bin/filebrowser
COPY --chown=user:user docker/common/ /
COPY --chown=user:user docker/alpine/ /
COPY --chown=user:user --from=fetcher /sbin/tini-static /bin/tini
COPY --from=fetcher /JSON.sh /JSON.sh
COPY --from=fetcher /etc/ca-certificates.conf /etc/ca-certificates.conf
COPY --from=fetcher /etc/ca-certificates /etc/ca-certificates
COPY --from=fetcher /etc/mime.types /etc/mime.types
COPY --from=fetcher /etc/ssl /etc/ssl

RUN mkdir -p /config /database /srv && \
    chown -R user:user /config /database /srv && \
    chmod +x /healthcheck.sh

HEALTHCHECK --start-period=2s --interval=5s --timeout=3s CMD /healthcheck.sh

USER user

VOLUME /srv /config /database

EXPOSE 80

ENTRYPOINT [ "tini", "--", "/init.sh" ]
