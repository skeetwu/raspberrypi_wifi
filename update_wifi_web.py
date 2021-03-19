from flask import Flask, render_template, request
import os
app = Flask(__name__)
log_file = "/tmp/update_wifi_info.log"

@app.route('/')
def index():
    return render_template('index.html')


@app.route('/update_wifi_info', methods=['post'])
def login():
    os.system("""date >> %s""" % log_file)
    ssid = request.form.get('ssid')
    ssid_password = request.form.get('ssid_password')
    key_mgmt = request.form.get('key_mgmt')
    if not key_mgmt:
        key_mgmt = "WPA-PSK"

    content_list = []
    content_list.append("""
network={
        ssid="%s"
        psk="%s"
        key_mgmt=%s
}
"""%(ssid, ssid_password,key_mgmt))
    # update wpa_supplicant_file
    wpa_supplicant_file = "/etc/wpa_supplicant/wpa_supplicant.conf"
    with open(wpa_supplicant_file, 'a') as f:
        f.write("\n".join(content_list))
        f.close()
    os.system("""echo 'update %s with new wifi info' >> %s"""%(wpa_supplicant_file, log_file))

    # update flag to wifi_need_update_file
    wifi_need2update_file = "/etc/raspberrypi_wifi/data/wifi_need2update_file"
    os.system("""echo 'True' > %s"""%wifi_need2update_file)
    os.system("""echo 'update %s with True' >> %s"""%(wifi_need2update_file, log_file))

    msg = "update done"
    return render_template('index.html', msg=msg)



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)

