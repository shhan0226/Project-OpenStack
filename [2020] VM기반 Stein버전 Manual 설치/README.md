본 프로젝트는 OpenStack의 Stein버전을 두개의 가상머신에 설치하는 것을 목적으로 한다.
====================================================================================

설치(실행)  순서는 다음과 같다.

step 1) ./INIT_INSTALLER.sh
- ip 설정 및 NTP 서비스는 별도로 설치해야 합니다.

step 2) ./KEYSTONE.sh
- controller node에 실행 

step 3) ./PLACEMENT.sh행
- controller node에 실행 

step 4) ./NOVA-CONTROLLER.sh
- controller node에 실행 

step 5) ./NOVA-COMPUTE.sh
- compute node에 실행

step 6) ./NOVA-COMPUTE-CHECK.sh
- controller node에 실행 

step 7) ./NEUTRON-CONTROLLER.sh
- controller node에 실행 

step 8) ./NEUTRON-COMPUTE.sh
- compute node에 실행

step 9)

step 10)

step 11)

