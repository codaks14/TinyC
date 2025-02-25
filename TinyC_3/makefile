all:
	flex TinyC3_22CS10005_22CS10065.l
	yacc -d TinyC3_22CS10005_22CS10065.y
	g++ TinyC3_22CS10005_22CS10065_translator.cpp

run: all
	./a.out	<TinyC3_22CS10005_22CS10065_test1.c > TinyC3_22CS10005_22CS10065_quads1.out
	./a.out	<TinyC3_22CS10005_22CS10065_test2.c > TinyC3_22CS10005_22CS10065_quads2.out
	./a.out	<TinyC3_22CS10005_22CS10065_test3.c > TinyC3_22CS10005_22CS10065_quads3.out
	./a.out	<TinyC3_22CS10005_22CS10065_test4.c > TinyC3_22CS10005_22CS10065_quads4.out
	./a.out	<TinyC3_22CS10005_22CS10065_test5.c > TinyC3_22CS10005_22CS10065_quads5.out

clean:
	rm -f lex.yy.c a.out y.tab.c y.tab.h TinyC3_22CS10005_22CS10065_quads1.out TinyC3_22CS10005_22CS10065_quads2.out TinyC3_22CS10005_22CS10065_quads3.out TinyC3_22CS10005_22CS10065_quads4.out TinyC3_22CS10005_22CS10065_quads5.out