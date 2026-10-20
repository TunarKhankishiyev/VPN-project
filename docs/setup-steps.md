# Setup steps (full commands)

Everything I did, in order. Replace `YOUR_ELASTIC_IP` with your own address.

## 1. Launch the EC2 instance

- AMI: Ubuntu Server 24.04 LTS, 64-bit (x86)
- Instance type: `t3.small`
- Key pair: create one and keep the `.pem` file safe (never commit it)
- Storage: 16-20 GiB gp3
- Security group:
  - SSH, TCP 22, source **My IP**
  - Custom UDP, port 1194, source 0.0.0.0/0 (add after launch if the wizard doesn't offer it)

## 2. After launch

1. **Elastic IP:** EC2 > Elastic IPs > Allocate > Associate with the instance.
2. **Source/destination check:** EC2 > Instances > select > Actions > Networking > Change source/destination check > Stop.

## 3. Connect over SSH

```bash
chmod 400 VPN.pem          # Mac/Linux only
ssh -i VPN.pem ubuntu@YOUR_ELASTIC_IP
```

## 4. Update the server

```bash
sudo apt update && sudo apt upgrade -y
```

## 5. Download and run the installer

```bash
curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh
sudo ./openvpn-install.sh interactive
```

Answers I used:

| Question | My answer |
|---|---|
| Endpoint IP version | IPv4 |
| Server public IP | my Elastic IP (not the private 172.31.x.x) |
| Client IP versions | IPv4 only |
| VPN subnet | default 10.8.0.0/24 |
| Route all client traffic through VPN | yes |
| Clients can access each other | yes |
| Clients can access server's local network | no |
| Port | 1194 |
| Protocol | UDP |
| DNS | Cloudflare |
| Multiple devices per profile | no |
| MTU | default |
| Auth mode | PKI |
| Custom encryption | no (defaults) |

Then create the first client when the script asks.

## 6. Check the service

```bash
sudo systemctl status openvpn-server@server
systemctl is-enabled openvpn-server@server
sysctl net.ipv4.ip_forward
```

Expected: `active (running)`, `enabled`, and `net.ipv4.ip_forward = 1`.

## 7. Add more clients

```bash
sudo ./openvpn-install.sh client add friend1
# see all options:
sudo ./openvpn-install.sh client --help
```

## 8. Download the profile (run on your own PC, not on the server)

```bash
scp -i VPN.pem ubuntu@YOUR_ELASTIC_IP:/home/ubuntu/client1.ovpn .
```

If the file isn't there, find it with `ls ~/*.ovpn` on the server.

## 9. Connect

Install OpenVPN Connect, import the `.ovpn`, connect. Check your public IP, it should now be the server's.

## 10. Ping between two clients

Find your VPN address (`10.8.0.x`) with `ipconfig` (Windows) or `ip a` (Linux/Mac), then ping your friend's. If Windows blocks it, in an Administrator PowerShell:

```powershell
New-NetFirewallRule -DisplayName "Allow ICMPv4" -Protocol ICMPv4 -IcmpType 8 -Action Allow
```

## Troubleshooting

| Problem | Check |
|---|---|
| Connects but no internet | source/dest check off, `ip_forward` = 1, NAT rule present |
| Can't connect at all | UDP 1194 in security group, Elastic IP attached, `grep remote client1.ovpn` matches the IP |
| Worked yesterday, not today | public IP changed after stop/start (no Elastic IP) |
| Need logs | `sudo journalctl -u openvpn-server@server -n 50` |
