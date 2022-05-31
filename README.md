依露Linux系统相关的一些配置

### 系统选择
经过一些实验，深度（Deepin）桌面版符合我们的系统需求。

### 开机独占系统
按如下步骤修改：

1. 运行
```bash
systemctl set-default multi-user.target
```

2. 修改  /etc/systemd/system/getty.target.wants/getty@tty1.service 实现root自动登录
修改这一行为

```bash
“ExecStart=-/sbin/agetty -a root %I $TERM”
```

3. 在/root/.profile里添加如下内容：
```bash
rm -rf /tmp/.X0-lock
isXrunning=`ps ax |grep "X :0" |grep -v "grep"|wc -l`
if [ $isXrunning -eq 0 ]; then
# 提前把编译好的程序放在正确的位置，比如/root目录下
/usr/bin/xinit /root/opfysiocare.AppImage --no-sandbox -- /usr/bin/X :0  #程序路径最好没有空格
fi
```

### 开/关机动画

放在plymouth目录下了，相关的脚本也改好了。

1. 将yilu_1目录拷贝到 `/lib/plymouth/themes/`

2，具体操作步骤参考：

https://connectwww.com/how-to-install-plymouth-themes-in-ubuntu-customize-the-boot-splash-screen-in-ubuntu/60731/

（具体步骤我现在不能试）

### 系统拷贝

脚本参考installer目录下的脚本，如果看不懂，建议就别用这个方法了，还不如一台一台的重装。
