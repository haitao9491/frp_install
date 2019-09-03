# frp_install
## 文件展示：
[file & PATH]

>工作目录:/opt/frp/(将frp.tar.gz放到/opt/frp/路径下，解压后产生如下三类文件)

[workdir]

>bin:存放frps/frpc可执行程序及自启动方式

>etc:存放frps/frpc配置文件(除01_configfile外其他文件自动生成)

>instal.sh:执行sh install.sh命令自动生成frps/frpc配置文件到etc目录下(必须提前在etc/01_configfile中配置frp规则)
