/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2020 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2020 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * ����������� ������� � Tsbrowse ��� dbf-�����
 * ����������� 2-� dbf � ���� �������
 * ���� ������ � ���� ����� ���������� �� ��������� ��
 * ������ �� ����������� ��������, ����� �� ����������� ��������
 * ������� Dbf-���� � ������ ����� HB_MEMIO
 * Virtual columns in Tsbrowse for dbf file
 * Combining 2 dbf into one table
 * The color of the text and background of the cells is written to the temporary database
 * Filter by virtual columns, colors by virtual columns
 * Create Dbf file in memory via HB_MEMIO
*/

#define _HMG_OUTLOG
#define SHOW_TITLE  "Virtual columns in Tsbrowse / Combining 2 dbf into one table ( " + cFileNoPath(App.ExeName) + " )"
#define VIRT_COLUMN_1      1
#define VIRT_COLUMN_2      2
#define VIRT_COLUMN_3      3
#define VIRT_COLUMN_4      4
#define VIRT_COLUMN_5      5
#define VIRT_COLUMN_6      6
#define VIRT_COLUMN_END    6
#define VIRT_COLUMN_MAX    ( VIRT_COLUMN_END + 1 )
#define NAME_FILE          1
#define NAME_ALIAS         2
#define NAME_CDP           3
#define NAME_VIA           4
#define NAME_TEMP          5
#define NAME_TEMP_ALIAS    6


#include "minigui.ch"
#include "TSBrowse.ch"

REQUEST HB_CODEPAGE_UTF8, HB_CODEPAGE_RU866, HB_CODEPAGE_RU1251
REQUEST DBFNTX, DBFCDX, DBFFPT
REQUEST HB_MEMIO

MEMVAR oPubApp    // ����� ��� ������ ( ��� ���� ������� ����� � *.ch ����� ����������� )
//////////////////////////////////////////////////////////////////////
PROCEDURE Main( cFile, cTmpPath )
   LOCAL cFile1, cAls1, cCdp1, cVia1, cFile2, cAls2, cCdp2, cVia2
   LOCAL oBrw1, oBrw2, nY, nX, nW, nH, nC, nWPrt, cFileTmp1, cFileTmp2
   LOCAL hFont1, hFont2, hFont3, cPthStart, cPthTmp
   LOCAL cAlsTmp1, cAlsTmp2, lOpen1, lOpen2, aSupHd1, aSupHd2
   LOCAL cFont := "Arial"
   LOCAL nSize := 12
   LOCAL lTmpErase  := .T.              // ������� tmp �����, ���� ��� �� � mem:
   Default cTmpPath := '.\', cFile := "demo.dbf"

   SET CODEPAGE TO RUSSIAN
   SET LANGUAGE TO RUSSIAN

   RddSetDefault( 'DBFCDX' )

   SET DECIMALS  TO 4
   SET EPOCH     TO 2000
   SET DATE      TO GERMAN
   SET CENTURY   ON
   SET DELETED   OFF
   SET AUTOPEN   ON                                         // ������������� ��������� ��������� �����
   SET EXACT     ON
   SET EXCLUSIVE ON
   SET SOFTSEEK  ON
   SET OOP ON
   SET MSGALERT BACKCOLOR TO { 141, 179, 226 }               // for HMG_Alert()
   DEFINE FONT DlgFont  FONTNAME "DejaVu Sans Mono" SIZE 12  // for HMG_Alert()
   SET MENUSTYLE EXTENDED                                    // switch menu style to advanced
   SetMenuBitmapHeight( 20 )                                 // set icon size 20x20

   SET DEFAULT ICON TO "1MAIN_ICO"
   SET FONT TO cFont, nSize

   // � �������� ������� ��� �������� ��������.  !!! ����� ������� SET OOP ON
   PUBLIC oPubApp                                    // ������ ��������, ������� ������
   oPubApp := oKeyData()                             // ������� ������ (���������) ��� PUBLIC ����������
   oPubApp:cCurDir  := GetStartUpFolder() + "\"
   oPubApp:cDbfDir  := oPubApp:cCurDir + "DBASE" + "\"
   oPubApp:cLogFile := oPubApp:cCurDir + "_Msg.log"
   oPubApp:aBColor  := SILVER                        // Color window
   oPubApp:cTmpPath := cTmpPath
   oPubApp:cFile    := cFile

   _SetGetLogFile( oPubApp:cLogFile ) ; fErase( _SetGetLogFile() )

   cPthTmp    := oPubApp:cTmpPath      // �������/������� � ������� ����� ��� mem:
   cPthStart  := oPubApp:cCurDir       // ���. �������

   // ������� ������ (���������) ��� ���������� (App.) � ������� ������ ����������
   WITH OBJECT (App.Object):Cargo := myAppCargoInit( cPthStart, cPthTmp, cFile, lTmpErase )
      cFile1     := :aFile1[ NAME_FILE  ]
      cFile2     := :aFile2[ NAME_FILE  ]
      cAls1      := :aFile1[ NAME_ALIAS ]
      cAls2      := :aFile2[ NAME_ALIAS ]
      cCdp1      := :aFile1[ NAME_CDP   ]
      cCdp2      := :aFile2[ NAME_CDP   ]
      cVia1      := :aFile1[ NAME_VIA   ]
      cVia2      := :aFile2[ NAME_VIA   ]
      cFileTmp1  := :aFile1[ NAME_TEMP  ]
      cFileTmp2  := :aFile2[ NAME_TEMP  ]
      cAlsTmp1   := :aFile1[ NAME_TEMP_ALIAS ]
      cAlsTmp2   := :aFile2[ NAME_TEMP_ALIAS ]
      aSupHd1    := :aSupHd1 // ���������� �������-1
      aSupHd2    := :aSupHd2 // ���������� �������-2
   END WITH

   // ������� ��������� ���� �� ������������ ����
   lOpen1 := CreateMemTmp( cFile1, cAls1, cCdp1, cVia1, cAlsTmp1, cFileTmp1 )
   lOpen2 := CreateMemTmp( cFile2, cAls2, cCdp2, cVia2, cAlsTmp2, cFileTmp2 )

   IF !lOpen1 .or. !lOpen2 ; QUIT
   ENDIF

   myFont( .T., nSize )  // ��������� ���� ����� ��� �������

   hFont1  := GetFontHandle( "TsbNorm"   )
   hFont2  := GetFontHandle( "TsbBold"   )
   hFont3  := GetFontHandle( "TsbSuperH" )

   nY := nX := 0

   DEFINE WINDOW Form_Main                             ;
      TITLE          SHOW_TITLE                        ;
      BACKCOLOR      oPubApp:aBColor                   ;
      MAIN TOPMOST   NOMAXIMIZE NOSIZE                 ;
      ON INIT {|| This.Topmost := .F., _wPost(5) }     ;         // _wPost ���. ��� ���������� ON INIT
      ON RELEASE {|| CloseMemTmp(cFileTmp1, cAlsTmp1), ;         // ������ �������, �.�. ���� mem:,
                     CloseMemTmp(cFileTmp2, cAlsTmp2), ;         // �� ���� ����������� �����
                     DbCloseAll(), myFont() }                    // dbDrop(cTmp, cTmp, 'DBFCDX')

      (This.Object):Cargo := oKeyData()         // ������� ������ (���������) ��� ���� Form_Main
      (This.Object):Cargo:oBrwFocus := Nil

      (This.Object):Event(1, {|| myVirtColumColorSaveCell(1) })  // ���������� ����. 1
      (This.Object):Event(2, {|| myVirtColumColorSaveCell(2) })  // ���������� ����. 2
      (This.Object):Event(3, {|| myColorsInitTempDbf(1) })       // ������ ����� � tempDBF 1
      (This.Object):Event(4, {|| myColorsInitTempDbf(2) })       // ������ ����� � tempDBF 2
      (This.Object):Event(5, {|| _wSend(3), _wSend(4) } )

      nW := This.ClientWidth       // ������ ����

      DEFINE MAIN MENU
         POPUP "Test tbrowse" FONT hFont3
            ITEM "Put color in virtual columns tbrowse-1" ACTION _wPost(1) FONT hFont1
            ITEM "Put color in virtual columns tbrowse-2" ACTION _wPost(2) FONT hFont1
            SEPARATOR
            ITEM "F3: ListColumn tbrowse-1"  ACTION  myListColumn(oBrw1) FONT hFont1
            ITEM "F3: ListColumn tbrowse-2"  ACTION  myListColumn(oBrw2) FONT hFont1
            SEPARATOR
            ITEM "What filter is tbrowse-1"  ACTION  myFilterTsb(oBrw1) FONT hFont1
            ITEM "What filter is tbrowse-2"  ACTION  myFilterTsb(oBrw2) FONT hFont1
            SEPARATOR
            ITEM "Exit"                      ACTION  _wPost(99)         FONT hFont3
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

      oBrw1 := myBrw( nY, nX, nW, nH, 1, cAlsTmp1, cAls1, aSupHd1 )

      /////////////// ������ ������� ///////////////////
      nY += nH
      nH := nC - nH

      oBrw2 := myBrw( nY, nX, nW, nH, 2, cAlsTmp2, cAls2, aSupHd2 )

      ON KEY ESCAPE ACTION {|| iif( oBrw2:IsEdit, oBrw2:SetFocus(), ;
                               iif( oBrw1:IsEdit, oBrw1:SetFocus() , _wPost(99) ) ) }

      WITH OBJECT This.Object
        :Cargo:oBrw1 := oBrw1               // �� ���� ���������, ������ tsb ��� �������
        :Cargo:oBrw2 := oBrw2               // �� ���� ���������, ������ tsb ��� �������
        :Event( 99, {|ow| ow:Release() } )  // ����� �� ESC
        :Event(500, {|  | NIL })            // ����. ���� �������� � myVirtHeadClick(...)
      END WITH

      This.Minimize ;  This.Restore ; DO EVENTS

      oBrw1:SetFocus()  // ����� �� ������� 1

   END WINDOW

   ACTIVATE WINDOW Form_Main

RETURN

////////////////////////////////////////////////////////////////////////
// ������� � ���������� ���������� ���� ���������� � �������
STATIC FUNCTION myAppCargoInit( cPath, cPthTmp, cFile, lTmpErase )
   LOCAL o, aTmp, nTmp, cTmp, nSize, cFile1, cFile2
   Default cPath := ".\", cPthTmp := ".\"
   Default cFile := "demo.dbf"
   Default lTmpErase := .T.

   WITH OBJECT o := oKeyData()               // ������� ���������
      :aFile1    := { cPath+cFile, "ONE", "RU866", RddSetDefault(), cPthTmp+"tmpONE.DBF", "MEMOONE"  }
      :aFile2    := { cPath+cFile, "TWO", "RU866", RddSetDefault(), cPthTmp+"tmpTWO.DBF", "MEMOTWO"  }
      :lTmpErase := lTmpErase                // ������� tmp �����, ���� ��� �� � mem:
      :nTmp2memSize :=  50                   // ���� LastRec > 50 ��, �� ������ �� TmpFile
      :nWaitWndMax  := 1000                  // ���� � �� ������ 1000 �������
      :nWaitWndCnt  := 250                   // ������� ������� ��� ������ ��������� ����� Color
      :nWaitWndCrt  :=  50                   // ������� ������� ��� ������ ��������� ����� Create
      :nWaitWndSave :=  50                   // ������� ������� ��� ������ ��������� ����� Save
      // ���� �������� tmpXXX.DBF
      nSize := FILESIZE( :aFile1[ NAME_FILE ] ) / 1024 / 1024
      IF nSize == 0
         // �������, ��� ������ �����
      ELSEIF nSize < :nTmp2memSize  // ��
         cPthTmp    := "mem:"       // �������/������� � ������ ����� HB_MEMIO
         //cPthTmp    := ".\"       // ����������
         :aFile1[ NAME_TEMP ] := cPthTmp + "tmpONE.DBF"
         :aFile2[ NAME_TEMP ] := cPthTmp + "tmpTWO.DBF"
      ELSE
         cPthTmp    := GetUserTempFolder() + "\"
         cFile1     := cPthTmp + "tmpONE.DBF"
         cFile2     := cPthTmp + "tmpTWO.DBF"
         // ��� ������� ���������� ����� ���������
         cFile1     := GetFileNameMaskNum(cFile1)    // �������� ����� ��� �����
         cFile2     := GetFileNameMaskNum(cFile2)    // �������� ����� ��� �����
         :aFile1[ NAME_TEMP ] := cFile1
         :aFile2[ NAME_TEMP ] := cFile2
      ENDIF

      :aTsbFonts := { "TsbNorm", "TsbBold", "TsbBold", "TsbSpecH", "TsbSuperH", "TsbEdit" }
      :aTmpStru  := {                        ;
                     {"VIRT_1", "N",  7, 0}, ;  // ����������� �������
                     {"VIRT_2", "N",  7, 0}, ;
                     {"VIRT_3", "N",  7, 0}, ;
                     {"VIRT_4", "N",  7, 0}, ;
                     {"VIRT_5", "N",  7, 0}, ;
                     {"VIRT_6", "N",  7, 0}, ;
                     {"RECID" , "N",  7, 0}  ;  // RecNo() �������������� ���� "9,999,999"
                    }
      :aTmpView  := {}                            // ���� ������ Field
      :aTmpHead  := {}                            // ���� ������ Head
      :aColVirt  := {}                            // ������ ����. ������� ��������
      :cColVirt  := ","                           // ������ ����. ������� ������� ",VIRT_1,...,VIRT_6,"
      FOR nTmp := 1 TO Len( :aTmpStru )
          aTmp := :aTmpStru[ nTmp ]
          IF     "VIRT" $ aTmp[1]
             cTmp := "("+hb_ntos(nTmp)+")"
             AADD( :aColVirt, aTmp[1] )
             :cColVirt += aTmp[1]+","
          ELSEIF "REC"  $ aTmp[1]
             cTmp := "ID"
          ENDIF
          AADD( :aTmpView, aTmp[1] )
          AADD( :aTmpHead, cTmp )
      NEXT
      // ���������� �������
      :aSupHd1 := { :aFile1[ NAME_FILE  ] + ' [ Alias: ' + ;
                    :aFile1[ NAME_ALIAS ] + "/"  + ;
                    :aFile1[ NAME_CDP   ] + '/'  + ;
                    :aFile1[ NAME_VIA   ] + ' ]' + ' + TempDbf - ' + ;
                    :aFile1[ NAME_TEMP  ] }

      :aSupHd2 := { :aFile2[ NAME_FILE  ] + ' [ Alias: ' + ;
                    :aFile2[ NAME_ALIAS ] + "/"  + ;
                    :aFile2[ NAME_CDP   ] + '/'  + ;
                    :aFile2[ NAME_VIA   ] + ' ]' + ' + TempDbf - ' + ;
                    :aFile2[ NAME_TEMP  ] }

   END WITH

RETURN o

////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myBrw( nY, nX, nW, nH, nBrw, cAlsTmp, cAlias, aSupHd )
   LOCAL cBrw   := "oBrw"+hb_ntos(nBrw)
   LOCAL AOC    := (App.Object):Cargo // ������������ �� ���������� ���������� ���� ����������
   LOCAL aFont  := AOC:aTsbFonts
   LOCAL aHead  := AOC:aTmpHead
   LOCAL aField := AOC:aTmpView
   LOCAL nNum   := Len( aField )
   LOCAL aFld   := {}
   LOCAL aNam   := {}
   LOCAL aHdr   := {}
   LOCAL lEdit  := .T.     // ��������� ������������� ������
   LOCAL oBrw, nFld, cFld

   FOR nFld := 1 TO (cAlias)->( FCount() )
      cFld := (cAlias)->( FieldName( nFld ) )
      AAdd( aFld, cFld )
      AAdd( aNam, cFld )
      AAdd( aHdr, cFld )
   NEXT

   DEFINE TBROWSE &cBrw OBJ oBrw ALIAS cAlsTmp CELL ;
          AT nY, nX WIDTH nW HEIGHT nH              ;
          FONT       aFont                          ;
          BRUSH      YELLOW                         ;
          HEADERS    aHead                          ;
          COLSIZES   NIL                            ;
          PICTURE    NIL                            ;
          JUSTIFY    NIL                            ;
          COLUMNS    aField                         ;
          COLNAMES   aField                         ;
          FOOTERS    .T.                            ;
          FIXED      COLSEMPTY                      ;
          LOADFIELDS GOTFOCUSSELECT                 ;
          COLNUMBER  { nNum, 40 }                   ;
          ENUMERATOR LOCK EDIT                      ;
          ON INIT    {|ob| ob:Cargo := oKeyData() }

          :DelColumn( ATail( aField ) )                   // ������� ������� "RECID" �� �������

          myVirtSetTsb( oBrw )                            // ��������� ����������� ��������

          :LoadFields( lEdit, aFld, cAlias, aNam, aHdr )  // ��������� ��� ���� ���. ���� � �������

          myBrwInit( oBrw, nBrw )      // init TBrowse and Cargo
          myColumnInit( oBrw )         // ������������� ������� ������� ��� �������/����� �� ����.��������
          myColorsInit( oBrw )         // ������������� ������ � Cargo
          mySetTsb( oBrw )             // ��������� �������
          //myPartWidthTsb( oBrw )      // ��������� ������ �������
          myColorTsb( oBrw )           // ����� �� �������
          myColorTsbElect( oBrw )      // ����� ���������/����� �� tempDBF
          mySupHdTsb( oBrw, aSupHd )   // SuperHeader
          myEnumTsb( oBrw )            // ENUMERATOR �� �������
          mySet2Tsb( oBrw )            // ��������� ������� ��������������
          mySetEditTsb( oBrw )         // ��������� ��������������
          mySetHeadClick( oBrw )       // ��������� ��� ����� �������

          :nFreeze     := :nColumn("ORDKEYNO")
          :nCell       := :nFreeze + 1
          :lLockFreeze := .T.

   END TBROWSE ON END {|ob| ob:SetNoHoles(), ob:Refresh() }   // ��� ���� ����� ���.������

RETURN oBrw

///////////////////////////////////////////////////////////
// ������������� TsBrowse � Cargo �������
STATIC FUNCTION myBrwInit( oBrw, nBrw )

   WITH OBJECT oBrw

      :Cargo:nBrowse  := nBrw                  // ����� ������� - ���������
      :Cargo:cFilter  := '""'                  // ��������� ���. ������� ����. �������
      :Cargo:nFilter  := 0                     // ��� ������� ����. �������
      :Cargo:aFilter  := {"DELETED()", "CITY", "STREET", "YEAR2", "DOLG2014", "DOLG2015"}

      // ������ �������, ���� ��� ������� �� ������� - ������������� ����� �������
      :bEvents := {|obr,nmsg|
                    If nmsg == WM_LBUTTONUP .and. obr:nLen == 0
                       obr:FilterData()
                       myClrVirtHead( obr, obr:Cargo:nClr4 ) // ������� ����� ���� ����� ������� ����������� �������
                       mySumVirtFoot( obr, .F. )             // ����� ������� ����������� �������
                       obr:DrawHeaders(.T.)
                       obr:SetFocus()
                       DO EVENTS
                    EndIf
                    Return Nil
                   }
      :bGotFocus := {|ob| myGotFocusTsb(ob)     }
      :bOnDraw   := {|ob| SayStatusBar(ob)      }   // ����� StatusBar - Recno/Column

      :UserKeys(VK_F3, {|ob| myListColumn(ob)   })  // ���� �� ������ �������
      /*
      // ���� ������� ������ - ��� ������������
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

/////////////////////////////////////////////////////////////////////////
// ������������� ������� ������� ��� �������/����� �� ����.��������
STATIC FUNCTION myColumnInit( oBrw )
   LOCAL oCol

   WITH OBJECT oBrw
      FOR EACH oCol IN :aColumns            // Init Cargo � �������
         oCol:Cargo := oKeyData()
         oCol:Cargo:nSum  := 0
         oCol:Cargo:aVirt := oKeyData()
         //oCol:Cargo:aVirt := Array((:cAlias)->( LastRec() ))
         //AFill(oCol:Cargo:aVirt, 0)
         // ������ ������ ���� � 0 � ��������
         oCol:lEmptyValToChar := .T.
      NEXT
   END WITH

RETURN Nil

///////////////////////////////////////////////////////////
// ������������� ������ ������� � Cargo
STATIC FUNCTION myColorsInit( oBrw )

   WITH OBJECT oBrw:Cargo
      // ��� ���������� ����� (���/�����) ��� ������ ������ ������ ��� �������������
      :nBackDef   := CLR_WHITE
      :nForeDef   := CLR_BLACK
      :nBackKeyNo := CLR_RED
      :nForeKeyNo := CLR_WHITE
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
      :nGREEN3    :=  RGB( 94,162, 38)
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
      :aClrVirt   := { :nBCDelRec, 0, :nHBLUE2, :nFCYear, :nHRED, :nPURPLE2 }
      :aClrBrw    := { :nGREEN2 , :nYELLOW }
   END WITH

RETURN Nil

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
   LOCAL oCol, AOC := (App.Object):Cargo
   LOCAL nKolvo := (oBrw:cAlias)->( Lastrec() )
   LOCAL nLen   := Len( hb_ntos(nKolvo) ), nWidth

   nLen   := iif( nLen > 2, nLen, nLen + 1 )           // ���� < 3�, �� +1 � nLen
   nWidth := GetFontWidth( AOC:aTsbFonts[ 1 ], nLen )  // Font ��� ��� cell

   WITH OBJECT oBrw

      FOR EACH oCol IN :aColumns
          oCol:nWidth  := nWidth     // ����� ������� ����� ����� ���� ��� � ������� #
          IF "KEYNO" $ oCol:cName
             oCol:nFieldLen := nLen
             LOOP
          ENDIF
          oCol:bDecode := {|xx| iif( Empty(xx), "", hb_ntos(xx) ) }
          oCol:nAlign  := DT_CENTER
          oCol:nHAlign := DT_CENTER
          oCol:nFAlign := DT_CENTER
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
      //:nCellMarginLR := 1           // ������ �� ����� ������ ��� �������� �����, ������ �� ���-�� ��������
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
#if 0
////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myPartWidthTsb( oBrw )         // ��������� ������ �������
   LOCAL nW, oCol, cType, hFont := oBrw:hFont  // 1-cells font
   LOCAL cCol, cNam, aColVirt, lColVirt
   LOCAL AOC := (App.Object):Cargo  // ������������ �� ���������� ���������� ���� ����������

   // ��-�� ����������� ������� ������ ��������� ������� ����������
   // + � ����� ������ ���� "DejaVu Sans Mono", �.�. �� ������������
   // ����� �������������� ���������� ������ �������

   aColVirt := AClone( AOC:aColVirt )  // { "VIRT_1", "VIRT_2", ... } // ������ ����. ������� ��������
   AADD( aColVirt , "ORDKEYNO" )       // ��� aClone() � AOC:aColVirt ����� ������ "ORDKEYNO"

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
#endif
////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myColorTsb( oBrw )
   LOCAL O := oBrw:Cargo

   WITH OBJECT oBrw
      :nClrLine := O:nClrLine   // ������� � ���������� tsb ���� ���������� � �������
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
STATIC FUNCTION myColorsInitTempDbf( nBrw )  // ������ ����� � tempDBF
   LOCAL nRecno, i, cField, cAlsIsx, nRec, lDel, nVal, nFldYear
   LOCAL AOC   := (App.Object):Cargo  // ������������ �� ���������� ���������� ���� ����������
   LOCAL aFile := { AOC:aFile1, AOC:aFile2 }
   LOCAL cBrw  := "oBrw"+hb_ntos(nBrw)
   LOCAL oBrw  := This.&(cBrw).Object
   LOCAL cAls  := oBrw:cAlias
   LOCAL O := oBrw:Cargo          // ������������ �� ���������� ������� ���� ����������
   LOCAL aVFore, aVBack, aFCell, aBCell, lWaitWnd
   LOCAL nWaitWndMax := AOC:nWaitWndMax
   LOCAL nWaitWndCnt := AOC:nWaitWndCnt
   LOCAL nWaitWnd := 0
   LOCAL cMsg := "Wait, color is being written to dbf file. "+cBrw+" - "

   nRecno   := (cAls)->( RecNo() )
   lWaitWnd := (cAls)->( LastRec() ) > nWaitWndMax        // ���� � �� ������ 1000 �������
   cAlsIsx  := aFile[ nBrw ][ NAME_ALIAS ]
   // �������� �� ����
   SELECT(cAlsIsx)
   nFldYear := FIELDNUM("YEAR2")
   SELECT(cAls)

   IF lWaitWnd
      WaitWindow( cMsg + repl(".", 7), .T. )
   ENDIF

   aVFore := Array( VIRT_COLUMN_END )
   aVBack := Array( VIRT_COLUMN_END )
   FOR i := 1 TO VIRT_COLUMN_END
       cField := "VFORE_" + hb_ntos( i )
       aVFore[ i ] := (cAls)->( FieldPos( cField ) )
       cField := "VBACK_" + hb_ntos( i )
       aVBack[ i ] := (cAls)->( FieldPos( cField ) )
   NEXT

   aFCell := Array( LEN(AOC:aFClrCell) )
   aBCell := Array( LEN(AOC:aFClrCell) )
   FOR i := 1 TO LEN(AOC:aFClrCell)
       cField := AOC:aFClrCell[ i ]
       aFCell[ i ] := (cAls)->( FieldPos( cField ) )
       cField := AOC:aBClrCell[ i ]
       aBCell[ i ] := (cAls)->( FieldPos( cField ) )
   NEXT

   (cAls)->( dbGotop() )

   DO WHILE (cAls)->( !EOF() )
      nRec  := (cAls)->( RecNo() )
      DO EVENTS
      FOR i := 1 TO VIRT_COLUMN_END  // LEN(AOC:aBClrCellVirt)
         (cAls)->( FieldPut(aVFore[ i ], O:nBLACK   ) )  // ���� ������ �����
         (cAls)->( FieldPut(aVBack[ i ], O:nBClrSpH ) )  // ���� ���� �����
      NEXT

      IF ( lDel := (cAls)->( DELETED() ) )                    // ��� �������� �������
         FOR i := 1 TO LEN(AOC:aFClrCell)
             (cAls)->( FieldPut(aFCell[ i ], O:nHGRAY    ) )  // ���� ������ �����
             (cAls)->( FieldPut(aBCell[ i ], O:nBCDelRec ) )  // ���� ���� �����
         NEXT
      ENDIF

      IF nFldYear > 0                            // ���� ����� ���� ���� � ����
         nVal := (cAlsIsx)->YEAR2                // � �������� �������
         IF nVal > 2020
            FOR i := 1 TO LEN(AOC:aFClrCell)
               cField := AOC:aFClrCell[ i ]      // ���� ������ �����
               //(cAls)->&cField := O:nHBLUE     // ����� ����
               cField := AOC:aBClrCell[ i ]      // ���� ���� �����
               (cAls)->&cField := O:nBCYear      // ����� ���
            NEXT
         ENDIF
      ENDIF

      IF lWaitWnd
         nWaitWnd++
         IF nWaitWnd >= nWaitWndCnt
            nWaitWnd := 0
            WaitWindow( cMsg+hb_ntos(nRec), .T. )
         ENDIF
      ENDIF

      (cAls)->( dbSkip() )
   ENDDO

   IF lWaitWnd
       nRec := (cAls)->( LastRec() )
       WaitWindow( cMsg+hb_ntos(nRec), .T. )
       InkeyGui(1000)
       WaitWindow()
   ENDIF

   (cAls)->( dbGoto( nRecno ) )
   oBrw:Refresh()

RETURN Nil

////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myColorTsbElect( oBrw )
   LOCAL aColVirt, lVirtual, nCol, cFld, oCol, cCol, cNam
   LOCAL nBrowse, nAt := oBrw:nAt, aCol := oBrw:aColumns
   LOCAL AOC := (App.Object):Cargo  // ������������ �� ���������� ���������� ���� ����������
   LOCAL O   := oBrw:Cargo          // ������������ �� ���������� ������� ���� ����������

   nBrowse  := O:nBrowse     // ����� �������
   aColVirt := AOC:aColVirt  //{ "VIRT_1", "VIRT_2", ... } // ������ ����. ������� ��������

   FOR nCol := 1 TO Len(aCol)
      oCol := aCol[ nCol ]
      cCol := oCol:cName
      lVirtual := .F.
      FOR EACH cNam IN aColVirt
         IF cCol == cNam
            lVirtual := .T.
            EXIT
         ENDIF
      NEXT
      IF lVirtual
         // --------- ����� ����� ��� ������ ������ ������� -----------
         oCol:nClrBack := {|at,nc,br| myClrBackVirt(at,nc,br) } // ���� ���� � ������� �������
         oCol:nClrFore := {|at,nc,br| myClrForeVirt(at,nc,br) } // ���� ������ � ������� �������
      ELSE
         IF cCol == "ORDKEYNO"
            oBrw:GetColumn(cCol):nClrFore := O:nBLACK
            oBrw:GetColumn(cCol):nClrBack := O:nBClrSpH  // ��� � ���������� �������
         ELSE
            // --------- ����� ����� ��� ������ ������ ������� -----------
            oCol:nClrBack := {|at,nc,br| myClrBack(at,nc,br) } // ���� ���� � ������� �������
            oCol:nClrFore := {|at,nc,br| myClrFore(at,nc,br) } // ���� ������ � ������� �������
            // --- ���� ������ ��� �������� ������ �������, ���� ������ :SetColor({5}...) - ���� �������
            oCol:nClrFocuFore := { |nr,nc,ob| nr:=nc, iif( (ob:cAlias)->( DELETED() ), O:nWHITE, O:nClr1 ) }

         ENDIF  // cCol == "ORDKEYNO"
      ENDIF   // lVirtual
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
STATIC FUNCTION myGetTmpDbfColor( cAls, cFld, nAt, lDel )
   LOCAL nRec, nColor

   SELECT(cAls)
   nRec := RecNo()
   DbGoto(nAt)
   lDel   := (cAls)->( Deleted() )
   nColor := (cAls)->&cFld    // ����� ����
   DbGoto(nRec)

RETURN nColor

////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myClrBackVirt( nAt, nCol, oBrw )
   LOCAL oCol := oBrw:aColumns[ nCol ]
   LOCAL nColor, cFld, cAls
   LOCAL AOC := (App.Object):Cargo  // ������������ �� ���������� ���������� ���� ����������
   LOCAL O   := oBrw:Cargo          // ������������ �� ���������� ������� ���� ����������

   cFld := AOC:aBClrCellVirt[ nCol ]  // ���� ���� ����������� ����� �� ����
   cAls := oBrw:cAlias
   nAt  := oBrw:nAtPos

   nColor := myGetTmpDbfColor( cAls, cFld, nAt )  // ����� ���� ���� ������
   IF nColor == 0
      nColor := O:nBClrSpH                        // ��� � ���������� �������
   ENDIF

RETURN nColor

////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myClrForeVirt( nAt, nCol, oBrw )
   LOCAL oCol := oBrw:aColumns[ nCol ]
   LOCAL nColor, cFld, cAls
   LOCAL AOC := (App.Object):Cargo  // ������������ �� ���������� ���������� ���� ����������
   LOCAL O   := oBrw:Cargo          // ������������ �� ���������� ������� ���� ����������

   cFld := AOC:aFClrCellVirt[ nCol ]  // ���� ������ ����������� �����
   cAls := oBrw:cAlias
   nAt  := oBrw:nAtPos

   nColor := myGetTmpDbfColor( cAls, cFld, nAt )    // ����� ���� ������ ������
   IF nColor == 0
      nColor := O:nClr1                             // ���� ������ �������
   ENDIF

RETURN nColor

////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myClrBack( nAt, nCol, oBrw )
   LOCAL oCol := oBrw:aColumns[ nCol ]
   LOCAL nColor, cFld, cAls, nI
   LOCAL AOC := (App.Object):Cargo  // ������������ �� ���������� ���������� ���� ����������
   LOCAL O   := oBrw:Cargo          // ������������ �� ���������� ������� ���� ����������

   nI   := nCol - VIRT_COLUMN_MAX
   cFld := AOC:aBClrCell[ nI ]       // ���� ���� ����������� ����� �� ����
   cAls := oBrw:cAlias
   nAt  := oBrw:nAtPos

   nColor := myGetTmpDbfColor( cAls, cFld, nAt )  // ����� ���� ���� ������
   IF nColor == 0
      nColor := O:nClr2                           // ���� ���� �������
   ENDIF

RETURN nColor

////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myClrFore( nAt, nCol, oBrw )
   LOCAL oCol := oBrw:aColumns[ nCol ]
   LOCAL nColor, cFld, cAls, nI, lDel, cTyp
   LOCAL AOC := (App.Object):Cargo  // ������������ �� ���������� ���������� ���� ����������
   LOCAL O   := oBrw:Cargo          // ������������ �� ���������� ������� ���� ����������

   nI   := nCol - VIRT_COLUMN_MAX
   cFld := AOC:aFClrCell[ nI ]  // ���� ������ ����������� �����
   cAls := oBrw:cAlias
   nAt  := oBrw:nAtPos
   cTyp := oCol:cFieldTyp
   lDel := .F.

   nColor := myGetTmpDbfColor( cAls, cFld, nAt, @lDel )   // ����� ���� ������ ������

   IF nColor == 0
      nColor := O:nClr1           // ���� ������ �������

      IF cTyp == "N" .AND. !lDel
         nColor := O:nGREEN       // ����� ���� ������ ������
      ENDIF

   ENDIF

RETURN nColor

//////////////////////////////////////////////////////////////////
// ����������
STATIC FUNCTION mySupHdTsb( oBrw, aSupHd )
   LOCAL O := oBrw:Cargo             // ������������ �� ���������� ���� ����������

   WITH OBJECT oBrw
   :AddSuperHead( 1, :nColCount(), aSupHd[1] )

   // ������ ����� �����������
   :SetColor( {16}, { O:nClr16 } ) // 16, ���� ���������
   :SetColor( {17}, { O:nClr17 } ) // 17, ������ ���������

   END WIDTH

RETURN NIL

/////////////////////////////////////////////////////////////////////////////////////
// ENUMERATOR �� ������� ������� ����
STATIC FUNCTION myEnumTsb( oBrw )
   LOCAL nOneCol, oCol, nI := 0, nCnt := 0

   nOneCol := oBrw:nColumn("ORDKEYNO")

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
   LOCAL i, oCol, cTyp, cColVirt, nBrowse
   LOCAL AOC := (App.Object):Cargo  // ������������ �� ���������� ���������� ���� ����������
   LOCAL O   := oBrw:Cargo          // ������������ �� ���������� ������� ���� ����������

   nBrowse  := O:nBrowse     // ����� �������
   cColVirt := AOC:cColVirt  // "VIRT_1,VIRT_2,..."    // ������ ����. ������� �������

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
         // edit �������
         IF cTyp $ "+=^"   // Type: [+] [=] [^]
            oCol:bPrevEdit := {|| AlertStop("It is forbidden to edit this type of field !") , FALSE }
         ENDIF

         IF oCol:cName $ cColVirt
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
   LOCAL nRow, nRow2, cNam, cForm, nCol, cCel, cMs, cColVirt
   LOCAL cMsg, cTyp, xVal, oCol, nY, nX, nWCel, nHCel
   LOCAL AOC := (App.Object):Cargo  // ������������ �� ���������� ���������� ���� ����������

   cColVirt := AOC:cColVirt         // ������ ����. ������� �������

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

   cMsg := 'Only for column: '+cColVirt+' !;;'
   cMsg += 'for more details see the "About" menu,; then the "Virtual table columns" menu'

   AlertInfo( cMs + cCel + cMsg + CRLF, ProcName()+"()" )

   IF _IsControlDefined("Lbl_0", cForm)
      DoMethod(cForm, "Lbl_0", "Release")
   ENDIF

RETURN Nil

////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myAllHeadClick( nClick, oBrw, nRowPix, nColPix, nAt )
   LOCAL cForm, nRow, nCell, cNam, cName, nCol, nIsHS, nLine, oCol
   LOCAL nY, nX, cMsg1, cMsg2, cMsg3, aMsg, nCol0, nEvnt, cVirt
   LOCAL AOC := (App.Object):Cargo  // ������������ �� ���������� ���������� ���� ����������

   cVirt := AOC:cColVirt            // ������ ����. ������� �������
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

   If nClick == 1
      // ���� ��������� ����� ������� �����
      IF cName $ cVirt
         nEvnt := Val(right(cName, 1))
         IF oBrw:Cargo:nFilter == nEvnt
            nEvnt := 99                     // ������� ����� ����. �������
         ENDIF
      ENDIF
   Else
      // ���� ��������� ������ ������� �����
   Endif

   cMsg1 := cNam + ", y:x " + hb_ntos(nRowPix) + ":" + hb_ntos(nColPix)
   cMsg2 := "Head position y/x: " + hb_ntos(nY) + '/' + hb_ntos(INT(nX))
   cMsg3 := "Column header: " + hb_ntos(nCol)
   cMsg3 += "-" + hb_ntos( VIRT_COLUMN_MAX ) + "="
   nCol0 := nCol - VIRT_COLUMN_MAX
   cMsg3 += hb_ntos(nCol0) + "  [" + cName + "]"
   aMsg  := { cMsg1, cMsg2, cMsg3 }

   IF cName $ cVirt+'ORDKEYNO,'
      // ������� ��������� ���������
      cMsg3 := "Column header: " + hb_ntos(nCol) + " [" + cName + "]"
      aMsg  := { cMsg1, cMsg2, cMsg3 }
      // ���� ����� ����������� �������
      myVirtHeadClick(oBrw, nY, nX, aMsg, nEvnt )
   ELSE
      // ���� ����� ������� �������
      myHeadClick(oBrw, nY, nX, aMsg )
   ENDIF

   oBrw:SetFocus()
   DO EVENTS

RETURN Nil

////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myVirtHeadClick( oBrw, nY, nX, aMsg, nEvnt )
   LOCAL cForm, hFont1, hFont2, hFont3

   cForm  := oBrw:cParentWnd
   hFont1 := GetFontHandle( "TsbEdit"   )
   hFont2 := GetFontHandle( "TsbSuperH" )
   hFont3 := GetFontHandle( "TsbBold"   )

   SET WINDOW THIS TO cForm
   // �������� ����� �������
   (This.Object):Event( 500, {|ow,ky,np| ky := ow, myFilter(np, oBrw) })
   SET WINDOW THIS TO

   IF nEvnt == NIL

      DEFINE CONTEXT MENU OF &cForm
         MENUITEM  "Show virtual columns"         ACTION  {|| myShowHideColumn(1,oBrw) } FONT hFont2
         MENUITEM  "Hide virtual columns"         ACTION  {|| myShowHideColumn(2,oBrw) } FONT hFont2
         SEPARATOR
         Popup 'Filter by virtual column ???'  FONT hFont3
            /*
            MENUITEM  "Filter by virtual column (1)"  ACTION  {|| myFilter(1,oBrw) }  FONT hFont2
            MENUITEM  "Filter by virtual column (2)"  ACTION  {|| myFilter(2,oBrw) }  FONT hFont2
            MENUITEM  "Filter by virtual column (3)"  ACTION  {|| myFilter(3,oBrw) }  FONT hFont2
            MENUITEM  "Filter by virtual column (4)"  ACTION  {|| myFilter(4,oBrw) }  FONT hFont2
            MENUITEM  "Filter by virtual column (5)"  ACTION  {|| myFilter(5,oBrw) }  FONT hFont2
            MENUITEM  "Filter by virtual column (6)"  ACTION  {|| myFilter(6,oBrw) }  FONT hFont2
            */
            MENUITEM  "Filter by virtual column (1)"  ACTION  _wPost(500, cForm, 1)   FONT hFont2
            MENUITEM  "Filter by virtual column (2)"  ACTION  _wPost(500, cForm, 2)   FONT hFont2
            MENUITEM  "Filter by virtual column (3)"  ACTION  _wPost(500, cForm, 3)   FONT hFont2
            MENUITEM  "Filter by virtual column (4)"  ACTION  _wPost(500, cForm, 4)   FONT hFont2
            MENUITEM  "Filter by virtual column (5)"  ACTION  _wPost(500, cForm, 5)   FONT hFont2
            MENUITEM  "Filter by virtual column (6)"  ACTION  _wPost(500, cForm, 6)   FONT hFont2
         End Popup
         /*
         MENUITEM  "Filter by all virtual column"  ACTION  {|| myFilter(0,oBrw)  }  FONT hFont3
         MENUITEM  "Clear table filter"            ACTION  {|| myFilter(99,oBrw) }  FONT hFont3
         */
         MENUITEM  "Filter by all virtual column"  ACTION  _wPost(500, cForm,  0)  FONT hFont3
         MENUITEM  "Clear table filter"            ACTION  _wPost(500, cForm, 99)  FONT hFont3
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

   ELSE

      DO EVENTS ; _wPost(500, cForm, nEvnt)

   ENDIF

   oBrw:SetFocus()
   oBrw:DrawSelect()
   DO EVENTS

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
   LOCAL AOC := (App.Object):Cargo  // ������������ �� ���������� ���������� ���� ����������

   cListCol := AOC:cColVirt         // ������ ����. ������� ������� - ",VIRT1,VIRT2,..."

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

//////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION CreateMemTmp( cFile, cAlias, cCdp, cVia, cAlsTmp, cFileTmp )
   LOCAL cFil := hb_FNameExtSet( cFile, "" )
   LOCAL cInd := hb_FNameExtSet( cFile, ".CDX" )
   LOCAL AOC  := (App.Object):Cargo
   LOCAL aStru := AClone( AOC:aTmpStru )
   LOCAL cFld  := ATail( aStru )[1]  // �� RECID ������ TAG, ���. RELATION
   LOCAL nWaitWndMax := AOC:nWaitWndMax
   LOCAL nWaitWndCnt := AOC:nWaitWndCrt
   LOCAL nWaitWnd := 0, lWaitWnd, nRec
   LOCAL cMsg := 'Wait, creating a temporary base '
   LOCAL i, k, lErr, nErr := 0

   AOC:aFClrCellVirt := {}    // ������ ����������� ������� ��� ����� ������ �����
   AOC:aBClrCellVirt := {}    // ������ ����������� ������� ��� ����� ���� �����

   FOR i := 1 TO VIRT_COLUMN_END
      // ��� ���� ����� ��� ������ ����� ����� ����������� ������� � �������
      AADD( aStru, { "VFORE_" + hb_ntos( i ), "N",  8, 0 } )  // ���� ������ �����
      AADD( aStru, { "VBACK_" + hb_ntos( i ), "N",  8, 0 } )  // ���� ���� �����
      AADD( AOC:aFClrCellVirt, "VFORE_" + hb_ntos( i )  )
      AADD( AOC:aBClrCellVirt, "VBACK_" + hb_ntos( i )  )
   NEXT

   cVia := iif( "mem:" $ cFil, "DBFCDX", cVia )

   IF ! hb_FileExists( cFile )
      MsgStop('File Dbf not found !' + CRLF + cFile  + CRLF + ProcNL() , "ERROR")
      RETURN .F.
   ENDIF

   IF ! hb_FileExists( cInd )
      USE &(cFile) ALIAS (cAlias) NEW    // open EXCLUSIVE
      INDEX ON RecNo() TAG &cFld         // TAG ��� RELATION
      USE
   ENDIF

   IF Empty(cCdp) ; USE &(cFile) ALIAS (cAlias) SHARED NEW
   ELSE           ; USE &(cFile) ALIAS (cAlias) SHARED NEW CODEPAGE cCdp
   ENDIF

   SET WINDOW MAIN OFF
   WaitWindow( cMsg+repl('.', 7), .T. )

   AOC:aFClrCell := {}    // ������ ������� ��� ����� ������ �����
   AOC:aBClrCell := {}    // ������ ������� ��� ����� ���� �����

   SET ORDER TO 1         // Set AutOpen ON
   GO TOP
   // ������� cAlias
   FOR i := 1 TO FCount()
      // ��� ���� ����� ��� ������ ����� ����� � �������
      AADD( aStru, { "FORE_" + hb_ntos( i ), "N",  8, 0 } )  // ���� ������ �����
      AADD( aStru, { "BACK_" + hb_ntos( i ), "N",  8, 0 } )  // ���� ���� �����
      AADD( AOC:aFClrCell, "FORE_" + hb_ntos( i )  )
      AADD( AOC:aBClrCell, "BACK_" + hb_ntos( i )  )
   NEXT

   CloseMemTmp( cFileTmp, cAlsTmp )

   DBCREATE( cFileTmp, aStru, cVia, .T., cAlsTmp )
   // ������� cAlsTmp
   lWaitWnd := (cAlias)->( LastRec() ) > nWaitWndMax        // ���� � �� ������ 1000 �������
   k := FieldPos( cFld )                                    // ������� � ���������� ���� �����
   (cAlias)->( dbGotop() )
   DO WHILE (cAlias)->( !Eof() )
      lErr := .T.
      BEGIN SEQUENCE WITH { |e|break(e) }
         (cAlsTmp)->( dbAppend() )
         lErr := (cAlsTmp)->( NetErr() )
      END SEQUENCE
      IF lErr
         nErr ++
         ? "DB:",cFileTmp, cAlsTmp, "Append blank error", (cAlias)->( RecNo() ), (cAlsTmp)->( RecNo() )
         IF nErr > 2   // �������, ��������� ������
            EXIT
         ENDIF
      ELSE
         (cAlsTmp)->( FieldPut( k, (cAlias)->( RecNo() ) ) )
         IF (cAlias)->( Deleted() )
            (cAlsTmp)->( dbDelete() )
         ENDIF
      ENDIF
      nRec := (cAlias)->( RecNo() )
      DO EVENTS
      IF lWaitWnd
         nWaitWnd++
         IF nWaitWnd >= nWaitWndCnt
            nWaitWnd := 0
            WaitWindow( cMsg+hb_ntos(nRec), .T. )
         ENDIF
      ENDIF
      (cAlias)->( dbSkip() )
   ENDDO
   (cAlias)->( dbGotop() )

   SELECT(cAlsTmp)
   GO TOP
   INDEX ON &cFld TAG &cFld    // ���� ��� ������� #
                               // ��� ������� ����� ����. ���������, � ID ����� RecNo
   DbCommit()

   SET ORDER TO 1
   SET RELATION TO &cFld INTO &cAlias
   GO TOP

   IF lWaitWnd
       nRec := (cAlias)->( LastRec() )
       WaitWindow( cMsg+hb_ntos(nRec), .T. )
       InkeyGui(1000)
   ENDIF

   WaitWindow()            // close the wait window

   IF nErr > 0
      AlertStop(cAlsTmp+": "+"Append blank error !"+CRLF+cFileTmp)
   ENDIF

   SET WINDOW MAIN ON

RETURN .T.

//////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION CloseMemTmp( cFile, cAlias )
   LOCAL cFil := hb_FNameExtSet( cFile, "" )
   LOCAL cInd := hb_FNameExtSet( cFile, ".CDX" )
   LOCAL AOC  := (App.Object):Cargo
   LOCAL lDel := AOC:lTmpErase

   cFile := hb_FNameExtSet( cFile, ".DBF" )

   IF cAlias != NIL .and. Select(cAlias) > 0
      (cAlias)->( dbCloseArea() )
   ENDIF
   IF "mem:" $ cFil ; dbDrop(cFil, cFil, "DBFCDX")
   ELSEIF lDel      ; fErase(cInd ) ; fErase(cFile)
   ENDIF

RETURN Nil

/////////////////////////////////////////////////////////////////////////////////
FUNCTION myVirtColumColorSaveCell(nBrw)
   LOCAL nRecno, nBrowse, nKolvo, cName, nRec, aItogo
   LOCAL nClr2VCol, oCol, nFlg, nFClr, nBClr, lDel, cAlsReal
   LOCAL xVal, cFiels, nJ, nI, aLineBClr, aLineFClr, aFClrCel, aBClrCel
   LOCAL cBrw  := "oBrw"+hb_ntos(nBrw)
   LOCAL oBrw  := This.&(cBrw).Object
   LOCAL AOC   := (App.Object):Cargo  // ������������ �� ���������� ���������� ���� ����������
   LOCAL aFile := { AOC:aFile1, AOC:aFile2 }
   LOCAL nWaitWndMax := AOC:nWaitWndMax
   LOCAL nWaitWndCnt := AOC:nWaitWndSave
   LOCAL nWaitWnd := 0, lWaitWnd
   LOCAL cMsg := "Wait, checking in progress. "+cBrw+" - "
   LOCAL cAls := oBrw:cAlias
   LOCAL O := oBrw:Cargo             // ������������ �� ���������� ������� ���� ����������
   LOCAL nKeyNo := oBrw:nColumn("ORDKEYNO")
   LOCAL aOVirt := {}

   lWaitWnd := (cAls)->( LastRec() ) > nWaitWndMax        // ���� � �� ������ 1000 �������

   WaitWindow( cMsg + " ... ", .T. )

   aFClrCel := AOC:aFClrCell         // ������ ������� ����� ������ �����
   aBClrCel := AOC:aBClrCell         // ������ ������� ����� ���� �����
   nBrowse  := nBrw                  // oBrw:Cargo:nBrowse    // ����� �������
   nRecno   := (cAls)->( RecNo() )
   nKolvo   := LastRec()
   cAlsReal := aFile[ nBrw ][ NAME_ALIAS ] // cAlsReal := IIF( nBrowse == 1, "ONE", "TWO" )
   aItogo   := Array( VIRT_COLUMN_END )
   AFILL( aItogo, 0 )

   // ����� ���� �� ������� ����.�������
   IF nBrowse == 1 .OR. nBrowse == 2
      nClr2VCol := O:aClrBrw[nBrowse]
   ELSE
      nClr2VCol := O:nWHITE
   ENDIF

   (cAls)->( dbGotop() )
   oBrw:GoTop()

   // ����������� ������� � ������� ������� - �����
   FOR EACH oCol IN oBrw:aColumns
      oCol:Cargo:nSum  := 0
      oCol:Cargo:aVirt := oKeyData()
      IF "VIRT" $ oCol:cName
         AADD( aOVirt, oCol:Cargo )      // ��������� cargo ������� ��� ����. �������
      ENDIF
   NEXT
   DO EVENTS
   hb_gcAll()                            // ����� ��������
   DO EVENTS

   DO WHILE (cAls)->( !EOF() )

      nRec := (cAls)->( RECNO() )
      lDel := (cAls)->( DELETED() )

      aLineBClr := myGetColorBackLine( oBrw )   // ������ ���� ������ ������ �������
      aLineFClr := myGetColorForeLine( oBrw )   // ���� ������ ������ ������ �������

      FOR nI := 1 TO LEN(oBrw:aColumns)

         oCol  := oBrw:GetColumn( nI )
         //xVal  := oBrw:GetValue( nI )   // ������ ������ ������ ������� �� ����� !
         cName := oCol:cName
         nBClr := aLineBClr[ nI ]   // ���� ���� ������ ������
         nFClr := aLineFClr[ nI ]   // ���� ������ ������ ������

         // ����������� �������
         IF cName == "VIRT_1"
            nFlg           := iif( lDel, 1, 0 )    // �������� ������
            (cAls)->( FieldPut(FieldPos(cName), nFlg) )
            //(cAls)->&cName := nFlg // ��������� ������, �.�. ���� ����� macro ����������, � ����� ������� ���� !
            aItogo[1] += nFlg
            IF nFlg > 0
               (cAls)->VFORE_1 := O:nFCDelRec      // ������ ������ ���� ���c��
               (cAls)->VBACK_1 := O:nBCDelRec      // ������ ������ ���� ����
               oCol:Cargo:aVirt:Set(nRec, { O:nBCDelRec, O:nFCDelRec })  // { Back, Fore }
            ENDIF

         ELSEIF cName == "CITY"
            xVal := oBrw:GetValue( nI )
            nFlg := iif( "DMITROV" $ UPPER(xVal), 1, 0 )
            nJ   := nI - nKeyNo   // oBrw:nColumn("ORDKEYNO")
            IF nFlg > 0
               cFiels := aFClrCel[ nJ ]
               (cAls)->( FieldPut(FieldPos(cFiels), O:nBLUE) )
               //(cAls)->&cFiels := O:nBLUE
               cFiels := aBClrCel[ nJ ]
               (cAls)->( FieldPut(FieldPos(cFiels), nClr2VCol) )
               //(cAls)->&cFiels := nClr2VCol   // ������ ������ ���� ���� - ��. ����

               (cAls)->VIRT_2 := 1
               aItogo[2]      += 1
               oCol:Cargo:aVirt:Set(nRec, { nClr2VCol, O:nBLUE })  // { Back, Fore }
                aOVirt[2]:aVirt:Set(nRec, { nClr2VCol, O:nBLUE })  // { Back, Fore }

               (cAls)->VFORE_2 := O:nBLUE     // ������ ������ ���� ���c��
               (cAls)->VBACK_2 := nClr2VCol   // ������ ������ ���� ����  - ��. ����
            ENDIF

         ELSEIF cName == "STREET"
            xVal := oBrw:GetValue( nI )
            nFlg := iif( "GAGARIN" $ UPPER(xVal), 1, 0 )
            nJ   := nI - nKeyNo   // oBrw:nColumn("ORDKEYNO")
            IF nFlg > 0
               cFiels          := aFClrCel[ nJ ]
               (cAls)->( FieldPut(FieldPos(cFiels), O:nBLACK) )
               //(cAls)->&cFiels := O:nBLACK
               cFiels := aBClrCel[ nJ ]
               (cAls)->( FieldPut(FieldPos(cFiels), O:nHBLUE2) )
               //(cAls)->&cFiels := O:nHBLUE2   // ������ ������ ���� ���� - ��. ����

               (cAls)->VIRT_3 := 1
               aItogo[3]      += 1
               oCol:Cargo:aVirt:Set(nRec, { O:nHBLUE2, O:nBLACK })  // { Back, Fore }
                aOVirt[3]:aVirt:Set(nRec, { O:nHBLUE2, O:nBLACK })  // { Back, Fore }

               (cAls)->VFORE_3 := O:nBLACK    // ������ ������ ���� ���c��
               (cAls)->VBACK_3 := O:nHBLUE2   // ������ ������ ���� ����  - ��. ����
            ENDIF

         ELSEIF cName == "YEAR2"
            nJ   := nI - nKeyNo   // oBrw:nColumn("ORDKEYNO")
            xVal := oBrw:GetValue( nI )
            IF VALTYPE(xVal) != "N"           // ��������� ��������� ��������
               (cAls)->VBACK_4 := O:nBLACK
               aOVirt[4]:aVirt:Set(nRec, { O:nBLACK, 0 })  // { Back, Fore }
            ELSE
               nFlg := iif( xVal > 2020, 1, 0 )
               IF nFlg > 0
                  cFiels          := aFClrCel[ nJ ]
                  (cAls)->( FieldPut(FieldPos(cFiels), nFClr) )
                  //(cAls)->&cFiels := nFClr
                  cFiels := aBClrCel[ nJ ]
                  (cAls)->( FieldPut(FieldPos(cFiels), O:nGREEN3) )
                  //(cAls)->&cFiels := O:nGREEN3   // ������ ������ ���� ���� - ��. ����

                  (cAls)->VIRT_4 := 1
                  aItogo[4]      += 1
                  oCol:Cargo:aVirt:Set(nRec, { O:nGREEN3, nFClr })  // { Back, Fore }
                   aOVirt[4]:aVirt:Set(nRec, { O:nGREEN3, nFClr })  // { Back, Fore }

                  (cAls)->VFORE_4 := nFClr       // ������ ������ ���� ���c��
                  (cAls)->VBACK_4 := O:nGREEN3   // ������ ������ ���� ����  - ��. ����
               ENDIF
            ENDIF

         ELSEIF cName == "DOLG2014"
            nJ   := nI - nKeyNo   // oBrw:nColumn("ORDKEYNO")
            xVal := oBrw:GetValue( nI )
            IF VALTYPE(xVal) != "N"           // ��������� ��������� ��������
               (cAls)->VBACK_5 := O:nBLACK
               aOVirt[5]:aVirt:Set(nRec, { O:nBLACK, 0 })  // { Back, Fore }
            ELSE
               nFlg := iif( xVal < 0, 1, 0 )
               IF nFlg > 0
                  cFiels          := aFClrCel[ nJ ]
                  (cAls)->( FieldPut(FieldPos(cFiels), O:nGREEN) )
                  //(cAls)->&cFiels := O:nGREEN
                  cFiels := aBClrCel[ nJ ]
                  (cAls)->( FieldPut(FieldPos(cFiels), O:nHRED) )
                  //(cAls)->&cFiels := O:nHRED     // ������ ������ ���� ���� - ��. ����

                  (cAls)->VIRT_5 := 1
                  aItogo[5]      += 1
                  oCol:Cargo:aVirt:Set(nRec, { O:nHRED, O:nGREEN })  // { Back, Fore }
                   aOVirt[5]:aVirt:Set(nRec, { O:nHRED, O:nGREEN })  // { Back, Fore }

                  (cAls)->VFORE_5 := O:nGREEN    // ������ ������ ���� ���c��
                  (cAls)->VBACK_5 := O:nHRED     // ������ ������ ���� ����  - ��. ����
               ENDIF
            ENDIF

         ELSEIF cName == "DOLG2015"
            nJ   := nI - nKeyNo   // oBrw:nColumn("ORDKEYNO")
            xVal := oBrw:GetValue( nI )
            IF VALTYPE(xVal) != "N"              // ��������� ��������� ��������
               (cAls)->VBACK_6 := O:nBLACK
               aOVirt[6]:aVirt:Set(nRec, { O:nBLACK, 0 })  // { Back, Fore }
            ELSE
               nFlg := iif( xVal < 0, 1, 0 )
               IF nFlg > 0
                  cFiels          := aFClrCel[ nJ ]
                  (cAls)->( FieldPut(FieldPos(cFiels), O:nGREEN) )
                  //(cAls)->&cFiels := O:nGREEN
                  cFiels := aBClrCel[ nJ ]
                  (cAls)->( FieldPut(FieldPos(cFiels), O:nPURPLE2) )
                  //(cAls)->&cFiels := O:nPURPLE2   // ������ ������ ���� ���� - ��. ����

                  (cAls)->VIRT_6 := 1
                  aItogo[6]      += 1
                  oCol:Cargo:aVirt:Set(nRec, { O:nPURPLE2, O:nGREEN })  // { Back, Fore }
                   aOVirt[6]:aVirt:Set(nRec, { O:nPURPLE2, O:nGREEN })  // { Back, Fore }

                  (cAls)->VFORE_6 := O:nGREEN     // ������ ������ ���� ���c��
                  (cAls)->VBACK_6 := O:nPURPLE2   // ������ ������ ���� ����  - ��. ����
               ENDIF
            ENDIF

         ENDIF

      NEXT
      DO EVENTS

      IF lWaitWnd
         nWaitWnd++
         IF nWaitWnd >= nWaitWndCnt
            nWaitWnd := 0
            WaitWindow( cMsg+hb_ntos(nRec), .T. )
         ENDIF
      ENDIF

      SELECT(cAls)
      (cAls)->( dbSkip())
   ENDDO
   (cAls)->( dbGoto(nRecno) )
   oBrw:GoTop()

   // ������ ����� � ����������� �������
   FOR nI := 1 TO LEN(oBrw:aColumns)
      oCol  := oBrw:GetColumn( nI )
      cName := oCol:cName
      IF cName == "ORDKEYNO"
         EXIT
      ENDIF
      oCol:Cargo:nSum := aItogo[nI]
   NEXT

   mySumVirtFoot( oBrw, .T. )   // ����� ������� ����������� �������

   IF lWaitWnd
       nRec := (cAls)->( LastRec() )
       WaitWindow( cMsg+hb_ntos(nRec), .T. )
       InkeyGui(1000)
   ENDIF

   WaitWindow()                 // ������� ���� ���������

   oBrw:Refresh() ; InkeyGui(500)

   oBrw:SetFocus()
   DO EVENTS

RETURN NIL

///////////////////////////////////////////////////////////////////
FUNCTION myGetColorBackLine(oBrw)
   LOCAL nCol, nColor, aClr := {}

   For nCol := 1 TO Len( oBrw:aColumns )
      nColor := oBrw:aColumns[ nCol ]:nClrBack
      If Valtype( nColor ) == "B"
         nColor := Eval( oBrw:aColumns[ nCol ]:nClrBack, oBrw:nAt, nCol, oBrw )
      EndIf
      AADD( aClr, nColor )
   Next

RETURN aClr

///////////////////////////////////////////////////////////////////
FUNCTION myGetColorForeLine(oBrw)
   LOCAL nCol, nColor, aClr := {}

   For nCol := 1 TO Len( oBrw:aColumns )
      nColor := oBrw:aColumns[ nCol ]:nClrFore
      If Valtype( nColor ) == "B"
         nColor := Eval( oBrw:aColumns[ nCol ]:nClrFore, oBrw:nAt, nCol, oBrw )
      EndIf
      AADD( aClr, nColor )
   Next

RETURN aClr

//////////////////////////////////////////////////////////////////
// Back ���� Header ����. ������� �������
STATIC FUNCTION myClrVirtHead( oBrw, nClr, lDraw )
   Local i
   Default nClr := oBrw:Cargo:nClr4
   FOR i := 1 TO oBrw:nColumn("ORDKEYNO")
      oBrw:aColumns[ i ]:nClrHeadBack := nClr
   NEXT
   IF ISLOGICAL(lDraw)
      oBrw:DrawHeaders(lDraw)
   ENDIF
RETURN Nil

//////////////////////////////////////////////////////////////////
// ����� ������� ����������� �������
STATIC FUNCTION mySumVirtFoot( oBrw, lDraw, aSum )
   Local i, oCol
   IF Empty(aSum)
      aSum := Array(VIRT_COLUMN_END)
      FOR i := 1 TO VIRT_COLUMN_END
          oCol := oBrw:aColumns[ i ]
          aSum[ i ] := oCol:Cargo:nSum
      NEXT
   ENDIF
   FOR i := 1 TO VIRT_COLUMN_END
       oCol := oBrw:aColumns[ i ]
       oCol:cFooting := iif( Empty(aSum[ i ]), "", hb_ntos(aSum[ i ]) )
   NEXT
   IF !Empty(lDraw)
      oBrw:DrawFooters()
   ENDIF
RETURN Nil

//////////////////////////////////////////////////////////////////
// ������ ���� ������ ����������� �������
STATIC FUNCTION mySumVirtCalc( oBrw )
   LOCAL cAls, aSum, nVal, nRec, cFld, i, aColVirt
   LOCAL AOC := (App.Object):Cargo  // ������������ �� ���������� ���������� ���� ����������

   aColVirt := AOC:aColVirt  //{ "VIRT_1", "VIRT_2", ... } // ������ ����. ������� ��������
   cAls     := oBrw:cAlias
   aSum     := Array( LEN(aColVirt) )
   AFill(aSum, 0)

   DO WHILE (cAls)->( !EOF() )
      nRec := (cAls)->( RecNo() )
      FOR i := 1 TO LEN(aColVirt)
         cFld := aColVirt[ i ]
         nVal := (cAls)->&cFld
         IF nVal > 0
            aSum[ i ] += 1
         ENDIF
      NEXT
      (cAls)->( dbSkip() )
   ENDDO
   (cAls)->( dbGotop() )

RETURN aSum

//////////////////////////////////////////////////////////////////
// ������ �� �������
STATIC FUNCTION myFilter(nFilter,oBrw)
   LOCAL cFilt, cFltr := "["+oBrw:cParentWnd+"], ["+oBrw:cControlName+"]"
   LOCAL aSum, aColVirt, nI
   LOCAL AOC := (App.Object):Cargo  // ������������ �� ���������� ���������� ���� ����������

   aColVirt := AOC:aColVirt         // ������ ����. ������� ��������

   myClrVirtHead( oBrw, oBrw:Cargo:nClr4, .F. )      // ������� ����� ���� ����� ������� ����������� �������

   IF     nFilter == 99                              // �������� ������
      oBrw:Cargo:nFilter := 0                        // ��� ������� �� �������
      oBrw:Cargo:cFilter := '""'                     // �������� ������� �������
   ELSEIF nFilter == 0                               // ������ �� ���� �����
      cFilt := ""
      FOR nI := 1 TO LEN(aColVirt)
         cFilt += aColVirt[nI] + " > 0 "
         cFilt += IIF( nI == LEN(aColVirt), "", ".OR." )
      NEXT
      oBrw:Cargo:nFilter := 100                      // ����� ������� �� �������
      oBrw:Cargo:cFilter := cFilt //"ALL VIRTUAL COLUMNS OF THE TABLE" // �� ���� ����.��������
      myClrVirtHead( oBrw, oBrw:Cargo:nORANGE )      // ���� ���� ����� ������� ����������� ������� �� �������

   ELSE
      cFilt := aColVirt[nFilter] + " > 0 "
      oBrw:Cargo:nFilter := nFilter                  // ����� ������� ��� ������� �� �������
      oBrw:Cargo:cFilter := cFilt //oBrw:Cargo:aFilter[nFilter]
      oBrw:aColumns[ nFilter ]:nClrHeadBack := oBrw:Cargo:nORANGE
   ENDIF

   oBrw:FilterData(cFilt)

   IF !Empty(cFilt) ; aSum := mySumVirtCalc( oBrw )
   ENDIF

   mySumVirtFoot( oBrw, .F., aSum )   // ����� ������� ����������� �������

   oBrw:DrawHeaders(.T.)
   oBrw:SetFocus()
   DO EVENTS

RETURN Nil

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
   cMsg += "�������� ������ ������� ���� �� ����� ����������� �������� �������,;"
   cMsg += "����� ������� ������ �� ���� �������,;"
   cMsg += "�������� ����� ������� ���� - ����� ����� ������������ ����:;"
   cMsg += "1) ��������/������ ����������� �������;"
   cMsg += "2) ������ �� ����������� ��������;;"
   cMsg += "Right-click on the header of the virtual table columns;"
   cMsg += "filter will be enabled for this column;"
   cMsg += "Left-click - the context menu will be shown:;"
   cMsg += "1) Show / hide virtual columns;"
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
   cMsg += "Filter condition by table column = " + oBrw:Cargo:cFilter + ";;"

   AlertInfo( cMsg, "About virtual table columns", , , {LGREEN} , , )

RETURN NIL

///////////////////////////////////////////////////////////////////
FUNCTION ProcNL(nVal)
   DEFAULT nVal := 0
   RETURN "Called from " + ProcName( nVal + 1 ) + "(" + hb_ntos( ProcLine( nVal + 1 ) ) + ") --> " + ProcFile( nVal + 1 )

///////////////////////////////////////////////////////////////////
// ��� ������� ����� �������� ����� ������ � ���
FUNCTION GetFileNameMaskNum( cFile )
   LOCAL i := 0, cPth, cFil, cExt

   If ! hb_FileExists(cFile); RETURN cFile
   EndIf

   hb_FNameSplit(cFile, @cPth, @cFil, @cExt)

   WHILE ( hb_FileExists( hb_FNameMerge(cPth, cFil + '(' + hb_ntos(++i) + ')', cExt) ) )
   END

   RETURN hb_FNameMerge(cPth, cFil + '(' + hb_ntos(i) + ')', cExt)
