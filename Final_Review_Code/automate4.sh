yacc -d -v parser.y
lex lexer.l
gcc lex.yy.c y.tab.c -ll
./a.out < final_input_case4.txt
