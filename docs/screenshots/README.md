# Screenshots

All screenshots are from my real setup. Public IPs, instance/account IDs and DNS names are blacked out.

| File | What it shows |
|---|---|
| 01-ec2-instance.png | EC2 instance summary: running, t3.small, Elastic IP attached |
| 02-security-group.png | Inbound rules: TCP 22 (SSH) and UDP 1194 (OpenVPN) |
| 03-service-status.png | `systemctl status openvpn-server@server`: active (running), enabled at boot |
| 04-client-connected.png | OpenVPN Connect showing "Securely Connected!" |
| 05-public-ip-check.png | IP lookup while on the VPN: ISP is Amazon, city Ashburn, Virginia |

If you add more screenshots, blur the public IP, AWS account ID and key names first. Never screenshot a `.ovpn` file or anything in `pki/private/`.
