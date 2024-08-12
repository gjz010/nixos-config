#! @bash@/bin/sh
PATH=@coreutils@/bin:@procps@/bin:@bubblewrap@/bin:@electron@/bin:@lsb_release@/bin
wechat_pid=`pidof wechat-uos`
if test $wechat_pid ;then
    kill -9 $wechat_pid
fi
bwrap --dev-bind / / \
    --bind @out@/usr/share/wechat-uos/var/ /var/ \
    electron @out@/usr/lib/wechat-uos "$@"
