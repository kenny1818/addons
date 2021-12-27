/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2018 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
*/
#define _HMG_OUTLOG

#include "minigui.ch"

* =======================================================================================
FUNCTION BrwDllXlsOle( oBrw, cFile, lActivate, lSaveFile, aImage )
   LOCAL lTsbSuperHd, lTsbHeading, lTsbFooting, nLine, cTitle, cTitle2, uData, aParam
   LOCAL aTTitle, aTTitle2, aTTitle3, aTSuperHd, aTHeading, aTFooting, aDim, nEnd
   LOCAL aColSel, nColTsb, cMerge, aFont, aColor, aCol, cData, nStart, aLine
   LOCAL aTCell, aTCellType, aStru, nRow, nCol, oCol, nFColor, nBColor, nSltr
   LOCAL nOldRec := iif( oBrw:lIsDbf, ( oBrw:cAlias )->( RecNo() ), oBrw:nAt )
   LOCAL nOldRow := oBrw:nLogicPos(), nOldCol := oBrw:nCell
   Default lActivate := .T., lSaveFile := .F. , aImage := {}

   ////////////// ��������� ������ ///////////////
   // nLine := 1        // ����� ������� aTsbTitle
   // nLine := 2        // ������ ������ - ������ aTsbTitle2
   // nLine := 3,4,...  // ������� ��� ������� ������� - ������ aTsbTitle2
   // nLine := ??       // ������ ������ - ������ aTsbTitle2
   // nLine := ??       // ���������� �������, ���� ���� 
   // nLine := ??       // ����� �������, ���� ���� 
   // nLine := ??       // ������ �������, ������ ������ (���� ���� ���������� � ����� �������)
   // nLine := nLine + oBrw:nLen // ������ �������, ���� ���� 
   // nLine := ??,??,...  // ������� ��� ��������, ���� ���� ������ aTsbTitleFoot

   CursorWait()

   oBrw:GoTop()
   oBrw:GoPos( oBrw:nRowPos, oBrw:nFreeze+1 )  // ������� ��� � ������� ������� �������
   DO EVENTS

   // ������ ������� ������ ������� ������� 
   aColSel   := nil  
   //aColSel := { 2,3,4,5,6,7,8,9,10 } // ������ ������� ������� (����� �������� ������� �������)
   // ���� aColSel == nil �� �� ���������� ��������� � ������� �������
   if aColSel = Nil .or. Len(aColSel) = 0
     aColSel := CalcAcolselForTbl( oBrw,aColSel)
   Endif
   nColTsb := Len(aColSel)  // ��������� ������ ������������ �������

   // �������� �������
   hb_MemoWrit("���_1��������.dim", hb_ValToExp( aImage )) 

   // ��������� �������
   cMerge   := "A1:" + Chr( IIF(nColTsb > 26, 90, 64 + nColTsb) ) + '1'
   cTitle   := "Example of exporting a table (TITLE OF THE TABLE)"
   aFont    := { "Arial", 18, .T. , .T. }           // ����/������/bold/italic
   aColor   := { BLUE , WHITE }                     // ����/���
   aTTitle  := { cTitle, cMerge, aFont, aColor }    // ����� � ����
? "// ��������� �������"
?v aTTitle
   hb_MemoWrit("���_2���������.dim", hb_ValToExp( aTTitle )) 

   // ������������ �������
   cTitle   := "Table subtitle (output example)"
   cTitle2  := "File - " + cFile
   cMerge   := Chr( IIF(nColTsb > 26, 90, 64 + nColTsb) ) 
   aColor   := { BLACK , WHITE }             // ����/���
   aTTitle2 := {}   
   AADD( aTTitle2, {} )   // A2:
   AADD( aTTitle2, { cTitle , "A3:" + cMerge + '3', { "Arial", 14, .f. , .f. }, aColor } )
   AADD( aTTitle2, { cTitle2, "A4:" + cMerge + '4', { "Arial", 14, .f. , .f. }, aColor } ) 
   AADD( aTTitle2, {} )   // A5:
   ? "// ������������ �������"
   ?v aTTitle2
   aDim := CtoA( AtoC( aTTitle2 ) )
   hb_MemoWrit("���_3������������.dim", hb_ValToExp( aDim )) 

   nLine := 1 + LEN(aTTitle2) // ��������� ������ ������� 

   // �������� ���������� �������
   lTsbSuperHd := oBrw:lDrawSuperHd
   IF lTsbSuperHd
      lTsbSuperHd := ( AScan( oBrw:aSuperHead, {|a| !Empty(a[3]) } ) > 0 )
   ENDIF
   aTSuperHd := {}
   // ������� ���������� �������
   If lTsbSuperHd 
      aFont     := { "Arial", 12, .f. , .f. }  
      aColor    := { BLACK , SILVER }                // ����/���
      // ��� ����� ����� ���� � ���� � �������
      For nCol := 1 To Len( oBrw:aSuperHead )
         aCol    := oBrw:aSuperHead[ nCol ]
         nFColor := myColorN( aCol[4], oBrw, nCol )   // oBrw:nClrSpcHdFore
         nBColor := myColorN( aCol[5], oBrw, nCol )   // oBrw:nClrSpcHdBack
         aFont   := GetFontParam( aCol[7] )           // ���� �����������
      Next
      aColor := { nFColor , nBColor }                

      FOR EACH aCol IN oBrw:aSuperHead
         cData  := If( ValType( aCol[3] ) == "B", Eval( aCol[3] ), aCol[3] )
         nStart := MaxNumFromArr(aColSel,aCol[1])
         nEnd   := MinNumFromArr(aColSel,aCol[2])
         AADD( aTSuperHd, { nStart, nEnd, cData, aFont, aColor } )
      NEXT

      nLine ++
   ENDIF
   ? "// ���������� �������"
   ?v aTSuperHd
   aDim := CtoA( AtoC( aTSuperHd ) )
   hb_MemoWrit("���_4C���������.dim", hb_ValToExp( aDim )) 

   // �������� ����� �������
   lTsbHeading := oBrw:lDrawHeaders
   IF lTsbHeading    
      lTsbHeading := ( AScan( oBrw:aColumns, { |o| !Empty( o:cHeading ) } ) > 0 )
   ENDIF
   aTHeading := {}
   // ������� ����� �������
   IF lTsbHeading     
      aFont     := { "Arial", 12, .t. , .f. }  
      aColor    := { BLACK , SILVER }                // ����/���

      FOR EACH nCol IN aColSel
         oCol  := oBrw:aColumns[ nCol ]

         cData := If( ValType( oCol:cHeading ) == "B", Eval( oCol:cHeading ), ;
                               oCol:cHeading )

         If ValType( cData ) != "C"
            Loop
         EndIf

         // ��� ����� ����� ���� � ���� � �������
         nFColor := myColorN( oCol:nClrHeadFore, oBrw, nCol ) 
         nBColor := myColorN( oCol:nClrHeadBack, oBrw, nCol ) 
         aColor  := { nFColor, nBColor }
         aFont   := myFontParam( oCol:hFontHead, oBrw, nCol, 0 ) // ����� ����� �������

         cData := StrTran( cData, CRLF, Chr( 10 ) )
         AADD( aTHeading, { cData, aFont, aColor } )
      Next
      nLine ++
   ENDIF
   ? "// ����� �������"
   ?v aTHeading
   hb_MemoWrit("���_4������������.dim", hb_ValToExp( aTHeading )) 

   // �������� ������� �������
   lTsbFooting := oBrw:lDrawFooters
   If lTsbFooting    
      lTsbFooting := ( AScan( oBrw:aColumns, { |o| !Empty( o:cFooting ) } ) > 0 )
   Endif
   aTFooting := {}
   // ������� ������ �������
   If lTsbFooting
      aFont     := { "Arial", 12, .t. , .f. }  
      aColor    := { BLACK , SILVER }                // ����/���

      For EACH nCol IN aColSel
         oCol := oBrw:aColumns[ nCol ]
         cData := If( ValType( oCol:cFooting ) == "B", Eval( oCol:cFooting ), ;
                               oCol:cFooting )

         // ��� ����� ����� ���� � ���� � �������
         nFColor := myColorN( oCol:nClrHeadFore, oBrw, nCol ) 
         nBColor := myColorN( oCol:nClrHeadBack, oBrw, nCol ) 
         aColor  := { nFColor, nBColor }
         aFont   := myFontParam( oCol:hFontFoot, oBrw, nCol, 0 ) // ����� ������� �������

         cData := cValTochar( cData )
         cData := StrTran( cData, CRLF, Chr( 10 ) )
         AADD( aTFooting, { cData, aFont, aColor } )

      Next
      nLine++
   Endif
   ? "// ������ �������"
   ?v aTFooting
   hb_MemoWrit("���_5�������������.dim", hb_ValToExp( aTFooting )) 

   // ������� ��� ��������
   cTitle   := "Signature below the table (output example)"
   cTitle2  := "File - " + cFile
   aColor   := { RED , WHITE }             // ����/���
   aTTitle3 := {}   
   AADD( aTTitle3, { "" } )   
   AADD( aTTitle3, { cTitle , { "Arial", 14, .f. , .f. }, aColor } )
   AADD( aTTitle3, { cTitle2, { "Arial", 14, .f. , .f. }, aColor } ) 
   AADD( aTTitle3, { "" } )   
   ? "// ������� ��� ��������"
   ?v aTTitle3
   aDim := CtoA( AtoC( aTTitle3 ) )
   hb_MemoWrit("���_6�����������.dim", hb_ValToExp( aDim )) 

   // ������ ������� 
   nSltr := IIF(oBrw:lSelector,1,0) // ���� ���� Selector
   aTCell := {}
   For nRow := 1 TO oBrw:nLen

      aLine := {}
      For nCol := 1 + nSltr TO LEN( aColSel )
         oCol     := oBrw:aColumns[ nCol ]
         uData    := oBrw:GetValue( nCol )
         AADD( aLine,  uData )  // ���������� ������ � ������
      Next

      AADD(aTCell, aLine ) 
      oBrw:Skip(1)
   Next
   ? "// ������ �������"
   ?v aTCell
   hb_MemoWrit("���_7�������������.dim", hb_ValToExp( aTCell )) 

   // ������� �������������� ������� ������� 
   oBrw:Reset()
   If oBrw:lIsDbf
      ( oBrw:cAlias )->( DbGoTo( nOldRec ) )
   Else      
      oBrw:GoPos( nOldRow, nOldCol )
   Endif

   aStru := Tsb_Struct( oBrw )  // ��������� ��������� �������

   aTCellType := {}
   For nCol := 1 TO LEN( aStru )
      AADD( aTCellType, { aStru[nCol,2], aStru[nCol,3], aStru[nCol,4] }  )  
   Next
   ? "// ��� � ������ ������� �������"
   ?v aTCellType
   hb_MemoWrit("���_8�����������������������.dim", hb_ValToExp( aTCellType )) 

   //nRetVal :=  HMG_CallDLL( "NIRCMD.DLL", HB_DYN_CTYPE_BOOL, "DoNirCmd", cCommand )
   //nRetVal := HMG_CallDLL("User32", NIL, "ChangeWindowMessageFilterEx", nHWnd, nMsg, nAction, 0)
   // CallDll32( "RMC_DRAW2PRINTER", "RMCHART.DLL", ID_CHART_2, RMC_LANDSCAPE, 10, 10, 220, 150, RMC_EMFPLUS ) 

   aParam := { aTTitle, aTTitle2, aTSuperHd, aTHeading, aTFooting, aTTitle3, aTCell, aTCellType }
   ? "// ������ c#"
   ? 'CallDLL( "lib32_c#xlsole.dll" , , "RunExcelOle" , '+cFile+', '+cValToChar(lActivate)+', aParam )'
   //????CallDLL( "lib32_c#xlsole.dll" , , "RunExcelOle" , cFile, lActivate, aParam ) 

   If lActivate .And. FILE(cFile)
      ShellExecute( 0, "Open", cFile,,, 3 )
   EndIf

   CursorArrow()

   RETURN Nil

* =======================================================================================
FUNCTION Tsb_Struct( oBrw )
   LOCAL oTyp := oKeyData(), nCnt, nCol, nLine, cLine, a, i
   LOCAL oLen := oKeyData(), oDec := oKeyData(), oCol, nFld
   LOCAL oFld := oKeyData(), oIss := oKeyData(), oVal := oKeyData()
   LOCAL nOldRec := iif( oBrw:lIsDbf, ( oBrw:cAlias )->( RecNo() ), oBrw:nAt )
   LOCAL nOldRow := oBrw:nLogicPos(), xVal, cPic, cCol, cTmp, aStru
   LOCAL nOldCol := oBrw:nCell, cTyp, nLen, nDec, aIss, cFld, nSkip
   LOCAL cFileDbf, cPref := 'FLD_' 
   //LOCAL nPos, aFld, aTyp, aLen, aDec

   WITH OBJECT oBrw
   nFld := nCol := 0 
   FOR EACH oCol IN :aColumns  
       nCol++
       // �������� �� ������ � ���������  
       If nCol == 1 .and. :lSelector; LOOP  
       ElseIf ! oCol:lVisible       ; LOOP  
       ElseIf oCol:lBitMap          ; LOOP  
       EndIf  
       nFld++  
       oCol:cField    := cPref + hb_ntos(nFld)  
       oCol:cFieldTyp := ''  
       oCol:nFieldLen := 0  
       oCol:nFieldDec := 0  
       oIss:Set(nFld, .F.)  
       oFld:Set(nFld, oCol:cField)  
       oTyp:Set(nFld, '') 
       oLen:Set(nFld, 0)  
       oDec:Set(nFld, 0)  
   NEXT  

   Eval( :bGoTop )
   nCnt   := :nLen
   nLine  := 1
   DO WHILE nLine <= nCnt
      nFld  := 0
      cLine := hb_ntos(nLine)
      FOR nCol := 1  To Len( :aColumns )
          oCol := :aColumns[ nCol ]
          // �������� �� ������ � ���������
          If nCol == 1 .and. :lSelector; LOOP
          ElseIf ! oCol:lVisible       ; LOOP
          ElseIf oCol:lBitMap          ; LOOP
          EndIf
          nFld++
          cCol   := hb_ntos(nFld)
          xVal   := :bDataEval( oCol, , nCol )
          cFld   := oCol:cField
          cTyp   := ValType( xVal )
          nLen   := 0
          nDec   := 0
          cPic   := oCol:cPicture
          cPic   := iif( HB_ISBLOCK(cPic), EVal(cPic, :nAt, nCol, oBrw), cPic )
          If     cTyp == 'C'
             nLen := Len(xVal)
             If CRLF $ xVal
                cTyp := 'M'
                nLen := 10
             EndIf
          ElseIf cTyp == 'N'
             If empty(cPic)
                cPic := hb_ntos(xVal)
             EndIf
             If ( i := RAt('.', cPic) ) > 0
                nDec:= Len(cPic) - i
             EndIf
             nLen := Len(cPic)
          ElseIf cTyp == 'D'
             nLen := 8
          ElseIf cTyp == 'L'
             nLen := 1
          ElseIf cTyp == 'U'
          EndIf
          oVal:Set(cLine + '.' + cCol, xVal)
          cTmp := oTyp:Get(nFld, '')
          If ! cTyp $ cTmp
             oTyp:Set(nFld, cTmp + cTyp)
          EndIf
          oLen:Set(nFld, Max( oLen:Get(nFld, 0), nLen ))
          oDec:Set(nFld, Max( oDec:Get(nFld, 0), nDec ))
          oIss:Set(nFld, .T.)
      NEXT
      nLine++
      nSkip := :Skip(1)
      DO EVENTS
      IF nSkip == 0
         EXIT
      ENDIF
   ENDDO
   // ������� �������������� ������� ������� 
   :GotoRec(nOldRec) 
   :GoPos( nOldRow, nOldCol ) 
   :Display()
   END WITH

   aIss  := oIss:GetAll(.F.)
   aStru := {}

   FOR EACH a IN aIss
       nCol := a[1]
       If ! a[2]; LOOP
       EndIf
       oCol := oBrw:aColumns[ nCol ]
       cFld := oFld:Get(nCol)
       cTyp := oTyp:Get(nCol)
       nLen := oLen:Get(nCol)
       nDec := oDec:Get(nCol)
       If 'U' $ cTyp
          cTyp := StrTran(cTyp, 'U', '')
       EndIf
       If     'M' $ cTyp
          cTyp := 'M'
          nLen := 10
          nDec :=  0
       ElseIf Len(cTyp) > 1
          cTyp := 'C'
          nDec :=  0
       ElseIf cTyp == 'N'
          nLen +=  3
       ElseIf cTyp == 'D'
          nLen :=  8
          nDec :=  0
       ElseIf cTyp == 'L'
          nLen :=  1
          nDec :=  0
       ElseIf cTyp == 'C'
          nDec :=  0
       EndIf
       oCol:cFieldTyp := cTyp
       oCol:nFieldLen := nLen
       oCol:nFieldDec := nDec
       AAdd( aStru, { cFld, cTyp, nLen, nDec })
   NEXT

   /////////// �������� ���� � ����� ������� � ���� ///////////////
   cFileDbf := "__New.dbf"
   /* ? procname(), '===================' ; ? 'Stru', aStru
   AEval(aStru, {|av,nv| _logfile(.T., nv, hb_valtoexp(av))})
   dbCreate( cFileDbf, aStru, , .T., '_NEW_' )

   FOR i := 1 TO nCnt
       cLine := hb_ntos(i)
       dbAppend()
       FOR nCol := 1 To Len( oBrw:aColumns )
           cCol := hb_ntos(nCol)
           oCol := oBrw:aColumns[ nCol ]
           // �������� �� ������ � ���������
           If nCol == 1 .and. oBrw:lSelector; LOOP
           ElseIf ! oCol:lVisible           ; LOOP
           ElseIf oCol:lBitMap              ; LOOP
           EndIf
           xVal := oVal:Get( cLine + '.' + cCol )
           cTmp := Valtype(xVal)
           cFld := cPref + hb_ntos(nCol)
           nPos := FieldPos(cFld)
           cTyp := FieldType(nPos)
           If cTyp != cTmp
              If cTmp == 'U'
                 If     cTyp $ 'CM'; xVal := ''
                 ElseIf cTyp == 'N'; xVal := 0
                 ElseIf cTyp == 'D'; xVal := CtoD('')
                 ElseIf cTyp == 'L'; xVal := .F.
                 EndIf
                 cTmp := cTyp
              ElseIf cTyp == 'C'
                 xVal := cValToChar(xVal)
                 cTmp := cTyp
              EndIf
           EndIf
           FieldPut(nPos, xVal)
       NEXT
   NEXT

   USE
   DELETEFILE(cFileDbf) */
   /////////// �������� ���� � ����� ������� � ���� ///////////////

   /////////// ����� ��������� ���� � ���-���� ///////////////////
   /*aFld := oFld:GetAll(.T.)
   aTyp := oTyp:GetAll(.T.)
   aLen := oLen:GetAll(.T.)
   aDec := oDec:GetAll(.T.)
   aIss := oIss:GetAll(.T.)
   ? 'Fld', aFld
   AEval(aFld, {|cv,nv| _logfile(.T., nv, cv)})
   ? 'Typ', aTyp
   AEval(aTyp, {|cv,nv| _logfile(.T., nv, cv)})
   ? 'Len', aLen
   AEval(aLen, {|cv,nv| _logfile(.T., nv, cv)})
   ? 'Dec', aDec
   AEval(aDec, {|cv,nv| _logfile(.T., nv, cv)})
   ? 'Iss', aIss
   AEval(aIss, {|cv,nv| _logfile(.T., nv, cv)})
   */
RETURN aStru


* =======================================================================================
// ����� ����� �� ������� ������ ��� ������ ��������� 
STATIC FUNCTION MinNumFromArr(aColSel,nIn)
   LOCAL nRet := Ascan(aColSel,nIn), nI
   if nRet == 0
     For nI := 1 to Len(aColSel)
        nRet := aColSel[nI]
        if nRet> nIn .and. nI>1
          nRet := aColSel[nI-1]
        endif
     Next
     nRet:=Ascan(aColSel,nRet)
   Endif
   RETURN nRet

* =======================================================================================
// ������ ��������� �������
STATIC FUNCTION CalcAcolselForTbl( oBrw,aColSel)
   LOCAL lIsNotVisible :=.f., Arab, InCol, nCol
   InCol := If(oBrw:lSelector,2,1)
   If aColSel != Nil .and. Len( aColSel) >0
       aRab := aColSel
   Else  
         Arab:={}
         For nCol := InCol TO Len( oBrw:aColumns )
            if oBrw:aColumns[nCol]:lVisible
               Aadd(Arab,nCol)
            Endif
         Next
   Endif
   RETURN aRab 

* =======================================================================================
// ����� ����� �� ������� ������ ��� ������ ��������� 
STATIC FUNCTION MaxNumFromArr(aColSel,nIn)
   LOCAL nRet := Ascan(aColSel,nIn), nI
   if nRet == 0
     For nI := 1 to Len(aColSel)
        nRet := aColSel[nI]
        if nRet > nIn 
          Exit
        endif
     Next
     nRet:=Ascan(aColSel,nRet)
   Endif
   RETURN nRet

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
