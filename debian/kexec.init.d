#! /bin/sh
### BEGIN INIT INFO
# Provides:		kexec
# Required-Start:
# Required-Stop:   	reboot
# X-Stop-After:		umountroot
# Default-Start:	2 3 4 5
# Default-Stop:		6
# Short-Description: Execute the kexec -e command to reboot system
# Description:
### END INIT INFO

PATH=/sbin:/bin:/usr/bin

. /lib/lsb/init-functions

test -r /etc/default/kexec && . /etc/default/kexec
if [ -d /etc/default/kexec.d ] ; then
	for snippet in $(run-parts --list /etc/default/kexec.d) ; do
		. "$snippet"
	done
fi

do_stop () {
	test "x`cat /sys/kernel/kexec_loaded`y" = "x1y" || exit 0
	test -x /sbin/kexec || exit 0

	log_action_msg "Will now restart with kexec"
	# Clear the screen if possible
	printf "\033[;H\033[2J"
        /sbin/kexec -e
        log_failure_msg "kexec failed"
}

case "$1" in
  start)
	# No-op
	;;
  restart|reload|force-reload)
	echo "Error: argument '$1' not supported" >&2
	exit 0
	;;
  stop)
	# Systemd kexec service works on limited system/boot configurations.
	# Instead of relying on it, trigger kexec here if needed
	do_stop
	;;
  *)
	echo "Usage: $0 start|stop" >&2
	exit 3
	;;
esac
exit 0
