
## 쉘 스크립트 설치(실행) 순서는 다음과 같다.

- step 1) ./INIT_INSTALLER.sh
  - ip 설정 및 NTP 서비스는 별도로 설치해야 합니다.

- step 2) ./KEYSTONE.sh
  - controller node

- step 3) ./PLACEMENT.sh행
  - controller node

- step 4) ./NOVA-CONTROLLER.sh
  - controller node

- step 5) ./NOVA-COMPUTE.sh
  - compute node

- step 6) ./NOVA-COMPUTE-CHECK.sh
  - controller node

- step 7) ./NEUTRON-CONTROLLER.sh
  - controller node

- step 8) ./NEUTRON-COMPUTE.sh
  - compute node

- step 9)

- step 10)

- step 11)

