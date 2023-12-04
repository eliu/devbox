# Consistent Development Box (devbox)

本项目可以在本地快速启动用于本地开发的基础虚拟机模板，可提供容器化环境、Java后端和前端编译工具等。开发人员可以得到一个与服务器环境一致的本地开发环境，彻底解决初次搭建开发环境所经历的痛苦与无奈。

项目是一个基于 Vagrant 和 VirtualBox 的搭建的，所以开发人员还是需要一些少量的软件安装工作。

## 前置软件安装

安装最新版 Vagrant： [Vagrant | HashiCorp Developer](https://developer.hashicorp.com/vagrant)

安装虚拟机软件 VirtualBox：[Downloads – Oracle VM VirtualBox](https://www.virtualbox.org/wiki/Downloads)

## 预装软件清单

开发环境启动后会安装如下软件到虚拟机中：

| 软件/系统        | 版本                       | 备注                           |
| ---------------- | -------------------------- | ------------------------------ |
| Vagrant Box 镜像 | `bento/rockylinux-9`       | 基础镜像                       |
| OpenJDK          | 8                          |                                |
| Apache Maven     | 3.9.5                      |                                |
| Git              | 2.29.3                     | 版本控制                       |
| Podman           | 4.4.1                      | 容器运行时                     |
| Podman Compose   | 1.0.6                      | 容器编排工具                   |
| Node.js          | 20.9.0                     | 由置备器 `frontend tools` 提供 |
| npm              | 10.2.4                     | 由置备器 `frontend tools` 提供 |
| Lerna            | 基于 Node 版本安装的最新版 | 由置备器 `frontend tools` 提供 |
| Yarn             | 基于 Node 版本安装的最新版 | 由置备器 `frontend tools` 提供 |

容器化置备器 `base services` 将启动以下基础服务：

| 服务  | 版本                         | 备注                          |
| ----- | ---------------------------- | ----------------------------- |
| mysql | 5.7                          | 由置备器 `base services` 提供 |
| redis | 4-alpine                     | 由置备器 `base services` 提供 |
| minio | RELEASE.2019-10-12T01-39-57Z | 由置备器 `base services` 提供 |

## 一键启动

```bash
$ vagrant up
```

## 置备器

当前的开发环境提供了几个常用的置备器（Provisioner）来按需执行特定的任务。开发环境通过 `vagrant up` 启动成功之后，就可以通过 `vagrant provision --provision-with <provisioner>` 来运行置备器。下面来逐个介绍一下。

### 1. base services

该置备器用来以容器化的方式、通过 Docker Compose 来启动基础服务，包括 `mysql` ，`redis` 和 `MinIO`。 用户可以在 `etc/basesvc/docker-compose.yaml` 中查看详细的定义。启动置备器的命令如下：

```bash
$ vagrant provision --provision-with "base services"
```

### 2. health check

该置备器用于在置备器 `base services` 执行完之后，查看服务的启动和运行状态。检查的原理实际上就是调用了 `podman-compose ps` 命令。运行该置备器的命令如下：

```bash
$ vagrant provision --provision-with "health check"
```

得到如下类似的检查结果：

```
Name               Command                  State                     Ports
-----------------------------------------------------------------------------------------
minio   /usr/bin/docker-entrypoint ...   Up (healthy)   0.0.0.0:9000->9000/tcp
mysql   docker-entrypoint.sh mysqld      Up             0.0.0.0:3306->3306/tcp, 33060/tcp
redis   docker-entrypoint.sh redis ...   Up             0.0.0.0:6379->6379/tcp
```

### 3. frontend tools

该置备器用户安装前端工具 Node, Yarn 和 Lerna，命令如下：

```bash
$ vagrant provision --provision-with "frontend tools"
```

## 进入开发环境

```bash
$ vagrant ssh
$ cd /devbox
```

