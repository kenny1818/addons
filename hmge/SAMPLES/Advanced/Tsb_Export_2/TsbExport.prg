/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2020 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2020 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * ������� ������� � Excel, Word, Open Office � �����: xls/doc/ods/xml
 * ������������� ���������������� ������ TSBcell ��� �������� �������� ������.
 * Export Excel, Word, Open Office spreadsheets to files: xls/doc/ods/xml
 * Using the auxiliary TSBcell class for quick data export.
*/

#define _HMG_OUTLOG

#include "hmg.ch"
#include "TSBrowse.ch"
* ========================================================================
FUNCTION ToExcel7(oBrw,nView)
   LOCAL hProgress, tTime, bExternXls, aTsb, aXlsParam, aXlsTitle, aImage
   LOCAL nRecno, aXlsFoot, bExtern2

   nRecno := (oBrw:cAlias)->( RecNo() )
   oBrw:GoTop()  // ������� ��� � ������� ������� �������
   DO EVENTS

   tTime      := HB_DATETIME()
   hProgress  := NIL //test.PBar_1.Handle        // ���� ��� ProgressBar �� ������ �����
   aTsb       := myGetTsbContent(oBrw)           // ���������� �������
   aXlsParam  := myExcelParam(oBrw)              // ��������� ��� ������
   aXlsTitle  := myReportTitle(nView)            // ��������� ������
   aXlsFoot   := myReportFoot(nView,aTsb)        // ������ ������
   aImage     := myImageReport()                 // ��������

   // ������� �������� ������� � ������ ��� � ������ ������� �������
   // ������� �������� - ��� �� ������ � �������, �� � ����� � ������
   // ���� ��������� � �������-��������� ������ (bExtern2) ���� �����

/* ? "------- ��������/check -----------"
? "aTsb="     ,aTsb      ; ?v aTsb      ; ?
? "aXlsParam=",aXlsParam ; ?v aXlsParam ; ?
? "aXlsTitle=",aXlsTitle ; ?v aXlsTitle ; ?
? "aXlsFoot=" ,aXlsFoot  ; ?v aXlsFoot  ; ?
? "aImage="   ,aImage    ; ?v aImage    ; ? */

   IF nView == 1
      bExternXls := nil   // ����������� �������� ����� ��� ���������� oSheet
      aImage     := nil   // �� ����� ��������
      bExtern2   := nil   // �� ����� �����
   ELSEIF nView == 2
      // �������� -> Tsb7xlsOle.prg
      bExternXls := {|oSheet,aTsb,aXlsTitle| ExcelOle7Extern( hProgress, oSheet, aTsb, aXlsTitle) }
      bExtern2   := nil   // �� ����� �����
   ELSEIF nView == 3
      // ������� ������������� ��������� ������ -> TsbXlsTuning.prg
      // ����������� �������� ����� ��� ���������� oSheet
      bExternXls := {|oSheet,aTsb,aXlsTitle| ExcelOle7Extern( hProgress, oSheet, aTsb, aXlsTitle) }
      // ����������� �������� ����� ��� ��������������� ���������� oExcel
      bExtern2   := {|oSheet,oExcel,aTsb,nLinecolor| myTuningExternExcel( hProgress, oSheet, oExcel, aTsb, nLinecolor) }
   ENDIF

   // ��� ������� � ������ -> Tsb7xlsOle.prg
   Brw7XlsOle( aTsb, aXlsParam, aXlsTitle, aXlsFoot, aImage, hProgress, bExternXls, bExtern2 )
   TotalTimeExports("Brw7XlsOle(" + HB_NtoS(nView) + ")=", aXlsParam[1], tTime )

   oBrw:Refresh(.T.)
   oBrw:GoToRec( nRecno )
   oBrw:SetFocus()
   DO EVENTS

   RETURN Nil

* ======================================================================
// ��������� ������ ������/����/����/���
FUNCTION myReportTitle(nView,cPrg)
   LOCAL aTitle, cTitle, aFont, aColor, n1, n2, nG
   DEFAULT cPrg := ""

   IF cPrg == "WORD"   ; nG := 6
   ELSE                ; nG := 0
   ENDIF

   aTitle := {}
   cTitle := "Example of exporting a table (TITLE OF THE TABLE)"
   aFont  := { "Comic Sans MS", 24 - nG, .f. , .f. }
   aColor := IIF(nView==1,{BLACK,WHITE},{RED,YELLOW})  // ����/��� �����
   n1     := 1                                         // ������ ������
   n2     := 0                                         // 0-���������� ������ �� ����� �������
   AADD( aTitle, {n1,n2, cTitle, aFont, aColor, DT_CENTER } )
   AADD( aTitle, {} )  // �������������� ������

   cTitle := "Table subtitle (output example)"
   aFont  := { "Times New Roman", 20 - nG, .T. , .f. }
   aColor := { BLACK , SILVER }                    // ����/��� �������
   n1     := 1                                     // ������ ������
   n2     := 0                                     // ���������� ������ �� ����� �������
   AADD( aTitle, {n1,n2, cTitle, aFont, aColor, DT_CENTER } )
   AADD( aTitle, {n1,n2, cTitle, aFont, aColor, DT_RIGHT  } )
   AADD( aTitle, {} )  // �������������� ������

   IF nView == 2  // ��� �������� ������

      aFont  := { "DejaVu Sans Mono", 14 - nG, .f. , .f. }
      n1     := 2     // ������ ������
      n2     := 4     // ���������� ������
      AADD( aTitle, { n1,n2,"Cell color from 91% and more", aFont, {BLACK,HMG_n2RGB(CLR_GREEN) }, DT_LEFT } )
      AADD( aTitle, { n1,n2,"Cell color from 76% to 91%"  , aFont, {BLACK,HMG_n2RGB(CLR_YELLOW)}, DT_LEFT } )
      AADD( aTitle, { n1,n2,"Cell color 51% to 76%"       , aFont, {BLACK,HMG_n2RGB(RGB(0,176,240)) }, DT_LEFT } )
      AADD( aTitle, { n1,n2,"Cell color less than 51%"    , aFont, {BLACK,HMG_n2RGB(CLR_HRED)  }, DT_LEFT } )
      AADD( aTitle, {} )  // �������������� ������

      n1 := 2 ; n2 := 8
      AADD( aTitle, { n1,n2,"Cell color if there is no debt for the second month", aFont, {BLUE,HMG_n2RGB(RGB(0,255,0))}, DT_LEFT } )
      AADD( aTitle, { n1,n2,"Cell color, if there is a debt for the second month", aFont, {BLUE,HMG_n2RGB(CLR_ORANGE)  }, DT_LEFT } )
      AADD( aTitle, {} )  // �������������� ������

   ENDIF

   RETURN aTitle

* ======================================================================
// ������ ������/�����/�����
FUNCTION myReportFoot(nView,aTsb,cPrg)
   LOCAL aFoot, cFoot, aFont, aColor, n1, n2, nG
   LOCAL nI, aTsbFoot, aTsbHead
   DEFAULT cPrg := ""

   IF cPrg == "WORD"   ; nG := 6
   ELSE                ; nG := 0
   ENDIF

   aTsbHead := aTsb[2]    // ������ ����/���� ����� �������
   aTsbFoot := aTsb[5]    // ������ ����/���� ������� �������
   aFoot := {}
   AADD( aFoot, {} )   // �������������� ������
   AADD( aFoot, {} )   // �������������� ������

   cFoot    := aTsbFoot[3,4]
   aFont    := { "Comic Sans MS", 16 - nG, .T. , .f. }
   aColor   := { BLACK , WHITE }                     // ����/��� �����
   n1       := 3                                     // ������ ������
   n2       := 5                                     // ���������� ������ ��
   AADD( aFoot, {n1,n2, cFoot, aFont, aColor, DT_LEFT } )
   AADD( aFoot, {} )  // �������������� ������

   FOR nI := 7 TO 9
      cFoot  := "Total - " + StrTran(aTsbHead[nI,4], CRLF, " ") + ": " + aTsbFoot[nI,4]
      aFont  := { "Comic Sans MS", 16 - nG, .T.  , .f. }
      aColor := { BLACK ,  WHITE }                    // ����/��� �������
      n1     := 3                                     // ������ ������
      n2     := 9                                     // ���������� ������ ��
      AADD( aFoot, {n1,n2, cFoot, aFont, aColor, DT_LEFT } )
   NEXT
   AADD( aFoot, {} )  // �������������� ������

   cFoot := "The head of the calving" + SPACE(50) + "/Petrov I.I./"
   aFont  := { "Arial Black", 16 - nG, .T. , .T. }
   aColor := { BLACK ,  WHITE }
   AADD( aFoot, {2,-1, cFoot, aFont, aColor, DT_LEFT } )

   IF nView == 2  // ��� �������� ������

      AADD( aFoot, {} )  // �������������� ������
      aFont := { "DejaVu Sans Mono", 14 - nG, .f. , .f. }
      n1    := 2     // ������ ������
      n2    := 8     // ���������� ������ ��
      AADD( aFoot, { n1,n2,"Test color foot - Cell color from 91% and more", aFont, {BLACK,HMG_n2RGB(CLR_GREEN) }, DT_LEFT } )
      AADD( aFoot, { n1,n2,"Test color foot - Cell color from 76% to 91%"  , aFont, {BLACK,HMG_n2RGB(CLR_YELLOW)}, DT_LEFT } )
      AADD( aFoot, { n1,n2,"Test color foot - Cell color 51% to 76%"       , aFont, {BLACK,HMG_n2RGB(RGB(0,176,240)) }, DT_LEFT } )
      AADD( aFoot, { n1,n2,"Test color foot - Cell color less than 51%"    , aFont, {BLACK,HMG_n2RGB(CLR_HRED)  }, DT_LEFT } )
      AADD( aFoot, {} )  // �������������� ������

   ENDIF

   RETURN aFoot

* ======================================================================
STATIC FUNCTION myExcelParam(oBrw)
   LOCAL cPath, cXlsFile, aXlsFont, lActivate, lSave, cMaska, cMsg
   LOCAL nWidthTsb
   cPath     := GetStartUpFolder() + "\"        // ���� ������ �����
   cMaska    := "zTest_7XlsOle"                 // ������ �����
   cXlsFile  := cPath + cMaska + "_" + CharRepl( ".", DTOC( DATE() ), "_" ) + ".xls"
   cXlsFile  := GetFileNameMaskNum(cXlsFile)    // �������� ����� ��� �����
   cXlsFile  := cPath + hb_FNameName(cXlsFile)  // .xls - �� ����
   lActivate := .T.                             // ������� Excel
   lSave     := .T.                             // ��������� ����
   nWidthTsb := oBrw:GetAllColsWidth()          // ������ ���� ������� ������� (�������)
   aXlsFont  := {"DejaVu Sans Mono", 9 }        // ������ ���� ������� ��� Excel
                                                // ��� �����-������ ��������
                                                // ��� �������� �������� ���� �������
                                                // � ����� �������

   // ��������� ��� ����� �� ���������� �����
   // � ������ ������� ���������� ����� � ����� ����� Excel ����� "��������" ��� �����
   IF AtNum( ".", HB_FNameName( cXlsFile ) ) > 0
      cMsg := 'Calling from: ' + ProcName(0) + '(' + hb_ntos( ProcLine(0) )
      cMsg += ') --> ' + ProcFile(0) + ';;'
      cMsg += 'Output File Name - "' + HB_FNameName( cXlsFile ) + '";'
      cMsg += 'contains several signs dot !;'
      cMsg += 'Excel can "truncate" the file name !;;'
      cMsg := AtRepl( ";", cMsg, CRLF )
      MsgStop( cMsg , "Error" )
   ENDIF

   RETURN { cXlsFile, lActivate, lSave, aXlsFont }

* ======================================================================
FUNCTION ToWord7(oBrw,nView)
   LOCAL hProgress, tTime, bExternDoc, aTsb, aDocParam, aDocTitle, aImage, aDocFoot
   LOCAL nRecno

   nRecno := (oBrw:cAlias)->( RecNo() )
   oBrw:GoTop()  // ������� ��� � ������� ������� �������
   DO EVENTS
   // ������ ������� �� ������ ������� c ��������� ������
   oBrw:HideColumns( 31, .t.)
   oBrw:HideColumns( 32, .t.)
   DO EVENTS

   tTime      := HB_DATETIME()
   hProgress  := NIL //test.PBar_1.Handle          // ���� ��� ProgressBar �� ������ �����
   aTsb       := myGetTsbContent(oBrw)             // ���������� �������
   aDocParam  := myWordParam(oBrw)                 // ��������� ��� word
   aDocTitle  := myReportTitle(nView,"WORD")       // ��������� ������/word
   aDocFoot   := myReportFoot(nView,aTsb,"WORD")   // ������ ������/word
   aImage     := myImageReport()                   // ��������

   // ������� �������� ������� � ������ ��� � ������ ������� �������
   // ������� �������� - ��� �� ������ � �������, �� � ����� � ������

/*? "------- ��������/check -----------" + ProcNL()
? "aTsb="     ,aTsb      ; ?v aTsb      ; ?
? "aDocParam=",aDocParam ; ?v aDocParam ; ?
? "aDocTitle=",aDocTitle ; ?v aDocTitle ; ?
? "aDocFoot=" ,aDocFoot  ; ?v aDocFoot  ; ?
? "aImage="   ,aImage    ; ?v aImage    ; ? */

   IF nView == 1
      bExternDoc := nil   // ����������� �������� ����� ��� ���������� oSheet
      aImage     := nil   // �� ����� ��������
   ELSEIF nView == 2
      bExternDoc := {|aTsb,oTbl, oActive| WordOle7Extern(hProgress, aTsb, oTbl, oActive) }
   ENDIF

   Brw7DocOle( aTsb, aDocParam, aDocTitle, aDocFoot, aImage, hProgress, bExternDoc )
   TotalTimeExports("Brw7DocOle("+ HB_NtoS(nView) +")=", aDocParam[1], tTime )

   // ������������ ������� �� ������ �������
   oBrw:HideColumns( 31, .f.)
   oBrw:HideColumns( 32, .f.)
   oBrw:Refresh(.T.)
   oBrw:GoToRec( nRecno )
   oBrw:SetFocus()
   DO EVENTS

   RETURN Nil

* ======================================================================
STATIC FUNCTION myWordParam(oBrw)
   LOCAL cPath, cFile, lActivate, lSave, cMaska, nWidthTsb, aTblFont
   Local nCol, anWidth:={} ,oCol
   cPath     := GetStartUpFolder() + "\"        // ���� ������ �����
   cMaska    := "zTest_7DocOle"                 // ������ �����
   cFile     := cPath + cMaska + "_" + CharRepl( ".", DTOC( DATE() ), "_" ) + ".doc"
   cFile     := GetFileNameMaskNum(cFile)       // �������� ����� ��� �����
   lActivate := .T.                             // ������� Word
   lSave     := .T.                             // ��������� ����
   nWidthTsb := oBrw:GetAllColsWidth()          // ������ ���� ������� ������� (�������)
   aTblFont  := {"DejaVu Sans Mono", 6 }        // ������ ���� ������� ��� Word
                                                // ��� �����-������ � �������� ��������
                                                // ���� ������� �����
   WITH OBJECT oBrw
      FOR nCol := 1 TO :nColCount()
         oCol := :aColumns[ nCol ]
         // �������, ������� �� �����
         If nCol == 1 .and. oBrw:lSelector ; LOOP
         ElseIf ! oCol:lVisible            ; LOOP
         ElseIf oCol:lBitMap               ; LOOP
         EndIf
         AADD(anWidth, oBrw:aColumns[ nCol ]:nWidth)
         DO EVENTS
       NEXT
   End With

   RETURN { cFile, lActivate, lSave, aTblFont, nWidthTsb, anWidth }

* ======================================================================
FUNCTION ToXml7(oBrw,nView)
   LOCAL hProgress, tTime, aTsb, aXmlParam, aXmlTitle, aImage
   LOCAL nRecno, aXmlFoot

   nRecno := (oBrw:cAlias)->( RecNo() )
   oBrw:GoTop()  // ������� ��� � ������� ������� �������
   DO EVENTS

   tTime      := HB_DATETIME()
   hProgress  := NIL //test.PBar_1.Handle        // ���� ��� ProgressBar �� ������ �����
   aTsb       := myGetTsbContent(oBrw)           // ���������� �������
   aXmlParam  := myXmlParam(oBrw)                // ��������� ��� Xml
   aXmlTitle  := myReportTitle(nView)            // ��������� Xml
   aXmlFoot   := myReportFoot(nView,aTsb)        // ������ Xml
   aImage     := myImageReport()                 // ��������

   // ������� �������� ������� � ������ ��� � ������ ������� �������
   // ������� �������� - ��� �� ������ � �������, �� � ����� � ������

/*? "------- ��������/check -----------" + ProcNL()
? "aTsb="     ,aTsb      ; ?v aTsb      ; ?
? "aXmlParam=",aXmlParam ; ?v aXmlParam ; ?
? "aXmlTitle=",aXmlTitle ; ?v aXmlTitle ; ?
? "aXmlFoot=" ,aXmlFoot  ; ?v aXmlFoot  ; ?
? "aImage="   ,aImage    ; ?v aImage    ; ?*/

   IF nView == 1
      aImage     := nil   // �� ����� ��������
      Brw7Xml( aTsb, aXmlParam, aXmlTitle, aXmlFoot, hProgress, aImage)
   ELSEIF nView == 2
      Brw7XmlColor( aTsb, aXmlParam, aXmlTitle, aXmlFoot, hProgress, aImage)
   ENDIF

   TotalTimeExports("Brw7Xml(" + HB_NtoS(nView) + ")=", aXmlParam[1], tTime )

   oBrw:Refresh(.T.)
   oBrw:GoToRec( nRecno )
   oBrw:SetFocus()
   DO EVENTS

   RETURN Nil

* ======================================================================
STATIC FUNCTION myXmlParam(oBrw)
   LOCAL cPath, cFile, aFont, lActivate, lSave, cMaska
   LOCAL anWidth:={}, nHeight, nCol, oCol

   cPath     := GetStartUpFolder() + "\"        // ���� ������ �����
   cMaska    := "zTest_7Xml"                    // ������ �����
   cFile     := cPath + cMaska + "_" + CharRepl( ".", DTOC( DATE() ), "_" ) + ".xml"
   cFile     := GetFileNameMaskNum(cFile)       // �������� ����� ��� �����
   lActivate := .T.                             // ������� Xml
   lSave     := .T.                             // ��������� ����
   aFont     := {"DejaVu Sans Mono", 12 }
   nHeight := oBrw:nHeightCell

   WITH OBJECT oBrw
      FOR nCol := 1 TO :nColCount()
         oCol := :aColumns[ nCol ]
         // �������, ������� �� �����
         If nCol == 1 .and. oBrw:lSelector ; LOOP
         ElseIf ! oCol:lVisible            ; LOOP
         ElseIf oCol:lBitMap               ; LOOP
         EndIf
         AADD(anWidth, oBrw:aColumns[ nCol ]:nWidth)
         DO EVENTS
      NEXT
   End With

RETURN { cFile, lActivate, lSave, aFont, anWidth, nHeight }

