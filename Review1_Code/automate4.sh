yacc -d parser.y
lex lexer.l
gcc lex.yy.c y.tab.c -ll
./a.out < invalid_input3.txt
