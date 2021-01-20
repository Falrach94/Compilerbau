%{
  typedef union
  {
     const char* text;
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
  
  #define MAX_VAR_COUNT 100
  #define MAX_VAR_LEN 32
  
  typedef struct
  {
     char name[MAX_VAR_LEN];
     double value; 
  } var_t;

  char currentVar[MAX_VAR_LEN];
  
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
		
Assignment 	: VariableName ASSIGNMENT Expression 
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
				      printf("%s was assigned value %f\n", $1.text, $3.value);
				   }
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
            	
VariableName 	: VARIABLE  {
				int len = strlen($1.text);
				
				if(len > MAX_VAR_LEN)
				{
			          printf("Maximum variable name length (%d) exceeded!\n", MAX_VAR_LEN);
				}
				else
				{
				   strcpy(currentVar, $1.text);
				  if(currentVar[len-1] == '\n')
				  {
				    currentVar[len-1] = '\0';
				  }  
				}
				
				$$.text = currentVar;
			    } 
            	
Variable	: VariableName	{
				  int id = findVar($1.text);
				  if(id == -1)
				  {
				     printf("Unkown variable %s!\n", $1.text);
				  }
				  else
				  {
				     $$.value = varTable[id].value;
				  }
				}
            	
Constants	:  PI			{$$.value = 3.14159265;}
		|  'e' 			{$$.value = 2.71828183;}		
            	
Functions	:  SIN '(' Expression ')'	{$$.value = sin($3.value);}
		|  COS '(' Expression ')'	{$$.value = cos($3.value);}
		|  TAN '(' Expression ')'	{$$.value = tan($3.value);}
		|  ABS '(' Expression ')'	{$$.value = abs($3.value);}

%%
int main (void) {
  while (!quit)
    yyparse();
}

int addVar(const char* name)
{
   if(varCount == MAX_VAR_COUNT)
   {
      return -1;
   }
   if(strlen(name) > MAX_VAR_LEN)
   {
      return -2;
   }
      
   strcpy(varTable[varCount].name, name);
   
   varCount++;
   return varCount-1;
}

int findVar(const char* name)
{
   int i;
   for(i = 0; i < varCount; i++)
   {
      if(strcmp(varTable[i].name, name) == 0)
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
