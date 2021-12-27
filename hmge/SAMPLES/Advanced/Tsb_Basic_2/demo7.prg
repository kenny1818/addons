/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2019 Verchenko Andrey <verchenkoag@gmail.com>
 * Copyright 2019 Sergej Kiselev <bilance@bilance.lv>
 *
 * ������� �� ��������� ������� � �������� ����� �� + ���������� �������
 * ��������������������� ������ � ����� 
 * Table on conditional index and database field card + record blocking
 * Multiuser work with the database
*/
#include "hmg.ch"
#include "TSBrowse.ch"
#include "Dbinfo.ch"

REQUEST DBFCDX

STATIC nStaticTime, aStaticTableColor, cStaticUser, lStaticEditCard

DECLARE WINDOW Form_0
/////////////////////////////////////////////////////////////////////
PROCEDURE Main
   LOCAL oBr, aAlias, aHWin, cUser, nOrder
   LOCAL nY, nX, nW, nH, nG, nBtnW, nBtnH
   LOCAL cForm  := 'Form_0'
   LOCAL cTitle := "(7) TsBrowse + Conditional index + RLock"                   

   RddSetDefault( 'DBFCDX' )

   SET DATE FORMAT 'DD.MM.YYYY'
   SET DELETED ON
   SET AUTOPEN OFF
   SET OOP ON

   SET DIALOGBOX CENTER OF PARENT
   DEFINE FONT DlgFont FONTNAME "Verdana" SIZE 12  // for HMG_Alert()
   SET CENTERWINDOW RELATIVE PARENT                // for HMG_Alert()

   aHWin  := OnlyOneInstance(cTitle)  // ������� �������� ��������
   aAlias := UseOpenBase()            // �������/������� �������� ���� 
   Index2Create(aHWin)                // ������� �������� ������ ��� ������ ���������
   nOrder      := INDEXORD()             
   nStaticTime := SECONDS()           // �������� ����� ��� ������ �������
   cUser       := "  " + HB_NtoS( LEN(aHWin) + 1 ) + "-User"  
   cStaticUser := ALLTRIM(cUser)

   DEFINE WINDOW  &cForm AT 20,10 WIDTH 590 HEIGHT 600               ;
      TITLE       cTitle + cUser                                     ;
      ICON        "MG_ICO"                                           ;
      MAIN        NOMAXIMIZE NOSIZE                                  ;
      ON INIT     ( ChangeWinBrw(oBr,aHWin), This.Topmost := .F. )   ;
      ON RELEASE  AEval( aAlias, {|ca| (ca)->( dbCloseArea(ca) ) } )    // ������� ��� ���� ��� ������

      DEFINE STATUSBAR
         STATUSITEM "" WIDTH 10
         STATUSITEM cTitle + " - network opening of the database !"  WIDTH 390 FONTCOLOR RED
         STATUSITEM "00:00:00" 
         STATUSITEM "Order: " + HB_NtoS(nOrder) 
         STATUSITEM cUser  
      END STATUSBAR
      
      nY := nX := nG := 5 
   
      nBtnH := 30  ; nBtnW := ( This.ClientWidth - nG * 7 ) / 6 

      @ nY, nX BUTTONEX Button_10 WIDTH nBtnW HEIGHT nBtnH ;
        CAPTION "10 Recno" SIZE 10 BOLD BACKCOLOR SILVER   ;
        FLAT NOXPSTYLE HANDCURSOR NOTABSTOP                ;
        ACTION RecnoCreateCondition(oBr,10)
        nX += nBtnW + nG

      @ nY, nX BUTTONEX Button_20 WIDTH nBtnW HEIGHT nBtnH ;
        CAPTION "20 Recno" SIZE 10 BOLD BACKCOLOR SILVER   ;
        FLAT NOXPSTYLE HANDCURSOR NOTABSTOP                ;
        ACTION RecnoCreateCondition(oBr,20)
        nX += nBtnW + nG

      @ nY, nX BUTTONEX Button_Refresh WIDTH nBtnW HEIGHT nBtnH ;
        CAPTION "Refresh" SIZE 10 BOLD BACKCOLOR SILVER         ;
        FLAT NOXPSTYLE HANDCURSOR NOTABSTOP                     ;
        ACTION RecnoRefresh(oBr, .t.)     // � ����������� �������
        nX += nBtnW + nG

      @ nY, nX BUTTONEX Button_BaseInfo WIDTH nBtnW HEIGHT nBtnH ;
        CAPTION "(i) Base" SIZE 10 BOLD BACKCOLOR SILVER         ;
        FLAT NOXPSTYLE HANDCURSOR NOTABSTOP                      ;
        ACTION {|| InfoDbase() , oBr:SetFocus() }
        nX += nBtnW + nG

      @ nY, nX BUTTONEX Button_Help WIDTH nBtnW HEIGHT nBtnH  ;
        CAPTION "(i) Help" SIZE 10 BOLD BACKCOLOR SILVER      ;
        FLAT NOXPSTYLE HANDCURSOR NOTABSTOP                   ;
        ACTION {|| MsgAbout() , oBr:SetFocus() }
        nX += nBtnW + nG

      @ nY, nX BUTTONEX Button_Exit WIDTH nBtnW HEIGHT nBtnH ;
        CAPTION "Exit" SIZE 10 BOLD BACKCOLOR SILVER         ;
        FLAT NOXPSTYLE HANDCURSOR NOTABSTOP                  ;
        ACTION ThisWindow.Release()

      nY  := This.Button_10.Row + This.Button_10.Height + 5
      nX  := This.Button_10.Col
      nW  := This.ClientWidth  - nX * 2
      nH  := This.ClientHeight - This.StatusBar.Height - nY - 5

      oBr := CreateBrowse(nY, nX, nW, nH)      // ������� �������

      // �������� ������ 1 ��� � ��������� ����� �������
      DEFINE TIMER Timer_1 INTERVAL 30 * 1000 ACTION RecnoRefresh(oBr, .t.)
      // �������� ������ 2 ��� ����������� ������� Timer_1 ������ �������
      DEFINE TIMER Timer_2 INTERVAL 1000 ACTION Timer1Show()

   END WINDOW

   CENTER   WINDOW &cForm
   ACTIVATE WINDOW &cForm ON INIT ( This.Topmost := .T., oBr:SetFocus() )

RETURN

/////////////////////////////////////////////////////////////////////
FUNCTION CreateBrowse( nY, nX, nW, nH )
   LOCAL oBrw, cAls := ALIAS()
   
   DEFINE TBROWSE oBrw OBJ oBrw AT nY, nX WIDTH nW HEIGHT nH ALIAS cAls GRID ;
          COLORS    { CLR_BLACK, CLR_BLUE }     ;
          FONT      "Tahona"                    ; //"MS Sans Serif"
          SIZE      12                          ;
          COLUMNS   { "F2", "F1", "F3", "CODE" }

   :SetAppendMode( .F. )      // ������� ������ ��������� (� ����� ���� �������� ����)
   :SetDeleteMode( .T., .T. ) // �������� ������ ���������

   :lNoHScroll  := .T.        // ����� ��������������� ���������
   :lCellBrw    := .F.
   :lInsertMode := .T.        // ���� ��� ������������ ������ ������� ��� ��������������
   :lPickerMode := .F.        // ���� ������� ������� ���� ���� ������� ����� �����

    ADD COLUMN TO TBROWSE oBrw DATA {|| (oBrw:cAlias)->( OrdKeyNo() ) } ;  
        HEADER CRLF + "NN" SIZE 60 ;
        COLORS {CLR_BLACK, WHITE} ALIGN DT_CENTER ;
        NAME NN                             

   :LoadFields(.F.)

   // Set columns width
   :SetColSize( oBrw:nColumn( "F1"   ), 100  )
   :SetColSize( oBrw:nColumn( "F2"   ), 200  )
   :SetColSize( oBrw:nColumn( "F3"   ),  80  )
   :SetColSize( oBrw:nColumn( "CODE" ),  90  )

   // Set names for the table header
   :aColumns[1]:cHeading := "NN"      
   :aColumns[2]:cHeading := "Text"      
   :aColumns[3]:cHeading := "Date"      
   :aColumns[4]:cHeading := "Number"      
   :aColumns[5]:cHeading := "CodeList" 

   :GetColumn('F1'):cPicture := Nil       // ������ ���� ���������� ��� ������
   :GetColumn('F1'  ):nAlign := DT_CENTER
   :GetColumn('CODE'):nAlign := DT_CENTER

   :lPickerMode  := .F.                 // ���� ������� ������� ���� ���� ������� ����� �����
   :lNoKeyChar   := .T.                 // ��������� ��� �������: edit �� ������� ������ ����\���� 
   :lNoGrayBar   := .F.                 // ���������� ���������� ������
   :nWheelLines  := 1                   // ��������� ������� ����
   :nClrLine     := COLOR_GRID          // ���� ����� ����� �������� �������
   :lNoChangeOrd := TRUE                // ������ ���������� �� ����
   :nColOrder    := 0                   // ������ ������ ���������� �� ����
   :lCellBrw     := TRUE                // celled browse flag
   :lNoVScroll   := TRUE                // ��������� ����� ��������������� ��������� �������
   :hBrush       := CreateSolidBrush( 242, 245, 204 )   // ���� ���� ��� ��������

   // prepare for showing of Double cursor
   AEval( :aColumns, {| oCol | oCol:lFixLite := oCol:lEdit := TRUE, ;
                               oCol:lOnGotFocusSelect := .T.,       ;
                               oCol:lEmptyValToChar   := .T. } )
          // oCol:lOnGotFocusSelect := .T. - ������� ��������� ������ ��� ��������� ������ 
          //   GetBox-�� � ����������, ������� ���� ��� ������� ������� ������� 
          // oCol:lEmptyValToChar := .T. - ��� .T. ��������� empty(...) �������� ���� � ""

   :nHeightCell += 10        // � ������ ����� ������� �������
   :nHeightHead += 5         // � ������ ����� ������� �������

   // GetBox ���������� � ������, ������ �������
   :aEditCellAdjust[1] += 4  // cell_Y + :aEditCellAdjust[1]
   :aEditCellAdjust[2] += 2  // cell_X + :aEditCellAdjust[2]
   :aEditCellAdjust[3] -= 5  // cell_W + :aEditCellAdjust[3]
   :aEditCellAdjust[4] -= 8  // cell_H + :aEditCellAdjust[4]

   :SetColor( { 1 }, { RGB( 0, 12, 120 )    } )
   :SetColor( { 2 }, { RGB( 242, 245, 204 ) } )
   :SetColor( { 3 }, { CLR_RED              } )
   :SetColor( { 4 }, { RGB( 231,178, 30 )   } )
   :SetColor( { 5 }, { RGB( 0, 0, 0 )       } )

   :SetColor( { 6 }, { { | a, b, oBr | a:=nil, IF( oBr:nCell == b, { RGB( 66, 255, 236 ), RGB( 111, 183, 155 ) }, ;
                          { CLR_HRED, CLR_HCYAN } ) } } )  // cursor backcolor

   :SetColor( { 9  }, { CLR_RED              } )
   :SetColor( { 10 }, { RGB( 231,178, 30 )   } )
   :SetColor( { 11 }, { CLR_YELLOW           } ) 
   :SetColor( { 12 }, { CLR_BLACK            } ) 

   :lFooting     := .T.  // ������������ ������ �������
   :lDrawFooters := .T.  // �������� ������ �������
   :nHeightFoot  := 6    // ������ ������ ������� �������

   :nFreeze      := 1     // ���������� �������
   :lLockFreeze  := .T.   // �������� ���������� ������� �� ������������ ��������

   // ������� ���� ����� �� �������  
   :bLDblClick  := {|up1,up2,nfl,obr| up1:=up2:=nfl:=Nil, ;
                                 obr:PostMsg( WM_KEYDOWN, VK_RETURN, 0 ) }
   // ------------------------------------------------------
   // 1) ��������� ������ � �������. ������� �������� 
   // :UserKeys( nKey, bKey, lCtrl, lShift ) 
   // � ���� ���� ��� ���������� ������: 
   // .T. - ���������� ��������� ������� � ���
   // .F. - � ����� ��� ���������� � ���������� ��������� ������� � ��� �� ���� 
   // ------- ������ ---------------------------------------
   // :UserKeys( VK_RETURN, {|ob| Table_Enter_Card(ob), .F. } )
   // :UserKeys( VK_F5, {|ob| Table_Print(ob), .F. } )

   // ���� ���������� ����-���� ����� .T. �� ����� �������� ������
   // 2) :bUserKeys := {|nKy,nFl,oBr| MyKeyUserEdit(nKy, nFl, oBr) }
   // �.�. ������� � ������� ����� ���������� ��� ����
   // ------------------------------------------------------

   // ��������� ���� ��������� ������� ������
   :bUserKeys   := {|nKy,nFl,oBr| MyKeyUserEdit(nKy, nFl, oBr) } 

   :ResetVScroll( .T. )       // ���������� ������������ �������� �������
   :oHScroll:SetRange(0,0)
   :AdjColumns()              // ��������� ������� �� ���������� ������� � ������ ������

   END TBROWSE  ON END ( oBrw:SetNoHoles(), ;  // ������ ����� ����� �������
                         oBrw:GoPos( 5,3 ) )   // ������ �� 5 ������ � 3 �������

RETURN oBrw

//////////////////////////////////////////////////////////////////////////////////
// ������� ��������� ������� ������ � ������� 
// ������� ������ ����������: .T. ��� .F.
// .T. - ���������� ��������� ������� � ���
// .F. - � ����� ��� ���������� � ���������� ��������� ������� � ��� �� ���� 
STATIC FUNCTION MyKeyUserEdit( nKey, nFlg, oBrw )
   LOCAL lRet, cForm := oBrw:cParentWnd
   Default nFlg := Nil, oBrw := Nil

   DO CASE
      CASE nKey == VK_DOWN .OR. nKey == VK_UP       // 38 + 40 
         lRet := .T.
      CASE nKey == VK_PRIOR .OR. nKey == VK_NEXT    // PgUp + PgDn / 33 + 34  
         lRet := .T.
      CASE nKey == VK_SPACE
      CASE nKey == VK_F5
         //Table_Print(oBrw)
      CASE nKey == VK_RETURN  
         Table_Enter_Card(oBrw)
         lRet := .F. 
      CASE nKey == 16 .OR. nKey == 17  // Shift+Alt  Shift+Ctrl  "RUS/LAT"
         lRet := .F. 
      OTHERWISE
         //? ProcName(0), " nKey == ",nKey
         lRet := .T. 
   ENDCASE
   
RETURN lRet

/////////////////////////////////////////////////////////////////////
FUNCTION Table_Enter_Card(oBrw)
   LOCAL cAls := oBrw:cAlias
   LOCAL nRecno, aDim

   // ����� ����� ������� �������� ����� �������� �� ���-�����
   aDim := CardGetStruct()       // ���� ���� �������� � �������

   nRecno := (cAls)->(RecNo())   // ����� ������ ������� �����������
                                 // �����, �.�. ���� ������-���������� �������

   IF (cAls)->(DBRLock(nRecno))  
      (cAls)->DT_RLOCK := cStaticUser    // �������� ��� ���������� ������
      (cAls)->(DbCommit())  
      Show_Card(oBrw, aDim, .T. , nRecno)  // ����� �������� � ������ ��������������  
   ELSE
      Show_Card(oBrw, aDim, .F. , nRecno)  // ����� �������� � ������ ������   
   ENDIF

   oBrw:SetFocus() 
   DO EVENTS 

   RETURN NIL

/////////////////////////////////////////////////////////////////////
STATIC FUNCTION CardGetStruct()
   LOCAL aDim, aFld, aType, aSpr

   // ������� ����� ���� ����, ������ ��� � ������� 4 �������, 
   // � � �������� ����� ���� ����� ����� �� (������ �� �������)
   // ����� ������� �������� �������� ����� ���-�����
   aDim := {}              ; aFld := {}              ; aType := {}          ; aSpr := {}
   AADD( aDim, "Date"    ) ; AADD( aFld, "F1"      ) ; AADD( aType, "D"   ) ; AADD( aSpr, {}             )
   AADD( aDim, "Text"    ) ; AADD( aFld, "F2"      ) ; AADD( aType, "C"   ) ; AADD( aSpr, {}             )
   AADD( aDim, "Number"  ) ; AADD( aFld, "F3"      ) ; AADD( aType, "N"   ) ; AADD( aSpr, {}             )
   AADD( aDim, "CodeList") ; AADD( aFld, "CODE"    ) ; AADD( aType, "S"   ) ; AADD( aSpr, SpravCode()    )
   AADD( aDim, "Handbook") ; AADD( aFld, "F4"      ) ; AADD( aType, "S"   ) ; AADD( aSpr, SpravCode2()   )
   AADD( aDim, "Recno"   ) ; AADD( aFld, ""        ) ; AADD( aType, "FUN" ) ; AADD( aSpr, 'MyRetRecno()' )
   AADD( aDim, "User"    ) ; AADD( aFld, "DT_RLOCK") ; AADD( aType, "CR"  ) ; AADD( aSpr, {}             )
   // aType - ��� ��������� ����, S-����������, FUN-�������, CR-����� ���� ��� ��������������

RETURN {aDim,aFld,aType,aSpr}

/////////////////////////////////////////////////////////////////////
// ������ ������� �������
FUNCTION MyRetRecno()
   RETURN (ALIAS())->(RECNO()) 

/////////////////////////////////////////////////////////////////////
// ������ �������� �����������. ����� ������ �������� �� dbf-�����
FUNCTION SpravCode()
   LOCAL nI, aDim := {}

   FOR nI := 1 TO 5
      AADD( aDim, { nI, PadR( " ( Code = " + HB_NtoS(nI) + " )", 20 ) } )
   NEXT

   RETURN aDim

/////////////////////////////////////////////////////////////////////
// ������ �������� �����������. ����� ������ �������� �� dbf-�����
FUNCTION SpravCode2()
   LOCAL aDim := {}

   AADD( aDim, { 1, PadR( " one"   , 10 ) } )
   AADD( aDim, { 2, PadR( " two"   , 10 ) } )
   AADD( aDim, { 3, PadR( " three" , 10 ) } )
   AADD( aDim, { 4, PadR( " four"  , 10 ) } )
   AADD( aDim, { 5, PadR( " five"  , 10 ) } )
   AADD( aDim, { 6, PadR( " six"   , 10 ) } )

   RETURN aDim

/////////////////////////////////////////////////////////////////////
// �������� �������� �� �����������
FUNCTION SpravGetCode( nVal, aDim )
   LOCAL nI, lRet := .F., cRet := " no handbook array"

   IF nVal == NIL
      nVal := -0.1
   ENDIF

   IF LEN(aDim) > 0
      FOR nI := 1 TO LEN(aDim)
         IF nVal > 0 .AND. nVal < LEN(aDim) + 1
            IF nVal == aDim[nI,1]
               cRet := aDim[nI,2]
               lRet := .T.
               EXIT
            ENDIF
         ENDIF
      NEXT
      IF ! lRet
         cRet := " no data (" + HB_NtoS(nVal)+ ")"
      ENDIF
   ENDIF

   RETURN cRet

/////////////////////////////////////////////////////////////////////
FUNCTION Show_Card(oBrw,aDim,lEditCard,nRecnoEdit)  
   LOCAL cForm := oBrw:cParentWnd , cAls := oBrw:cAlias
   LOCAL aCargo, actpos := {0,0,0,0}
   LOCAL nCol, nRow, nWidth, nHeight, cMsgIndx
   LOCAL cMsg, aBackColor := { 242, 245, 204 }
   LOCAL cFont := "Tahona", nFontSize := 12
   LOCAL nI, nX, nY, nWLbl, nHF, nWGbx, cN, cN2
   LOCAL aCardName, aCardFld, aCardType, aCardFSpr, cRun
   LOCAL nG, nK, cVal, xVal, aObjGBox, nColButt, cNButt
   
   aBackColor := aStaticTableColor   // ����� ����� ����  

   GetWindowRect( GetFormHandle( cForm ), actpos )  // ���������� ��������� ����
   nCol    := actpos[1]              // Form_0.Col
   nRow    := actpos[2]              // Form_0.Row   
   nWidth  := actpos[3] - actpos[1]  // Form_0.Width 
   nHeight := actpos[4] - actpos[2]  // Form_0.Height

   SELECT(cAls)
   cMsgIndx := "Index condition: [ " + OrdFor() + " ]"

   aCardName := aDim[1]   // ������������ �����
   aCardFld  := aDim[2]   // ���� ����
   aCardType := aDim[3]   // ��� ��������� ����
   aCardFSpr := aDim[4]   // ���� �������/����������� 2�-������

   lStaticEditCard := .F.    // �� ���� �������������� ����� ��������

   nK := 0  // 100 - ��� �����, �������� �������� ������ 
   DEFINE WINDOW Form_Card               ;
      At nRow, nCol + 70 + nK            ;
      WIDTH nWidth - 70 HEIGHT nHeight   ;
      TITLE "Card test box"              ;
      MODAL                              ;
      BACKCOLOR aBackColor               ;
      NOSIZE                             ;
      FONT cFont SIZE nFontSize          ;
      ON INIT {|| This.Topmost := .F. , CardRecnoInfo(oBrw), DoEvents(), MyFocus() }  

      nWidth  := This.ClientWidth 
      nHeight := This.ClientHeight
      cForm   := ThisWindow.Name

      SetProperty(cForm, 'Cargo', aDim)    // ������� �� ������ ��� ���� ��������
      
      @ 0, 0 LABEL buff WIDTH nWidth HEIGHT 40 VALUE cMsgIndx ;
        BACKCOLOR SILVER CENTERALIGN VCENTERALIGN 

      @ 60, 20 LABEL Lbl_Rec WIDTH nWidth-170 HEIGHT nFontSize*2*3 VALUE "" ;
        FONTCOLOR BLACK  TRANSPARENT

      @ 40 + 20, nWidth-130-20 BUTTONEX Button_Help WIDTH 130 HEIGHT 50 ;
         CAPTION "(?) Help" BOLD FLAT NOXPSTYLE HANDCURSOR NOTABSTOP    ;
         FONTCOLOR WHITE BACKCOLOR { 0,176,240 }                        ;
         ACTION {|| MsgAbout(), Form_Card.buff.Setfocus }

      nG    := 5   // ���������� ����� �������� ��������
      nY    := Form_Card.Lbl_Rec.Row + Form_Card.Lbl_Rec.Height + 10
      nX    := 30
      nWLbl := 90
      nHF   := nFontSize*2
      nWGbx := 60

      aObjGBox := {}  // ������ ���������� �������� ��������
      FOR nI := 1 TO Len(aCardName)

         cN := 'Lbl_Card_' + StrZero(nI, 2)
         @ nY, nX LABEL &cN WIDTH nWLbl HEIGHT nHF VALUE aCardName[nI] + ":" ;
           FONTCOLOR BLUE TRANSPARENT RIGHTALIGN

         cN2   := 'GetBox_Card_' + StrZero(nI, 2)
         AADD( aObjGBox, cN2 )  // ������ ���������� �������� ��������

         IF aCardType[nI]  == "S" // ��� ���� ����������

            aDim  := aCardFSpr[nI] 
            cVal  := aDim[1][2] 
            nWGbx := GetTxtWidth( REPL("A", LEN(cVal)), nFontSize, cFont ) + 20
            nWGbx := IIF( nWGbx > nWidth - (nX+nWLbl+10)-nX, nWidth - (nX+nWLbl+10)-nX, nWGbx )
            xVal  := FIELDGET( FIELDNUM( aCardFld[nI] ) ) // �������� ���� � ��
            cVal  := SpravGetCode( xVal, aCardFSpr[nI] )   // �������� �� �����������

            @ nY-2, nX+nWLbl+10 GETBOX &cN2 WIDTH nWGbx HEIGHT nHF ;
               VALUE cVal READONLY //ON CHANGE {|| "�� ����� ����" } 

            aCargo := { aCardType[nI], aCardFld[nI], xVal, cVal }
            //SetProperty(cForm, cN2, 'Cargo', aCargo )   // ������� �� ������
            This.&(cN2).Cargo := aCargo

            nColButt := nX+nWLbl+10 + nWGbx + 10
            cNButt   := "Button_" + cN2 
            @ nY-2, nColButt BUTTONEX &cNButt WIDTH nHF HEIGHT nHF   ;
               CAPTION "?" FLAT NOXPSTYLE HANDCURSOR NOTABSTOP       ;
               BOLD FONTCOLOR BLACK BACKCOLOR SILVER                 ;
               ACTION {|| lStaticEditCard := .T.  /* ���� ��������� */      ,;  
                          SetProperty(cForm, 'Button_Down', 'Enabled', .F.) ,; 
                          SetProperty(cForm, 'Button_Up'  , 'Enabled', .F.) ,; 
                          EditTypeSprav( This.Cargo ) ,  MyFocus() }      
            // ����� ������ � ������� - ��� ��� ������ �� aDim[]
            //SetProperty(cForm, cNButt, 'Cargo', { nI, cN2, cNButt } ) 
            This.&(cNButt).Cargo := { nI, cN2, cNButt }

            IF !lEditCard  // ���� ������ ����������� (��� ��������������)
               SetProperty(cForm, cNButt, 'Enabled', .F.)  // ����������� ��������������
            ENDIF

         ELSEIF aCardType[nI]  == "FUN" // ��� ���� �������
            cRun  := aCardFSpr[nI]
            xVal  := &cRun
            cVal  := cValToChar(xVal)
            nWGbx := GetTxtWidth( REPL("A", LEN(cVal)), nFontSize, cFont ) + 20
            nWGbx := IIF( nWGbx > nWidth - (nX+nWLbl+10)-nX, nWidth - (nX+nWLbl+10)-nX, nWGbx )

            @ nY, nX+nWLbl+10 LABEL &cN2 WIDTH nWGbx HEIGHT nHF VALUE xVal BOLD TRANSPARENT 

            aCargo := { aCardType[nI], aCardFld[nI], 0, "������" }
            //SetProperty(cForm, cN2, 'Cargo', aCargo )   // ������� �� ������
            This.&(cN2).Cargo := aCargo

         ELSE   
            // ��� ��������� ���� N C D
            xVal  := FIELDGET( FIELDNUM( aCardFld[nI] ) )
            cVal  := cValToChar(xVal)
            nWGbx := GetTxtWidth( REPL("A", LEN(cVal)), nFontSize, cFont ) + 20
            nWGbx := IIF( nWGbx > nWidth - (nX+nWLbl+10)-nX, nWidth - (nX+nWLbl+10)-nX, nWGbx )

            IF aCardType[nI]  == "CR" // ��� ���� C � ������ ����� 
               @ nY, nX+nWLbl+10 LABEL &cN2 WIDTH nWGbx HEIGHT nHF VALUE xVal BOLD TRANSPARENT 
            ELSE
               @ nY-2, nX+nWLbl+10 GETBOX &cN2 WIDTH nWGbx HEIGHT nHF ;
                  VALUE xVal ON CHANGE {|| lStaticEditCard := .T.  /* ���� ��������� */      ,;
                                           SetProperty(cForm, 'Button_Down', 'Enabled', .F.) ,; 
                                           SetProperty(cForm, 'Button_Up'  , 'Enabled', .F.)  } 
            ENDIF

            aCargo := { aCardType[nI], aCardFld[nI], 0, "������" }
            //SetProperty(cForm, cN2, 'Cargo', aCargo )   // ������� �� ������
            This.&(cN2).Cargo := aCargo

            IF !lEditCard  // ���� ������ ����������� (��� ��������������)
               SetProperty(cForm, cN2, 'Readonly', .T.)  // ����������� ��������������
            ENDIF

         ENDIF

         nY += nHF + nG
      NEXT

      cMsg := "������ �������� � ���� CODE = 2, ����� �������� ������ [Save record]"+CRLF
      cMsg += '� �������� ������� ��� ������ ������ "���������" � �� ������� ��������� ���� !'+CRLF
      cMsg += "Enter the value in the database CODE = 2, then press the button [Save record]" + CRLF
      cMsg += 'In the conditional index, this entry should "disappear" and also be removed from the table !'

      @ nY, nX LABEL Lbl_Info WIDTH nWidth-nX*2 HEIGHT 100 VALUE cMsg ;
        SIZE 10 FONTCOLOR RED TRANSPARENT 

      @ nHeight-50-60, 10 IMAGE Image_1 PICTURE "MINIGUI_EDIT_CANCEL" WIDTH 32 HEIGHT 32 ;
         STRETCH TRANSPARENT BACKGROUNDCOLOR aBackColor INVISIBLE                   

      // ������ ������������� ������������� ... Record blocked by user
      @ nHeight-50-60, 50 LABEL Lbl_RLock WIDTH nWidth-50 HEIGHT 40 VALUE ""  ;
        SIZE 11 FONTCOLOR RED TRANSPARENT INVISIBLE 

      @ nHeight-50-20, 20 BUTTONEX Button_Down WIDTH 100 HEIGHT 50            ;
         CAPTION "Down to"+CRLF+"record" FLAT NOXPSTYLE HANDCURSOR NOTABSTOP  ;
         FONTCOLOR WHITE BACKCOLOR GRAY                                       ;
         ACTION {|| nRecnoEdit := CardDownUp(oBrw, 1, aObjGBox)  ,;
                    MyFocus() }

      @ nHeight-50-20, 20+100+20 BUTTONEX Button_Up WIDTH 100 HEIGHT 50      ;
         CAPTION "Up to"+CRLF+"record"  FLAT NOXPSTYLE HANDCURSOR NOTABSTOP  ;
         FONTCOLOR WHITE BACKCOLOR GRAY                                      ;
         ACTION {|| nRecnoEdit := CardDownUp(oBrw, 2, aObjGBox)  ,;
                    MyFocus() }

      @ nHeight-50-20, 20+200+40+10 BUTTONEX Button_Save WIDTH 100 HEIGHT 50   ;
         CAPTION "Save"+CRLF+"record" FLAT NOXPSTYLE HANDCURSOR NOTABSTOP      ;
         FONTCOLOR WHITE BACKCOLOR LGREEN                                      ;
         ACTION {|lWrite| lWrite := CardSave(oBrw, nRecnoEdit, aObjGBox) ,;
                    nRecnoEdit := CardDownUp(oBrw, 0, aObjGBox) ,;
                    MyFocus() }

      @ nHeight-50-20, nWidth-100-20 BUTTONEX Button_Exit WIDTH 100 HEIGHT 50 ;
         CAPTION "Exit" BOLD FLAT NOXPSTYLE HANDCURSOR NOTABSTOP              ;
         FONTCOLOR WHITE BACKCOLOR MAROON                                     ;
         ACTION {|| CardModify(oBrw, nRecnoEdit, aObjGBox) ,;
                    (cAls)->(DbGoto(nRecnoEdit))           ,;
                    FieldUserRlock(.F., nRecnoEdit)        ,;  // �������� ��� ���������� ������
                    RecnoRefresh(oBrw, .t.)                ,;  // �������� ����� �������
                    ThisWindow.Release }

      // RecnoRefresh(oBrw, .t.)  // ���������� ������� ������, �.�. ������ ���������
                                  // ����� �������/�������� ������ ��� ���� �������

      IF !lEditCard // ���� ������ ����������� (��� ��������������)
         CardRecnoGetSay(.F., aObjGBox)  // �������� �������� �������� �� �����
         SayUserRlock()
      ENDIF

      ON KEY ESCAPE OF Form_Card ACTION ThisWindow.Release

      ON KEY F3     OF Form_Card ACTION MsgDebug( GetProperty(cForm, 'Cargo') )

   END WINDOW

   //CENTER WINDOW Form_Card
   ACTIVATE WINDOW Form_Card ON INIT {|| This.Topmost := .T. }  

RETURN NIL 

/////////////////////////////////////////////////////////////////////
STATIC FUNCTION MyFocus()
    Form_Card.buff.Setfocus
RETURN NIL

/////////////////////////////////////////////////////////////////////
STATIC FUNCTION SayUserRlock()
   LOCAL cMsg, cAls := ALIAS()
   cMsg := "������ ������������� �������������: " + (cAls)->DT_RLOCK 
   cMsg += CRLF + "����� ������ ��������. Record locked !" 
   Form_Card.Lbl_RLock.Value := cMsg
RETURN NIL

/////////////////////////////////////////////////////////////////////
STATIC FUNCTION FieldUserRlock(lWrite,nRecno)
   LOCAL cAls := ALIAS()

   IF (cAls)->(DBRLock(nRecno))  
      IF lWrite
         (cAls)->DT_RLOCK := cStaticUser   // �������� ��� ���������� ������
      ELSE
         (cAls)->DT_RLOCK := ""            // �������� ��� ���������� ������
      ENDIF
      (cAls)->(DBUnlock())
   ENDIF
   (cAls)->(DbCommit())  

RETURN NIL

/////////////////////////////////////////////////////////////////////
STATIC FUNCTION CardRecnoInfo(oBrw)
   LOCAL cMsg, cAls := oBrw:cAlias

   // ������ �� ������� ����� ������ 
   cMsg := HB_NtoS( (cAls)->(OrdKeyNo()) ) + " / " + HB_NToS( (cAls)->(OrdKeyCount()) ) + CRLF
   cMsg += "Recno() = " + HB_NtoS( (cAls)->(RecNo()) ) + CRLF
   cMsg += "oBrw:nRowPos = " + HB_NtoS( oBrw:nRowPos ) + CRLF
   cMsg += "oBrw:nAt = " + HB_NtoS( oBrw:nAt ) + CRLF

   Form_Card.Lbl_Rec.Value := cMsg

RETURN NIL

/////////////////////////////////////////////////////////////////////
// ������� ����� ������ � �������� �������
// �������� �������� �������� �� �����
STATIC FUNCTION CardRecnoGetSay(lVal, aObjGBox)
   LOCAL xVal, cVal, nI, cObj, aCargo, cNButt, cForm := ThisWindow.Name
   LOCAL aDimCard, aCardName, aCardType, aCardFld, aCardFSpr, cRun

   Form_Card.Lbl_RLock.Visible   := !lVal  // �������� �������
   Form_Card.Lbl_Info.Visible    := lVal
   Form_Card.Button_Save.Visible := lVal
   Form_Card.Image_1.Visible     := !lVal

   aDimCard := GetProperty(cForm, 'Cargo') // ������� ���� ������ ��������

   aCardName := aDimCard[1]   // ������������ �����
   aCardFld  := aDimCard[2]   // ���� ����
   aCardType := aDimCard[3]   // ��� ��������� ����
   aCardFSpr := aDimCard[4]   // ���� �������/����������� 2�-������

   FOR nI := 1 TO Len(aObjGBox)

      cObj   := aObjGBox[nI]
      IF aCardType[nI]  == "S" // ��� ���� ����������
         SetProperty(cForm, cObj, 'Enabled' , lVal)
         // ����������� �������������� ����� ������, �.�. ��� ������ ����� ��������
         SetProperty(cForm, cObj, 'Readonly', .T. )  
         xVal := FIELDGET( FIELDNUM( aCardFld[nI] ) )
         cVal := SpravGetCode( xVal, aCardFSpr[nI] )        // �������� �� �����������
         SetProperty(cForm, cObj, "Value" , cVal)           // ����� �� ��������
         aCargo    := GetProperty(cForm, cObj, 'Cargo' )    // ������� ���� ������
         aCargo[3] := xVal
         aCargo[4] := cVal
         SetProperty(cForm, cObj, 'Cargo', aCargo )         // �������� ���� ������
         cNButt := "Button_" + cObj
         SetProperty(cForm, cNButt, 'Enabled' , lVal)       // ������ �����/�����������
      ELSEIF aCardType[nI] == "FUN" // ��� ���� �������
         cRun  := aCardFSpr[nI]
         xVal  := &cRun
         cVal  := cValToChar(xVal)
         SetProperty(cForm, cObj, "Value" , cVal)  // ����� �� ��������
      ELSE
         // �����������/�������������� �������������� �����
         SetProperty(cForm, cObj, 'Readonly', !lVal)  
         xVal := FIELDGET( FIELDNUM( aCardFld[nI] ) )
         SetProperty(cForm, cObj, "Value" , xVal)  // ����� �� ��������
      ENDIF

   NEXT

   SetProperty( cForm, 'Button_Down', 'Enabled', .T. )  
   SetProperty( cForm, 'Button_Up'  , 'Enabled', .T. )     

RETURN NIL

/////////////////////////////////////////////////////////////////////
STATIC FUNCTION CardDownUp(oBrw, nArrow, aObjGBox)
   LOCAL cAls := oBrw:cAlias, cForm := ThisWindow.Name
   LOCAL nRecno, lRLock

   // ������ ���������� ������ 
   nRecno  := (cAls)->(RecNo())
   (cAls)->(DbGoto(nRecno))  
   FieldUserRlock(.F., nRecno)           // �������� ��� ���������� ������
   (cAls)->(DBUnlock())
   (cAls)->(DbCommit())  

   IF nArrow == 1
      oBrw:GoDown()
      IF oBrw:lHitBottom
         TONE(600)
      ENDIF
   ELSEIF nArrow == 2
      oBrw:GoUp()
      IF oBrw:lHitTop
         TONE(600)
      ENDIF
   ELSEIF nArrow == 0
      // ���������� �������� ����� ��������
   ENDIF

   RecnoRefresh(oBrw, .f.)  // ���������� ������� ������, �.�. ������ ��������� ����� 
                            // �������/�������� ������ ��� ���� ������� (������� �������) 

   nRecno  := (cAls)->(RecNo())

   // �������� ���������� ������ ������ ����������
   IF (cAls)->(DBRLock(nRecno))  
      lRLock := .F.
      (cAls)->(DBUnlock())
   ELSE
      lRLock := .T.
   ENDIF
   (cAls)->(DbCommit())  

   FieldUserRlock(.T., nRecno)        // �������� ��� ���������� ������
   // ���������� ������� ������ 
   (cAls)->(DBRLock(nRecno))  
   (cAls)->(DbCommit())  

   IF lRLock 
      CardRecnoGetSay(.F., aObjGBox)  // ������ �������
      SetProperty( cForm, 'Image_1'  , 'Enabled', .T. )     
   ELSE 
      CardRecnoGetSay(.T., aObjGBox)  // ������� ����� ������ � �������� �������
      SetProperty( cForm, 'Image_1'  , 'Enabled', .F. )     
   ENDIF

   SayUserRlock()
   CardRecnoInfo(oBrw)

   lStaticEditCard := .F.       // ���������� ����� ������ � ��������� ��� �� ���� 

RETURN nRecno

/////////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION CardSave(oBrw, nRecnoEdit, aObjGBox)
   LOCAL cForm := ThisWindow.Name
   LOCAL nRecno, nKolvo1, nKolvo2, nRowPos, aCargo
   LOCAL cAls := oBrw:cAlias, nRecGo, nCell, lRecnoWrite
   LOCAL cCardType, cCardFld, nI, cObj, xVal, nRow := 0

   nRowPos := oBrw:nRowPos
   nCell   := oBrw:nCell 
   nRecno  := (cAls)->(RecNo())
   (cAls)->( dbSkip(1) )
   If (cAls)->( EOF() )
      (cAls)->( dbGoto(nRecno) )
      (cAls)->( dbSkip(-1) )
      nRow := -1
   EndIf
   nRecGo   := (cAls)->(RecNo())         // ���� ���� (��������� ������ � ����)
   (cAls)->( dbGoto(nRecno) )            // ��������������� ����� ������� ������ � ����
   nKolvo1  := ORDKEYCOUNT()             // ����� ������� � ������� �� ���������� �����

   // ���� ������ ������� �� �������, ������ nRecnoEdit �� ����� nRecno
   // � ����� ���������� ������ �� ������ nRecnoEdit
   IF nRecnoEdit # nRecno
      dbGoto(nRecnoEdit)
   ENDIF

   SELECT(cAls)
   lRecnoWrite := .F.
   // ������� ������ ������ 
   IF (cAls)->(RLock())    

      FOR nI := 1 TO Len(aObjGBox)

          cObj   := aObjGBox[nI]
          aCargo := GetProperty(cForm, cObj, 'Cargo')   // ������ ������ �� ������� GetBox
          //  ��� ���������, ��� ����, �������� ���� � ��, �������� �� �����������
          cCardType := aCargo[1]
          cCardFld  := aCargo[2]
          IF cCardType  == "S" // ��� ���� ����������
             xVal := aCargo[3]
             FIELDPUT( FIELDNUM( cCardFld ) , xVal )  // ������ � ����
          ELSEIF cCardType == "FUN" // ��� ���� �������
             // ������� ������
          ELSE
             xVal := GetProperty( cForm, cObj, "Value" )
             FIELDPUT( FIELDNUM( cCardFld ) , xVal )  // ������ � ����
          ENDIF

      NEXT

      (cAls)->(DBUnlock())
      lRecnoWrite := .T.
   ELSE
      MsgStop("Record " + HB_NtoS(RECNO()) + " locked!")
   ENDIF
   (cAls)->(DbCommit())  // ��������� �� ����
   DO EVENTS

   SetProperty(cForm, 'Button_Down', 'Enabled', .T.)  
   SetProperty(cForm, 'Button_Up'  , 'Enabled', .T.)  

   IF lRecnoWrite
      lStaticEditCard := .F.   // �������� ��� ������ ������ 
   ENDIF

   nKolvo2 := ORDKEYCOUNT()    // ����� ������� ������� ����� ���������� ����� 

   WITH OBJECT oBrw                        
   IF nKolvo1 # nKolvo2
      :Reset()       
      If :nRowCount() >= :nLen
         :GoPos(nRowPos + nRow, nCell)
      ElseIf nRowPos == :nRowCount()
         :GoBottom()
         :nCell := nCell
      Else
         :GotoRec(nRecGo, nRowPos) 
         :nCell := nCell
         :UpStable()
      EndIf
    //? "nRecGo, nRowPos, :nRowCount(), :nLen, nKol2 =",nRecGo, nRowPos, :nRowCount(), :nLen, nKolvo2
   ELSE
      :Refresh()        
   ENDIF

   :SetFocus() 
   END WITH
   DO EVENTS 

RETURN lRecnoWrite

/////////////////////////////////////////////////////////////////////
// ��������� ������ �� ������ - ���������� S �����/������
STATIC FUNCTION EditTypeSprav(aThisCargo) 
   LOCAL cForm := ThisWindow.Name
   LOCAL nI, nKey, cN2, nRet, aDim, cVal, aClr, aButt, cMsg, aCargo
   LOCAL aDimCard, aCardName, aCardType, aCardFld, aCardFSpr

   aDimCard := GetProperty(cForm, 'Cargo') // ������� ���� ������ ��������

   aCardName := aDimCard[1]   // ������������ �����
   aCardFld  := aDimCard[2]   // ���� ����
   aCardType := aDimCard[3]   // ��� ��������� ����
   aCardFSpr := aDimCard[4]   // ���� �������/����������� 2�-������

   SetProperty( cForm, 'Button_Exit', 'Enabled', .F. )  
   SetProperty( cForm, 'Button_Save', 'Enabled', .F. )     

   nKey   := aThisCargo[1]       // ����� ������� ������ 
   cN2    := aThisCargo[2]       // ��� ������� GetBox
   aDim   := aCardFSpr[nKey]     // ���� ���������� �� ���� ������

   // ������� ���������� �� 3 ��������, ����� ����� ������ ���� ����������
   aClr  := { YELLOW, RED, GREEN }
   //aButt := {" CODE = 1 "," CODE = 2 "," CODE = 3 "} 
   aButt := {}
   FOR nI := 1 TO 3
      AADD(aButt, ALLTRIM(aDim[nI,2]) )
   NEXT
   cMsg  := "Select the value you need from the handbook ?" + CRLF
   cMsg  += "�������� ������ �������� �� ����������� ?"

   nRet  := HMG_Alert( cMsg, aButt, "Attention!", NIL, NIL, NIL, aClr, NIL )  

   IF nRet == 0  // ���������, ��� ����� ���������� �� ������ �� �����������
      lStaticEditCard := .F.  // ��������, ��� �� �������� ��� ���� ��������
   ELSE

      aDim   := aCardFSpr[nKey]                       // ���� ���������� 
      cVal   := SpravGetCode( nRet, aDim )            // ������������ �� �����������
      SetProperty(cForm, cN2, 'Value', cVal)          // �������� ��� ���� �� �������

      aCargo    := GetProperty(cForm, cN2, 'Cargo')   // ������� ������ GetBox
      aCargo[3] := nRet
      aCargo[4] := cVal
      //           ��� ���������, ����-��    , �������� ���� � ��
      //aCargo := { aCardType[nI], aCardFld[nI], nRet, cVal }
      SetProperty(cForm, cN2, 'Cargo', aCargo)        // �������� ���� ������ GetBox

   ENDIF

   SetProperty( cForm, 'Button_Exit', 'Enabled', .T. )  
   SetProperty( cForm, 'Button_Save', 'Enabled', .T. )     

RETURN NIL

/////////////////////////////////////////////////////////////////////
// �������� ����������� �������� � ������ �������� � ���� 
STATIC FUNCTION CardModify(oBrw, nRecnoEdit, aObjGBox)
   LOCAL cMsg, lRecnoSave

   IF lStaticEditCard  // ���� ����������� ���� ��������

     cMsg := "������ �������� ���� �������� !" + CRLF
     cMsg += "�� ������ �������� ��������� ������ � �������� ?" + CRLF
     cMsg += CRLF + "Record card has been changed!" + CRLF
     cMsg += "Do you want to write the changed data in the card ?"

     IF MsgYesNo( cMsg, "Save record" /*"��������� ������"*/, .T. )
        lRecnoSave := CardSave(oBrw, nRecnoEdit, aObjGBox)
        IF lRecnoSave
           lStaticEditCard := .F.   // �������� ��� ������ ������
        ENDIF
     ENDIF

   ENDIF

RETURN NIL

/////////////////////////////////////////////////////////////////////
// ������� ������ ��� ������ � ������� 
STATIC FUNCTION RecnoCreateCondition(oBrw,nRecno) 
   LOCAL nOrder, cVal, lWrite, nI := 0
   LOCAL cForm  := oBrw:cParentWnd
   LOCAL cAlias := oBrw:cAlias

   IF GetControlIndex("Timer_1", cForm ) > 0
      SetProperty( cForm, "Timer_1" , "Enabled" , .F. )                 // ��������� ������
   ENDIF
   cVal := GetProperty( cForm, "StatusBar" , "Item" , 2 )               // ������� ��� ����
   SetProperty( cForm, "StatusBar" , "Item" , 2, "Re-read database!" )  // ����� ����������

   oBrw:Enabled( .F. )  // ���������� ������� � ���������
   InkeyGui(600)

   lWrite := .T.
   SELECT(cAlias)
   nOrder := INDEXORD()             
   DbSetOrder(0)
   GOTO TOP
   DO WHILE ! EOF()
      IF ! DELETED()
         IF (cAlias)->(RLock())    
            (cAlias)->CODE := 0  // ��������
            (cAlias)->(DBUnlock())
         ENDIF
         IF lWrite
            IF RECNO() % 5 == 0
               // ������� ������ ������
               IF (cAlias)->(RLock())    
                  (cAlias)->CODE := 1  // �������� ��� ������ �� ��������� �������
                  nI ++
                  (cAlias)->(DBUnlock())
               ELSE
                  MsgStop("Record " + HB_NtoS(RECNO()) + " locked!")
               ENDIF
               IF nRecno == nI
                  lWrite := .F.  // ���������� ������
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      SKIP
   ENDDO

   (cAlias)->(DbCommit())  // ��������� �� ����

   DbSetOrder(nOrder)

   oBrw:Enabled( .T. )         // ������������� ������� � ���������

   oBrw:Reset() 

   // ����������� ���������� ��������� ������������� ���������
   oBrw:ResetVScroll( .T. ) 
   oBrw:oHScroll:SetRange( 0, 0 ) 

   SysRefresh() 
   oBrw:nLen := ( oBrw:cAlias )->( Eval( oBrw:bLogicLen ) ) 
   oBrw:Upstable() 
   oBrw:Refresh(.T., .T.) 
   oBrw:SetFocus() 
   DO EVENTS

   InkeyGui(500) // ��� �����

   SetProperty( cForm, "StatusBar" , "Item" , 2, cVal )  // ������� ���������

   IF GetControlIndex("Timer_1", cForm ) > 0
      SetProperty( cForm, "Timer_1" , "Enabled" , .F. )  // �������� ������
      nStaticTime := SECONDS()                           // �������� �����
   ENDIF

RETURN Nil

/////////////////////////////////////////////////////////////////////
STATIC FUNCTION RecnoRefresh(oBrw, ltimer)
   LOCAL cVal, cForm := oBrw:cParentWnd
   Default ltimer := .f.

   // ���� ��� �������������� ������ ������ �� ���������� ����
   // if there is no editing of record by the user that we will re-read the database
   If empty( oBrw:aColumns[ oBrw:nCell ]:oEdit )

      Index2Reindex(oBrw:cAlias,2)  // ����������������� ������

      cVal := GetProperty( cForm, "StatusBar" , "Item" , 2 )               // ������� ��� ����
      SetProperty( cForm, "StatusBar" , "Item" , 2, "Re-read database!" )  // ����� ����������
      // ��� ��������� �������
      SysRefresh() 
      oBrw:nLen := ( oBrw:cAlias )->( Eval( oBrw:bLogicLen ) ) 
      oBrw:Upstable() 
      oBrw:Refresh(.T., .T.) 
      oBrw:SetFocus() 
      DO EVENTS
      SetProperty( cForm, "StatusBar" , "Item" , 2, cVal )  // ������� ���������
   EndIf

   If ltimer
      nStaticTime := SECONDS()  // �������� �����
   EndIf

RETURN Nil

/////////////////////////////////////////////////////////////////////
FUNCTION Timer1Show()  // ����� ������� �� ����� 
    LOCAL cTime

    cTime := " " + SECTOTIME( GetProperty( ThisWindow.Name, "Timer_1", "Value" ) / 1000 - (SECONDS() - nStaticTime) )
    SetProperty ( ThisWindow.Name, "StatusBar" , "Item" , 3, cTime )

RETURN NIL

/////////////////////////////////////////////////////////////////////
FUNCTION UseOpenBase()
   LOCAL aStr   := {} 
   LOCAL cDbf   := GetStartUpFolder() + "\test7" 
   LOCAL cIndx  := cDbf 
   LOCAL lDbfNo 
   LOCAL aAlias := {} 
   LOCAL i, j, nn  := 1 
  
   IF ( lDbfNo := ! File( cDbf+'.dbf' ) ) 
      AAdd( aStr, { 'F1'      , 'D',  8, 0 } ) 
      AAdd( aStr, { 'F2'      , 'C', 60, 0 } ) 
      AAdd( aStr, { 'F3'      , 'N', 10, 2 } ) 
      AAdd( aStr, { 'CODE'    , 'N',  4, 0 } ) 
      AAdd( aStr, { 'F4'      , 'N',  2, 0 } ) 
      AAdd( aStr, { 'DT_RLOCK', 'C', 10, 0 } ) 
      dbCreate( cDbf, aStr ) 
   ENDIF 
  
   IF lDbfNo .OR. !File( cIndx+'.cdx' )
      USE ( cDbf ) ALIAS TEST EXCLUSIVE NEW 
  
      i := 0
      j := 0
      WHILE TEST->( RecCount() ) < 200 
         TEST->( dbAppend() ) 
         TEST->F1   := Date() + nn++
         TEST->F2   := "Recno = " + HB_NtoS( RECNO() )
         TEST->F3   := RECNO() 
         TEST->CODE := IIF( i == 1, 0, i + nn ) 
         TEST->F4   := j  
         IF ( i % 3 ) == 0
            DbDelete()
         ENDIF
         i++
         j++
         j := IIF( j > 3, 0, j ) 
      END 
  
      INDEX ON RECNO() TAG ALL TO (cIndx)           
      USE 
   ENDIF 

   SET AUTOPEN ON
  
   USE ( cDbf ) ALIAS TEST SHARED NEW 
   OrdSetFocus('ALL') 
   Dbsetorder(1)
   GO TOP 

   SET AUTOPEN OFF
  
   AADD( aAlias, ALIAS() )

RETURN aAlias

/////////////////////////////////////////////////////////////////////
FUNCTION Index2Create(aHWindows)
   LOCAL cFilter, cIndx, cMaska

   cMaska := HB_NtoS( LEN(aHWindows) + 1 ) + "-User"
   // �������� ������ ����� ������ ��� ������� ����� ��������
   // ����� �� ���� ���������� ��� ������������� ����� �����
   cIndx := GetStartUpFolder() + "\test7." + cMaska + '.cdx'
   cFilter := "CODE==1 .AND. !Deleted()"
   DELETEFILE(cIndx) // �����������
   SELECT TEST
   INDEX ON RECNO() TAG CODE1 TO (cIndx) FOR &cFilter ADDITIVE 
   OrdSetFocus('CODE1') 
   Dbsetorder(2)
   GO TOP 

RETURN NIL

/////////////////////////////////////////////////////////////////////
// ����������������� ������ 
STATIC FUNCTION Index2Reindex( cAls, nOrder )
   LOCAL aMemIndex, cTag, nTekOrder, cFilter, cOrdKey, cFileIndex
   LOCAL nKolvo, nRecno

   SELECT(cAls)
   nTekOrder  := INDEXORD()             
   cFileIndex := DBORDERINFO(DBOI_FULLPATH)
   cFilter    := OrdFor() 
   cOrdKey    := OrdKey()
   cTag       := OrdName()                 
   nRecno     := OrdKeyNo()

   IF nOrder == 2     // ����������� ������ 

      // ��������� ��� �������� �������
      aMemIndex := Index2OpenSave()
      DBCLEARINDEX()

      Index2OpenRestore( aMemIndex, -1 ) // ������������ ��������� ������ ����, ����� ����������

      INDEX ON &cOrdKey TAG &cTag TO (cFileIndex) FOR &cFilter ADDITIVE 
      OrdSetFocus(cTag) 
      DBSetOrder( nTekOrder )             // ������������ ����� 
      nKolvo := OrdKeyCount()             // ����� ������� �������  
      nRecno := IIF( nRecno > nKolvo, nKolvo, nRecno )
      nRecno := IIF( nRecno == 0, nKolvo, nRecno )
      ORDKEYGOTO(nRecno)                  // ������������ ������� ������

   ENDIF

RETURN NIL

/////////////////////////////////////////////////////////////////
// ������ ������� ��������� ������ �������� ���� 
FUNCTION Index2OpenSave()
LOCAL aDim := {}, nI, cPath

   FOR nI := 1 TO 100
      IF LEN(ORDNAME(nI)) == 0
          EXIT
      ELSE
         DBSetOrder(nI)
         cPath := ALLTRIM( DBORDERINFO(DBOI_FULLPATH,,ORDNAME(nI)) ) 
         IF cPath == ""
            EXIT
         ELSE
            AADD( aDim, { ALIAS(), cPath } )
         ENDIF
      ENDIF
   NEXT

RETURN aDim

/////////////////////////////////////////////////////////////////
// ���������� � �������� ���� ����� �������� ��������� ����� 
FUNCTION Index2OpenRestore(aDim,nFile)
LOCAL nI, cBase, nSel, cPathIndex 
DEFAULT aDim := {}, nFile := 0

IF LEN(aDim) == 0
   MsgDebug("��� �������� �������� ��� ���� !"+SPACE(40)+"������� �����: "+ALIAS()+" !")
ELSE
   cBase  := aDim[1,1]
   nSel   := SELECT(cBase)
   IF nSel > 0
      SELECT(cBase)
      FOR nI := 1 TO LEN(aDim) + nFile   // ������������ �������� �������
         cPathIndex := aDim[nI,2]        // -1 ����� ���������� �� ��� 
         ORDLISTADD( cPathIndex  )
         DBSetOrder(nI)
      NEXT
   ELSE
     MsgDebug("��� �������� ����: "+cBase+" ! ������� �� �����������...")
   ENDIF
ENDIF

RETURN NIL

///////////////////////////////////////////////////////////////////////////
#define GW_HWNDFIRST	0
#define GW_HWNDLAST	1
#define GW_HWNDNEXT	2
#define GW_HWNDPREV	3
#define GW_OWNER	4
#define GW_CHILD	5

// Check to run the second/third copy of the program
FUNCTION OnlyOneInstance(cAppTitle)
   LOCAL cTitle, hWnd, aHWindows := {} 
 
   hWnd := GetWindow( GetForegroundWindow(), GW_HWNDFIRST )
   WHILE hWnd != 0  // Loop through all the windows
      cTitle := GetWindowText( hWnd )
      IF GetWindow( hWnd, GW_OWNER ) = 0 .AND. cAppTitle $ cTitle 
         AADD( aHWindows, { hWnd, cTitle, IsWindowVisible( hWnd ) } )
      ENDIF
      hWnd := GetWindow( hWnd, GW_HWNDNEXT )  // Get the next window
      DO EVENTS
   ENDDO

RETURN aHWindows

///////////////////////////////////////////////////////////////////////////
FUNCTION ChangeWinBrw(oBrw,aHWindows)
   LOCAL nH := Form_0.Height , nW := Form_0.Width
   LOCAL nK, nI, hWnd
 
   IF LEN(aHWindows) == 0
      // skipping
      aStaticTableColor := { 242, 245, 204 } // ���� ��� ��������

   ELSEIF LEN(aHWindows) == 1

      Form_0.Row := 0 
      Form_0.Col := 0
      aStaticTableColor := { 255,178,178 }  // ���� ��� ��������

      oBrw:SetColor( { 2 }, { RGB( 255,178,178 ) } )
      oBrw:hBrush := CreateSolidBrush( 255,178,178 )
      RecnoRefresh(oBrw)

      FOR nI := 1 TO LEN(aHWindows)
          hWnd := aHWindows[nI,1]
          ShowWindow( hWnd, 6 )      // MINIMIZE windows
          ShowWindow( hWnd, 1 )      // SW_NORMAL windows
          BringWindowToTop( hWnd )   // A window on the foreground
         DO EVENTS
      NEXT
   ELSEIF LEN(aHWindows) == 2

      Form_0.Row := 0   
      Form_0.Col := GetDesktopWidth() - nW
      aStaticTableColor := { 159,191,236 }  // ���� ��� ��������

      oBrw:SetColor( { 2 }, { RGB( 159,191,236 ) } )
      oBrw:hBrush := CreateSolidBrush( 159,191,236 )
      RecnoRefresh(oBrw)

      FOR nI := 1 TO LEN(aHWindows)
          hWnd := aHWindows[nI,1]
          ShowWindow( hWnd, 6 )      // MINIMIZE windows
          ShowWindow( hWnd, 1 )      // SW_NORMAL windows
          BringWindowToTop( hWnd )   // A window on the foreground
         DO EVENTS
      NEXT
   ELSE
      nK := LEN(aHWindows)

      Form_0.Row := GetDesktopHeight() - 20 * nK - nH
      Form_0.Col := 0 + 20 * nK
      aStaticTableColor := { 159-10 * nK,191,236 }  // ���� ��� ��������

      oBrw:SetColor( { 2 }, { RGB( 159 - 10 * nK,191,236 ) } )
      oBrw:hBrush := CreateSolidBrush( 159 - 10 * nK,191,236 )
      RecnoRefresh(oBrw)

      FOR nI := 1 TO LEN(aHWindows)
          hWnd := aHWindows[nI,1]
          ShowWindow( hWnd, 6 )      // MINIMIZE windows
          ShowWindow( hWnd, 1 )      // SW_NORMAL windows
          BringWindowToTop( hWnd )   // A window on the foreground
         DO EVENTS
      NEXT

   ENDIF

RETURN Nil

///////////////////////////////////////////////////////////////////////////
#define COPYRIGHT  "Author by Andrey Verchenko. Dmitrov, 2019."
#define PRG_NAME   "TsBrowse - network opening of the database !"
#define PRG_VERS   "Version 1.0"
#define PRG_INF1   "������� �� ��������� ������� � �������� ����� ��"
#define PRG_INF2   "�������� ������ � ��������� - " +;
                   '���������� ������ ��� ������ ������� �������������� !' 
#define PRG_INF3   "Table on conditional index and database field card + record blocking"
#define PRG_INF4   "The scenario of working with the card -" +;
                   'write lock for editing by other users !'
#define PRG_INF5   "Tips and tricks programmers from our forum http://clipper.borda.ru"
#define PRG_INF6   "SergKis, Grigory Filatov and other..."

/////////////////////////////////////////////////////////////////////
FUNCTION MsgAbout()
   RETURN MsgInfo( PadC( PRG_NAME , 70 ) + CRLF +  ;
                   PadC( PRG_VERS , 70 ) + CRLF +  ;
                   PadC( COPYRIGHT, 70 ) + CRLF + CRLF + ;
                   PRG_INF1 + CRLF + ;
                   PRG_INF2 + CRLF + CRLF + ;
                   PRG_INF3 + CRLF + ;
                   PRG_INF4 + CRLF + CRLF + ;
                   PadC( PRG_INF5, 70 ) + CRLF + ;
                   PadC( PRG_INF6, 70 ) + CRLF + CRLF + ;
                   hb_compiler() + CRLF + ;
                   Version() + CRLF + ;
                   MiniGuiVersion() + CRLF + CRLF + ;
                   PadC( "This program is Freeware!", 70 ) + CRLF + ;
                   PadC( "Copying is allowed!", 70 ), "About", "ZZZ_B_ALERT", .F. )

///////////////////////////////////////////////////////////////////////////////
FUNCTION GetTxtWidth( cText, nFontSize, cFontName )  // �������� Width ������
   LOCAL hFont, nWidth
   DEFAULT cText     := REPL('A', 2)        ,  ;
           cFontName := _HMG_DefaultFontName,  ;   // �� MiniGUI.Init()
           nFontSize := _HMG_DefaultFontSize       // �� MiniGUI.Init()

   IF Valtype(cText) == 'N'
      cText := repl('A', cText)
   ENDIF

   hFont  := InitFont(cFontName, nFontSize)
   nWidth := GetTextWidth(0, cText, hFont)        // ������ ������ 
   DeleteObject (hFont)                    

   RETURN nWidth

//////////////////////////////////////////////////////////////////////////////
FUNCTION InfoDbase()
RETURN MsgInfo( Base_Current(), "Open databases" )

//////////////////////////////////////////////////////////////////////////////
FUNCTION Base_Current(cPar)
   LOCAL cMsg, nI, nSel, nOrder, cAlias, cIndx, aIndx := {}
   DEFAULT cPar := ""

   cAlias := ALIAS()
   nSel := SELECT(cAlias)
   IF nSel == 0
      cMsg := "No open BASE !" + CRLF 
      RETURN cMsg
   ENDIF

   nOrder := INDEXORD()  
   cMsg   := "Open Database - alias: " + cAlias + "   RddName: " + RddName() + CRLF
   cMsg   += "Path to the database - " + DBINFO(DBI_FULLPATH) + CRLF + CRLF
   cMsg   += "Open indexes: "

   IF nOrder == 0
      cMsg += " (no indexes) !" + CRLF 
   ELSE
      cMsg += ' DBOI_ORDERCOUNT: ( ' + HB_NtoS(DBORDERINFO(DBOI_ORDERCOUNT)) + ' )' + CRLF + CRLF
      FOR nI := 1 TO 100
         cIndx := ALLTRIM( DBORDERINFO(DBOI_FULLPATH,,ORDNAME(nI)) )
         IF cIndx == ""
            EXIT
         ELSE
            DBSetOrder( nI )
            cMsg += HB_NtoS(nI) + ') - Index file: '  + CRLF + DBORDERINFO(DBOI_FULLPATH) + CRLF
            cMsg += '     Index Focus: ' + ORDSETFOCUS() + ",  DBSetOrder(" + HB_NtoS(nI)+ ")" + CRLF
            cMsg += '       Index key: "' + DBORDERINFO( DBOI_EXPRESSION ) + '"' + CRLF
            cMsg += '       FOR index: "' + OrdFor() + '"' + CRLF
            cMsg += '   DBOI_KEYCOUNT: ( ' + HB_NtoS(DBORDERINFO(DBOI_KEYCOUNT)) + ' )' + CRLF + CRLF
            AADD( aIndx, STR(nI,3) + "  OrdName: " + OrdName(nI) + "  OrdKey: " + OrdKey(nI) )
         ENDIF
      NEXT
      DBSetOrder( nOrder ) 
      cMsg += "Current index = "+HB_NtoS(nOrder)+" , Index Focus: " + ORDSETFOCUS()
   ENDIF
   cMsg += "          Number of records = " + HB_NtoS(ORDKEYCOUNT()) + CRLF

   RETURN cMsg
