/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 */

#include "hmg.ch"

FUNCTION Main()

   SET DEFAULT ICON TO "DefaultIcon.ICO"
   SET EVENTS FUNCTION TO MYEVENTS

   DEFINE WINDOW Form_1 ;
         WIDTH 640 ;
         HEIGHT 480 ;
         TITLE "Set Default Icon To Dialog Box" ;
         MAIN

      @ 50, 100 BUTTON Button_1 ;
         CAPTION "Click Me" ;
         ACTION MsgInfo( "Text", "Title" )

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN NIL


#define WM_WINDOWPOSCHANGING  70
*--------------------------------------------------------*
FUNCTION MyEvents ( hWnd, nMsg, wParam, lParam )
*--------------------------------------------------------*

   LOCAL result := 0

	SWITCH nMsg
	CASE WM_WINDOWPOSCHANGING

		_HMG_SetDialogBoxIcon()
		EXIT

	DEFAULT
		result := Events( hWnd, nMsg, wParam, lParam )
	END

RETURN result


FUNCTION _HMG_SetDialogBoxIcon()

   LOCAL hWnd := GetActiveWindow()

   IF _SetGetGlobal( "hIcon" ) == NIL
      STATIC hIcon AS GLOBAL VALUE 0, Old_hWnd AS GLOBAL VALUE 0
   ENDIF

   IF _SetGetGlobal( "Old_hWnd" ) <> hWnd .AND. GetClassName( hWnd ) == "#32770"

      ASSIGN GLOBAL Old_hWnd := hWnd

      IF _SetGetGlobal( "hIcon" ) == 0
         ASSIGN GLOBAL hIcon := LOADICONBYNAME( _HMG_DefaultIconName, 0, 0 )
      ENDIF

      IF _SetGetGlobal( "hIcon" ) <> 0
         #define GCLP_HICON   (-14)
         SetClassLongPtr( hWnd, GCLP_HICON, _SetGetGlobal( "hIcon" ) )
      ENDIF

   ENDIF

RETURN NIL

#pragma BEGINDUMP

#include <mgdefs.h>

//        SetClassLongPtr (hWnd, nIndex, dwNewLong) --> return dwRetLong
HB_FUNC ( SETCLASSLONGPTR )
{
   HWND hWnd           = (HWND) HB_PARNL (1);
   int  nIndex         = (int)  hb_parnl (2);
   LONG_PTR dwNewLong  = (LONG_PTR) HB_PARNL (3);

   ULONG_PTR dwRetLong = SetClassLongPtr( hWnd, nIndex, dwNewLong );

   HB_RETNL( (LONG_PTR) dwRetLong );
}

#pragma ENDDUMP
