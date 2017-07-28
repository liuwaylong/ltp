#!/bin/sh

echo "start umount check ..."
#uname -r | grep -e "3\.1.\.0"
if [ $? -eq 0 ]; then
	echo "start umount ..."
        # cgroup directory umount
        grep "/sys/fs/cgroup/" /proc/mounts | grep -v systemd | \
                                              awk '{print $2}' > all_cgroup
	pwd
	ls -l
	cat all_cgroup
        while read dir; do
                cd $dir
		echo "cd $dir"
		ls -l
                for line in `find -type d | grep -v '^.$' | sort -r`; do
                        cd $line
			echo "cd $line"
                        while read pid; do
                                echo $pid > $dir/tasks
                        done < tasks
                        cd - > /dev/null
                        rmdir $line
			echo "rmdir $line..."
                        if [ $? -ne 0 ]; then
				cat $line/tasks
                                rm -f $line/tasks
                                rmdir $line
                        fi
                done
                cd $ltp_dir
                umount $dir
        done < all_cgroup
        service NetworkManager stop 2> /dev/null
fi
