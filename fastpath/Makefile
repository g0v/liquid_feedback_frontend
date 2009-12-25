getpic: getpic.c
	cc -g -Wall -o getpic getpic.c -I `pg_config --includedir` -L `pg_config --libdir` -lpq -Wl,-rpath,`pg_config --libdir`

clean::
	rm -f getpic
