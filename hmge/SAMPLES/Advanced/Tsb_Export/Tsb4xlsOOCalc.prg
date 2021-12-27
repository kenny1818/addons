/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2018-2020 Pavel Tsarenko <tpe2@mail.ru>
 *
*/
#define _HMG_OUTLOG

#define PBM_SETPOS       1026
#define LINE_WRITE       100                // ���������� ����� ��� ������ ������� 

#include "minigui.ch"
#include "tsbrowse.ch"
* =======================================================================================
FUNCTION Brw4OleCalc( oBrw, cFile, lActivate, hProgress, aTitle, hFont, lSave, bExtern )
   LOCAL lTsbSuperHd, lTsbHeading, lTsbFooting, cVal, nCol, nLine, nTotal, nCount, nEvery
   LOCAL nColHead, nColDegTbl, flag_new_OutXls := .f.
   LOCAL aSet, nIndexaSet, uData, aTipeChars
   LOCAL oSM, oSD, oDoc, oDispatch, aProps := {}
   LOCAL oSheet, oRange, nColDbf, nBeginTable
   LOCAL aFont, aClr, aCol, oCol, cMsg, cTitle, nVar, nStart, nRow
   LOCAL nRecNo := ( oBrw:cAlias )->( RecNo() ), nAt := oBrw:nAt
   LOCAL nOldRow := oBrw:nLogicPos(), nOldCol := oBrw:nCell
   Local lBrSelector := oBrw:lSelector
           
   ////////////// ��������� ������ ///////////////
   // nLine := 1  // ����� ������� 
   // nLine := 2  // ������ ������ 
   // nLine := 3  // ���������� �������, ���� ���� 
   // nLine := 4  // ����� �������, ���� ���� 
   // nLine := 5  // ������ �������, ������ ������ (���� ���� ���������� � ����� �������)
   // nLine := nLine + oBrw:nLen // ������ �������, ���� ���� 

   CursorWait()
   WaitThreadCreateIcon( 'Loading the report in', 'OO Calc OLE ...' )   // ������ ��� �������

   IF ( oSM := win_oleCreateObject( "com.sun.star.ServiceManager" ) ) == NIL 
      cMsg := REPLICATE( "-._.", 16 ) + ";;"
      IF Hb_LangSelect() == "ru.RU1251"
         cMsg += "OO Calc �� �������� !;;   ������"
         cVal := "������!"
      ELSE
         cMsg += "OO Calc is not available !;;   Error"
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

   AADD(aProps, oSM:Bridge_GetStruct("com.sun.star.beans.PropertyValue"))
   aProps[1]:Name := "Hidden"
   aProps[1]:Value := .T.
   oSD := oSM:createInstance("com.sun.star.frame.Desktop")
   oDoc := oSD:LoadComponentFromURL( "private:factory/scalc", "_blank", 0, aProps)

   oSheet := oDoc:Sheets:getByIndex(0)
   oDispatch := oSM:createInstance("com.sun.star.frame.DispatchHelper")
   // oDoc:getCurrentController:getFrame:getContainerWindow:setVisible( .f. )

   If oBrw:lSelector  // ���� ���� �������� � �������
      oBrw:aClipBoard := { ColClone( oBrw:aColumns[ 1 ], oBrw ), 1, "" }
      oBrw:DelColumn( 1 )
      oBrw:lSelector := .F.
   EndIf

   // �������� ���������� �������
   lTsbSuperHd := oBrw:lDrawSuperHd
   IF lTsbSuperHd
      lTsbSuperHd := ( AScan( oBrw:aSuperHead, {|a| !Empty(a[3]) } ) > 0 )
      // ���� ���������� ������� ����� ������, �� ��� ������ ����������� �������
      // ������ ���������� ������� � demo2.prg ������ 232 - :aSuperhead[ 1, 3 ] := '' 
   ENDIF

   // �������� ����� �������
   lTsbHeading := oBrw:lDrawHeaders
   If lTsbHeading    
      lTsbHeading := ( AScan( oBrw:aColumns, { |o| !Empty( o:cHeading ) } ) > 0 )
      // ���� ����� ������� ������ ������ �������, �� ��� ������ ����� �������
      // ������ ����� ������� � demo2.prg ������ 266 - oCol:cHeading := '' ��� NIL
   Endif

   // �������� ������� �������
   lTsbFooting := oBrw:lDrawFooters
   If lTsbFooting    
      lTsbFooting := ( AScan( oBrw:aColumns, { |o| !Empty( o:cFooting ) } ) > 0 )
      // ���� ������ ������� ����� ������ �������, �� ��� ������ ������� �������
      // ������ ������ ������� � demo2.prg ������ 269 - oCol:cFooting := '' ��� NIL
   Endif

   // ������� �������, ���� ����
   If hProgress != Nil
      nTotal := oBrw:nLen 
      SetProgressBarRange ( hProgress , 1 , nTotal )
      SendMessage(hProgress, PBM_SETPOS, 0, 0)
      nEvery := Max( 1, Int( nTotal * 0.05 ) ) // refresh hProgress every 5 %
   EndIf
 
   nColDbf := Len( oBrw:aColumns )            // ���-�� �������� � �������
   aSet := Array(Min(LINE_WRITE,oBrw:nLen), nColDbf )
   aTipeChars := Array( nColDbf )

   nLine  := 1
   cTitle := aTitle[1]
   cTitle := AllTrim( cTitle )

   // ��������� �������
   If ! Empty( cTitle )
      SetOOValue( oSheet, nLine++, 1, AllTrim( cTitle ), 2 )
      oRange := OORange( oSheet, 1, 1,, nColDbf )
      oRange:Merge( .t. )
      If aTitle != Nil
        aFont := GetFontParam( aTitle[2] )
        aClr := BLACK
        SetOOFont( oRange, aFont, RGB(aClr[1],aClr[2],aClr[3]) )
      EndIf
      ++nLine
   EndIf
   nColDegTbl := 3  // ��������� ������ ��������� ������� 

   // ������� ���������� �������
   If lTsbSuperHd 

      nVar  := If( oBrw:lSelector, 1, 0 )
      FOR EACH aCol IN oBrw:aSuperHead
         uData := If( ValType( aCol[3] ) == "B", Eval( aCol[3] ), aCol[3] )
         SetOOValue( oSheet, nLine, iif(aCol[1] - nVar>0,aCol[1] - nVar,1), uData )
         oRange := OORange( oSheet, nLine, iif(aCol[1] - nVar>0,aCol[1] - nVar,1),, iif(aCol[2] - nVar>0,aCol[2] - nVar,1) )
         oRange:Merge(.t.)
         oRange:HoriJustify := 2
         SetOOFont( oRange, aFont )
      NEXT
      ++nLine
   Endif

   // ������� ����� �������
   If lTsbHeading     
      nColHead := 0
      FOR EACH oCol IN oBrw:aColumns

         uData := If( ValType( oCol:cHeading ) == "B", Eval( oCol:cHeading ), ;
                               oCol:cHeading )

         If ValType( uData ) != "C"
            Loop
         EndIf

         uData := StrTran( uData, CRLF, Chr( 10 ) )
         nColHead ++
         oRange := SetOOValue( oSheet, nLine, nColHead, uData )
         SetOOFont( oRange, aFont )
      Next
      ++ nLine
   Endif

   Eval( oBrw:bGoTop )  // ������� �� ������ �������
   nCount := 0

   // ������ - ����� ������� ������ !
   nIndexaSet := 1
   nStart := nLine
   nBeginTable := nStart
   For nRow := 1 TO oBrw:nLen
   
      For nCol := 1 TO nColDbf

         oCol  := oBrw:aColumns[ nCol ]
         uData := oBrw:GetValue( nCol )
         If oCol:cPicture != Nil .and. uData != Nil
            uData := Transform( uData, oCol:cPicture )
         EndIf

         // ���������� ��� ���� � �������
         If Empty(aTipeChars[nCol]) .and. !Empty(uData )
        aTipeChars[nCol] := ValType( uData )
             //��� ����� ������� ������� Excel �� ���� ������ ������� oBrw
             IF aTipeChars[nCol] =='C'
             // ��� ������ ���������� �����, ��� ������������� ����� ��������� ��� ��� ������ �����
               oRange := OORange( oSheet, nBeginTable, nCol, oBrw:nLen+nBeginTable-1, nCol )
             ENDIF
    Endif
         uData := If( ValType( uData )=="D", DtoC( uData ), If( ValType( uData )=="N", Str( uData ), ;
                  If( ValType( uData )=="L", If( uData ,".T." ,".F." ), cValToChar( uData ) ) ) )

         // ������ ������� � �������� � ������ �������� ������ �� ������� ������� CHR(10)
         //         aWidthChars [nCol] := max(aWidthChars [nCol], LenStrokaWithCRLF(uData))

         // ���������� ������ � ������
         aSet[ nIndexaSet , nCol ] := uData 

      Next

      IF (nIndexaSet == LINE_WRITE).or.(nRow == oBrw:nLen) // �� ���������� ������� ��� ����� �������
   flag_new_OutXls := .t. // ������ �������� - ����� ���������� � ������� � Excel
      ENDIF

      ++nLine

      // ���������� ������� �� LINE_WRITE ����� �� ������������ �������� 
      IF flag_new_OutXls

         oRange := OORange( oSheet, nStart, 1, nLine-1, nColDbf )
         if Len( aSet ) > nLine - nStart
            ASize(aSet, nLine - nStart )       // ��������� ����
         endif
         oRange:setDataArray( aSet )
         // oSheet:getRows():getByIndex(nStart-1):OptimalHeight := .t.
         // oRange:OptimalHeight := .t.

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

      oBrw:Skip(1)
   Next

   // ������� ������ �������
   If lTsbFooting
      For nCol := 1 To nColDbf

         oCol := oBrw:aColumns[ nCol ]
         uData := If( ValType( oCol:cFooting ) == "B", Eval( oCol:cFooting ), ;
                               oCol:cFooting )
         uData := cValTochar( uData )
         uData := StrTran( uData, CRLF, Chr( 10 ) )
         oRange := SetOOValue( oSheet, nLine, nCol, uData )
         aFont := GetFontParam( aTitle[2] )
         SetOOFont( oRange, aFont )
      Next
      nLine++
   Endif

   If hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, 100, 0 )
   EndIf
   SysRefresh()

   // ����� ������ ������� � �������
   oRange := OORange( oSheet, nBeginTable, 1, oBrw:nLen+nBeginTable-1, nColDbf )
   aFont := GetFontParam( hFont )
   SetOOFont( oRange, aFont )

   // ������� ����� �� �������
   oRange := OORange( oSheet, nColDegTbl, 1, nLine-1, nColDbf )
   OOCellBorder( oRange, 7 )
   OOCellBorder( oRange, 8 )
   OOCellBorder( oRange, 9 )
   OOCellBorder( oRange, 10 )
   OOCellBorder( oRange, 11 )
   OOCellBorder( oRange, 12 )

   // ����� ����� ������ ����������� �������: ��������� ������� ��� �������� � �.�.

   If hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, 0, 0 )
   EndIf

   If bExtern != Nil  
      Eval( oBrw:bGoTop )  // ������� �� ������ �������
      Eval( bExtern, oSheet, oBrw )   // ����� �������� ����� ����������� �������
   EndIf

   If lBrSelector  // ���� ���� �������� � �������
      oBrw:lSelector := .T.  
      oBrw:InsColumn( oBrw:aClipBoard[ 2 ], oBrw:aClipBoard[ 1 ] ) 
      oBrw:lNoPaint  := .F.
   EndIf

   // ������� �������������� ������� ������� � �������
   oBrw:Reset()
   If oBrw:lIsDbf
      ( oBrw:cAlias )->( DbGoTo( nRecNo ) )
      oBrw:GoPos(nOldRow, nOldCol)
   EndIf
   oBrw:nAt := nAt

   If hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, 0, 0 )
   EndIf

   for nCol := 1 to nColDbf
      oRange := oSheet:getColumns():getByIndex(nCol-1)
      oRange:OptimalWidth := .t.
      oRange:IsTextWrapped := .t.
   next

   If ! Empty( cFile ) .and. lSave
      oDoc:StoreAsURL( ConvFileOO( cFile ), {})
   EndIf

   WaitThreadCloseIcon()  // kill the window waiting
   CursorArrow()

   If lActivate
      oDoc:getCurrentController:getFrame:getContainerWindow:setVisible( .t. )
      SetCalcWindowToForeground(cFile)
   Else
     oDoc:close(.t.) // ������� Calc
   EndIf

   RETURN Nil

* =======================================================================================
Static func SetOOValue( oSheet, nRow, nCol, cValue, nAlign )
   Local oRange := oSheet:getCellByPosition( nCol-1, nRow-1 )
   if cValue # nil
      oRange:SetString( cValue )
   endif
   if nAlign # nil
      oRange:HoriJustify := nAlign
   endif
   Return oRange

* =======================================================================================
Static func OORange( oSheet, nRow1, nCol1, nRow2, nCol2)
   Return oSheet:getCellRangeByPosition( nCol1-1, nRow1-1, nCol2-1, if(nRow2==nil, nRow1, nRow2) - 1)

* =======================================================================================
Static func SetOOFont( oRange, aFont, nRGB )
   oRange:CharFontName := aFont[ 1 ]
   oRange:CharHeight := aFont[ 2 ]
   if aFont[ 3 ]
      oRange:CharWeight := 150
   endif
   if nRGB # nil
      oRange:CharColor := nRGB
   endif
   Return nil

* =======================================================================================
Static func ConvFileOO(cFile)
   cFile := StrTran(cFile, "\", "/")
   cFile := StrTran(cFile, " ", "%20")
   cFile := "file:///" + cFile
   Return cFile

* =======================================================================================
Function OOCellBorder(oRange, nNSEW, nWidth)
   Local oBorder := oRange:TableBorder
   Local oLine

   if nNSEW == 8
      oLine := oBorder:TopLine
   elseif nNSEW == 9
      oLine := oBorder:BottomLine
   elseif nNSEW == 10
      oLine := oBorder:RightLine
   elseif nNSEW == 7
      oLine := oBorder:LeftLine
   elseif nNSEW == 11
      oLine := oBorder:VerticalLine
   elseif nNSEW == 12
      oLine := oBorder:HorizontalLine
   endif
   if nNSEW < 11
      oLine:OuterLineWidth := if(nWidth == nil, 10, nWidth)
   else
      oLine:InnerLineWidth := if(nWidth == nil, 10, nWidth)
   endif

   if nNSEW == 8
      oBorder:TopLine := oLine
   elseif nNSEW == 9
      oBorder:BottomLine := oLine
   elseif nNSEW == 10
      oBorder:RightLine := oLine
   elseif nNSEW == 7
      oBorder:LeftLine := oLine
   elseif nNSEW == 11
      oBorder:VerticalLine := oLine
   elseif nNSEW == 12
      oBorder:HorizontalLine := oLine
   endif

   oRange:TableBorder := oBorder
   Return nil

//////////////////////////////////////////////////////////////////////
// ���� Calc ��� LibreOffice �� �������� ���� 
STATIC FUNCTION SetCalcWindowToForeground(cFile)
   LOCAL hWnd, cTitle, cText := hb_FNameNameExt(cFile)

   // ������� 1
   hWnd := myGetWindowHandles(cText, .F.)  // ����� �� ������ ���� ���� � ������

   IF hWnd == 0  
     // ������� 2
     //  ����� ������ ��������� ���� ��������� 
     cTitle := cText + " - OpenOffice Calc"
     hWnd := FindWindowEx(,,, cTitle )    
     IF hWnd == 0
        MsgStop("�� ����� ����: " + cTitle, "Error")
     ENDIF
   ENDIF

   IF hWnd > 0
      ShowWindow( hWnd, 6 )      // MINIMIZE windows
      ShowWindow( hWnd, 3 )      // MAXIMIZE windows
      BringWindowToTop( hWnd )   // A window on the foreground
   ENDIF
  
   RETURN NIL

* ======================================================================
* ������������� EnumWindows - ������ ���� �������� � ������
* Using EnumWindows - a list of program windows in memory
FUNCTION myGetWindowHandles(cText, lLogOut)     
LOCAL nI, hWnd := 0, ahWnd := EnumWindows()  

   IF ! Empty(lLogOut) 
      FOR nI := 1 TO Len(ahWnd) 
         ? nI, , ahWnd[ nI ], GetClassName(ahWnd[ nI ]), GetWindowText(ahWnd[ nI ]) 
      NEXT 
   ENDIF

   cText := UPPER(cText) 
   FOR nI := 1 TO Len(ahWnd) 
      IF cText $ UPPER( GetWindowText(ahWnd[ nI ]) )
         //? nI, , ahWnd[ nI ], GetClassName(ahWnd[ nI ]), GetWindowText(ahWnd[ nI ]) 
         hWnd := ahWnd[ nI ]
      ENDIF
   NEXT 

RETURN hWnd 

