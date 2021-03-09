# 开发基础环境

本地快速启动用于搭建应用环境的基础虚拟机，启动完成之后改虚拟机会包含以下操作系统和软件：

| 属性           | 值         |
| -------------- | ---------- |
| 操作系统       | CentOS 7.5 |
| Node.js        | 12.18.3    |
| NPM            | 6.14.6     |
| lerna          | 4.0.0      |
| yarn           | 1.22.10    |
| java           | 1.8.0_282  |
| maven          | 3.3.9      |
| Git            | 2.24.3     |
| Docker         | 17.09.1-ce |
| Docker Compose | 1.24.1     |

Docker Compose 启动以下基础服务：

| 属性  | 值                           |
| ----- | ---------------------------- |
| mysql | 5.7                          |
| redis | 4-alpine                     |
| minio | RELEASE.2018-05-25T19-49-13Z |

### 启动命令

```shell
$ vagrant up
$ vagrant provision --provision-with base-service
$ vagrant provision --provision-with health-check
```

### 进入开发环境

```shell
$ vagrant ssh
$ cd /quickstart
```

