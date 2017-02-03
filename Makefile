all:
	mkdir -p bin/
	lsc -o bin/ -bc src/sa-learn-nicely.ls
	cp src/sa-learn-pipe-file.sh bin/
	chmod 755 bin/*.sh
