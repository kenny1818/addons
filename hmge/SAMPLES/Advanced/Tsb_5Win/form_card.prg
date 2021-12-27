/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2021 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2021 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
*/

//#define  _HMG_OUTLOG
#include "hmg.ch"

MEMVAR oMain

STATIC cStaticAliasCard
///////////////////////////////////////////////////////////////////////////////
FUNCTION Show_Card(oBrw)
   LOCAL cIco, cTitle, aBColor, nW, nH, aBtnFnt, nY, nX, aHeader, aField, aEdit
   LOCAL o, nTable, nI, aForm := oMain:Cargo:aFormData
   LOCAL nWLbl, nHLbl, cForm := ThisWindow.Name

   DO EVENTS

   FOR nI := 1 TO Len(aForm)
       IF aForm[nI] == cForm ; LOOP
       ENDIF
       IF _IsWindowDefined(aForm[nI]) ; DoMethod(aForm[nI], "Hide")
       ENDIF
   NEXT

   DBSELECTAREA(oBrw:cAlias)
   cStaticAliasCard := oBrw:cAlias  // �������� ����������� � ������������ ���������� �������
                                    // ��� ����� ��������� � ������������ ��� ������ ����� � ��
   ? "==[]==", ProcNL()
   ? "      WINDOW �� Form_Card = ", cForm
   cIco    := "2MAIN_64"
   cTitle  := "Card for form: " + cForm
   nW      := System.ClientWidth * 0.7
   nH      := System.ClientHeight - 20
   aBtnFnt := { "Comic Sans MS", 28 }

   o       := oBrw:Cargo               // �������� ������ �� �������
   nTable  := o:nTable                 // ����� �������
   aBColor := HMG_n2RGB( o:nClr_2 )    // ���� ���� �������
   aHeader := o:aHeader                // ������ �������� ����� � ��������
   aField  := o:aField                 // ������ ������������ ������� �������
   aEdit   := o:aEdit                  // ������ ������ ��� �������������� �������

   DEFINE WINDOW Form_Card        ;
       AT 0, 0 WIDTH nW HEIGHT nH ;
       TITLE cTitle ICON cIco     ;
       MODAL  NOSYSMENU  NOSIZE   ;
       BACKCOLOR aBColor          ;
       ON INIT    {|| oMain:Cargo:lFormCard := .T. } ;
       ON RELEASE {|| oMain:Cargo:lFormCard := .F. }

       nW := This.ClientWidth
       nH := This.ClientHeight
       nY := nX := 20

       @ nY, nX BUTTONEX Btn_Exit WIDTH 200 HEIGHT 60           ;
         CAPTION "Exit" NOXPSTYLE HANDCURSOR NOTABSTOP          ;
         FONT aBtnFnt[1] SIZE aBtnFnt[2] BACKCOLOR CLR_HRED     ;
         ACTION  {||
                     ? "ACTION", ThisWindow.Name, This.Name, This.Enabled
                     This.Enabled := .F.
                     ? "ACTION", ThisWindow.Name, This.Name, This.Enabled
                     (ThisWindow.Object):Release()
                    Return Nil
                 }

       // ������ ������� � ����
       //(ThisWindow.Object):Event(99, {|ow| _logfile(.T., "-> Event(99)"), ow:Release() })

       nX    += This.Btn_Exit.Width + 20
       nWLbl := nW - This.Btn_Exit.Width - 20 * 2
       nHLbl := This.Btn_Exit.Height

       @ nY, nX LABEL Label_Title WIDTH nWLbl HEIGHT nHLbl VALUE cTitle ;
         FONTCOLOR RED BOLD VCENTERALIGN CENTERALIGN TRANSPARENT
       // ������� ������� �� ������������ ������ �����
       SetFontSizeTextMax(ThisWindow.Name, "Label_Title")

       nY += This.Btn_Exit.Height + 10

       mySayCardDatos(cForm, nY, nTable, aHeader, aField, aEdit)

   END WINDOW

   CENTER   WINDOW Form_Card
   ACTIVATE WINDOW Form_Card

   DO EVENTS ; wApi_Sleep(50)

   FOR nI := 1 TO Len(aForm)
       IF aForm[nI] == cForm ; LOOP
       ENDIF
       IF _IsWindowDefined(aForm[nI]) ; DoMethod(aForm[nI], "Show")
       ENDIF
   NEXT

   SwitchToWin( cForm )  // ����������� �� ���.�����

RETURN NIL

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION mySayCardDatos(cForm, nY, nTable, aHeader, aField, aEdit)
   LOCAL nI, nW, nH, nGRow, nGCol, cFont, nFSize, nWLbl, nWTxt
   LOCAL cSay, cN, cN2, cDbf, lEdit, nWGbx, nX, nLine, xVal

   ? "   ====[say]==== " + ProcNL(), cForm
   cFont  := "Tahoma"
   nFSize := ModeSizeFont() + 4
   nW     := This.ClientWidth
   nH     := This.ClientHeight
   nGRow  := 10
   nGCol  := 20
   nWLbl  := 0
   nLine  := nFSize * 2

   IF nTable == 1
   ENDIF

   FOR nI := 1 TO LEN(aHeader)
     cSay  := aHeader[nI]
     cSay  := AtRepl( ";", cSay, " " )
     cSay  := ALLTRIM( cSay )
     nWTxt := GetTxtWidth( cSay, nFSize, cFont, .F. )  // �������� Width ������
     nWLbl := MAX( nWLbl, nWTxt )
     aHeader[nI] := cSay
   NEXT
   nWLbl += 10

   nX    := nGCol
   nWGbx := nW - nGCol - nWLbl - nGCol/2 - nGCol

   FOR nI := 1 TO LEN(aHeader)
      cSay := aHeader[nI]
      IF LOWER(cSay) == "not-show"     //  ��������� ������� -> ListTables.prg
         // �������
         LOOP
      ELSE

         cN := 'Lbl_Card_' + StrZero(nI,2)
         @ nY, nX LABEL &cN WIDTH nWLbl HEIGHT nLine VALUE cSay + ":" ;
           FONT cFont SIZE nFSize FONTCOLOR BLUE RIGHTALIGN VCENTERALIGN TRANSPARENT

         cN2  := 'GBox_Card_' + StrZero(nI,2)
         cDbf := aField[nI]
         xVal := FIELDGET( FIELDNUM( cDbf ) )
         @ nY, nX + nWLbl + nGCol/2 GETBOX &cN2 WIDTH nWGbx HEIGHT nLine VALUE xVal

         lEdit := aEdit[nI]

         nY += nLine + nGRow/2

      ENDIF
   NEXT

   ? "   ====[end]==== " + ProcNL(), cForm

RETURN NIL
