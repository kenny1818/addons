/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 */

#include "minigui.ch"

PROCEDURE Main()

   DEFINE WINDOW Form_1 ;
         AT 0, 0 ;
         WIDTH 334 ;
         HEIGHT 276 ;
         TITLE 'Create Desktop Shortcut' ;
         MAIN

      DEFINE MAIN MENU

         DEFINE POPUP "Test"
            MENUITEM 'Create Desktop Shortcut' ACTION CreateShortcut()
            MENUITEM 'Remove Desktop Shortcut' ACTION DeleteShortcut( "Calculator" )
            SEPARATOR
            ITEM 'Exit' ACTION Form_1.Release()
         END POPUP

      END MENU

   END WINDOW

   Form_1.Center()
   Form_1.Activate()

RETURN

*------------------------------------------------------------------------------*
PROCEDURE CreateShortcut()
*------------------------------------------------------------------------------*

   LOCAL cDesktop := GetDesktopFolder()
   LOCAL cLinkName := "Calculator"
   LOCAL cExeName := GetWindowsFolder() + "\Calc.exe"
   LOCAL cIco, nSuccess

   IF ! File( cExeName )
      cExeName := GetSystemFolder() + "\Calc.exe"
   ENDIF

   cIco := cExeName

   CREATE LINK FILE cDesktop + "\" + cLinkName + ".lnk" ;
      TARGETFILE cExeName ;
      DESCRIPTION "Classic arithmetic tasks with an on-screen calculator." ;
      WORKING DIRECTORY cFilePath( cExeName ) ;
      ICON LOCATION cIco ;
      RESULT nSuccess

   IF nSuccess == S_OK
      MsgInfo( "Shortcut was created on desktop successfully.", "Result" )
   ELSE
      MsgStop( "Create Link Error!", "ERROR", , .F. )
   ENDIF

RETURN

*------------------------------------------------------------------------------*
PROCEDURE DeleteShortcut( cLink )
*------------------------------------------------------------------------------*

   LOCAL WshShell := CreateObject( "WScript.Shell" )
   LOCAL DesktopFolder := WshShell:SpecialFolders:Item( "Desktop" )
   LOCAL FSO := CreateObject( "Scripting.fileSystemObject" )
   LOCAL cLinkName, lError := .F.

   cLinkName := DesktopFolder + "\" + cLink + ".lnk"
   IF FSO:FileExists( cLinkName )
      FSO:DeleteFile( cLinkName )
   ELSE
      lError := .T.
      MsgAlert( "Shortcut <" + cLink + "> not found on desktop.", "Result" )
   ENDIF

   IF ! lError
      MsgInfo( "Shortcut was removed from desktop.", "Result" )
   ENDIF

   FSO := NIL
   WshShell := NIL

RETURN
