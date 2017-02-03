all:
	mkdir -p bin/
	node_modules/livescript/bin/lsc -o bin/ -bc src/sa-learn-nicely.ls
	cp src/sa-learn-pipe-file.sh bin/
	cp src/sa-learn-nicely bin/
	chmod 755 bin/*.sh

install:
	ln -s /opt/sa-learn-nicely/example-systemd-unit/sa-learn-nicely.service /etc/systemd/system/

