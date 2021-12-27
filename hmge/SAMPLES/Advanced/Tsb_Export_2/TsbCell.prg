/*
 * MINIGUI - Harbour Win32 GUI library Demo - Tsbrowse
 *
 * Copyright 2020 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2020 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * ������������� ���������������� ������ TSBcell ��� �������� �������� ������.
 * Using the auxiliary TSBcell class for quick data export.
 */

#define _HMG_OUTLOG
#define TYPE_EXCEL_FORMULA '#'              // ��� ��� ������� ��� ������

#include "hmg.ch"
#include "TSBrowse.ch"
* ======================================================================
FUNCTION myGetTsbContent(oBrw)     // ���������� �������
   LOCAL aTsb, aTsbEnum, aTsbFoot, aTsbHead, aTsbSupH, aTsbCell, cMsg

   CursorWait()
   IF Hb_LangSelect() == "ru.RU1251" ; cMsg := '�������� ������ � �������'
   ELSE                              ; cMsg := 'Read data from the table'
   ENDIF
   WaitThreadCreateIcon( cMsg, )   // ������ �� ��������

   // ��� ������ ������� �������
   aTsbEnum := myGetTsbEnum(oBrw)  // ������ ����/����/����� ���������� �������
   aTsbFoot := myGetTsbFoot(oBrw)  // ������ ����/���� ������� �������
   aTsbHead := myGetTsbHead(oBrw)  // ������ ����/���� ����� �������
   aTsbSupH := myGetTsbSupH(oBrw)  // ������ ����/���� ����������� �������
   aTsbCell := myGetTsbCell(oBrw)  // ������ ����/���� ����� �������
   aTsb     := { aTsbSupH, aTsbHead, aTsbEnum, aTsbCell, aTsbFoot }

   WaitThreadCloseIcon()  // kill the window waiting
   CursorArrow()

   RETURN aTsb

* =======================================================================================
// ������ ����/���� ����������� �������
FUNCTION myGetTsbSupH(oBrw)
   LOCAL aRet, oCel, xVal, aFore, aBack, hFnt, aSup, nFrom, nTo
   LOCAL nCol, oCol, nEnd, nAlign, nVertText

   aRet := {}
   aSup := oBrw:DrawSuper( .F. )
   FOR EACH oCel IN aSup
      hFnt  := oCel:hFont
      aFore := oCel:nClrFore
      aBack := oCel:nClrBack
      xVal  := oCel:cValue
      //   - added the new variables :nFromCol, :nToCol in the class TSBcell.
      nFrom := oCel:nFromCol
      nTo   := oCel:nToCol
      nAlign :=  oCel:nVAlign
      nVertText := oCel:nVertText

      IF nFrom > 0 .AND. nTo > 0

         nEnd := 0

         FOR nCol := nFrom TO nTo
            oCol := oBrw:aColumns[ nCol ]
            If nCol == 1 .and. oBrw:lSelector ; LOOP
            ElseIf ! oCol:lVisible            ; LOOP
            ElseIf oCol:lBitMap               ; LOOP
            EndIf
            // ... ������������ ��� ������� �������
            nEnd := nCol
         NEXT
         nTo := nEnd

         IF nEnd > 0
            AADD( aRet, { aFore, aBack, hFnt, xVal, nFrom, nTo, nAlign, nVertText } )
         ENDIF

      ENDIF
      DO EVENTS

   NEXT
   // ����������� ���������� (������)
   AEval( oBrw:aColumns ,{|oc| oc:oCell := NIL, oc:oCellHead := NIL, ;
                           oc:oCellEnum := NIL, oc:oCellFoot := NIL } )
RETURN aRet

* =======================================================================================
// ������ ����/���� ����� �������
FUNCTION myGetTsbHead(oBrw)
   LOCAL aRet, nCol, oCol, oCel, xVal, aFore, aBack, hFnt

   aRet := {}
   oBrw:DrawHeaders( , .F.)  // �� ������� ��� Header, SpcHd, Footer, Enum

   IF oBrw:lDrawHeaders
      FOR nCol := 1 TO oBrw:nColCount()
         oCol  := oBrw:aColumns[ nCol ]

         // �������, ������� �� �����
         If nCol == 1 .and. oBrw:lSelector ; LOOP
         ElseIf ! oCol:lVisible            ; LOOP
         ElseIf oCol:lBitMap               ; LOOP
         EndIf

         oCel  := oCol:oCellHead
         hFnt  := oCel:hFont
         aFore := oCel:nClrFore
         aBack := oCel:nClrBack
         xVal  := oCel:cValue
         IF oCel:lMultiLine
            // xVal := StrTran(xVal, CRLF, " ") - �� ����
         ENDIF
         AADD( aRet, { aFore, aBack, hFnt, xVal } )
         DO EVENTS
      NEXT
   ENDIF
   // ����������� ���������� (������)
   AEval( oBrw:aColumns ,{|oc| oc:oCell := NIL, oc:oCellHead := NIL, ;
                           oc:oCellEnum := NIL, oc:oCellFoot := NIL } )

RETURN aRet

* =======================================================================================
// ������ ����/����/����� ���������� �������
FUNCTION myGetTsbEnum(oBrw)
   LOCAL aRet, nCol, oCol, oCel, xVal, aFore, aBack, hFnt, lCol

   aRet := {}
   oBrw:DrawHeaders( , .F.)  // ������� ��� Header, SpcHd, Footer, Enum

   IF oBrw:lDrawSpecHd

      FOR nCol := 1 TO oBrw:nColCount()
         oCol  := oBrw:aColumns[ nCol ]

         // �������, ������� �� �����
         If nCol == 1 .and. oBrw:lSelector ; LOOP
         ElseIf ! oCol:lVisible            ; LOOP
         ElseIf oCol:lBitMap               ; LOOP
         EndIf

         oCel  := oCol:oCellEnum
         hFnt  := oCel:hFont
         aFore := oCel:nClrFore
         aBack := oCel:nClrBack
         xVal  := oCel:cValue
         lCol  := oCol:lVisible
         IF xVal == ""
            xVal := HB_NtoS(nCol)
         ENDIF
         AADD( aRet, { aFore, aBack, hFnt, xVal } )
         DO EVENTS

      NEXT

   ENDIF
   // ����������� ���������� (������)
   AEval( oBrw:aColumns ,{|oc| oc:oCell := NIL, oc:oCellHead := NIL, ;
                           oc:oCellEnum := NIL, oc:oCellFoot := NIL } )

RETURN aRet

* =======================================================================================
// ������ ����/����_�����/����_����/��������/���/������/���_���� ����� �������
FUNCTION myGetTsbCell(oBrw)
   LOCAL aRet, aLine, nAt, nCol, oCol, oCel, xVal, aFore, aBack
   LOCAL cName, hFnt, cType, cPict, lCol
   LOCAL nAlign

   aRet := {}

   WITH OBJECT oBrw
   :GoTop()
   :lDrawLine := .F.
   :GoTop()

   FOR nAt := 1 TO :nLen
      :DrawLine()
      aLine := {}
      FOR nCol := 1 TO :nColCount()
         oCol := :aColumns[ nCol ]

         // �������, ������� �� �����
         If nCol == 1 .and. oBrw:lSelector ; LOOP
         ElseIf ! oCol:lVisible            ; LOOP
         ElseIf oCol:lBitMap               ; LOOP
         EndIf

         oCel   := oCol:oCell
         hFnt   := oCel:hFont
         aFore  := oCel:nClrFore
         aBack  := oCel:nClrBack
         nAlign := oCol:nAlign
         Switch nAlign
          case DT_LEFT
            nAlign := "Left"
            Exit
         case DT_CENTER
            nAlign := "Center"
            Exit
         Case DT_RIGHT
            nAlign := "Right"
            Exit
         End switch

         //cType := Valtype(oCel:uValue) - �� ���
         cType := oCol:cFieldTyp
         cPict := oCol:cPicture
         cName := oCol:cName
         lCol  := oCol:lVisible

         If Valtype(oCel:uValue) == 'L'
            IF Hb_LangSelect() == "ru.RU1251" ; xVal := iif(oCel:uValue,'��','���')
            ELSE                              ; xVal := iif(oCel:uValue,'yes','no')
            ENDIF
            //xVal  := if(oCel:uValue,'[+]','[ ]')
            cPict := 'XXX'
         Elseif Valtype(oCel:uValue) == 'C'
            xVal  := ALLTRIM(oCel:uValue)
            If SUBSTR(xVal,1,1) = "="        // ��� ������� Excel
               cType := TYPE_EXCEL_FORMULA   // ��� ������ ��� �������
            Endif
         Else
            //xVal  := oCel:cValue - ��� ������ ! ��������� � ��������� ������
            xVal  := oCel:uValue
            cPict := oCol:cPicture
         Endif

         AADD( aLine, { aFore, aBack, hFnt, xVal, cType, cPict, cName, nAlign } )
         DO EVENTS

      NEXT
      AADD( aRet, aLine )  // ������ �������
      :GoDown()
      DO EVENTS
   NEXT

   :lDrawLine := .T.
   :Reset()
   // ����������� ���������� (������)
   AEval( :aColumns ,{|oc| oc:oCell := NIL, oc:oCellHead := NIL, ;
                           oc:oCellEnum := NIL, oc:oCellFoot := NIL } )

   END WITH

RETURN aRet

* =======================================================================================
// ������ ����/���� ������� �������
FUNCTION myGetTsbFoot(oBrw)
   LOCAL aRet, nCol, oCol, oCel, xVal, aFore, aBack, hFnt, lCol

   aRet := {}
   oBrw:DrawHeaders( , .F.)  // �� ������� ��� Header, SpcHd, Footer, Enum
   IF oBrw:lDrawFooters

      FOR nCol := 1 TO oBrw:nColCount()
         oCol  := oBrw:aColumns[ nCol ]

         // �������, ������� �� �����
         If nCol == 1 .and. oBrw:lSelector ; LOOP
         ElseIf ! oCol:lVisible            ; LOOP
         ElseIf oCol:lBitMap               ; LOOP
         EndIf

         oCel  := oCol:oCellFoot
         hFnt  := oCel:hFont
         aFore := oCel:nClrFore
         aBack := oCel:nClrBack
         xVal  := oCel:cValue
         lCol  := oCol:lVisible
         AADD( aRet, { aFore, aBack, hFnt, xVal } )
         DO EVENTS

      NEXT

   ENDIF
   // ����������� ���������� (������)
   AEval( oBrw:aColumns ,{|oc| oc:oCell := NIL, oc:oCellHead := NIL, ;
                           oc:oCellEnum := NIL, oc:oCellFoot := NIL } )
RETURN aRet

* ======================================================================
// ������� ���� �������� �� �������� ���������
FUNCTION myImageReport(cRes)
   LOCAl aImage, cFileLogo, aXY, cMsg, nResult, cFile
   Default cRes := "LogoMG"

   cFile  := cRes + ".png"
   aImage := {}  // ��� �������� !  ���� ���� ��� �������� !

   //cFileLogo := GetStartUpFolder() + "\LogoMG.png"
   cFileLogo := GetUserTempFolder() + "\" + cFile
   If !hb_FileExists( cFileLogo )
      nResult := RCDataToFile( cRes, cFileLogo, "PNG" )
      If nResult > 0
      Else
         cMsg := "cRes = '" + cRes + "'" + CRLF
         cMsg += "RCDataToFile() - Code: " + hb_NtoS( nResult ) + CRLF
         cMsg += cFileLogo + CRLF
         MsgStop( cMsg, "Checkout error" )
      Endif
   Endif
   If hb_FileExists( cFileLogo )
      aXY  := hb_GetImageSize( cFileLogo )
      cMsg := cFileLogo + ": " + hb_NtoS( aXY[1] ) + " x " + hb_NtoS( aXY[2] ) + " Pixels"
      //AlertInfo(cMsg)
      aImage := { cFileLogo, aXY[1], aXY[2] }
   Endif

   RETURN aImage

