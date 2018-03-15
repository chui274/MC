/*Crear una plantilla Lex para encontrar:
 -Direcciones de correo electronico y de paginas web en un fichero texto*/
                /*----- Sección de Declaraciones --------------*/
%{
#include <stdio.h>

int  nc, np;
void escribir_datos (int dato1, int dato2);
%}

/*minuscula       [a-z]*/
/*mayuscula       [A-Z]*/
/*numero          [0-9]*/

palabra         [^\t\n]+
correo          {palabra}@{palabra}.{palabra}+
paginaweb       [www].{palabra}.{palabra}+

%%
                 /*----- Sección de Reglas ----------------*/ 

{correo}        { nc ++; printf ("Correo encontrado: %s", yytext); }
{paginaweb}   	{ np ++; printf ("Web encontrada: %s", yytext); }


%%   
                /*----- Sección de Procedimientos --------*/ 

int main (int argc, char *argv[])
{   
  if (argc == 2)   
  {     
    yyin = fopen (argv[1], "rt");     

    if (yyin == NULL)     
    {       
      printf ("El fichero %s no se puede abrir\n", argv[1]);       
      exit (-1);     
    }   
  }   
  else yyin = stdin;   

  nc = np = 0;
  yylex ();   
  escribir_datos(nc,np);

  return 0; 
}

void escribir_datos (int dato1, int dato2)
{
  printf ("Num_correos=%d\tNum_paginas=%d\n",dato1,dato2);   
}
 
