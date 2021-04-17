#get size of directories
du -sch .[!.]* * |sort -h
du -hs */ | sort -rh
du -h */  --max-depth=1

#search for text in files
find . -type f -exec grep -H 'texttosearchfor' {} \; 

#change password expiration to not expire
chage -I -1 -m 0 -M 99999 -E -1 username


#list files from a compressed tar file
tar -ztvf archive.tar.gz
tar -zxf archive.tar.gz ./path/to/file.inside

#files between two dates
find . -type f -name "*" -newermt 2018-04-01 ! -newermt 2018-04-30


#fix the nfs mounts not being accessible
lsof -a +L1 /data/dir01/pgdb-backup
df -h
mount
crontab -l
vi /etc/exports
df -h
systemctl restart nsfd
systemctl restart nfs-server
mount /dev/sdc1

#determine who is logged in and log them out
who (list logged in sessions)
pkill -9 -t pts/0  (log them out)

