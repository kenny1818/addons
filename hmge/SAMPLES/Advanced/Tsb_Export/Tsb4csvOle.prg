/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2018 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
*/
#define _HMG_OUTLOG

#include "minigui.ch"
#include "excel.ch"

* =======================================================================================
FUNCTION Brw4CsvOle( oBrw, cFile, cFileFormat, lOpenFile )
   LOCAL cMsg, cVal, cFileExport, cPth, cFil, cExt
   LOCAL oExcel, oBook, oSheet

   hb_FNameSplit(cFile, @cPth, @cFil, @cExt) 
   cFileExport := cPth + cFil + ".csv"

   IF ! FILE( cFile )  
      cMsg := REPLICATE( "-._.", 16 ) + ";;"
      IF Hb_LangSelect() == "ru.RU1251"
         cMsg += "������ ����� ��� !;;"
         cVal := "������!"
      ELSE
         cMsg += "There is no such file!;;"
         cVal := "Error!"
      ENDIF
      cMsg += cFile + ";;"
      cMsg += REPLICATE( "-._.", 16 ) + ";;"
      cMsg := AtRepl( ";", cMsg, CRLF )
      MsgStop( cMsg , cVal )
      RETURN Nil 
   ENDIF

   CursorWait()
   WaitThreadCreateIcon( 'Loading the report in', 'EXCEL OLE ...' )   // ������ ��� �������

   oExcel := win_oleCreateObject( "Excel.Application" ) 

   // ���������� Ole �� HBWIN.lib
   IF ( oExcel := win_oleCreateObject( "Excel.Application" ) ) == NIL 
      cMsg := REPLICATE( "-._.", 16 ) + ";;"
      IF Hb_LangSelect() == "ru.RU1251"
         cMsg += "MS Excel �� �������� !;;   ������"
         cVal := "������!"
      ELSE
         cMsg += "MS Excel is not available !;;   Error"
         cVal := "Error!"
      ENDIF
      WaitThreadCloseIcon()  // kill the window waiting
      CursorArrow()

      cMsg += " [ " + win_oleErrorText() + " ];;"
      cMsg += REPLICATE( "-._.", 16 ) + ";;"
      cMsg := AtRepl( ";", cMsg, CRLF )
      MsgStop( cMsg , cVal )
      RETURN Nil 
   ENDIF

   oExcel:Visible := .F.          // .T. �������� Excel �� ������ ��� �������
   oExcel:DisplayAlerts := .F.    // ������ �������������� Excel

   oExcel:Workbooks:Open(cFile)
   oBook  := oExcel:ActiveWorkbook
   oSheet := oExcel:ActiveSheet

   DeleteOnTheExcelSheet(oBrw,oExcel,oSheet)

   IF cFileFormat == "CSV"
      oBook:SaveAs( cFileExport, xlCSVWindows )
   ELSEIF cFileFormat == "DBF"
      oBook:SaveAs( cFileExport, xlDBF4 )
   ELSE
      cMsg := "Unknown file format - " + cFileFormat + " !"
      MsgStop( cMsg, "Error!" )
   ENDIF

   oExcel:Application:Quit()

   WaitThreadCloseIcon()  // kill the window waiting
   CursorArrow()

   If lOpenFile
      ShellExecute( 0, "Open", cFileExport,,, 3 )
   EndIf

   RETURN Nil

* =======================================================================================
FUNCTION DeleteOnTheExcelSheet(oBrw,oExcel,oSheet)
   LOCAL nI, lTsbSuperHd, lTsbHeading, lTsbFooting, nLine, aLineDel := {}

   // �������� ���������� �������
   lTsbSuperHd := oBrw:lDrawSuperHd
   IF lTsbSuperHd
      lTsbSuperHd := ( AScan( oBrw:aSuperHead, {|a| !Empty(a[3]) } ) > 0 )
   ENDIF

   // �������� ����� �������
   lTsbHeading := oBrw:lDrawHeaders
   If lTsbHeading    
      lTsbHeading := ( AScan( oBrw:aColumns, { |o| !Empty( o:cHeading ) } ) > 0 )
   Endif

   // �������� ������� �������
   lTsbFooting := oBrw:lDrawFooters
   If lTsbFooting    
      lTsbFooting := ( AScan( oBrw:aColumns, { |o| !Empty( o:cFooting ) } ) > 0 )
   Endif

   ////////////// ��������� ������ ///////////////
   // nLine := 1  // ����� ������� 
   // nLine := 2  // ������ ������ 
   // nLine := 3  // ���������� �������, ���� ���� 
   // nLine := 4  // ����� �������, ���� ���� 
   // nLine := 5  // ������ �������, ������ ������ (���� ���� ���������� � ����� �������)
   // nLine := nLine + oBrw:nLen // ������ �������, ���� ���� 

   nLine  := 1
   AADD( aLineDel, nLine )  // ����� ������� 

   ++nLine
   AADD( aLineDel, nLine )  // ������ ������

   // ���������� �������
   If lTsbSuperHd 
      ++nLine
      AADD( aLineDel, nLine )
   EndIf

   // ����� �������
   If lTsbHeading     
      ++nLine
      AADD( aLineDel, nLine )
   EndIf

   nLine := nLine + oBrw:nLen

   // ������� ������ �������
   If lTsbFooting
      ++nLine
      AADD( aLineDel, nLine )
   EndIf

   FOR nI := LEN(aLineDel) TO 1 STEP -1
      nLine := aLineDel[nI]
      oSheet:Cells( nLine, 1 ):Value := nI
      oExcel:Rows(nLine):Delete()
   NEXT

   RETURN Nil

