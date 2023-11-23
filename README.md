# Consistent Development Box (devbox)

本项目的目标是可以在本地快速启动用于搭建应用环境的基础虚拟机模板，开发人员可以得到一个与服务器环境一致的本地开发环境，彻底解决初次搭建开发环境所经历的痛苦与无奈。另外，本项目是一个基于 Vagrant 和 VirtualBox 的搭建的，所以开发人员还是需要一些少量的软件安装工作。

## 前置条件

安装最新版 Vagrant： [Vagrant | HashiCorp Developer](https://developer.hashicorp.com/vagrant)

安装虚拟机软件 VirtualBox：[Downloads – Oracle VM VirtualBox](https://www.virtualbox.org/wiki/Downloads)

## 预装软件清单

预置安装的软件如下：

| 软件/系统        | 版本                       | 备注                           |
| ---------------- | -------------------------- | ------------------------------ |
| Vagrant Box 镜像 | `bento/rockylinux-9`       | 基础镜像                       |
| OpenJDK          | 8                          |                                |
| Apache Maven     | 3.9.5                      |                                |
| Git              | 2.29.3                     | 版本控制                       |
| Podman           | 4.4.1                      | 容器运行时                     |
| Podman Compose   | 1.0.6                      | 容器编排工具                   |
| Node.js          | 20.9.0                     | 由置备器 `frontend_tools` 提供 |
| npm              | 10.2.4                     | 由置备器 `frontend_tools` 提供 |
| Lerna            | 基于 Node 版本安装的最新版 | 由置备器 `frontend_tools` 提供 |
| Yarn             | 基于 Node 版本安装的最新版 | 由置备器 `frontend_tools` 提供 |

Docker Compose 将启动以下基础服务：

| 服务  | 版本                         | 备注                          |
| ----- | ---------------------------- | ----------------------------- |
| mysql | 5.7                          | 由置备器 `base_services` 提供 |
| redis | 4-alpine                     | 由置备器 `base_services` 提供 |
| minio | RELEASE.2019-10-12T01-39-57Z | 由置备器 `base_services` 提供 |

## 启动命令

```shell
$ vagrant up
```

## 置备器

当前的开发环境提供了几个常用的置备器（Provisioner）来按需执行特定的任务。开发环境通过 `vagrant up` 启动成功之后，就可以通过 `vagrant provision --provision-with <provisioner>` 来运行置备器。下面来逐个介绍一下。

### 1. base_services

该置备器用来以容器化的方式、通过 Docker Compose 来启动基础服务，包括 `mysql` ，`redis` 和 `MinIO`。 用户可以在 `base_services/docker-compose.yaml` 中查看详细的定义。启动置备器的命令如下：

```shell
$ vagrant provision --provision-with base_services
```

### 2. health_check

该置备器用于在置备器 `base_services` 执行完之后，查看服务的启动和运行状态。检查的原理实际上就是调用了 `docker-compose ps` 命令。运行该置备器的命令如下：

```shell
$ vagrant provision --provision-with health_check
```

得到如下类似的检查结果：

```
Name               Command                  State                     Ports
-----------------------------------------------------------------------------------------
minio   /usr/bin/docker-entrypoint ...   Up (healthy)   0.0.0.0:9000->9000/tcp
mysql   docker-entrypoint.sh mysqld      Up             0.0.0.0:3306->3306/tcp, 33060/tcp
redis   docker-entrypoint.sh redis ...   Up             0.0.0.0:6379->6379/tcp
```

### 3. frontend_tools

该置备器用户安装前端工具 Node, Yarn 和 Lerna，这些工具由一个名叫 `frontend_tools` 的置备器来提供安装，命令如下：

```shell
$ vagrant provision --provision-with frontend_tools
```

## 进入开发环境

```shell
$ vagrant ssh
$ cd /devbox
```

