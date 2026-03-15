# Self-signed HTTPS stack

This stack runs File Browser behind Nginx with a self-signed certificate.

## Quick start

From the repository root:

```sh
mkdir -p /srv/filebrowser/{data,database,config}
chown -R 1000:1000 /srv/filebrowser
SSL_CN=your.domain.or.ip docker compose -f docker-compose.selfsigned.yml up -d --build
```

The certificate is generated automatically on first run and stored in the `filebrowser_tls` Docker volume.

## Notes

- `SSL_CN` should match the host you open in the browser.
- Browsers will show a warning because the certificate is self-signed.
- To regenerate certificate, remove the `filebrowser_tls` volume and restart:

```sh
docker compose -f docker-compose.selfsigned.yml down
docker volume rm filebrowser_filebrowser_tls
SSL_CN=your.domain.or.ip docker compose -f docker-compose.selfsigned.yml up -d --build
```
