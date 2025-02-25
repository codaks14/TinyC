run: a.out ass3_22CS10005_22CS10065_test.c
	./a.out < ass3_22CS10005_22CS10065_test.c > output.txt

a.out: lex.yy.c ass3_22CS10005_22CS10065.c
	gcc -o a.out ass3_22CS10005_22CS10065.c

lex.yy.c: ass3_22CS10005_22CS10065.l
	lex ass3_22CS10005_22CS10065.l

ass3_22CS10005_22CS10065.c:
	touch ass3_22CS10005_22CS10065.c

clean:
	rm -f a.out lex.yy.c output.txt
