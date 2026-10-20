# Threat model (simple version)

A VPN isn't magic. Here is what mine does and doesn't do.

## What I'm protecting

- Traffic between a client and the VPN server (confidentiality and integrity)
- Access to the private VPN network (only people with a valid certificate)
- The server itself (SSH and admin access)

## What it protects against

| Threat | How it helps |
|---|---|
| Someone on the same Wi-Fi sniffing my traffic | Traffic goes through an encrypted tunnel to the server |
| My ISP seeing which sites I visit | They only see encrypted traffic to the server's IP |
| Random people joining my VPN | Each client needs a certificate signed by my CA |
| A lost or stolen device | I can revoke that one client certificate |

## What it does NOT protect against

| Threat | Why |
|---|---|
| The server owner (me) seeing traffic | After the tunnel ends at the server, traffic to normal websites is only as private as the website's own HTTPS |
| AWS seeing metadata | It's their network; they can see the server's connections |
| Malware on a client | A VPN doesn't clean an infected device |
| A friend's compromised PC attacking mine | Client-to-client access is **on**, so a compromised client can reach other clients |
| A leaked `.ovpn` file | It contains the client's private key; anyone with it can connect as that client until revoked |
| Being anonymous | The server's IP is tied to my AWS account |

## Attack surface

- **SSH (TCP 22):** restricted to my IP in the security group. Key-only login.
- **OpenVPN (UDP 1194):** open to the internet by design. Protected by TLS and certificates.
- **The server OS:** needs regular updates.

## Mitigations (done / planned)

- [x] SSH restricted to my IP
- [x] One certificate per device
- [ ] fail2ban on SSH
- [ ] Automatic security updates
- [ ] Revocation tested
- [ ] Consider turning off client-to-client access, or firewalling between clients
- [ ] Share `.ovpn` files only through a secure channel

## Lessons

The biggest risk in a small project like this is not the crypto, it's the human stuff: leaked key files, forgotten updates, and an overly open firewall.
