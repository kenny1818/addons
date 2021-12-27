/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2019-2021 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2015-2021 Verchenko Andrey <verchenkoag@gmail.com>
 * Many thanks for your help - forum http://clipper.borda.ru
 *
*/
//#define  _HMG_OUTLOG
#include "hmg.ch"
#define WM_PAINT  15

REQUEST HB_CODEPAGE_RU1251, HB_CODEPAGE_RU866
REQUEST HB_CODEPAGE_UA1251, HB_CODEPAGE_UA866
REQUEST DBFCDX, DBFFPT
REQUEST CtoT, Descend    // ��������� ������� ������� ����� ��������������
*----------------------------------------------------------------------------*
FUNC SetsEnv()
*----------------------------------------------------------------------------*
   LOCAL cFileLog

   SET CODEPAGE TO RUSSIAN
   SET LANGUAGE TO RUSSIAN

   rddSetDefault( "DBFCDX" )

   SET CENTURY      ON
   SET DATE         GERMAN
   SET EXCLUSIVE    ON
   SET EPOCH TO     2000
   SET AUTOPEN      ON
   SET EXACT        ON
   SET SOFTSEEK     ON
   SET DELETED      OFF //ON

   SET NAVIGATION   EXTENDED
   SET FONT         TO "Arial", 16
   SET DEFAULT ICON TO "1MAIN_ICO"

   //SET DIALOGBOX CENTER OF PARENT
   //SET CENTERWINDOW RELATIVE PARENT                // for HMG_Alert()

   DEFINE FONT FontBold FONTNAME _HMG_DefaultFontName SIZE _HMG_DefaultFontSize BOLD
   DEFINE FONT DlgFont  FONTNAME "DejaVu Sans Mono" SIZE 16  // for HMG_Alert()
   DEFINE FONT AgeCard  FONTNAME "Verdana"          SIZE 12  BOLD

   // --------------------------------
   SET OOP ON
   // --------------------------------

   cFileLog := GetStartUpFolder() + "\_Msg.log"
   fErase( cFileLog )
   // ���������� ��� ����� ��� ������ - ������� _LogFile(...) -> h_ini.prg
   SET LOGFILE TO &cFileLog
   ? "=======================  ������ ��������� - " + myTIME() + "  ======================="
   ? MiniGuiVersion() , MiniGuiVersionNumba()
   ? "���������� ������ = " + HB_NtoS(GetDesktopWidth())+"x"+HB_NtoS(GetDesktopHeight())
   ? "LargeFonts() = " + IIF(LargeFonts()," .������� ����. "," ��� ��")
   ? "."
   //SET WINDOW MAIN OFF

RETURN NIL

///////////////////////////////////////////////////////////////////////////////
FUNCTION MiniGuiVersionNumba()
   LOCAL cRegEx, cVer, aVal, nVer := 0,  cVal := MiniGuiVersion()
   // Harbour MiniGUI Extended Edition 21.10.3 (32-bit) ANSI
   // Harbour MiniGUI Extended Edition 15.12
   cRegEx := "\d+\.\d+[\d.]*"
   aVal   := HB_RegEx(cRegEx, cVal)
   IF LEN(aVal) > 0
      cVal := aVal[1]
      cVer := CHARREM( '.', cVal )
      cVer := PADR(cVer,6,'0')
      nVer := VAL( cVer )
   ENDIF

RETURN nVer

*-----------------------------------
Function SwitchToWin( cForm )
*-----------------------------------

    If _IsWindowDefined( cForm )
       DO EVENTS
       If IsIconic( GetFormHandle(cForm) )
          _Restore( GetFormHandle(cForm) )
       Else
          DoMethod( cForm, "SetFocus" )
       EndIf
    EndIf

Return Nil

///////////////////////////////////////////////////////////////////////////////
// ����������� �������� �� �����
*--------------------------------------------------------*
Procedure RefreshWin( hWnd )
*--------------------------------------------------------*
   SendMessage( hWnd, WM_PAINT, 0, 0 )
   Do Events
Return

///////////////////////////////////////////////////////////////////////////////
FUNCTION ToRGB(aDim)
RETURN RGB(aDim[1],aDim[2],aDim[3])

///////////////////////////////////////////////////////////////////
FUNCTION ProcNameLine(nVal)
   DEFAULT nVal := 0
   RETURN "Call from: " + ProcName( nVal + 1 ) + "(" + hb_ntos( ProcLine( nVal + 1 ) ) + ") --> " + ProcFile( nVal + 1 )

///////////////////////////////////////////////////////////////////
FUNCTION ProcNL(nVal)
   DEFAULT nVal := 0
   RETURN "Call from: " + ProcName( nVal + 1 ) + "(" + hb_ntos( ProcLine( nVal + 1 ) ) + ") --> " + ProcFile( nVal + 1 )

///////////////////////////////////////////////////////////////////
FUNCTION myTIME()
   LOCAL cTm := "", tDtm := HB_DATETIME()
   HB_TTOD( tDtm, @cTm, "hh:mm:ss.fff" )
RETURN cTm

////////////////////////////////////////////////////////////////////////////
// ��������� �� ����� / Darken the form
FUNCTION Darken2Open(hWinHandle)
   LOCAL aBClr := { BLACK , RED , { 61, 61, 61 }, YELLOW }  // ���� ����
   LOCAL aColor, nTransparencyLevel := 128                  // ������� ������������

   aColor := aBClr[1]
   // ��������� �� ����� / Darken the form
   OverlayCreate(hWinHandle, aColor[1], aColor[2], aColor[3], nTransparencyLevel)

   DO EVENTS

RETURN NIL

////////////////////////////////////////////////////////////////////////////
// ��������� �� ����� / Darken the form
FUNCTION Darken2Close(hWinHandle)
   OverlayClose(hWinHandle)
   Do Events
   // ����������� �������� �� �����
   SendMessage( hWinHandle, WM_PAINT, 0, 0 )
   Do Events
RETURN NIL

///////////////////////////////////////////////////////////////////////////
FUNCTION MG_Info( cMsg, cTitle )
   LOCAL hParentWin := GetFormHandle( ThisWindow.Name )
   LOCAL bInit := NIL //{|| this.topmost := .t. }
   DEFAULT cTitle := "����"

   Darken2Open(hParentWin)             // ��������� �� �����

   SET MSGALERT FONTCOLOR TO BLACK
   SET MSGALERT BACKCOLOR TO { 141, 179, 226 }

   AlertStop( cMsg, cTitle, "iAlert64", 64, { { 84, 141, 212 } }, .T., bInit )

   Darken2Close(hParentWin)            // ��������� �� �����

RETURN NIL

///////////////////////////////////////////////////////////////////////////
FUNCTION MG_Stop( cMsg, cTitle )
   LOCAL hParentWin := GetFormHandle( ThisWindow.Name )
   LOCAL bInit      := {|| this.topmost := .t. }
   DEFAULT cTitle := "����"

   Darken2Open(hParentWin)             // ��������� �� �����

   SET MSGALERT FONTCOLOR TO BLACK
   SET MSGALERT BACKCOLOR TO { 255, 178, 178 }

   AlertStop( cMsg, cTitle, "iStop64", 64, { { 217, 67, 67 } }, .T., bInit )

   Darken2Close(hParentWin)            // ��������� �� �����

RETURN NIL

//////////////////////////////////////////////////////////////////////////
FUNCTION MG_Exclam(cMsg, cTitle)
   LOCAL hParentWin := GetFormHandle( ThisWindow.Name )
   LOCAL bInit      := {|| this.topmost := .t. }
   DEFAULT cTitle := "��������"

   Darken2Open(hParentWin)             // ��������� �� �����

   SET MSGALERT FONTCOLOR TO BLACK
   SET MSGALERT BACKCOLOR TO { 238, 249, 142 }   // ������-�����

   AlertExclamation( cMsg, cTitle, "iSmile64", 64, { { 217, 67, 67 } }, .T., bInit )

   Darken2Close(hParentWin)            // ��������� �� �����

   RETURN NIL

////////////////////////////////////////////////////////////////////////////////
FUNCTION MG_Debug( ... )
   LOCAL i, cMsg, nCnt := PCount()
   LOCAL bInit := {|| this.topmost := .t. }

   cMsg := ProcNL( 1 ) + ";"
   cMsg += ProcNL( 2 ) + ";;"

   FOR i = 1 TO nCnt
      cMsg += hb_ValToExp( PValue( i ) ) + iif( i < nCnt, ", ", "" )
   NEXT

   SET MSGALERT BACKCOLOR TO { 190, 190, 190 }   // ������-�����
   AlertStop(cMsg, "�������", "iDebug64", 64, { { 126, 126, 126 } }, .T., bInit)

RETURN cMsg


///////////////////////////////////////////////////////////////////////////
Function MG_YesNo(cMsg, cTitle, cIcoRes, nIcoSize, cParentWin)
   LOCAL hParentWin, nI, lRet := .F.
   LOCAL aBtnColor := { LGREEN , {189,30,73} }
   LOCAL aBtnMsg   := {"&����������", "&������"}
   DEFAULT cParentWin := _HMG_ThisFormName
   DEFAULT cIcoRes    := "iSmile64", nIcoSize := 64
   DEFAULT cTitle     := "��� �����"

   IF ! empty(cParentWin) .and. _IsWindowDefined( cParentWin )
       hParentWin := GetFormHandle( cParentWin )
   ENDIF
   IF ! empty( hParentWin )
      hParentWin := GetFormHandle( cParentWin )
      Darken2Open(hParentWin)             // ��������� �� �����
   ENDIF

   SET MSGALERT FONTCOLOR TO WHITE
   SET MSGALERT BACKCOLOR TO { 178, 162, 199 }
   _HMG_ModalDialogReturn := 2
   nI := HMG_Alert( cMsg, aBtnMsg, cTitle, Nil, cIcoRes, nIcoSize, aBtnColor )
   IF nI == 1
      lRet := .T.
   ENDIF
   _HMG_ModalDialogReturn := 1

   IF ! empty( hParentWin )
      Darken2Close(hParentWin)            // ��������� �� �����
   ENDIF

   RETURN lRet

////////////////////////////////////////////////////////////////////
FUNCTION HMG_SetMousePos( nHandle, y1, x1 )
   LOCAL c := _HMG_MouseCol
   LOCAL r := _HMG_MouseRow
   Local y := GetWindowRow(nHandle)
   Local x := GetWindowCol(nHandle)
   Default y1 := 1, x1 := 1

   SetCursorPos( x + x1, y + y1 )

RETURN {c,r}

////////////////////////////////////////////////////////////////////
FUNCTION HMG_MouseGet()
   LOCAL x := _HMG_MouseCol
   LOCAL y := _HMG_MouseRow
RETURN {x,y}

////////////////////////////////////////////////////////////////////
FUNCTION HMG_MouseSet(aXY)
   LOCAL aXYold := HMG_MouseGet()
   SetCursorPos( aXY[1], aXY[2] )
RETURN aXYold

///////////////////////////////////////////////////////////////////////////////
FUNCTION _GetDesktopHeight()
   LOCAL nHeight, cMode

   IF TYPE('cPubClientDisplayMode') != "U"
      // �������� ������� ������
      cMode   := LOWER( M->cPubClientDisplayMode )
      nHeight := VAL( SUBSTR(cMode,AT("x",cMode)+1) )
   ELSE
      // ("������! �� ��������� PUBLIC cPubClientDisplayMode � ������� ������ !")
      // �������� ������ ������
      //nHeight := GetDesktopHeight()
      nHeight := System.ClientHeight      // ������ �������� ����� ���������� - ������ �����
   ENDIF

   RETURN nHeight

///////////////////////////////////////////////////////////////////////////////
FUNCTION _GetDesktopWidth()
   LOCAL nWidth, cMode

   IF TYPE('cPubClientDisplayMode') != "U"
      // �������� ������� ������
      cMode  := LOWER( M->cPubClientDisplayMode )
      nWidth := VAL( SUBSTR(cMode,1,AT("x",cMode)-1) )
   ELSE
      // ("������! �� ��������� PUBLIC cPubClientDisplayMode � ������� ������ !")
      // �������� ������ ������
      //nWidth := GetDesktopWidth()
      nWidth := System.ClientWidth  // ������ �������� ����� ����������
   ENDIF

   RETURN nWidth

///////////////////////////////////////////////////////////////////////////////
Function ModeScreen()   // ������ �������, ������� ��� �������������
   LOCAL cMsg, nMode := 0

   IF _GetDesktopHeight() < 600
      cMsg := DTOC(DATE())+" "+TIME()+" - ������ !" + CRLF + CRLF
      cMsg += "���������� ������ ������ ���� �� ����� 800�600 !" + CRLF + CRLF
      cMsg += "� � ��� ������: " + LTRIM(STR(GetDesktopWidth()))+"x"+LTRIM(STR(GetDesktopHeight())) + CRLF + CRLF
      cMsg += "�������� ���������� ������ !" + CRLF
      MsgStop( cMsg )
      nMode := 1
      RETURN nMode
   ENDIF

   IF _GetDesktopWidth() == 800
      nMode := 1
   ELSEIF _GetDesktopWidth() < 1024
      nMode := 1
   ELSEIF _GetDesktopWidth() == 1024
      nMode := 2
   ELSEIF _GetDesktopWidth() == 1152
      nMode := 3
   ELSEIF _GetDesktopWidth() == 1201
      nMode := 4
   ELSEIF _GetDesktopWidth() == 1280
      nMode := 5
   ELSE
      nMode := 6
   ENDIF

RETURN nMode

//////////////////////////////////////////////////////////////////////
Function ModeSizeFont()
   LOCAL nSize := 10

   IF _GetDesktopHeight() == 600
      nSize := 10
   ELSEIF _GetDesktopHeight() == 768
      nSize := 11
   ELSEIF _GetDesktopHeight() == 800
      nSize := 12
   ELSEIF _GetDesktopHeight() > 800 .AND. ;
             _GetDesktopHeight() < 1050
      nSize := 14
   ELSEIF _GetDesktopHeight() >= 1050 .AND. ;
             _GetDesktopHeight() <= 1080
      nSize := 18
   ELSEIF _GetDesktopHeight() == 1152
      nSize := 20
   ELSEIF _GetDesktopHeight() >= 1200
      nSize := 22
   ELSE
      //nSize := 14
   ENDIF

   nSize := IIF(LargeFonts(),nSize-2,nSize)

RETURN nSize

/*---------------------------------------------------------------------------
 * MINIGUI - Harbour Win32 GUI library
*/
*----------------------------------------------------------------------------*
FUNCTION GetTxtWidth( cText, nFontSize, cFontName, lBold )  // �������� Width ������
*----------------------------------------------------------------------------*
   LOCAL hFont, nWidth
   DEFAULT cText     := REPL('A', 2)        ,  ;
           cFontName := _HMG_DefaultFontName,  ;   // �� MiniGUI.Init()
           nFontSize := _HMG_DefaultFontSize,  ;   // �� MiniGUI.Init()
           lBold     := .F.

   IF Valtype(cText) == 'N'
      cText := repl('A', cText)
   ENDIF

   hFont  := InitFont(cFontName, nFontSize, lBold)
   nWidth := GetTextWidth(0, cText, hFont)         // ������ ������
   DeleteObject (hFont)

   RETURN nWidth

*----------------------------------------------------------------------------*
FUNCTION GetTxtHeight( cText, nFontSize, cFontName, lBold )  // �������� Height ������
*----------------------------------------------------------------------------*
   LOCAL hFont, nHeight
   DEFAULT cText     := "B"                 ,  ;
           cFontName := _HMG_DefaultFontName,  ;   // �� MiniGUI.Init()
           nFontSize := _HMG_DefaultFontSize,  ;   // �� MiniGUI.Init()
           lBold     := .F.

   hFont := InitFont( cFontName, nFontSize, lBold )
   nHeight := GetTextHeight( 0, cText , hFont )    // ������ ������
   DeleteObject( hFont )

   RETURN nHeight

///////////////////////////////////////////////////////////////////
// ������� ������� �� ������������ ������ �����
FUNCTION SetFontSizeTextMax(cForm, cObj, nWDel, nHDel)
   LOCAL cFText, cFName, lFBold, nWidth, nHeight, nFSize, cFType
   DEFAULT nWDel := 5, nHDel := 5

   cFType := GetProperty( cForm, cObj, "Type" )
   IF cFType == "LABEL" .OR. cFType == "GETBOX" .OR. cFType == "TEXTBOX"
      cFText := GetProperty( cForm, cObj, "Value"   )
   ELSE
      cFText := GetProperty( cForm, cObj, "Caption" )
   ENDIF
   cFName  := GetProperty( cForm, cObj, "FontName"     )
   lFBold  := GetProperty( cForm, cObj, "FontBold"     )
   nWidth  := GetProperty( cForm, cObj, "ClientWidth"  ) - nWDel
   nHeight := GetProperty( cForm, cObj, "ClientHeight" ) - nHDel

   IF LEN(cFText) > 0
      nFSize  := GetFontSize4Text( cFText, cFName, , lFBold, nWidth, nHeight )
      SetProperty(cForm, cObj, "Fontsize", nFSize)  // �������� ������ �����
   ENDIF

RETURN NIL

////////////////////////////////////////////////////////////////////////
// ������� ������� �� ����������� ������ �����
FUNCTION SetFontSizeTextMin(cForm, cObj, nSize)
   LOCAL cFText, cFName, lFBold, nWidth, nHeight, nFSize, cFType
   LOCAL nFWLbl, lMin := .T.
   DEFAULT nSize := 25

   cFType := GetProperty( cForm, cObj, "Type" )
   IF cFType == "LABEL" .OR. cFType == "GETBOX" .OR. cFType == "TEXTBOX"
      cFText := GetProperty( cForm, cObj, "Value"   )
   ELSE
      cFText := GetProperty( cForm, cObj, "Caption" )
   ENDIF
   cFName  := GetProperty( cForm, cObj, "FontName"     )
   lFBold  := GetProperty( cForm, cObj, "FontBold"     )
   nWidth  := GetProperty( cForm, cObj, "ClientWidth"  ) - nSize
   nHeight := GetProperty( cForm, cObj, "ClientHeight" ) - nSize
   nFSize  := GetProperty( cForm, cObj, "Fontsize"     )

   DO WHILE lMin
      nFWLbl  := GetTxtWidth( cFText, nFSize, cFName, lFBold )
      IF nFWLbl > nWidth
         nFSize := nFSize - 2
      ELSE
         lMin := .F.
      ENDIF
   ENDDO

   // �������� ������ �����
   SetProperty(cForm, cObj, "Fontsize", nFSize)

RETURN NIL

//////////////////////////////////////////////////////////////////
// ������� ������ ������������ ������ �����
// ��� �������� ������ �� ������ � ������
FUNCTION GetFontSize4Text( cText, cFontName, nFontSize, lBold, nWmax, nHmax )
   LOCAL hFont, nK := 1, cT := "", nHeig, nWidt
   LOCAL nSize := 6 // App.FontSize

   IF CRLF $ cText
      AEval(hb_ATokens(cText, CRLF), {|t,n| nK := Max( nK, n ), cT := iif( Len( t ) > Len( cT ), t, cT ) })
      cText := cT
   ENDIF

//   nSize := nFontSize
   lBold := !Empty(lBold)
   hFont := InitFont( cFontName, nSize, lBold )
   nHeig := GetTextHeight( 0, cText, hFont ) * nK
   nWidt := GetTextWidth ( 0, cText, hFont )
   DeleteObject( hFont )

   IF     nHeig > nHmax .and. nWidt > nWmax
      DO WHILE .T.
         hFont := InitFont( cFontName, nSize, lBold )
         nHeig := GetTextHeight( 0, cText, hFont ) * nK
         nWidt := GetTextWidth ( 0, cText, hFont )
         DeleteObject( hFont )
         IF nHeig <= nHmax .or. nWidt <= nWmax ; nSize ++ ; EXIT
         ENDIF
         nSize --
      ENDDO
   ELSEIF nHeig < nHmax .and. nWidt < nWmax
      DO WHILE .T.
         hFont := InitFont( cFontName, nSize, lBold )
         nHeig := GetTextHeight( 0, cText, hFont ) * nK
         nWidt := GetTextWidth ( 0, cText, hFont )
         DeleteObject( hFont )
         IF nHeig >= nHmax .or. nWidt >= nWmax ; nSize -- ; EXIT
         ENDIF
         nSize ++
      ENDDO
   ENDIF

RETURN iif( Empty(nFontSize), nSize, Min( nFontSize, nSize ) )

//////////////////////////////////////////////////////////////////
// ������� ������ ������������ ������ �����
// ��� �������� ������ �� ������ � ������
FUNCTION FontSizeMaxAutoFit( cText, cFontName, lBold, nWidth, nHeight )
   LOCAL nTxtWidth, nFSize, lExit := .T.

   cText := cText + "AA" // ��� �������� ����� � ������
   nFSize := 6
   DO WHILE lExit
      nTxtWidth := GetTxtWidth( cText, nFSize, cFontName, lBold )
      IF nTxtWidth >= nWidth
         lExit := .F.
         nFSize--
      ELSE
         nFSize++
      ENDIF
      IF nFSize >= nHeight
         lExit := .F.
         nFSize--
      ENDIF
   ENDDO

RETURN nFSize

//////////////////////////////////////////////////////////////////
// ������� ������ ������������ ������ �����
// �� ������ ������ ������ ������
FUNCTION ButtonFontSizeMaxCaption(aBtnCap, nWBtn, cFName, lFBold)
   LOCAL aBtnFS, nJ, nF, cCapt, nWidth, nHeight, nRetFS

   aBtnFS  := ARRAY(LEN(aBtnCap))
   AFILL(aBtnFS,0)
   nWidth  := nWBtn - ModeDelWidth()
   nHeight := nWBtn

   FOR nJ := 1 TO LEN(aBtnCap)
      cCapt := aBtnCap[nJ]
      IF AT(";",cCapt) > 0
         cCapt := StrTran( cCapt, ";" , CRLF )
         // ������� �������������� ������ �� ������. ������ 2 ����� ������ ������
      ENDIF
      IF AT(CRLF,cCapt) > 0
         // ������� �������������� ������ �� ������. ������ 2 ����� ������ ������
      ENDIF
      nF := FontSizeMaxAutoFit( cCapt, cFName, lFBold, nWidth, nHeight )
      aBtnFS[nJ] := nF
   NEXT

   nRetFS := 90
   FOR nF := 1 TO LEN(aBtnFS)
      nRetFS := MIN(aBtnFS[nF],nRetFS)
   NEXT

RETURN nRetFS

///////////////////////////////////////////////////////////////////////////////
Function ModeDelWidth()
   LOCAL nWDel := 0, nW := _GetDesktopWidth()

   IF nW <= 1024
      nWDel := 10
   ELSEIF nW > 1024 .AND. nW <= 1200
      nWDel := 20
   ELSEIF nW > 1200 .AND. nW <= 1280
      nWDel := 30
   ELSEIF nW > 1280 .AND. nW <= 1600
      nWDel := 50
   ELSE
      nWDel := 90
   ENDIF

RETURN nWDel

* ======================================================================
* ��� ������� ����� �������� ����� ������ � ���
FUNCTION GetFileNameMaskNum( cFile ) //FileNameMaskNum( cFile )
   LOCAL i := 0, cPth, cFil, cExt

   If ! hb_FileExists(cFile); RETURN cFile
   EndIf

   hb_FNameSplit(cFile, @cPth, @cFil, @cExt)

   WHILE ( hb_FileExists( hb_FNameMerge(cPth, cFil + '(' + hb_ntos(++i) + ')', cExt) ) )
   END

   RETURN hb_FNameMerge(cPth, cFil + '(' + hb_ntos(i) + ')', cExt)

* =========================================================================
* ��� ������� ����� �������� ����� ������ � ��� ����� ��� ���������� �����
FUNCTION GetFileNameMaskNumNotExt( cFile )
   LOCAL i := 0, cPth, cFil, cExt

   If ! hb_FileExists(cFile); RETURN cFile
   EndIf

   hb_FNameSplit(cFile, @cPth, @cFil, @cExt)

   WHILE ( hb_FileExists( hb_FNameMerge(cPth, cFil + '(' + hb_ntos(++i) + ')', cExt) ) )
   END

   RETURN hb_FNameMerge(cPth, cFil + '(' + hb_ntos(i) + ')', cExt)

*----------------------------------------------------------------------------*
// ������� �������� ���������� �� ������� ���� � ���������� �������
// ������ ������:        nSizeFont := IIF(Large2Fonts(),9,11)
// ��� �� - 120%, ��� Win7 - 125%
FUNCTION Large2Fonts()
LOCAL hDC, nPixelX, lRet := .F.
hDC := CreateDC( "DISPLAY", "", "" )
nPixelX := GetDevCaps( hDC )
DeleteDC( hDc )
IF nPixelX > 100
   lRet := .T.
ENDIF
RETURN (lRet)

*----------------------------------------------------------------------------*
// ������� �������� ���������� �� ������� ���� � ���������� �������
// ������ ������:        nSizeFont := IIF(LargeFonts(),9,11)
// ��� �� - 120%, ��� Win7 - 125%
FUNCTION LargeFonts()
LOCAL hDC, nPixelX
hDC := CreateDC( "DISPLAY", "", "" )
nPixelX := GetDevCaps( hDC )
DeleteDC( hDc )
RETURN (nPixelX == 120)

#pragma BEGINDUMP
#include <windows.h>
#include "hbapi.h"
HB_FUNC( CREATEDC )
{
   hb_retnl( ( LONG ) CreateDC( hb_parc( 1 ), hb_parc( 2 ), hb_parc( 3 ), 0 ) );
}
HB_FUNC( DELETEDC )
{
   hb_retl( DeleteDC( ( HDC ) hb_parnl( 1 ) ) );
}
HB_FUNC ( GETDEVCAPS )
{
 INT      ix;
 HDC      hdc;
 hdc = ( HDC ) hb_parnl( 1 );

 ix  = GetDeviceCaps( hdc, LOGPIXELSX );

 hb_retni( (UINT) ix );
}
#pragma ENDDUMP

