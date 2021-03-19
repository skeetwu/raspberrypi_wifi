#!/bin/sh

# 下载程序到指定目录
cd /etc
wget https://gitee.com/serena-li/raspberrypi_wifi/repository/archive/master.zip
unzip master.zip
rm -rf master.zip

cd raspberrypi_wifi
chmod -R +x start_wifi.sh pre_install.sh update_wifi_web.py templates
# 安装所需软件及相关配置
echo "执行pre_install.sh..."
bash pre_install.sh

work_dir=/etc/raspberrypi_wifi
#设置开机启动
echo "设置开机启动..."
if [ "$(grep update_wifi_web.py /etc/rc.local)" != "" ];then
  # 删除已有的信息
  sed -i '/update_wifi_web.py/d' /etc/rc.local
fi
sed -i '/^exit 0/i\python /etc/raspberrypi_wifi/update_wifi_web.py &' /etc/rc.local

if [ "$(grep start_wifi.sh /etc/rc.local)" != "" ];then
  # 删除已有的
  sed -i '/start_wifi.sh/d' /etc/rc.local
fi
sed -i '/^exit 0/i\bash /etc/raspberrypi_wifi/start_wifi.sh &' /etc/rc.local


echo "设置完成"

exit
