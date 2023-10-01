#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'
BLUE="\033[36m"

echo "Vui lòng chọn ngôn ngữ | Please select a language"
echo -e "${YELLOW}Please note that the language you choose will affect the output of the backend program"
echo -e "Xin lưu ý rằng ngôn ngữ bạn chọn sẽ ảnh hưởng đến đầu ra của chương trình phụ trợ${PLAIN}"
echo -e "${BLUE}However no support for language other than Chinese and English is provided in this installation script${PLAIN}"
echo -e "${BLUE}Tuy nhiên, tập lệnh cài đặt này chỉ cung cấp hỗ trợ tiếng Trung và tiếng Anh${PLAIN}"
echo "1.简体中文(zh_cn)"
echo "2.English(en_us)"
echo "3.Vietnamese(vi_vn)"
read -e language
if [ $language != "1" ] && [ $language != "2" ] && [ $language != "3" ]; then
    echo "Lỗi đầu vào, đã thoát | Input error, exit"
    exit;
fi
if [ $language == '1' ]; then
  echo "Quản lý ID Apple của bạn theo cách mới, chương trình phát hiện và mở khóa Apple ID tự động dựa trên các câu hỏi bảo mật"
  echo "Địa chỉ dự án：github.com/pplulee/appleid_auto"
  echo "Nhóm truyền thông dự án TG: @appleunblocker"
  echo "==============================================================="
else
  echo "Manage your Apple ID in a new way, an automated Apple ID detection & unlocking program based on security questions"
  echo "Project address: github.com/pplulee/appleid_auto"
  echo "Project discussion Telegram group: @appleunblocker"
  echo "==============================================================="
fi
if docker >/dev/null 2>&1; then
    echo "Docker đã được cài đặt | Docker is installed"
else
    echo "Docker chưa được cài đặt, hãy bắt đầu cài đặt... | Docker is not installed, start installing..."
    docker version > /dev/null || curl -fsSL get.docker.com | bash
    systemctl enable docker && systemctl restart docker
    echo "Cài đặt Docker hoàn tất | Docker installed"
fi
if [ $language == '1' ]; then
  echo "Bắt đầu cài đặt phụ trợ Apple_Auto"
  echo "Vui lòng nhập URL API (tên miền ngoại vi, định dạng http[s]://xxx.xxx)"
  read -e api_url
  echo "Vui lòng nhập API Key"
  read -e api_key
  echo "Bật cập nhật tự động?(y/n)"
  read -e auto_update
  echo "Vui lòng nhập khoảng thời gian đồng bộ nhiệm vụ (đơn vị: phút, mặc định 15)"
  read -e sync_time
  if [ "$sync_time" = "" ]; then
      sync_time=15
  fi
  echo "Triển khai vùng chứa Docker Selenium?(y/n)"
  read -e run_webdriver
else
  echo "Start installing Apple_Auto backend"
  echo "Please enter API URL (http://xxx.xxx)"
  read -e api_url
  echo "Please enter API Key"
  read -e api_key
  echo "Do you want to enable auto update? (y/n)"
  read -e auto_update
  echo "Please enter the task synchronization period (unit: minute, default 15)"
  read -e sync_time
  if [ "$sync_time" = "" ]; then
      sync_time=15
  fi
  echo "Do you want to deploy Selenium Docker container? (y/n)"
  read -e run_webdriver
fi
if [ "$run_webdriver" = "y" ]; then
    echo "Bắt đầu triển khai bộ chứa Selenium Docker | Start deploying Selenium Docker container"
    echo "Vui lòng nhập cổng chạy Selenium (mặc định 4444) | Vui lòng nhập cổng chạy Selenium (mặc định 4444)"
    read -e webdriver_port
    if [ "$webdriver_port" = "" ]; then
        webdriver_port=4444
    fi
    echo "Vui lòng nhập số phiên tối đa (mặc định 10) trong Selenium | Vui lòng nhập số phiên tối đa (mặc định 10)"
    read -e webdriver_max_session
    if [ "$webdriver_max_session" = "" ]; then
        webdriver_max_session=10
    fi
    docker pull selenium/standalone-chrome
    docker run -d --name=webdriver --log-opt max-size=1m --log-opt max-file=1 --shm-size="1g" --restart=always -e SE_NODE_MAX_SESSIONS=$webdriver_max_session -e SE_NODE_OVERRIDE_MAX_SESSIONS=true -e SE_SESSION_RETRY_INTERVAL=1 -e SE_VNC_VIEW_ONLY=1 -p $webdriver_port:4444 -p 5900:5900 selenium/standalone-chrome
    echo "Đã hoàn tất triển khai vùng chứa Docker của webdriver | Đã triển khai vùng chứa Docker của Webdriver"
fi
enable_auto_update=$([ "$auto_update" == "y" ] && echo True || echo False)
docker run -d --name=appleauto --log-opt max-size=1m --log-opt max-file=2 --restart=always --network=host -e API_URL=$api_url -e API_KEY=$api_key -e SYNC_TIME=$sync_time -e AUTO_UPDATE=$enable_auto_update -e LANG=$language -v /var/run/docker.sock:/var/run/docker.sock sahuidhsu/appleauto_backend
if [ $language = "1" ]; then
  echo "Quá trình cài đặt hoàn tất và container được bắt đầu"
  echo "Tên vùng chứa mặc định: appleauto"
  echo "Cách vận hành:"
  echo "Dừng container: docker stop appleauto"
  echo "Khởi động lại container: docker restart appleauto"
  echo "Xem nhật ký vùng chứa: docker logs appleauto"
else
  echo "Installation completed, container started"
  echo "Default container name: appleauto"
  echo "Operation method:"
  echo "Stop: docker stop appleauto"
  echo "Restart: docker restart appleauto"
  echo "Check status: docker logs appleauto"
fi
exit 0
