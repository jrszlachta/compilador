$DEPURA=1

compilador: lex.yy.c y.tab.c compilador.o compilador.h
	gcc lex.yy.c compilador.tab.c compilador.o list.o -o compilador -ll -ly -lc

lex.yy.c: compilador.l compilador.h
	flex compilador.l

y.tab.c: compilador.y compilador.h
	bison compilador.y -d -v

compilador.o : compilador.h compiladorF.c list.o
	gcc -c compiladorF.c list.o -o compilador.o

list.o: list.c
	gcc -c list.c -o list.o

clean :
	rm -f compilador.tab.* lex.yy.c *.output
