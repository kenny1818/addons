//*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2020 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 * Copyright 2020 Sidorov Aleksandr <aksidorov@mail.ru>  Dmitrov, Moscow region
 *
 * ������������� ����� ����� � ���� '^', '+', '=', '@', 'T'
 * ������� ������� Excel � ���� xls ����� OLE
 * ��������� ������ � ������� ��� �������� � ����� Excel (����� � �������).
 * Using field types in the database '^', '+', '=', '@', 'T'
 * Export Excel table to xls file via OLE
 * Support for formulas in the table for calculation in Excel itself (text to formula).
*/

#define PBM_SETPOS       1026  // ������������� ������� ������� ��� ���������� ���������� � �������������� ������, ����� �������� ����� �������
#define LINE_WRITE       100   // ���������� ����� ��� ������ �������
#define WIN_VT_VARIANT   12

#define Number_Characters_String_Cell  100  // ���������� �������� ������ ��� ������
#define TYPE_EXCEL_FORMULA '#'              // ��� ��� ������� ��� ������

#include "minigui.ch"
#include "tsbrowse.ch"
#include "excel.ch"
* =======================================================================================
// �������� ! ��������� ������ 65533 ����� � Excel ������ ! ����������� Excel 2003.
// Attention ! Upload more than 65533 rows in Excel is NOT possible ! Excel 2003 Restriction.
FUNCTION Brw7XlsOle( aTsb, aXlsParam, aXlsTitle, aXlsFoot, aImage, hProgress, bExtern, bExtern2 )
   LOCAL cVal, nCol, nLine, nLinef, nLinecolor, nTotal, nCount, nEvery
   LOCAL nColHead, nColBegTbl, flag_new_OutXls := .f.
   LOCAL oExcel, oBook, oSheet, oRange, cRange, nColDbf, nBeginTable
   LOCAL hWnd, uData , aTipeChars[Len(aTsb[4,1])]
   LOCAL aSet[ Min(LINE_WRITE,Len(aTsb[4])), Len(aTsb[4,1]) ]
   LOCAL aFont, aFontSHF, aClr, cMsg, cTitle, nStart, nRow, aCol
   LOCAL rType, nPoint, rPicture, nColSh1, nColSh2
   LOCAL cFile, lActivate, lSave, hFont, nIndexaSet, lFormula
   Default hProgress := nil, aXlsFoot := nil
   Default aImage := {}, bExtern := nil, bExtern2 := nil

   ////////////// ��������� ������ ///////////////
   // ����� xls-�����, ���� ����
   // �������
   // ������ xls-�����, ���� ����

   cFile     := aXlsParam[1]
   lActivate := aXlsParam[2]
   lSave     := aXlsParam[3]
   hFont     := aXlsParam[4]
   nTotal    := Len(aTsb[4])     // ���������� ����� �������
   nColDbf   := Len(aTsb[4,1])   // ���������� �������

   CursorWait()
   IF Hb_LangSelect() == "ru.RU1251" ; cMsg := '�������� ����� �'
   ELSE                              ; cMsg := 'Upload report to'
   ENDIF
   WaitThreadCreateIcon( cMsg, 'EXCEL OLE ...' )   // ������ ��� �������

   // ���������� Ole �� HBWIN.lib
   IF ( oExcel := win_oleCreateObject( "Excel.Application" ) ) == NIL
      cMsg := ";;"
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
      MG_Stop( cMsg , cVal )
      RETURN Nil
   ENDIF

   oExcel:Visible := .F.          // .T. �������� Excel �� ������ ��� �������
   oExcel:DisplayAlerts := .F.    // ������ �������������� Excel
   //oExcel:ActiveWindow:DisplayZeros := .F. // �� ���������� 0,00 � �������

   oExcel:WorkBooks:Add()
   oBook  := oExcel:ActiveWorkBook
   oSheet := oExcel:ActiveSheet

   // ���������� ����� ��� ����������� + ����� + ������ �������
   //   aFontSHF := GetFontParam( hFont )

   // ������� �������, ���� ����
   If hProgress != Nil
      SetProgressBarRange ( hProgress , 1 , nTotal )
      SendMessage(hProgress, PBM_SETPOS, 0, 0)
      nEvery := Max( 1, Int( nTotal * 0.05 ) ) // refresh hProgress every 5 %
   EndIf

   nLine  := 1
   // �������� � ������� ���� �������
   If ! Empty( aImage )
        oRange:=oSheet:Range(osheet:cells(1,1),osheet:cells(1,1))
        //  oExcel:ActiveSheet:Shapes:AddPicture(aImage[1],0, -1, oRange:Left, oRange:Top, -1, -1 ) �� ��������
        oExcel:ActiveSheet:Shapes:AddPicture(aImage[1],0, -1, oRange:Left, oRange:Top, PixelToPointX(aImage[2]),PixelToPointY(aImage[3]))
   Endif

   // ��������� �������
   If !Empty(aXlsTitle)
      For nRow := 1 TO Len(aXlsTitle)
         if Len(aXlsTitle[nRow]) >0
            cTitle := aXlsTitle[nRow,3]
            cTitle := AllTrim( cTitle )
            nCol := if (Empty(aXlsTitle[nRow,2]),nColDbf,aXlsTitle[nRow,2])
            oSheet:Cells( nLine, aXlsTitle[nRow,1]):NumberFormat := '@'
            oSheet:Cells( nLine, aXlsTitle[nRow,1]):Value := AllTrim( cTitle )
            cRange := HeadXls( aXlsTitle[nRow,1]) + Hb_NtoS( nLine )  + ":" + ;
                      HeadXls( nCol) + Hb_NtoS( nLine )

            oRange := oSheet:Range( cRange )
            If aXlsTitle[nRow,6] != Nil
              oRange:HorizontalAlignment := TbsXlsAlign( aXlsTitle[nRow,6] )
            Else
              oRange:HorizontalAlignment := TbsXlsAlign( DT_CENTER )
            Endif
            oRange:Merge()
            If aXlsTitle[nRow,4] != Nil
              aFont := aXlsTitle[nRow,4]
              aClr  := aXlsTitle[nRow,5]
              oRange:Font:Name := aFont[ 1 ]
              oRange:Font:Size := aFont[ 2 ]
              oRange:Font:Bold := aFont[ 3 ]
              oRange:Font:Color = RGB(aClr[1,1],aClr[1,2],aClr[1,3])
              oRange:Interior:Color := RGB(aClr[2,1],aClr[2,2],aClr[2,3])
            EndIf
         EndIf
         ++nLine
       Next
       ++nLine
   EndIf

   nColBegTbl := nLine  // ��������� ������ ��������� �������
   // ������� ���������� �������
   If Len(aTsb[1])>0
      nCol :=0
      nColSh2 :=0
      FOR EACH aCol IN aTsb[1]
         nCol++
         nColSh1 := if(aCol[5]>0, aCol[5], nColSh2+1)
         // ����  � -1 �� ��������� � ��������� ����������, �� ����� �� ���������
         if aCol[6]>0.and.nCol<Len(aTsb[1])
            if aTsb[1,nCol+1,5]>0
                nColSh2 := aTsb[1,nCol,5]-1
            endif
         endif
         nColSh2 := if(aCol[6]>0, aCol[6], if(nCol==Len(aTsb[1]), nColDbf, nColSh1))
         oSheet:Cells( nLine,  nColSh1):NumberFormat := '@'
         oSheet:Cells( nLine,  nColSh1):Value := if(Empty(aCol[4]),' ',aCol[4])
         cRange :=  HeadXls( nColSh1) + Hb_NtoS( nLine )  + ":" + ;
                    HeadXls( nColSh2) + Hb_NtoS( nLine )
         oSheet:Range( cRange ):HorizontalAlignment  := xlHAlignCenterAcrossSelection
         aFontSHF := GetFontParam(aCol[3])
         oSheet:Range( cRange ):Font:Name := aFontSHF[ 1 ]
         oSheet:Range( cRange ):Font:Size := aFontSHF[ 2 ]
         oSheet:Range( cRange ):Font:Bold := aFontSHF[ 3 ]
      NEXT
      ++nLine
   Endif

   // ������� ����� �������
   If Len(aTsb[2])>0
      nCol :=0
      FOR nColHead:= 1 to Len(aTsb[2])
         oSheet:Cells( nLine, nColHead ):NumberFormat := '@'
         oSheet:Cells( nLine, nColHead ):Value := aTsb[2,nColHead,4]
         // oSheet:Cells( nLine, nColHead ):Borders():LineStyle := xlContinuous
         aFontSHF := GetFontParam( aTsb[2,nColHead,3])
         oSheet:Cells( nLine, nColHead ):Font:Name := aFontSHF[ 1 ]
         oSheet:Cells( nLine, nColHead ):Font:Size := aFontSHF[ 2 ]
         oSheet:Cells( nLine, nColHead ):Font:Bold := aFontSHF[ 3 ]
         // aWidthChars [nCol] := max(aWidthChars [nCol], LenStrokaWithCRLF(uData))
      Next
      ++ nLine
   Endif

   // ��������� �������
   If Len(aTsb[3])>0
      FOR nCol:= 1 to Len(aTsb[3])
         oSheet:Cells( nLine, 1):NumberFormat := '@'
         oSheet:Cells( nLine, nCol ):Value := if(empty(aTsb[3,nCol,4]),' ',aTsb[3,nCol,4])
         oRange:=oSheet:Range(osheet:cells(nLine, nCol),osheet:cells(nLine, nCol))
         oRange:HorizontalAlignment := TbsXlsAlign( DT_CENTER )
         aFontSHF := GetFontParam( aTsb[3,nCol,3])
         oSheet:Cells( nLine, nCol ):Font:Name := aFontSHF[ 1 ]
         oSheet:Cells( nLine, nCol ):Font:Size := aFontSHF[ 2 ]
         oSheet:Cells( nLine, nCol ):Font:Bold := aFontSHF[ 3 ]
      Next
      ++nLine
   Endif

   nCount := 0
   // ������ - ����� ������� ������ !
   nIndexaSet  := 1
   nStart      := nLine
   nBeginTable := nStart
   nLinef      := nLine
   nLinecolor  := nLine

   FOR nRow:= 1 to nTotal
      FOR nColHead:= 1 to nColDbf
         uData    := aTsb[4,nRow,nColHead,4]
         rType    := aTsb[4,nRow,nColHead,5]
         rPicture := aTsb[4,nRow,nColHead,6]
         do Case
            Case (rType==TYPE_EXCEL_FORMULA)
               uData    := ''
               lFormula := .t. //��� �������
            Case (rType=='@'.or.rType=='D').and.Empty(uData)
               uData := ''
            Case ValType( uData )=="D"
               uData := hb_dtoc( uData , "dd.mm.yyyy")
            Case rType == 'L'
               rType := 'C'
            Case rPicture != Nil .and. uData != Nil .and. rType !='N'
              uData := Transform( uData, rPicture )
         endCase
         // ���������� ��� ���� � �������
         If !(rType = "U") .and. Empty(aTipeChars[nColHead]) .and. !Empty(uData )
            aTipeChars[nColHead] := rType
            cRange :=  HeadXls(nColHead)
            //��� ����� ������� ������� Excel �� ���� ������ ������� oBrw
            Do case
                  // ��� ������������� ����� ��������� ��� ��� ������ �����
               Case rType=="D"
                 //��� ���� ���� ���� ��� ����������������� Excel
                 //oSheet:Range(cRange+hb_NtoS(nBeginTable)+':'+cRange+hb_NtoS(nTotal+nBeginTable-1)):NumberFormat := "��.��.����"
                 //��� ���� ���� ������, �� ������� �� ��������� ��������
                 oSheet:Range(cRange+hb_NtoS(nBeginTable)+':'+cRange+hb_NtoS(nTotal+nBeginTable-1)):NumberFormat := "@"
               case aTipeChars[nColHead] =='C'.or.aTipeChars[nColHead] =='L'.or.aTipeChars[nColHead] =='='.or.aTipeChars[nColHead] =='@'
                 oSheet:Range(cRange+hb_NtoS(nBeginTable)+':'+cRange+hb_NtoS(nTotal+nBeginTable-1)):NumberFormat := '@'
                 // oSheet:Range(cRange+LTrim( Str(nBeginTable))+':'+cRange+LTrim( Str(nTotal+nBeginTable-1))):WrapText := .f.
                 oSheet:Range(cRange+hb_NtoS(nBeginTable)+':'+cRange+hb_NtoS(nTotal+nBeginTable-1)):ColumnWidth := Number_Characters_String_Cell
               case aTipeChars[nColHead] =='N'.or.aTipeChars[nColHead] =='+'.or.aTipeChars[nColHead] =='^'
                 If Empty(rPicture)
                   rPicture := Transform( uData, rPicture )
                 Endif
                 nPoint   := AT('.', rPicture )
                 if nPoint == 0
                    rPicture :='#0'
                 else
                    rPicture := Repl("#",nPoint-2) + '0,' + Repl("0",Len(rPicture)-nPoint)
                  //  rPicture :="#,##0.00"
                 endif
                 // ������ ���� := '## ### ###0' ��� '## ### ###0,00'
              oSheet:Range(cRange+hb_NtoS(nBeginTable)+':'+cRange+hb_NtoS(nTotal+nBeginTable-1)):NumberFormat := rPicture
            Endcase
         Endif
         uData := If( ValType( uData )=="N", uData , ;
               If( ValType( uData )=="L", If( uData ,".T." ,".F." ), cValToChar( uData ) ) )
         // ���������� ������ � ������
         aSet[ nIndexaSet , nColHead ] := uData
      Next

      IF (nIndexaSet == LINE_WRITE).or.(nRow == nTotal) // �� ���������� ������� ��� ����� �������
         flag_new_OutXls := .t. // ������ �������� - ����� ���������� � ������� � Excel
      ENDIF

      ++nLine

      // ���������� ������� �� LINE_WRITE ����� �� ������������ ��������
      IF flag_new_OutXls
         cRange :=  "A" + HB_NtoS(nStart)+":" +  HeadXls(nColDbf) + HB_NtoS(nLine-1)
         oRange:=oSheet:Range(cRange):Value := __oleVariantNew( WIN_VT_VARIANT, aSet, nIndexaSet, nColDbf ) // Microsoft Excel 8.0 Object Library
         nIndexaSet := 1        // ��������� ���������� � ������ �������
         nStart := nLine        // ������ ������ ��������� �����
         flag_new_OutXls := .f.
      ELSE
         nIndexaSet++          // ����� ��������� ������ ������
      EndIf

      If hProgress != Nil
         If nCount % nEvery == 0
            SendMessage(hProgress, PBM_SETPOS,nCount,0)
         EndIf
         nCount ++
      EndIf

   Next

   // ������� �������
   if lFormula  // ���� �������

      FOR nRow:= 1 to nTotal //Len(aTsb[4])
         FOR nColHead:= 1 to nColDbf //Len(aTsb[4,1])
            rType    := aTsb[4,nRow,nColHead,5]
            uData    := aTsb[4,nRow,nColHead,4]
            if rType==TYPE_EXCEL_FORMULA.or.rType=='C'.and.Left(uData,1)='='
               oSheet:Cells( nLinef, nColHead):Formula := uData
            endif
         Next
        nLinef++
      Next
  endif

   // ������� ������ �������
   nColHead := 0
   If Len(aTsb[5])>0
      FOR nColHead:= 1 to Len(aTsb[5])
         oSheet:Cells( nLine, nColHead):NumberFormat := '@'
         oSheet:Cells( nLine, nColHead ):Value := aTsb[5,nColHead,4]
         oSheet:Cells( nLine, nColHead ):Font:Name := aFontSHF[ 1 ]
         oSheet:Cells( nLine, nColHead ):Font:Size := aFontSHF[ 2 ]
         oSheet:Cells( nLine, nColHead ):Font:Bold := aFontSHF[ 3 ]
         // aWidthChars [nCol] := max(aWidthChars [nCol], LenStrokaWithCRLF(uData))
      Next
      nLine++
   Endif
   SysRefresh()

   // ����� ������ ������� � �������
   cRange :=  "A" + HB_NtoS(nBeginTable)+":" + HeadXls(nColDbf) + HB_NtoS(nTotal+nBeginTable-1)
   oRange := oSheet:Range(cRange)
   // oRange:Borders():LineStyle := xlContinuous
   aFont := hFont
   oRange:Font:Name := aFont[ 1 ]
   oRange:Font:Size := aFont[ 2 ]
   If Len(aFont)>3
      oRange:Font:Bold := aFont[ 3 ]
   Endif

   // ������� ����� �� �������
   cRange :=  "A" + HB_NtoS(nColBegTbl)+":" + HeadXls(nColDbf) + HB_NtoS(nLine-1)
   oRange:=oSheet:Range(cRange)
   oRange:Borders():LineStyle := xlContinuous
   //oRange:Columns:AutoFit() - ������ ! ����� ��������� ������ �������.

   oRange:Columns:AutoFit() // ������������� �������� ������ ���� �������� � ������ ���� �����
                            // � ���������, ����� ���� ��������� ����� �����.
                            // ����� ��������� ������ � ��� ����������, ������� ������� ��
                            // ������ �������� (���������) ��� ������ ����� (����� ���������), ����� ����� ������.

   // ��������� ������ �������
   If !Empty(aXlsFoot)
      For nRow := 1 TO Len(aXlsFoot)
         if Len(aXlsFoot[nRow]) >0
            cTitle := aXlsFoot[nRow,3]
            cTitle := AllTrim( cTitle )
            nCol := if (Empty(aXlsFoot[nRow,2]),nColDbf,if(aXlsFoot[nRow,2]<0,aXlsFoot[nRow,1],aXlsFoot[nRow,2]))
            oSheet:Cells( nLine, aXlsFoot[nRow,1]):NumberFormat := '@'
            oSheet:Cells( nLine, aXlsFoot[nRow,1]):Value := AllTrim( cTitle )
            cRange :=  HeadXls( aXlsFoot[nRow,1]) + Hb_NtoS( nLine )  + ":" + ;
                       HeadXls( nCol) + Hb_NtoS( nLine )

            oRange := oSheet:Range( cRange )
            If aXlsFoot[nRow,6] != Nil
              oRange:HorizontalAlignment := TbsXlsAlign( aXlsFoot[nRow,6] )
            Else
              oRange:HorizontalAlignment := TbsXlsAlign( DT_CENTER )
            Endif
            oRange:Merge()
            If aXlsFoot[nRow,4] != Nil
              aFont := aXlsFoot[nRow,4]
              aClr  := aXlsFoot[nRow,5]
              oRange:Font:Name := aFont[ 1 ]
              oRange:Font:Size := aFont[ 2 ]
              oRange:Font:Bold := aFont[ 3 ]
              oRange:Font:Color = RGB(aClr[1,1],aClr[1,2],aClr[1,3])
              oRange:Interior:Color := RGB(aClr[2,1],aClr[2,2],aClr[2,3])
            EndIf
         EndIf
         ++nLine
       Next
   EndIf

   // ����� �������
   ++nLine
   ++nLine

   // ���.������� ��� ��������
   cVal := "End table ! - Version (" + oExcel:Version + ") " + ExcelVersion( VAL( oExcel:Version ) )
   cVal += "  Path - " + ExcelPath() + "  +  " + MiniGuiVersion()
   aClr := RED
   oRange := oSheet:Cells( nLine, 1 )
   oRange:Font:Color := RGB(aClr[1],aClr[2],aClr[3])
   oRange:Font:Name  := "Times New Roman"
   oRange:Font:Size  := 16
   oRange:Font:Bold  := .T.
   oRange:Value := cVal
   cRange :=  "A" + HB_NtoS(nLine) + ":" + HeadXls(nColDbf) + HB_NtoS(nLine)
   oRange := oSheet:Range( cRange )
   oRange:Merge()

   If hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, 100, 0 )
   EndIf
   SysRefresh()

   If hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, 0, 0 )
   EndIf

   // ����� �������� ����� ����������� �������
   If bExtern != Nil
      Eval( bExtern, oSheet, aTsb, aXlsTitle)
   EndIf

   // ����� ���������������� �������� ����� ����������� �������
   If bExtern2 != Nil //.and. lFormula
      Eval( bExtern2, oSheet, oExcel, aTsb, nLinecolor)
      // ������ ����� - ����� ������� ������� �������� �� ����� 
      // oExcel:ReferenceStyle := xlR1C1   
   EndIf

   If hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, 0, 0 )
   EndIf

   If ! Empty( cFile ) .and. lSave
      oBook:SaveAs( cFile, xlWorkbookNormal )
   EndIf

   WaitThreadCloseIcon()  // kill the window waiting
   CursorArrow()

   If lActivate
      //� ��� ������ ����� ����� � �������� 77% ?
      oExcel:ActiveWindow:Zoom:= 77
      oExcel:ReferenceStyle := xlA1   // ����� ������� ������� - �����
      oSheet:Range( "A1" ):Select()   // ������� ������� Excel
      oExcel:Visible := .T.           // �������� Excel �� ������
      hWnd := oExcel:hWnd             // ����� ���� Excel
      ShowWindow( hWnd, 6 )           // MINIMIZE windows
      ShowWindow( hWnd, 3 )           // MAXIMIZE windows
      BringWindowToTop( hWnd )        // a window on the foreground
   Else
      oExcel:Application:Quit()       // ������� Excel
   EndIf

   RETURN Nil

* =======================================================================================
// ���������� ��������� �������
FUNCTION NumbColumnsForTbl( oBrw,aColSel)
   LOCAL lIsNotVisible :=.f., Arab, InCol, nCol , lRet
   InCol := If(oBrw:lSelector,2,1)
   If aColSel != Nil .and. Len( aColSel) >0
       LRet := Len(aColSel)
   Else
      lIsNotVisible :=.f.
      For nCol := InCol TO Len( oBrw:aColumns )
         if !oBrw:aColumns[nCol]:lVisible
            lIsNotVisible :=.t.
            Exit
         Endif
      Next
      if lIsNotVisible
         Arab:={}
         For nCol := InCol TO Len( oBrw:aColumns )
            if oBrw:aColumns[nCol]:lVisible
               Aadd(Arab,nCol)
            Endif
         Next
         LRet := Len(Arab)
      else
         LRet := Len(oBrw:aColumns)
      endif
   Endif
RETURN lRet

* =======================================================================================
// ������� ������ �� TSB � XLS
STATIC FUNCTION TbsXlsAlign(nAlign)
   LOCAL nRet := 0

   IF nAlign == DT_LEFT
      nRet := xlHAlignLeft
   ELSEIF nAlign == DT_RIGHT
      nRet := xlHAlignRight
   ELSE
      nRet := xlHAlignCenterAcrossSelection  // DT_CENTER
   ENDIF

   RETURN nRet

* =======================================================================================
// �������� ����� ������� ���: bExtern := {|oSheet,oBrw| ExcelOleExtern(oSheet, oBrw) }
// ������������ Sheet � ������� ����� � ���� ����, ����� �������� �� ������
// Sheet � ��������� ������ � ������ oBrw � ������ �������, �������, �����, ...
// �������� ��� ������ excel.
FUNCTION ExcelOle7Extern( hProgress, oSheet, aTsb, aXlsTitle)
   LOCAL cRange, oRange, nCol, nRow, nBColor, nFColor
   LOCAL nCount, nTotal, nEvery, aFont, nColHead
   LOCAL oldnFColor, aRCnFColor[4], oldaFont[3]
   LOCAL oldnBColor, aRCnBColor[4], aRCaFont[4]
   LOCAL aCol, lEndTabl, oFont, nColDbf, nCell
   LOCAL nLine, lTsbFontTable, lTsbFontHeader
   LOCAL aFontSHF, nBeginTable, nColSh1, nColSh2

   nLine          := 1
   nTotal         := Len(aTsb[4])     // ���������� ����� �������
   nColDbf        := Len(aTsb[4,1])   // ���������� �������
   lTsbFontTable  := .t.              // ������ ����� �������
   lTsbFontHeader := .f.              // ������ ����� ��������� � �������

   // ��������� �������
   If !Empty(aXlsTitle)
      nLine += Len(aXlsTitle)+1
   EndIf

   If hProgress != Nil
      SetProgressBarRange ( hProgress , 1 , nTotal )
      SendMessage(hProgress, PBM_SETPOS, 0, 0)
      nEvery := Max( 1, Int( nTotal * 0.05 ) ) // refresh hProgress every 5 %
   EndIf

   // ������� ����� ����,������ � ������ ����������� �������
   nCell:=0
   // ������� ���������� �������
   If Len(aTsb[1])>0
      nCol :=0
      nColSh2 :=0
      FOR EACH aCol IN aTsb[1]
         nCol++
         nColSh1 := if(aCol[5]>0, aCol[5], nColSh2+1)
         // ����  � -1 �� ��������� � ��������� ����������, �� ����� �� ���������
         if aCol[6]>0.and.nCol<Len(aTsb[1])
       if aTsb[1,nCol+1,5]>0
                nColSh2 := aTsb[1,nCol,5]-1
            endif
         endif
         nColSh2 := if(aCol[6]>0, aCol[6], if(nCol==Len(aTsb[1]), nColDbf, nColSh1))
         cRange :=  HeadXls( nColSh1) + Hb_NtoS( nLine )  + ":" + ;
                    HeadXls( nColSh2) + Hb_NtoS( nLine )
         oSheet:Range( cRange ):HorizontalAlignment  := xlHAlignCenterAcrossSelection
         nFColor := myColorFirst(aCol[1])
         nBColor := myColorFirst(aCol[2])
         oRange := oSheet:Range( cRange )
         oFont :=  oRange:Font
         oFont:Color          := nFColor        // ���� ������ �����
         oRange:Interior:Color:= nBColor        // ���� ����
         If lTsbFontHeader
            aFontSHF := GetFontParam( aCol[3])
            oSheet:Range( cRange ):Font:Name := aFontSHF[ 1 ]
            oSheet:Range( cRange ):Font:Size := aFontSHF[ 2 ]
            oSheet:Range( cRange ):Font:Bold := aFontSHF[ 3 ]
         Endif
      NEXT
      ++nLine
   Endif

   // ������� ����� �������
   If Len(aTsb[2])>0
      nCol :=0
      FOR nColHead:= 1 to Len(aTsb[2])
         nFColor := myColorFirst(aTsb[2,nColHead,1])
         nBColor := myColorFirst(aTsb[2,nColHead,2])
         oRange := oSheet:Cells( nLine, nColHead )
         oFont :=  oRange:Font
         oFont:Color    := nFColor        // ���� ������ �����
         oRange:Interior:Color:= nBColor        // ���� ����
         If lTsbFontHeader
            aFontSHF := GetFontParam( aTsb[2,nColHead,3])
            oSheet:Cells( nLine, nColHead ):Font:Name := aFontSHF[ 1 ]
            oSheet:Cells( nLine, nColHead ):Font:Size := aFontSHF[ 2 ]
            oSheet:Cells( nLine, nColHead ):Font:Bold := aFontSHF[ 3 ]
         Endif
      Next
      ++ nLine
   Endif

   // ��������� �������
   If Len(aTsb[3])>0
      FOR nCol:= 1 to Len(aTsb[3])
         nFColor := myColorFirst(aTsb[3,nCol,1])
         nBColor := myColorFirst(aTsb[3,nCol,2])
         oRange := oSheet:Cells( nLine, nCol)
         oFont :=  oRange:Font
         oFont:Color    := nFColor        // ���� ������ �����
         oRange:Interior:Color:= nBColor        // ���� ����
         If lTsbFontHeader
            aFontSHF := GetFontParam( aTsb[3,nCol,3])
            oSheet:Cells( nLine, nCol ):Font:Name := aFontSHF[ 1 ]
            oSheet:Cells( nLine, nCol ):Font:Size := aFontSHF[ 2 ]
            oSheet:Cells( nLine, nCol ):Font:Bold := aFontSHF[ 3 ]
         Endif
      Next
      ++nLine
   Endif

   // ��������� ������ ������������ ������ ��������� � �������
   nCount     := 0
   oldnFColor := Nil
   oldnBColor := Nil
   aFill(oldaFont,Nil)
   lEndTabl   := .f.

   // ������� ����� ���� � ������ ����� ���� ������� �������//
   nBeginTable := nLine

   FOR nRow:= 1 to nTotal //Len(aTsb[4])
      FOR nColHead:= 1 to nColDbf //Len(aTsb[4,1])
          If nRow == nTotal .and. nColHead == nColDbf
             lEndTabl :=.t. //���� ��������� ������ �������
          Endif

          nFColor := myColorFirst(aTsb[4,nRow,nColHead,1])
          nBColor := myColorFirst(aTsb[4,nRow,nColHead,2])
          if (!oldnFColor == nFColor)
             // ��� ��������� ����� ���� �� ����� ������� ������������ �������
             if !oldnFColor==Nil
                ChangeRangeFontColor( oSheet,oldnFColor, aRCnFColor, ncoldbf )
             Endif
             oldnFColor:=nFColor
             aRCnFColor[1] :=  nLine; aRCnFColor[2] :=  nColHead
          Endif
          aRCnFColor[3] :=  nLine; aRCnFColor[4] :=  nColHead
          If lEndTabl
                ChangeRangeFontColor( oSheet,oldnFColor, aRCnFColor, ncoldbf )
          Endif
          // ��� ������
          if (!oldnBColor == nBColor)
             // ��� ��������� ����� ���� �� ����� ������� ������������ �������
             if !oldnBColor==Nil
                ChangeRangeInterior( oSheet,oldnBColor, aRCnBColor, ncoldbf)
             Endif
             oldnBColor:=nBColor
             aRCnBColor[1] :=  nLine; aRCnBColor[2] :=  nColHead
          Endif
          aRCnBColor[3] :=  nLine; aRCnBColor[4] :=  nColHead
          If lEndTabl
             ChangeRangeInterior( oSheet,oldnBColor, aRCnBColor, ncoldbf)
          Endif
          // ���� ������
          If lTsbFontTable
            aFont := GetFontParam(aTsb[4,nRow,nColHead,3])
            if (!(oldaFont[1] == aFont[1].and.oldaFont[2] == aFont[2].and.oldaFont[3] == aFont[3])).or.lEndTabl
               // ��� ��������� ����� ���� �� ����� ������ ������ �������
               if !oldaFont[1] == Nil
                  ChangeRangeFont( oSheet, oldaFont, aRCaFont, ncoldbf)
               Endif
               oldaFont[1] := aFont[1]; oldaFont[2] := aFont[2]; oldaFont[3] := aFont[3]
               aRCaFont[1] :=  nLine; aRCaFont[2] :=  nColHead
             Endif
             aRCaFont[3] :=  nLine; aRCaFont[4] :=  nColHead
             if lEndTabl
              if !oldaFont[1] == Nil
                    ChangeRangeFont( oSheet, oldaFont, aRCaFont, ncoldbf)
               Endif
            Endif
          Endif
      Next

      If hProgress != Nil
         If nCount % nEvery == 0
            SendMessage(hProgress, PBM_SETPOS,nCount,0)
         EndIf
         nCount ++
      EndIf
      ++nLine
   Next

   // ������� ����� ���� � ������ ������� �������
   If Len(aTsb[5])>0
      FOR nColHead:= 1 to Len(aTsb[5])
         nFColor := myColorFirst(aTsb[5,nColHead,1])
         nBColor := myColorFirst(aTsb[5,nColHead,2])
         oRange := oSheet:Cells( nLine, nColHead )
         oFont :=  oRange:Font
         oFont:Color    := nFColor         // ���� ������ �����
         oRange:Interior:Color:= nBColor   // ���� ����
         If lTsbFontHeader
            aFontSHF := GetFontParam( aTsb[5,nColHead,3])
            oSheet:Cells( nLine, nColHead ):Font:Name := aFontSHF[ 1 ]
            oSheet:Cells( nLine,nColHead ):Font:Size := aFontSHF[ 2 ]
            oSheet:Cells( nLine,nColHead ):Font:Bold := aFontSHF[ 3 ]
         Endif
         // aWidthChars [nCol] := max(aWidthChars [nCol], LenStrokaWithCRLF(uData))
      Next
      nLine++
   Endif

   cRange :=  "A" + HB_NtoS(nBeginTable)+":" + HeadXls(nColDbf) + HB_NtoS(nLine-1)
   oRange:=oSheet:Range(cRange)
   oRange:Columns:AutoFit() // ������������� �������� ������ ���� �������� � ������ ���� �����
                            // � ���������, ����� ���� ��������� ����� �����.
                            // ����� ��������� ������ � ��� ����������, ������� ������� ��
                            // ������ �������� (���������) ��� ������ ����� (����� ���������), ����� ����� ������.


   If hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, 100, 0 )
   EndIf
   SysRefresh()

   RETURN Nil

* =======================================================================================
STATIC FUNCTION ChangeRangeInterior( oSheet,oldnBColor, aRCnBColor, nMaxCol )
   LOCAL cRange, nDif := aRCnBColor[3] - aRCnBColor[1]

   Do case
      case nDif == 0
         cRange := HeadXls(aRCnBColor[2]) + LTrim( Str( aRCnBColor[1]) )+":" + ;
                   HeadXls(aRCnBColor[4]) + LTrim( Str( aRCnBColor[3]) )
         oSheet:Range(cRange):Interior:Color    := oldnBColor  // ��� ������
      case ndif =1
         cRange := HeadXls(aRCnBColor[2]) + LTrim( Str( aRCnBColor[1]) )+":" + ;
                   HeadXls(nMaxCol) + LTrim( Str( aRCnBColor[1]) )
         oSheet:Range(cRange):Interior:Color    := oldnBColor  // ��� ������
         cRange := HeadXls(1) + LTrim( Str( aRCnBColor[3]) )+":" + ;
                   HeadXls(aRCnBColor[4]) + LTrim( Str( aRCnBColor[3]) )
         oSheet:Range(cRange):Interior:Color    := oldnBColor  // ��� ������
      Otherwise
         cRange := HeadXls(aRCnBColor[2]) + LTrim( Str( aRCnBColor[1]) )+":" + ;
                   HeadXls(nMaxCol) + LTrim( Str( aRCnBColor[1]) )
         oSheet:Range(cRange):Interior:Color    := oldnBColor  // ��� ������
         cRange := HeadXls(1) + LTrim(Str( aRCnBColor[1]+1 ))+":" + ;
                   HeadXls(nMaxCol) + LTrim( Str( aRCnBColor[3]-1 ) )
         oSheet:Range(cRange):Interior:Color    := oldnBColor  // ��� ������
         cRange := HeadXls(1) + LTrim( Str( aRCnBColor[3]) )+":" + ;
                   HeadXls(aRCnBColor[4]) + LTrim( Str( aRCnBColor[3]) )
         oSheet:Range(cRange):Interior:Color    := oldnBColor  // ��� ������
   Endcase

RETURN Nil

* =======================================================================================
STATIC FUNCTION ChangeRangeFontColor( oSheet,oldnFColor, aRCnFColor, nMaxCol )
   LOCAL cRange, nDif := aRCnFColor[3] - aRCnFColor[1]

   Do case
      case nDif == 0
         cRange := HeadXls(aRCnFColor[2]) + LTrim( Str( aRCnFColor[1]) )+":" + ;
                   HeadXls(aRCnFColor[4]) + LTrim( Str( aRCnFColor[3]) )
         oSheet:Range(cRange):Font:Color    := oldnFColor  // ��� ������
      case ndif =1
         cRange := HeadXls(aRCnFColor[2]) + LTrim( Str( aRCnFColor[1]) )+":" + ;
                   HeadXls(nMaxCol) + LTrim( Str( aRCnFColor[1]) )
         oSheet:Range(cRange):Font:Color    := oldnFColor  // ��� ������
         cRange := HeadXls(1) + LTrim( Str( aRCnFColor[3]) )+":" + ;
                   HeadXls(aRCnFColor[4]) + LTrim( Str( aRCnFColor[3]) )
         oSheet:Range(cRange):Font:Color    := oldnFColor  // ��� ������
      Otherwise
         cRange := HeadXls(aRCnFColor[2]) + LTrim( Str( aRCnFColor[1]) )+":" + ;
                   HeadXls(nMaxCol) + LTrim( Str( aRCnFColor[1]) )
         oSheet:Range(cRange):Font:Color    := oldnFColor  // ��� ������
         cRange := HeadXls(1) + LTrim(Str( aRCnFColor[1]+1 ))+":" + ;
                   HeadXls(nMaxCol) + LTrim( Str( aRCnFColor[3]-1 ) )
         oSheet:Range(cRange):Font:Color    := oldnFColor  // ��� ������
         cRange := HeadXls(1) + LTrim( Str( aRCnFColor[3]) )+":" + ;
                   HeadXls(aRCnFColor[4]) + LTrim( Str( aRCnFColor[3]) )
         oSheet:Range(cRange):Font:Color    := oldnFColor  // ��� ������
   Endcase

RETURN Nil

* =======================================================================================
STATIC FUNCTION ChangeRangeFont( oSheet, oldaFont, aRCaFont, nMaxCol)
   LOCAL cRange, oFont, nDif := aRCaFont[3] - aRCaFont[1]

   Do case
      case nDif == 0
         cRange :=  HeadXls(aRCaFont[2]) + LTrim( Str( aRCaFont[1]) )+":" + ;
         HeadXls(aRCaFont[4]) + LTrim( Str(aRCaFont[3]) )
         oFont := oSheet:Range(cRange):Font
         oFont:Name := oldaFont[ 1 ]
         oFont:Size := oldaFont[ 2 ]
         oFont:Bold := oldaFont[ 3 ]
      case ndif =1
         cRange :=  HeadXls(aRCaFont[2]) + LTrim( Str( aRCaFont[1]) )+":" + ;
         HeadXls(nMaxCol) + LTrim( Str( aRCaFont[1]) )
         oFont := oSheet:Range(cRange):Font
         oFont:Name := oldaFont[ 1 ]
         oFont:Size := oldaFont[ 2 ]
         oFont:Bold := oldaFont[ 3 ]
         cRange :=  HeadXls(1) + LTrim( Str( aRCaFont[3]) )+":" + ;
         HeadXls(aRCaFont[4]) + LTrim( Str( aRCaFont[3]) )
         oFont := oSheet:Range(cRange):Font
         oFont:Name := oldaFont[ 1 ]
         oFont:Size := oldaFont[ 2 ]
         oFont:Bold := oldaFont[ 3 ]
      Otherwise
         cRange :=  HeadXls(aRCaFont[2]) + LTrim( Str( aRCaFont[1]) )+":" + ;
         HeadXls(nMaxCol) + LTrim( Str( aRCaFont[1]) )
         oFont := oSheet:Range(cRange):Font
         oFont:Name := oldaFont[ 1 ]
         oFont:Size := oldaFont[ 2 ]
         oFont:Bold := oldaFont[ 3 ]
         cRange :=  HeadXls(1) + LTrim(Str( aRCaFont[1]+1 ))+":" + ;
         HeadXls(nMaxCol) + LTrim( Str( aRCaFont[3]-1 ) )
         oFont := oSheet:Range(cRange):Font
         oFont:Name := oldaFont[ 1 ]
         oFont:Size := oldaFont[ 2 ]
         oFont:Bold := oldaFont[ 3 ]
         cRange :=  HeadXls(1) + LTrim( Str( aRCaFont[3]) )+":" + ;
         HeadXls(aRCaFont[4]) + LTrim( Str( aRCaFont[3]) )
         oFont := oSheet:Range(cRange):Font
         oFont:Name := oldaFont[ 1 ]
         oFont:Size := oldaFont[ 2 ]
         oFont:Bold := oldaFont[ 3 ]
   Endcase

RETURN Nil

* =======================================================================================
STATIC FUNCTION myColorFirst(nColor)
   If Valtype( nColor ) == "A"
      nColor := nColor[1]
   EndIf
Return nColor

////////////////////////////////////////////////////////////
STATIC FUNCTION HeadXls(nCol)
RETURN IF(nCol>26,Chr(Int((nCol-1)/26)+64),'')+CHR((nCol-1)%26+65)

/////////////////////////////////////////////////////////////
// ������� �������� ������ Excel
STATIC FUNCTION ExcelVersion(nVer)
   LOCAL aDim[20]
   DEFAULT nVer := 1

   AFILL(aDim,"???")
   aDim[01] := "No Excel on this computer!"
   aDim[09] := "Excel 2000"
   aDim[10] := "Excel XP"
   aDim[11] := "Excel 2003"
   aDim[12] := "Excel 2007"
   aDim[14] := "Excel 2010"
   aDim[15] := "Excel 2013"
   aDim[16] := "Excel 2016"
   aDim[17] := "Excel 2019"
   aDim[18] := "Excel New!"

   RETURN aDim[nVer]

/////////////////////////////////////////////////////////////////
// ������� ���� � Excel
// http://clipper.borda.ru/?1-20-0-00000371-000-0-0-1195742832
// Pasha - ���� N: 645
STATIC FUNCTION ExcelPath()
   LOCAL cPath := NIL
   cPath := win_regRead( "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\excel.exe\Path" )
   Return cPath

/////////////////////////////////////////////////////////////////
STATIC Function PixelToPointX(iPixels)
    Local lngDPI, rPixelToPoint
    lngDPI = GetDPIX()
    rPixelToPoint = (iPixels / lngDPI) * 72
Return rPixelToPoint

/////////////////////////////////////////////////////////////////
STATIC Function PixelToPointY(iPixels)
    Local lngDPI, rPixelToPoint
    lngDPI = GetDPIY()
    rPixelToPoint = (iPixels / lngDPI) * 72
Return rPixelToPoint

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( GETDPIX )
{
   HDC    hDC = GetDC( GetDesktopWindow() );
   hb_retni( ( LONG ) GetDeviceCaps(hDC, LOGPIXELSX) );
   return;
}
HB_FUNC( GETDPIY )
{
   HDC    hDC = GetDC( GetDesktopWindow() );
   hb_retni( ( LONG ) GetDeviceCaps(hDC, LOGPIXELSY) );
   return;
}

#pragma ENDDUMP
