%{
  typedef union
  {
     char* text;
     double value;
  } val_t;
 #define YYSTYPE val_t
  #include "y.tab.h"
  //extern double yylval;
%}

varLetter [a-zA-Z]
digits [0-9]+
%%

sin		{return SIN;}
cos		{return COS;}
tan		{return TAN;}
abs		{return ABS;}
fin		{return FIB;}
pi		{return PI;}

[ ]*:=[ ]*	{return ASSIGNMENT;}

[a-zA-Z]+[a-zA-Z0-9]* {
		yylval.text = yytext;
		return VARIABLE;
		}

{digits}      {	
		yylval.value = atof(yytext);
                return NUMBER;
              }
{digits}[.]{digits}      {	
		yylval.value = atof(yytext);
                return NUMBER;
              }

(.quit)|(exit) {	return QUIT;
              }



.             {	/*pass along other characters */
                return yytext[0];
              }

\n            {	/*tell yacc that the end of the input is reached*/
				return 0;
              }

%%
