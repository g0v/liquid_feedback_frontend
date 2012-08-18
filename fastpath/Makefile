getpic: getpic.c
	cc -g -Wall -o getpic getpic.c -I `pg_config --includedir` -L `pg_config --libdir` -lpq -Wl,-rpath,`pg_config --libdir` -D PUBLIC_ACCESS

clean::
	rm -f getpic
