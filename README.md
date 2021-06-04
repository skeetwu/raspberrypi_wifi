# raspberrypi_wifi

#### 软件架构
start.sh#安装程序,出厂前执行一次
- 主要功能：
 1. 下载软件到指定目录
 2. 解压修改权限
 3. 执行pre_install.sh #安装所需软件及相关配置;
    其中的如下配置需根据具体树莓派型号验证更新
    - hw_mode=b #WiFi网络模式
    - channel=8 #根据hw_mode填写正确的信道编号

 4. 设置开机启动
    - 添加python update_wifi_web.py & 到/etc/rc.local;
      update_wifi_web.py 提供web界面，以便用户输入WIFI信息
    - 添加bash start_wifi.sh & 到/etc/rc.local;
      start_wifi.sh 负责启动热点，监控用户WIFI信息输入，连接、切换并监测相关状态。

#### 安装教程

1.  下载start.sh到树莓派某个目录
2.  chmod +x start.sh
3.  ./start.sh

#### 使用说明
1. 安装后重启树莓派，发现热点信息：
   ssid=serena-raspberry;
   wpa_passphrase=12345678;
2. 连接热点后，可以打开网页http://10.0.0.1，
   输入想要连接的WIFI账号密码
3. 如果WIFI连接失败会自动转为热点状态




感谢Serena同学，弄的非常不错。
