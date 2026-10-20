# Building my own OpenVPN server on AWS EC2

![Platform](https://img.shields.io/badge/platform-Ubuntu%2024.04-E95420?style=flat)
![Cloud](https://img.shields.io/badge/cloud-AWS%20EC2-FF9900?style=flat)
![Instance](https://img.shields.io/badge/instance-t3.small-232F3E?style=flat)
![Region](https://img.shields.io/badge/region-us--east--1-0073BB?style=flat)
![VPN](https://img.shields.io/badge/VPN-OpenVPN-EA7E20?style=flat)
![Auth](https://img.shields.io/badge/auth-PKI-6f42c1?style=flat)
![Language](https://img.shields.io/badge/language-Bash-4EAA25?style=flat)
![License](https://img.shields.io/badge/license-MIT-4c1?style=flat)
![Version](https://img.shields.io/badge/version-v1.0-orange?style=flat)

A cybersecurity side project: I set up a private VPN server on AWS so a friend and I, living in different houses, can sit on the same virtual network and ping each other. Along the way I wanted to actually understand what's going on under the hood (certificates, routing, NAT, firewall rules) instead of just clicking "connect" in a commercial VPN app.

> **Status:** server is running and working, and I connect to it from my own PC.

## Why I did this

- I wanted hands-on practice with AWS, Linux and networking.
- I wanted to learn how a PKI (certificate authority, server cert, client certs) works in a real setup.
- My friend and I wanted a private network to ping and play around on without port forwarding on either home router.

Honest note: if you only want to connect two PCs, Tailscale or ZeroTier is much faster and free. I did this one the hard way on purpose, because the learning was the point.

## Architecture

```
   My PC (10.8.0.2)                                  Friend's PC (10.8.0.3)
        |                                                    |
        |  encrypted tunnel (UDP 1194)                       |  encrypted tunnel (UDP 1194)
        v                                                    v
   +------------------------------------------------------------+
   |        AWS EC2 (t3.small, Ubuntu 24.04), Elastic IP         |
   |        OpenVPN server, VPN subnet 10.8.0.0/24               |
   |        NAT + IP forwarding                                  |
   +------------------------------------------------------------+
                              |
                              v
                          Internet
```

The VPN addresses above are just examples. Yours will be assigned by the server.

## What I used

| Part | Choice |
|---|---|
| Cloud | AWS EC2, `t3.small` (2 vCPU, 2 GiB RAM) |
| OS | Ubuntu Server 24.04 LTS (x86_64) |
| VPN | OpenVPN, installed with the [angristan/openvpn-install](https://github.com/angristan/openvpn-install) script |
| Auth | PKI mode (own CA, server cert, one client cert per device) |
| Protocol / port | UDP 1194 |
| DNS pushed to clients | Cloudflare (1.1.1.1) |
| Fixed address | AWS Elastic IP |
| Clients | OpenVPN Connect |

**Credit:** the heavy lifting of generating the CA, certs and server config is done by Nyr/angristan's installer script. This repo is my documentation, my choices, and my testing around it, not a replacement for that project.

## How I set it up

Short version below. The full step-by-step with commands is in [`setup-steps.md`](setup-steps.md).

1. Launched the EC2 instance in `us-east-1` (t3.small, Ubuntu 24.04).
2. Security group: SSH (22) and UDP 1194 for OpenVPN.
3. Attached an Elastic IP so the address survives stop/start.
4. Turned off the source/destination check so the instance can forward VPN traffic.
5. Created my own admin user (`tunar`) instead of working as the default `ubuntu` user.
6. Ran `apt update && apt upgrade`, then the installer in interactive mode.
7. Created a client profile (`User1`), downloaded the `.ovpn` with `scp`, imported it into OpenVPN Connect.

**The instance: running, t3.small, Elastic IP attached**

![EC2 instance summary](docs/screenshots/01-ec2-instance.png)

**Security group inbound rules**

![Security group inbound rules](docs/screenshots/02-security-group.png)

## Choices I made, and why

- **PKI mode instead of fingerprint mode:** more to learn, and it lets me revoke a single client without touching the others.
- **One profile per device (multi-device off):** if a device is lost or a friend stops using it, I revoke just that one.
- **Own admin user instead of `ubuntu`:** a small step, but the default username is the first thing bots try.
- **Default encryption settings:** the script's defaults are modern and safe, and I didn't want to weaken them by guessing.
- **Clients can see each other: yes.** This is what makes "ping my friend" work. It's also a risk (see below).

## Testing

**Service running on the server**

![Service status](docs/screenshots/03-service-status.png)

**Client connected in OpenVPN Connect**

![Client connected](docs/screenshots/04-client-connected.png)

**My public IP while on the VPN: it's an Amazon server in Ashburn, Virginia, not my home connection**

![Public IP check](docs/screenshots/05-public-ip-check.png)

## Known issue: SSH is open to the internet

Look at the security group screenshot: port 22 has source `0.0.0.0/0`, so anyone can try to reach SSH. Login needs my private key (no passwords), but it's still more exposure than I want. This is the first thing I'm fixing: change the SSH rule to **My IP**, then retake the screenshot. I'm leaving it documented here because it's a good example of the gap between "it works" and "it's secure".

## Repo layout

```
.
├── README.md             project overview, setup choices, screenshots
├── setup-steps.md        full step-by-step commands, start to finish
├── LICENSE
├── .gitignore            keeps keys, certs and .ovpn files out of the repo
└── docs/
    └── screenshots/
        ├── 01-ec2-instance.png
        ├── 02-security-group.png
        ├── 03-service-status.png
        ├── 04-client-connected.png
        └── 05-public-ip-check.png
```

## Security note

This repo contains **no** keys, certificates, `.ovpn` files, or real IP addresses, and the `.gitignore` is set up to keep it that way. If you fork this, please keep it that way too.

## License

MIT for my docs. The installer script belongs to its own authors and has its own license.
