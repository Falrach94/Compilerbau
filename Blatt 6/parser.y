%{
  typedef union
  {
     char* text;
     double value;
  } val_t;
 #define YYSTYPE val_t
  #include "y.tab.h"
  #include <stdio.h>
  #include <stdlib.h>
  #include <math.h>
  #include <string.h>
  int quit=0;

  void printProduction(int productionID);
  int yyerror (char *msg);
  int yylex();
  int findVar(const char* name);
  int addVar(const char* name);
  int fib(int n);
  
  #define MAX_VAR_COUNT 100
  #define MAX_VAR_LEN 32
  
  typedef struct
  {
     char name[MAX_VAR_LEN];
     double value; 
  } var_t;

  char nameTmp[MAX_VAR_LEN];
  
  var_t varTable[MAX_VAR_COUNT];
  int varCount = 0; 
  
%}

%token SIN
%token COS
%token TAN
%token ABS
%token FIB
%token VARIABLE
%token NUMBER
%token QUIT
%token PI
%token ASSIGNMENT
%start Start

%%

Start		:  Expression          {printf ("= %f\n", $1.value);}
            	|  QUIT                {quit = 1;}
		|  Assignment
		
Assignment 	: VARIABLE ASSIGNMENT Expression 
				{
				   int id = findVar($1.text);
				   if(id == -1)
				   {
				      id = addVar($1.text);
				   }
				   if(id == -1)
				   {
				      printf("Maximum number of variables (%d) exceeded!\n", MAX_VAR_COUNT);
				   }
				   else if(id == -2)
				   {
				      printf("Maximum variable name length (%d) exceeded!\n", MAX_VAR_LEN);
				   }
				   else
				   {
				      varTable[id].value = $3.value;
				      printf("%s was assigned value %f\n", varTable[id].name, $3.value);
				   }
				   free($1.text);
				}
		
Expression  	:  Expression '+' Division {$$.value = $1.value + $3.value;}
		|  Expression '-' Division {$$.value = $1.value - $3.value;}
            	|  Division                

Division	:  Product '/' Factor	{$$.value = $1.value / $3.value;}	
		|  Product

Product        	:  Product '*' Factor     {$$.value = $1.value * $3.value;}
            	|  Factor
		 
Factor      	:  '(' Expression ')'  {$$.value = $2.value;}
            	|  NUMBER
            	|  Constants
            	|  Functions
            	|  Variable
            	
Variable	: VARIABLE  {
				int id = findVar($1.text);
				
				if(id == -1)
				{
				   printf("Unkown variable %s!\n", $1.text);
				   yyerrok;
				}
				else if(id == -2)
				{
				   printf("Maximum variable name length (%d) exceeded!\n", MAX_VAR_LEN);
				}
			 	else
			 	{
				   $$.value = varTable[id].value;
				}
				
				free($1.text);
			    }
            	
            	
Constants	:  PI			{$$.value = 3.14159265;}
		|  'e' 			{$$.value = 2.71828183;}		
            	
Functions	:  SIN '(' Expression ')'	{$$.value = sin($3.value);}
		|  COS '(' Expression ')'	{$$.value = cos($3.value);}
		|  TAN '(' Expression ')'	{$$.value = tan($3.value);}
		|  ABS '(' Expression ')'	{$$.value = abs($3.value);}
		|  FIB '(' Expression ')'	{$$.value = fib((int)$3.value);}

%%
int main (void) {
  while (!quit)
    yyparse();
}

//https://www.geeksforgeeks.org/c-program-for-fibonacci-numbers/
int fib(int n)
{
 
    int a = 0, b = 1, c, i; 
    if (n == 0) 
        return a; 
    for (i = 2; i <= n; i++) { 
        c = a + b; 
        a = b; 
        b = c; 
    } 
    return b;  
}

int addVar(const char* name)
{
   int len = strlen(name); 
   if(varCount == MAX_VAR_COUNT)
   {
      return -1;
   }
   if(len > MAX_VAR_LEN)
   {
      return -2;
   }
      
   strcpy(varTable[varCount].name, name);
   
   if(name[len-1] == '\n')
   {
      varTable[varCount].name[len-1] = '\0';
   }   
   varCount++;
   return varCount-1;
}

int findVar(const char* name)
{
   int len = strlen(name);

   if(len > MAX_VAR_LEN)
   {
      return 2;
   }

   strcpy(nameTmp, name);
   
   //workarround
   if(nameTmp[len-1] == '\n')
   {
      nameTmp[len-1] = '\0';
   }
   

   int i;
   for(i = 0; i < varCount; i++)
   {
      if(strcmp(varTable[i].name, nameTmp) == 0)
      {
      	 return i;
      }
   }
   return -1;
}


/* We (I) need this function as it is not contained in the default libraries that come
 * with lex/yacc on my distribution.
 */
int yyerror (char *msg) {

  return fprintf (stderr, "Error: %s\n", msg);
}
