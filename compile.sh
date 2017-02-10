

# g++ testmain.cpp  -o test   -I/usr/local/include/luajit-2.0  -lluajit-5.1 -fPIC

g++ test_h3pgmHandler.cpp  -o h3pgmHandler.out   -I/usr/local/include/luajit-2.0  -lluajit-5.1 -fPIC -std=gnu++11

#valgrind --tool=memcheck --leak-check=full ./h3pgmHandler.out
