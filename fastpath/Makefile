getpic: getpic.c
	cc -g -Wall -o getpic getpic.c -I /usr/pkg/include/ -I /usr/include/postgresql -L /usr/pkg/lib -L /usr/lib/postgresql -lpq -Wl,-rpath,/usr/pkg/lib -Wl,-rpath,/usr/lib/postgresql

clean::
	rm -f getpic
