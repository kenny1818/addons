/*
 * MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

STATIC oGif
*--------------------------------------------------------*
Function Main
*--------------------------------------------------------*
	Local cFile := "telegraaf.gif"

	SET MULTIPLE OFF WARNING

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 320 HEIGHT 240 ;
		TITLE 'MiniGUI Label Demo' ;
		MAIN ;
		ON INIT CircleProgressAnimation( cFile )

		DEFINE LABEL Label_1
			ROW	20
			COL	20
			VALUE ' Animated Label '
			AUTOSIZE .T.
			FONTNAME 'Times New Roman'
			FONTSIZE 10
			FONTCOLOR { 0, 70, 213 }
		END LABEL

		DEFINE BUTTON Button_1
			Row     18
			Col     130
			Caption 'Start'
			OnClick IIF( !oGif:IsRunning(), oGif:Play(), )
		END BUTTON

		DEFINE BUTTON Button_2
			Row     50
			Col     130
			Caption 'Stop'
			OnClick IIF( oGif:IsRunning(), oGif:Stop(), )
		END BUTTON

		ON KEY ESCAPE ACTION ThisWindow.Release

	END WINDOW

	CENTER WINDOW Form_Main

	ACTIVATE WINDOW Form_Main

Return Nil

*--------------------------------------------------------*
Function CircleProgressAnimation( cGIFfile )
*--------------------------------------------------------*
	Local aPictInfo, r, c

	aPictInfo := hb_GetImageSize( cGIFfile )

	@ 20 + Form_Main.Label_1.Height, 50 ANIGIF Gif_1 ;
		OBJ oGif ;
		PARENT Form_Main ;
		PICTURE cGIFfile ;
		WIDTH aPictInfo [1] ;
		HEIGHT aPictInfo [2]

	r := Form_Main.Label_1.Row
	c := Form_Main.Label_1.Col

	DRAW RECTANGLE IN WINDOW Form_Main ;
		AT r - 2, c - 2 TO r + Form_Main.Label_1.Height + Form_Main.Gif_1.Height + 2, ;
			c + Form_Main.Label_1.Width + 2 ;
		PENCOLOR { 100, 100, 100 }

Return Nil
