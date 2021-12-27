/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2020 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 * Copyright 2020 Sidorov Aleksandr <aksidorov@mail.ru>  Dmitrov, Moscow region
 *
*/
#define _HMG_OUTLOG
#define PBM_SETPOS          1026   // ������������� ������� ������� ��� ���������� ���������� � �������������� ������, ����� �������� ����� �������
#define TYPE_EXCEL_FORMULA  '#'    // ��� ��� ������� ��� ������

#include "hmg.ch"
#include "excel.ch"
* ======================================================================
// ����� ���������������� �������� ����� ����������� ������� �� bExtern2
FUNCTION myTuningExternExcel( hProgress, oSheet, oExcel)
   LOCAL aParams := hb_aParams(), nParams := PCount()
   LOCAL nTotal, nRow, nColHead, oRange, nRowXls, nI, cMsg //, hWnd
   LOCAL uValue, aFClr, aBClr, nXlsRow, nXlsColumn, xVal
   LOCAL nRowLine1, nRowRecno, nRowFoot, nLinef, oBook

   ? "----" + ProcNL()
   ? "nParams=", nParams
   ? "aParams=", aParams
   //?v aParams

   oExcel:Visible        := .F.      // .T. �������� Excel �� ������ ��� �������
   oExcel:DisplayAlerts  := .F.      // ������ �������������� Excel
   oExcel:ReferenceStyle := xlR1C1   // ����� ������� ������� - �����
   oExcel:ActiveWindow:Zoom:= 75     // % ������ ����� ����� � ��������
   oExcel:UserName       := cFileNoPath( App.ExeName, "" )
                                                                     // �������� ��������
   //oExcel:ActiveWorkbook:BuiltinDocumentProperties:Item(1) := "Harbour + MiniGui + Excel"     // ���������
   //oExcel:ActiveWorkbook:BuiltinDocumentProperties:Item(3) := cFileNoPath( App.ExeName, "" )  // ����� (��������� ��������)

   oRange     := oExcel:ActiveCell:SpecialCells( xlLastCell )
   nXlsRow    := oRange:Row                      // ���������� ����� ������� Excel
   nXlsColumn := oRange:Column                   // ���������� ������� Excel - �� ������ �������� ��������� !
   nXlsColumn := oSheet:UsedRange:Columns:Count  // ���������� ������� Excel - ��������

   ?  "XLS= row/col:", nXlsRow, nXlsColumn

   nRowLine1 := nRowRecno := 0
   FOR nRow := 1 to nXlsRow                 // �� ������� �������
      xVal := oSheet:Cells( nRow, 1 ):Value
      IF xVal == NIL
      ELSE
         IF VALTYPE(xVal) == "N"
            IF nRowLine1 == 0
               nRowLine1 := nRow
            ENDIF
         ELSE
            xVal := VAL(xVal)
         ENDIF
         IF xVal > 0
            nRowRecno ++
         ENDIF
      ENDIF
   NEXT
   // ����� ������ � ��������� ������ ������� � ������ ����� �� ��������
   nRowRecno -= 1             // ����� � ������ �����
   nRowFoot := nRowRecno - 1  // ������ ������� �����
   ? "  ����� ������ � ��������� ������ ������� � ������ ����� �� ��������"
   ? "  =",nRowLine1, nRowRecno, nRowFoot

   // ������ �� ������� � �� �������� ��������
   // ��� �������� � ������ < 0 �������� ������
   aFClr := WHITE   // ���� ������ ������
   aBClr := PURPLE  // ���� ���� ������
   nLinef := nRowLine1
   nTotal := nRowFoot
   FOR nRow := 1 to nTotal                     // �� ������� �������
      //FOR nColHead := 1 to nColDbf           // �� ���� �������� �������
      FOR nColHead := 31 to 32                 // �� �������� �������� �������
         // ������ ��� ������� - �������
          uValue := oSheet:Cells( nLinef, nColHead):Value
          // ��� �������� � ������ < 0 �������� �������� ������ � �����
          if !Empty(uValue) .and. oSheet:Cells( nLinef, nColHead):Value < 0
              oSheet:Cells( nLinef, nColHead):Font:Color     := RGB(aFClr[1],aFClr[2],aFClr[3])
              oSheet:Cells( nLinef, nColHead):Interior:Color := RGB(aBClr[1],aBClr[2],aBClr[3])
          endif
      NEXT
      If hProgress != Nil
         SendMessage(hProgress, PBM_SETPOS,nLinef,0)
      EndIf
      nLinef++
      DO EVENTS
   NEXT

   nRowXls := nRowFoot + nRowLine1  // ������ ������� � ������
   FOR nI := 31 TO 32    // ������ ������� ��� �����
      oSheet:Cells[ nI, nRowXls ]:NumberFormat        := '' // ������� ������� - ������ ������
      oSheet:Cells[ nI, nRowXls ]:Font:ColorIndex     := 3  // ����� �������
      oSheet:Cells[ nI, nRowXls ]:Font:Bold           := .T.
      oSheet:Cells[ nI, nRowXls ]:Borders():LineStyle := 1
      // ������� ��� ������ �������
      oSheet:Cells[ nI, nRowXls ]:Formula := "=����(R[-" + HB_NtoS(nRowXls + 1 - nTotal) + "]C:R[-1]C)"
   NEXT

   nLinef := nRowLine1
   FOR nRow := 1 to nTotal                     // �� ������� �������
      // ������ �� ������� � �� 3 ������� �������
      // ��� �������� ���������� "Dmitrov" �������� ������
      // �������� ��� ������
      aFClr := PURPLE           // ���� ������ ������
      aBClr := SILVER           // ���� ���� ������
      nColHead := 3             // ����� �� 3 �������
      uValue := oSheet:Cells( nLinef, nColHead):Value
      if At("Dmitrov",uValue)>0
        // ����� ��� ������
        oRange:=oSheet:Range(osheet:cells(nLinef,1),osheet:cells(nLinef,nXlsColumn))
        oRange:Font:Color     := RGB(aFClr[1],aFClr[2],aFClr[3])
        oRange:Interior:Color := RGB(aBClr[1],aBClr[2],aBClr[3])
        // ���� ������ �� ����� �������
        //        oSheet:Cells( nLinef, nColHead):Font:Color     := RGB(aFClr[1],aFClr[2],aFClr[3])
        //        oSheet:Cells( nLinef, nColHead):Interior:Color := RGB(aBClr[1],aBClr[2],aBClr[3])
      endif
      If hProgress != Nil
         SendMessage(hProgress, PBM_SETPOS,nLinef,0)
      EndIf
      nLinef++
      DO EVENTS
   NEXT
//------------------------------------------------------------
   WorkingOtherSheets(oExcel)    // ������ � ������� 2 � 3

   WorkingFormulaSheets(oExcel)  // ������ � ��������� - ���� 2
//------------------------------------------------------------
   // ��������� ������ �������
   cMsg := UPPER(oExcel:ActivePrinter)
   IF AT("�����������", cMsg ) > 0
      // ���� ��� ���������  � �������
      AlertStop("����������� ������� !;�������� ������ ���������� !;", "������ ��� ������")
   ELSE
      oExcel:ActiveSheet:PageSetup:Zoom := FALSE
      oExcel:ActiveSheet:PageSetup:FitToPagesWide := 1
      oExcel:ActiveSheet:PageSetup:FitToPagesTall := 10
      oExcel:ActiveSheet:PageSetup:Orientation := xlLandscape // �������� - �������
   ENDIF

   oBook   := oExcel:ActiveWorkBook
   oSheet  := oBook:Sheets("My_Table"):Select()  // �������� �� 1 ����

   RETURN NIL

* ======================================================================
// ������ � ������� ������� ������
FUNCTION WorkingOtherSheets(oExcel)
   LOCAL oBook, oSheet, oSheets, nCnt, cMsg, xVal, oRange, nXlsRow, nXlsColumn, nI

   ? "----" + ProcNL()

   oExcel:Visible  := .T. //�������� Excel �� ������ ��� �������

   oBook   := oExcel:ActiveWorkBook
   oSheets := oBook:Sheets

   // �������� ������ ������
   nCnt    := oSheets:Count   // ���������� ������ � ����� ������
   IF nCnt == 1
      oSheets:Add() // 3
      oSheets:Add() // 2
   ELSEIF nCnt == 2
      oSheets:Add()
   ENDIF

   oSheet := oBook:Sheets("����1")   // ������� �� 1 ����
   oSheet:name := "My_Table"         // ��� ����� ��������
   oSheet := oBook:Sheets("����2")   // ������� �� 2 ����
   oSheet:name := "My_Report"        // ��� ����� ��������
   oSheet := oBook:Sheets("����3")   // ������� �� 2 ����
   oSheet:name := "Other"            // ��� ����� ��������
   oSheet:Visible := .F.             // ������ ���� 3 � ������

   nCnt := oBook:Sheets:Count   // ���������� ������ � ����� ������
   cMsg := "Number of sheets in a book = " + HB_NtoS(nCnt) + ";"

   FOR EACH oSheet IN oBook:WorkSheets
      cMsg += oSheet:Name + ";"
   NEXT
   //AlertInfo(cMsg)
   cMsg := ATREPL( ";", cMsg, CRLF )
   ? cMsg

   oSheet := oBook:Sheets("My_Report")  // ������� �� 2 ����
   oSheet:Cells:Font:Name := "Arial"
   oSheet:Cells:Font:Size := 12

   oSheet:Cells( 1, 1 ):Value := "Progr:"
   oSheet:Cells( 2, 1 ):Value := "Avtor:"
   oSheet:Cells( 3, 1 ):Value := "Lib:"
   oSheet:Cells( 4, 1 ):Value := "Lang:"

   oSheet:Columns( 1 ):Font:Bold := .T.
   oSheet:Columns( 1 ):AutoFit()
   oSheet:Columns( 2 ):AutoFit()

   oSheet:Cells( 1, 2 ):Value     := App.ExeName
   oSheet:Cells( 2, 2 ):Value     := "(c) 2020 Verchenko Andrey. Dmitrov, Moscow region"
   oSheet:Cells( 1, 2 ):Font:Size := 14
   oSheet:Cells( 2, 2 ):Font:Size := 14
   oSheet:Cells( 3, 2 ):Value     := MiniGuiVersion()
   oSheet:Cells( 4, 2 ):Value     := Version()

   oSheet     := oBook:Sheets("My_Table")        // ������� �� ����
   oRange     := oExcel:ActiveCell:SpecialCells( xlLastCell )
   nXlsRow    := oRange:Row                      // ���������� ����� ������� Excel
   nXlsColumn := oSheet:UsedRange:Columns:Count  // ���������� ������� Excel - ��������
   ?  "XLS= row/col:", nXlsRow, nXlsColumn

   // ������� ������ � 1-�� ����� ������
   xVal := oSheet:Cells( 1, 1 ):Value
   ? "  Read data from Excel - Cell(1,1)=", VALTYPE(xVal) , xVal ; ? // ��������� ����� �����

   xVal := oSheet:Cells( 11, 3 ):Value
   ? "  Read data from Excel - Cell(11,3)=", VALTYPE(xVal) , xVal ; ?

   // ����� � ���
   xVal := oSheet:Range("R11:C3"):Value
   ? "  Read data from Excel - Cell(R11:C3)=", VALTYPE(xVal) , xVal ; ?
   ?v xVal

   ? "------"
   ? " Row 11:"
   FOR nI := 1 TO nXlsColumn
       xVal := oSheet:Cells( 11, nI ):Value
       ? "       .", nI, VALTYPE(xVal) , xVal
   NEXT

RETURN NIL

* ======================================================================
// ������ � � ��������� - ���� 2
FUNCTION WorkingFormulaSheets(oExcel)
   LOCAL oBook, oSheet //, oSheets

   oBook  := oExcel:ActiveWorkBook
   oSheet := oBook:Sheets("My_Report")       // ������� �� 2 ����

   // ������� ����� � ����� ��� ���� ��������
   //oSheet:Cells:Font:Name       := "Arial Black"
   //oSheet:Cells:Font:Size       := 12
   //oSheet:Cells:Font:ColorIndex := 6
   //oSheet:Cells:Font:Bold       := .T.

   oSheet:Cells( 6, 2 ):Value               := "Summa:"
   oSheet:Cells( 6, 3 ):Value               := 123456.1234
   oSheet:Cells( 6, 3 ):NumberFormat        := '# ##0,0000'
   oSheet:Cells( 6, 3 ):Font:ColorIndex     := 3
   oSheet:Cells( 6, 3 ):Borders():LineStyle := 1

   oSheet:Cells( 7, 2 ):Value := "10 % ="
   oSheet:Cells( 7, 3 ):NumberFormat        := '' // ������� ������� - ������ ������
   oSheet:Cells( 7, 3 ):Font:ColorIndex     := 5
   oSheet:Cells( 7, 3 ):Borders():LineStyle := 1
   oSheet:Cells( 7, 3 ):Value               := "=R[-1]C/10"        // ������� ��� ������ �������

   oSheet:Cells( 8, 2 ):Value := "28 % ="
   oSheet:Cells( 8, 3 ):NumberFormat        := '' // ������� ������� - ������ ������
   oSheet:Cells( 8, 3 ):Font:ColorIndex     := 4
   oSheet:Cells( 8, 3 ):Borders():LineStyle := 1
   oSheet:Cells( 8, 3 ):Value               := "=R[-2]C*(28/100)"  // ������� ��� ������ �������

   oSheet := oBook:Sheets("My_Table")  // �������� �� ����
   //oSheets:Item(1):Select()          
   //oBook:Sheets(1):Select()          

   RETURN NIL
