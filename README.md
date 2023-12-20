# Local Development Box (devbox)

本项目可以在本地快速启动用于本地开发的基础虚拟机模板，可提供容器化环境、Java后端和前端编译工具等。开发人员可以得到一个与服务器环境一致的本地开发环境，彻底解决初次搭建开发环境所经历的痛苦与无奈。

项目具有以下特点：

1. 环境一致性体验：本项目所解决的核心痛点，让本地开发环境与生产环境一致，帮开发人员从繁琐的环境搭建中解放出来
2. 国内加速器：基于国内网络环境进行充分优化，下载安装速度可观
3. 预装 EPEL：预装企业级仓库 `epel` ，可安装额外的企业级软件
4. 容器化支持：预装 Podman 和 Podman Compose，容器化启动软件随心所欲
5. 预装软件丰富：详见预装软件清单

## 前置软件安装

本项目是一个基于 Vagrant 和 VirtualBox 的搭建的，所以开发人员还是需要一些少量的软件安装工作，安装指引参照官网。

安装最新版 Vagrant： [Vagrant | HashiCorp Developer](https://developer.hashicorp.com/vagrant)

安装虚拟机软件 VirtualBox：[Downloads – Oracle VM VirtualBox](https://www.virtualbox.org/wiki/Downloads)

## 预装软件清单

开发环境启动后会安装如下软件到虚拟机中：

| 软件/系统        | 版本                         | 备注                          |
| ---------------- | ---------------------------- | ----------------------------- |
| Vagrant Box 镜像 | `bento/rockylinux-9`         | 基础镜像                      |
| OpenJDK          | 8                            |                               |
| Apache Maven     | 3.9.5                        |                               |
| Git              | 2.29.3                       | 版本控制                      |
| Podman           | 4.4.1                        | 容器运行时                    |
| Podman Compose   | 1.0.6                        | 容器编排工具                  |
| Node.js          | 20.9.0                       | 前端工具                      |
| npm              | 10.2.4                       | 前端软件包管理工具            |
| Lerna            | 基于 Node 版本安装的最新版   | 前端软件包管理工具            |
| Yarn             | 基于 Node 版本安装的最新版   | 前端软件包管理工具            |
| MySQL            |                              | 由 `base services` 置备器提供 |
| Redis            | 4-alpine                     | 由 `base services` 置备器提供 |
| MinIO            | RELEASE.2019-10-12T01-39-57Z | 由 `base services` 置备器提供 |

## 配置选项

`devbox` 中所安装的所有基础软件都可通过配置文件来控制是否要安装，配置文件路径为 `etc/devbox.properties`，支持的选项及说明如下表所示：

| 选项                          | 类型   | 含义                                               | 默认值  |
| ----------------------------- | ------ | -------------------------------------------------- | ------- |
| `logging.level`               | 字符串 | 日志打印级别，可选值有`info`, `verbose` 和 `debug` | `info`  |
| `setup.hosts.enabled`         | 布尔   | 是否配置域名和 IP 映射关系                         | `false` |
| `installer.git.enabled`       | 布尔   | 是否安装 `Git`                                     | `true`  |
| `installer.pip3.enabled`      | 布尔   | 是否安装 `Python3` 和 `pip3`                       | `true`  |
| `installer.openjdk.enabled`   | 布尔   | 是否安装 `Java`                                    | `true`  |
| `installer.epel.enabled`      | 布尔   | 是否安装 `EPEL`                                    | `true`  |
| `installer.maven.enabled`     | 布尔   | 是否安装 `Maven`                                   | `true`  |
| `installer.container.enabled` | 布尔   | 是否安装 `容器运行时`，`Podman` 和 `Podman Compose`            | `true`  |
| `installer.frontend.enabled`  | 布尔   | 是否安装 `前端工具`，包括 `npm`，`yarn`,`lerna`    | `true`  |

以上选项既可以在一键启动命令 `vagrant up` 之前配置，也可以在其执行之后配置，需要注意以下两点：

1. 软件一但安装，禁用安装选项也不会将其从虚拟机中卸载
2. 修改完配置项之后，可以运行 `vagrant provision` 生效配置

## 一键启动

启动命令很简单，按照 Vagrant 官方建议，只需要执行 `vagrant up` 即可一键启动，命令如下：

```bash
$ vagrant up
```

> 提示：初次运行时由于开发人员本地还未下载任何 Vagrant 基础镜像文件，因此初次运行时会花费更多的时间来下载基础镜像。此处暂无国内环境下的提速方法，所以此时体验不佳。但随后的初始化过程由于使用了国内加速镜像站，速度上会有保障。

安装过程中会输出日志，最后会输出所有已安装成功的软件版本清单，日志内容大致如下：

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
default: [INFO] All set! Wrap it up...
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

该置备器用来以容器化的方式、通过 `Podman` 和 `Compose` 来启动基础服务，包括 `mysql` ，`redis` 和 `MinIO`，服务组件版本如下：

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

