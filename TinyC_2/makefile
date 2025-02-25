all:
	yacc -d tinyC2_22CS10005_22CS10065.y
	flex tinyC2_22CS10005_22CS10065.l
	gcc tinyC2_22CS10005_22CS10065.c
run: all
	./a.out < input_22CS10005_22CS10065.c > output_22CS10005_22CS10065.txt
clean:
	rm -f a.out lex.yy.c y.tab.c y.tab.h output_22CS10005_22CS10065.txt