#!/bin/bash

sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'

sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y openvpn easy-rsa
sudo mkdir -p /etc/openvpn/easy-rsa
sudo ln -s /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/
sudo chown -R $USER:$USER /etc/openvpn/easy-rsa

cd /etc/openvpn/easy-rsa

./easyrsa init-pki <<< "yes"
./easyrsa --batch build-ca nopass
./easyrsa --batch gen-req server nopass
./easyrsa --batch sign-req server server
./easyrsa gen-dh

./easyrsa --batch gen-req client nopass
./easyrsa --batch sign-req client client

sudo cp pki/ca.crt pki/private/ca.key pki/issued/server.crt pki/private/server.key pki/dh.pem /etc/openvpn

sudo bash -c 'cat <<EOT > /etc/openvpn/server.conf
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
keepalive 10 120
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
log-append /var/log/openvpn.log
verb 3
push "route 10.0.0.0 255.255.0.0"
push "route 10.8.0.0 255.255.255.0"
topology subnet
EOT'

sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf


#sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o ens3 -j MASQUERADE

sudo ufw disable

sudo systemctl start openvpn@server
sudo systemctl enable openvpn@server

sudo bash -c 'cat <<EOT > /etc/openvpn/client.ovpn
client
dev tun
proto udp
remote SERVER_PUBLIC_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca [inline]
cert [inline]
key [inline]
cipher AES-256-CBC
verb 3
route 10.0.0.0 255.255.0.0

<ca>
$(sudo cat /etc/openvpn/ca.crt)
</ca>
<cert>
$(sudo cat /etc/openvpn/easy-rsa/pki/issued/client.crt)
</cert>
<key>
$(sudo cat /etc/openvpn/easy-rsa/pki/private/client.key)
</key>
EOT'