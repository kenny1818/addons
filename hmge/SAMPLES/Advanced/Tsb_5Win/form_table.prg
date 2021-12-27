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

MEMVAR oMain
///////////////////////////////////////////////////////////////////////////////
FUNCTION Show_Table( nTable )
   LOCAL om := M->oMain:Cargo
   LOCAL cForm := om:aFormData[nTable]   // ��� ����
   LOCAL cTabl := subs(cForm, 2)         // ��� TBrowse
   LOCAL cIco, cTitle, c2Title, nW, nH, nY, nX, nG, nR, cAls
   LOCAL cFont, nFSize, hWnd, nHMain, nHBrd, oThis, aBackColor, aUse3Dim
   LOCAL aBtn4Dim, nWBtn, nHBtn, nKBtn, nHIco, nYBrw, nXBrw, nWBrw, nHBrw
   LOCAL oBrw   // ��� ������ ������� ����� ���� oBrw

   ? "======", cForm, cTabl, ProcNL()
   IF !_IsWindowActive( cForm )

      nHMain     := oMain:Height
      nW         := System.ClientWidth
      nHBrd      := GetBorderHeight()
      nH         := System.ClientHeight - nHMain - nHBrd
      nR         := nHMain + nHBrd
      cIco       := "2MAIN_ICO"
      cFont      := "Tahoma"
      nFSize     := ModeSizeFont()
      cTitle     := cForm + " (" + HB_NtoS(nTable) + ")"
      c2Title    := "Table: " + cTabl + " for form: " + cForm
      // ������ �� ����� -> ListTables.prg
      aBackColor := myTableBackColor(nTable)          // ���� �����
      aBtn4Dim   := myTableButtonUp(nTable)           // ������ ������ ����� �����
      // ������ �� ������� -> ListTables.prg
      aUse3Dim   := myTableUse(nTable)                // ������ ���� dbf/alias/codepage

      IF Empty( cAls := Use_Table(aUse3Dim) ) ; RETURN .F.
      ENDIF

      DEFINE WINDOW &cForm                          ;
         At nR, 0 WIDTH nW HEIGHT nH                ;
         TITLE cTitle  ICON  cIco                   ;
         WINDOWTYPE STANDARD TOPMOST                ;
         NOMAXIMIZE NOSIZE                          ;
         BACKCOLOR aBackColor                       ;
         ON GOTFOCUS NIL                            ;  // ������� ������ �� �����
         ON INIT     {|| DoEvents(), _wPost(1)   }  ;  // ����������� ����� ������������� ����
         ON RELEASE  {|| (cAls)->(dbCloseArea()) }     // ����������� ����� ����������� ����

         oThis             := This.Object
         This.Cargo        := oHmgData()                // ��������� ��� ����� ����
         This.Cargo:nTable := nTable
         This.Cargo:cForm  := cForm

         nW    := This.ClientWidth
         nH    := This.ClientHeight
         hWnd  := ThisWindow.Handle
         nY    := nX := nG := 20
         nHIco := 64                                  // ������ ������
         nKBtn := LEN(aBtn4Dim[1])                    // ���-�� ������
         nHBtn := nHIco + 10                          // ������ ������
         nWBtn := ( nW - nG*(nKBtn+1) ) / nKBtn       // ������ ������

         @ 0, 10 LABEL Buff WIDTH nW HEIGHT 10 VALUE '������������ ������'  INVISIBLE

         Button_UpMenu(nY,nX,nG,nHIco,aBtn4Dim,nWBtn,nHBtn)  // �������� ���� ������ �� �����

         nXBrw := nG
         nWBrw := nW - nXBrw * 2
         nYBrw := nG * 2 + nHBtn
         nHBrw := nH - nYBrw - nG

         // �������� ������
         /*c2Title += " Alias: " + cAls
         @ nYBrw, nXBrw LABEL Label_Tsb WIDTH nWBrw HEIGHT nHBrw VALUE c2Title ;
           FONTCOLOR WHITE VCENTERALIGN CENTERALIGN TRANSPARENT BORDER
         // ������� ������� �� ������������ ������ �����
         SetFontSizeText(ThisWindow.Name, "Label_Tsb") */

         // ������� -> form_tbrowse.prg
         oBrw := TBrowse_Create( nTable, cTabl, cForm, cAls, c2Title, nYBrw, nXBrw, nWBrw, nHBrw )

         oBrw:Cargo:nHMain := nR     // ������ �������� ����
         This.Cargo:oBrw   := oBrw   // ��������� �������

         // ������� ��� �������� ���� / Events for window objects
         ThisEventsWindowObjects()

         ON KEY F1     ACTION NIL
         ON KEY ESCAPE ACTION NIL

      END WINDOW

      //CENTER   WINDOW &cForm
      ACTIVATE WINDOW &cForm ON INIT {|| This.Minimize, wApi_Sleep(50), ;
                                         This.Restore , DoEvents() }

      DO EVENTS ; _wPost( 101, oMain:Name )

   ELSE

      SwitchToWin( cForm )  // ����������� �� ���.�����

   ENDIF

RETURN NIL

///////////////////////////////////////////////////////////////////////////////
// ������� ��� �������� ���� / Events for window objects
STATIC FUNCTION ThisEventsWindowObjects()

   // ������ ������� �� ������ ���� �� ListTables.prg
   // aBtnPst := { 10, 11, 12, 13, 14, 90 } // _wPost(�) - ����� ������� �� ������
   // aBtnCap := { "������", "��������", "�����", "������", "���������", "�����" }

   WITH OBJECT This.Object

      :Event(  0, {|ow| AlertInfo(":Event(0)",ow:Name), DoEvents() })
      :Event(  1, {|ow| // ��� ON INIT ����� ����
                        Local om := oMain:Cargo                          // MAIN ����
                        Local oBrw := ow:Cargo:oBrw
                        //? ProcNL(), "ow:Name=", ow:Name
                        This.Topmost := .F.
                        //ow:SetFocus("Buff")
                        oBrw:Setfocus()     // ����� �� �������
                        DO EVENTS
                        IF om:nStartWindow > 0 ; _wPost(100, oMain:Name)  // MAIN ����
                        ENDIF
                        Return Nil
                  })

      :Event( 10, {|ow,ky,cp| TestButton( ow,ky,cp )     } )  // ������

      :Event( 11, {|| This.Enabled := .F., _wPost(111, , This.Name) } )  // ��������
      :Event(111, {|ow,ky,cn| // �������� - �����������
                        Local oBrw := ow:Cargo:oBrw
                        Local hWnd := ow:Handle       //!!!
                        //MG_Debug(ow:Name,ky,cn)
                        ky := cn // ������ ������ �����������, �.�. ky ����� ������ �� ������������
                        SET WINDOW THIS TO ow:Name    // save This ����� ���� ow
                        Darken2Open(hWnd)             // ��������� �� �����
                        Show_Card(oBrw)               // -> form_card.prg
                        ? "-> Show_Card(oBrw) end", ow:Name, hWnd
                        Darken2Close(hWnd)            // ������ ��������� �� �����
                        ? "-> Darken2Close(ky) end", ow:Name, hWnd
                        SET WINDOW THIS TO            // restore This ����� ���� ow
                        //This.&(cn).Enabled := .T.
                        SetProperty(ow:Name, cn, 'Enabled', .T.)
                        //ow:SetFocus('Buff')
                        oBrw:SetFocus()         // ����� �� �������
                        Return Nil
                  })

      :Event( 12, {|ow,ky,cp| TestButton( ow,ky,cp )    } ) // �����
      :Event( 13, {|ow,ky,cp| TestButton( ow,ky,cp )    } ) // ������
      :Event( 14, {|ow,ky,cp| TestButton( ow,ky,cp )    } ) // ���������
      :Event( 50, {|ow,ky,cp| TestButton( ow,ky,cp )    } ) // ������
      :Event( 51, {|ow,ky,cp| TestButton( ow,ky,cp )    } ) // ���� 1
      :Event( 52, {|ow,ky,cp| TestButton( ow,ky,cp )    } ) // ���� 2

      // ������� 70 ��������������� ��� ������������ ���� ������� -> form_tbrowse.prg
      //:Event( 70, {|ow,p1,p2| MG_Debug("ow:Name=",ow:Name,p1,p2), DoEvents() })
      // ������� 80 ��������������� ��� ������������ ���� ������� -> form_tbrowse.prg
      //:Event( 80, {|ow,p1,p2| MG_Debug("ow:Name=",ow:Name,p1,p2), DoEvents() })

      :Event( 90, {|  | _wPost(99, , This.Name)         } ) // ����� �� ���� �������
      :Event( 99, {|ow| ow:Release()                    } ) // ����� - �����������
   END WITH

RETURN NIL

/////////////////////////////////////////////////////////////////////////////////
FUNCTION TestButton(ow,ky,cp)    // ��� ������������ ������� ������
   LOCAL oWnd, hHandle, oCtl, cObj, oCargo, oBrw, a2Dim, nI, cTxt, cMsg

   ?  "--------- " + ProcNL() + "(", ow,ky,cp ,")"
   oWnd    := ThisWindow.Object  // ������ ����
   oCtl    := This.Object        // ������ ������� ������
   hHandle := ThisWindow.Handle

   //------------------------------------------------------------------------
   ? 'Form   :', oWnd:Type, oWnd:Name, oWnd:Handle, oWnd:Index, ;
                 oWnd:IsWindow, oWnd:IsControl, ;
                 oWnd:Row , oWnd:Col , oWnd:Width , oWnd:Height, ;
                 oWnd:ClientWidth , oWnd:ClientHeight
   // ������ ����
   // oWnd:Hide(), oWnd:Show(), oWnd:Restore(), oWnd:SetFocus(ControlName)
   // oWnd:SetSize(y,x,w,h), oWnd:GetObj(ControlName), oWnd:Release()

   ? '�������:', oCtl:Type, oCtl:Name, oCtl:Handle, oCtl:Index, ;
                 oCtl:IsWindow, oCtl:IsControl, ;
                 oCtl:Row , oCtl:Col , oCtl:Width , oCtl:Height, ;
                 oCtl:ClientWidth , oCtl:ClientHeight
   // ������ ��������
   // xVal := oCtl:Value
   // oCtl:Value := xVal
   // oCtl:Hide(), oCtl:Show(), oCtl:SetSize(y,x,w,h), oCtl:SetFocus()
   // oCtl:Refresh(), oCtl:Disable(), oCtl:Enable()
   // oGet := oCtl:Get - ��� GetBox
   // oBrw := oCtl:Tsb - ��� TsBrowse
   // oBrw:Refresh()
   // oBrw:... � �.�.
   //------------------------------------------------------------------------
   ? Repl("-",60)
   ?  " _HMG_ThisFormIndex  <���� index>               :=",  _HMG_ThisFormIndex
   ?  " _HMG_ThisEventType                             :=",  _HMG_ThisEventType
   IF _HMG_ThisType == 'W'
   ?  " _HMG_ThisType       'W' // 'W[indow]'  ������� :=",  _HMG_ThisType
   ?  "    ������� - _wPost(This.Cargo:nPost, This.Name)"
   ELSE
   ?  " _HMG_ThisType       'C' // 'C[ontrol]' ������� :=",  _HMG_ThisType
   ?  "    ������� - _wPost(This.Cargo:nPost, This.Index)"
   ENDIF
   ?  " _HMG_ThisIndex      <���� index>               :=",  _HMG_ThisIndex
   ?  " _HMG_ThisFormName   <���� name>                :=",  _HMG_ThisFormName
   ?  " _HMG_ThisControlName                           :=",  _HMG_ThisControlName
   ? Repl("-",60)

   cObj  := ow:Name
   ?  "cObj= (ow:Name)=",ow:Name
   ?  "oWnd:Name=", oWnd:Name

   oCargo  := This.Cargo       // ���� ������ � ������ �� ��� �������� �����
   Darken2Open(hHandle)        // ��������� �� �����

   // �������� � ������ ������
   a2Dim := oCargo:GetAll(.F.)
   cTxt  := ""
   // ��� ������ ���� ������ � �� ��������
   FOR nI := 1 TO Len(a2Dim)
      ? "  oCargo:", nI, "Key =", a2Dim[nI][1], "Val =", a2Dim[nI][2]
      cTxt += "  oCargo:" + STR(nI,2) + ") Key = " + a2Dim[nI][1]
      cTxt += ", Val = " + cValToChar(a2Dim[nI][2])
      IF VALTYPE(a2Dim[nI][2]) == "A"
         ?? HB_ValToExp(a2Dim[nI][2])
         cTxt += HB_ValToExp(a2Dim[nI][2])
      ENDIF
      cTxt += CRLF
   NEXT
   ? Repl("-",60)

   SET WINDOW THIS TO oWnd:Name    // save This ����� ���� ow
       oBrw := oWnd:Cargo:oBrw                    // �������� ������ �� �������
       //oBrw := (ThisWindow.Object):Cargo:oBrw   // �������� ������ �� �������
   SET WINDOW THIS TO              // restore This ����� ���� ow
   ?  "oBrw = ",oBrw
   ??  oBrw:cAlias

   cMsg := ProcNL() + ";" + Repl("-",40) + ";"
   cMsg += "oWnd:Name="+oWnd:Name+", ow:Name=" + ow:Name + ";;"
   cMsg += cTxt + ";" + Repl("-",40) + ";"
#ifdef _HMG_OUTLOG
   cMsg += "������ oBrw - �������� ! oBrw:cAlias = " + oBrw:cAlias
   cMsg += ";������ �������� ��� ����������;"
   cMsg += "aHeader := oBrw:Cargo:aHeader // ������ �������� ����� � ��������;"
   cMsg += "aField  := oBrw:Cargo:aField  // ������ ������������ ������� �������;"
   cMsg += "aEdit   := oBrw:Cargo:aEdit   // ������ ������ ��� �������������� �������;"
   cMsg += "� ��� ������ �������� � oBrw:Cargo:����� !;"
   cMsg += Repl("-",40) + ";;"
   cMsg += "��� �������� ������� ������������ � ��� ��� ���� �������:"
   cMsg += ";��� ��������� � ���������        = " + HB_NtoS( App.Cargo:nUser )
   cMsg += ";��� ��������� � ���������        = " + App.Cargo:cUser
   cMsg += ";��� ������ ��������� � ��������� = " + HB_NtoS( App.Cargo:nUGrp )
#endif
   MG_Info(cMsg)

   Darken2Close(hHandle)      // ������ ��������� �� �����
   This.&(oCargo:cObj).Enabled := .T.
   //SetProperty(oWnd:Name, cObj, "Enabled", .T.) - ����� � ���

   oWnd:SetFocus('Buff')
   oBrw:Setfocus()   // ������� ����� �� �������

RETURN NIL
/////////////////////////////////////////////////////////////////////////////////
// �������� � ������ ��������,����,������ � �.�.
FUNCTION Button_UpMenu(nY,nX,nG,nIcoSize,aBtn4Dim,nWBtn,nHBtn)
   LOCAL cForm, aBtnCap, aBtnIco, aBtnClr, aBtnPst, cCapt, aIco
   LOCAL cN, cFont, nFSize, lFBold, nJ, aColor, aBtnGrd, aGrOver, aGrFill
   LOCAL aFntClr, nwPost, hIco, aBtnObj, nFSMin, nFH

   aBtnObj := {}
   cForm   := ThisWindow.Name
   // ������
   aBtnCap := aBtn4Dim[1]
   aBtnIco := aBtn4Dim[2]
   aBtnClr := aBtn4Dim[3]
   aBtnPst := aBtn4Dim[4]
   // ����� ��� ������
   aFntClr := { BLACK , OLIVE }
   cFont   := "Comic Sans MS"
   nFSize  := 16
   lFBold  := .T.
   nFSMin  := 72

   FOR nJ := 1 TO LEN(aBtnCap)
      cCapt   := StrTran( aBtnCap[nJ], ";" , CRLF )
      aIco    := aBtnIco[nJ]
      aColor  := aBtnClr[nJ]
      aBtnGrd := { HMG_RGB2n( aColor ), CLR_WHITE }  // �������� ������
      aGrOver := { { 0.5, aBtnGrd[2], aBtnGrd[1] }, { 0.5, aBtnGrd[1], aBtnGrd[2] } }
      aGrFill := { { 0.5, aBtnGrd[1], aBtnGrd[2] }, { 0.5, aBtnGrd[2], aBtnGrd[1] } }
      nwPost  := aBtnPst[nJ]
      hIco    := LoadIconByName( aIco[1], nIcoSize, nIcoSize )
      cN      := 'Btn_' + StrZero(nJ, 2)
      AADD(aBtnObj,cN)

      @ nY, nX BUTTONEX &cN WIDTH nWBtn HEIGHT nHBtn                            ;
        CAPTION cCapt ICON hIco                                                 ;
        FLAT NOXPSTYLE HANDCURSOR NOTABSTOP LEFTTEXT                            ;
        FONT cFont SIZE nFSize BOLD FONTCOLOR aFntClr[1]                        ;
        BACKCOLOR aGrOver GRADIENTFILL aGrFill                                  ;
        ON MOUSEHOVER ( This.Fontcolor := aFntClr[2]                                      ,;
                        This.Icon := LoadIconByName(This.Cargo:aIco[2],nIcoSize,nIcoSize) ,;
                        This.GradientFill := This.Cargo:aGrFill     )            ;
        ON MOUSELEAVE ( This.Fontcolor := aFntClr[1]                                      ,;
                        This.Icon := LoadIconByName(This.Cargo:aIco[1],nIcoSize,nIcoSize) ,;
                        This.GradientOver := This.Cargo:aGrOver     )            ;
        ACTION  {| | This.Enabled := .F., _wPost(This.Cargo:nPost, This.Index) } ; // � ������� ����� ����� This ��� ������,
        ON INIT {|o|                                                               // �.�. ����� This.Index �������� 2
                     This.Cargo := oKeyData()  // ������� ������ (���������) ��� ���� ������
                     o := This.Cargo
                     // ������� �� ������ ������ ������
                     o:nBtn    := nJ
                     o:nPost   := nwPost
                     o:cCapt   := cCapt
                     o:aIco    := aIco
                     o:aBClr   := aColor
                     o:cObj    := This.Name
                     o:aGrFill := aGrFill
                     o:aGrOver := aGrOver
                     Return Nil
                 }          // ON INIT ���� �������� ������ ������ ����

      // ��� ������ ���������� �������� ������� ������
      This.&(cN).ImageWidth  := nIcoSize
      This.&(cN).ImageHeight := nIcoSize
      This.&(cN).Icon        := LoadIconByName( aIco[1], nIcoSize, nIcoSize )

      // ������������ ������ ����� �� ������ + ������� ���.��������
      SetFontSizeTextMax(cForm, cN, 8 + nIcoSize , 8 )
                        // 3-��������: ��������� �� ������ �������� + 8 ��������
                        // 4-��������: ��������� �� ������ 8 ��������
      nFH    := This.&(cN).Fontsize
      nFSMin := MIN(nFSMin,nFH)

      // ����� ������
      nX += nWBtn + nG
   NEXT

   // ���������� �� ������ ����������� ���������� ������ �����
   FOR nJ := 1 TO LEN(aBtnObj)
      cN  := aBtnObj[nJ]
      This.&(cN).Fontsize := nFSMin
   NEXT


RETURN NIL

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Use_Table( a3Dim, lMsg )
   LOCAL lUsed, cAls, cDbf, cCDP
   DEFAULT lMsg := .T.

   cDbf := App.Cargo:cPathDbf + a3Dim[1]
   cAls := a3Dim[2]
   cCDP := a3Dim[3]

   IF !FILE( cDbf )
      cAls := ""
      IF lMsg
         MG_Stop("Error ! No such file !;;"+cDbf, "File open error")
      ENDIF
   ELSE
      USE (cDbf) ALIAS (cAls) CODEPAGE (cCDP) SHARED  NEW
      lUsed := Used()
      cAls  := Alias()
      IF lMsg .and. ! lUsed
         cAls := ""
         MG_Stop("Error ! File not used !;;"+cDbf, "File open error")
      ENDIF
   ENDIF

RETURN cAls

