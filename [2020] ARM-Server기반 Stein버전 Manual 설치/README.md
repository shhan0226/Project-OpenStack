# [2020] ARM기반 Stein버전 Manual 설치
  - ARM CPU 서버기반 Stein버전 Manual 설치 방법은 [Wiki](https://github.com/shhan0226/Project-OpenStack/wiki)에 작성되어 있습니다. <br>
  - 여기에는 Wiki에 작성된 내용을 기반으로 쉘 스크립트를 작성하였으며, 쉘 스크립트의 실행 순서는 다음과 같다.

### Step.1 
- Controller Node에서 실행합니다.
```
./INIT_INSTALLER.sh
```



### Step.2
-  Controller Node에서 실행합니다.
```
./KEYSTONE.sh
```

### Step.3
- Controller Node에서 실행합니다.
```
./GLANCE.sh
```

### Step.4
- Controller Node에서 실행합니다.
```
./PLACEMENT.sh
```

### Step.5
- Controller Node에서 실행합니다.
```
./NOVA-CONTROLLER.sh
```

### Step.6
- Compute Node에서 실행합니다.
```
./NOVA-COMPUTE.sh
```

### Step.7
- Controller Node에서 실행합니다.
```
./NOVA-COMPUTE-CHECK.sh
```

### Step.8
- Controller Node에서 실행합니다.
```
./NEUTRON-CONTROLLER.sh
```

### Step.9
- Compute Node에서 실행합니다.
```
./NEUTRON-COMPUTE.sh
```
