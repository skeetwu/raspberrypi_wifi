#!/bin/sh
LOG_DIR=/tmp/pre_install.log
echo ------出厂前执行------ >> $LOG_DIR
echo `date "+%y-%m-%d %H:%M:%S"` >>$LOG_DIR 2>&1

echo install hostapd and dnsmasq >>$LOG_DIR
apt update >>$LOG_DIR 2>&1
apt install hostapd >>$LOG_DIR 2>&1
systemctl stop hostapd >>$LOG_DIR 2>&1
apt install dnsmasq >>$LOG_DIR 2>&1
systemctl stop dnsmasq >>$LOG_DIR 2>&1


echo 配置hostapd.conf >>$LOG_DIR
cat > /etc/hostapd/hostapd.conf << EOF
interface=wlan0
driver=nl80211
ssid=serena-raspberry
wpa_passphrase=12345678
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
hw_mode=b
channel=8
auth_algs=1
wpa=2
EOF

echo 设置wlan0 IP地址 >>$LOG_DIR
ip addr flush dev wlan0
ip addr add 10.0.0.1/24 dev wlan0
ip link set wlan0 up

cat > /etc/network/interfaces.d/wlan0 << EOF
auto wlan0
iface wlan0 inet static
    address 10.0.0.1
    netmask 255.255.255.0
EOF


echo 设置DAEMON_CONF >>$LOG_DIR
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"'>>/etc/default/hostapd

systemctl unmask hostapd>> $LOG_DIR 2>&1
systemctl enable hostapd >> $LOG_DIR 2>&1


echo 配置DNS >> $LOG_DIR
cat > /etc/dnsmasq.conf << EOF
bind-interfaces
interface=wlan0
listen-address=10.0.0.1,127.0.0.1
dhcp-range=10.0.0.100,10.0.0.200,24h
EOF

systemctl enable dnsmasq >> $LOG_DIR 2>&1
wpa_cli -i wlan0 reconfigure >>$LOG_DIR 2>&1
# reconfigure wpa_cli 以防已连接wifi断开

echo -----配置结束----- >>$LOG_DIR
exit

