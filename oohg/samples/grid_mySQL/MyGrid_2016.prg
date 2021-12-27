 
/* 13-01-2007 - Espa�ol  
	Espa�ol  
 Grid for Harbour + Oohg + MySql  
 Trabajo realizado sobre original de Novo Antonio   
         email: novoantonio@hotmail.com  
 Arreglos, Adaptacion y Agregados por Gustavo Carlos Asborno  
       email: gustavo@lahersistemas.com.ar   
 Otros arreglos por Antonio V�zquez.
       email:  avazquezc@telefonica.net   

 Nota:   
	1) Se arreglo bugs en el label de cabecera  
	2) Se agrego DATA aCampo para referenciar Columna del Select  
	3) Se agrego METHOD ejecutar(), para tener un ONCHANGE   
	4) Se agrego METHOD stabilize(), para el metodo Refresh  
	5) Se quit� METHOD MySeek, porque no me resultaba funcional  

 Notas:
  0) No s� si se puede considerar o no una continuaci�n del trabajo, puesto que, partiendo de la misma idea, 
     el desarrollo cambia bastante (al menos en mi opini�n). He preguntado c�mo subirlo y me dicen que debo 
     continuar lo publicado. As� lo hago.
  1) El criterio anterior era cargar el grid en un workarea y a partir de ah�, gestionar todo con ese workarea
     El criterio ahora es hacer la b�squeda y carga en workarea s�lo de los registros que presentar� en pantalla.
     Con ello, se pueden suprimir una serie de METHOD que eran necesarios antes
  2) Modificaci�n de la cabecera para que puedan salir centrados los campos de la cabecera.
  3) Permite alinear cada una de las columnas.
  4) Se suprime el METHOD stabilize al no ser ya necesario
  5) Se suprime el METHOD MySeek porque la b�squeda la hace en cada consulta
  6) Permite la ordenaci�n del Grid en funci�n de hacer un click en la cabecera.   
  7) Bug corregido que desactiva la asignaci�n de teclas cuando se pasa a modificaci�n y/o a�adido de registros
     Cuando Graba o Cancela la modificaci�n, vuelven a estar activadas las teclas Home, Ene, AVP�g, ReP�g, cursores.
  8) Se ha corregido para que cuando se est� modificacndo o a�adiendo un registro, no permita que pinchando con el rat�n en una celda,
     se traslade el control hasta esa fila. Lo que hace es el equivalente a poner el grid en enabled. 
  9) Se ha suprimido el control de barra de desplazamiento. En un futuro se podr� realizar, pero no ser� yo... jeje
 10) Como no hablo ni escribo en ingl�s, he comentado en castellano... si alguien hace el favor de traducirlo, mejor.
 11) He cambiado la definici�n de las variables X, Y. Siempre he trabajado con Y para las ordenadas o filas y X para las abcisas o columnas
            - Y define rows
            - X define cols  
 12) Permite seleccionar los campos por lo que va a realizar la b�squeda. Se indica en la definici�n de la columna. Debajo del grid 
     mostrar� el campo editable para la b�squeda o no. Al pulsar ENTER en el campo montar� la nueva b�squeda. La b�squeda se realiza
     cuando se pulsa <ENTER> en alguno de los campos de b�squeda.            
 13) Permite gestionar m�s de un grid en el mismo formulario.
 14) Permite gestionar dos o m�s grid anidados (el segundo puede depender del primero) 
 15) Simula la funci�n SETFOCUS cuando tiene 2 o m�s grid. Al pulsar o realizar una acci�n sobre un supuesto grid, entiende que obtiene
     el foco, por lo que a partir de ese momento, las teclas de cursores se refieren a ese grid. Tambi�n se obtiene si se pincha en el 
     t�tulo del grid (si encima del grid le pongo un t�tulo) 
 16) Calcula y deja espacio si se quiere poner t�tulo al grid. Se pasa como par�metro en el lugar n� 13
             
	English  
  
 Grid for Harbour + Oohg + MySql  
 I work carried out on original of Novo Antonio   
         email: novoantonio@hotmail.com  
 Arrangements, Adaptation and Added for Gustavo Carlos Asborno  
       email: gustavo@lahersistemas.com.ar   
 He/she notices:   
	1) you fixes bugs in the head label  
	2) one adds it DATES I camp to index Column of the Select  
	3) one adds METHOD to execute (), to have an ONCHANGE   
	4) one adds METHOD stabilize (), for the method Refresh  
*/	
*------------------------------------------------------------------------------
#include "HBClass.Ch"
#include "oohg.ch"
#Define RCARRO Chr(13)+Chr(10)
#define WM_MBUTTONDOWN 519 // 0x0207
#define WM_MBUTTONUP 520 // 0x0208

CLASS MyGrid FROM TControl
   DATA yyRow                  INIT 0     && Coordenada vertical
   DATA xxCol                  INIT 0     && Coordenada horizontal
   DATA Y                      INIT 0     && Coordenada vertical variable
   DATA X                      INIT 0     && Coordenada horizontal variable
   DATA WorkArea               INIT ""    && Carga de las filas en memoria
   DATA Form1                  INIT ""    && Nombre del Formulario
   DATA Height                 INIT 250   && Altura del Formulario
   DATA nOrden                 INIT 1     && Columna por la que se ordenar� la consulta
   DATA Width                  INIT 0     && Ancho del Grid
   DATA MaxRows                INIT 22      && N� de l�neas encontradas en la consulta (m�x nLineasTotGrid,  pero puede ser menor)
   DATA MaxCols                INIT 22      && N� de columnas
   DATA aHeads                 INIT {}      && Array con las Cabeceras
   DATA aFields                INIT {}      && Array con los campos de las columnas
   DATA HSpacing               INIT 1       && Pixeles de espacio entre columnas
   DATA VSpacing               INIT 1       && Pixeles de espacio entre filas
   DATA HeightCell             INIT 15      && Altura en pixeles de la celda
   DATA WidthCell              INIT {}      && Array con la longitud de la columna (x)
   DATA aAlinea                INIT {}      && Array que indica c�mo debe alinear la columna  (0,1,2)
   DATA aBuscaCampo            INIT {}      && Array que indica si va a filtrar/buscar por ese campo (.t.,.f.)
   DATA aConsulta              INIT {}      && Array que montar� la consulta
   DATA aUpperBusca            INIT {}      && Array que establece si la b�squeda es s�lo en may�sculas
   DATA aOrdenConsulta         INIT {}      && Array que establece el orden de las consultas
   DATA aPicture               INIT {}      && Array que establece el formato de vista PICTURE
   DATA aFunciones             INIT {}      && Array que contiene las funciones que llamar� para a�adir, editar y borrar
   DATA Grid                   INIT "" && Nombre del Grid
   DATA FontCell               INIT "Arial"    &&Comic Sans MS"     && "Comic San" && Fuente de la celda
   DATA SizeCell               INIT 09      && Tama�o de la celda
   DATA ColorCell              INIT {0,0,0} && Color de la celda
   DATA BackColorCell          INIT {230, 230, 230}
   DATA AlternateBackColorCell INIT {255, 255, 255}
   DATA FontColorHead          INIT {255,255,255}
   DATA BackColorHead          INIT {0,0,0}
   DATA FontHead               INIT "Arial"      && Fuente de la cabecera
   DATA SizeHead               INIT 09           && Tama�o de la cabecera
   DATA HeightHead             INIT 20           && Altura de la cabecera
   DATA HeightHeadBusca        INIT 20           && Altura de la cabecera de los campos de b�squeda
   DATA BackColorSelect        INIT {0,0,255}
   DATA FontColorSelect        INIT {255,255,255}
   DATA Value                  INIT 1
   DATA nRegScroll             INIT 0    && Muestra el N� de registros totales del scroll (Guarda el n�)
   DATA nRegAct                INIT 1    && N� Registro actual de una b�squeda con respecto al total. Para SCROLLBAR
   DATA aCampo                 INIT {}   && Valores del registro activo
   DATA nSuperior              INIT 0    && L�mite superior por donde empieza el select
   DATA nMaxReg                INIT 0    && N� de Registros encontrados en la b�squeda en la Tabla sin l�mites
                                         && Es el n� de registros que cumplen la condici�n.
   DATA nRegAntHilite          INIT 1    && registro anterior que estaba activo. Para que hilite lo vuelva a su color normal (sin selecci�n)

   DATA nlineastotGrid         INIT 12   && N� de l�neas a mostrar en el Grid
   DATA cConsulta              INIT ""   && Monta la consulta de los campos que se va a realizar
   DATA cOrdenGrid             INIT ""   && Especifica el Orden para la b�squeda. Permite que al pinchar en la cabecera ordene por ese campo

   DATA ShowCamposBusqueda     INIT .t.     && Habilita o no que se pueda buscar/filtrar por campos. Luego, en cada columan indicar� si se busca o no por ese campo

   DATA cConsulta2             INIT ""
   DATA cConsulta3             INIT ""
   DATA lBuscaArriba           INIT .f.    && Indica si los campos de b�squeda van arriba o abajo
   DATA lDISTINCT              INIT .f.    && Indica si la b�squeda es DISTINCT
   DATA nClick                 INIT 0      && Cuenta el n� de click qu ese pulsan
   
   *-Properties of: Navigate Control
   DATA ShowNavigate           INIT .F.     && Muestra botones de navegaci�n
   DATA ShowNavigatederecha    INIT .F.     && Muestra botones de navegaci�n a la derecha en lugar de abajo
   DATA ShowBotones            INIT .t.     && Muestra botones A�ade, Modifica, Borra                                       
   DATA WidtNavigate           INIT 32
   DATA HeightNavigate         INIT 32
   DATA FontNavigate           INIT "Arial"
   DATA SizeFontNavigate       INIT 08
   DATA BackColorNavigate      INIT {170, 170, 190}
   DATA FontColorNavigate      INIT {0,0,240}

   DATA lCadenaFiltraFija      INIT .f.     && Indica si debe filtrar en cada b�suqeda o el filtrado es fijo. Si es .t. ser� el valor de cCadenaFiltraFija
   DATA cCadenaFiltraFija      INIT ""      && Si el campo anterior es .t., siempre filrar� por esta cadena. V�lido para grid dependientes de otros (ej, facturas y albaranes)
   DATA ccadenafiltrada        INIT ""      && Cadena montada en el filtro por el conjuto de campos que va a filtrar/buscar
   DATA lcadenafiltrada        INIT .f.     && Indica si debe filtrar o no en la b�suqeda
   DATA cTabla                 INIT ""      && Nombre de la tabla donde va a realizar la consulta.  

   DATA lbuscadesdeinicio      INIT .f.     && Indica si busca desde principio de la palabra en la b�suqeda
   DATA lbuscaexacta           INIT .f.     && Indica si la busca  es exacta

   DATA PosVSCroll      INIT 0
   DATA lVScroll        INIT .f.
   
   DATA cTituloGrid            INIT ""      && Valor del t�tulo del grid. Calcula espacio y lo quita del alto del grid.

   METHOD New(yRow, xCol, xForm1, xWidh, xHeight, change, xBuscaCampo,xnOrden, xaFunciones, xGrid, xlBuscaArriba, xConsulta3, xcTituloGrid)
   METHOD NewColumn(xTitleCol,xCodeBlock,xSizeCol,xAlinea,xBuscaCampo,xcConsulta, xaUpperBusca, xOrdenConsulta, xPicture)
   METHOD Show()
   METHOD Hilite(yRow)
   METHOD PopulateGrid()
   METHOD Home()
   METHOD End()
   METHOD Prior()
   METHOD Next()
   METHOD Up()
   METHOD Down()
   METHOD Thumb()
   METHOD T_NUEVO             && A�ade un registro a pulsar INSERT
   METHOD T_ENTER             && Modificar el registro actual al pulsar ENTER
   METHOD T_BORRA             && Borra el registro actual al pulsar SUPR
   METHOD ejecutar()
	 METHOD asignaTeclas()     && Habilita o no las teclas (cuando a�ade o modifica hay que desactivar los controles)
	 METHOD OrdenaCab()        && Especifica el orden de las consultas (se modifica cuando se pincha en la cabecera por esa columna)
   METHOD MontaBusqueda()    && Crea la cadena que pasar� a la consulta MySql en el filtrado por los campos de b�squeda. Puede hacer por varios a la vez
                             && es la condici�n de b�squeda o filtrado.
   METHOD MySqlQuery (nsup,nlimite,ldescend) && Realiza la Consulta
   METHOD activa_desactiva(lactivo)  && Activa o no botones
   METHOD VSCRollMovement()
   METHOD grid_activa_desactiva(lactivo)  && Cuando vaya a modificar campos, debo desactivar los campos del grid
   METHOD vaciagrid()         && Llama a la funci�n para vaciar el Grid
   METHOD PulsaUnClick()      && Espera y comprueba si es click o doble click
   METHOD buscaengrid(cQueryBusca,cBuscaCod )  && Busca en el grid un valor.
   METHOD grid_visible(LACTIVO)
ENDCLASS

*--------------------------------------------------------------------------------
METHOD New(yRow, xCol, xForm1, xWidth, xHeight, change, xBuscaCampo,xnOrden, xaFunciones, xGrid, xlBuscaArriba, xConsulta3, xcTituloGrid) CLASS MyGrid
default xGrid TO "Grid"
default xlBuscaArriba TO .f.
default xConsulta3 to ""
default xcTituloGrid to ""

     
    ::yyRow    := yRow
    if xlBuscaArriba
       ::yyRow += 25
    endif

    ::xxCol    := xCol
    ::Form1    := xForm1
*    ::Width    := xWidth
    ::Width    := 0       && Cuando a�ada columnas, sumo el tama�o real de cada columna
    ::Height   := xHeight

    ::cTituloGrid := xcTituloGrid       &&Comprueba si hay t�tulo. Si lo hay reserva 25 pixeles
** NONO
*    if !empty(::cTituloGrid)
*       ::Height -=25
*    endif
    
	  ASSIGN ::OnChange    VALUE change    TYPE "B"
    ::ShowCamposBusqueda   := xBuscaCampo
    ::nOrden := xnOrden
    ::aFunciones := xaFunciones
    if ::afunciones[1]="nada()" .and. ::afunciones[2]="nada()" .and. ::afunciones[3]="nada()"   && Mira si tiene que imprimir los botones
       ::ShowBotones:=.f.
*       ::yyrow += 25
    else
       ::ShowBotones:=.t.
*       ::yyrow += 25
    endif 
    
    ::Grid   := xGrid
    ::lBuscaArriba:=xlBuscaArriba
    ::cConsulta3:=xConsulta3
RETURN self

  *--------------------------------------------------------------------------------
METHOD NewColumn(xTitleCol,xCodeBlock,xSizeCol,xAlinea,xBuscaCampo,xcConsulta, xaUpperBusca, xOrdenConsulta, xaPicture) CLASS MyGrid
default xaUpperBusca to .t.
default xcConsulta to xCodeBlock 
default xOrdenConsulta to xcConsulta
default xaPicture to "@!"
    AADD(::aHeads,      xTitleCol)
    AADD(::aFields,     xCodeBlock)
    AADD(::WidthCell,   xSizeCol)
    AADD(::aAlinea,     xAlinea)
    AADD(::aBuscaCampo, xBuscaCampo)
    AADD(::aConsulta,   xcConsulta)
    AADD(::aUpperBusca, xaUpperBusca)
    AADD(::aPicture, xaPicture)
if xOrdenConsulta= NIL
    AADD(::xOrdenConsulta,   xcConsulta)
else
    AADD(::aOrdenConsulta,   xOrdenConsulta)
endif
    ::cConsulta +=  xcConsulta+","             && Va montando la consulta con los campos que forman cada columna
    ::Width     +=  xSizeCol
RETURN self
 
*--------------------------------------------------------------------------------
*-Dibuja el Control del Grid
*--------------------------------------------------------------------------------
METHOD Show() CLASS MyGrid
*----------------------------
    LOCAL clabel := "", acolor := {}, I := 5, J := 0
    if ::ShowNavigateDerecha=.f.
       IF ::ShowBotones .or. ::ShowNavigate 
          i+=32
       endif
    endif 
    if ::Showcamposbusqueda 
       i+=25
    endif 
     if !empty(::cTituloGrid)
       i+=25
    endif
    ::nlineastotGrid := INT( ( ::Height - ::HeightHead - i ) / ( ::HeightCell + ::HSpacing ) )
    ::MaxRows := ::nlineastotGrid
    ::nSuperior:=0
    ::nMaxReg:=0
    ::Y := ::yyRow
    ::X := ::xxCol

    AADD(::WidthCell,60)
    AADD(::WidthCell,60)

    ::cConsulta := substr(::cConsulta,1,len(::cConsulta)-1)
    ::cOrdenGrid := ::aOrdenConsulta[::nOrden]
    *---------------------------------------------------
    *-Pone T�tulo si existe
    if !empty(::cTituloGrid)    
       cLabel := ::Grid+"LABEL"
       ::Y := ::yyRow -25  + if(::lBuscaArriba, -25, 0)
       DEFINE   LABEL &cLabel 
                PARENT (::Form1)
               	ROW ::y 
                COL ::xxCol 
                HEIGHT 20
                WIDTH len(::cTituloGrid)*12                       && ::Width
                VALUE ::cTituloGrid
                FONTNAME 'MS Sans Serif'
                FONTSIZE 12
                BACKCOLOR aColor
                FONTCOLOR {255,0,0}
                FONTBOLD .T.
	     END LABEL
    endif

    *---------------------------------------------------
    *-Header Table   Cabecera
    ::Y := ::yyRow
    ::MaxCols := LEN(::aFields)
    ::aCampo := ARRAY(::MaxCols)
    FOR J := 1 TO ::MaxCols
      cLabel := "LABEL"+::Grid+"__"+ALLTRIM(STR(0))+"_"+ALLTRIM(STR(J))
      DEFINE LABEL &cLabel
        PARENT (::Form1)
        ROW ::Y
      	COL ::X 
        CENTERALIGN .t.
        ACTION {|| ::ordenacab(),::asignaTeclas(.t.) }
        WIDTH ::WidthCell[J]
        HEIGHT ::HeightHead
        VALUE ::aHeads[J]
        FONTNAME ::FontHead
        FONTSIZE ::SizeHead
        BACKCOLOR ::BackColorHead
        FONTCOLOR ::FontColorHead
      END LABEL
	    
      ::X += ::WidthCell[J] + ::HSpacing

    NEXT
    ::Y += ::HeightHead + ::VSpacing
    *----------------------------------------------------
    ::nsuperior := 0
    ::Value  := 1
    *----------------------------------------------------
    *-Vertical ScrollBar
    if ::lVScroll    
       cLabel := ::grid+"SLIDER"
       @ ::yyrow + ::heightHead, ::x+3 SCROLLBAR &cLabel OF (::Form1);
          WIDTH 17 ;
          HEIGHT ( ::nlineastotGrid * (::HeightCell+::vSpacing)  ) ;
          RANGE 1, ::maxrows ;
          VALUE 1 ;
          LINESKIP 1 ;
          PAGESKIP ::nlineastotGrid ;
          ON TOP (::Home()) ;
          ON BOTTOM (::End()) ;
          ON LINEUP (::up()) ;
          ON LINEDOWN (::Down()) ;
          ON PAGEUP (::Prior()) ;
          ON PAGEDOWN  (::Next()) ;
          AUTOMOVE ;

      cLabel := ::grid+"nregscroll"
      @ ::yyrow + ::heightHead +( ::nlineastotGrid * (::HeightCell+::vSpacing)  ) +1, ::x+3 label &clabel value alltrim(str(::maxrows)) autosize size 7 OF (::Form1)   
 
 *          ON CHANGE ( ocontrol:=getcontrolobject(::grid+"SLIDER",::Form1),::thumb(ocontrol:value));

          
          
*          tooltip 'Reg: '+alltrim(str(::nsuperior+::value))+' de '+alltrim(str(::nMaxReg))+'.' ;
*          ATTACHED 
*          AUTOMOVE ;

*          ON THUMB ( ocontrol:=getcontrolobject(::grid+"SLIDER",::Form1),::thumb(ocontrol:value));
*          ON CHANGE ::VSCROLLMovement() 

*          RANGE 1, ::nlineastotGrid ;
*          ON TRACK thumb() ;
*          ON ENDTRACK thumb()
           
    endif
    *-Body of Table
    FOR I := 1 TO ::nLineasTotGrid
        ::X := ::xxCol
        FOR Jcol := 1 TO ::MaxCols
            cLabel := "LABEL"+::Grid+"__"+ALLTRIM(STR(I))+"_"+ALLTRIM(STR(Jcol))
            aColor := IIF(I % 2 == 0,::AlternateBackColorCell,::BackColorCell)
            DO CASE 
               CASE ::aAlinea[jcol] = 0
                    DEFINE   LABEL &cLabel 
                              PARENT (::Form1)
                            	ROW ::Y
      	                      COL ::X 
                              CENTERALIGN .t.
                              OnClick {|| ::PulsaUnClick(), ::Hilite(),::asignaTeclas(.t.) } 
                              WIDTH ::WidthCell[Jcol]
                              HEIGHT ::HeightCell
                              VALUE " "
                              FONTNAME ::FontCell
                              FONTSIZE ::SizeCell
                              BACKCOLOR aColor
                              FONTCOLOR ::ColorCell
	                  END LABEL
*                              ACTION ( ::PulsaUnClick(), ::Hilite(), ::asignaTeclas(.t.) )



*                    @ ::Y, ::X LABEL &cLabel;
*                        VALUE " ";
*                        CENTERALIGN ;
*                        ACTION ( ::Hilite(),::asignaTeclas(.t.) );
*                        WIDTH ::WidthCell[Jcol];
*                        HEIGHT ::HeightCell;
*                        FONT ::FontCell;
*                        SIZE ::SizeCell;
*                        BACKCOLOR aColor;
*                        FONTCOLOR ::ColorCell ;
*                        NOWORDWRAP

               CASE ::aAlinea[jcol] = 1
                    @ ::Y, ::X LABEL &cLabel;
                        PARENT (::Form1) ;
                        VALUE " ";
                        ACTION ( ::PulsaUnClick(), ::Hilite(),::asignaTeclas(.t.) );
                        WIDTH ::WidthCell[Jcol];
                        HEIGHT ::HeightCell;
                        FONT ::FontCell;
                        SIZE ::SizeCell;
                        BACKCOLOR aColor;
                        FONTCOLOR ::ColorCell  ;
                        NOWORDWRAP

               CASE ::aAlinea[jcol] = 2
                    DEFINE   LABEL &cLabel 
                              PARENT (::Form1) 
                              click:=0
                             	ROW ::Y
      	                      COL ::X 
                              RIGHTALIGN .t.
                              OnClick {|| ::PulsaUnClick(), ::Hilite(),::asignaTeclas(.t.) } 
                              WIDTH ::WidthCell[Jcol]
                              HEIGHT ::HeightCell
                              VALUE " "
                              FONTNAME ::FontCell
                              FONTSIZE ::SizeCell
                              BACKCOLOR aColor
                              FONTCOLOR ::ColorCell
	                  END LABEL

            endcase
            ::X += ::WidthCell[Jcol] + ::HSpacing
        NEXT
        ::Y += ::HeightCell + ::VSpacing
    NEXT
*    DRAW line in window &(::Form1) at ::yyrow-1,::xxcol-1 to ::yyrow-1,::x+1  penwidth 1
*    DRAW line in window &(::Form1) at ::yyrow-1,::xxcol-1 to ::y+1,::xxcol-1  penwidth 1
*    DRAW line in window &(::Form1) at ::yyrow-1,::x+1 to ::y+1,::x+1  penwidth 1
*    DRAW line in window &(::Form1) at ::y+1,::xxcol-1 to ::y+1,::x+1  penwidth 1
*     clabel:="frame"+::grid
*     @ ::yyrow-8, ::xxcol-1 FRAME &cLabel parent (::Form1) width ::x+3-::xxcol heigHt ::y+7-::yyrow fONTCOLOR {0,0,0} transparent     
*    draw rectangle in window &(::Form1) at ::yyRow-1,::xxCol-1 to ::y+1,::x+1 penwidth 0.5 

    ::asignaTeclas()
    
    if ::X - ::xxCol < 300  && determina el tama�o de los botones
       ::WidtNavigate:=::HeightNavigate:=20
    else
       ::WidtNavigate:=::HeightNavigate:=32
    endif
    ::X := ::xxCol
    ::Y+=5
    if ::ShowNavigateDerecha
       ::X := ::xxCol
       FOR Jcol := 1 TO ::MaxCols
           ::X += ::WidthCell[Jcol] + ::HSpacing
       NEXT
       ::X += 20
       ::Y := ::yyRow
    endif
    IF ::ShowNavigate
        cnomb:=::grid+"First"
        @ ::Y, ::X BUTTON &cNomb picture "primero" parent (::Form1) ACTION { || ::Home() } WIDTH ::WidtNavigate HEIGHT ::HeightNavigate FONT ::FontNavigate SIZE ::SizeFontNavigate TOOLTIP "Ir al Primer Registro"
        ::X += ::WidtNavigate+2
        cnomb:=::grid+"Prior"
        @ ::Y, ::X BUTTON &cNomb picture "repag" parent (::Form1) ACTION { || ::Prior() } WIDTH ::WidtNavigate HEIGHT ::HeightNavigate FONT ::FontNavigate SIZE ::SizeFontNavigate TOOLTIP "Atr�s una P�gina"
        ::X += ::WidtNavigate+2
        cnomb:=::grid+"Up"
        @ ::Y, ::X BUTTON &cNomb picture "anterior" parent (::Form1)  ACTION { || ::Up() } WIDTH ::WidtNavigate HEIGHT ::HeightNavigate FONT ::FontNavigate SIZE ::SizeFontNavigate TOOLTIP "Atr�s un Registro"
        ::X += ::WidtNavigate+2
        cnomb:=::grid+"Down"
        @ ::Y, ::X BUTTON &cNomb picture "siguiente" parent (::Form1) ACTION { || ::Down() } WIDTH ::WidtNavigate HEIGHT ::HeightNavigate FONT ::FontNavigate SIZE ::SizeFontNavigate TOOLTIP "Adelante un Registro"
        ::X += ::WidtNavigate+2
        cnomb:=::grid+"Next"
        @ ::Y, ::X BUTTON &cNomb picture "avpag" parent (::Form1) ACTION { || ::Next() } WIDTH ::WidtNavigate HEIGHT ::HeightNavigate FONT ::FontNavigate SIZE ::SizeFontNavigate TOOLTIP "Adelante una P�gina"
        ::X += ::WidtNavigate+2
        cnomb:=::grid+"Last"
        @ ::Y, ::X BUTTON &cNomb  picture "ultimo" parent (::Form1) ACTION { || ::End() } WIDTH ::WidtNavigate HEIGHT ::HeightNavigate FONT ::FontNavigate SIZE ::SizeFontNavigate TOOLTIP "Ir al Ultimo Registro"
    ENDIF
    ******* Botones de edici�n (a�adir, editar, borrar)
    IF ::ShowBotones
       if ::ShowNavigateDerecha
          ::X := ::xxCol
          FOR Jcol := 1 TO ::MaxCols
              ::X += ::WidthCell[Jcol] + ::HSpacing
          NEXT
          ::Y+=35
          ::X+=20
       endif
       cText := ::aFunciones[1]
       ::X+= ::WidtNavigate+5
*       ::X+= 34
        cnomb:=::grid+"b_nuevo"
       @ ::Y, ::X BUTTON &cnomb PICTURE 'nuevo' parent (::Form1) ACTION &cText WIDTH ::WidtNavigate HEIGHT ::HeightNavigate TOOLTIP '<INSERT>. A�ade Registro'
       ::X+= ::WidtNavigate+2
       cText := ::aFunciones[2]
        cnomb:=::grid+"b_editar"
       @ ::Y, ::X BUTTON &cnomb PICTURE 'editar' parent (::Form1) ACTION &cText WIDTH ::WidtNavigate HEIGHT ::HeightNavigate TOOLTIP '<ENTER>. Modifica Registro'
       ::X+= ::WidtNavigate+2
       cText := ::aFunciones[3]
       cnomb:=::grid+"b_eliminar"
       @ ::Y, ::X BUTTON &cnomb PICTURE 'borrar' parent (::Form1) ACTION &ctext WIDTH ::WidtNavigate HEIGHT ::HeightNavigate TOOLTIP '<Supr>. Elimina Registro'
    endif

    ***** Relleno los campos de b�squeda
    && Si est� activada la b�squeda en campos. Caso contrario no permite buscar/filtrar
    && Tambi�n es necesario que no haya un filtro fijo, porque entonces no tiene sentido buscar nada (para grid dependientes de otros)
    IF ::Showcamposbusqueda .and. ::lCadenaFiltraFija=.f.  
       ::X := ::xxCol
       if ::lBuscaArriba
          ::Y := ::YYrow-25
       else
          ::Y += 32
       endif
       FOR J := 1 TO ::MaxCols
           if ::aBuscaCampo[j]
              cTextbox:="t_busca"+::grid+"__"+strzero(j,2)
              DEFINE TEXTBOX &cTextBox
                   parent (::Form1) 
                   ROW    ::y
                   COL    ::x 
                   WIDTH ::WidthCell[J]
                   HEIGHT ::HeightHeadBusca
                   FONTNAME ::FontHead
                   FONTSIZE ::SizeHead
                   UPPERCASE ::aUpperBusca[j]
                   TOoLTIP ::aHeads[J] + " <ENTER>"
                   VALUE ""
                   ONENTER (::nSuperior:=200,::value:=1, ;
                            ::montabusqueda(), if(alltrim(::ccadenafiltrada)=='wh',::home(J), ::end(j)  ) )
                   ongotfocus {|| _ReleaseHotKey ( ::Form1 , 0 , VK_INSERT) ,;
                                  _ReleaseHotKey ( ::Form1 , 0 , VK_RETURN) ,;
                                  _ReleaseHotKey ( ::Form1 , 0 , VK_DELETE) }
                   onlostfocus {|| _DefineHotKey( ::Form1, 0, VK_INSERT, { || ::t_nuevo() } ) ,;
                                   _DefineHotKey( ::Form1, 0, VK_RETURN, { || ::t_enter() } ) ,;
                                   _DefineHotKey( ::Form1, 0, VK_DELETE, { || ::t_BORRA() } ) }
                   
              END TEXTBOX
           endif
           ::X += ::WidthCell[J] + ::HSpacing
        NEXT
    endif
    ::nSuperior:=1
    ::MontaBusqueda()
    if(alltrim(::ccadenafiltrada)=='wh',::home(j), ::end(j) )  
*    ::Home()
    *----------------------------------------------------
RETURN self
** para q pierda el foco t_busca                          ocontrol:=getcontrolobject(::Form1 ,::Form1), ocontrol:setfocus:=.t. ,; 

*------------------------------------------------------------------------------
*- Monta la cadena que pasar� a la consulta de MySql para el filtrado por lo campos de b�squeda. Puede hacer por varios a la vez
*------------------------------------------------------------------------------
METHOD MontaBusqueda() CLASS MyGrid
*-------------------------
::ccadenafiltrada:=' where '+::cCadenaFiltraFija
if ::lCadenaFiltraFija
   ::lcadenafiltrada:=.t.
else
   ::lcadenafiltrada:=.f.
   ::ccadenafiltrada:=" where "
   IF ::Showcamposbusqueda  && Si est� activada la b�squeda en campos. Caso contrario no permite buscar/filtrar
      FOR K := 1 TO ::maxcols
          if ::aBuscaCampo[K]
             cTextbox:="t_busca"+::grid+"__"+strzero(K,2)
             q:=_GetValue(cTextBox, ::Form1)
             if !empty(q)
                ccadtemp:=q
                if at("&",ccadtemp)<>0
                   nij:=0
                   ccadtemp+=" &"
                   ccadenamonta:="("
                   do while .t.
                      nij++
                      if at("&",ccadtemp)=0
                         exit
                      endif
                      ccadtemp2:=substr(ccadtemp,1,at("&",ccadtemp)-1)
                      ccadtemp:=substr(ccadtemp,at("&",ccadtemp)+1)
                      ccadenamonta+=if(nij>1,' or ','')
                      if ::lbuscadesdeinicio
                         ccadenamonta+=::aConsulta[K]+" like '"+alltrim(ccadtemp2)+"%'"
                      else
                         if ::lbuscaexacta
                            ccadenamonta+=::aConsulta[K]+" like '"+alltrim(ccadtemp2)+"'"
                         else
                            ccadenamonta+=::aConsulta[K]+" like '%"+alltrim(ccadtemp2)+"%'"
                         endif
                      endif
                   enddo
                   ccadenamonta+=') and ' 
                   ::ccadenafiltrada+=ccadenamonta
                   ::lcadenafiltrada:=.t.
                else
                   if ::lbuscadesdeinicio
                      ::ccadenafiltrada+=::aConsulta[K]+" like '"+alltrim(q)+"%' and "
                   else
                      if ::lbuscaexacta
                         ::ccadenafiltrada+=::aConsulta[K]+" like '"+alltrim(q)+"' and "
                      else
                         ::ccadenafiltrada+=::aConsulta[K]+" like '%"+alltrim(q)+"%' and "
                      endif
                   endif
                ::lcadenafiltrada:=.t.
                endif
             endif
          endif
      next
      if !empty(::cConsulta3)
      else
         ::ccadenafiltrada:= substr(::ccadenafiltrada,1,len(::ccadenafiltrada)-4)
      endif
   endif    
   if !empty(::cConsulta3)
      ::lcadenafiltrada:=.t.
      ::ccadenafiltrada+=::cConsulta3
   endif
endif   
*msginfo(::ccadenafiltrada)
return self

*------------------------------------------------------------------------------
* Realiza la consulta 
*   Los campos que devolver� son los inclu�dos en grid_1:cConsulta
*   El filtro de b�squeda en  grid_1:ccadenafiltrada
*------------------------------------------------------------------------------
METHOD MySqlQuery (nsup,nlimite,ldescend) CLASS MyGrid
*------------------------------------------------------------------------------
*-Monto un Query con Select
local cquery, oQuery,orow, t_cta,t_clc,t_cco,t_cc2,t_cca,t_cor
default nsup to ::nsuperior
default nlimite to ::MaxRows
default ldescend to .f.

**** Para saber el n� total de registros
if ::lvscroll
   cquery:= 'Select count(*) From '+::cTabla+;
             if( ::lcadenafiltrada=.f.,''+if(!empty(::cConsulta2)," where "+::cconsulta2,""), ::ccadenafiltrada+;
             if(empty(::cConsulta2),""," and "+::cConsulta2)) +;
             ' order by '+ ::cOrdenGrid
*msginfo(cquery)             
   oQuery := oServer:Query( cquery)               
   *-Verifico si ocurrio un Error
   If oQuery:NetErr()
       Msgstop("Error en el Grid (Select): " + oQuery:Error()+chr(13)+chr(10)+cquery)
       RELEASE WINDOW ALL
       Quit
   Endif
   oRow := oQuery:GetRow(1)
   ocontrol:=getcontrolobject(::grid+"SLIDER",::Form1)
   ocontrol:SetRange (1, orow:fieldget(1))
   ocontrol:=getcontrolobject(::grid+"nregscroll",::Form1)
   ocontrol:value:= alltrim(str(orow:fieldget(1)))
   
*   msginfo("Rango Max"+str(orow:fieldget(1)))
endif


*** Hacemos la b�squeda para el grid
if nlimite=0
   cquery:= 'Select '+if(::ldistinct," distinct ","")+' count(*) From '+::cTabla+;
             if( ::lcadenafiltrada=.f.,''+if(!empty(::cConsulta2)," where "+::cconsulta2,""), ::ccadenafiltrada+if(!empty(::cConsulta2)," and "+::cConsulta2,""))
else                               
   cquery:= 'Select '+if(::ldistinct," distinct ","")+ ::cConsulta +' From '+::cTabla+;
             if( ::lcadenafiltrada=.f.,''+if(!empty(::cConsulta2)," where "+::cconsulta2,""), ::ccadenafiltrada+;
             if(empty(::cConsulta2),""," and "+::cConsulta2)) +;
             ' order by '+ ::cOrdenGrid +;
             ' limit '+str(if(nsup<0,0,nsup))+', '+str(nlimite)
endif
*msginfo(cquery)
oQuery := oServer:Query( cquery)               
*-Verifico si ocurrio un Error
If oQuery:NetErr()
    Msgstop("Error en el Grid (Select): " + oQuery:Error()+chr(13)+chr(10)+cquery)
    RELEASE WINDOW ALL
    Quit
Endif


Return oQuery


*------------------------------------------------------------------------------
*- Asigna teclas de movimiento a funciones
*------------------------------------------------------------------------------
METHOD AsignaTeclas(lActivo,cQueGrid) CLASS MyGrid
*-------------------------
*------------------ Asignaci�n de funciones a teclas
DEFAULT cQueGrid TO ::Grid
if lActivo == NIL
else
   if lActivo    
      _DefineHotKey( ::Form1, 0, VK_HOME, { || ::Home() } )
      _DefineHotKey( ::Form1, 0, VK_END, { || ::End() } )
      _DefineHotKey( ::Form1, 0, VK_PRIOR, { || ::Prior() } )
      _DefineHotKey( ::Form1, 0, VK_NEXT, { || ::Next() } )
      _DefineHotKey( ::Form1, 0, VK_UP, { || ::Up() } )
      _DefineHotKey( ::Form1, 0, VK_DOWN, { || ::Down() } )
      _DefineHotKey( ::Form1, 0, VK_INSERT, { || ::t_nuevo() } )
      _DefineHotKey( ::Form1, 0, VK_RETURN, { || ::t_enter() } )
      _DefineHotKey( ::Form1, 0, VK_DELETE, { || ::t_BORRA() } )
      _DefineHotKey( ::Form1, 0, WM_MBUTTONUP, { || ::Prior() } )
      _DefineHotKey( ::Form1, 0, WM_MBUTTONDOWN, { || ::Next() } )

   else
      _ReleaseHotKey ( ::Form1 , 0 , VK_HOME)
      _ReleaseHotKey ( ::Form1 , 0 , VK_END)
      _ReleaseHotKey ( ::Form1 , 0 , VK_PRIOR)
      _ReleaseHotKey ( ::Form1 , 0 , VK_NEXT)
      _ReleaseHotKey ( ::Form1 , 0 , VK_UP)
      _ReleaseHotKey ( ::Form1 , 0 , VK_DOWN)
      _ReleaseHotKey ( ::Form1 , 0 , VK_INSERT)
      _ReleaseHotKey ( ::Form1 , 0 , VK_RETURN)
      _ReleaseHotKey ( ::Form1 , 0 , VK_DELETE)
      _ReleaseHotKey ( ::Form1 , 0 , WM_MBUTTONUP)
      _ReleaseHotKey ( ::Form1 , 0 , WM_MBUTTONDOWN)
   endif
endif
RETURN self

******************************************************************
METHOD activa_desactiva(lactivo) CLASS MyGrid
******************************************************************
if ::ShowNavigate
   ocontrol:=getcontrolobject(::grid+"First",::Form1)
   ocontrol:visible:=lActivo
   ocontrol:=getcontrolobject(::grid+"Prior",::Form1)
   ocontrol:visible:=lActivo
   ocontrol:=getcontrolobject(::grid+"Up",::Form1)
   ocontrol:visible:=lActivo
   ocontrol:=getcontrolobject(::grid+"Down",::Form1)
   ocontrol:visible:=lActivo
   ocontrol:=getcontrolobject(::grid+"Next",::Form1)
   ocontrol:visible:=lActivo
   ocontrol:=getcontrolobject(::grid+"Last",::Form1)
   ocontrol:visible:=lActivo
endif   
IF ::ShowBotones
   ocontrol:=getcontrolobject(::grid+"B_nuevo",::Form1)
   if ::afunciones[1]="nada()"
      ocontrol:Visible:=.f.
   else
      ocontrol:Visible:=lActivo
   endif
   ocontrol:=getcontrolobject(::grid+"B_editar",::Form1)
   if ::afunciones[2]="nada()"
      ocontrol:Visible:=.f.
   else
      ocontrol:Visible:=lActivo
   endif
   ocontrol:=getcontrolobject(::grid+"B_eliminar",::Form1)
   if ::afunciones[3]="nada()"
      ocontrol:Visible:=.f.
   else
      ocontrol:Visible:=lActivo
   endif
endif

****************************************
METHOD T_NUEVO
****************************************
    IF ::ShowBotones
       cText:=::aFunciones[1]
       if ctext = "nada()"
       else
          &ctext
       endif
    endif

****************************************
METHOD T_ENTER
****************************************
    IF ::ShowBotones
       cText:=::aFunciones[2]
       if ctext = "nada()"
       else
          &ctext
       endif
    endif
       
****************************************
METHOD T_BORRA
****************************************
    IF ::ShowBotones
       cText:=::aFunciones[3]
       if ctext = "nada()"
       else
          &ctext
       endif
    endif


*------------------------------------------------------------------------------
*- Va al Primer Registro de la Selecci�n
*------------------------------------------------------------------------------
METHOD Home(nColumna) CLASS MyGrid
*-------------------------
default ncolumna to 3 
*cgr:=::grid+":cconsulta"
*msginfo(&cgr)
                                                                                                                          
    if ::nsuperior=0
       ::value:=1
       ::Hilite(::value)
    else
       ::nSuperior:=0
       ::value:=1
       ::WorkArea :=::MySqlQuery(::nsuperior,::nLineasTotGrid,)
       ::MaxRows := ::WorkArea:LastRec()
       if ::MaxRows = 0
*          msginfo("No hay registros")
          cTextbox:="t_busca"+::grid+strzero(ncolumna,2)
          &cTextBox:=""
          ::montabusqueda()
          ::WorkArea :=::MySqlQuery(0,::nLineasTotGrid)
          ::MaxRows := ::WorkArea:LastRec()
       endif
*       if ::maxrows > 0
          ::PopulateGrid()
*       endif
    endif
    if ::lVScroll    
       ::nRegAct:=::nSuperior+::value
       ocontrol:=getcontrolobject(::grid+"SLIDER",::Form1)
       ocontrol:value(::nRegAct)
    endif   
RETURN self

*------------------------------------------------------------------------------
*- Va al �ltimo registro de la Selecci�n
*------------------------------------------------------------------------------
METHOD End() CLASS MyGrid
*------------------------
    if ::nsuperior = ::nMaxReg - ::Maxrows
       ::value := ::MaxRows
       ::Hilite(::MaxRows)
    else
       ::nSuperior:=0
       ::value:=::MaxRows
       ::workArea := ::MySqlQuery(0,0)
       oRow := ::workArea :GetRow(1)
       ::nMaxReg := oRow:FieldGet(1)
       ::nsuperior := ::nMaxReg - ::nLineasTotGrid 
       if ::nsuperior < 0
          ::nsuperior:=0
       endif
       ::workArea :=::MySqlQuery(::nsuperior,::nLineasTotGrid,.t.)
       ::MaxRows := ::workArea :LastRec()
       ::value:=::MaxRows
       ::PopulateGrid()
    endif
    if ::lVScroll    
       ::nRegAct:=::nSuperior+::value
       ocontrol:=getcontrolobject(::grid+"SLIDER",::Form1)
       ocontrol:value(::nRegAct)
    endif   
*msginfo(::grid+"___1")
RETURN self

*------------------------------------------------------------------------------
*- Retrocede una P�gina
*------------------------------------------------------------------------------
METHOD Prior() CLASS MyGrid
*--------------------------
    if ::value > 1
       ::value := 1
       ::hilite(::value)       
    else
       ::nSuperior := ::nSuperior - ::nLineasTotGrid
       if ::nsuperior <0
          ::nsuperior := 0
       endif
       ::value := 1
       ::workArea :=::MySqlQuery(::nsuperior,::nLineasTotGrid)
       ::MaxRows := ::workArea :LastRec()
       ::PopulateGrid()
    endif
    if ::lVScroll    
       ::nRegAct:=::nSuperior+::value
       ocontrol:=getcontrolobject(::grid+"SLIDER",::Form1)
       ocontrol:value(::nRegAct)
    endif   
RETURN self

*------------------------------------------------------------------------------
*- Avanza una P�gina
*------------------------------------------------------------------------------
METHOD Next() CLASS MyGrid
*-------------------------
    if ::value < ::MaxRows
       ::value := ::MaxRows
       ::Hilite(::value)
    else
       ::nSuperior:=::nSuperior+ ::MaxRows
       do while .t.
          ::workArea :=::MySqlQuery(::nsuperior,::nLineasTotGrid)
          if ::workArea :LastRec() = 0 .and. ::nSuperior > 0
             ::nSuperior:=::nSuperior- ::MaxRows
             loop
          endif
          ::MaxRows := ::workArea :LastRec()
          ::value := ::MaxRows
          exit
       enddo
       ::PopulateGrid()
   endif
    if ::lVScroll    
       ::nRegAct:=::nSuperior+::value
       ocontrol:=getcontrolobject(::grid+"SLIDER",::Form1)
       ocontrol:value(::nRegAct)
    endif   
RETURN self

*------------------------------------------------------------------------------
*- Retrocede un Registro
*------------------------------------------------------------------------------
METHOD Up() CLASS MyGrid
*--------------------------
    if ::value > 1
       ::value := ::value - 1
       ::Hilite(::value)
    else
       if ::nsuperior > 0
          ::nSuperior := ::nSuperior - 1
          ::value := 1
          if ::nSuperior <0
             ::nSuperior:=0
          endif
          ::workArea :=::MySqlQuery(::nsuperior,::nLineasTotGrid)
          ::MaxRows := ::workArea :LastRec()
          ::PopulateGrid()
       endif
    endif
    if ::lVScroll    
       ::nRegAct:=::nSuperior+::value
       ocontrol:=getcontrolobject(::grid+"SLIDER",::Form1)
       ocontrol:value(::nRegAct)
    endif   
RETURN self
*------------------------------------------------------------------------------
*- Avanza un Registro
*------------------------------------------------------------------------------
METHOD Down() CLASS MyGrid
*----------------------------
    if ::value < ::MaxRows
       ::value := ::value + 1
       ::Hilite(::value)
    else
       if ::MaxRows = ::nLineasTotGrid
          ::nSuperior:=::nSuperior+1
          do while .t.
             ::workArea :=::MySqlQuery(::nsuperior,::nLineasTotGrid)
             if ::workArea :LastRec() = 0
                ::nSuperior:=::nSuperior-1
                loop
             endif
             ::MaxRows := ::workArea :LastRec()
             ::value := ::MaxRows
             exit
          enddo
          ::PopulateGrid()
      endif
    endif
    if ::lVScroll    
       ::nRegAct:=::nSuperior+::value
       ocontrol:=getcontrolobject(::grid+"SLIDER",::Form1)
       ocontrol:value(::nRegAct)
    endif   
RETURN self

*------------------------------------------------------------------------------
*- Arrastra el Scrollbar
*------------------------------------------------------------------------------
METHOD thumb(nvalue) CLASS MyGrid
*-------------------------
if ::lVScroll    
   ::nSuperior := nvalue
   ::value:=1
endif   
msginfo(str(::nsuperior)+" - "+str(::value) )
::workArea :=::MySqlQuery(::nsuperior,::nLineasTotGrid)
::MaxRows := ::workArea :LastRec()
::PopulateGrid()
RETURN self


*------------------------------------------------------------------------------
*- Modifica el orden de b�squeda. Se modifica haciendo CLICK en la cabecera
*------------------------------------------------------------------------------
METHOD OrdenaCab() CLASS MyGrid
*---------------------------------
Local i:=0
cLabel := THIS.Name
i:=val(substr(clabel,-2))
if i=0
   i:=val(substr(clabel,-1))
endif
::cOrdenGrid:=::aOrdenConsulta[i]
*msginfo(::cordengrid)
::nSuperior:=1000
::home()

*------------------------------------------------------------------------------
*- Borra el Grid y lo rellena completo (todas las filas y columnas)
*------------------------------------------------------------------------------
METHOD PopulateGrid() CLASS MyGrid
*---------------------------------
    LOCAL nj := 1, ni := 1, clabel := "", oRow := ""
    nlastrec:=::workarea:lastrec()
    FOR nI := 1 TO ::nlineastotGrid
        IF ni <= nlastrec
           oRow := ::WorkArea:GetRow(ni)
        endif
        FOR nJ := 1 TO ::MaxCols
            cLabel := "LABEL"+::Grid+"__"+ALLTRIM(STR(nI))+"_"+ALLTRIM(STR(nJ))
            IF ni <= ::workarea:lastrec()
               _SetValue(clabel, ::Form1, HB_ValToStr(oRow:FieldGet(nJ)))
           ELSE
                _SetValue(clabel, ::Form1, "")
           ENDIF
           if nlastrec = 0
              ::aCampo[nJ]:=HB_ValToStr("")
           else
              if ni == ::value
                 ::aCampo[nJ]:=HB_ValToStr(oRow:FieldGet(nJ))
                 _SetFontColor(clabel, ::Form1, ::FontColorSelect)
                 _SetBackColor(clabel, ::Form1, ::BackColorSelect)
*                 _SetAlign(clabel, ::Form1, ::aAlinea[nj])
                 ::nRegAntHilite:= ni
              else
                 _SetFontColor(clabel, ::Form1, ::ColorCell)
                 _SetBackColor(clabel, ::Form1, IIF(nI % 2 == 0,::AlternateBackColorCell,::BackColorCell))
              endif
            endif
        NEXT
    NEXT
    ::ejecutar()
RETURN self


*------------------------------------------------------------------------------
* HILITE. Cuando se pincha sobre un registro, o se pulsa una tecla de movimiento (y el cambio est� dentro de la misma pantalla,
*         en lugar de volver a hacer la consulta y/o de pintar todo el grid, lo que hace es lo siguiente:
*           - deselecciona el registro que estaba activo, devolvi�ndole el color normal
*           - selecciona el registro activo, marc�ndolo con el color asignado al registro activo.
*------------------------------------------------------------------------------
METHOD Hilite(yRow) CLASS MyGrid
*---------------------------------
LOCAL cLabel := "", clabel2 := "", clabel3 := "", nI := 0, nJ := 0, lData := .F.,oRow
    IF yRow == Nil
       cLabel := THIS.Name
       yrow:=val(substr(clabel,at("__",clabel)+2,3))
    endif
    if yRow < 1 
       yRow := 1
    ENDIF
    if yRow > ::MaxRows
       yRow := ::MaxRows
    ENDIF
        
    FOR nJ := 1 TO ::MaxCols            
        cLabel2 := "LABEL"+::Grid+"__"+ALLTRIM(STR(::nRegAntHilite))+"_"+ALLTRIM(STR(nJ))
        _SetFontColor(clabel2, ::Form1, ::ColorCell)
        _SetBackColor(clabel2, ::Form1, IIF(::nRegAntHilite % 2 == 0,::AlternateBackColorCell,::BackColorCell))
    next
    oRow := ::WorkArea:GetRow(yrow)
    if ::WorkArea:LastRec() = 0
    else
       FOR nJ := 1 TO ::MaxCols            
           cLabel2 := "LABEL"+::Grid+"__"+ALLTRIM(STR(yRow))+"_"+ALLTRIM(STR(nJ))
           ::aCampo[nJ]:=HB_ValToStr(oRow:FieldGet(nJ))
           _SetFontColor(clabel2, ::Form1, ::FontColorSelect)
           _SetBackColor(clabel2, ::Form1, ::BackColorSelect)
           ::nRegAntHilite:= yRow
       next
       ::value:=yRow
    endif
*    if ::lvscroll
*       ocontrol:=getcontrolobject(::grid+"SLIDER",::Form1)
*       ocontrol:value:=::value
*    endif
    ::ejecutar()
RETURN self


*------------------------------------------------------------------------------
* Ejecuta una funci�n cuando se produce un cambio en el grid. Ejecutar� la funci�n que se indique en la creaci�n del grid.
*------------------------------------------------------------------------------
METHOD ejecutar() CLASS MyGrid
::doevent(::OnChange)

*------------------------------------------------------------------------------
*-Move the Vertical Slider
*------------------------------------------------------------------------------
METHOD VSCROLLMovement(nnum) CLASS MyGrid
*---------------------------------------
default nnum to 1
if ::lVScroll
   ocontrol:=getcontrolobject(::grid+"SLIDER",::Form1)
   ocontrol:value+= nnum
*   ::value:=ocontrol:value
   ::Hilite(::nRegAntHilite)
   ::populategrid(::value)
*   msginfo(str(ocontrol:value)+" - "+str(::value))
endif
RETURN self


*------------------------------------------------------------------------------
* - Activa o desactiva los campos del grid
*------------------------------------------------------------------------------
METHOD grid_activa_desactiva(lactivo) CLASS MyGrid
*---------------------------------------
default lactivo to .t.
FOR J := 1 TO ::MaxCols     && Cabecera
    cLabel := "LABEL"+::Grid+"__"+ALLTRIM(STR(0))+"_"+ALLTRIM(STR(J))
    ocontrol:=getcontrolobject(clabel,::Form1)
    ocontrol:Enabled:=lActivo
next
FOR I := 1 TO ::nLineasTotGrid         && Resto de L�neas
    FOR Jcol := 1 TO ::MaxCols
        cLabel := "LABEL"+::Grid+"__"+ALLTRIM(STR(I))+"_"+ALLTRIM(STR(Jcol))
        ocontrol:=getcontrolobject(clabel,::Form1)
        ocontrol:Enabled:=lActivo
    next
next
FOR J := 1 TO ::MaxCols     && Campos de B�squeda
    cTextbox:="t_busca"+::grid+"__"+strzero(j,2)
    ocontrol:=getcontrolobject(ctextbox,::Form1)
    ocontrol:Enabled:=lActivo
next

*------------------------------------------------------------------------------
* - HACE VISIBLE O NO EL GRID
*------------------------------------------------------------------------------
METHOD grid_visible(lactivo) CLASS MyGrid
*---------------------------------------
default lactivo to .t.
FOR J := 1 TO ::MaxCols     && Cabecera
    cLabel := "LABEL"+::Grid+"__"+ALLTRIM(STR(0))+"_"+ALLTRIM(STR(J))
    ocontrol:=getcontrolobject(clabel,::Form1)
    ocontrol:VISIBLE:=lActivo
next
FOR I := 1 TO ::nLineasTotGrid         && Resto de L�neas
    FOR Jcol := 1 TO ::MaxCols
        cLabel := "LABEL"+::Grid+"__"+ALLTRIM(STR(I))+"_"+ALLTRIM(STR(Jcol))
        ocontrol:=getcontrolobject(clabel,::Form1)
        ocontrol:VISIBLE:=lActivo
    next
next
FOR J := 1 TO ::MaxCols     && Campos de B�squeda
    cTextbox:="t_busca"+::grid+"__"+strzero(j,2)
    ocontrol:=getcontrolobject(ctextbox,::Form1)
    ocontrol:VISIBLE:=lActivo
next
*** PARA LOS BOTONES
if ::ShowNavigate
   ocontrol:=getcontrolobject(::grid+"First",::Form1)
   ocontrol:visible:=lActivo
   ocontrol:=getcontrolobject(::grid+"Prior",::Form1)
   ocontrol:visible:=lActivo
   ocontrol:=getcontrolobject(::grid+"Up",::Form1)
   ocontrol:visible:=lActivo
   ocontrol:=getcontrolobject(::grid+"Down",::Form1)
   ocontrol:visible:=lActivo
   ocontrol:=getcontrolobject(::grid+"Next",::Form1)
   ocontrol:visible:=lActivo
   ocontrol:=getcontrolobject(::grid+"Last",::Form1)
   ocontrol:visible:=lActivo
endif   
IF ::ShowBotones
   ocontrol:=getcontrolobject(::grid+"B_nuevo",::Form1)
   if ::afunciones[1]="nada()"
      ocontrol:Visible:=.f.
   else
      ocontrol:Visible:=lActivo
   endif
   ocontrol:=getcontrolobject(::grid+"B_editar",::Form1)
   if ::afunciones[2]="nada()"
      ocontrol:Visible:=.f.
   else
      ocontrol:Visible:=lActivo
   endif
   ocontrol:=getcontrolobject(::grid+"B_eliminar",::Form1)
   if ::afunciones[3]="nada()"
      ocontrol:Visible:=.f.
   else
      ocontrol:Visible:=lActivo
   endif
endif
if ::lVScroll    
   cLabel := ::grid+"SLIDER"
   ocontrol:=getcontrolobject(cLabel,::Form1)
   ocontrol:VISIBLE:=lActivo
   cLabel := ::grid+"nregscroll"
   ocontrol:=getcontrolobject(cLabel,::Form1)
   ocontrol:VISIBLE:=lActivo
endif


*------------------------------------------------------------------------------
* - Vac�a el contenido del Grid
*------------------------------------------------------------------------------
METHOD VaciaGrid()  CLASS MyGrid
FOR I := 1 TO ::nLineasTotGrid
    FOR Jcol := 1 TO ::MaxCols
        cLabel := "LABEL"+::Grid+"__"+ALLTRIM(STR(I))+"_"+ALLTRIM(STR(Jcol))
        ocontrol:=getcontrolobject(clabel,::Form1)
        ocontrol:value:=" "
    next
next
for i:=1 to len(::acampo)
    ::aCampo[i] := " "
next    

*------------------------------------------------------------------------------
* - Pulsaci�n de un click
*------------------------------------------------------------------------------
METHOD PulsaUnClick()  CLASS MyGrid
::nclick++
*for n:=1 to 100000
*next
cLabel := THIS.Name
if at("SLID",clabel) <> 0
else
   yrow:=val(substr(clabel,at("__",clabel)+2,3))
   *msginfo(str(::value)+"-"+str(::nRegAntHilite)+'-'+str(yrow))
   if yrow <> ::nRegAntHilite 
      ::nclick:=0
   endif
   if ::nclick = 2
      ::nclick:=0
      ::Hilite()
      ::t_enter()
   endif   
endif
***********************************************
METHOD buscaengrid(cQueryBusca,cBuscaCod ) CLASS MyGrid
***********************************************
* cQueryBusca   Consulta Mysql que se va a realizar
* cBuscaCod     Valor que se busca
* 
Local ooQuery, nnnn, oooo, nnn, ooRow , comparara
   *** Busca el valor en el grid
*msginfo(cquerybusca)
   ooQuery := oServer:Query( cQueryBusca )
   If ooQuery:NetErr()
      MsgStop ( ooQuery:Error() )
      Return
   Endif
   nnnn:=oooo:=0
*   for nnn:=1 to ooQuery:lastrec()
   for nnn:=ooquery:lastrec()-20 to ooQuery:lastrec()
       ooRow:=ooQuery:GetRow(nnn)
       comparara:= oorow:fieldget(1)
       if valtype (comparara)= "N"
          comparara:=alltrim(str(comparara))
       else
          comparara:=alltrim(comparara)
       endif
       if valtype (cBuscaCod)= "N"
          cBuscaCod:=alltrim(str(cBuscaCod))
       else
          cBuscaCod:=alltrim(cBuscaCod)
       endif
       if (cBuscaCod) == comparara
          nnnn:= 1+mod(nnn-1,::nLineasTotGrid)
          oooo:= int((nnn-1)/::nLineasTotGrid)*::nLineasTotGrid
          exit
       endif
    next
    if nnn=ooQuery:lastrec()+1
       for nnn:=0 to ooQuery:lastrec()
           ooRow:=ooQuery:GetRow(nnn)
           comparara:= oorow:fieldget(1)
           if valtype (comparara)= "N"
              comparara:=alltrim(str(comparara))
           else
              comparara:=alltrim(comparara)
           endif
           if valtype (cBuscaCod)= "N"
              cBuscaCod:=alltrim(str(cBuscaCod))
           else
              cBuscaCod:=alltrim(cBuscaCod)
           endif
           if (cBuscaCod) == comparara
              nnnn:= 1+mod(nnn-1,::nLineasTotGrid)
              oooo:= int((nnn-1)/::nLineasTotGrid)*::nLineasTotGrid
              exit
           endif
        next
     endif
*msginfo(cbuscacod+'-'+comparara+'-'+str(nnnn)+'--'+str(oooo))
    ::VALUE:=nnnn
    ::nSuperior := oooo
  	::WorkArea := ::MySqlQuery(::nSuperior,::nLineasTotGrid)
    ::populategrid()
  
  
