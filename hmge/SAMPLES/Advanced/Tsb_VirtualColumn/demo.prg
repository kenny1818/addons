/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2020 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2020 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * ����������� ������� � Tsbrowse ��� dbf-�����.
 * ��������� ������ ��� ����� ���� �����.
 * ������ �� ����������� ��������, ����� �� ����������� ��������.
 * Virtual columns in Tsbrowse for dbf file.
 * Separate array for background color of cells.
 * Filter by virtual columns, colors by virtual columns
*/

#define _HMG_OUTLOG
#define SHOW_TITLE  "Virtual columns in Tsbrowse for dbf file ( " + cFileNoPath(App.ExeName) + " )"
#define VIRT_COLUMN_1      1
#define VIRT_COLUMN_2      2
#define VIRT_COLUMN_3      3
#define VIRT_COLUMN_4      4
#define VIRT_COLUMN_5      5
#define VIRT_COLUMN_6      6
#define VIRT_COLUMN_END    6
#define VIRT_COLUMN_MAX    ( VIRT_COLUMN_END + 1 )

#include "minigui.ch"
#include "TSBrowse.ch"

REQUEST HB_CODEPAGE_UTF8, HB_CODEPAGE_RU866, HB_CODEPAGE_RU1251
REQUEST DBFNTX, DBFCDX, DBFFPT
//////////////////////////////////////////////////////////////////////
PROCEDURE Main()
   LOCAL cFile1, cAls1, cCdp1, cVia1, cFile2, cAls2, cCdp2, cVia2
   LOCAL oBrw1, oBrw2, nY, nX, nW, nH, nC, nWPrt, aDatos1, aDatos2
   LOCAL cFont, nSize, aBackColor, aTsbFont, hFont1, hFont2, hFont3

   SET CODEPAGE TO RUSSIAN
   SET LANGUAGE TO RUSSIAN

   RddSetDefault( 'DBFCDX' )

   SET DECIMALS  TO 4
   SET EPOCH     TO 2000
   SET DATE      TO GERMAN
   SET CENTURY   ON
   SET DELETED   OFF
   SET AUTOPEN   OFF
   SET EXACT     ON
   SET EXCLUSIVE ON
   SET SOFTSEEK  ON
   SET OOP ON
   SET MSGALERT BACKCOLOR TO { 141, 179, 226 }               // for HMG_Alert()
   DEFINE FONT DlgFont  FONTNAME "DejaVu Sans Mono" SIZE 12  // for HMG_Alert()
   SET MENUSTYLE EXTENDED                                    // switch menu style to advanced
   SetMenuBitmapHeight( 20 )                                 // set icon size 20x20

   _SetGetLogFile( GetStartUpFolder() + "\_Msg.log" )
   fErase( _SetGetLogFile() )

   nY := nX := 0

   cFont      := "Arial"
   nSize      := 12
   aBackColor := SILVER
   cFile1     := cFile2 := GetStartUpFolder() + "\demo.DBF"
   cAls1      := "ONE"
   cAls2      := "TWO"
   cCdp1      := cCdp2  := "RU866"
   cVia1      := cVia2  := "DBFCDX"
   aTsbFont   := { "TsbNorm", "TsbBold", "TsbBold", "TsbSpecH", "TsbSuperH", "TsbEdit" }

   myFont( .T., nSize )  // ��������� ���� ����� ��� �������
   aDatos1 := CreateDatos1( cFile1, cAls1, cCdp1, cVia1 )
   aDatos2 := CreateDatos2( cFile2, cAls2, cCdp2, cVia2 )

   SET DEFAULT ICON TO "1MAIN_ICO"
   SET FONT TO cFont, nSize
   hFont1  := GetFontHandle( "TsbNorm"   )
   hFont2  := GetFontHandle( "TsbBold"   )
   hFont3  := GetFontHandle( "TsbSuperH" )

   DEFINE WINDOW Form_Main                    ;
      TITLE SHOW_TITLE ICON "1MAIN_ICO"       ;
      BACKCOLOR aBackColor                    ;
      MAIN TOPMOST                            ;
      ON INIT    {|| This.Topmost := .F. /*, myVirtColumColorSaveCell(oBrw1) , myVirtColumColorSaveCell(oBrw2)*/  } ;
      ON RELEASE {|| DbCloseAll(), myFont() } ;
      NOMAXIMIZE NOSIZE

      nW := This.ClientWidth       // ������ ����

      (This.Object):Cargo           := oKeyData()
      (This.Object):Cargo:oBrwFocus := Nil

      DEFINE MAIN MENU
         POPUP "Test tbrowse" FONT hFont3
            ITEM "Put color in virtual columns tbrowse-1" ACTION myVirtColumColorSaveCell(oBrw1) FONT hFont1
            ITEM "Put color in virtual columns tbrowse-2" ACTION myVirtColumColorSaveCell(oBrw2) FONT hFont1
            SEPARATOR
            ITEM "F3: ListColumn tbrowse-1"  ACTION  myListColumn(oBrw1) FONT hFont1
            ITEM "F3: ListColumn tbrowse-2"  ACTION  myListColumn(oBrw2) FONT hFont1
            SEPARATOR
            ITEM "What filter is tbrowse-1"  ACTION  myFilterTsb(oBrw1) FONT hFont1
            ITEM "What filter is tbrowse-2"  ACTION  myFilterTsb(oBrw2) FONT hFont1
            SEPARATOR
            ITEM "Exit"                      ACTION Form_Main.Release FONT hFont3
         END POPUP
         POPUP "About"        FONT hFont3
            ITEM "Program Info"                 ACTION MsgAbout()          FONT hFont2
            ITEM "Virtual table columns"        ACTION MsgVirtColunm()     FONT hFont2
            ITEM "Table virtual column header"  ACTION MsgVirtHeadColunm() FONT hFont2
            ITEM "Table column header"          ACTION MsgInfoHeader()     FONT hFont2
         END POPUP
         POPUP "Right/left mouse click on the table header"  FONT hFont2
            ITEM "Mouse click on the table header"                  ACTION MsgInfoHeader()     FONT hFont2
            ITEM "Mouse click on the header of the virtual columns" ACTION MsgVirtHeadColunm() FONT hFont2
         END POPUP
      END MENU

      nWPrt := ( nW - 10 ) / 6
      DEFINE STATUSBAR
         STATUSITEM ""                  WIDTH 10
         STATUSITEM "Recno: 0/0"        WIDTH nWPrt FONTCOLOR PURPLE ACTION  Nil
         STATUSITEM "Column: 0/0"       WIDTH nWPrt FONTCOLOR PURPLE ACTION  Nil
         STATUSITEM "Mode: Dbf"         WIDTH nWPrt FONTCOLOR RED
         STATUSITEM "ALIAS1 - " + cAls1 WIDTH nWPrt FONTCOLOR GRAY
         STATUSITEM "ALIAS2 - " + cAls2 WIDTH nWPrt FONTCOLOR GRAY
         STATUSITEM "DELETE OFF"        WIDTH nWPrt FONTCOLOR LGREEN
      END STATUSBAR

      //////////// ������ ������� ///////////////////
      nC := This.ClientHeight - This.StatusBar.Height - nY
      nH := nC * 0.5

      oBrw1 := myBrw1( nY, nX, nW, nH, aDatos1, aTsbFont, 1 )
      (This.Object):Cargo:oBrw1 := oBrw1         // �� ���� ���������, ������ tsb ��� �������

      /////////////// ������ ������� ///////////////////
      nY += nH
      nH := nC - nH

      oBrw2 := myBrw2( nY, nX, nW, nH, aDatos2, aTsbFont, 2 )
      (This.Object):Cargo:oBrw2 := oBrw2         // �� ���� ���������, ������ tsb ��� �������

      ON KEY ESCAPE ACTION {|| iif( oBrw2:IsEdit, oBrw2:SetFocus(), ;
                               iif( oBrw1:IsEdit, oBrw1:SetFocus() , _wPost(99) ) ) }

      WITH OBJECT This.Object
        :Event(99, {|ow| ow:Release() } )  // ����� �� ESC
      END WITH

      This.Minimize ;  This.Restore ; DO EVENTS

      oBrw1:SetFocus()  // ����� �� ������� 1

   END WINDOW

   ACTIVATE WINDOW Form_Main

RETURN

////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myBrw1( nY, nX, nW, nH, aDatos, aFont, nBrw )
   LOCAL aHead, aSize, aFoot, aPict, aAlign, aArray, aFAlign, aField
   LOCAL oBrw1, aName, aSupHd, cAlias

   cAlias     := aDatos[  1 ]
   aArray     := aDatos[  1 ]
   aHead      := aDatos[  2 ]
   aSize      := aDatos[  3 ]
   aFoot      := aDatos[  4 ]
   aPict      := aDatos[  5 ]
   aAlign     := aDatos[  6 ]
   aName      := aDatos[  7 ]
   aField     := aDatos[  8 ]
   aFAlign    := aDatos[  9 ]         // ��������� ������ ����������
   aSupHd     := aDatos[ 10 ]
   aFoot      := .T.                  // ������� ������ �������� ��� �������
/*
? "-------- " + ProcName() + " ------ ������� -------"
? "aArray =" , aArray               ; ?
? "aHead ="  , aHead   ; ?v aHead   ; ?
? "aSize ="  , aSize   //; ?v aSize ; ?
//? "aFoot =", aFoot   ; ?v aFoot   ; ?
? "aPict ="  , aPict   ; ?v aPict   ; ?
? "aAlign =" , aAlign  ; ?v aAlign  ; ?
? "aName ="  , aName   ; ?v aName   ; ?
? "aField =" , aField  ; ?v aField  ; ?
? "aSupHd =" , aSupHd  ; ?v aSupHd  ; ?
*/
   DEFINE TBROWSE oBrw1                                  ;
          AT nY, nX ALIAS aArray WIDTH nW HEIGHT nH CELL ;
          FONT       aFont                               ;
          BRUSH      YELLOW                              ;
          HEADERS    aHead                               ;
          COLSIZES   aSize                               ;
          PICTURE    aPict                               ;
          JUSTIFY    aAlign                              ;
          COLUMNS    aField                              ;
          COLNAMES   aName                               ;
          FOOTERS    aFoot                               ;
          FIXED      COLSEMPTY                           ;
          LOADFIELDS                                     ;
          COLNUMBER  { VIRT_COLUMN_MAX, 40 }             ;
          ENUMERATOR LOCK EDIT

          myBrwInit( oBrw1, nBrw )              // init TBrowse and Cargo
          myColorsInit( oBrw1 )                 // ������������� ������ � Cargo
          myVirtSetTsb( oBrw1 )                 // ��������� ����������� ��������
          mySetTsb( oBrw1 )                     // ��������� �������
          myPartWidthTsb( oBrw1 )               // ��������� ������ �������
          myColorTsb( oBrw1 )                   // ����� �� �������
          myColorTsbElect( oBrw1 )              // ����� ���������
          mySupHdTsb( oBrw1, aSupHd )           // SuperHeader
          myEnumTsb( oBrw1 , VIRT_COLUMN_MAX )  // ENUMERATOR �� �������
          mySet2Tsb( oBrw1 )                    // ��������� ������� ��������������
          mySetEditTsb( oBrw1 )                 // ��������� ��������������
          mySetHeadClick( oBrw1 )               // ��������� ��� ����� �������

   END TBROWSE ON END {|ob| ob:SetNoHoles(), ob:oPhant:nClrHeadBack := ob:Cargo:nClr4, ;
                                             ob:oPhant:nClrFootBack := ob:Cargo:nClr10,;
                                             ob:Refresh() }
RETURN oBrw1

////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myBrw2( nY, nX, nW, nH, aDatos, aFont, nBrw )
   LOCAL aHead, aSize, aFoot, aPict, aAlign, aArray, aFAlign, aField
   LOCAL oBrw2, aName, aSupHd, cAlias

   cAlias     := aDatos[  1 ]
   aArray     := aDatos[  1 ]
   aHead      := aDatos[  2 ]
   aSize      := aDatos[  3 ]
   aFoot      := aDatos[  4 ]
   aPict      := aDatos[  5 ]
   aAlign     := aDatos[  6 ]
   aName      := aDatos[  7 ]
   aField     := aDatos[  8 ]
   aFAlign    := aDatos[  9 ]         // Footer align
   aSupHd     := aDatos[ 10 ]
   aFoot      := .T.                  // ������� ������ �������� ��� �������

   DEFINE TBROWSE oBrw2                                  ;
          AT nY, nX ALIAS aArray WIDTH nW HEIGHT nH CELL ;
          FONT       aFont                               ;
          BRUSH      YELLOW                              ;
          HEADERS    aHead                               ;
          COLSIZES   aSize                               ;
          PICTURE    aPict                               ;
          JUSTIFY    aAlign                              ;
          COLUMNS    aField                              ;
          COLNAMES   aName                               ;
          FOOTERS    aFoot                               ;
          FIXED      COLSEMPTY                           ;
          LOADFIELDS GOTFOCUSSELECT                      ;
          COLNUMBER  { VIRT_COLUMN_MAX, 40 }             ;
          ENUMERATOR LOCK  EDIT

          myBrwInit( oBrw2, nBrw )             // init TBrowse and Cargo
          myColorsInit( oBrw2 )                // ������������� ������ � Cargo
          myVirtSetTsb( oBrw2 )                // ��������� ����������� ��������
          mySetTsb( oBrw2 )                    // ��������� �������
          myPartWidthTsb( oBrw2 )              // ��������� ������ �������
          myColorTsb( oBrw2 )                  // ����� �� �������
          myColorTsbElect( oBrw2 )             // ����� ���������
          mySupHdTsb( oBrw2, aSupHd )          // SuperHeader
          myEnumTsb( oBrw2 , VIRT_COLUMN_MAX)  // ENUMERATOR �� �������
          mySet2Tsb( oBrw2 )                   // ��������� ������� ��������������
          mySetEditTsb( oBrw2 )                // ��������� �������������� �������
          mySetHeadClick( oBrw2 )              // ��������� ��� ����� �������

   END TBROWSE ON END {|ob| ob:SetNoHoles(), ob:oPhant:nClrHeadBack := ob:Cargo:nClr4, ;
                                             ob:oPhant:nClrFootBack := ob:Cargo:nClr10,;
                                             ob:Refresh() }
RETURN oBrw2

///////////////////////////////////////////////////////////
// ������������� TsBrowse � Cargo �������
STATIC FUNCTION myBrwInit( oBrw, nBrw )
   LOCAL nRecords, nCol

   WITH OBJECT oBrw

      :Cargo          := oKeyData()            // ������� ������ ��� ���������� (������� ������) ���������� ���� �� ����
      :Cargo:nBrowse  := nBrw                  // ����� ������� - ���������
      :Cargo:nFilter  := 0                     // ��� ������� �� �������
      :Cargo:cFilter  := ""                    // ������� ������� �� �������
      :Cargo:aSum     := array( VIRT_COLUMN_END )
      AFill( :Cargo:aSum, 0 )
      :Cargo:aBrwVirt := GetVirtAll(:cAlias)   // ������� ������ �������� ����.�������
                                               // �� ���� ��������� ����������� �������
      nRecords := Len( :Cargo:aBrwVirt[1] )    // ���-�� ������� � ����
      :Cargo:aRecnoClrBack := Array( Len( :aColumns ) )  // ���-�� ������� ��� ����� ����

      // �� ������ ������� #, �.�. ����. ������� ������
      FOR nCol := :nColumn("ORDKEYNO") TO Len( :aColumns )
         :Cargo:aRecnoClrBack[nCol] := Array( nRecords )
         // ������ ����� ���� ��� ������ ������� - ��������� 0
         AFill(:Cargo:aRecnoClrBack[nCol], 0)
      NEXT

      // ������ �������, ���� ��� ������� �� ������� - ������������� ����� �������
      :bEvents := {|obr,nmsg|
                    Local i, oCol
                    If nmsg == WM_LBUTTONUP .and. obr:nLen == 0
                       obr:FilterData()
                       obr:SetFocus()
                       FOR i := 1 TO VIRT_COLUMN_END
                           oCol := obr:aColumns[ i ]
                           oCol:nClrHeadBack := obr:Cargo:nClr4
                           oCol:cFooting := iif( Empty(obr:Cargo:aSum[ i ]), "", hb_ntos(obr:Cargo:aSum[ i ]) )
                       NEXT
                       obr:DrawHeaders(.T.)
                    EndIf
                    Return Nil
                   }
      :bGotFocus := {|ob| myGotFocusTsb(ob)     }
      :bOnDraw   := {|ob| SayStatusBar(ob)      }   // ����� StatusBar - Recno/Column

      :UserKeys(VK_F3, {|ob| myListColumn(ob)   })  // ���� �� ������ �������
      /*
      // ���� ������� ������
      :bTSDrawCell := {|ob,ocel,ocol|
                        If ocel:nDrawType == 0 .and. ob:Cargo:nFilter > 0      // Line
                           If ocol:cName == "VIRT1"
                              ocel:nClrBack := ocol:Cargo:oBack:Get(ob:nAtPos, oCol:Cargo:nBackDef)
                              ocel:nClrFore := ocol:Cargo:oFore:Get(ob:nAtPos, oCol:Cargo:nForeDef)
                              //? ob:nAt, ob:nAtPos, ocol:cName, ocel:nClrBack
                           EndIf
                        EndIf
                        Return Nil
                       }
      */
   END WITH

RETURN Nil

///////////////////////////////////////////////////////////
// ������������� ������ ������� � Cargo
STATIC FUNCTION myColorsInit( oBrw )

   WITH OBJECT oBrw:Cargo

      // 0. ������ �������� ����������
      :nBtnText   :=  GetSysColor( COLOR_BTNTEXT )     // nClrSpecHeadFore
      :nBtnFace   :=  GetSysColor( COLOR_BTNFACE )     // nClrSpecHeadBack
      :nBClrSpH   :=  GetSysColor( COLOR_BTNFACE )     // nClrSpecHeadBack
      // 1. ���������� ������ �� #define CLR_... � RGB(...), ����� ������ ����� ������ ����� ���
      :nHRED      :=  CLR_HRED
      :n_HRED     := -CLR_HRED
      :nRED       :=  CLR_RED
      :nBLUE      :=  CLR_BLUE
      :n_BLUE     := -CLR_BLUE
      :n_HBLUE    := -RGB(128,225,225)
      :nHBLUE     :=  RGB(128,225,225)
      :nHBLUE2    :=  RGB(  0,176,240)   //CLR_HBLUE
      :nHGRAY     :=  CLR_HGRAY
      :nGRAY      :=  CLR_GRAY
      :nBLACK     :=  CLR_BLACK
      :nYELLOW    :=  CLR_YELLOW
      :nGREEN     :=  CLR_GREEN
      :nGREEN2    :=  RGB(  0,255,  0)
      :nGREEN3    :=  RGB( 94,162, 38)        // ������� ������. 25%
      :nORANGE    :=  CLR_ORANGE
      :nWHITE     :=  CLR_WHITE
      :nPURPLE2   := RGB(206,59,255)
      :nBCDelRec  := RGB( 65, 65, 65 )
      :nFCDelRec  := RGB( 251, 250, 174 )     // ������ ������.
      :nBCYear    := RGB( 178, 227, 137 )     // ������� ������. 60%
      :nBCYear2   := :nGREEN3                 // ������� ������. 25%
      :nFCYear    := RGB( 63, 108, 25 )       // ����� ������� ������. 50%

      // 2. ���������� RGB( ... ) ��� �������������
      :nRgb0      :=  RGB(  0,  0,  0)
      :nRgb1      :=  RGB(180,180,180)
      :nRgb2      :=  RGB(255,255,240)
      :nRgb3      := -RGB(128,225,225)

      // 3. ���������� (aColors items number) �� ������ ������� � :SetColor( {...}, ... ) �� TsBrowse.ch
      :nClrLine   :=  :nRgb1
      :nClr1      :=  :nRgb0                  // #define CLR_         1   // text
      :nClr2      :=  :nRgb2                  // #define CLR_PANE     2   // back
      :nClr3      :=  :nWHITE                 // #define CLR_HEADF    3   // header text
      :nClr4      := {:nHGRAY, :nGRAY}        // #define CLR_HEADB    4   // header back
      :nClr5      :=  :nRgb0                  // #define CLR_FOCUSF   5   // focused text
      :nClr6_1    :=  :n_BLUE                 // #define CLR_FOCUSB   6 1 // focused back
      :nClr6_2    :=  :nRgb3                  // #define CLR_FOCUSB   6 2 // focused back
      :nClr9      :=  :nWHITE                 // #define CLR_FOOTF    9   // footer text
      :nClr10     := {:nGRAY, :nHGRAY}        // #define CLR_FOOTB   10   // footer back
      :nClr11     :=  :nRgb0                  // #define CLR_SELEF   11   // focused inactive (or selected) text
      :nClr12_1   :=  :n_BLUE                 // #define CLR_SELEB   12 1 // focused inactive (or selected) back
      :nClr12_2   :=  :nRgb3                  // #define CLR_SELEB   12 2 // focused inactive (or selected) back
      :nClr16     := {RGB(0,176,240),RGB(60,60,60)}    // 16, ���� ���������
      :nClr17     :=  :nYELLOW                         // 17, ������ ���������
      :aClrVirt   := { :nBCDelRec, 0, :nHBLUE2, :nBCYear2, :nHRED, :nPURPLE2 }
      :aClrBrw    := { :nGREEN2 , :nYELLOW }

   END WITH

RETURN Nil

////////////////////////////////////////////////////////////////////////
// ������� ������ �������� ����.������� = ���-�� ������� ����
// �������� ����.������� ����� ��� �������� ���� ������� �� ������ ��������
STATIC FUNCTION GetVirtAll()
   LOCAL i, nOld := Recno(), nSum, aDim, nRec, aVirt

   nRec  := LASTREC()
   nSum  := 0
   aVirt := {}

   FOR i := 1 TO VIRT_COLUMN_END
      aDim := ARRAY(nRec)
      AFill( aDim, nSum )
      AADD( aVirt, aDim )
   NEXT

   GOTO nOld

RETURN aVirt

////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myGotFocusTsb( oBrw )
   LOCAL oCargo := GetProperty(oBrw:cParentWnd, "Cargo")

   oCargo:oBrwFocus   := oBrw                 // �� ���� ���������, ����� tsb � ������
   oBrw:Cargo:nClr6_1 := oBrw:Cargo:n_HRED

RETURN Nil

/////////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION SayStatusBar( oBrw )      // ����� StatusBar - Recno/Column
   LOCAL nCell  := oBrw:nCell
   LOCAL nRecno := (oBrw:cAlias)->( Recno() )
   LOCAL cForm  := oBrw:cParentWnd
   LOCAL cSt1, cSt2, cRec, lDel, cDel, cVal

   cVal := "Column: "+hb_ntos(nCell - VIRT_COLUMN_MAX)+" / "
   cVal += hb_ntos(oBrw:nColCount() - VIRT_COLUMN_MAX)
   SetProperty( cForm, "StatusBar" , "Item" , 3, cVal )

   cSt1 := hb_NtoS(nRecno)
   cSt2 := hb_NtoS((oBrw:cAlias)->( LastRec() ))
   lDel := (oBrw:cAlias)->( Deleted() )
   cDel := iif( (oBrw:cAlias)->( Deleted() ), "Deleted", "" )
   cRec := iif( lDel, "*", " " )+"Recno: "
   cVal := cRec+cSt1+" / "+cSt2+" "+cDel
   SetProperty( cForm, "StatusBar" , "Item" , 2, cVal )

RETURN Nil

/////////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myListColumn( oBrw )
   LOCAL oCol, nCol, cCol, cSize, cMsg := ''

   FOR nCol := 1 TO Len(oBrw:aColumns)
      oCol  := oBrw:aColumns[ nCol ]
      cCol  := oCol:cName
      cSize := HB_NtoS( INT( oBrw:GetColSizes()[nCol] ) )
      cMsg  += HB_NtoS(nCol) + ") " + cCol + " = " + cSize
      cMsg  += " :nWidth=" + HB_NtoS(oCol:nWidth)
      cMsg  += '  ( "' + oCol:cFieldTyp + '" ' + HB_NtoS(oCol:nFieldLen)
      cMsg  += ',' + HB_NtoS(oCol:nFieldDec) + ' ) ;'
   NEXT

   AlertInfo(cMsg + REPL(";",30))

RETURN Nil

//////////////////////////////////////////
// ��������� ����������� ��������
STATIC FUNCTION myVirtSetTsb( oBrw )
   LOCAL i, o

   WITH OBJECT oBrw

      FOR i := 1 TO Len(:aColumns)
          o := :aColumns[ i ]
          IF o:cName == "ORDKEYNO"; EXIT
          ENDIF
          o:cAlias   := :cAlias
          //o:Cargo    := This.Cargo:aBrwVirt[ i ]     // ������ ����������� ������
          o:Cargo    := :Cargo:aBrwVirt[ i ]           // ������ ����������� ������
          o:cName    := 'VIRT'+hb_ntos(i)
          o:cHeading := "("+hb_ntos(i)+")"
          o:cFooting := ""
          o:cPicture := Nil
          o:bData    := {|| Nil }
          o:bValue   := {|u,obr,ncol,ocol|
                          Local nrec := (obr:cAlias)->( RecNo() )
                          ncol := nil
                          If nrec > Len(ocol:Cargo)
                             u := -1
                          Else
                             u := ocol:Cargo[nrec]  // ����. ��������
                          Endif
                          //?? u
                          Return u
                        }
          o:nAlign    := DT_CENTER
          o:nFAlign   := DT_CENTER
          o:cField    := ""
          o:cFieldTyp := "N"
          o:nFieldLen := 5
          o:nWidth    := 40 //o:ToWidth(o:nFieldLen)
      NEXT

   END WITH

RETURN Nil

//////////////////////////////////////////
STATIC FUNCTION mySetTsb( oBrw )
   WITH OBJECT oBrw
      :nColOrder     := 0           // ������ ������ ���������� �� ����
      :lNoChangeOrd  := .T.         // ������ ���������� �� ����
      :nWheelLines   := 1           // ��������� ������� ����
      :lNoGrayBar    := .F.         // ���������� ���������� ������ � �������
      :lNoLiteBar    := .F.         // ��� ������������ ������ �� ������ ���� �� ������� "������" Bar
                                    // ������ ��������, ��� ������������� ������, ���������������,
                                    // ��� .T. ���������� �������� ������ ���, �.�. ��� ������
                                    // ��������� �� ���� ��� (�� ������������� ������), �.�.
                                    // ��� ������ :DrawSelect()
      :lNoResetPos   := .F.         // ������������� ����� ������� ������ �� gotfocus
      :lNoPopUp      := .T.         // �������� ����������� ���� ��� ������ ������ ������� ���� �� ��������� �������
      :lNoHScroll    := .T.         // ��������� ����� HScroll ��� �������� �� ������ ��� (��� ������� ������ � �����)
      :nHeightCell   += 2           // ������ ����� ������� ������� 2 �������
      :nCellMarginLR := 1           // ������ �� ����� ������ ��� �������� �����, ������ �� ���-�� ��������
      :nStatusItem   :=  0
      :lNoKeyChar    := .T.         // method :KeyChar disabled
      :lCheckBoxAllReturn := .T.    // Enter modify value oCol:lCheckBox
      :lPickerMode        := .F.    // ������ ���� ����������
   END WITH
RETURN Nil

//////////////////////////////////////////
STATIC FUNCTION mySet2Tsb( oBrw )
   LOCAL nLen, cBrw, nTsb

   WITH OBJECT oBrw
      cBrw := :cControlName
      nTsb := This.&(cBrw).ClientWidth   // ������ ������ ���
      nLen := :GetAllColsWidth() - 1     // ������ ���� ������� �������
      IF nLen > nTsb                     // �������� �� ������ � ����� -> HScroll
         :lAdjColumn  := .T.             // ����������� ��������� ������� ��� ����������
         :lNoHScroll  := .F.             // ��������\���. �������� ��������������
         :lMoreFields := ( :nColCount() > 30 ) // ���� ������� ������, �� ���.
                                               // ����� ������, ��� �� ��
                                               // �������� ���������� ���
      ELSE
         :AdjColumns()  // ������� ������ � ���� ���, ������ ������������ "�����"
                        // ����������� �� �������� �� ��������, ��������
      ENDIF
   END WITH

RETURN Nil

////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myPartWidthTsb( oBrw )         // ��������� ������ �������
   LOCAL nW, oCol, cType, hFont := oBrw:hFont  // 1-cells font
   LOCAL cCol, cNam, aColVirt, lColVirt

   // ��-�� ����������� ������� ������ ��������� ������� ����������
   // + � ����� ������ ���� "DejaVu Sans Mono", �.�. �� ������������
   // ����� �������������� ���������� ������ �������

   aColVirt := { "VIRT1", "VIRT2", "VIRT3", "VIRT4", "VIRT5", "VIRT6", "ORDKEYNO" }

   WITH OBJECT oBrw
      FOR EACH oCol IN :aColumns
         cCol     := oCol:cName
         cType    := oCol:cFieldTyp
         lColVirt := .F.
         FOR EACH cNam IN aColVirt
            IF cCol == cNam
               lColVirt := .T.
               EXIT
            ENDIF
         NEXT
         IF !lColVirt

            IF cType $ "=@T"
               oCol:nWidth := GetTextWidth( Nil, REPL("9",24), hFont ) // 24 �����
            ELSEIF cType $ "+^" // Type: [+] [^]
               oCol:nWidth := GetTextWidth( Nil, REPL("9",6), hFont )  // 6 �����
            ELSEIF cType == "D"
               oCol:nWidth := GetTextWidth( Nil, REPL("9",11), hFont )
            ELSEIF cType == "C"
               // �������� ������ �������
               oCol:nWidth := GetTextWidth( Nil, REPL("H", oCol:nFieldLen), hFont )
               // �������� ������ ������� ��� ����������� :nCellMarginLR := 1
               // ��� ����� �� ������ ! ������� �� ���������� ������ � �����
               nW := GetTextWidth( Nil, REPL("H",1), hFont )
               oCol:nWidth +=  nW + nW/2

            ELSEIF cType == "N"
               oCol:nWidth := GetTextWidth( Nil, REPL("0", oCol:nFieldLen), hFont ) * 0.8
               IF oCol:nFieldLen < VIRT_COLUMN_MAX
                  oCol:nWidth := GetTextWidth( Nil, REPL("0", oCol:nFieldLen), hFont )
               ENDIF
            ENDIF

            // �������� ������ ������� ��� ������� �������� �����
            nW := GetTextWidth( Nil, "H" + oCol:cName, hFont )
            IF nW > oCol:nWidth
               oCol:nWidth := nW
            ENDIF

         ENDIF  // !lColVirt

      NEXT

   END WITH

RETURN Nil

////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myColorTsb( oBrw )
   LOCAL O

   WITH OBJECT oBrw
      O := :Cargo
      :nClrLine := O:nClrLine          // ������� � ���������� ���� ���������� � �������
      :SetColor( { 1}, { O:nClr1  } )  // 1 , ������ � ������� �������
      :SetColor( { 2}, { O:nClr2  } )  // 2 , ���� � ������� �������
      :Setcolor( { 3}, { O:nClr3  } )  // 3 , ������ ����� �������
      :SetColor( { 4}, { O:nClr4  } )  // 4 , ���� ����� �������   // !!! ��� ������ ���� ����, ������� ����������
      :SetColor( { 5}, { O:nClr5  } )  // 5 , ������ �������, ����� � ������� � �������
      :SetColor( { 6}, { {|c,n,b| c := b:Cargo, iif( b:nCell == n, c:nClr6_1 , c:nClr6_2  ) } } )  // 6 , ���� �������
      :SetColor( { 9}, { O:nClr9  } )  // 9 , ������ ������� �������
      :SetColor( {10}, { O:nClr10 } )  // 10, ���� ������� ������� // !!! ��� ������ ���� ����, ������� ����������
      :SetColor( {11}, { O:nClr11 } )  // 11, ������ ����������� ������� (selected cell no focused)
      :SetColor( {12}, { {|c,n,b| c := b:Cargo, iif( b:nCell == n, c:nClr12_1, c:nClr12_2 ) } } )  // 12, ���� ����������� ������� (selected cell no focused)
      :hBrush   := CreateSolidBrush( 255, 255, 230 )   // ���� ���� ��� ��������
   END WITH

RETURN Nil

////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myColorTsbElect( oBrw )
   LOCAL aColVirt, lVirtual, nCol, cFld, oCol, cCol, cNam
   LOCAL nBrowse, nAt := oBrw:nAtPos, aCol := oBrw:aColumns
   LOCAL O := oBrw:Cargo  // ������������ �� ���������� ���� ����������

   nBrowse  := O:nBrowse  // ����� �������
   aColVirt := { "VIRT1", "VIRT2", "VIRT3", "VIRT4", "VIRT5", "VIRT6" }
   // ���� ���� � ������� ������� ��� ����������� �������
   //oBrw:GetColumn("VIRT1"):nClrBack     := { |a,n,b| myTsbColorBackVirt(a,n,b) }
   //oBrw:GetColumn("VIRT2"):nClrBack     := { |a,n,b| myTsbColorBackVirt(a,n,b) }
   oBrw:GetColumn("ORDKEYNO"):nClrBack  := O:nBClrSpH

   FOR nCol := 1 TO Len(aCol)
      oCol := aCol[ nCol ]
      cCol := oCol:cName
      lVirtual := .F.
      FOR EACH cNam IN aColVirt
          IF cCol == cNam
             oCol:nClrBack := { |a,n,b| myTsbColorBackVirt(a,n,b)   }              // ���� ���� � ������� �������
             oCol:nClrFore := { || iif( cNam == "VIRT1", O:nFCDelRec, O:nClr1 ) }  // ���� ������ � ������� �������
             lVirtual := .T.
             EXIT
          ENDIF
      NEXT
      IF cCol == "ORDKEYNO"
         lVirtual := .T.
      ENDIF
      IF !lVirtual
         // ----- ������ ������� ��� ������ ������� --------- ���� �� ����� �� ���� ---------
         //oCol:nClrBack := { |nr,nc,ob| nr:=nc, iif( (ob:cAlias)->( Deleted() ), O:nBCDelRec, O:nClr2 ) }
         //oCol:nClrFore := { |nr,nc,ob| nr:=nc, iif( (ob:cAlias)->( Deleted() ), O:nFCDelRec, O:nClr1 ) }

         // ----- ���.������� ��� ������ ������� ------- ���� ����� �� ���� ----------
         //oCol:nClrBack := { |nr,nc,ob| nr:=nc, iif( Eval(ob:GetColumn("YEAR2"):bData) > 2020 , O:nBCYear, O:nClr2 ) }
         //oCol:nClrFore := { |nr,nc,ob| nr:=nc, iif( Eval(ob:GetColumn("YEAR2"):bData) > 2020 , O:nBCYear2, O:nClr1 ) }
         // ��� ����� ���
         //oCol:nClrBack := { |nr,nc,ob| nr:=nc, iif( (ob:cAlias)->YEAR2 > 2020 , O:nBCYear, O:nClr2 ) }
         //oCol:nClrFore := { |nr,nc,ob| nr:=nc, iif( (ob:cAlias)->YEAR2 > 2020 , O:nBCYear2, O:nClr1 ) }

         // ���� ���� ��� ���� ����� ������ �������  - ��������� �������
         oCol:nClrBack := { |a,n,b| myTsbColorBackLine(a,n,b)   }
         // ���� ������ ��� ���� ����� ������ ������� - ��������� �������
         oCol:nClrFore := { |a,n,b| myTsbColorForeLine(a,n,b)   }
         // ���� ������ ��� �������� ������ �������, ���� ������ :SetColor({5}...) - ���� �������
         oCol:nClrFocuFore := { |nr,nc,ob| nr:=nc, iif( (ob:cAlias)->( DELETED() ), O:nWHITE, O:nClr1 ) }

         // --------- ���. ������� �� ����� ��� ������ ������ ������� -----------
         // ���� ���� � ������� ������� � CARGO > 0
         oCol:nClrBack := { |a,n,b| myTsbColorBackCell(a,n,b)   }
      ENDIF
   NEXT

   // ���� ���� ����� ������� ��� ����������� ������ �������
   FOR EACH cFld IN { "ID", "TS", "VM", "IM", "DT", "TT" }
      IF cFld $ "IM,DT,TT"
         oBrw:GetColumn(cFld):nClrHeadBack := {|| oBrw:Cargo:nORANGE }  // ���� ���� ����� �������
         oBrw:GetColumn(cFld):nClrFootBack := {|| oBrw:Cargo:nORANGE }  // ���� ���� ������� �������
      ELSE
         oBrw:GetColumn(cFld):nClrHeadBack := {|| oBrw:Cargo:nRED }  // ���� ���� ����� �������
         oBrw:GetColumn(cFld):nClrFootBack := {|| oBrw:Cargo:nRED }  // ���� ���� ������� �������
      ENDIF
   NEXT

   /*FOR EACH cFld IN { "ID", "TS", "VM", "IM", "DT", "TT" }
       oCol              := oBrw:GetColumn(cFld)
       // oCol:nClrBack  := { |a,n,b| myTsbColorBack(a,n,b)   }  // ���� ���� � ������� �������
       oCol:nClrHeadBack := { |n,b  | myTsbColorBackHead(n,b) }  // ���� ���� ������� �������
       oCol:nClrFootBack := { |n,b  | myTsbColorBackHead(n,b) }  // ���� ���� ����� �������
       // ��� ������������ ���������� (��������� ���� ���� {|b,n,a| ... } )
       // ��� ����� ���� ������� - ���������� ��� ���������
       // ��� ������(�����) - ���������� ��� ���������
   NEXT*/

RETURN Nil

////////////////////////////////////////////////////////////////////////
// ���� ���� ��� ���� ����� ������ �������  - ��������� �������
STATIC FUNCTION myTsbColorBackLine( nAt, nCol, oBrw )
   LOCAL nColor, nVal, lDel, nI, nRez1 := nAt, nRez2 := nCol
   LOCAL O := oBrw:Cargo  // ������������ �� ���������� ���� ����������

   lDel := (oBrw:cAlias)->( Deleted() )
   // ---- ������ ������� ----
   // ��� ���
   //nVal := Eval(oBrw:GetColumn("YEAR2"):bData)
   // ��� ���
   //nVal := (oBrw:cAlias)->YEAR2
   // ��� ���
   nI   := oBrw:GetColumn("YEAR2")
   nVal := oBrw:GetValue(nI)

   IF VALTYPE(nVal) != "N"     // ��������� ��������� ��������
      nColor := O:nBLACK
   ELSEIF lDel
      nColor := O:nBCDelRec    // ����� ���� ���� �������
   ELSEIF nVal > 2020
      nColor := O:nBCYear      // ����� ���� ���� �������
   ELSE
      nColor := O:nClr2        // ���� ���� �������
   ENDIF

RETURN nColor

////////////////////////////////////////////////////////////////////////
// ���� ������ ��� ���� ����� ������ ������� - ��������� �������
STATIC FUNCTION myTsbColorForeLine( nAt, nCol, oBrw )
   LOCAL nColor, nVal, lDel, nI, nRezerv := nAt := nCol
   LOCAL O := oBrw:Cargo  // ������������ �� ���������� ���� ����������

   lDel := (oBrw:cAlias)->( Deleted() )
   // ---- ������ ������� ----
   // ��� ���
   //nVal := Eval(oBrw:GetColumn("YEAR2"):bData)
   // ��� ���
   //nVal := (oBrw:cAlias)->YEAR2
   // ��� ���
   nI   := oBrw:GetColumn("YEAR2")
   nVal := oBrw:GetValue(nI)

   IF VALTYPE(nVal) != "N"     // ��������� ��������� ��������
      nColor := O:nBLACK
   ELSEIF lDel
      nColor := O:nFCDelRec    // ����� ���� ������ �������
   ELSEIF nVal > 2020
      nColor := O:nFCYear      // ����� ���� ������ �������
   ELSE
      nColor := O:nClr1        // ���� ������ �������
   ENDIF

RETURN nColor

////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbColorBackCell( nAt, nCol, oBrw )  // ��� ������
   LOCAL nColor, nRecnoClrBack, aRecno

   nAt := oBrw:nAtPos
   aRecno := oBrw:Cargo:aRecnoClrBack
   IF nCol > LEN(aRecno)
      //? "����������� ����� ������� oBrw:Cargo:aRecnoClrBack !", LEN(aRecno), nCol
      RETURN CLR_WHITE
   ENDIF

   IF nAt > LEN(aRecno[nCol])
      //? "����������� ����� ������� oBrw:Cargo:aRecnoClrBack[nCol] !", LEN(aRecno[nCol]), nAt
      RETURN CLR_WHITE
   ENDIF

   // ������ ����.�����         // ���-�� ������� - ������
   nRecnoClrBack := oBrw:Cargo:aRecnoClrBack[nCol][nAt]

   IF VALTYPE(nRecnoClrBack) != "N"    // ��������� ��������� ��������
      nColor := CLR_WHITE
   ELSE
      IF nRecnoClrBack > 0
         nColor := nRecnoClrBack       // ����� ����
      ELSE
         nColor := myTsbColorBackLine(nAt, nCol, oBrw)  // ������ ����
      ENDIF
   ENDIF

RETURN nColor

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbColorBackVirt( nAt, nCol, oBrw )  // ������ ����.�������
   LOCAL nVal, nColor, oCargo, nBrowse, nRzv := nAt
   LOCAL O := oBrw:Cargo  // ������������ �� ���������� ���� ����������

   SET WINDOW THIS TO oBrw
      oCargo  := This.Cargo
      nBrowse := oBrw:Cargo:nBrowse      // ����� �������
   SET WINDOW THIS TO

   nVal := oBrw:GetValue(nCol)
   IF HB_ISCHAR(nVal) ; nVal := Val(nVal)
   ENDIF

   IF VALTYPE(nVal) != "N"             // ��������� ��������� ��������
      nColor := O:nBLACK
   ELSEIF nVal == 0
      // ������ ���� ���� �����������
      nColor := O:nBClrSpH
   ELSE
      IF nCol >= 1 .AND. nCol < VIRT_COLUMN_MAX
         nColor := O:aClrVirt[nCol]
         IF nCol == 2  // ������ ��� ������ �������
            IF nBrowse == 0
               nColor := O:nRED
            ELSEIF nBrowse == 1 .OR. nBrowse == 2
               nColor := O:aClrBrw[nBrowse]
            ELSE
               nColor := O:nRED
            ENDIF
         ENDIF
      ELSE
         nColor := O:nWHITE
      ENDIF
   ENDIF

RETURN nColor

//////////////////////////////////////////////////////////////////
// ����������
STATIC FUNCTION mySupHdTsb( oBrw, aSupHd )
   LOCAL O := oBrw:Cargo            // ������������ �� ���������� ���� ����������

   WITH OBJECT oBrw
   :AddSuperHead( 1, :nColCount(), aSupHd[1] )

   // ������ ����� �����������
   :SetColor( {16}, { O:nClr16 } ) // 16, ���� ���������
   :SetColor( {17}, { O:nClr17 } ) // 17, ������ ���������

   END WIDTH

RETURN NIL

/////////////////////////////////////////////////////////////////////////////////////
// ENUMERATOR �� ������� ������� ����
STATIC FUNCTION myEnumTsb( oBrw , nOneCol )
   LOCAL oCol, nI := 0, nCnt := 0
   DEFAULT nOneCol := 1

   FOR EACH oCol IN oBrw:aColumns
      nI++
      oCol:cSpcHeading := NIL
      oCol:cSpcHeading := IIF( nI == nOneCol, "#" , "+" )
      IF nI > nOneCol
         IF oCol:lVisible
            oCol:cSpcHeading := hb_ntos( ++nCnt )
         ENDIF
      ENDIF
   NEXT

RETURN NIL

/////////////////////////////////////////////////////////////////////////////////////
// ��������� ��������������
STATIC FUNCTION mySetEditTsb( oBrw )
   LOCAL i, oCol, cTyp, cCol

   WITH OBJECT oBrw

      // ��������/�������������� ������ ���������
      // ������ ��� ��������, ����� �������� � �� ��������������
      :SetDeleteMode( .T., .F., {|| AlertYesNo(iif((oBrw:cAlias)->(Deleted()), "������������", "�������") + ;
                                                  " ������ � ������� ?", "�������������") } )

      :SetAppendMode( .F. )      // ��������� ������� ������ � ����� ���� �������� ����

      AEval( :aColumns, {|oc|                   // � ������ ��������� edit ���������
                          If oc:lEdit
                             oc:bPrevEdit := {|xv,ob| xv := ! (ob:cAlias)->(Deleted()) }
                          EndIf
                          Return Nil
                        } )

      FOR i := 1 TO Len(:aColumns)

         oCol := :aColumns[ i ]
         cTyp := oCol:cFieldTyp
         cCol := oCol:cName
         // edit �������
         IF cTyp $ "+=^"   // Type: [+] [=] [^]
            oCol:bPrevEdit := {|| AlertStop("It is forbidden to edit this type of field !") , FALSE }
         ENDIF

         IF cCol $ 'VIRT1,VIRT2,VIRT3,VIRT4,VIRT5,VIRT6,'
            // edit ����������� ����� ������� - � �������� �������
            oCol:bLClicked := {|nrp,ncp,nat,obr| myVirtCellClick(1,obr,nrp,ncp,nat) }
            oCol:bRClicked := {|nrp,ncp,nat,obr| myVirtCellClick(2,obr,nrp,ncp,nat) }
         ENDIF

      NEXT

   END WIDTH

RETURN NIL

/////////////////////////////////////////////////////////////////////////////////////
// ��������� ��� ����� �������
STATIC FUNCTION mySetHeadClick( oBrw )
   LOCAL i, oCol

   WITH OBJECT oBrw

      FOR i := 1 TO Len(:aColumns)
         oCol := :aColumns[ i ]
         oCol:bHLClicked := {|nrp,ncp,nat,obr| myAllHeadClick(1,obr,nrp,ncp,nat) }
         oCol:bHRClicked := {|nrp,ncp,nat,obr| myAllHeadClick(2,obr,nrp,ncp,nat) }
      NEXT

   END WIDTH

RETURN NIL

//////////////////////////////////////////////////////////////////
STATIC FUNCTION myVirtCellClick( nClick, oBrw, nRowPix, nColPix )
   LOCAL nRow, nRow2, cNam, cForm, nCol, cCel, cMs
   LOCAL cMsg, cTyp, xVal, oCol, nY, nX, nWCel, nHCel

   cNam  := {'Left mouse', 'Right mouse'}[ nClick ]
   cForm := oBrw:cParentWnd
   nRow  := oBrw:GetTxtRow(nRowPix)             // ����� ������ ������� � �������
   nCol  := Max(oBrw:nAtCol(nColPix, .T.), 1)   // ����� ������� ������� � �������
   nRow2 := oBrw:nAt                            // ����� ������ � �������
   cMs   := cNam + ", y/x: " + hb_ntos(nRowPix) + "/" + hb_ntos(nColPix) + ";;"
   xVal  := oBrw:GetValue(nCol)
   cTyp  := ValType(xVal)
   cCel  := "Cell position row/column: " + hb_ntos(nRow2) + '/' + hb_ntos(nCol) + ";"
   cCel  += "Get Cell value: [" + cValToChar(xVal) + "]    "
   cCel  += "Type Cell: " + cTyp + ";"
   oCol  := oBrw:aColumns[ nCol ]
   cCel  += "Column: " + hb_ntos(nCol) + " [" + oCol:cName + "];;"
   nWCel := oBrw:aColumns[ nCol ]:nWidth       // ������ ������� ������
   nHCel := oBrw:nHeightCell                   // ������ ������� ������

   nY := (nRow2 - 1) * nHCel + oBrw:nTop + oBrw:nHeightHead + oBrw:nHeightSuper
   nY += IIF( oBrw:lDrawSpecHd, oBrw:nHeightSpecHd, 0 )
   nX := oCol:oCell:nCol
   IF _IsControlDefined("Lbl_0", cForm)
      DoMethod(cForm, "Lbl_0", "SetFocus")
   ELSE
      @ nY,nX GETBOX Lbl_0 OF &cForm WIDTH nWCel HEIGHT nHCel ;
        BACKCOLOR YELLOW VALUE "[ "+HB_NtoS(xVal)+" ]" READONLY NOTABSTOP
   ENDIF
   InkeyGui(1000)

   cMsg := 'Only for column: VIRT1,VIRT2,VIRT3,VIRT4,VIRT5,VIRT6 !;;'
   cMsg += 'for more details see the "About" menu,; then the "Virtual table columns" menu'

   AlertInfo( cMs + cCel + cMsg + CRLF, ProcName()+"()" )

   IF _IsControlDefined("Lbl_0", cForm)
      DoMethod(cForm, "Lbl_0", "Release")
   ENDIF

RETURN Nil

////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myAllHeadClick( nClick, oBrw, nRowPix, nColPix, nAt )
   LOCAL cForm, nRow, nCell, cNam, cName, nCol, nIsHS, nLine, oCol
   LOCAL nY, nX, cMsg1, cMsg2, cMsg3, aMsg, nCol0

   cForm := oBrw:cParentWnd
   nRow  := oBrw:GetTxtRow(nRowPix)                 // ����� ������ ������� � �������
   nCol  := Max(oBrw:nAtColActual( nColPix ), 1 )   // ����� �������� ������� ������� � �������
   nCell := oBrw:nCell                              // ����� ������ � �������
   nIsHS := iif(nRowPix > oBrw:nHeightSuper, 1, 2)
   cNam  := {'Left mouse', 'Right mouse'}[ nClick ]
   oCol  := oBrw:aColumns[ nCol ]
   cName := oCol:cName
   nLine := nAt

   nY    := GetProperty(cForm, "Row") + GetTitleHeight()
   nX    := GetProperty(cForm, "Col") + GetBorderWidth() - 4
   // ����� ���������� �� ����� �������
   nY    += GetMenuBarHeight() + oBrw:nTop + 2
   nY    += IIF( oBrw:lDrawSuperHd, oBrw:nHeightSuper, 0 )
   nY    += IIF( oBrw:lDrawHeaders, oBrw:nHeightHead , 0 )
   nX    += oCol:oCell:nCol

   If nIsHS == 2        // ����� SuperHider
      oBrw:SetFocus()
      RETURN NIL
   Else
      // ����� Header
   Endif

   If nClick == 1       // ���� ��������� ����� ������� �����
   Else                 // ���� ��������� ������ ������� �����
   Endif

   cMsg1 := cNam + ", y:x " + hb_ntos(nRowPix) + ":" + hb_ntos(nColPix)
   cMsg2 := "Head position y/x: " + hb_ntos(nY) + '/' + hb_ntos(INT(nX))
   cMsg3 := "Column header: " + hb_ntos(nCol)
   cMsg3 += "-" + hb_ntos( VIRT_COLUMN_MAX ) + "="
   nCol0 := nCol - VIRT_COLUMN_MAX
   cMsg3 += hb_ntos(nCol0) + "  [" + cName + "]"
   aMsg  := { cMsg1, cMsg2, cMsg3 }

   IF cName $ 'VIRT1,VIRT2,VIRT3,VIRT4,VIRT5,VIRT6,ORDKEYNO,'
      // ������� ��������� ���������
      cMsg3 := "Column header: " + hb_ntos(nCol) + " [" + cName + "]"
      aMsg  := { cMsg1, cMsg2, cMsg3 }
      // ���� ����� ����������� �������
      myVirtHeadClick(oBrw, nY, nX, aMsg )
   ELSE
      // ���� ����� ������� �������
      myHeadClick(oBrw, nY, nX, aMsg )
   ENDIF

RETURN Nil

////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myVirtHeadClick( oBrw, nY, nX, aMsg )
   LOCAL cForm, hFont1, hFont2, hFont3

   cForm  := oBrw:cParentWnd
   hFont1 := GetFontHandle( "TsbEdit"   )
   hFont2 := GetFontHandle( "TsbSuperH" )
   hFont3 := GetFontHandle( "TsbBold"   )

   DEFINE CONTEXT MENU OF &cForm
      MENUITEM  "Show virtual columns"         ACTION  {|| myShowHideColumn(1,oBrw) } FONT hFont2
      MENUITEM  "Hide virtual columns"         ACTION  {|| myShowHideColumn(2,oBrw) } FONT hFont2
      SEPARATOR
      Popup 'Filter by virtual column ???'  FONT hFont3
         MENUITEM  "Filter by virtual column (1)"  ACTION  {|| myFilter(1,oBrw) }  FONT hFont2
         MENUITEM  "Filter by virtual column (2)"  ACTION  {|| myFilter(2,oBrw) }  FONT hFont2
         MENUITEM  "Filter by virtual column (3)"  ACTION  {|| myFilter(3,oBrw) }  FONT hFont2
         MENUITEM  "Filter by virtual column (4)"  ACTION  {|| myFilter(4,oBrw) }  FONT hFont2
         MENUITEM  "Filter by virtual column (5)"  ACTION  {|| myFilter(5,oBrw) }  FONT hFont2
         MENUITEM  "Filter by virtual column (6)"  ACTION  {|| myFilter(6,oBrw) }  FONT hFont2
      End Popup
      MENUITEM  "Filter by all virtual column"  ACTION  {|| myFilter(0,oBrw)  }  FONT hFont3
      MENUITEM  "Clear table filter"            ACTION  {|| myFilter(99,oBrw) }  FONT hFont3
      SEPARATOR
      MENUITEM  "Exit"                          ACTION  {|| oBrw:SetFocus() } FONT hFont3
      SEPARATOR
      MENUITEM  aMsg[1] DISABLED  FONT hFont1
      MENUITEM  aMsg[2] DISABLED  FONT hFont1
      MENUITEM  aMsg[3] DISABLED  FONT hFont1
   END MENU

   _ShowContextMenu(cForm, nY, nX, .f. ) // SHOWING DROP OUT MENU
   InkeyGui(100)

   DEFINE CONTEXT MENU OF &cForm         // delete menu after exiting
   END MENU

   DO EVENTS

   oBrw:SetFocus()
   oBrw:DrawSelect()

RETURN Nil

///////////////////////////////////////////////////////////////////////
STATIC FUNCTION myHeadClick( oBrw, nY, nX, aMsg )
   LOCAL cForm, hFont1, hFont2, hFont3

   cForm  := oBrw:cParentWnd
   hFont1 := GetFontHandle( "TsbEdit"   )
   hFont2 := GetFontHandle( "TsbSuperH" )
   hFont3 := GetFontHandle( "TsbBold"   )

   DEFINE CONTEXT MENU OF &cForm
       MENUITEM  aMsg[3]  ACTION  {|| MsgDebug(aMsg[3]) } FONT hFont2
       MENUITEM  "Exit"   ACTION  {|| oBrw:SetFocus() } FONT hFont3
       SEPARATOR
       MENUITEM  aMsg[1] DISABLED  FONT hFont1
       MENUITEM  aMsg[2] DISABLED  FONT hFont1
   END MENU

   _ShowContextMenu(cForm, nY, nX, .f. ) // SHOWING DROP OUT MENU
   InkeyGui(100)

   DEFINE CONTEXT MENU OF &cForm         // delete menu after exiting
   END MENU

   DO EVENTS

   oBrw:SetFocus()
   oBrw:DrawSelect()

RETURN Nil

//////////////////////////////////////////////////////////////////
// ��������/������ ������� �� �����������
STATIC FUNCTION myShowHideColumn( nShowHide, oBrw )
   LOCAL oCol, cCol, cListCol, nCol, aDimCol := {}
   LOCAL aCol := oBrw:aColumns

   // ������ �������
   cListCol := ",VIRT1,VIRT2,VIRT3,VIRT4,VIRT5,VIRT6,"

   FOR nCol := 1 TO Len(aCol)
      oCol := aCol[ nCol ]
      cCol := oCol:cName
      IF ","+cCol+"," $ cListCol
         AADD( aDimCol , nCol )
      ENDIF
   NEXT

   IF nShowHide == 1
      oBrw:HideColumns( aDimCol ,.f.)   // �������� �������
   ELSE
      oBrw:HideColumns( aDimCol ,.t.)   // ������ �������
   ENDIF

RETURN Nil

//////////////////////////////////////////////////////////////////
STATIC FUNCTION CreateDatos1( cFile, cAlias, cCdp, cVia )
   LOCAL aDatos, aSupHd

   aDatos := CreateDatos(cFile, cAlias, cCdp)

   IF Empty( aDatos ) ; RETURN aDatos   // File not found !
   ENDIF

   // ����������
   aSupHd     := { cFile }

   IF ! empty(cCdp) ; aSupHd[1] += '   [ ' + cCdp + ' ] '
   ENDIF

   IF ! empty(cVia) ; aSupHd[1] += '   [ ' + cVia + ' ] '
   ENDIF

   IF ! empty(cAlias) ; aSupHd[1] += '   [ Alias: ' + cAlias + ' ]'
   ENDIF

   AAdd( aDatos, aSupHd )  // ������� � aDatos ������ aSupHd

RETURN aDatos

//////////////////////////////////////////////////////////////////
STATIC FUNCTION CreateDatos2( cFile, cAlias, cCdp, cVia )
   LOCAL aDatos, aSupHd

   aDatos := CreateDatos(cFile, cAlias, cCdp)

   IF Empty( aDatos ) ; RETURN aDatos   // File not found !
   ENDIF

   // ����������
   aSupHd     := { cFile }

   IF ! empty(cCdp) ; aSupHd[1] += '   [ ' + cCdp + ' ] '
   ENDIF

   IF ! empty(cVia) ; aSupHd[1] += '   [ ' + cVia + ' ] '
   ENDIF

   IF ! empty(cAlias) ; aSupHd[1] += '   [ Alias: ' + cAlias + ' ]'
   ENDIF

   AAdd( aDatos, aSupHd )  // ������� � aDatos ������ aSupHd

RETURN aDatos

//////////////////////////////////////////////////////////////////
STATIC FUNCTION CreateDatos( cFile, cAlias, cCdp )
   LOCAL aDatos, i, k, n, p
   LOCAL aHead, aSize, aFoot, aPict, aAlign, aName, aField, aFAlign

   IF hb_FileExists( cFile )

      IF Empty(cCdp) ; USE &(cFile) ALIAS (cAlias) SHARED NEW
      ELSE           ; USE &(cFile) ALIAS (cAlias) SHARED NEW CODEPAGE cCdp
      ENDIF

   ELSE

      MsgStop('File Dbf not found !' + CRLF + cFile  + CRLF + ProcName() , "ERROR")
      RETURN NIL

   ENDIF

   n       := 6
   k       := fCount()+n
   aHead   := array(k)
   aFoot   := array(k)
   aPict   := array(k)
   aName   := array(k)
   aAlign  := array(k)
   aField  := array(k)
   aSize   := array(k)
   aFAlign := array(k)       // Footer align

   FOR i := 1 TO k
       p := iif( i > n, i - n, 1 )
       aHead  [ i ] := FieldName( p )
       aFoot  [ i ] := hb_ntos  ( p )
       aName  [ i ] := FieldName( p )
       aField [ i ] := FieldName( p )
       aFAlign[ i ] := DT_CENTER
       aAlign [ i ] := DT_CENTER
       IF i > n
          switch FieldType( p )
             case 'C' ; aAlign[ i ] := DT_LEFT   ; exit
             case 'M' ; aAlign[ i ] := DT_LEFT   ; exit
             case 'N' ; aAlign[ i ] := DT_RIGHT  ; exit
          end switch
       ENDIF
   NEXT

   aDatos := ALIAS()
   aSize  := NIL // array(k) - ������ ����� ������� �������� ��� tsbrowse

RETURN { aDatos, aHead, aSize, aFoot, aPict, aAlign, aName, aField, aFAlign }

/////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myFont( lCreate, nFSDef )
   LOCAL aFont := {}, cFont
   DEFAULT nFSDef := _HMG_DefaultFontSize

   // ������� ������ ���� ������ ��� ������� ��� ������� ��
   AAdd( aFont, "TsbNorm"   )
   AAdd( aFont, "TsbBold"   )
   AAdd( aFont, "TsbSpecH"  )
   AAdd( aFont, "TsbSuperH" )
   AAdd( aFont, "TsbEdit"   )

   IF empty(lCreate)
      FOR EACH cFont IN aFont ; _ReleaseFont( cFont )
      NEXT
   ELSE
      DEFINE FONT TsbNorm   FONTNAME "DejaVu Sans Mono"   SIZE nFSDef
      DEFINE FONT TsbBold   FONTNAME "Tahona"             SIZE nFSDef BOLD
      DEFINE FONT TsbSpecH  FONTNAME _HMG_DefaultFontName SIZE nFSDef BOLD
      DEFINE FONT TsbSuperH FONTNAME "Comic Sans MS"      SIZE nFSDef + 2 BOLD
      DEFINE FONT TsbEdit   FONTNAME "DejaVu Sans Mono"   SIZE nFSDef BOLD
   ENDIF

RETURN .T.

/////////////////////////////////////////////////////////////////////////////////
FUNCTION myVirtColumColorSaveCell(oBrw)
   LOCAL i, cAls, nRecno, nBrowse, nKolvo, aSum, cSumm, cName, nSum, nCol
   LOCAL aBrwVirt1, aBrwVirt2, aBrwVirt3, aBrwVirt4, aBrwVirt5, aBrwVirt6
   LOCAL nBColor, nClr2VCol
   LOCAL O := oBrw:Cargo  // ������������ �� ���������� ���� ����������

   WaitWindow( "Wait, checking in progress", .T. )

   nBrowse   := oBrw:Cargo:nBrowse       // ����� �������
   aBrwVirt1 := oBrw:Cargo:aBrwVirt[1]   // ����������� �������
   aBrwVirt2 := oBrw:Cargo:aBrwVirt[2]   // ����������� �������
   aBrwVirt3 := oBrw:Cargo:aBrwVirt[3]   // ����������� �������
   aBrwVirt4 := oBrw:Cargo:aBrwVirt[4]   // ����������� �������
   aBrwVirt5 := oBrw:Cargo:aBrwVirt[5]   // ����������� �������
   aBrwVirt6 := oBrw:Cargo:aBrwVirt[6]   // ����������� �������

   cAls     := oBrw:cAlias
   nRecno   := (cAls)->( RecNo() )
   nKolvo   := LastRec()
   aSum     := array(6)
   AFILL( aSum, 0 )

   // ����� ���� �� ������� ����.�������
   IF nBrowse == 1 .OR. nBrowse == 2
      nClr2VCol := O:aClrBrw[nBrowse]
   ELSE
      nClr2VCol := O:nWHITE
   ENDIF

   (cAls)->( dbGotop() )
   DO WHILE (cAls)->( !EOF() )

      i := (cAls)->( RecNo() )
      // �������� ������ ����������� ������ ����� ��� ������ ������ �������
      // �� ������ ������� #, �.�. ����. ������� ������
      FOR nCol := oBrw:nColumn("ORDKEYNO") TO Len( oBrw:aColumns )
         nBColor := myTsbColorBackLine(i, nCol, oBrw)   // ���� ������ ������
         oBrw:Cargo:aRecnoClrBack[nCol][i] := nBColor
      NEXT

      IF (cAls)->( DELETED() ) // �������� ������
         aBrwVirt1[ i ] := 1
         aSum[1] += 1
      ENDIF

      IF "DMITROV" $ UPPER((cAls)->CITY)
         aBrwVirt2[ i ] := 1
         aSum[2] += 1
         nCol := oBrw:nColumn("CITY")
         oBrw:Cargo:aRecnoClrBack[nCol][i] := nClr2VCol  // ������ ������ ���� ����
      ENDIF

      IF "GAGARIN" $ UPPER((cAls)->STREET)
         aBrwVirt3[ i ] := 1
         aSum[3] += 1
         nCol := oBrw:nColumn("STREET")
         oBrw:Cargo:aRecnoClrBack[nCol][i] := O:nHBLUE2  // ������ ������ ���� ����
      ENDIF

      IF (cAls)->YEAR2 > 2020
         aBrwVirt4[ i ] := 1
         aSum[4] += 1
         nCol := oBrw:nColumn("YEAR2")
         oBrw:Cargo:aRecnoClrBack[nCol][i] := O:nBCYear2   // ������ ������ ���� ����
      ENDIF

      IF (cAls)->DOLG2014 < 0
         aBrwVirt5[ i ] := 1
         aSum[5] += 1
         nCol := oBrw:nColumn("DOLG2014")
         oBrw:Cargo:aRecnoClrBack[nCol][i] := O:nHRED  // ������ ������ ���� ����
      ENDIF

      IF (cAls)->DOLG2015 < 0
         aBrwVirt6[ i ] := 1
         aSum[6] += 1
         nCol := oBrw:nColumn("DOLG2015")
         oBrw:Cargo:aRecnoClrBack[nCol][i] := O:nPURPLE2  // ������ ������ ���� ����
      ENDIF
      (cAls)->( dbSkip() )
   ENDDO
   (cAls)->( dbGoto(nRecno) )

   oBrw:GetColumn(1):Cargo := aBrwVirt1
   oBrw:GetColumn(2):Cargo := aBrwVirt2
   oBrw:GetColumn(3):Cargo := aBrwVirt3
   oBrw:GetColumn(4):Cargo := aBrwVirt4
   oBrw:GetColumn(5):Cargo := aBrwVirt5
   oBrw:GetColumn(6):Cargo := aBrwVirt6

   oBrw:Cargo:aSum := AClone(aSum)

   // ����� ������� ����������� �������
   FOR i := 1 TO LEN(aSum)
      nSum := aSum[ i ]
      IF nSum > 0
         cSumm := hb_ntos(nSum)
         cName := "VIRT" + hb_ntos(i)
         oBrw:GetColumn(cName):cFooting := cSumm
      ENDIF
   NEXT
   oBrw:DrawFooters()

   WaitWindow()     // ������� ���� ���������

   oBrw:Refresh()
   oBrw:SetFocus()
   DO EVENTS

RETURN NIL

//////////////////////////////////////////////////////////////////
// ������ �� �������
STATIC FUNCTION myFilter(nFilter,oBrw)
   LOCAL cFilt, cFltr := "["+oBrw:cParentWnd+"], ["+oBrw:cControlName+"]"
   LOCAL aVirt, oCol, cAls, i, nRec, aSum := array( VIRT_COLUMN_END )

   // ������� ������� �� ������� �������
   IF     nFilter == 1
      oBrw:Cargo:cFilter := "DELETED()"
   ELSEIF nFilter == 2
      oBrw:Cargo:cFilter := "CITY"
   ELSEIF nFilter == 3
      oBrw:Cargo:cFilter := "STREET"
   ELSEIF nFilter == 4
      oBrw:Cargo:cFilter := "YEAR2"
   ELSEIF nFilter == 5
      oBrw:Cargo:cFilter := "DOLG2014"
   ELSEIF nFilter == 6
      oBrw:Cargo:cFilter := "DOLG2015"
   ELSEIF nFilter == 99
      oBrw:Cargo:cFilter := ""                       // �������� ������� �������
   ENDIF

   IF     nFilter == 99                              // �������� ������
      oBrw:Cargo:nFilter := 0                        // ��� ������� �� �������
      // ������� ����� ���� ����� ������� ����������� �������
      FOR i := 1 TO VIRT_COLUMN_END
         oBrw:aColumns[ i ]:nClrHeadBack := oBrw:Cargo:nClr4
      NEXT
   ELSEIF nFilter == 0                               // ������ �� ���� �����
      cFilt := "myAllVirtFltr( " + cFltr + " )"
      oBrw:Cargo:nFilter := 100                                  // ����� ������� �� �������
      oBrw:Cargo:cFilter := "ALL VIRTUAL COLUMNS OF THE TABLE"   // �� ���� ����.��������
      // ���� ���� ����� ������� ����������� ������� �� �������
      FOR i := 1 TO VIRT_COLUMN_END
         oBrw:aColumns[ i ]:nClrHeadBack := oBrw:Cargo:nORANGE
      NEXT
   ELSE
      cFilt := "myOneVirtFltr( "+hb_ntos(nFilter)+", " + cFltr + " )"
      oBrw:Cargo:nFilter := nFilter                  // ����� ������� ��� ������� �� �������
      // ������� ����� ���� ����� ������� ����������� �������
      FOR i := 1 TO VIRT_COLUMN_END
         oBrw:aColumns[ i ]:nClrHeadBack := oBrw:Cargo:nClr4
      NEXT
      // ���� ���� ����� ������� ����������� ������� �� ������� - ������� ������
      oBrw:aColumns[ nFilter ]:nClrHeadBack := oBrw:Cargo:nORANGE
   ENDIF

   oBrw:FilterData(cFilt)

   // ����� ������� ����������� �������
   AFill(aSum, 0)
   cAls := oBrw:cAlias
   DO WHILE (cAls)->( !EOF() )
      nRec := (cAls)->( RecNo() )
      FOR i := 1 TO VIRT_COLUMN_END
          aVirt := oBrw:Cargo:aBrwVirt[ i ]   // ����������� �������
          IF nRec <= Len( aVirt ) .and. aVirt[ nRec ] > 0
             aSum[ i ] += 1
          ENDIF
      NEXT
      (cAls)->( dbSkip() )
   ENDDO
   (cAls)->( dbGotop() )

   FOR i := 1 TO VIRT_COLUMN_END
       oCol := oBrw:aColumns[ i ]
       oCol:cFooting := iif( aSum[ i ] > 0, hb_ntos(aSum[ i ]), "" )
   NEXT
   oBrw:DrawHeaders(.T.)

   oBrw:SetFocus()

RETURN Nil

/////////////////////////////////////////////////////////////////////////////////
// ����� ����� ��� � dbf (VIRT1,VIRT2,...), ��� ������� ���� ������ �������,
// ������� ����������� ��� ������ ������ � ���������� .T. ��� .F.
FUNCTION myAllVirtFltr( cForm, cBrw )
   Local oWnd   := _WindowObj(cForm)
   Local oBrw   := oWnd:GetObj(cBrw):Tsb
   Local nRec   := (oBrw:cAlias)->(RecNo())
   Local aVirt1 := oBrw:Cargo:aBrwVirt[ 1 ]
   Local aVirt2 := oBrw:Cargo:aBrwVirt[ 2 ]
   Local aVirt3 := oBrw:Cargo:aBrwVirt[ 3 ]
   Local aVirt4 := oBrw:Cargo:aBrwVirt[ 4 ]
   Local aVirt5 := oBrw:Cargo:aBrwVirt[ 5 ]
   Local aVirt6 := oBrw:Cargo:aBrwVirt[ 6 ]
   Local lRet   := .F.

   IF nRec > 0 .and. nRec <= Len(aVirt1)
      lRet  := aVirt1[ nRec ] > 0 .or. aVirt2[ nRec ] > 0 .or. aVirt3[ nRec ] > 0 .or. ;
               aVirt4[ nRec ] > 0 .or. aVirt5[ nRec ] > 0 .or. aVirt6[ nRec ] > 0
   ENDIF

RETURN lRet

/////////////////////////////////////////////////////////////////////////////////
// ����� ����� ��� � dbf (VIRT1,VIRT2,...), ��� ������� ���� ������ �������,
// ������� ����������� ��� ������ ������ � ���������� .T. ��� .F.
FUNCTION myOneVirtFltr( nVirtCol, cForm, cBrw )
   Local oWnd  := _WindowObj(cForm)
   Local oBrw  := oWnd:GetObj(cBrw):Tsb
   Local nRec  := (oBrw:cAlias)->(RecNo())
   Local aVirt := oBrw:Cargo:aBrwVirt[ nVirtCol ]
   Local lRet  := .F. //aVirt[ nRec ] > 0

   IF nRec > 0 .and. nRec <= Len(aVirt)
      lRet  := aVirt[ nRec ] > 0
   ENDIF

RETURN lRet

/////////////////////////////////////////////////////////////////////////////////
FUNCTION MsgAbout()
   LOCAL cMsg

   cMsg := SHOW_TITLE + ";;"
   cMsg += "(c) 2020 Verchenko Andrey <verchenkoag@gmail.com>;"
   cMsg += "(c) 2020 Sergej Kiselev <bilance@bilance.lv>;;"
   cMsg += hb_compiler() + ";" + Version() + ";" + MiniGuiVersion() + ";"
   cMsg += "(c) Grigory Filatov http://www.hmgextended.com;;"
   cMsg += PadC( "This program is Freeware!", 60 ) + ";"
   cMsg += PadC( "Copying is allowed!", 60 ) + ";"

   AlertInfo( cMsg, "About this demo", , , {RED} , , )

RETURN NIL

/////////////////////////////////////////////////////////////////////////////////
FUNCTION MsgVirtColunm()
   LOCAL cMsg

   cMsg := SHOW_TITLE + ";;"
   cMsg += "�������� ����������� ������� �������, � �������� �������:;"
   cMsg += "(1) - ��������� ������ ;"
   cMsg += "(2) - � ������� CITY ���������� ����� DMITROV ;"
   cMsg += "(3) - � ������� STREET ���������� ����� GAGARIN ;"
   cMsg += "(4) - YEAR2 > 2020;"
   cMsg += "(5) - DOLG2014 < 0;"
   cMsg += "(6) - DOLG2015 < 0;;"
   cMsg += "Description of virtual table columns, as an example:;"
   cMsg += "(1) - deleted record;"
   cMsg += "(2) - the CITY column contains the word DMITROV;"
   cMsg += "(3) - the STREET column contains the word GAGARIN;"
   cMsg += "(4) - YEAR2 > 2020;"
   cMsg += "(5) - DOLG2014 < 0;"
   cMsg += "(6) - DOLG2015 < 0"

   AlertInfo( cMsg, "About virtual table columns", , , {RED} , , )

RETURN NIL

/////////////////////////////////////////////////////////////////////////////////
FUNCTION MsgVirtHeadColunm()
   LOCAL cMsg

   cMsg := SHOW_TITLE + ";;"
   cMsg += "����� �������� ������ �� ����� ����������� �������� �������:;"
   cMsg += "1) ��������/������ ����������� �������;"
   cMsg += "2) ������ �� ����������� ��������;;"
   cMsg += "You need to click on the header of the virtual columns of the table:;"
   cMsg += "1) Show / hide virtual speakers;"
   cMsg += "2) Filter by virtual columns"

   AlertInfo( cMsg, "About virtual table columns", , , {RED} , , )

RETURN NIL

/////////////////////////////////////////////////////////////////////////////////
FUNCTION MsgInfoHeader()
   LOCAL cMsg

   cMsg := SHOW_TITLE + ";;"
   cMsg += "�������� ������/����� ������� ���� �� ����� ������� �������:;"
   cMsg += "����� ������������ ���� ��� ������� ����� �������;;"
   cMsg += "Click with the right/left mouse button on the header of the table columns:;"
   cMsg += "Show context menu for table header columns"

   AlertInfo( cMsg, "About virtual table columns", , , {RED} , , )

RETURN NIL

/////////////////////////////////////////////////////////////////////////////////
FUNCTION myFilterTsb(oBrw)
   LOCAL cMsg, cFlt := ( oBrw:cAlias )->( dbFilter() )

   cMsg := SHOW_TITLE + ";;"
   cMsg += "������ �� ���� = "
   cMsg += IIF( LEN(cFlt) == 0, '���', '����' ) + ";"
   cMsg += "Filter by base = "
   cMsg += IIF( LEN(cFlt) == 0, 'no', 'there is' ) + ";"
   cMsg += "(" + oBrw:cAlias + ")->( dbFilter() ) = " + IIF( LEN(cFlt) == 0, '""', cFlt )
   cMsg += ";;"
   cMsg += "����� ������� �� ������� = " + HB_NtoS(oBrw:Cargo:nFilter) + ";"
   cMsg += "������� ������� �� ������� ������� = " + oBrw:Cargo:cFilter + ";;"
   cMsg += "Filter number for the table = " + HB_NtoS(oBrw:Cargo:nFilter) + ";"
   cMsg += "Filter condition by table column = " + oBrw:Cargo:cFilter + ";"

   AlertInfo( cMsg, "About virtual table columns", , , {LGREEN} , , )

RETURN NIL
