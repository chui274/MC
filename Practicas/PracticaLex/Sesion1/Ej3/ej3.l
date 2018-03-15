/* Crear una plantilla Lex para encontrar:
    Comentarios en un fichero con codigo fuente C++
 */


                /*----- Sección de Declaraciones --------------*/
%{

#include <stdio.h>
int nc,ni;
void escribir_datos (int dato1, int dato2);
%}



%x C_COMMENT

%x L_COMMENT

              /*----- Sección de Reglas --------------*/

%%

"/*"            { BEGIN(C_COMMENT); ni++; }

<C_COMMENT>"*/" { BEGIN(INITIAL); }

<C_COMMENT>.    {  }

"//"            { BEGIN(L_COMMENT); nc++; }

<L_COMMENT>\n   { BEGIN(INITIAL); }

<L_COMMENT>.    {  }



%%

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

  ni = nc = 0;
  yylex ();   
  escribir_datos(ni,nc);

  return 0; 
}

void escribir_datos (dato1,dato2)
{
  printf ("Comentarios_encontrados=%d\tBarras_encontradas=%d\n",dato1,dato2);
}
 