#!/bin/sh

#cgroup directory umount
grep "/sys/fs/cgroup/" /proc/mounts | grep -v systemd | \
                                              awk '{print $2}' > all_cgroup
while read dir; do
	cd $dir
	for line in `find -type d | grep -v '^.$' | sort -r`; do
		cd $line
		while read pid; do
			echo $pid > $dir/tasks
		done < tasks
		cd - > /dev/null
		rmdir $line
		if [ $? -ne 0 ]; then
			cat $line/tasks
			rm -f $line/tasks
			rmdir $line
		fi
	done
	cd ../ > /dev/null
	umount $dir
done < all_cgroup0
