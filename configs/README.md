# Configs

If you want to share your server config in this repo, **sanitize it first**.

On the server:

```bash
sudo cat /etc/openvpn/server/server.conf
```

Before pasting it into a file here, check that:

- There are no private keys or inline certificate blocks (`<key>...</key>`)
- Your real public IP is replaced with `YOUR_ELASTIC_IP`
- Nothing else identifies you

Save it as `server.conf.sanitized` in this folder, then add a short explanation of the main settings: cipher, TLS version, `tls-crypt`, pushed routes and DNS. Explaining each line is a great way to show you understand it, not just that you ran a script.

**Never** put these here: `ca.key`, `server.key`, anything from `pki/private/`, or any `.ovpn` file.
