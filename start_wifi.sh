#!/bin/sh
LOG_DIR=/tmp/start_wifi.log

check_wifi_info()
{
  # wpa_supplicant.conf里面包含用户填写的WIFI信息
  echo '----check wpa_supplicant.conf里面是否有WIFI信息...' >>$LOG_DIR
  res=`grep network={ /etc/wpa_supplicant/wpa_supplicant.conf`
  wifi_info_existing=1
  if [ "$res" != "" ];then
    echo "有WIFI信息" >>$LOG_DIR
    wifi_info_existing=0
  else
    echo "无WIFI信息" >>$LOG_DIR
    wifi_info_existing=1
  fi
  return $wifi_info_existing
}

check_wifi_status()
{
  # check WIFI是否连接成功
  min=0
  max=2
  tmp_wifi_enabled_flag=1
  echo 'check_wifi_status...' >>$LOG_DIR

  while [ $min -le $max ]
  do
    min=`expr $min + 1`
    ip_account=`ip a | grep wlan0 | grep 'inet ' | grep -v "169.254"  -c`
    if [ "$ip_account" = "2" ]; then
      echo "WIFI已连接" >>$LOG_DIR
      tmp_wifi_enabled_flag=0
      break
    else
      echo "当前WIFI未连接" >>$LOG_DIR
    fi
    sleep 30s
  done
  return $tmp_wifi_enabled_flag
}

check_AP_status()
{ # check AP状态
  echo 'check_AP_status...' >>$LOG_DIR

  min=0
  max=5 #每次5s共25s
  tmp_AP_status_flag=1

  while [ $min -le $max ]
  do
    min=`expr $min + 1`
    hostpd_status=`systemctl status hostapd >>$LOG_DIR; echo $?`
    dnsmasq_status=`systemctl status dnsmasq >>$LOG_DIR; echo $?`
    if [ "$hostpd_status" = "0" ] && [ "$dnsmasq_status" = "0" ];then
      echo "热点状态正常" >>$LOG_DIR
      tmp_AP_status_flag=0
      break
    else
      echo "当前热点未启动" >>$LOG_DIR
    fi
    sleep 5s
  done
  return $tmp_AP_status_flag
}

delete_wifi_info()
{
  echo "删除错误WIFI信息" >> $LOG_DIR
  `sed -i "/network/,/^\}/ d" /etc/wpa_supplicant/wpa_supplicant.conf` >> $LOG_DIR 2>&1
  wpa_cli -i wlan0 reconfigure >>$LOG_DIR 2>&1
}

start_AP()
{
  systemctl restart hostapd >> $LOG_DIR 2>&1
  systemctl restart dnsmasq >> $LOG_DIR 2>&1
}

#-------------------------------------------------------------
echo ------开机启动------ >> $LOG_DIR
echo `date "+%y-%m-%d %H:%M:%S"` >>$LOG_DIR 2>&1

while true
do
  check_wifi_info
  wifi_info_flag=$?
  # check 是否有WIFI信息
  if $wifi_info_flag; then
    # 有WIFI信息
    wifi_enabled_flag=check_wifi_status
    if $wifi_enabled_flag; then
      echo "WIFI连接正常" >>$LOG_DIR
    else
      echo "有WIFI信息,WIFI连接失败，即将重启WIFI..." >>$LOG_DIR
      wpa_cli -i wlan0 reconfigure >>$LOG_DIR 2>&1
      # 因为是重启WIFI 多check几次
      check_wifi_status
      tmp_wifi_enabled_flag=$?
      if [ "$tmp_wifi_enabled_flag" = "1" ]; then
        echo "WIFI连接失败,WIFI信息有误，删除错误信息并重启热点..." >>$LOG_DIR
        delete_wifi_info
        start_AP
      fi
    fi
  else
    # 无WIFI信息
    check_AP_status
    AP_enabled_flag=$?
    echo $AP_enabled_flag
    if [ "$AP_enabled_flag" = "1" ]; then
      echo "无WIFI信息，热点未启动，即将启动热点..." >>$LOG_DIR
      start_AP
    fi
  fi

  sleep 5s
done

