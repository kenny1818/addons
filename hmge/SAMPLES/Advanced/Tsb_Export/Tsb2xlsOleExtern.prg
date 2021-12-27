/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2018 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
*/
#define _HMG_OUTLOG

#include "minigui.ch"
#include "tsbrowse.ch"

#define PBM_SETPOS       1026

* =======================================================================================
// �������� ����� ������� ���: bExtern := {|oSheet,oBrw| ExcelOleExtern(oSheet, oBrw) }
// ������������ Sheet � ������� ����� � ���� ����, ����� �������� �� ������ 
// Sheet � ��������� ������ � ������ oBrw � ������ �������, �������, �����, ...
// �������� ��� ������ excel.
FUNCTION ExcelOleExtern( hProgress, lTsbFont, oSheet, oBrw )
   LOCAL nLine, nCol, nRow, aFColor, nBColor, nFColor, nStart, nVar
   LOCAL nCount, nTotal, nEvery, aFont, oCol, hFont//, nI
   LOCAL aCol, cRange
   LOCAL oRange, oFont
   Local lBrSelector := oBrw:lSelector

   // nLine := 1  // ����� ������� 
   // nLine := 2  // ������ ������ 
   // nLine := 3  // ���������� �������, ���� ���� 
   // nLine := 4  // ����� �������, ���� ���� 
   // nLine := 5  // ������ �������, ������ ������ (���� ���� ���������� � ����� �������)
   // nLine := nLine + oBrw:nLen // ������ �������, ���� ���� 

   // ���� ������ ����� �������
   aFColor := BLUE
   nLine := 1  
   oSheet:Cells( nLine, 1):Font:Color := RGB(aFColor[1],aFColor[2],aFColor[3])   

   nStart := 2

   // ������� ����� ���� � ������ ����������� �������
   If oBrw:lDrawSuperHd //! Empty( oBrw:aSuperHead )

      nLine := 3  // ���������� �������, ���� ���� 

      nVar   := If( oBrw:lSelector, 1, 0 )
      For nCol := 1 To Len( oBrw:aSuperHead )
          aCol   := oBrw:aSuperHead[ nCol ]
          cRange :=  HeadXls( iif(aCol[1] - nVar>0,aCol[1] - nVar,1) ) + Hb_NtoS( nLine )  + ":" + ;
                     HeadXls( iif(aCol[2] - nVar>0,aCol[2] - nVar,1) ) + Hb_NtoS( nLine ) 
          nFColor := myColorN( aCol[4], oBrw, nCol )             // oBrw:nClrSpcHdFore
          nBColor := myColorN( aCol[5], oBrw, nCol )             // oBrw:nClrSpcHdBack
          aFont   := GetFontParam( aCol[7] )                     // ����� �����������
          oRange := oSheet:Range( cRange )
          oFont :=  oRange:Font
          oFont:Color    := nFColor        // ���� ������ �����
          oRange:Interior:Color:= nBColor        // ���� ����
          If lTsbFont 
            oFont:Name := aFont[ 1 ]
            oFont:Size := aFont[ 2 ]
            oFont:Bold := aFont[ 3 ]
          Endif
      Next

      nLine++
      nStart := nLine
   EndIf

   // ������� ����� ���� � ������ ����� �������
   If oBrw:lDrawHeaders    

      nLine := nStart

      For nCol := 1 TO Len( oBrw:aColumns )
          oCol    := oBrw:aColumns[ nCol ]
          nFColor := myColorN( oCol:nClrHeadFore, oBrw, nCol ) 
          nBColor := myColorN( oCol:nClrHeadBack, oBrw, nCol ) 

          oRange := oSheet:Cells( nLine, nCol )
          oFont :=  oRange:Font
          oFont:Color    := nFColor        // ���� ������ �����
          oRange:Interior:Color:= nBColor        // ���� ����
          If lTsbFont 
            hFont := oCol:hFontHead              // ����� ����� �������
            aFont := myFontParam( hFont, oBrw, nCol, 0 )
            oFont:Name := aFont[ 1 ]
            oFont:Size := aFont[ 2 ]
            oFont:Bold := aFont[ 3 ]
          Endif

      Next

      nStart := nLine
   Endif

   If hProgress != Nil
      nTotal := oBrw:nLen 
      SetProgressBarRange ( hProgress , 1 , nTotal )
      SendMessage(hProgress, PBM_SETPOS, 0, 0)
      nEvery := Max( 1, Int( nTotal * 0.05 ) ) // refresh hProgress every 5 %
   EndIf

   If oBrw:lSelector
      oBrw:lSelector := .F.
   EndIf

   Eval( oBrw:bGoTop )  // ������� �� ������ �������
   nCount := 0

   // ������� ����� ���� � ������ ����� ���� ������� �������
   For nLine := 1 TO oBrw:nLen

      nRow := nStart + nLine

      For nCol := 1 TO Len( oBrw:aColumns )
          oCol    := oBrw:aColumns[ nCol ] 
          nFColor := myColorN( oCol:nClrFore, oBrw, nCol, oBrw:nAt ) 
          nBColor := myColorN( oCol:nClrBack, oBrw, nCol, oBrw:nAt ) 
 
          oRange := oSheet:Cells( nRow, nCol )
          oFont :=  oRange:Font
          oFont:Color    := nFColor        // ���� ������ �����
          oRange:Interior:Color:= nBColor        // ���� ����
          If lTsbFont 
            aFont := myFontParam( oCol:hFont, oBrw, nCol, oBrw:nAt )
            oFont:Name := aFont[ 1 ]
            oFont:Size := aFont[ 2 ]
            oFont:Bold := aFont[ 3 ]
          Endif

      Next

      If hProgress != Nil

         If nCount % nEvery == 0
            SendMessage(hProgress, PBM_SETPOS,nCount,0)
         EndIf

         nCount ++
      EndIf

      oBrw:Skip(1)
   Next
 
   nStart := nRow + 1

 
   // ������� ����� ���� � ������ ������� �������
   If oBrw:lDrawFooters

      nLine := nStart

      For nCol := 1 TO Len( oBrw:aColumns )
          oCol    := oBrw:aColumns[ nCol ] 
          nFColor := myColorN( oCol:nClrFootFore, oBrw, nCol, oBrw:nAt ) 
          nBColor := myColorN( oCol:nClrFootBack, oBrw, nCol, oBrw:nAt ) 

          oRange := oSheet:Cells( nLine, nCol )
          oFont :=  oRange:Font
          oFont:Color    := nFColor        // ���� ������ �����
          oRange:Interior:Color:= nBColor        // ���� ����
          If lTsbFont 
            aFont := myFontParam( oCol:hFontFoot, oBrw, nCol, 0 )
            oFont:Name := aFont[ 1 ]
            oFont:Size := aFont[ 2 ]
            oFont:Bold := aFont[ 3 ]
          Endif
   
      Next

      nLine++                          
      nStart := nLine
   Endif

   // ���.������� ��� ��������
   nLine := nStart + 1
   aFColor := RED
   oRange := oSheet:Cells( nLine, 1)
   oRange:Font:Color := RGB(aFColor[1],aFColor[2],aFColor[3])   
   oRange:Value := "End table !" 

   If lBrSelector
      oBrw:lSelector := .T.  
   EndIf

   RETURN Nil

* =======================================================================================
STATIC FUNCTION myColorN( nColor, oBrw, nCol, nAt )

   If Valtype( nColor ) == "B"
      If empty(nAt) 
         nColor := Eval( nColor, nCol, oBrw )
      Else
         nColor := Eval( nColor, nAt, nCol, oBrw )
      EndIf
   EndIf  

   If Valtype( nColor ) == "A"
      nColor := nColor[1]
   EndIf  

RETURN nColor

* =======================================================================================
STATIC FUNCTION myFontParam( hFont, oBrw, nCol, nAt )
   LOCAL aFont, oCol := oBrw:aColumns[ nCol ] 
   DEFAULT nAt := 0
   // ����� ����� �������
   hFont := If( hFont == Nil, oBrw:hFont, hFont )  
   hFont := If( ValType( hFont ) == "B", Eval( hFont, nAt, nCol, oBrw ), hFont )  

   If empty(hFont)
      aFont    := array(3) 
      aFont[1] := _HMG_DefaultFontName
      aFont[2] := _HMG_DefaultFontSize
      aFont[3] := .F.
   Else
      aFont := GetFontParam( hFont )
   EndIf

RETURN aFont

* =======================================================================================
STATIC FUNCTION HeadXls(nCol)
RETURN IF(nCol>26,Chr(Int((nCol-1)/26)+64),'')+CHR((nCol-1)%26+65)
