/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2021 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2021 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * ������������� ������ ��������� ���������� ������
*/

//#define  _HMG_OUTLOG
#include "hmg.ch"
#include "tsbrowse.ch"

MEMVAR oMain
#define BRW_BMP_CONTEX_MENU    28
//////////////////////////////////////////////////////////////////////////////////////////
FUNCTION TBrowse_Create(nTable, cTabl, cForm, cAls, c2Title, nYBrw, nXBrw, nWBrw, nHBrw)
   LOCAL aBackColor, aUse3Dim, cSupHdr, aTsbFont, nBrwBC, nBrwBC2, nBrwBC3, aParam
   LOCAL xSelector, aBrush, aEdit, aNumer, aSupHdr, aBrwColors, nHead1, nHead2
   LOCAL aHeader, aFSize, aFooter, aPict, aAlign, aNames, aField, aFAlign, aCardTitle
   LOCAL oBrw   // ��� ������ ������� ����� ���� oBrw

   ? "====== " + ProcNL(), cForm, cTabl, nTable, cAls

   // ������ �� ����� -> ListTables.prg
   aBackColor := myTableBackColor(nTable)          // ���� �����
   // ������ �� ������� -> ListTables.prg
   aUse3Dim   := myTableUse(nTable)                // ������ ���� dbf/alias/codepage

   aTsbFont   := myTsbFont()                       // ��������� ����� ��� �������
   aHeader    := myTableDatos(nTable,1)            // ������ ����� ������� �������
   aCardTitle := myTableDatos(nTable,1)            // ������ �������� � ��������
   aFSize     := myTableDatos(nTable,2)            // ������ ������� �������
   aFooter    := myTableDatos(nTable,3)            // ������ ������� ������� �������
   aPict      := myTableDatos(nTable,4)            // ������ PICTURE ������� �������
   aAlign     := myTableDatos(nTable,5)            // ������ ������� ������� �������
   aNames     := myTableDatos(nTable,6)            // ������ ������������ ������� �������
   aField     := myTableDatos(nTable,7)            // ������ ����� ���� ������� �������
   aFAlign    := myTableDatos(nTable,8)            // ������ ������� ������� ������� �������
   aEdit      := myTableDatos(nTable,9)            // ������ ������ ������� �������

   cSupHdr    := "[Alias: " + aUse3Dim[2] + " , CodePage: " + aUse3Dim[3] + "]"
   cSupHdr    += SPACE(5) + c2Title
   aSupHdr    := { cSupHdr }                       // ������ ����������� - ��� ������� 1
   xSelector  := .T.                               // ������ ������� - ��������
   aNumer     := { 1, 70 }                         // ����������� ������� � ����������
   aBrush     := SILVER                            // ���� ���� ��� ��������
   nBrwBC     := ToRGB( aBackColor        )        // ���� ���� �������
   nBrwBC2    := ToRGB( { 255, 255, 255 } )        // ���� ���� ����� ���� �����
   nBrwBC3    := ToRGB( {  50,  50,  50 } )        // ���� ���� �������� �������
   nHead1     := ToRGB( {  40, 122, 237 } )        // ���� ���� ����� � �������: ������� ����
   nHead2     := ToRGB( {  48,  29,  26 } )        // ���� ���� ����� � �������: ����-������ ���
               //    1       2       3       4        5       6       7
   aParam     := { nTable, aEdit, nBrwBC, nBrwBC2, nBrwBC3, nHead1, nHead2 } // �������� � Cargo
   aBrwColors := myBrwGetColor(nTable,nBrwBC,nBrwBC2,nBrwBC3,nHead1,nHead2)  // ����� ����� ����� Tsbrowse, ������ :SetColor(...)

   DEFINE TBROWSE &cTabl OBJ oBrw CELL ;
      AT nYBrw, nXBrw ALIAS cAls WIDTH nWBrw HEIGHT nHBrw ;
      FONT aTsbFont                    ;   // ��� ����� ��� �������
      BRUSH aBrush                     ;   // ���� ���� ��� ��������
      COLORS  aBrwColors               ;   // ��� ����� �������
      BACKCOLOR aBackColor             ;   // ��� ������� - ��������� � ����� ����
      HEADERS aHeader                  ;   // ������ ����� ������� �������
      JUSTIFY aAlign                   ;   // ������ ������� ������� �������
      COLUMNS aField                   ;   // ������ ������������ ������� �������
      NAMES   aNames                   ;   // ������ ����� ���� ������� �������
      EDITCOLS aEdit                   ;   // ������ ������ ��� �������������� ������� .T.\.F.\Nil>\.T\.F.\NIL
      FOOTERS aFooter                  ;   // ������ ������� ������� �������
      SIZES aFSize                     ;   // ������ ������� �������
      LOADFIELDS                       ;   // �������������� �������� �������� �� ����� �������� ���� ������
      GOTFOCUSSELECT                   ;
      EMPTYVALUE                       ;
      FIXED                            ;   // ���������� ������� �������� ������� �� ������������ ��������
      COLNUMBER aNumer                 ;   // ����������� ������� � ����������
      ENUMERATOR                       ;   // ��������� �������
      LOCK                             ;   // �������������� ���������� ������ ��� ����� � ���� ������
      SELECTOR xSelector               ;   // ������ ������� - �������� �������
      ON INIT {|ob| myBrwInit( ob ) }      // ��������� ������� - �������� ����

      myBrwInit(oBrw, aParam)              // ��� ����������� �������
      myBrwSetting(oBrw,aTsbFont)          // ��������� �������
      myBrwDelColumn(oBrw)                 // ������ ������� �� �����������
      myBrwColumnWidth(oBrw)               // ��������� ������ ������ �������
      myBrwMaskBmp(oBrw)                   // ����� ������ ��������
      myBrwEnum(oBrw)                      // ENUMERATOR �� �������
      myBrwColorChange(oBrw,nTable)        // ����� ��������
      myBrwHeaderFooterSpcHd(oBrw,aFAlign) // ��������� �����, ������� � ����������
      myBrwSuperHeader(oBrw,aSupHdr)       // ������� ���������� �������
      RecnoDeleteRecover(oBrw, .T.)        // init for :DeleteRow()

      IF ! :lSelector   // ���� ��� ���������
         :AdjColumns()
      ENDIF

   END TBROWSE ON END {|ob| mySetNoHoles(ob) ,;  // �������� ����
                            iif( ob:lSelector, ob:AdjColumns(), Nil ), ;
                            ob:SetFocus() }
        // AdjColumns() - �������� ������� ��� �������� ������� �� ���� ����� Tsbrowse

   // !!! ������� SELECTOR ���� !!!
   // �� END TBROWSE ������� SELECTOR ��� ���������, ��� ��������� � �������� �� ������,
   // ��� ����� SELECTOR, � ����� END TBROWSE ������� SELECTOR ����. :AdjColumns() ��
   // END TBROWSE ����������� �� ��� ������ ��� ������� SELECTOR, � ���������� � ����
   // ON END ����������� �� ��� ������ � ������ ������� SELECTOR

   // ��� ������� ������� SELECTOR � ORDKEYNO (COLNUMBER aNumer) - �����������,
   // �.�. �� ��� � Dbf �����

   oBrw:nFreeze     := oBrw:nColumn("ORDKEYNO") // ���������� ������� �� ����� �������
   oBrw:lLockFreeze := .T.                      // �������� ���������� ������� �� ������������ ��������
   oBrw:nCell       := oBrw:nFreeze + 1         // ����������� ������ �� ������� �����

   // ������� ���� �������
   oBrw:GetColumn("SELECTOR"):nClrBack := GetSysColor( COLOR_BTNFACE )

   // ������� - ����������� ���� ��� / TSB context menu
   myBrwContextMenu(oBrw)

   // ��������/��������� ����������� ���� ���
   //SET CONTEXT MENU CONTROL &(oBrw:cControlName) OF &cForm ON
   //SET CONTEXT MENU CONTROL &(oBrw:cControlName) OF &cForm OFF

   // ��������� ��� ��������
   oBrw:Cargo:aHeader := aCardTitle  // ������ �������� ����� � ��������
   oBrw:Cargo:aField  := aField      // ������ ������������ ������� �������
   oBrw:Cargo:aEdit   := aEdit       // ������ ������ ��� �������������� �������

RETURN oBrw  // �������� ! ������� ��� �������� ������� � �������

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myBrwInit( oBrw, aPrm )  // !!! ���������, ��������� ���  !!!

   WITH OBJECT oBrw
      IF Empty(aPrm)                // !!! ������ ��� ��������� � ON INIT !!!
         :nColOrder     :=  0       // ������ ������ ���������� �� ����
         :lNoChangeOrd  := .F.      // ������ ���������� �� ����
                                    // ��� �� ������� bLDblClick, ����� �������� ::SetOrder(...)
         :nWheelLines   :=  1       // ��������� ������� ���� � ����� ...
         :lNoGrayBar    := .F.      // ���������� ���������� ������ � �������
         :lNoLiteBar    := .F.      // ��� ������������ ������ �� ������ ���� �� ������� "������" Bar
         :lNoResetPos   := .F.      // ������������� ����� ������� ������ �� gotfocus
         :lNoPopUp      := .T.      // �������� ����������� ���� ��� ������ ������ ������� ���� �� ��������� �������
         :nStatusItem   :=  0       // � 1-� Item StatusBar �� �������� ��������� �� ���
         :lPickerMode   := .F.      // ������ ���� ����������
         :nMemoHV       :=  1       // ����� ����� ������ ����-����
         //:lCellBrw    := .F.      // ������ �� ��� �������
         //:lNoHScroll  := .T.      // ���-������ ��������������� ���������
         //:lNoVScroll  := .T.      // ���-������ ������������� ���������
         //:lFooting    := .T.      // ������������ ������
         //:lDrawFooters:= .T.      // ��������  �������
         :lNoMoveCols   := .T.      // .T. - ������ ������ �������� ������ ��� ���������� �������
         :nCellMarginLR :=  1       // ������ �� ����� ������ ��� �������� �����, ������ �� ���-�� ��������
         :lNoKeyChar    := .T.      // ������ �� ���� �������� � ���� � ������
         :lCheckBoxAllReturn := .F. // Enter modify value oCol:lCheckBox
         // --------- �������� ������� CHECKBOX �� ���� �������� ---------
         :aCheck   := { LoadImage("CheckT24"), LoadImage("CheckF24") }
         // --------- ��������� ��������, ��������� ����� �������� ������� ��������� ------
         :aBitMaps := { LoadImage("Empty16" ), LoadImage("No16") ,;
                        LoadImage("Arrow_down")    ,; // �������� �������_����  30x30
                        LoadImage("Arrow_up")      ,; // �������� �������_����� 30x30
                        LoadImage("ArrowDown20")   ,; // �������� �������_����  20x20
                        LoadImage("ArrowUp20")     ,; // �������� �������_����� 20x20
                        LoadImage("bFltrAdd20")    ,; // �������� ������ 20x20
                        LoadImage("bSupHd40")      ,; // �������� 40x140
                        LoadImage("ArrDown40Blue") ,; // �������� �������_���� 40x40 - PNG
                      }
                      // �������� PNG � ������������� �� ���� ������ ���
                      // :nBmpMaskXXXX := 0x00CC0020    // SRCCOPY

         :Cargo := oHmgData()                 // init Cargo ��� THmgData ������-���������
      ELSE
         :Cargo:nHMain     := 0               // ������ �������� ���� ��������� � -> form_table.prg
         :Cargo:nTable     := aPrm[1]         // ����� �������
         :Cargo:aEdit      := aPrm[2]         // ������ ������ ��� �������������� �������
         :Cargo:hArrDown   := :aBitMaps[3]    // �������� �������_����  30x30
         :Cargo:hArrUp     := :aBitMaps[4]    // �������� �������_����� 30x30
         :Cargo:hArrDown20 := :aBitMaps[5]    // �������� �������_����  20x20
         :Cargo:hArrUp20   := :aBitMaps[6]    // �������� �������_����� 20x20
         :Cargo:hFltrAdd20 := :aBitMaps[7]    // �������� ������ 20x20
         :Cargo:bSupHd32   := :aBitMaps[8]    // �������� 32x118
         :Cargo:bArrDown32 := :aBitMaps[9]    // �������� �������_���� 36x36
         // ��������� ���� � ������ ���������� � THmgData ������-���������
         :Cargo:nClr_2     := aPrm[3]         // ���� ���� �������
         :Cargo:nClr_2_1   := aPrm[4]         // ���� ������\�������� row
         :Cargo:nClr_2_2   := aPrm[3]         // ���� ������\�������� row
         :Cargo:nClr_2_Del := aPrm[5]         // ���� �������� �������
         :Cargo:nClr_4_1   := aPrm[6]         // ���� ���� ����� �������: ��������
         :Cargo:nClr_4_2   := aPrm[7]         // ���� ���� ����� �������: ��������
         :Cargo:nClr_10_1  := aPrm[6]         // ���� ���� ������� �������: ��������
         :Cargo:nClr_10_2  := aPrm[7]         // ���� ���� ������� �������: ��������

         // �������������� ����� � �������
         IF :Cargo:nTable == 2
          :Cargo:nClr_1      := CLR_RED         // ���� ����� �������
         ELSE
          :Cargo:nClr_1      := CLR_BLACK       // ���� ����� �������
         ENDIF
         :Cargo:nClr_2Col1  := GetSysColor( COLOR_BTNFACE )   // ���� ���� ������ �������
         :Cargo:nClr_2xC10  := CLR_WHITE       // ���� ���� ����� 1-�������:10-������� - ���� COUNTRY
         :Cargo:nClr_2xBlck := CLR_ORANGE      // ���� ���� ����� ��� ����� ���� [+] [=] [^]

         :Cargo:nClr_Fltr   := CLR_YELLOW      // ���� ���� ������� ������� � ��������
         :Cargo:aColFilter  := {}              // ������� ������� � ��������
         :Cargo:aColNumFltr := {}              // ������ ������� ������� � ��������
         :Cargo:cBrwFilter  := ""              // ������ ������� �� ���� ������� �������
         :Cargo:cSuperHead  := ""              // ����� �����������
         :Cargo:nHSuperHead := 0               // ������ ������ �����������

      ENDIF
   END WITH

RETURN Nil

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myBrwSetting( oBrw, aTsbFont )   // ��������� �������
   LOCAL nCol, cCol, lRet, cFontHead := aTsbFont[2]
   LOCAL cFontFoot := aTsbFont[3]

   WITH OBJECT oBrw

      :nHeightCell    += 6              // ������� �������� � ������ �����
      :nHeightHead    := GetFontHeight(cFontHead) * 2       // ������ �����
      :nHeightFoot    := GetFontHeight(cFontFoot)           // ������ �������
      :nHeightSpecHd  := 24    // ������ ��������           // ������ ���������� ENUMERATOR

      :aColumns[1]:hFont := GetFontHandle(cFontHead  )      // 1-� ������� ������ Bold-����
      :aColumns[2]:hFont := GetFontHandle("TsbOneCol")      // 2-� ������� ������ ��� ����
      IF oBrw:Cargo:nTable > 2
         FOR nCol := 1 TO Len(:aColumns)
            cCol := :aColumns[ nCol ]:cName
            IF cCol == "CENA_ALL" .OR. cCol == "CENAMAST"
              :aColumns[nCol]:hFont := GetFontHandle("TsbOneCol")   // ������ ��� ���� �� �������
            ENDIF
         NEXT
      ENDIF

      // �������� ����: 1 = Cells, 2 = Headers, 3 = Footers, 4 = SuperHeaders
      //:ChangeFont( cFontHead, 5 , 1 )     // ������ ���� ����� ������� 5-�� ������� �� aStaticFont[2]
      //:ChangeFont( aTsbFont[ 3 ], , 2 )   // ������ ���� ����� ������� �� ...
      FOR nCol := 1 TO Len(:aColumns)
         cCol := :aColumns[ nCol ]:cName
         IF     cCol == "SELECTOR"
         ELSEIF cCol == "ORDKEYNO"
         ELSE
            :ChangeFont( aTsbFont[ 6 ], nCol, 3 )   // ������ ���� ������� ������� �� TsbBoldMini
         ENDIF
      NEXT

      // ��������� ������� ������ ��� ��������� - ����� �� ���������
      //:bKeyDown := { |nKey,nFalgs,ob| myKeyAction(nKey, 0, nFalgs, ob) }

      // ������� ���� ����� �����
      //:bLDblClick := {|p1,p2,p3,ob| p1:=p2:=p3, ob:PostMsg( WM_KEYDOWN, VK_RETURN, 0 ) }
      :bLDblClick := {|p1,p2,p3,ob|
                       Local nRow := ob:GetTxtRow( p1 )
                       Local nCol := ob:nAtColActual( p2 )
                       p3 := p1 > ob:nHeightSuper
                       ? "=>", nRow, nCol, p3, p1, ob:nHeightSuper
                       DO EVENTS
                       IF     nRow > 0      // Cell
                          ob:PostMsg( WM_KEYDOWN, VK_RETURN, 0 )
                       ELSEIF nRow ==  0
                          IF p3             // Header
                             _wPost(801, ob:cParentWnd, {ob, nRow, nCol, p1, p2, p3})
                          ELSE              // Super Header
                             _wPost(801, ob:cParentWnd, {ob, nRow, nCol, p1, p2, p3})
                          ENDIF
                       ELSEIF nRow == -1    // Footer
                          _wPost(801, ob:cParentWnd, {ob, nRow, nCol, p1, p2, p3})
                       ELSEIF nRow == -2    // SpecHd
                          _wPost(801, ob:cParentWnd, {ob, nRow, nCol, p1, p2, p3})
                       ENDIF
                       Return Nil
                     }

      (ThisWindow.Object):Event( 801, {|ow,ky,ap|
                                       Local oBrw := ap[1]   // �������� ������ �������
                                       Local nRow := ap[2]
                                       Local nCol := ap[3]
                                       Local nPixelRow, nPixelCol, cWnd, cBrw, lHeader, cMsg
                                       nPixelRow := ap[4]
                                       nPixelCol := ap[5]
                                       lHeader   := ap[6]
                                       cMsg := hb_ntos(ky)+" bLDblClick: "+hb_ntos(nRow)+", "+hb_ntos(nCol)
                                       cWnd := ow:Name
                                       cBrw := oBrw:cControlName
                                       IF nRow == 0
                                          IF lHeader ; cMsg += " Header "
                                             // ������ ��������� ����� �������
                                             //MsgBox(cMsg, "INFO: "+cBrw)
                                             myBrwHeadClick(3,oBrw,nPixelRow, nPixelCol,oBrw:nAt)
                                          ELSE       ; cMsg += " Super Head"
                                             // ������ ��������� ����������� �������
                                             //MG_Debug(nPixelRow, nPixelCol, cWnd, cBrw, lHeader, cMsg)
                                             myBrwHeadClick(3,oBrw,nPixelRow, nPixelCol,oBrw:nAt)
                                          ENDIF
                                       ENDIF
                                       Return Nil
                                      } )

      // ��������� ������� ESC
      :UserKeys(VK_ESCAPE, {|ob| _wSend(99, ob:cParentWnd), .F.  })
      // ��������� ������� ENTER
      :UserKeys(VK_RETURN, {|ob,nky,cky| lRet := myRecnoEnter(ob,nky,cky), lRet })

      // ������������� ������ ������� - ���������
      :UserKeys(VK_F4 ,    {|ob,nky,cky| lRet := myRecnoEnter(ob,nky,cky), lRet })
      :nFireKey := VK_F4   // KeyDown default Edit

      // �������� ������ �� ������� F12
      :UserKeys(VK_F12,    {|ob| myBrwInfoFont( ob )   })
      // ���� �� ������ �������
      :UserKeys(VK_F2 ,    {|ob| myBrwListColumn( ob ) })
      // ���� �� ������ ������
      :UserKeys(VK_F3 ,    {|ob| myBrwInfoRecno( ob ) })

      :SetAppendMode( .F. )    // ��������� ������� ������ � ����� ���� �������� ����
      //:SetDeleteMode( .F. )  // �������� ������ ���������

      // ������ ��� ��������, ����� �������� � �� ��������������
      :SetDeleteMode( .T., .F., {|| MG_YesNo( "�������� !;;" + iif((oBrw:cAlias)->(Deleted()) ,;
                                              "������������", "�������") + ;
                                              " ������ � ������� ?;", "�������������") } )

      // �������/�������� ������ ����� ������� - ������
      //:UserKeys(VK_INSERT, {|ob| _wPost(71, ob, ob), .F. }) // ������ Insert
      //:UserKeys(VK_DELETE, {|ob| _wPost(72, ob, ob), .F. }) // ������ Delete
      //(ThisWindow.Object):Event( 71, {|ob,ob| RecnoInsert(ob)        } )
      //(ThisWindow.Object):Event( 72, {|ob,ob| RecnoDeleteRecover(ob) } )

      // �������/�������� ������ - ��������
      :UserKeys(VK_INSERT, {|ob| RecnoInsert(ob)       , .F. })
      :UserKeys(VK_DELETE, {|ob| RecnoDeleteRecover(ob), .F. })

      //:bGotFocus := {|ob| myGotFocusTsb(ob)     }   // ������
      //:bOnDraw   := {|ob| SayStatusBar(ob)      }   // ����� StatusBar - Recno/Column

   END WITH

RETURN Nil

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myBrwDelColumn(oBrw)      // ������ ������� �� �����������
   LOCAL nCol, aHideCol := {}
   LOCAL aCol := oBrw:aColumns
   LOCAL cDelCol, oCol, cCol

   // ��������� �������
   cDelCol := LOWER("Not-show")        // -> ListTables.prg

   // ������ �������
   FOR nCol := 1 TO Len(aCol)
      oCol := aCol[ nCol ]
      cCol := LOWER( oCol:cHeading )
      IF cCol == cDelCol
         AADD( aHideCol , nCol )
      ENDIF
   NEXT

   IF Len(aHideCol) > 0
      oBrw:HideColumns( aHideCol ,.t.)   // ������ �������
   ENDIF

RETURN Nil

//////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myBrwColumnWidth( oBrw )  // ��������� ������ ������ �������
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

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myBrwMaskBmp(oBrw)                   // ����� ������ ��������
   LOCAL oCol, cCol

   // ��������� ����� ������ �������� � �������
   FOR EACH oCol IN oBrw:aColumns
      cCol := oCol:cName
      //IF oCol:lVisible
         //oCol:nBmpMaskHead := 0x00CC0020    // SRCCOPY - ������
         //oCol:nBmpMaskFoot := 0x00CC0020    // SRCCOPY - ������
         oCol:nBmpMaskHead   := 0x00BB0226    // MERGEPAINT
         oCol:nBmpMaskFoot   := 0x00BB0226    // MERGEPAINT
         oCol:nBmpMaskSpcHd  := 0x00CC0020    // SRCCOPY
         //oCol:nBmpMaskCell := 0x00CC0020    // SRCCOPY - ������ ������� ����������
         //oCol:nBmpMaskCell := 0x00BB0226    // MERGEPAINT - ������ �������
      //ENDIF
   NEXT

RETURN Nil

///////////////////////////////////////////////////////////////////////////////
// ENUMERATOR �� ������� ������� ����
STATIC FUNCTION myBrwEnum( oBrw, nOneCol )
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

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myBrwColorChange( oBrw, nTable )          // ����� ��������
   LOCAL o, oCol, nBC1Col, cCol, cTyp

   o        := oBrw:Cargo          // �������� ������ �� �������
   nBC1Col  := o:nClr_2Col1        // ���� ���� ������� 1-2

   IF nTable == 3 .OR. nTable == 4
      //oBrw:GetColumn("ORDKEYNO"):nClrBack := nBC1Col
   ENDIF
   oCol := oBrw:GetColumn("ORDKEYNO")
   oCol:nClrBack := nBC1Col

   // ��������� �������� ��� �������� ������� � ������� ORDKEYNO
   oCol:uBmpCell := {|nc,ob| nc:=nil, iif( (ob:cAlias)->(Deleted()), ob:aBitMaps[2], ob:aBitMaps[1] ) }

   //oCol := oBrw:GetColumn("SELECTOR")  // ��� �� ����� ��������, �.�.
   //oCol:nClrBack := nBC1Col            // ������� SELECTOR ��� ���

   // ��������� ����� ���������� - ENUMERATOR (��������� �������)
   FOR EACH oCol IN oBrw:aColumns
      oCol:nClrSpcHdBack := nBC1Col     // ::aColorsBack[ 18 ]
      oCol:nClrSpcHdFore := CLR_BLACK   // ::aColorsBack[ 19 ]
   NEXT

   // ����� ���� TBROWSE
   oBrw:nClrHeadBack := oBrw:Cargo:nClr_2_2

   // �������� �� ���� ���� ������ �������
   oBrw:SetColor( {1}, { { |nr,nc,ob| BrwColorForeCell(nr,nc,ob) } } ) // 1 , ������ � ������� �������
   oBrw:SetColor( {2}, { { |nr,nc,ob| BrwColorBackCell(nr,nc,ob) } } ) // 2 , ���� � ������� �������

   // ���� ���� ����� ������� + ������� ��� ����������� ������ �������
   FOR EACH oCol IN oBrw:aColumns
      cCol := oCol:cName
      cTyp := oCol:cFieldTyp
      IF cCol == "COUNTRY"
         oCol:nClrHeadBack := { |n,b  | myTsbColorBackHead(n,b) }
         oCol:nClrFootBack := { |n,b  | myTsbColorBackHead(n,b) }
      ENDIF
      IF cTyp $ "+=^"   // Type: [+] [=] [^]
         oCol:nClrHeadBack := { |n,b  | myTsbColorBackHead(n,b) }
         oCol:nClrFootBack := { |n,b  | myTsbColorBackHead(n,b) }
      ENDIF
   NEXT

RETURN Nil

///////////////////////////////////////////////////////////////////////////////
// ��������� ����� � ������� � ����������(����������) �������
STATIC FUNCTION myBrwHeaderFooterSpcHd(oBrw,aFAlign)
   LOCAL nI, oCol, cCol

   /* �������� \SOURCE\TsBrowse\TSCOLUMN.PRG
   // Click Event - ���� ������
   DATA bFLClicked   // ���� ��� ������ � ������ �����������, ������� ����� ������� ����
   DATA bFRClicked   // ���� ��� ������ � ������ �����������, ������� ������ ������� ����
   DATA bHLClicked   // ���� ��� ������ �� ���������(�����-�������), ������� ����� ������� ����
   DATA bHRClicked   // ���� ��� ������ � ���������(�����-�������), ������� ������ ������� ����
   DATA bSLClicked   // ���� ��� ������ � ����������� ���������(���������), ������� ����� ������� ����
   DATA bSRClicked   // ���� ��� ������ � ����������� ���������(���������), ������� ������ ������� ����
   DATA bLClicked    // ���� ��� ������ ��� ������ ����� ������� ���� �� ������
   */
   FOR nI := 1 TO Len( oBrw:aColumns )
      oCol := oBrw:aColumns[ nI ]
      cCol := oCol:cName
      IF ISARRAY(aFAlign)
         oCol:nFAlign := DT_CENTER //aFAlign[ nI ]
      ENDIF
      IF cCol == "ORDKEYNO" .OR. cCol == "SELECTOR"
      ELSE
         // �������� � ����� ������� ������� - �������_����  20x20
         // {|| hArrDown } - ��� ������
         oCol:uBmpHead  := {|nc,ob| nc := ob:Cargo, nc:hArrDown20 }
         oCol:nHAlign   := nMakeLong( DT_CENTER, DT_RIGHT  )
         // �������� � ������� ������� ������� - �������_����� 20x20
         oCol:uBmpFoot  := {|nc,ob| nc := ob:Cargo, nc:hArrUp20  }
         oCol:nFAlign   := nMakeLong( DT_CENTER, DT_RIGHT  )
         // �������� � ���������� ������� ������� - �������_����  20x20
         oCol:uBmpSpcHd := {|nc,ob| nc := ob:Cargo, nc:hArrDown20   }
         oCol:nSAlign   := nMakeLong( DT_CENTER, DT_RIGHT  )
      ENDIF
      // ��������� ��� ����� � ����������� �������
      oCol:bHLClicked := {|nrp,ncp,nat,obr| myBrwHeadClick(1,obr,nrp,ncp,nat) }
      oCol:bHRClicked := {|nrp,ncp,nat,obr| myBrwHeadClick(2,obr,nrp,ncp,nat) }
      // ��������� ��� ������� �������
      oCol:bFLClicked := {|nRowPix,nColPix,nAt,oBrw| myBrwFootClick(1,nRowPix,nColPix,nAt,oBrw) }
      oCol:bFRClicked := {|nRowPix,nColPix,nAt,oBrw| myBrwFootClick(2,nRowPix,nColPix,nAt,oBrw) }
      // ��������� ��� SpecHd �������
      oCol:bSLClicked := {|nrp,ncp,nat,obr| myBrwSpcHdClick(1,nrp,ncp,nat,obr) }
      oCol:bSRClicked := {|nrp,ncp,nat,obr| myBrwSpcHdClick(2,nrp,ncp,nat,obr) }
   NEXT

RETURN Nil

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myBrwSuperHeader(oBrw,aSupHdr)   // ������� ���������� �������
   LOCAL nI, nFSz, aFont, hFont

   hFont  := GetFontHandle("TsbSuperH")
   aFont  := GetFontParam( hFont )
   nFSz   := aFont[2]

   WITH OBJECT oBrw
      /*
      //---------- ������� ��� �������� ����������� -------------
      Add Super Header To oBrw From Column 1 To Column 1 Title ""

      Add Super Header To oBrw From Column 2 To Column 2 Title "" ;
           BITMAP :Cargo:bArrDown32 HORZ DT_CENTER VERT DT_CENTER

      Add Super Header To oBrw From Column 2 To Column :nColCount() ;
          Title aSupHdr[1] BITMAP :Cargo:bSupHd32 HORZ DT_CENTER VERT DT_CENTER
      */
      // ��������� 1,2,3 ������� - ����������
      :AddSuperHead( 1, 1, "",,, .F.,,, .F., .F., .F.,, )
      :AddSuperHead( 2, 2, "",,, .F.,, :Cargo:bArrDown32, .F., .F., .F., DT_CENTER, DT_CENTER )
      :AddSuperHead( 2, :nColCount(), aSupHdr[1],,, .F.,, :Cargo:bSupHd32, .F., .F., .F., DT_CENTER, DT_CENTER )

      // ������ ������ � �������, ����� END TBROWSE ... ������������,
      // �.�. ��� ���������� "����������" � ����� ���������
      // � ������ ������ ������ ������ ����������� � 2 ������
      //:nHeightSuper := nFSz * 2 + 10                  // ������ ��������� (�����������)

      // ���������� �� ������ �������� 40x140 - "bSupHd40"
      :nHeightSuper   := 40 + 2*2                     // ������ ��������� (�����������)

      //:nHeightSuper := 0                            // ������ ���������� - ���� ����

      :Cargo:cSuperHead  := aSupHdr[1]                // �������� ����� �����������
      :Cargo:nHSuperHead := :nHeightSuper             // �������� ������ ������ �����������

      //SuperHeader oBrw:aSuperHead[ nI, 15 ] - ��� nBitmapMask ��� ������ SuperHead
      // ��������� ����� ������ �������� � ����������� �������
      FOR nI := 1 TO Len( :aSuperHead )
         IF !Empty( :aSuperHead[ nI ][8] )           // uBitMap ����� ?
            :aSuperHead[ nI ][15]   := 0x00BB0226    // MERGEPAINT
            //:aSuperHead[ nI ][15] := 0x00CC0020    // SRCCOPY
         ENDIF
      NEXT

      // ������ �������� ����� �������� = ������ �����������
      //? "  ������ �����������=", :nHeightSuper, ProcNL()

   END WITH

RETURN Nil
///////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myRecnoEnter( oBrw, nKey, cKey )  // ������������� ������
   LOCAL o, nTable, lDel, aEdit, cMsg, nCell, nRow, nDop, cCol, nCol, oCol
   LOCAL lEdit, cTyp, lVal, lRet, cVal, oCell, nY, nX, nW, nH, nHMain

   ? PROCNL()
   o      := oBrw:Cargo                    // �������� ������ �� �������
   nTable := o:nTable                      // ����� �������
   nHMain := o:nHMain                      // ������ �������� ����
   lDel   := (oBrw:cAlias)->( DELETED() )  // ������� �� ������ ?
   aEdit  := o:aEdit                       // ������ ������ ��� �������������� �������
   nCell  := oBrw:nCell                    // ����� ������/������� � �������
   nRow   := oBrw:nAt                      // ����� ������ � �������
   oCell  := oBrw:GetCellInfo(oBrw:nRowPos)
   nY     := oCell:nRow + oBrw:nHeightHead + 4 + nHMain
   nX     := oCell:nCol
   nW     := oCell:nWidth
   nH     := oCell:nHeight

   nDop := 0
   FOR nCol := 1 TO 3
      cCol := oBrw:aColumns[ nCol ]:cName
      IF cCol == "SELECTOR" .OR. cCol == "ORDKEYNO"
         nDop ++
      ENDIF
   NEXT

   IF lDel
      cMsg := "��������� ������������� ��������� ������ !;;"
      cMsg += ProcNL()
      MG_Stop(cMsg)
      Return .F.
   ENDIF

   oCol := oBrw:aColumns[ nCell ]
   cTyp := oCol:cFieldTyp
   cCol := oCol:cName
   IF cTyp $ "+=^"   // Type: [+] [=] [^]
      cMsg := "��������� ������������� ���� [" + cCol + "] ����� ���� !;;"
      cMsg += ProcNL()
      MG_Stop(cMsg)
      Return .F.
   ENDIF

   IF nCell <= 2
      cMsg := "��������� ������������� ������� [" + cCol + "] � ������� !;;"
      cMsg += ProcNL()
      MG_Stop(cMsg)
      Return .F.
   ENDIF

   lEdit := aEdit[nCell - nDop]  // � ������ ���.������� � �������
   IF !lEdit
      cMsg := "��������� ������������� ���� [" + cCol + "] � ������� aEdit[] !;;"
      cMsg += ProcNL()
      MG_Stop(cMsg)
      Return .F.
   ENDIF

   IF nTable == 5
      cMsg := "������� ����� 5 - ��������� ������������� .....;;"
      cMsg += ProcNL()
      MG_Stop(cMsg)
      Return .F.
   ENDIF

   If cTyp == "L"
      lVal := oBrw:GetValue(cCol)
      IF !oBrw:lCheckBoxAllReturn         // ���� .F. � ���������� myBrwInit()
         IF (oBrw:cAlias)->(RLock())      // �� ������ ������
            oBrw:SetValue( cCol, !lVal )
            (oBrw:cAlias)->(dbUnLock())
            oBrw:DrawSelect()             // ������������ ������� ������ �������
         ENDIF
      ENDIF
   EndIf

   // lRet := myTableEnterGeneral(oBrw)

   IF nTable == 1 .AND. cCol == "COUNTRY"
      IF nKey == VK_F4
         // ����� �������������
         cVal := "F4 - ����� �������������"
      ELSE
         cVal := myMenuListCountry(oBrw)     // -> menu_list.prg
         IF LEN(cVal) > 0
            IF (oBrw:cAlias)->(RLock())      // �� ������ ������
               oBrw:SetValue( cCol, cVal )
               (oBrw:cAlias)->(dbUnLock())
               oBrw:DrawSelect()             // ������������ ������� ������ �������
            ENDIF
         ENDIF
         Return .F.
      ENDIF
   ENDIF

#ifdef _HMG_OUTLOG
   MG_Debug( nKey, cKey,"����� �������=", nTable, "Alias=",oBrw:cAlias,;
            "Deleted()=",lDel,"nCell=",nCell,"nRow=",nRow, "lEdit=",lEdit, cVal,;
             "���������� ������:", nY, nX, nW, nH )
#else
   cKey := NIL
#endif
   lRet := .T.

   //oBrw:aColumns[nCell]:lEdit := .T.

RETURN lRet

///////////////////////////////////////////////////////////////////////////////
// ������ ����� �������, ����� ����� ����� Tsbrowse, ������ :SetColor(...)
STATIC FUNCTION myBrwGetColor(nTable,nPane,nPane2,nPane3,nHead1,nHead2)
   LOCAL aColors, nBCSpH
   DEFAULT nHead1 := 0 , nHead2 := 0

   // nPane  // ���� ���� �������
   // nPane2 // ���� ���� ������� ����� ���� ������
   // nPane3 // ���� ���� ������� �������� �������

   nBCSpH := GetSysColor( COLOR_BTNFACE )     // ���� ���� ���������� �������
   IF nHead1 == 0
      nHead1 := ToRGB( { 40, 122, 237 } )     // ������� ����
   ENDIF
   IF nHead2 == 0
      nHead2 := ToRGB( { 48,  29,  26 } )     // ����-������ ���
   ENDIF

   aColors := {}
   AAdd( aColors, { CLR_TEXT  , {|| CLR_BLACK          } } )            // 1 , ������ � ������� �������
   AAdd( aColors, { CLR_PANE  , {|| nPane              } } )            // 2 , ���� � ������� �������

   // ---- ��� �� ��������, ����� ������ ����� ���� ����
   //AAdd( aColors, { CLR_PANE  , {|nr,nc,ob| nr:=nc, iif( (ob:cAlias)->(DELETED()), nPane3 ,;
   //                                         iif( ob:nAt % 2 == 0, nPane2, nPane ) )   } } )

   // ---- �������� �� ���� ���� ������ ������� - ��� ���� �� ��������, �� ���������� oBrw:Cargo
   //AAdd( aColors, { CLR_TEXT  , {|nr,nc,ob| BrwColorForeCell(nr,nc,ob) } } ) // 1 , ������ � ������� �������
   //AAdd( aColors, { CLR_PANE  , {|nr,nc,ob| BrwColorBackCell(nr,nc,ob) } } ) // 2 , ���� � ������� �������
   nPane2 := nPane3  // ����� ������ ����������

   AAdd( aColors, { CLR_HEADF , {|| ToRGB( YELLOW )    } } )            // 3 , ������ ����� �������
   AAdd( aColors, { CLR_HEADB , {|| { nHead1, nHead2 } } } )            // 4 , ���� ����� �������
   AAdd( aColors, { CLR_FOCUSF, {|| CLR_BLACK } } )                     // 5 , ������ �������, ����� � ������� � �������

   //AAdd( aColors, { CLR_FOCUSB, {|a,b,c| a := b, If( c:nCell == b, ; // 6 , ���� �������
   //                         CLR_HRED, { RGB( 163, 163, 163 ), RGB( 127, 127, 127 ) } ) } } )
   AAdd( aColors, { CLR_FOCUSB, {|a,b,c| a := b, If( c:nCell == b, ;
                                          -CLR_HRED, -CLR_BLUE ) } } ) // 6 , ���� �������

   AAdd( aColors, { CLR_EDITF , {|| CLR_RED    } } )                   // 7 , ������ �������������� ����
   AAdd( aColors, { CLR_EDITB , {|| CLR_YELLOW } } )                   // 8 , ���� �������������� ����
   AAdd( aColors, { CLR_FOOTF , {|| ToRGB( YELLOW )       } } )        // 9 , ������ ������� �������
   AAdd( aColors, { CLR_FOOTB , {|| { nHead1, nHead2 }    } } )        // 10, ���� ������� �������
   AAdd( aColors, { CLR_SELEF , {|| CLR_GRAY   } } )                   // 11, ������ ����������� ������� (selected cell no focused)
   AAdd( aColors, { CLR_SELEB , {|| { RGB(255,255,74), ;               // 12, ���� ����������� ������� (selected cell no focused)
                                         RGB(240,240, 0) } } } )
   AAdd( aColors, { CLR_ORDF  , {|| CLR_WHITE  } } )                   // 13, ������ ����� ���������� �������
   AAdd( aColors, { CLR_ORDB  , {|| CLR_RED    } } )                   // 14, ���� ����� ���������� �������
   AAdd( aColors, { CLR_LINE  , {|| CLR_GRAY   } } )                   // 15, ����� ����� �������� �������
   AAdd( aColors, { CLR_SUPF  , {|| nBCSpH     } } )                   // 16, ���� ���������
   //AAdd( aColors, { CLR_SUPF  , {|| { CLR_WHITE, nHead1 }  } } )     // 16, ���� ���������
   AAdd( aColors, { CLR_SUPB  , {|| CLR_RED    } } )                   // 17, ������ ���������

   IF nTable == 1  // ����� ������ ����� � ����������� �� �������
   ENDIF

RETURN aColors

///////////////////////////////////////////////////////////////////
// 1 , ����� � ������� �������
// ������ ��� ��������� ������� �� ������� CENAMAST
STATIC FUNCTION BrwColorForeCell( nAt, nCol, oBrw )
   LOCAL nColor, nSum, o, nTable, nText, lDel, cCol, nBC1Col
   Default nAt := 0 , nCol := 0

   o       := oBrw:Cargo                      // �������� ������ ��
   nTable  := o:nTable                        // ����� �������
   nText   := o:nClr_1                        // ���� ����� �������
   nBC1Col := o:nClr_2Col1                    // ���� ���� ������� 1-2
   lDel    := (oBrw:cAlias)->( DELETED() )    // ������� �� ������ ?

   cCol := oBrw:aColumns[ nCol ]:cName
   IF cCol == "SELECTOR" .OR. cCol == "ORDKEYNO"
      nColor := nText
   ELSE

      IF nTable > 2  // ��� � �������� ������� ��� ����� ������

         If Len(oBrw:aColumns) > 0
            nSum := Eval( oBrw:GetColumn('CENAMAST'):bData )
         EndIf

         // ��������� ��������� ��������
         IF VALTYPE(nSum) != "N"
            RETURN CLR_HGRAY
         ENDIF

         cCol := oBrw:aColumns[ nCol ]:cName
         IF cCol == 'CENAMAST'
            IF nSum <= -1500
               nColor := CLR_HRED
            ELSEIF nSum < 0
               nColor := CLR_RED
            ELSEIF nSum <= 100
               nColor := CLR_GREEN
            ELSEIF nSum > 100
               nColor := CLR_BLUE
               nColor := CLR_BLUE
            ENDIF
         ELSE
            nColor := nText
         ENDIF

      ELSE
         // ��� nTable = 1 � 2
         nColor := nText
      ENDIF

      // ��� ������� ��������� ������
      IF lDel // ������� �� ������ ?
         nColor := CLR_HGRAY
      ENDIF

   ENDIF

RETURN nColor

////////////////////////////////////////////////////////////////////////////////////
// 2 , ���� � ������� �������
STATIC FUNCTION BrwColorBackCell( nAt, nCol, oBrw )
   LOCAL nColor, lDel, o, nTable, nTBC, nTBC1, nTBC2, nTBCdel, nBC1Col, cCol
   LOCAL nBCFltr, aColFltr, nJ
   Default nAt := 0, nCol := 0

   o        := oBrw:Cargo                      // �������� ������ ��
   nTable   := o:nTable                        // ����� �������
   nTBC     := o:nClr_2                        // ���� ���� �������
   nTBC1    := o:nClr_2_1                      // ���� ������\�������� row
   nTBC2    := o:nClr_2_2                      // ���� ������\�������� row
   nTBCdel  := o:nClr_2_Del                    // ���� �������� �������
   nBC1Col  := o:nClr_2Col1                    // ���� ���� ������� 1-2
   nBCFltr  := o:nClr_Fltr                     // ���� ���� ������� ������� � ��������
   aColFltr := o:aColNumFltr                   // ������ ������� ������� � ��������
   lDel     := (oBrw:cAlias)->( DELETED() )    // ������� �� ������ ?

   cCol := oBrw:aColumns[ nCol ]:cName
   IF cCol == "SELECTOR" .OR. cCol == "ORDKEYNO"
      nColor := nBC1Col
   ELSE

      IF nTable == 3 .OR. nTable == 4  // ��� � �������� ������� ��� ����� ������
         IF oBrw:nAt % 2 == 0
            nColor := nTBC2
         ELSE
            nColor := nTBC1
         ENDIF
      ELSE
         nColor := nTBC
      ENDIF

      // ���� ���� ������ �� �������
      IF LEN(aColFltr) > 0
         FOR nJ := 1 TO LEN(aColFltr)
            IF aColFltr[nJ] == nCol
               nColor := nBCFltr
            ENDIF
         NEXT
      ENDIF

      // ��� ������� ��������� ������
      IF lDel                 // ������� �� ������ ?
         nColor := nTBCdel
      ENDIF

   ENDIF

RETURN nColor

///////////////////////////////////////////////////////////////////////////////
// 4 + 10 , ���� �����/������� � �������
STATIC FUNCTION myTsbColorBackHead( nCol, oBrw )
   LOCAL o, cName, nColor, cType, nBCxC10, nBCxBlck, nClr_4_1, nClr_4_2

   o        := oBrw:Cargo              // �������� ������ �� ����������
   nBCxC10  := o:nClr_2xC10            // ���� ���� ����� 1-�������:10-������� - ���� COUNTRY
   nBCxBlck := o:nClr_2xBlck           // ���� ���� ����� ��� ����� ���� [+] [=] [^]
   nClr_4_1 := o:nClr_4_1              // ���� ���� ����� �������: ��������
   nClr_4_2 := o:nClr_4_2              // ���� ���� ����� �������: ��������
   cName    := oBrw:aColumns[nCol]:cName
   cType    := oBrw:aColumns[nCol]:cFieldTyp

   IF cName == "COUNTRY"
      nColor := { nBCxC10, nClr_4_2 }
   ELSE
      nColor := { nClr_4_1, nClr_4_2 }
   ENDIF

   IF cType $ "+=^"   // Type: [+] [=] [^]
      nColor := { nBCxBlck, nClr_4_2 }
   ENDIF

RETURN nColor

//////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION mySetNoHoles(oBrw)
   LOCAL nHole, nProc
   /*
   ? ProcNL() , "����� � ����� ������� "
   ? "nHeightSuper =", oBrw:nHeightSuper
   ? "nHeightHead  =", oBrw:nHeightHead
   ? "nHeightSpecHd=", oBrw:nHeightSpecHd
   ? "nHeightFoot  =", oBrw:nHeightFoot
   ? "nHeightCell  =", oBrw:nHeightCell
   */
   nHole := oBrw:SetNoHoles(1, .F.)  // ������ ������ �����, ��� ��������� �����
   //!!!  nHole ��� ��, ��� ���� ��������� �����
   //!!!  ����������� :nHeightSuper, :nHeightHead, :nHeightSpcHd, :nHeightFoot

   // � ������ ������, ��� ������� ��������� ������ :nHeightSuper � :nHeightSpcHd
   // ��� ��� ��� ������������ ��������, �� nHole ���� �� 2 ��������
   nProc := 0.5                      // 2 ��������
   //? "nHole=", nHole, "nProc=", nProc
   oBrw:nHeightHead   += INT(nHole * nProc)   // �������� � ������ �����
   oBrw:nHeightFoot   += INT(nHole * nProc)   // �������� � ������ �������
   //oBrw:nHeightSuper  +=
   //oBrw:nHeightSpecHd +=
   /*
   ? "    ����� ���������� �������� � ������ ����� + �������:", INT(nHole * nProc)
   ? "nHeightSuper =", oBrw:nHeightSuper
   ? "nHeightHead  =", oBrw:nHeightHead
   ? "nHeightSpecHd=", oBrw:nHeightSpecHd
   ? "nHeightFoot  =", oBrw:nHeightFoot
   ? "nHeightCell  =", oBrw:nHeightCell
   */
   nHole := oBrw:SetNoHoles(1, .F.)  // ������ ������ �����, ��� ��������� �����
   //? "nHole=", nHole
   IF nHole >= 1
      oBrw:nHeightFoot += nHole  // ������� ������� � ������
      //? "  ������� ������� � ������ ������� - :nHeightFoot  =", oBrw:nHeightFoot
   ENDIF

   nHole := oBrw:SetNoHoles(1)  //!!! ������ ������ ����� ���������� � ������ ��������� (��������)
   //? "New nHole =", nHole

RETURN nHole

//////////////////////////////////////////////////////////////////////////////
// ����� ������ � ���� ����������� � ����� ���� � ��������� ����� � ��������������
STATIC FUNCTION RecnoInsert(oBrw)
   LOCAL nRecno

   IF MG_YesNo( "�������� ������ � ������� ?", "���������� ������" )
      // �������� � ���� DT_ADD ����+����� ������� ������
      oBrw:bAddAfter  := {|ob,ladd|
                           If ladd
                              (ob:cAlias)->( dbSkip(0) )
                              //(ob:cAlias)->DT_ADD := (ob:cAlias)->TS
                           EndIf
                           Return Nil
                         }

      // ���������� ����� ��� ���������� ������
      oBrw:AppendRow(.T.)

      oBrw:bAddAfter  := Nil

      IF (oBrw:cAlias)->(RLock())
         //(oBrw:cAlias)->DT_USER := M->nPubUser     // ��� ������� ������
         //(oBrw:cAlias)->IM      := hb_DateTime()   // ����� �������� ������
         (oBrw:cAlias)->(DBUnlock())
      ENDIF
      (oBrw:cAlias)->(DbCommit())

      nRecno := (oBrw:cAlias)->( RecNo() )
      ? ProcNL(), "Insert=", nRecno

      oBrw:nCell := 3  // � ������ ������� ��� ��������������
      oBrw:Setfocus()
      DO EVENTS

   ENDIF

RETURN Nil

////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION RecnoDeleteRecover(oBrw, lSet)
   LOCAL lChange, cChange, nAt, lDelete, nRecno, nRecnew
   DEFAULT lSet := .F.

   IF lSet

      // �������� ��� ������, ������ �� Eval(...), �.�.
      // oBrw:bDelBefore := {|rec,obr| ... }
      // oBrw:bDelAfter  := {|rec,obr| ... }
      // oBrw:bDelete    := {|rec,obr: ... }
      // oBrw:bPostDel   := {|obr    | ... }
      // �� �������� � �������������� �������� ���� :bPostDel

      oBrw:Cargo:nRecnoDeleteRecover := 0
      oBrw:bPostDel := {|ob|
                        Local nRec := ob:Cargo:nRecnoDeleteRecover  // ������ �� ������� ���� �� :DeleteRow()
                        Local cAls := ob:cAlias
                        Local nOld := (cAls)->( RecNo() )
                        Local lDel
                        If nRec > 0
                           (cAls)->( dbGoto( nRec ) )
                           lDel := (cAls)->( Deleted() )   // .T. - ������ �������
                           If (cAls)->( RLock() )
                              // ���� ����� ������ � ���� ����+����� ��� ���� ��������
                              //If lDel ; (cAls)->DT_DEL  := hb_DateTime()
                              //Else    ; (cAls)->DT_REST := hb_DateTime()
                              //EndIf
                              (cAls)->( DbUnLock() )
                           EndIf
                           (cAls)->( dbGoto( nOld ) )
                        EndIf
                        Return nil
                       }
      RETURN Nil
   ENDIF

   oBrw:Cargo:nRecnoDeleteRecover := (oBrw:cAlias)->(RecNo())

   nAt     := oBrw:nAt     // ��� dbf :nAt ����� �� ������������
   lDelete := (oBrw:cAlias)->(Deleted())
   nRecno  := (oBrw:cAlias)->(RecNo())

   // ��������/�������������� ������ ��������� !!!
   // ���������� ����� ��� �������� ������� ������
   lChange := oBrw:DeleteRow(.F., .T.)

   DO EVENTS

   IF lChange             // ��������� ����
      nRecnew := (oBrw:cAlias)->(RecNo())
      (oBrw:cAlias)->(dbGoto(nRecno))
      cChange := iif( lDelete, "Recover ", "Delete " )
      ? ProcNL()
      ? "    ...",hb_DateTime(), "cChange=", cChange, "nRecno=",nRecno
      ?? "Deleted=",(oBrw:cAlias)->(Deleted())
      (oBrw:cAlias)->(dbGoto(nRecnew))
   ENDIF

   oBrw:Cargo:nRecnoDeleteRecover := 0
   oBrw:DrawLine()     // ������������ ������� ������ �������
   oBrw:SetFocus()
   DO EVENTS

RETURN Nil

///////////////////////////////////////////////////////////////////////////////////
// ����������� ���� ��� / TSB context menu
STATIC FUNCTION myBrwContextMenu(oBrw)
   LOCAL nI, nJ, aTsbMnu, nTsbMnu, cTsbMnu, hFont1, hFont2, hWnd, cMenu, cImage

   SET MENUSTYLE EXTENDED
   SetMenuBitmapHeight( 32 )
   SetThemes(1)               // ���� "Office 2000 theme"
   //SetThemes(2)             // ���� SILVER

   hFont1 := GetFontHandle( "TsbNorm" )
   hFont2 := GetFontHandle( "TsbBold" )
   hWnd   := GetFormHandle(oBrw:cParentWnd)

   // � �������� ������� - ������� ����������� ���� �������
   //DEFINE CONTEXT MENU CONTROL &(oBrw:cControlName)
   //   MENUITEM "F2  - ���� �� �������� �������" ACTION {|| myBrwListColumn(oBrw)} NAME 0081 FONT hFont1 IMAGE "Dbg32"
   //   MENUITEM "F3  - ���� �� ������ ������"    ACTION {|| myBrwInfoRecno(oBrw) } NAME 0082 FONT hFont1 IMAGE "Dbg32"
   //   MENUITEM "F12 - ���� �� ������ �������"   ACTION {|| myBrwInfoFont(oBrw)  } NAME 0083 FONT hFont1 IMAGE "Dbg32"
   //   SEPARATOR
   //   MENUITEM "������ �������� ��"     ACTION {|| myGetAllUse()                      } FONT hFont1 NAME 0084 IMAGE "bBase32"
   //   MENUITEM "������� ����"           ACTION {|| Base_Tek()                         } FONT hFont1 NAME 0085 IMAGE "bBase32"
   //   MENUITEM "Set relation ���� ����" ACTION {|| MG_Info( Base_Relation( ALIAS() )) } FONT hFont1 NAME 0086 IMAGE "bBase32"
   //   MENUITEM "DbFilter ���� ����"     ACTION {|| Darken2Open(hWnd) ,;
   //                                                MG_Info( "DbFilter() ���� ����: " +;
   //                                                  (oBrw:cAlias)->( DbFilter() )) ,;
   //                                                Darken2Close(hWnd)                 } FONT hFont1 NAME 0087 IMAGE "bBase32"
   //   MENUITEM "������ �� (Cargo)"      ACTION {|| Darken2Open(hWnd) ,;
   //                                                MG_Debug("������ ������ � Cargo:",;
   //                                                oBrw:Cargo:cBrwFilter    ,;
   //                                                oBrw:Cargo:aColFilter    ,;
   //                                                oBrw:Cargo:aColNumFltr)  ,;
   //                                                Darken2Close(hWnd)                 } FONT hFont1 NAME 0088 IMAGE "bBase32"
   //   SEPARATOR
   //   MENUITEM "�����"   ACTION Nil  NAME 0089  FONT hFont2
   //END MENU

   nTsbMnu  := 80
   aTsbMnu  := { " F2  - ���� �� �������� �������", " F3  - ���� �� ������ ������",;
                 " F12 - ���� �� ������ �������"  , "SEPARATOR"                   ,;
                 " ������ �������� ��"            , " ������� ����"               ,;
                 " Set relation ���� ����"        , " Dbfilter ���� ����"         ,;
                 " ������ �� (Cargo)"         }

   DEFINE CONTEXT MENU CONTROL &(oBrw:cControlName)

      nJ := 1
      FOR nI := 1 TO Len(aTsbMnu)
         cMenu   := aTsbMnu[ nI ]
         IF cMenu == "" .OR. cMenu == "SEPARATOR"
            SEPARATOR
         ELSE
            cTsbMnu := StrZero(nTsbMnu + nJ, 4)
            cImage := IIF( "F" $ cMenu, "Dbg32", "bBase32" )
            MENUITEM cMenu ACTION _wPost(80, ,This.Name) NAME &(cTsbMnu) FONT hFont1 IMAGE cImage
            nJ++
         ENDIF
      NEXT
      (ThisWindow.Object):Event( 80, {|ow,ky,cnam| myTsbContextMnu(ow,ky,cnam) } )
      SEPARATOR
      MENUITEM  "Exit"  ACTION {|| Nil } FONT hFont2 NAME 0089

   END MENU

   oBrw:SetFocus()

RETURN Nil

///////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbContextMnu(ow, ky, cItm)
   LOCAL oBrw  := (ThisWindow.Object):Cargo:oBrw     // �������� ������ �� �������
   LOCAL hWnd, cForm := ow:Name

   IF ISOBJECT(oBrw)
      hWnd := GetFormHandle(oBrw:cParentWnd)
      ky   := VAL(cItm)
      Darken2Open(hWnd)
      IF     ky == 81
         myBrwListColumn(oBrw)
      ELSEIF ky == 82
         myBrwInfoRecno(oBrw)
      ELSEIF ky == 83
         myBrwInfoFont(oBrw)
      ELSEIF ky == 84
         myGetAllUse()                             // ������ �������� �� ->  util_InfoDbf.prg
      ELSEIF ky == 85
         DBSELECTAREA(oBrw:cAlias)
         Base_Tek()                                // ������� ���� ->  util_InfoDbf.prg
      ELSEIF ky == 86
         MG_Info( Base_Relation( ALIAS() ) )       // Set relation ���� ���� ->  util_InfoDbf.prg
      ELSEIF ky == 87
         MG_Info( "DbFilter() ���� ����: " + ;
                   (oBrw:cAlias)->( DbFilter() ))  // DbFilter ���� ���� ->  util_InfoDbf.prg
      ELSEIF ky == 88
#ifdef _HMG_OUTLOG
         MG_Debug( "������ ������ � Cargo:"  ,;    // ������ �� (Cargo) ->  util_InfoDbf.prg
                   oBrw:Cargo:cBrwFilter     ,;
                   "������ ������� �� ��������:", oBrw:Cargo:aColFilter ,;
                   "������ �������� � ��������:", oBrw:Cargo:aColNumFltr )
#endif
      ENDIF
      Darken2Close(hWnd)
   ENDIF

RETURN NIL

////////////////////////////////////////////////////////////////////////////
// ��������� ����� � ����������� �������
STATIC FUNCTION myBrwHeadClick( nClick, oBrw, nRowPix, nColPix, nAt )
   LOCAL cForm, nRow, nCell, cNam, cName, nCol, nIsHS, nLine, oCol
   LOCAL nY, nX, cMsg1, cMsg2, cMsg3, aMsg, nVirt, cCol, nV
   LOCAL cVirt, aNam, aMenu, cMenu, cCnr, nCnr

   aNam  := {'Left mouse :OneClick', 'Right mouse :OneClick', 'Left mouse :bLDblClick'}
   aMenu := {'Header - ', 'SuperHeader - '}
   cForm := oBrw:cParentWnd
   nRow  := oBrw:GetTxtRow(nRowPix)                 // ����� ������ ������� � �������
   nCol  := Max(oBrw:nAtColActual( nColPix ), 1 )   // ����� �������� ������� ������� � �������
   nCell := oBrw:nCell                              // ����� ������ � �������
   nLine := nAt                                     // ������ ������ � �������
   oCol  := oBrw:aColumns[ nCol ]
   cName := oCol:cName
   nIsHS := iif(nRowPix > oBrw:nHeightSuper, 1, 2)
   cNam  := aNam[ nClick ]
   cMenu := aMenu[ nIsHS ]
   cVirt := ",ORDKEYNO,SELECTOR,"
   cCnr  := ""
   nCnr  := 0

   nY    := GetProperty(cForm, "Row") + GetTitleHeight()
   nX    := GetProperty(cForm, "Col") + GetBorderWidth() - 4
   // ����� ���������� �� ����� �������
   nY    += GetMenuBarHeight() + oBrw:nTop + 2
   nY    += IIF( oBrw:lDrawSuperHd, oBrw:nHeightSuper , 0 )
   nY    += IIF( oBrw:lDrawHeaders, oBrw:nHeightHead  , 0 )
   nY    -= IIF( oBrw:lDrawSpecHd , oBrw:nHeightSpecHd, 0 )
   IF nIsHS == 2  // ���������� �������
      nY -= IIF( oBrw:lDrawHeaders, oBrw:nHeightHead  , 0 )
   ENDIF
   nX    += oCol:oCell:nCol
   nX    += IIF( oBrw:lSelector, oBrw:aColumns[1]:nWidth , 0 )  // ���� ���� ��������
   nX    -= 5

   nVirt := 0
   FOR nV := 1 TO 3
      cCol := oBrw:aColumns[ nV ]:cName
      IF cCol == "SELECTOR" .OR. cCol == "ORDKEYNO"
         nVirt ++
      ENDIF
   NEXT

   cMsg1 := cMenu + cNam + ", y:x " + hb_ntos(nRowPix) + ":" + hb_ntos(nColPix)
   cMsg2 := "Head position y/x: " + hb_ntos(nY) + '/' + hb_ntos(INT(nX))
   // ������ ������� �� ��������� � �������� ����� � ����,
   // �.�. ���� �������/�������� ������� �� ������� ��.������� myBrwDelColumn()
   // ��������� ����� �� ���������� �������
   //IF oBrw:nCell > oBrw:nColumn("ORDKEYNO")
      //cCnr := oBrw:aColumns[ oBrw:nCell ]:cSpcHeading - ��� ������
      cCnr := oBrw:aColumns[ nCol ]:cSpcHeading
      nCnr := Val( cCnr )
   //ENDIF
   cMsg3 := "Column header: " + hb_ntos(nCnr) + "  [" + cName + "]"
   // ������� ��� �������� �������
   //cMsg3 := "Column header: " + hb_ntos(nCol) + " - " + hb_ntos(nVirt)
   //cMsg3 += " = " + hb_ntos(nCol-nVirt) + "  [" + cName + "]"
   aMsg  := { cMsg1, cMsg2, cMsg3 }

   IF cName $ cVirt
      // ������� ��������� ���������
      cMsg3 := "Virtual column: " + hb_ntos(nCol) + " [" + cName + "]"
      aMsg  := { cMsg1, cMsg2, cMsg3 }
      // ���� ����� ����������� ������� - ����� ������� ��������� ����
      myMenuHeadClick(oBrw, nY, nX, aMsg, nIsHS)
   ELSE
      // ���� ����� ������� �������
      myMenuHeadClick(oBrw, nY, nX, aMsg, nIsHS)
   ENDIF

   oBrw:SetFocus()
   DO EVENTS

RETURN Nil

//////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myMenuHeadClick( oBrw, nY, nX, aMsg, nIsHS )
   LOCAL cForm, hFont1, hFont2, hFont3, aTsbMnu, nI, cTsbMnu, nTsbMnu, cVal

   cForm   := oBrw:cParentWnd
   hFont1  := GetFontHandle( "TsbEdit"   )
   hFont2  := GetFontHandle( "TsbSuperH" )
   hFont3  := GetFontHandle( "TsbBold"   )
   aTsbMnu := myListConstantsImages()           // -> menu_list.prg
   nTsbMnu := 70

   SET MENUSTYLE EXTENDED                       // switch menu style to advanced
   SetMenuBitmapHeight( BRW_BMP_CONTEX_MENU )   // set image size
   SetThemes(1)                                 // "White theme" � ContextMenu

   DEFINE CONTEXT MENU OF &cForm
       MENUITEM  aMsg[1] DISABLED  FONT hFont1
       MENUITEM  aMsg[2] DISABLED  FONT hFont1
       IF nIsHS == 2  // SuperHeader
          SEPARATOR
          FOR nI := 1 TO Len(aTsbMnu)
             cTsbMnu := StrZero(nTsbMnu + nI, 4)
             cVal    := aTsbMnu[ nI,1 ] //+ " - ��������� ������ �������� � �����������"
             MENUITEM cVal ACTION _wPost(70, ,This.Name) NAME &(cTsbMnu) FONT hFont1 IMAGE "Dbg32"
          NEXT
       ENDIF
       SEPARATOR
       MENUITEM  aMsg[3] ACTION  {|| MG_Debug(aMsg[3]) } FONT hFont2
       MENUITEM  "Exit"  ACTION  {|| oBrw:SetFocus() } FONT hFont3
   END MENU
   (ThisWindow.Object):Event( 70, {|ow,ky,cnam| myConstImageSuperHead(ow,ky,cnam,aTsbMnu) } )

   _ShowContextMenu(cForm, nY, nX, .f. ) // SHOWING DROP OUT MENU
   InkeyGui(100)

   DEFINE CONTEXT MENU OF &cForm         // delete menu after exiting
   END MENU

   DO EVENTS

   oBrw:SetFocus()
   oBrw:DrawSelect()

RETURN Nil

//////////////////////////////////////////////////////////////////////////////////
// ��������� ����������(����������) �������
STATIC FUNCTION myBrwSpcHdClick( nClick, nRowPix, nColPix, nAt, oBrw )
   LOCAL cForm, nRPos, nAtCol, cNam, cName, cMsg, cCnr, nCnr
   LOCAL oCol, nY, nX, cMsg1, cMsg2, cMsg3, cMsg4, aMsg, nVirt, cCol, nCol
   LOCAL nClickRow := oBrw:GetTxtRow( nRowPix )

   cForm  := oBrw:cParentWnd
   nRPos  := oBrw:nRowPos
   nAtCol := Max( oBrw:nAtCol( nColPix ), 1 )  // ����� �������
   oCol   := oBrw:aColumns[ nAtCol ]
   cName  := oCol:cName
   nY     := GetProperty(cForm, "Row") + GetTitleHeight()
   nX     := GetProperty(cForm, "Col") + GetBorderWidth() - 4
   // ����� ���������� �� ����� �������
   nY     += GetMenuBarHeight() + oBrw:nTop + 2
   nY     += IIF( oBrw:lDrawSuperHd, oBrw:nHeightSuper , 0 )
   nY     += IIF( oBrw:lDrawHeaders, oBrw:nHeightHead  , 0 )
   nY     -= 1   //IIF( oBrw:lDrawSpecHd , oBrw:nHeightSpecHd, 0 )
   nX     += oCol:oCell:nCol
   nX     += IIF( oBrw:lSelector, oBrw:aColumns[1]:nWidth , 0 )  // ���� ���� ��������
   nX     -= 5
   nVirt  := 0
   cCnr   := ""
   nCnr   := 0

   FOR nCol := 1 TO 3
      cCol := oBrw:aColumns[ nCol ]:cName
      IF cCol == "SELECTOR" .OR. cCol == "ORDKEYNO"
         nVirt ++
      ENDIF
   NEXT

   cMsg  := "Special Header - "
   cNam  := {'Left mouse :OneClick', 'Right mouse :OneClick'}[ nClick ]
   cMsg1 := cMsg + cNam + ", y:x " + hb_ntos(nRowPix) + ":" + hb_ntos(nColPix)
   cMsg2 := "Head position y/x: " + hb_ntos(nY) + '/' + hb_ntos(INT(nX))
   // ������ ������� �� ��������� � �������� ����� � ����,
   // �.�. ���� �������/�������� ������� �� ������� ��.������� myBrwDelColumn()
   // ��������� ����� �� ���������� �������
   //cCnr := oBrw:aColumns[ oBrw:nCell ]:cSpcHeading - ��� ������
   cCnr := oBrw:aColumns[ nAtCol ]:cSpcHeading
   nCnr := Val( cCnr )

   cMsg3 := "Column header: " + hb_ntos(nCnr) + "  [" + cName + "]"
   cMsg4 := "nAt=" + hb_ntos(nAt) + ", nAtCol=" + hb_ntos(nAtCol)
   cMsg4 += ", nClickRow=" + hb_ntos(nClickRow)
   aMsg  := { cMsg1, cMsg2, cMsg3, cMsg4 }

   IF     cName == "SELECTOR"
   ELSEIF cName == "ORDKEYNO"
      myMenuSpcHdClick( oBrw, nY, nX, aMsg, nCnr, nAtCol, 1 )
   ELSE
      myMenuSpcHdClick( oBrw, nY, nX, aMsg, nCnr, nAtCol, 99 )
   ENDIF

RETURN NIL

////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myMenuSpcHdClick( oBrw, nY, nX, aMsg, nCol, nAtCol, nMode )
   LOCAL cForm, hFont1, hFont2, hFont3, cMenu1, cMenu2, oCol, nJ, nDel
   LOCAL o, c2Fltr, aFltr, cName, cSpcHd, nMenu, aColFltr, lFilter, c1Fltr
   LOCAL lChange, cMenu0, cMenu3, cMenu4, cMenu5, nCnt, cCol, cFilter, a2Fltr
   LOCAL nRowPos, nCell

   o        := oBrw:Cargo                 // �������� ������ �� �������
   aFltr    := o:aColFilter               // ������� ������� � ��������
   aColFltr := o:aColNumFltr              // ������ ������� ������� � ��������
   cForm    := oBrw:cParentWnd
   hFont1   := GetFontHandle( "TsbEdit"   )
   hFont2   := GetFontHandle( "TsbSuperH" )
   hFont3   := GetFontHandle( "TsbBold"   )
   cMenu0   := '������� ��� ������� �� ��������'
   cMenu1   := '������� ������ �� ������� "' + hb_ntos(nCol) + '"'
   cMenu2   := '��������� ������ �� ������� "' + hb_ntos(nCol) + '"'
   cMenu3   := '����������� �� �����������'
   cMenu4   := '����������� �� ��������'
   cMenu5   := '��� ����������'
   oCol     := oBrw:aColumns[ nAtCol ]
   cName    := oCol:cName
   cSpcHd   := oCol:cSpcHeading
   nMenu    := 0
   lFilter  := .F.
   lChange  := .F.
   cFilter  := ""
   nRowPos  := oBrw:nRowPos
   nCell    := oBrw:nCell

   IF LEN(aColFltr) > 0
      FOR nJ := 1 TO LEN(aColFltr)
         IF aColFltr[nJ] == nAtCol
            lFilter  := .T.
            EXIT
         ENDIF
      NEXT
   ENDIF

   SET MENUSTYLE EXTENDED                       // switch menu style to advanced
   SetMenuBitmapHeight( BRW_BMP_CONTEX_MENU )   // set image size
   SetThemes(0)                                 // "White theme" � ContextMenu

   DEFINE CONTEXT MENU OF &cForm
       MENUITEM aMsg[1] DISABLED FONT hFont2
       SEPARATOR
       IF nMode == 1
          nMenu := 0
          MENUITEM cMenu0 ACTION {|| MG_Debug(cMenu0,cName,nAtCol) } FONT hFont2 IMAGE "bFltrDel28"
       ELSE
          MENUITEM cMenu3 ACTION {|| nMenu := 3, c2Fltr := MG_Debug(cMenu3,cName,nAtCol,"������") } FONT hFont2 IMAGE "bSortA28"
          MENUITEM cMenu4 ACTION {|| nMenu := 4, c2Fltr := MG_Debug(cMenu4,cName,nAtCol,"������") } FONT hFont2 IMAGE "bSortZ28"
          MENUITEM cMenu5 ACTION {|| nMenu := 5, c2Fltr := MG_Debug(cMenu5,cName,nAtCol,"������") } FONT hFont2
          SEPARATOR
          IF lFilter
             MENUITEM cMenu1 ACTION {|| nMenu := 1 } FONT hFont2 IMAGE "bFltrDel28"
          ELSE
             MENUITEM cMenu1 DISABLED FONT hFont2 IMAGE "bFltrDel28"
          ENDIF
          MENUITEM cMenu2  ACTION {|| nMenu := 2, a2Fltr := MenuFltr(oBrw,cMenu2,cName,cSpcHd,nAtCol) } FONT hFont2 IMAGE "bFltrAdd28"
       ENDIF
       SEPARATOR
       MENUITEM aMsg[3] ACTION  {|| MG_Debug(aMsg)  } FONT hFont2
       MENUITEM "Exit"  ACTION  {|| oBrw:SetFocus() } FONT hFont3
   END MENU

   _ShowContextMenu(cForm, nY, nX, .f. ) // SHOWING DROP OUT MENU
   InkeyGui(100)

   DEFINE CONTEXT MENU OF &cForm         // delete menu after exiting
   END MENU

   DO EVENTS

   IF nMenu == 0                  // ������� ��� ������� �� ��������
      lChange  := .T.
      aFltr    := {}
      aColFltr := {}
      nCnt     := 0
      FOR EACH oCol IN oBrw:aColumns
         cCol := oCol:cName
         IF cCol == "SELECTOR" .OR. cCol == "ORDKEYNO"
            // ������� ���������
         ELSE
            IF oCol:lVisible
               oCol:cSpcHeading := hb_ntos( ++nCnt )
               // �������� � ���������� ������� ������� - �������_���� 20x20
               oCol:uBmpSpcHd   := {|nc,ob| nc := ob:Cargo, nc:hArrDown20  }
            ENDIF
         ENDIF
      NEXT
      // ������� ������� ������� �� �������
      cFilter := ""

   ELSEIF nMenu == 1              // ���� - ������ ������
      lChange := .T.
      nDel    := 0
      FOR nJ := 1 TO LEN(aColFltr)
         IF aColFltr[nJ] == nAtCol
            nDel := nJ
            EXIT
         ENDIF
      NEXT
      IF nDel > 0
         // ������� ������� ������� ��� �������
         ADel( aFltr   , nDel, .T. )
         ADel( aColFltr, nDel, .T. )
      ENDIF
      IF AT( "[", cSpcHd ) > 0
         cSpcHd := SUBSTR( cSpcHd, 1, AT("[",cSpcHd) - 2 )
      ENDIF
      oCol:cSpcHeading := cSpcHd
      // �������� � ���������� ������� ������� - �������_���� 20x20
      oCol:uBmpSpcHd := {|nc,ob| nc := ob:Cargo, nc:hArrDown20  }
      // ������� ������� ������� �� �������
      IF LEN(aFltr) == 0
         cFilter := ""
      ELSE
         cFilter := ""
         FOR nJ := 1 TO LEN(aFltr)
            cFilter += aFltr[nJ] + IIF(nJ==LEN(aFltr),""," .AND. ")
         NEXT
      ENDIF

   ELSEIF nMenu == 2  // ���� - ��������� ������
      IF LEN(a2Fltr) > 0  // ��������� ������ �� �������
         lChange := .T.
         nDel    := 0
         FOR nJ := 1 TO LEN(aColFltr)
            IF aColFltr[nJ] == nAtCol
               nDel := nJ
               EXIT
            ENDIF
         NEXT
         c1Fltr := a2Fltr[1]  // ������ �������
         c2Fltr := a2Fltr[2]  // ������ �������, ������
         IF nDel == 0
            // ����� ������� ������� ��� �������
            AADD( aFltr   , c1Fltr )
            AADD( aColFltr, nAtCol )
            cSpcHd += "  [" + hb_ntos(LEN(aFltr)) + "]"
         ELSE
            //  ������ ��� ����
            aFltr[nDel] := c1Fltr
         ENDIF
         oCol:cSpcHeading := cSpcHd
         // �������� � ���������� ������� ������� - ������  20x20
         oCol:uBmpSpcHd := {|nc,ob| nc := ob:Cargo, nc:hFltrAdd20   }
         // �������� ������ �� ������ ��������, ���� ����
         cFilter := ""
         FOR nJ := 1 TO LEN(aFltr)
            cFilter += aFltr[nJ] + IIF(nJ==LEN(aFltr),""," .AND. ")
         NEXT
      ENDIF

   ELSEIF nMenu == 3  // ���� - ����������� �� �����������
   ELSEIF nMenu == 4  // ���� - ����������� �� ��������
   ELSEIF nMenu == 5  // ���� - ��� ����������

   ENDIF

   nRowPos := oBrw:nRowPos
   nCell   := oBrw:nCell
   // ���������� ����� � ���������
   oBrw:DrawHeaders()
   IF lChange
      // ������������ �������� � ���������-������
      o:aColFilter  := aFltr                // ������� ������� � ��������
      o:aColNumFltr := aColFltr             // ������ ������� ������� � ��������
      o:cBrwFilter  := cFilter              // ������ ������� �� ���� ������� �������

      // oBrw:Reset() - ��� �� ����, ��� ���� � oBrw:FilterData()
      IF LEN(cFilter) == 0
         oBrw:FilterData()
      ELSE
         oBrw:FilterData( cFilter )         // ��������� ������� �� ����
      ENDIF
      mySuperHeaderChange( oBrw, cFilter )  // �������� ���������� �������

      // ��� ���������� ������������ ������� (�� ��������� ���� ���)
      DO EVENTS
      nCell := nCell - 1
      oBrw:GoPos( nRowPos, nCell )          // ������������ ������ � ������� �� ������/�������
      oBrw:GoRight()

   ENDIF
   DO EVENTS
   oBrw:SetFocus()

RETURN Nil

//////////////////////////////////////////////////////////////////////////////////
// �������� ���������� �������
STATIC FUNCTION mySuperHeaderChange( oBrw, cFilter )
   LOCAL cText, nH, aFltr

   nH    := oBrw:Cargo:nHSuperHead     // ������ ������ ����������� - �� ���������
   cText := oBrw:Cargo:cSuperHead      // ����� �����������
   aFltr := oBrw:Cargo:aColFilter      // ������� ������� � ��������

   IF LEN(aFltr) > 0
      cText += CRLF + cFilter
   ENDIF

   oBrw:aSuperHead[3,3] := cText   // �������� ����������
   oBrw:DrawHeaders()              // ���������� ����������/�����/���������
   DO EVENTS

RETURN Nil

//////////////////////////////////////////////////////////////////////////////////
// ��������� ������� �������
STATIC FUNCTION myBrwFootClick( nClick, nRowPix, nColPix, nAt, oBrw )
   LOCAL cForm, nRPos, nAtCol, nHrow, nLine, nHcell, cNam, cName, cMsg
   LOCAL oCol, nY, nX, cMsg1, cMsg2, cMsg3, cMsg4, aMsg, nVirt, cCol, nCol
   LOCAL nClickRow := oBrw:GetTxtRow( nRowPix )

   cForm  := oBrw:cParentWnd
   nRPos  := oBrw:nRowPos        // ����� �������
   nAtCol := Max( oBrw:nAtCol( nColPix ), 1 )
   oCol   := oBrw:aColumns[ nAtCol ]
   cName  := oCol:cName
   nHCell := oBrw:nHeightCell    // ������ ����� ������
   nLine  := oBrw:nRowCount()    // ���-�� ����� � �������
   nHrow  := nLine * nHcell      // ������ ����� � �������
   cMsg   := "Footer - "
   nVirt  := 0
   nY     := GetProperty(cForm, "Row") + GetTitleHeight()
   nX     := GetProperty(cForm, "Col") + GetBorderWidth() - 4
   // ����� ���������� �� ����� �������
   nY     += GetMenuBarHeight() + oBrw:nTop + 2
   nY     += IIF( oBrw:lDrawSuperHd, oBrw:nHeightSuper , 0 )
   nY     += IIF( oBrw:lDrawHeaders, oBrw:nHeightHead  , 0 )
   nY     += IIF( oBrw:lDrawSpecHd , oBrw:nHeightSpecHd, 0 )
   nY     += nHrow                                    // ����� ������ ����� �������� �������
   nY     -= 22
   nX     += oCol:oCell:nCol
   nX     += IIF( oBrw:lSelector, oBrw:aColumns[1]:nWidth , 0 )  // ���� ���� ��������
   nX     -= 5

   FOR nCol := 1 TO 3
      cCol := oBrw:aColumns[ nCol ]:cName
      IF cCol == "SELECTOR" .OR. cCol == "ORDKEYNO"
         nVirt ++
      ENDIF
   NEXT

   cNam  := {'Left mouse :OneClick', 'Right mouse :OneClick'}[ nClick ]
   cMsg1 := cMsg + cNam + ", y:x " + hb_ntos(nRowPix) + ":" + hb_ntos(nColPix)
   cMsg2 := "Foot position y/x: " + hb_ntos(nY) + '/' + hb_ntos(INT(nX))
   cMsg3 := "Column: " + hb_ntos(nAtCol) + " - " + hb_ntos(nVirt)
   cMsg3 += " = " + hb_ntos(nAtCol-nVirt) + "  [" + cName + "]"
   cMsg4 := "nAt=" + hb_ntos(nAt) + ", nAtCol=" + hb_ntos(nAtCol)
   cMsg4 += ", nClickRow=" + hb_ntos(nClickRow)
   aMsg  := { cMsg1, cMsg2, cMsg3, cMsg4 }

   myMenuFootClick( oBrw, nY, nX, aMsg )

   IF nAtCol > 2
      // ��������� � ������ ������
      oBrw:aColumns[nAtCol]:cFooting := "[ "+HB_NtoS(nAtCol-nVirt) + " ]"
      oBrw:DrawFooters()
   ENDIF

RETURN NIL

///////////////////////////////////////////////////////////////////////
STATIC FUNCTION myMenuFootClick( oBrw, nY, nX, aMsg )
   LOCAL cForm, hFont1, hFont2, hFont3

   cForm  := oBrw:cParentWnd
   hFont1 := GetFontHandle( "TsbEdit"   )
   hFont2 := GetFontHandle( "TsbSuperH" )
   hFont3 := GetFontHandle( "TsbBold"   )

   SET MENUSTYLE EXTENDED                       // switch menu style to advanced
   SetMenuBitmapHeight( BRW_BMP_CONTEX_MENU )   // set image size
   SetThemes(1)                                 // "White theme" � ContextMenu

   DEFINE CONTEXT MENU OF &cForm
       MENUITEM  aMsg[1] DISABLED FONT hFont1
       MENUITEM  aMsg[2] DISABLED FONT hFont1
       MENUITEM  aMsg[4] DISABLED FONT hFont1
       SEPARATOR
       MENUITEM  aMsg[3] ACTION  {|| MG_Debug(aMsg[3]) } FONT hFont2
       MENUITEM  "Exit"  ACTION  {|| oBrw:SetFocus()   } FONT hFont3
   END MENU

   //nY -= BRW_BMP_CONTEX_MENU * 6        // 6 ����� ����

   _ShowContextMenu(cForm, nY, nX, .f. )  // SHOWING DROP OUT MENU
   InkeyGui(100)

   DEFINE CONTEXT MENU OF &cForm          // delete menu after exiting
   END MENU

   DO EVENTS

   oBrw:SetFocus()

RETURN Nil

///////////////////////////////////////////////////////////////////////////////////
// ������� �������� � ����������� - �������� ���������� ������
STATIC FUNCTION myConstImageSuperHead(ow, ky, cItm, aTsbMnu)
   LOCAL oBrw := (ThisWindow.Object):Cargo:oBrw        // �������� ������ �� �������
   LOCAL nI, nMsk, cForm := ow:Name

   ky   := VAL(cItm)
   nI   := ky - 70
   nMsk := aTsbMnu[nI,2]

   IF ISOBJECT(oBrw)
      // ��������� ����� ������ �������� � ����������� �������
      FOR nI := 1 TO Len( oBrw:aSuperHead )
         IF !Empty( oBrw:aSuperHead[ nI ][8] )      // uBitMap ����� ?
            oBrw:aSuperHead[ nI ][15] := nMsk       // SRCCOPY
         ENDIF
      NEXT
      oBrw:DrawHeaders()     // ���������� ����������/�����/���������
   ENDIF

RETURN NIL

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myBrwInfoFont( oBrw )
   LOCAL cMsg

   cMsg := "Table alias: " + oBrw:cAlias + ";;"
   cMsg += "1-Cell: "+hb_valtoexp(GetFontParam(oBrw:hFont)) + ";"
   cMsg += "   2-Head: "+hb_valtoexp(GetFontParam(oBrw:hFontHead )) + ";"
   cMsg += "   3-Foot: "+hb_valtoexp(GetFontParam(oBrw:hFontFoot )) + ";"
   cMsg += "  4-SpcHd: "+hb_valtoexp(GetFontParam(oBrw:hFontSpcHd)) + ";"
   cMsg += "   5-Edit: "+hb_valtoexp(GetFontParam(oBrw:hFontEdit )) + ";"
   cMsg += "6-SuperHd: "+hb_valtoexp(GetFontParam(oBrw:hFontSupHdGet(1))) + ";"

   MG_Info(cMsg,"���� � ������ �������")

RETURN Nil

/////////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myBrwListColumn( oBrw )
   LOCAL oCol, nCol, cCol, cSize, cMsg := ''

   FOR nCol := 1 TO Len(oBrw:aColumns)
      oCol  := oBrw:aColumns[ nCol ]
      cCol  := oCol:cName
      cSize := HB_NtoS( INT(oBrw:GetColSizes()[nCol]) )
      cMsg  += HB_NtoS(nCol) + ") " + cCol + " = " + cSize
      cMsg  += ' ( "' + oCol:cFieldTyp + '" ' + HB_NtoS(oCol:nFieldLen)
      cMsg  += ',' + HB_NtoS(oCol:nFieldDec) + ' ) ;'
   NEXT

   MG_Info(cMsg + REPL(";",30))

RETURN Nil

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myBrwInfoRecno( oBrw )            // ���� �� ������ ������
   LOCAL nLine, cAls, nCell, cMsg, oCol, cTyp, cCol, xVal
   LOCAL oCell, nY, nX, nW, nH, aVal

   cMsg  := ""
   cAls  := oBrw:cAlias
   nLine := oBrw:nAt
   nCell := oBrw:nCell                     // ����� ������/������� � �������
   oCol  := oBrw:aColumns[ nCell ]
   cTyp  := oCol:cFieldTyp
   cCol  := oCol:cName
   xVal  := oBrw:GetValue(cCol)
   //xVal := oBrw:GetValue(nCell)          // ����� ���
   oCell := oBrw:GetCellInfo(oBrw:nRowPos)
   nY    := oCell:nRow + oBrw:nHeightHead + 4
   nX    := oCell:nCol
   nW    := oCell:nWidth
   nH    := oCell:nHeight
   aVal  := { nY, nX, nW, nH }

   cMsg += "  ����: " + cAls + ";"
   cMsg += "������: " + HB_NtoS( (cAls)->( RECNO() ) ) + ";;"
   cMsg += " ����� ������ � �������: " + HB_NtoS( nLine ) + ";"
   cMsg += "����� ������� � �������: " + HB_NtoS( nCell ) + ";"
   cMsg += "��� ���� ����: " + cCol + "  [" + cTyp + "];;"
   cMsg += "�������� ������: [" + cValToChar(xVal) + "];;"
   cMsg += "���������� ������: " + HB_ValToExp( aVal )

   MG_Info( cMsg + REPL(";",20), "���� �� ������ ������" )

RETURN Nil

