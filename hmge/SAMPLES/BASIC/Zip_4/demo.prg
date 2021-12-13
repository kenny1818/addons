/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Based on the built-in ZIP Support in Windows.
 * The usage was explained by Jimmy on HMG forum 04/Apr/2020
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
 */

#include <minigui.ch>
#include "directry.ch"
#include "fileio.ch"


#command COMPRESS [ FILES ] <afiles> ;
      TO <zipfile> ;
      BLOCK <block> ;
      [ <ovr: OVERWRITE> ] ;
      => ;
      COMPRESSFILES ( <zipfile>, <afiles>, <block>, <.ovr.> )


#command UNCOMPRESS [ FILE ] <zipfile> ;
      EXTRACTPATH <extractpath> ;
      [ BLOCK <block> ] ;
      [ <createdir: CREATEDIR> ] ;
      => ;
      UNCOMPRESSFILES ( <zipfile>, <block>, <extractpath>, <.createdir.> )


*------------------------------------------------------------------------------*
PROCEDURE Main()
*------------------------------------------------------------------------------*

   DEFINE WINDOW Form_1 ;
         AT 0, 0 ;
         WIDTH 400 HEIGHT 215 ;
         TITLE "Backup" ;
         ICON "demo.ico" ;
         MAIN ;
         NOMAXIMIZE NOSIZE ;
         FONT "Arial" SIZE 9

      DEFINE BUTTON Button_1
         ROW 140
         COL 45
         WIDTH 150
         HEIGHT 30
         CAPTION "&Create Backup"
         ACTION CreateZip()
      END BUTTON

      DEFINE BUTTON Button_2
         ROW 140
         COL 205
         WIDTH 150
         HEIGHT 28
         CAPTION "&Recover Backup"
         ACTION UnZip()
      END BUTTON

      DEFINE PROGRESSBAR ProgressBar_1
         ROW 60
         COL 45
         WIDTH 310
         HEIGHT 30
         RANGEMIN 0
         RANGEMAX 10
         VALUE 0
      END PROGRESSBAR

      DEFINE LABEL Label_1
         ROW 100
         COL 25
         WIDTH 350
         HEIGHT 20
         VALUE ""
         FONTNAME "Arial"
         FONTSIZE 10
         TOOLTIP ""
         FONTBOLD .T.
         TRANSPARENT .T.
         CENTERALIGN .T.
      END LABEL

      ON KEY ESCAPE ACTION Form_1.RELEASE

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN

*------------------------------------------------------------------------------*
FUNCTION CreateZip()
*------------------------------------------------------------------------------*

   LOCAL aDir := Directory( "*.prg", "D" ), aFiles := {}, nLen
   LOCAL cPath := CurDrive() + ":\" + CurDir() + "\"

   FillFiles( aFiles, aDir, cPath )

   IF ( nLen := Len( aFiles ) ) > 0
      Form_1.ProgressBar_1.RANGEMIN := 0
      Form_1.ProgressBar_1.RANGEMAX := nLen
      MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR { 0, 0, 0 }

      COMPRESS aFiles ;
         TO cPath + 'Backup.Zip' ;
         BLOCK {| cFile, nPos | ProgressUpdate( nPos, cFile, .T. ) } ;
         OVERWRITE

      InkeyGUI( 250 )
      MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR { 0, 0, 255 }
      Form_1.Label_1.VALUE := 'Backup is finished'
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION ProgressUpdate( nPos, cFile, lShowFileName )
*------------------------------------------------------------------------------*

DEFAULT lShowFileName := .F.

   Form_1.ProgressBar_1.VALUE := nPos
   Form_1.Label_1.VALUE := cFileNoPath( cFile )

   IF lShowFileName
      InkeyGUI( 250 )
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION UnZip()
*------------------------------------------------------------------------------*

   LOCAL cCurDir := GetCurrentFolder(), cArchive

   cArchive := Getfile ( { { 'ZIP Files', '*.zip' } }, 'Open File', cCurDir, .F., .T. )

   IF ! Empty( cArchive )
      Form_1.ProgressBar_1.RANGEMIN := 0
      Form_1.ProgressBar_1.RANGEMAX := GetFilesCountInZip( cArchive )
      MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR { 0, 0, 0 }

      UNCOMPRESS cArchive ;
         EXTRACTPATH cCurDir + "\BackUp" ;
         BLOCK {| cFile, nPos | ProgressUpdate( nPos, cFile, .T. ) } ;
         CREATEDIR

      InkeyGUI( 250 )
      MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR { 0, 0, 255 }
      Form_1.Label_1.VALUE := 'Restoration of Backup is finished'
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION FillFiles( aFiles, cDir, cPath )
*------------------------------------------------------------------------------*

   LOCAL aSubDir, cItem

   FOR cItem := 1 TO Len( cDir )
      IF cDir[ cItem ][ F_ATTR ] <> "D"
         AAdd( aFiles, cPath + cDir[ cItem ][ F_NAME ] )
      ELSEIF cDir[ cItem ][ F_NAME ] <> "." .AND. cDir[ cItem ][ F_NAME ] <> ".."
         aSubDir := Directory( cPath + cDir[ cItem ][ F_NAME ] + "\*.*", "D" )
         aFiles := FillFiles( aFiles, aSubdir, cPath + cDir[ cItem ][ F_NAME ] + "\" )
      ENDIF
   NEXT

RETURN aFiles

*------------------------------------------------------------------------------*
FUNCTION GetFilesCountInZip ( zipfile )
*------------------------------------------------------------------------------*

RETURN GetZipObject( zipfile ):items():Count()

*------------------------------------------------------------------------------*
STATIC FUNCTION GetZipObject( zipfile )
*------------------------------------------------------------------------------*

   IF _SetGetGlobal( "oShell" ) == NIL

      STATIC oShell AS GLOBAL VALUE CreateObject( "Shell.Application" )

      STATIC oZip AS GLOBAL VALUE _SetGetGlobal( "oShell" ):NameSpace( ZipFile )

   ENDIF

RETURN _SetGetGlobal( "oZip" )

*------------------------------------------------------------------------------*
PROCEDURE UNCOMPRESSFILES ( zipfile, block, extractpath, createdir )
*------------------------------------------------------------------------------*

   LOCAL oZip
   LOCAL oNameDest

   IF createdir .AND. ! hb_DirExists( extractpath )

      hb_DirBuild( extractpath )

   ENDIF

   DO EVENTS

   oZip := GetZipObject( zipfile )

   oNameDest := _SetGetGlobal( "oShell" ):NameSpace( extractpath )

   oNameDest:CopyHere( oZip:items(), 0x10 )

   IF ValType( block ) == 'B'
      Eval( block, Directory( extractpath + "\*.prg" )[ 1 ][ F_NAME ], 1 )
   ENDIF

   ASSIGN GLOBAL oZip := NIL
   ASSIGN GLOBAL oShell := NIL

RETURN

*------------------------------------------------------------------------------*
PROCEDURE COMPRESSFILES ( zipfile, afiles, block, ovr )
*------------------------------------------------------------------------------*

   LOCAL oZip
   LOCAL cFile
   LOCAL i
   LOCAL xCount
   LOCAL nCount
   LOCAL nHandle
   LOCAL iMax
   LOCAL aHead := { 80, 75, 5, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

   IF ovr == .T.

      IF File( zipfile )
         DELETE FILE ( zipfile )
      ENDIF

   ENDIF

   // create ZIP and write Header
   //
   nHandle := FCreate( ZipFile, FC_NORMAL )
   iMax := Len( aHead )
   FOR i := 1 TO iMax
      FWrite( nHandle, Chr( aHead[ i ] ) )
   NEXT
   FClose( nHandle )

   // create COM Object
   //
   oZip := GetZipObject( zipfile )

   FOR i := 1 TO Len( aFiles )

      cFile := aFiles[ i ]

      Eval( block, cFile, i )

      oZip:CopyHere( cFile ) // copy one file

      // wait until all files are written
      //
      xCount := 0
      DO WHILE .T.
         nCount := oZip:items():Count()
         IF nCount >= i
            EXIT
         ENDIF
         DO EVENTS
         IF ++xCount > 50
            EXIT
         ENDIF
      ENDDO

   NEXT i

   ASSIGN GLOBAL oZip := NIL
   ASSIGN GLOBAL oShell := NIL

RETURN
