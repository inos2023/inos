# 说明
smake（super make）实现了对buildroot make命令的封装，目的是为了定制buildroot执行环境时可以使用更少的命令输入。

# 安装&卸载
## 安装
在使用smake命令之前推荐先执行`sudo ./tools/smake --install`进行安装。

该命令会将./tools/smake安装到/usr/local/bin目录下。

## 卸载
```
sudo smake --remove
```
该命令会从移除/usr/local/bin/smake命令。

## 重新安装
```
sudo ./tools/smake --reinstall
```
该命令会先移除/usr/local/bin/smake，再将./tools/smake安装到/usr/local/bin目录下。

# .smake.local文件
.smake.local文件是一个json格式的文件用于缓存smake的本地配置信息，目前支持以下集中配置
- OUTPUT
  
  编译后产物的输出路径，默认是${TOPDIR}/output。可以通过修改.smake.local指定为其他路径（相对路径），也可以通过smake O=dir指定（相对路径是基于${TOPDIR}）。

- DOWNLOAD_DIR

  buildroot编译时依赖的tar文件的下载路径，默认是${TOPDIR}/dl。可以通过修改.smake.local指定为其他路径（绝对路径），也可以通过smake BR2_DL_DIR=dir或者smake -d dir或者smake --download指定为其他路径（相对路径是基于${TOPDIR}）。
