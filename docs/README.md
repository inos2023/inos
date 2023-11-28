## 说明
该工程的目录结构采用buildroot的是br2-external tree模式，是将INOS的工程放在buildroot工程之外，但是为了INOS工程和buildroot工程不至于太分散，把buildroot的工程作为INOS工程的一个子目录。该工程主要是一些配置和编译脚本，源码需要通过repo工具下载。

## 源码下载
- 安装repo

[repo的使用文档](https://source.android.com/docs/setup/create/repo?hl=zh-cn)。
```
curl https://mirrors.tuna.tsinghua.edu.cn/git/git-repo > /bin/repo
chmod a+x /bin/repo
```

- 下载
```
# 切换REPO_URL为清华镜像
export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo'

# 初始化代码仓
repo init -u ssh://git@gitlab.dros-cluster.com:10022/inos/inos.git

# 下载所有源码
repo sync -c
```
若要下载指定版本v0.2.0,如下：
```
repo init -u ssh://git@gitlab.dros-cluster.com:10022/inos/inos.git -b v0.2.0
```

- 开发流程
  使用repo的开发流程可参考[该文档](https://source.android.com/docs/setup/create/coding-tasks?hl=zh-cn)

    - repo start切换到项目的开发分支，例如```repo start master inos```
    - 修改文件
    - git add
    - git commit
    - 进入到对应的项目，执行git push


## 编译方式
> 需要在根目录下编译

第一次编译需要先执行```./envsetup.sh```，可以选择需要编译的目标板，比如当前我们使用的是ft2004_buildroot,这里选择2,如果是使用qemu_x86调试环境选择5.并且会把对应的config文件拷贝到buildroot，kernel和uboot中。

```
This script is executed directly...
Top of tree: /home/hefan/Phytium/inos-embeded

You're building on Linux
Lunch menu...pick a combo:

0. non-inos boards
1. barboard
2. hanwei_ft2004_buildroot
3. hanwei_ft2004_initrd
4. inos
5. qemu_x86
   Which would you like? [0]:
  
```

buildroot下make命令的用法可参考[该文档](https://buildroot.org/downloads/manual/manual.html#make-tips)。

对于嵌入式开发者需要全量编译执行```./build.sh all```，编译后默认的输出目录是在buildroot/output下，编译之后会在buildroot/output/images下生成操作系统的镜像文件。
对于应用开发者需要执行系统编译```./build.sh buildroot```,编译完所有依赖之后可以编译自己的app。

## 编译指令
见[manual_for_new_board.md](./docs/manual_for_new_board.md)文档。

## 添加新工程
见[manual_for_new_board.md](./docs/manual_for_new_board.md)文档。

## 目录结构
详细见[工程结构](./docs/%E5%B7%A5%E7%A8%8B%E7%BB%93%E6%9E%84.md)文档。
