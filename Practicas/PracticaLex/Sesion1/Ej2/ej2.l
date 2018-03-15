/* Crear una plantilla Lex para encontrar:
    Fechas, Numeros de telefono, Matriculas, Codigos postales y NIF en otro fichero
 */

                /*----- Sección de Declaraciones --------------*/
%{
#include <stdio.h>

int  np, nm, nd, ncp, nn;
void escribir_datos (int dato1, int dato2, int dato3, int dato4, int dato5);
%}

mayuscula   [A-Z]
minuscula   [a-z]
palabra     [mayuscula|minuscula]
numero      [0-9]
separador   [".""\""-""/"]

telefono         [69]{numero}{8}
fecha            {numero}{2}{separador}{numero}{2}{separador}{numero}{4}
matricula        ({mayuscula}{2}-?{numero}{4}-?{mayuscula}{2}|{numero}{4}-?{mayuscula}{3})
CP               [0-5]{numero}{4}
NIF              {numero}{8}-?{mayuscula}

%%
                 /*----- Sección de Reglas ----------------*/ 

{telefono}       { np++; printf ("Telefono encontrado: %s", yytext);}
{fecha}          { nd++; printf ("Fecha encontrada: %s", yytext); }
{matricula}      { nm++; printf ("Matricula encontrada: %s", yytext);}
{CP}             { ncp++; printf ("CP encontrado: %s", yytext);}
{NIF}            { nn++; printf ("NIF encontrado: %s", yytext);}

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

  np = nn = nm = ncp = nd = 0;
  yylex ();   
  escribir_datos(nd,np,nm,ncp,nn);

  return 0; 
}

void escribir_datos (dato1, dato2, dato3, dato4, dato5)
{
  printf ("Num_fechas=%d\tNum_telefono=%d\tNum_matriculas=%d\tNum_CP=%d\tNum_NIF=%d\n",dato1,dato2,dato3,dato4,dato5);
}
 
