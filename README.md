# 本地开发环境 (devbox)

`devbox` 是一个可以在本地快速启动用于本地开发的虚拟机模板，可提供容器化环境、Java后端和前端编译工具等。开发人员可以得到一个与服务器环境一致的本地开发环境。

项目具有以下特点：

1. 一致性体验：本项目所解决的核心痛点，让本地开发环境与生产环境一致，帮开发人员从繁琐的环境搭建中解放出来
2. 国内加速器：预配置 DNS 以及国内仓库和软件源



## 先决条件

本项目基于 Vagrant 和 VirtualBox 搭建，所以开发人员还是需要一些少量的软件安装工作。

- Vagrant： [Vagrant | HashiCorp Developer](https://developer.hashicorp.com/vagrant)

- VirtualBox：[Downloads – Oracle VM VirtualBox](https://www.virtualbox.org/wiki/Downloads)



## 预装软件清单

开发环境启动后会安装如下软件到虚拟机中：

| 软件/系统        | 版本                         | 备注                                             |
| ---------------- | ---------------------------- | ------------------------------------------------ |
| Vagrant Box 镜像 | `bento/rockylinux-9`         | 基础镜像，提供 Rocky Linux 9 操作系统            |
| OpenJDK          | 8                            |                                                  |
| Apache Maven     | 3.9.5                        |                                                  |
| Git              | 2.29.3                       | 版本控制                                         |
| CRI              | N/A                          | 容器运行时: docker 或者 podman                   |
| Compose          |                              | 容器编排工具：docker compose 或者 podman compose |
| Node.js          | 20.9.0                       | 前端工具                                         |
| Lerna            | 基于 Node 版本安装的最新版   | 前端软件包管理工具                               |
| Yarn             | 基于 Node 版本安装的最新版   | 前端软件包管理工具                               |
| MySQL            | 5.7                          | 由 `base services` 置备器提供                    |
| Redis            | 4-alpine                     | 由 `base services` 置备器提供                    |
| MinIO            | RELEASE.2019-10-12T01-39-57Z | 由 `base services` 置备器提供                    |

## 配置选项

devbox 中所安装的所有基础软件都可通过配置文件来控制是否要安装，配置文件路径为 `etc/devbox.properties`，支持的选项及说明如下表所示。默认选项是全部禁用的，开发人员按需更改选项，如需启用，将选项值从 `false` 改为 `true` 即可。

> 提示：`true` 代表安装，`false` 代表卸载。

| 选项                         | 类型   | 含义                                            | 默认值      |
| ---------------------------- | ------ | ----------------------------------------------- | ----------- |
| logging.level                | 字符串 | 日志级别，可选值有`info`, `verbose` ,`debug`    | info        |
| setup.host.enabled           | 布尔   | 是否配置主机名称                                | false       |
| setup.host.name              | 字符串 | 主机名称                                        | example.com |
| installer.git.enabled        | 布尔   | 是否安装 `Git`                                  | false       |
| installer.openjdk.enabled    | 布尔   | 是否安装 `Open JDK`                             | false       |
| installer.epel.enabled       | 布尔   | 是否安装 `EPEL`                                 | false       |
| installer.maven.enabled      | 布尔   | 是否安装 `Maven`                                | false       |
| installer.frontend.enabled   | 布尔   | 是否安装 `前端工具`，包括 `npm`，`yarn`,`lerna` | false       |
| installer.container.enabled  | 布尔   | 是否安装容器运行时                              | false       |
| installer.containert.runtime | 字符串 | 容器运行时：podman 或者 docker                  | docker      |

以上选项既可以在一键启动命令 `vagrant up` 之前配置，也可以在其执行之后配置。在调整完之后，运行 `vagrant provision` 命令以生效配置。

## 一键启动

启动命令很简单，按照 Vagrant 官方建议，只需要执行 `vagrant up` 即可一键启动，命令如下：

```bash
$ vagrant up
```

> 提示：初次运行时由于开发人员本地还未下载任何 Vagrant 基础镜像文件，因此初次运行时会花费更多的时间来下载基础镜像。此处暂无国内环境下的提速方法，所以此时体验不佳。但随后的初始化过程由于使用了国内加速镜像站，速度上会有保障。

安装过程中会输出日志，最后会输出所有已安装成功的软件版本清单。在所有配置项均启用的时候，日志内容大致如下：

```shell
default: [INFO] Gathering facts for networks...
default: [INFO] Setting up machine hosts...
default: [INFO] Gathering facts for networks...
default: [INFO] Resolving dns...
default: [INFO] Accelerating base repo...
default: [INFO] Making cache. This may take a few seconds...
default: [INFO] Installing base packages that may take some time...
default: [INFO] Accelerating python pip...
default: [INFO] Setting up environment for TZ...
default: [INFO] Setting up environment for PATH...
default: [INFO] Setting up envionment for JAVA_HOME...
default: [INFO] Setting up epel repo...
default: [INFO] Accelerating epel repo...
default: [INFO] Making cache. This may take a few seconds...
default: [INFO] Accelerating maven repo...
default: [INFO] Setting up environment for MAVEN_HOME...
default: [INFO] Setting up environment for PATH...
default: [INFO] Installing podman...
default: [INFO] Installing podman compose as user vagrant...
default: [INFO] Accelerating container registry...
default: [INFO] Installing node and npm...
default: [INFO] Setting up environment for PATH...
default: [INFO] Accelerating npm registry...
default: [INFO] Installing yarn and lerna...
default: [INFO] Installation complete! Wrap it up...
default: CATEGORY          NAME          VALUE
default: ----------------  ----          -----
default: PROPERTY          MACHINE_OS    Rocky Linux release 9.2 (Blue Onyx)
default: PROPERTY          MACHINE_IP    192.168.133.100
default: PROPERTY          USING_DNS     8.8.8.8,114.114.114.114
default: ----------------  ----          -----
default: SOFTWARE VERSION  GIT           2.39.3
default: SOFTWARE VERSION  EPEL          epel-release.noarch.9-7.el9
default: SOFTWARE VERSION  OPENJDK       1.8.0_392
default: SOFTWARE VERSION  MAVEN         3.9.5
default: SOFTWARE VERSION  PYTHON3       3.9.16
default: SOFTWARE VERSION  PIP3          21.2.3
default: SOFTWARE VERSION  PODMAN        4.6.1
default: SOFTWARE VERSION  NODE          v20.9.0
default: SOFTWARE VERSION  NPM           10.2.5
default: SOFTWARE VERSION  YARN          1.22.21
default: SOFTWARE VERSION  LERNA         8.0.1
```

## 置备器

当前的开发环境提供了几个常用的置备器（Provisioner）来按需执行特定的任务。开发环境通过 `vagrant up` 启动成功之后，就可以通过 `vagrant provision --provision-with <provisioner>` 来运行置备器。下面来逐个介绍一下。

### 1. base services

该置备器用来以容器化的方式、通过  `Compose`  来启动基础服务，包括 `mysql` ，`redis` 和 `MinIO`，服务组件版本如下：

| 服务  | 版本                         |
| ----- | ---------------------------- |
| mysql | 5.7                          |
| redis | 4-alpine                     |
| minio | RELEASE.2019-10-12T01-39-57Z |

你也可以在 `etc/basesvc/docker-compose.yaml` 中查看详细的定义，包括默认的数据库用户名和密码等等。启动置备器的命令如下：

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

## License

[Apache-2.0](LICENSE)

