/*
 * $Id: winprint.prg $
 */
/*
 * ooHG source code:
 * HBPRINTER printing library
 *
 * Copyright 2005-2021 Vicente Guerra <vicente@guerra.com.mx> and contributors of
 * the Object Oriented (x)Harbour GUI (aka OOHG) Project, https://oohg.github.io/
 *
 * Based upon:
 * HBPRINT and HBPRINTER libraries
 * Copyright 2002 Richard Rylko <rrylko@poczta.onet.pl>
 * http://rrylko.republika.pl
 * Original contributions made by
 * Eduardo Fernandes <modalsist@yahoo.com.br> and
 * Mitja Podgornik <yamamoto@rocketmail.com>
 *
 * Portions of this project are based upon:
 *    "Harbour MiniGUI Extended Edition Library"
 *       Copyright 2005-2021 MiniGUI Team, http://hmgextended.com
 *    "Harbour GUI framework for Win32"
 *       Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 *       Copyright 2001 Antonio Linares <alinares@fivetech.com>
 *    "Harbour MiniGUI"
 *       Copyright 2002-2016 Roberto Lopez <mail.box.hmg@gmail.com>
 *    "Harbour Project"
 *       Copyright 1999-2021 Contributors, https://harbour.github.io/
 */
/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file LICENSE.txt. If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1335, USA (or download from http://www.gnu.org/licenses/).
 *
 * As a special exception, the ooHG Project gives permission for
 * additional uses of the text contained in its release of ooHG.
 *
 * The exception is that, if you link the ooHG libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the ooHG library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the ooHG
 * Project under the name ooHG. If you copy code from other
 * ooHG Project or Free Software Foundation releases into a copy of
 * ooHG, as the General Public License permits, the exception does
 * not apply to the code that you add in this way. To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for ooHG, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 */


#include "hbclass.ch"

/*
 * Define NO_GUI macro for non-ooHG compilation.
 * It allows to compile HBPRINTER library for console mode.
 * Fully functional but no preview.
 */

#ifndef NO_GUI
   #include "oohg.ch"
#endif

#define NO_HBPRN_DECLARATION
#include "winprint.ch"

// For DevCaps
#define DI_VERT_SIZE          1
#define DI_HORZ_SIZE          2
#define DI_VERT_RES           3
#define DI_HORZ_RES           4
#define DI_VERT_LOGPIX        5
#define DI_HORZ_LOGPIX        6
#define DI_VERT_PHYSIZE       7
#define DI_HORZ_PHYSIZE       8
#define DI_VERT_PHYOFFS       9
#define DI_HORZ_PHYOFFS       10
#define DI_VERT_FONTSIZE      11
#define DI_HORZ_FONTSIZE      12
#define DI_ROWS               13
#define DI_COLS               14
#define DI_ORIENTATION        15
#define DI_TMASCENT           16
#define DI_PAPERSIZE          17

// For Pages ( ::MetaFiles)
#define PG_FILE               1
#define PG_VERT_SIZE          2
#define PG_HORZ_SIZE          3
#define PG_VERT_RES           4
#define PG_HORZ_RES           5
#define PG_ORIENTATION        6
#define PG_PAPER_SIZE         7

// For ::aTH
#define TH_ROW                1
#define TH_COL                2
#define TH_HEIGHT             3
#define TH_WIDTH              4
#define TH_HWND               5

// For ::aHS
#define PREVIEW_RECT          1
#define PREVIEW_RECT_TOP      1, 1
#define PREVIEW_RECT_LEFT     1, 2
#define PREVIEW_RECT_BOTTOM   1, 3
#define PREVIEW_RECT_RIGHT    1, 4
#define PREVIEW_RECT_HEIGHT   1, 5
#define PREVIEW_RECT_WIDTH    1, 6

#define PREVIEW_FORM          2
#define PREVIEW_FORM_TOP      2, 1
#define PREVIEW_FORM_LEFT     2, 2
#define PREVIEW_FORM_BOTTOM   2, 3
#define PREVIEW_FORM_RIGHT    2, 4
#define PREVIEW_FORM_HEIGHT   2, 5
#define PREVIEW_FORM_WIDTH    2, 6
#define PREVIEW_FORM_HWND     2, 7

#define PREVIEW_TB            3
#define PREVIEW_TB_TOP        3, 1
#define PREVIEW_TB_LEFT       3, 2
#define PREVIEW_TB_BOTTOM     3, 3
#define PREVIEW_TB_RIGHT      3, 4
#define PREVIEW_TB_HEIGHT     3, 5
#define PREVIEW_TB_WIDTH      3, 6
#define PREVIEW_TB_HWND       3, 7

#define PREVIEW_SB            4
#define PREVIEW_SB_TOP        4, 1
#define PREVIEW_SB_LEFT       4, 2
#define PREVIEW_SB_BOTTOM     4, 3
#define PREVIEW_SB_RIGHT      4, 4
#define PREVIEW_SB_HEIGHT     4, 5
#define PREVIEW_SB_WIDTH      4, 6
#define PREVIEW_SB_HWND       4, 7

#define PREVIEW_PAGE          5
#define PREVIEW_PAGE_TOP      5, 1
#define PREVIEW_PAGE_LEFT     5, 2
#define PREVIEW_PAGE_BOTTOM   5, 3
#define PREVIEW_PAGE_RIGHT    5, 4
#define PREVIEW_PAGE_HEIGHT   5, 5
#define PREVIEW_PAGE_WIDTH    5, 6
#define PREVIEW_PAGE_HWND     5, 7

#define PREVIEW_IMAGE         6
#define PREVIEW_IMAGE_TOP     6, 1
#define PREVIEW_IMAGE_LEFT    6, 2
#define PREVIEW_IMAGE_BOTTOM  6, 3
#define PREVIEW_IMAGE_RIGHT   6, 4
#define PREVIEW_IMAGE_HEIGHT  6, 5
#define PREVIEW_IMAGE_WIDTH   6, 6
#define PREVIEW_IMAGE_HWND    6, 7

#define PREVIEW_THUMBS        7
#define PREVIEW_THUMBS_TOP    7, 1
#define PREVIEW_THUMBS_LEFT   7, 2
#define PREVIEW_THUMBS_BOTTOM 7, 3
#define PREVIEW_THUMBS_RIGHT  7, 4
#define PREVIEW_THUMBS_HEIGHT 7, 5
#define PREVIEW_THUMBS_WIDTH  7, 6
#define PREVIEW_THUMBS_HWND   7, 7

/*--------------------------------------------------------------------------------------------------------------------------------*/
CLASS HBPrinter

   DATA AfterPrint                INIT {|| NIL }
   DATA aHS                       INIT {}
   DATA aOpisy                    INIT {}
   DATA aTH                       INIT {}
   DATA aZoom                     INIT { 0, 0, 0, 0 }
   DATA BaseDoc                   INIT ""
   DATA BeforePrint               INIT {|| .T. }
   DATA BeforePrintCopy           INIT {|| .T. }
   DATA BinNames                  INIT {}
   DATA BkColor                   INIT 0xFFFFFF
   DATA BkMode                    INIT BKMODE_TRANSPARENT
   DATA Brushes                   INIT { {}, {} }
   DATA Cargo                     INIT { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
   DATA ClsPreview                INIT .T.
   DATA CurPage                   INIT 1 PROTECTED
   DATA DevCaps                   INIT { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 }
   DATA DocName                   INIT "HBPRINTER"
   DATA dx                        INIT 0
   DATA dy                        INIT 0
   DATA Error                     INIT 0 READONLY
   DATA Fonts                     INIT { {}, {}, 0, {} }
   DATA hData                     INIT 0
   DATA hDC                       INIT 0
   DATA hDCRef                    INIT 0 PROTECTED
   DATA IloscStron                INIT 0              // 'Ilosc Stron' means 'Number of Pages' in polish
   DATA ImageLists                INIT { {}, {} }
   DATA InMemory                  INIT .F.
   DATA lAbsoluteCoords           INIT .F.
   DATA lEscaped                  INIT .F.
   DATA lGlobalChanges            INIT .T.
   DATA lReportError              INIT .F.
   DATA lReturnRGB                INIT .T.
   DATA MaxCol                    INIT 0
   DATA MaxRow                    INIT 0
   DATA MetaFiles                 INIT {} PROTECTED
   DATA nCopies                   INIT 1
   DATA nFromPage                 INIT 1
   DATA nGroup                    INIT -1
   DATA NoButtonOptions           INIT .F.
   DATA NoButtonSave              INIT .F.
   DATA NotifyOnSave              INIT .F.
   DATA nPages                    INIT {}
   DATA nToPage                   INIT 0
   DATA nWhatToPrint              INIT 0
   DATA oWinPagePreview           INIT NIL
   DATA oWinPreview               INIT NIL
   DATA oWinThumbs                INIT NIL
   DATA Page                      INIT 1
   DATA PaperNames                INIT {}
   DATA Pens                      INIT { {}, {} }
   DATA PolyFillMode              INIT POLYFILL_ALTERNATE
   DATA Ports                     INIT {}
#ifndef NO_GUI
   DATA PreviewMode               INIT .F.
#else
   DATA PreviewMode               INIT .F. PROTECTED
#endif
   DATA PreviewRect               INIT { 0, 0, 0, 0 }
   DATA PreviewScale              INIT 1
   DATA PrinterDefault            INIT ""
   DATA PrinterName               INIT ""
   DATA Printers                  INIT {}
   DATA Printing                  INIT .F.
   DATA PrintingEMF               INIT .F. PROTECTED
   DATA PrintOpt                  INIT 1 PROTECTED
   DATA Regions                   INIT { {}, {} }
   DATA Scale                     INIT 1
   DATA TextColor                 INIT 0
   DATA Thumbnails                INIT .F.
   DATA TimeStamp                 INIT ""
   DATA Units                     INIT 0
   DATA Version                   INIT 2.48 READONLY
   DATA ViewportOrg               INIT { 0, 0 }

   DESTRUCTOR Destroy

   METHOD New
   METHOD SelectPrinter
   METHOD SetDevMode
   METHOD SetUserMode
   METHOD StartDoc
   METHOD SetPage
   METHOD StartPage
   METHOD EndPage
   METHOD EndDoc
   METHOD SetTextColor
   METHOD GetTextColor            INLINE ::TextColor
   METHOD SetBkColor
   METHOD GetBkColor              INLINE ::BkColor
   METHOD SetBkMode
   METHOD GetBkMode               INLINE ::BkMode
   METHOD DefineImageList
   METHOD DrawImageList
   METHOD DefineBrush
   METHOD ModifyBrush
   METHOD SelectBrush
   METHOD DefinePen
   METHOD ModifyPen
   METHOD SelectPen
   METHOD DefineFont
   METHOD ModifyFont
   METHOD SelectFont
   METHOD GetFontNames            INLINE RR_GetFontNames()
   METHOD GetObjByName
   METHOD DrawText
   METHOD TextOut
   METHOD Say
   METHOD SetCharset( charset )   INLINE RR_SetCharset( charset, ::hData, Self )
   METHOD Rectangle
   METHOD RoundRect
   METHOD FillRect
   METHOD FrameRect
   METHOD InvertRect
   METHOD Ellipse
   METHOD Arc
   METHOD ArcTo
   METHOD Chord
   METHOD Pie
   METHOD Polygon
   METHOD PolyBezier
   METHOD PolyBezierTo
   METHOD SetUnits
   METHOD Convert
   METHOD UnConvert
   METHOD DefineRectRgn
   METHOD DefinePolygonRgn
   METHOD DefineEllipticRgn
   METHOD DefineRoundRectRgn
   METHOD CombineRgn
   METHOD SelectClipRgn
   METHOD DeleteClipRgn
   METHOD SetPolyFillMode
   METHOD GetPolyFillMode         INLINE ::PolyFillMode
   METHOD SetViewPortOrg
   METHOD GetViewPortOrg
   METHOD DxColors
   METHOD SetRGB
   METHOD SetTextCharExtra
   METHOD GetTextCharExtra
   METHOD SetTextJustification
   METHOD GetTextJustification
   METHOD SetTextAlign
   METHOD GetTextAlign
   METHOD Picture
   METHOD BitMap
   METHOD MoveTo
   METHOD Line
   METHOD LineTo
   METHOD End
   METHOD GetTextExtent
   METHOD GetTextExtent_MM
   METHOD ReportData
   METHOD InitMessages
   METHOD BasePageName            INLINE ::BaseDoc
   METHOD GetVersion              INLINE ::Version
#ifndef NO_GUI
   METHOD Preview
   METHOD PrevClose
   METHOD PrevPrint
   METHOD PrevShow
   METHOD PrevThumb
   METHOD PrintOption
   METHOD SaveMetaFiles
   METHOD CleanOnPrevClose
#endif

   ENDCLASS

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD New( cLang, cFolder ) CLASS HBPrinter

   LOCAL aPrnPort

   ::hData := RR_CreateHBPrinterData()

   aPrnPort := RR_GetPrinters( ::hData )
   IF ! aPrnPort == ",,"
      aPrnPort := RR_Str2Arr( aPrnPort, ",," )
      AEval( aPrnPort, {| x, xi | aPrnPort[ xi ] := RR_Str2Arr( x, ',' ) } )
      AEval( aPrnPort, {| x | AAdd( ::Printers, x[ 1 ] ), AAdd( ::Ports, x[ 2 ] ) } )
      ::PrinterDefault := GetDefaultPrinter()
   ELSE
      ::Error := 1
   ENDIF
   IF Empty( cFolder )
      cFolder := RR_GetTempFolder()
   ELSE
      IF ! Right( cFolder, 1 ) == "\"
         cFolder += "\"
      ENDIF
      IF ! File( cFolder + "NUL" )
         cFolder := RR_GetTempFolder()
      ENDIF
   ENDIF
   ::TimeStamp := TToS( DateTime() )
   ::BaseDoc := cFolder + ::TimeStamp + "_HBPrinter_preview_"
   ::InitMessages( cLang )

   RETURN Self

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SelectPrinter( cPrinter, lPrev ) CLASS HBPrinter

   LOCAL txtp := "", txtb := "", t := { 0, 0, 1, 0 }

   IF cPrinter == NIL
      ::hDCRef := RR_GetDC( ::PrinterDefault, ::hData )
      ::hDC := ::hDCRef
      ::PrinterName := ::PrinterDefault
   ELSEIF Empty( cPrinter )
      ::hDCRef := RR_PrintDialog( t, ::hData )
      ::nFromPage := t[ 1 ]
      ::nToPage := t[ 2 ]
      ::nCopies := t[ 3 ]
      ::nWhatToPrint := t[ 4 ]
      ::hDC := ::hDCRef
      ::PrinterName := RR_PrinterName( ::hData )
   ELSE
      ::hDCRef := RR_GetDC( cPrinter, ::hData )
      ::hDC := ::hDCRef
      ::PrinterName := cPrinter
   ENDIF
   IF HB_ISLOGICAL( lPrev )
      #ifndef NO_GUI
         ::PreviewMode := lPrev
      #endif
   ENDIF
   IF ::hDC == 0
      ::Error := 1
      ::PrinterName := ""
   ELSE
      RR_DeviceCapabilities( @txtp, @txtb, ::hData )
      ::PaperNames := RR_Str2Arr( txtp, ",," )
      ::BinNames := RR_Str2Arr( txtb, ",," )
      AEval( ::BinNames, {| x, xi | ::BinNames[ xi ] := RR_Str2Arr( x, ',' ) } )
      AEval( ::PaperNames, {| x, xi | ::PaperNames[ xi ] := RR_Str2Arr( x, ',' ) } )
      AAdd( ::Fonts[ 1 ], RR_GetCurrentObject( 1, ::hData ) ) ; AAdd( ::Fonts[ 2 ], "*" ) ;       AAdd( ::Fonts[ 4 ], {} )
      AAdd( ::Fonts[ 1 ], RR_GetCurrentObject( 1, ::hData ) ) ; AAdd( ::Fonts[ 2 ], "DEFAULT" ) ; AAdd( ::Fonts[ 4 ], {} )
      AAdd( ::Brushes[ 1 ], RR_GetCurrentObject( 2, ::hData ) ) ; AAdd( ::Brushes[ 2 ], "*" )
      AAdd( ::Brushes[ 1 ], RR_GetCurrentObject( 2, ::hData ) ) ; AAdd( ::Brushes[ 2 ], "DEFAULT" )
      AAdd( ::Pens[ 1 ], RR_GetCurrentObject( 3, ::hData ) ) ; AAdd( ::Pens[ 2 ], "*" )
      AAdd( ::Pens[ 1 ], RR_GetCurrentObject( 3, ::hData ) ) ; AAdd( ::Pens[ 2 ], "DEFAULT" )
      AAdd( ::Regions[ 1 ], 0 ) ; AAdd( ::Regions[ 2 ], "*" )
      AAdd( ::Regions[ 1 ], 0 ) ; AAdd( ::Regions[ 2 ], "DEFAULT" )
      ::Fonts[ 3 ] := ::Fonts[ 1, 1 ]
      RR_GetDeviceCaps( ::DevCaps, ::Fonts[ 3 ], ::hData )
      ::SetUnits( ::Units )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SetDevMode( what, newvalue ) CLASS HBPrinter

   LOCAL uRet

   STATIC aWhat := { DM_ORIENTATION, DM_PAPERSIZE, DM_SCALE, DM_COPIES, DM_DEFAULTSOURCE, DM_PRINTQUALITY, DM_COLOR, DM_DUPLEX, DM_COLLATE, DM_PAPERLENGTH, DM_PAPERWIDTH }

   uRet := RR_SetDevMode( what, newvalue, ::lGlobalChanges, ::hData )
   IF uRet == NIL
      IF ::lReportError
         MsgInfo( ::aOpisy[ 37 ] + ::aOpisy[ 38 + aScan( aWhat, uRet ) ], "" )
      ENDIF
      ::Error := 1
   ELSE
      RR_GetDeviceCaps( ::DevCaps, ::Fonts[ 3 ], ::hData )
      ::SetUnits( ::Units )
      ::Error := 0
   ENDIF

   RETURN ::Error

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SetUserMode( what, value, value2 ) CLASS HBPrinter

   LOCAL uRet

   uRet := RR_SetUserMode( what, value, value2, ::hData )
   IF uRet == NIL
      IF ::lReportError
         MsgInfo( ::aOpisy[ 37 ] + ::aOpisy[ 38 + aScan( what, what ) ], "" )
      ENDIF
      ::Error := 1
   ELSE
      RR_GetDeviceCaps( ::DevCaps, ::Fonts[ 3 ], ::hData )
      ::SetUnits( ::Units )
      ::Error := 0
   ENDIF

   RETURN ::Error

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD StartDoc( cDocName ) CLASS HBPrinter

   ::Printing := .T.
   IF HB_ISCHAR( cDocName )
      ::DocName := cDocName
   ENDIF
   IF ! ::PreviewMode
      RR_StartDoc( ::DocName, ::hData )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SetPage( orient, size, fontname ) CLASS HBPrinter

   LOCAL lhand := ::GetObjByName( fontname, "F" )

   IF size <> NIL
      ::SetDevMode( DM_PAPERSIZE, size )
   ENDIF
   IF orient <> NIL
      ::SetDevMode( DM_ORIENTATION, orient )
   ENDIF
   IF lhand <> 0
      ::Fonts[ 3 ] := lhand
   ENDIF
   RR_GetDeviceCaps( ::DevCaps, ::Fonts[ 3 ], ::hData )
   ::SetUnits( ::Units )

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD StartPage() CLASS HBPrinter

   IF ::PreviewMode
      IF ::InMemory
         ::hDC := RR_CreatEMFile( "", ::hData )
      ELSE
         ::hDC := RR_CreatEMFile( ::BaseDoc + AllTrim( Str( ::CurPage ) ) + '.emf', ::hData )
         ::CurPage ++
      ENDIF
   ELSE
      RR_StartPage( ::hData )
   ENDIF
   IF ! ::PrintingEMF
      RR_SelectClipRgn( ::Regions[ 1, 1 ], ::hData )
      RR_SetViewportOrg( ::ViewportOrg, ::hData )
      RR_SetTextColor( ::TextColor, ::hData )
      RR_SetBkColor( ::BkColor, ::hData )
      RR_SetBkMode( ::BkMode, ::hData )
      RR_SelectBrush( ::Brushes[ 1, 1 ], ::hData )
      RR_SelectPen( ::Pens[ 1, 1 ], ::hData )
      RR_SelectFont( ::Fonts[ 1, 1 ], ::hData )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD EndPage() CLASS HBPrinter

   IF ::PreviewMode
      IF ::InMemory
         AAdd( ::MetaFiles, { RR_ClosEMFile( ::hData ), ;
                              ::DevCaps[ DI_VERT_SIZE ], ::DevCaps[ DI_HORZ_SIZE ], ;
                              ::DevCaps[ DI_VERT_RES ], ::DevCaps[ DI_HORZ_RES ], ;
                              ::DevCaps[ DI_ORIENTATION ], ::DevCaps[ DI_PAPERSIZE ] } )
      ELSE
         RR_CloseFile( ::hData )
         AAdd( ::MetaFiles, { ::BaseDoc + AllTrim( Str( ::CurPage - 1 ) ) + '.emf', ;
                              ::DevCaps[ DI_VERT_SIZE ], ::DevCaps[ DI_HORZ_SIZE ], ;
                              ::DevCaps[ DI_VERT_RES ], ::DevCaps[ DI_HORZ_RES ], ;
                              ::DevCaps[ DI_ORIENTATION ], ::DevCaps[ DI_PAPERSIZE ] } )
      ENDIF
   ELSE
      RR_EndPage( ::hData )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD EndDoc( cParent, lWait, lSize ) CLASS HBPrinter

   IF ! HB_ISLOGICAL( lWait )
      lWait := ::PreviewMode
   ENDIF
   IF ! HB_ISLOGICAL( lSize )
      lSize := ! lWait
   ENDIF

   IF ::PreviewMode
#ifndef NO_GUI
      ::Preview( cParent, lWait, lSize )
#endif
   ELSE
      IF lWait
         MsgInfo( ::aOpisy[ 31 ], "" )
      ENDIF
      RR_EndDoc( ::hData )
   ENDIF
   ::Printing := .F.

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SetTextColor( clr ) CLASS HBPrinter

   LOCAL lret := ::TextColor

   IF clr <> NIL
      IF HB_ISNUMERIC ( clr )
         ::TextColor := RR_SetTextColor( clr, ::hData )
      ELSEIF HB_ISARRAY ( clr )
         ::TextColor := RR_SetTextColor( RR_SetRGB( clr[ 1 ], clr[ 2 ], clr[ 3 ] ), ::hData )
      ENDIF
   ENDIF

   RETURN lret

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SetPolyFillMode( style ) CLASS HBPrinter

   LOCAL lret := ::PolyFillMode

   ::PolyFillMode := RR_SetPolyFillMode( style, ::hData )

   RETURN lret

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SetBkColor( clr ) CLASS HBPrinter

   LOCAL lret := ::BkColor

   IF HB_ISNUMERIC ( clr )
      ::BkColor := RR_SetBkColor( clr, ::hData )
   ELSEIF HB_ISARRAY ( clr )
      ::BkColor := RR_SetBkColor( RR_SetRGB( clr[ 1 ], clr[ 2 ], clr[ 3 ] ), ::hData )
   ENDIF

   RETURN lret

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SetBkMode( nmode ) CLASS HBPrinter

   LOCAL lret := ::BkMode

   ::BkMode := nmode
   ::Error := iif( RR_SetBkMode( nmode, ::hData ) == 0, 1, 0 )

   RETURN lret

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD DefineBrush( defname, lstyle, lcolor, lhatch ) CLASS HBPrinter

   LOCAL lhand := ::GetObjByName( defname, "B" )

   IF lhand == 0
      IF HB_ISARRAY ( lcolor )
         lcolor := RR_SetRGB( lcolor[ 1 ], lcolor[ 2 ], lcolor[ 3 ] )
      ENDIF

      lstyle := iif( lstyle == NIL, BS_NULL, lstyle )
      lcolor := iif( lcolor == NIL, 0xFFFFFF, lcolor )
      lhatch := iif( lhatch == NIL, HS_HORIZONTAL, lhatch )
      AAdd( ::Brushes[ 1 ], RR_CreateBrush( lstyle, lcolor, lhatch ) )
      AAdd( ::Brushes[ 2 ], Upper( AllTrim( defname ) ) )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SelectBrush( defname ) CLASS HBPrinter

   LOCAL lhand := ::GetObjByName( defname, "B" )

   IF lhand <> 0
      RR_SelectBrush( lhand, ::hData )
      ::Brushes[ 1, 1 ] := lhand
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD ModifyBrush( defname, lstyle, lcolor, lhatch ) CLASS HBPrinter

   LOCAL lhand := 0, lpos

   IF defname == "*"
      lpos := AScan( ::Brushes[ 1 ], ::Brushes[ 1, 1 ], 2 )
      IF lpos > 1
         lhand := ::Brushes[ 1, lpos ]
      ENDIF
   ELSE
      lhand := ::GetObjByName( defname, "B" )
      lpos := ::GetObjByName( defname, "B", .T. )
   ENDIF
   IF lhand == 0 .OR. lpos == 0
      ::Error := 1
      RETURN NIL
   ENDIF

   lstyle := if( lstyle == NIL, -1, lstyle )
   IF HB_ISARRAY ( lcolor )
      lcolor := RR_SetRGB( lcolor[ 1 ], lcolor[ 2 ], lcolor[ 3 ] )
   ENDIF
   lcolor := if( lcolor == NIL, -1, lcolor )
   lhatch := if( lhatch == NIL, -1, lhatch )

   ::Brushes[ 1, lpos ] := RR_ModifyBrush( lhand, lstyle, lcolor, lhatch )
   IF lhand == ::Brushes[ 1, 1 ]
      ::SelectBrush( ::Brushes[ 2, lpos ] )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD DefinePen( defname, lstyle, lwidth, lcolor ) CLASS HBPrinter

   LOCAL lhand := ::GetObjByName( defname, "P" )

   IF lhand == 0
      IF HB_ISARRAY ( lcolor )
         lcolor := RR_SetRGB( lcolor[ 1 ], lcolor[ 2 ], lcolor[ 3 ] )
      ENDIF
      lstyle := iif( lstyle == NIL, PS_SOLID, lstyle )
      lcolor := iif( lcolor == NIL, 0xFFFFFF, lcolor )
      lwidth := iif( lwidth == NIL, 0, lwidth )

      AAdd( ::Pens[ 1 ], RR_CreatePen( lstyle, lwidth, lcolor ) )
      AAdd( ::Pens[ 2 ], Upper( AllTrim( defname ) ) )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD ModifyPen( defname, lstyle, lwidth, lcolor ) CLASS HBPrinter

   LOCAL lhand := 0, lpos

   IF defname == "*"
      lpos := AScan( ::Pens[ 1 ], ::Pens[ 1, 1 ], 2 )
      IF lpos > 1
         lhand := ::Pens[ 1, lpos ]
      ENDIF
   ELSE
      lhand := ::GetObjByName( defname, "P" )
      lpos := ::GetObjByName( defname, "P", .T. )
   ENDIF
   IF lhand == 0 .OR. lpos <= 1
      ::Error := 1
      RETURN NIL
   ENDIF

   lstyle := if( lstyle == NIL, -1, lstyle )
   IF HB_ISARRAY ( lcolor )
      lcolor := RR_SetRGB( lcolor[ 1 ], lcolor[ 2 ], lcolor[ 3 ] )
   ENDIF
   lcolor := iif( lcolor == NIL, -1, lcolor )
   lwidth := iif( lwidth == NIL, -1, lwidth )

   ::Pens[ 1, lpos ] := RR_ModifyPen( lhand, lstyle, lwidth, lcolor )
   IF lhand == ::Pens[ 1, 1 ]
      ::SelectPen( ::Pens[ 2, lpos ] )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SelectPen( defname ) CLASS HBPrinter

   LOCAL lhand := ::GetObjByName( defname, "P" )

   IF lhand <> 0
      RR_SelectPen( lhand, ::hData )
      ::Pens[ 1, 1 ] := lhand
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD DefineFont( defname, lfontname, lfontsize, lfontwidth, langle, lweight, litalic, lunderline, lstrikeout ) CLASS HBPrinter

   LOCAL lhand := ::GetObjByName( lfontname, "F" )

   IF lhand == 0
      lfontname := if( lfontname == NIL, "", Upper( AllTrim( lfontname ) ) )
      IF lfontsize == NIL
         lfontsize := -1
      ENDIF

      IF lfontwidth == NIL
         lfontwidth := 0
      ENDIF
      IF langle == NIL
         langle := -1
      ENDIF
      lweight := if( Empty( lweight ), 0, 1 )
      litalic := if( Empty( litalic ), 0, 1 )
      lunderline := if( Empty( lunderline ), 0, 1 )
      lstrikeout := if( Empty( lstrikeout ), 0, 1 )
      AAdd( ::Fonts[ 1 ], RR_CreateFont( lfontname, lfontsize, -lfontwidth, langle * 10, lweight, litalic, lunderline, lstrikeout, ::hData ) )
      AAdd( ::Fonts[ 2 ], Upper( AllTrim( defname ) ) )
      AAdd( ::Fonts[ 4 ], { lfontname, lfontsize, lfontwidth, langle, lweight, litalic, lunderline, lstrikeout } )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD ModifyFont( defname, lfontname, lfontsize, lfontwidth, langle, lweight, lnweight, litalic, lnitalic, lunderline, lnunderline, lstrikeout, lnstrikeout ) CLASS HBPrinter

   LOCAL lhand := 0, lpos

   IF defname == "*"
      lpos := AScan( ::Fonts[ 1 ], ::Fonts[ 1, 1 ], 2 )
      IF lpos > 1
         lhand := ::Fonts[ 1, lpos ]
      ENDIF
   ELSE
      lhand := ::GetObjByName( defname, "F" )
      lpos := ::GetObjByName( defname, "F", .T. )
   ENDIF
   IF lhand == 0 .OR. lpos <= 1
      ::Error := 1
      RETURN NIL
   ENDIF

   IF lfontname <> NIL
      ::Fonts[ 4, lpos, 1 ] := Upper( AllTrim( lfontname ) )
   ENDIF

   IF lfontsize <> NIL
      ::Fonts[ 4, lpos, 2 ] := lfontsize
   ENDIF
   IF lfontwidth <> NIL
      ::Fonts[ 4, lpos, 3 ] := lfontwidth
   ENDIF
   IF langle <> NIL
      ::Fonts[ 4, lpos, 4 ] := langle
   ENDIF
   IF lweight
      ::Fonts[ 4, lpos, 5 ] := 1
   ENDIF
   IF lnweight
      ::Fonts[ 4, lpos, 5 ] := 0
   ENDIF
   IF litalic
      ::Fonts[ 4, lpos, 6 ] := 1
   ENDIF
   IF lnitalic
      ::Fonts[ 4, lpos, 6 ] := 0
   ENDIF
   IF lunderline
      ::Fonts[ 4, lpos, 7 ] := 1
   ENDIF
   IF lnunderline
      ::Fonts[ 4, lpos, 7 ] := 0
   ENDIF
   IF lstrikeout
      ::Fonts[ 4, lpos, 8 ] := 1
   ENDIF
   IF lnstrikeout
      ::Fonts[ 4, lpos, 8 ] := 0
   ENDIF

   ::Fonts[ 1, lpos ] := RR_CreateFont( ::Fonts[ 4, lpos, 1 ], ::Fonts[ 4, lpos, 2 ], -::Fonts[ 4, lpos, 3 ], ::Fonts[ 4, lpos, 4 ] * 10, ::Fonts[ 4, lpos, 5 ], ::Fonts[ 4, lpos, 6 ], ::Fonts[ 4, lpos, 7 ], ::Fonts[ 4, lpos, 8 ], ::hData )

   IF lhand == ::Fonts[ 1, 1 ]
      ::SelectFont( ::Fonts[ 2, lpos ] )
   ENDIF
   RR_DeleteObjects( { 0, lhand } )

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SelectFont( defname ) CLASS HBPrinter

   LOCAL lhand := ::GetObjByName( defname, "F" )

   IF lhand <> 0
      RR_SelectFont( lhand, ::hData )
      ::Fonts[ 1, 1 ] := lhand
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SetUnits( newvalue, r, c, lAbsolute ) CLASS HBPrinter

   LOCAL oldvalue := ::Units

   IF HB_ISSTRING( newvalue )
      newvalue := Upper( AllTrim( newvalue ) )
      IF newvalue == "ROWCOL"
         newvalue := 0
      ELSEIF newvalue == "MM"
         newvalue := 1
      ELSEIF newvalue == "INCHES"
         newvalue := 2
      ELSEIF newvalue == "PIXELS"
         newvalue := 3
      ENDIF
   ENDIF
   newvalue := if( HB_ISNUMERIC( newvalue ), newvalue, 0 )
   ::Units := if( newvalue < 0 .OR. newvalue > 4, 0, newvalue )
   DO CASE
   CASE ::Units == 0
      ::MaxRow := ::DevCaps[ DI_ROWS ] - 1
      ::MaxCol := ::DevCaps[ DI_COLS ] - 1
   CASE ::Units == 1
      ::MaxRow := ::DevCaps[ DI_VERT_SIZE ] - 1
      ::MaxCol := ::DevCaps[ DI_HORZ_SIZE ] - 1
   CASE ::Units == 2
      ::MaxRow := ( ::DevCaps[ DI_VERT_SIZE ] / 25.4 ) - 1
      ::MaxCol := ( ::DevCaps[ DI_HORZ_SIZE ] / 25.4 ) - 1
   CASE ::Units == 3
      ::MaxRow := ::DevCaps[ DI_VERT_RES ]
      ::MaxCol := ::DevCaps[ DI_HORZ_RES ]
   CASE ::Units == 4
      IF HB_ISNUMERIC( r )
         ::MaxRow := r - 1
      ENDIF
      IF HB_ISNUMERIC( c )
         ::MaxCol := c - 1
      ENDIF
   ENDCASE
   IF HB_ISLOGICAL( lAbsolute )
      ::lAbsoluteCoords := lAbsolute
   ENDIF

   RETURN oldvalue

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Convert( arr, lsize ) CLASS HBPrinter

   LOCAL aret := AClone( arr )

   DO CASE
   CASE ::Units == 0   // ROWCOL
      aret[ 1 ] := arr[ 1 ] * ::DevCaps[ DI_VERT_FONTSIZE ]
      aret[ 2 ] := arr[ 2 ] * ::DevCaps[ DI_HORZ_FONTSIZE ]
   CASE ::Units == 3   // PIXEL
   CASE ::Units == 4   // ROWS   COLS
      aret[ 1 ] := arr[ 1 ] * ::DevCaps[ DI_VERT_RES ] / ( ::MaxRow + 1 )
      aret[ 2 ] := arr[ 2 ] * ::DevCaps[ DI_HORZ_RES ] / ( ::MaxCol + 1 )
   CASE ::Units == 1   // MM
      aret[ 1 ] := arr[ 1 ] * ::DevCaps[ DI_VERT_LOGPIX ] / 25.4 - iif( ! ::lAbsoluteCoords .AND. lsize == NIL, ::DevCaps[ DI_VERT_PHYOFFS ], 0 )
      aret[ 2 ] := arr[ 2 ] * ::DevCaps[ DI_HORZ_LOGPIX ] / 25.4 - iif( ! ::lAbsoluteCoords .AND. lsize == NIL, ::DevCaps[ DI_HORZ_PHYOFFS ], 0 )
   CASE ::Units == 2   // INCHES
      aret[ 1 ] := arr[ 1 ] * ::DevCaps[ DI_VERT_LOGPIX ] - iif( ! ::lAbsoluteCoords .AND. lsize == NIL, ::DevCaps[ DI_VERT_PHYOFFS ], 0 )
      aret[ 2 ] := arr[ 2 ] * ::DevCaps[ DI_HORZ_LOGPIX ] - iif( ! ::lAbsoluteCoords .AND. lsize == NIL, ::DevCaps[ DI_HORZ_PHYOFFS ], 0 )
   OTHERWISE
      aret[ 1 ] := arr[ 1 ] * ::DevCaps[ DI_VERT_FONTSIZE ]
      aret[ 2 ] := arr[ 2 ] * ::DevCaps[ DI_HORZ_FONTSIZE ]
   ENDCASE

   RETURN aret

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD UnConvert( arr, lsize ) CLASS HBPrinter

   LOCAL aret := AClone( arr )

   DO CASE
   CASE ::Units == 0   // ROWCOL
      aret[ 1 ] := Int( arr[ 1 ] / ::DevCaps[ DI_VERT_FONTSIZE ] )
      aret[ 2 ] := Int( arr[ 2 ] / ::DevCaps[ DI_HORZ_FONTSIZE ] )
   CASE ::Units == 3   // PIXEL
   CASE ::Units == 4   // ROWS   COLS
      aret[ 1 ] := Int( arr[ 1 ] / ::DevCaps[ DI_VERT_RES ] * ( ::MaxRow + 1 ) )
      aret[ 2 ] := Int( arr[ 2 ] / ::DevCaps[ DI_HORZ_RES ] * ( ::MaxCol + 1 ) )
   CASE ::Units == 1   // MM
      aret[ 1 ] := ( arr[ 1 ] + iif( ! ::lAbsoluteCoords .AND. lsize == NIL, ::DevCaps[ DI_VERT_PHYOFFS ], 0 ) ) / ::DevCaps[ DI_VERT_LOGPIX ] * 25.4
      aret[ 2 ] := ( arr[ 2 ] + iif( ! ::lAbsoluteCoords .AND. lsize == NIL, ::DevCaps[ DI_HORZ_PHYOFFS ], 0 ) ) / ::DevCaps[ DI_HORZ_LOGPIX ] * 25.4
   CASE ::Units == 2   // INCHES
      aret[ 1 ] := ( arr[ 1 ] + iif( ! ::lAbsoluteCoords .AND. lsize == NIL, ::DevCaps[ DI_VERT_PHYOFFS ], 0 ) ) / ::DevCaps[ DI_VERT_LOGPIX ]
      aret[ 2 ] := ( arr[ 2 ] + iif( ! ::lAbsoluteCoords .AND. lsize == NIL, ::DevCaps[ DI_HORZ_PHYOFFS ], 0 ) ) / ::DevCaps[ DI_HORZ_LOGPIX ]
   OTHERWISE
      aret[ 1 ] := Int( arr[ 1 ] / ::DevCaps[ DI_VERT_FONTSIZE ] )
      aret[ 2 ] := Int( arr[ 2 ] / ::DevCaps[ DI_HORZ_FONTSIZE ] )
   ENDCASE

   RETURN aret

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD DrawText( row, col, torow, tocol, txt, style, defname, lNoWordBreak ) CLASS HBPrinter

   LOCAL lhf := ::GetObjByName( defname, "F" )

   IF torow == NIL
      torow := ::MaxRow
   ENDIF
   IF tocol == NIL
      tocol := ::MaxCol
   ENDIF

   RETURN( ::Error := RR_DrawText( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), txt, style, lhf, lNoWordBreak, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD TextOut( row, col, txt, defname ) CLASS HBPrinter

   LOCAL lhf := ::GetObjByName( defname, "F" )

   RETURN ( ::Error := RR_TextOut( txt, ::Convert( { row, col } ), lhf, NumAt( " ", txt ), ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Say( row, col, txt, defname, lcolor, lalign ) CLASS HBPrinter

   LOCAL atxt := {}, i, lhf := ::GetObjByName( defname, "F" ), oldalign, apos, lError := .F.

   DO CASE
   CASE HB_ISNUMERIC( txt ) ;  AAdd( atxt, Str( txt ) )
   CASE ValType( txt ) == "T" ;  AAdd( atxt, ttoc( txt ) )
   CASE HB_ISDATE( txt ) ;  AAdd( atxt, DToC( txt ) )
   CASE HB_ISLOGICAL( txt ) ;  AAdd( atxt, if( txt, ".T.", ".F." ) )
   CASE ValType( txt ) == "U" ;  AAdd( atxt, "NIL" )
   CASE ValType( txt ) $ "BO" ;  AAdd( atxt, "" )
   CASE HB_ISARRAY( txt ) ;  AEval( txt, {| x | AAdd( atxt, RR_SayConvert( x ) ) } )
   CASE ValType( txt ) $ "MC" ;  atxt := RR_Str2Arr( txt, CRLF )
   ENDCASE
   apos := ::Convert( { row, col } )
   IF lcolor <> NIL
      IF HB_ISNUMERIC ( lcolor )
         RR_SetTextColor( lcolor, ::hData )
      ELSEIF HB_ISARRAY ( lcolor )
         RR_SetTextColor( RR_SetRGB( lcolor[ 1 ], lcolor[ 2 ], lcolor[ 3 ] ), ::hData )
      ENDIF
   ENDIF
   IF lalign <> NIL
      oldalign := RR_GetTextAlign( ::hData )
      RR_SetTextAlign( lalign, ::hData )
   ENDIF
   FOR i := 1 TO Len( atxt )
      IF RR_TextOut( atxt[ i ], apos, lhf, NumAt( " ", atxt[ i ] ), ::hData ) == 1
         lError := .T.
      ENDIF
      apos[ 1 ] += ::DevCaps[ DI_VERT_FONTSIZE ]
   NEXT
   IF lalign <> NIL
      RR_SetTextAlign( oldalign, ::hData )
   ENDIF
   IF lcolor <> NIL
      RR_SetTextColor( ::TextColor, ::hData )
   ENDIF

   RETURN ( ::Error := iif( lError, 1, 0 ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD DefineImageList( defname, cpicture, nicons ) CLASS HBPrinter

   LOCAL lhi := ::GetObjByName( defname, "I" ), w := 0, h := 0, hand, lError := .F.

   IF lhi == 0
      hand := RR_CreateImageList( cpicture, nicons, @w, @h )
      IF hand <> 0 .AND. w > 0 .AND. h > 0
         AAdd( ::ImageLists[ 1 ], { hand, nicons, w, h } )
         AAdd( ::ImageLists[ 2 ], Upper( AllTrim( defname ) ) )
      ELSE
         lError := .T.
      ENDIF
   ENDIF

   RETURN ( ::Error := iif( lError, 1, 0 ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD DrawImageList( defname, nicon, row, col, torow, tocol, lstyle, color ) CLASS HBPrinter

   LOCAL lhi := ::GetObjByName( defname, "I" )

   IF Empty( lhi )
      RETURN NIL
   ENDIF
   IF color == NIL
      color := -1
   ENDIF
   IF torow == NIL
      torow := ::MaxRow
   ENDIF
   IF tocol == NIL
      tocol := ::MaxCol
   ENDIF

   RETURN ( ::Error := RR_DrawImageList( lhi[ 1 ], nicon, ::Convert( { row, col } ), ::Convert( { torow - row, tocol - col } ), lhi[ 3 ], lhi[ 4 ], lstyle, color, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Rectangle( row, col, torow, tocol, defpen, defbrush ) CLASS HBPrinter

   LOCAL lhp := ::GetObjByName( defpen, "P" ), lhb := ::GetObjByName( defbrush, "B" )

   IF torow == NIL
      torow := ::MaxRow
   ENDIF
   IF tocol == NIL
      tocol := ::MaxCol
   ENDIF

   RETURN( ::Error := RR_Rectangle( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), lhp, lhb, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD FrameRect( row, col, torow, tocol, defbrush ) CLASS HBPrinter

   LOCAL lhb := ::GetObjByName( defbrush, "B" )

   IF torow == NIL
      torow := ::MaxRow
   ENDIF
   IF tocol == NIL
      tocol := ::MaxCol
   ENDIF

   RETURN ( ::Error := RR_FrameRect( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), lhb, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD RoundRect( row, col, torow, tocol, widthellipse, heightellipse, defpen, defbrush ) CLASS HBPrinter

   LOCAL lhp := ::GetObjByName( defpen, "P" ), lhb := ::GetObjByName( defbrush, "B" )

   IF torow == NIL
      torow := ::MaxRow
   ENDIF
   IF tocol == NIL
      tocol := ::MaxCol
   ENDIF
   IF widthellipse == NIL
      widthellipse := 0
   ENDIF
   IF heightellipse == NIL
      heightellipse := 0
   ENDIF

   RETURN ( ::Error := RR_RoundRect( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), ::Convert( { widthellipse, heightellipse } ), lhp, lhb, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD FillRect( row, col, torow, tocol, defbrush ) CLASS HBPrinter

   LOCAL lhb := ::GetObjByName( defbrush, "B" )

   IF torow == NIL
      torow := ::MaxRow
   ENDIF
   IF tocol == NIL
      tocol := ::MaxCol
   ENDIF

   RETURN ( ::Error := RR_FillRect( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), lhb, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD InvertRect( row, col, torow, tocol ) CLASS HBPrinter

   IF torow == NIL
      torow := ::MaxRow
   ENDIF
   IF tocol == NIL
      tocol := ::MaxCol
   ENDIF

   RETURN ( ::Error := RR_InvertRect( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Ellipse( row, col, torow, tocol, defpen, defbrush ) CLASS HBPrinter

   LOCAL lhp := ::GetObjByName( defpen, "P" ), lhb := ::GetObjByName( defbrush, "B" )

   IF torow == NIL
      torow := ::MaxRow
   ENDIF
   IF tocol == NIL
      tocol := ::MaxCol
   ENDIF

   RETURN ( ::Error := RR_Ellipse( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), lhp, lhb, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Arc( row, col, torow, tocol, rowsarc, colsarc, rowearc, colearc, defpen ) CLASS HBPrinter

   LOCAL lhp := ::GetObjByName( defpen, "P" )

   IF torow == NIL
      torow := ::MaxRow
   ENDIF
   IF tocol == NIL
      tocol := ::MaxCol
   ENDIF

   RETURN ( ::Error := RR_Arc( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), ::Convert( { rowsarc, colsarc } ), ::Convert( { rowearc, colearc } ), lhp, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD ArcTo( row, col, torow, tocol, rowrad1, colrad1, rowrad2, colrad2, defpen ) CLASS HBPrinter

   LOCAL lhp := ::GetObjByName( defpen, "P" )

   IF torow == NIL
      torow := ::MaxRow
   ENDIF
   IF tocol == NIL
      tocol := ::MaxCol
   ENDIF

   RETURN ( ::Error := RR_ArcTo( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), ::Convert( { rowrad1, colrad1 } ), ::Convert( { rowrad2, colrad2 } ), lhp, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Chord( row, col, torow, tocol, rowrad1, colrad1, rowrad2, colrad2, defpen, defbrush ) CLASS HBPrinter

   LOCAL lhp := ::GetObjByName( defpen, "P" ), lhb := ::GetObjByName( defbrush, "B" )

   IF torow == NIL
      torow := ::MaxRow
   ENDIF
   IF tocol == NIL
      tocol := ::MaxCol
   ENDIF

   RETURN ( ::Error := RR_Chord( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), ::Convert( { rowrad1, colrad1 } ), ::Convert( { rowrad2, colrad2 } ), lhp, lhb, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Pie( row, col, torow, tocol, rowrad1, colrad1, rowrad2, colrad2, defpen, defbrush ) CLASS HBPrinter

   LOCAL lhp := ::GetObjByName( defpen, "P" ), lhb := ::GetObjByName( defbrush, "B" )

   IF torow == NIL
      torow := ::MaxRow
   ENDIF
   IF tocol == NIL
      tocol := ::MaxCol
   ENDIF

   RETURN ( ::Error := RR_Pie( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), ::Convert( { rowrad1, colrad1 } ), ::Convert( { rowrad2, colrad2 } ), lhp, lhb, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Polygon( apoints, defpen, defbrush, style ) CLASS HBPrinter

   LOCAL apx := {}, apy := {}, temp
   LOCAL lhp := ::GetObjByName( defpen, "P" ), lhb := ::GetObjByName( defbrush, "B" )

   AEval( apoints, {| x | temp := ::Convert( x ), AAdd( apx, temp[ 2 ] ), AAdd( apy, temp[ 1 ] ) } )

   RETURN ( ::Error := RR_Polygon( apx, apy, lhp, lhb, style, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD PolyBezier( apoints, defpen ) CLASS HBPrinter

   LOCAL apx := {}, apy := {}, temp
   LOCAL lhp := ::GetObjByName( defpen, "P" )

   AEval( apoints, {| x | temp := ::Convert( x ), AAdd( apx, temp[ 2 ] ), AAdd( apy, temp[ 1 ] ) } )

   RETURN ( ::Error := RR_PolyBezier( apx, apy, lhp, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD PolyBezierTo( apoints, defpen ) CLASS HBPrinter

   LOCAL apx := {}, apy := {}, temp
   LOCAL lhp := ::GetObjByName( defpen, "P" )

   AEval( apoints, {| x | temp := ::Convert( x ), AAdd( apx, temp[ 2 ] ), AAdd( apy, temp[ 1 ] ) } )

   RETURN ( ::Error := RR_PolyBezierTo( apx, apy, lhp, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD MoveTo( row, col ) CLASS HBPrinter

   LOCAL aPrevious := { NIL, NIL }

   ::Error := RR_MoveTo( ::Convert( { row, col } ), ::hData, aPrevious )

   RETURN ::UnConvert( aPrevious )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Line( row, col, torow, tocol, defpen ) CLASS HBPrinter

   LOCAL lhp := ::GetObjByName( defpen, "P" )

   IF torow == NIL
      torow := ::MaxRow
   ENDIF
   IF tocol == NIL
      tocol := ::MaxCol
   ENDIF

   RETURN ( ::Error := RR_Line( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), lhp, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD LineTo( row, col, defpen ) CLASS HBPrinter

   LOCAL lhp := ::GetObjByName( defpen, "P" )

   RETURN ( ::Error := RR_LineTo( ::Convert( { row, col } ), lhp, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD GetTextExtent( ctext, apoint, deffont ) CLASS HBPrinter

   LOCAL lhf := ::GetObjByName( deffont, "F" )

   RETURN ( ::Error := RR_GetTextExtent( ctext, apoint, lhf, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD GetTextExtent_MM( ctext, apoint, deffont ) CLASS HBPrinter

   LOCAL lhf := ::GetObjByName( deffont, "F" )

   ::Error = RR_GetTextExtent( ctext, apoint, lhf, ::hData )
   apoint[ 1 ] := 25.4 * apoint[ 1 ] / ::DevCaps[ DI_VERT_LOGPIX ]
   apoint[ 2 ] := 25.4 * apoint[ 2 ] / ::DevCaps[ DI_HORZ_LOGPIX ]

   RETURN ::Error

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD GetObjByName( defname, what, retpos ) CLASS HBPrinter

   LOCAL lfound, lret := 0, aref, ahref

   IF ValType( defname ) == "C"
      DO CASE
      CASE what == "F" ; aref := ::Fonts[ 2 ] ; ahref := ::Fonts[ 1 ]
      CASE what == "B" ; aref := ::Brushes[ 2 ] ; ahref := ::Brushes[ 1 ]
      CASE what == "P" ; aref := ::Pens[ 2 ] ; ahref := ::Pens[ 1 ]
      CASE what == "R" ; aref := ::Regions[ 2 ] ; ahref := ::Regions[ 1 ]
      CASE what == "I" ; aref := ::ImageLists[ 2 ] ; ahref := ::ImageLists[ 1 ]
      ENDCASE
      lfound := AScan( aref, Upper( AllTrim( defname ) ) )
      IF lfound > 0
         IF aref[ lfound ] == Upper( AllTrim( defname ) )
            IF retpos <> NIL
               lret := lfound
            ELSE
               lret := ahref[ lfound ]
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   RETURN lret

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD DefineRectRgn( defname, row, col, torow, tocol ) CLASS HBPrinter

   LOCAL lhand := ::GetObjByName( defname, "R" )

   IF lhand == 0
      IF torow == NIL
         torow := ::MaxRow
      ENDIF
      IF tocol == NIL
         tocol := ::MaxCol
      ENDIF
      AAdd( ::Regions[ 1 ], RR_CreateRgn( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), 1, NIL, ::hData ) )
      AAdd( ::Regions[ 2 ], Upper( AllTrim( defname ) ) )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD DefineEllipticRgn( defname, row, col, torow, tocol ) CLASS HBPrinter

   LOCAL lhand := ::GetObjByName( defname, "R" )

   IF lhand == 0
      IF torow == NIL
         torow := ::MaxRow
      ENDIF
      IF tocol == NIL
         tocol := ::MaxCol
      ENDIF
      AAdd( ::Regions[ 1 ], RR_CreateRgn( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), 2, NIL, ::hData ) )
      AAdd( ::Regions[ 2 ], Upper( AllTrim( defname ) ) )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD DefineRoundRectRgn( defname, row, col, torow, tocol, widthellipse, heightellipse ) CLASS HBPrinter

   LOCAL lhand := ::GetObjByName( defname, "R" )

   IF lhand == 0
      IF torow == NIL
         torow := ::MaxRow
      ENDIF
      IF tocol == NIL
         tocol := ::MaxCol
      ENDIF
      AAdd( ::Regions[ 1 ], RR_CreateRgn( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), 3, ::Convert( { widthellipse, heightellipse } ), ::hData ) )
      AAdd( ::Regions[ 2 ], Upper( AllTrim( defname ) ) )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD DefinePolygonRgn( defname, apoints, style ) CLASS HBPrinter

   LOCAL apx := {}, apy := {}, temp
   LOCAL lhand := ::GetObjByName( defname, "R" )

   IF lhand == 0
      AEval( apoints, {| x | temp := ::Convert( x ), AAdd( apx, temp[ 2 ] ), AAdd( apy, temp[ 1 ] ) } )
      AAdd( ::Regions[ 1 ], RR_CreatePolygonRgn( apx, apy, style ) )
      AAdd( ::Regions[ 2 ], Upper( AllTrim( defname ) ) )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD CombineRgn( defname, reg1, reg2, style ) CLASS HBPrinter

   LOCAL lr1 := ::GetObjByName( reg1, "R" ), lr2 := ::GetObjByName( reg2, "R" )
   LOCAL lhand := ::GetObjByName( defname, "R" )

   IF lhand == 0 .AND. lr1 # 0 .AND. lr2 # 0
      AAdd( ::Regions[ 1 ], RR_CombineRgn( lr1, lr2, style ) )
      AAdd( ::Regions[ 2 ], Upper( AllTrim( defname ) ) )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SelectClipRgn( defname ) CLASS HBPrinter

   LOCAL lhand := ::GetObjByName( defname, "R" )

   IF lhand <> 0
      RR_SelectClipRgn( lhand, ::hData )
      ::Regions[ 1, 1 ] := lhand
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD DeleteClipRgn() CLASS HBPrinter

   ::Regions[ 1, 1 ] := 0
   RR_DeleteClipRgn( ::hData )

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SetViewPortOrg( row, col ) CLASS HBPrinter

   row := if( row <> NIL, row, 0 )
   col := if( col <> NIL, col, 0 )
   ::ViewportOrg := ::Convert( { row, col } )

   RETURN ( ::Error := RR_SetViewportOrg( ::ViewportOrg, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD GetViewPortOrg() CLASS HBPrinter

   RETURN ( ::Error := RR_GetViewportOrg( ::ViewportOrg, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE Destroy() CLASS HBPrinter

   ::End()

   RETURN

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD End() CLASS HBPrinter

   IF ::PreviewMode
      IF ! ::InMemory
         AEval( ::MetaFiles, {| x | FErase( x[ PG_FILE ] ) } )
      ENDIF
      ::MetaFiles := {}
   ENDIF
   RR_DeleteObjects( ::Fonts[ 1 ] )
   RR_DeleteObjects( ::Brushes[ 1 ] )
   RR_DeleteObjects( ::Pens[ 1 ] )
   RR_DeleteObjects( ::Regions[ 1 ] )
   RR_DeleteImageLists( ::ImageLists[ 1 ] )
   IF ::hData # 0
      IF ::hDCRef # 0
         RR_DeleteDC( ::hData )
        ::hDCRef := 0
      ENDIF
      RR_ResetPrinter( ::hData )
      RR_Finish( ::hData )
      ::hData := 0
   ENDIF
   IF HB_ISOBJECT( ::oWinPreview )
      ::PrevClose()
   ENDIF
   ::BeforePrint := NIL
   ::AfterPrint := NIL
   ::BeforePrintCopy := NIL

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD DxColors( uPar ) CLASS HBPrinter

   LOCAL nColor := 0
   STATIC aColors := { ;
      { "aliceblue", 0xfffff8f0 }, ;
      { "antiquewhite", 0xffd7ebfa }, ;
      { "aqua", 0xffffff00 }, ;
      { "aquamarine", 0xffd4ff7f }, ;
      { "azure", 0xfffffff0 }, ;
      { "beige", 0xffdcf5f5 }, ;
      { "bisque", 0xffc4e4ff }, ;
      { "black", 0xff000000 }, ;
      { "blanchedalmond", 0xffcdebff }, ;
      { "blue", 0xffff0000 }, ;
      { "blueviolet", 0xffe22b8a }, ;
      { "brown", 0xff2a2aa5 }, ;
      { "burlywood", 0xff87b8de }, ;
      { "cadetblue", 0xffa09e5f }, ;
      { "chartreuse", 0xff00ff7f }, ;
      { "chocolate", 0xff1e69d2 }, ;
      { "coral", 0xff507fff }, ;
      { "cornflowerblue", 0xffed9564 }, ;
      { "cornsilk", 0xffdcf8ff }, ;
      { "crimson", 0xff3c14dc }, ;
      { "cyan", 0xffffff00 }, ;
      { "darkblue", 0xff8b0000 }, ;
      { "darkcyan", 0xff8b8b00 }, ;
      { "darkgoldenrod", 0xff0b86b8 }, ;
      { "darkgray", 0xffa9a9a9 }, ;
      { "darkgreen", 0xff006400 }, ;
      { "darkkhaki", 0xff6bb7bd }, ;
      { "darkmagenta", 0xff8b008b }, ;
      { "darkolivegreen", 0xff2f6b55 }, ;
      { "darkorange", 0xff008cff }, ;
      { "darkorchid", 0xffcc3299 }, ;
      { "darkred", 0xff00008b }, ;
      { "darksalmon", 0xff7a96e9 }, ;
      { "darkseagreen", 0xff8fbc8f }, ;
      { "darkslateblue", 0xff8b3d48 }, ;
      { "darkslategray", 0xff4f4f2f }, ;
      { "darkturquoise", 0xffd1ce00 }, ;
      { "darkviolet", 0xffd30094 }, ;
      { "deeppink", 0xff9314ff }, ;
      { "deepskyblue", 0xffffbf00 }, ;
      { "dimgray", 0xff696969 }, ;
      { "dodgerblue", 0xffff901e }, ;
      { "firebrick", 0xff2222b2 }, ;
      { "floralwhite", 0xfff0faff }, ;
      { "forestgreen", 0xff228b22 }, ;
      { "fuchsia", 0xffff00ff }, ;
      { "gainsboro", 0xffdcdcdc }, ;
      { "ghostwhite", 0xfffff8f8 }, ;
      { "gold", 0xff00d7ff }, ;
      { "goldenrod", 0xff20a5da }, ;
      { "gray", 0xff808080 }, ;
      { "green", 0xff008000 }, ;
      { "greenyellow", 0xff2fffad }, ;
      { "honeydew", 0xfff0fff0 }, ;
      { "hotpink", 0xffb469ff }, ;
      { "indianred", 0xff5c5ccd }, ;
      { "indigo", 0xff82004b }, ;
      { "ivory", 0xfff0ffff }, ;
      { "khaki", 0xff8ce6f0 }, ;
      { "lavender", 0xfffae6e6 }, ;
      { "lavenderblush", 0xfff5f0ff }, ;
      { "lawngreen", 0xff00fc7c }, ;
      { "lemonchiffon", 0xffcdfaff }, ;
      { "lightblue", 0xffe6d8ad }, ;
      { "lightcoral", 0xff8080f0 }, ;
      { "lightcyan", 0xffffffe0 }, ;
      { "lightgoldenrodyellow", 0xffd2fafa }, ;
      { "lightgreen", 0xff90ee90 }, ;
      { "lightgrey", 0xffd3d3d3 }, ;
      { "lightpink", 0xffc1b6ff }, ;
      { "lightsalmon", 0xff7aa0ff }, ;
      { "lightseagreen", 0xffaab220 }, ;
      { "lightskyblue", 0xffface87 }, ;
      { "lightslategray", 0xff998877 }, ;
      { "lightsteelblue", 0xffdec4b0 }, ;
      { "lightyellow", 0xffe0ffff }, ;
      { "lime", 0xff00ff00 }, ;
      { "limegreen", 0xff32cd32 }, ;
      { "linen", 0xffe6f0fa }, ;
      { "magenta", 0xffff00ff }, ;
      { "maroon", 0xff000080 }, ;
      { "mediumaquamarine", 0xffaacd66 }, ;
      { "mediumblue", 0xffcd0000 }, ;
      { "mediumorchid", 0xffd355ba }, ;
      { "mediumpurple", 0xffdb7093 }, ;
      { "mediumseagreen", 0xff71b33c }, ;
      { "mediumslateblue", 0xffee687b }, ;
      { "mediumspringgreen", 0xff9afa00 }, ;
      { "mediumturquoise", 0xffccd148 }, ;
      { "mediumvioletred", 0xff8515c7 }, ;
      { "midnightblue", 0xff701919 }, ;
      { "mintcream", 0xfffafff5 }, ;
      { "mistyrose", 0xffe1e4ff }, ;
      { "moccasin", 0xffb5e4ff }, ;
      { "navajowhite", 0xffaddeff }, ;
      { "navy", 0xff800000 }, ;
      { "oldlace", 0xffe6f5fd }, ;
      { "olive", 0xff008080 }, ;
      { "olivedrab", 0xff238e6b }, ;
      { "orange", 0xff00a5ff }, ;
      { "orangered", 0xff0045ff }, ;
      { "orchid", 0xffd670da }, ;
      { "palegoldenrod", 0xffaae8ee }, ;
      { "palegreen", 0xff98fb98 }, ;
      { "paleturquoise", 0xffeeeeaf }, ;
      { "palevioletred", 0xff9370db }, ;
      { "papayawhip", 0xffd5efff }, ;
      { "peachpuff", 0xffb9daff }, ;
      { "peru", 0xff3f85cd }, ;
      { "pink", 0xffcbc0ff }, ;
      { "plum", 0xffdda0dd }, ;
      { "powderblue", 0xffe6e0b0 }, ;
      { "purple", 0xff800080 }, ;
      { "red", 0xff0000ff }, ;
      { "rosybrown", 0xff8f8fbc }, ;
      { "royalblue", 0xffe16941 }, ;
      { "saddlebrown", 0xff13458b }, ;
      { "salmon", 0xff7280fa }, ;
      { "sandybrown", 0xff60a4f4 }, ;
      { "seagreen", 0xff578b2e }, ;
      { "seashell", 0xffeef5ff }, ;
      { "sienna", 0xff2d52a0 }, ;
      { "silver", 0xffc0c0c0 }, ;
      { "skyblue", 0xffebce87 }, ;
      { "slateblue", 0xffcd5a6a }, ;
      { "slategray", 0xff908070 }, ;
      { "snow", 0xfffafaff }, ;
      { "springgreen", 0xff7fff00 }, ;
      { "steelblue", 0xffb48246 }, ;
      { "tan", 0xff8cb4d2 }, ;
      { "teal", 0xff808000 }, ;
      { "thistle", 0xffd8bfd8 }, ;
      { "tomato", 0xff4763ff }, ;
      { "turquoise", 0xffd0e040 }, ;
      { "violet", 0xffee82ee }, ;
      { "wheat", 0xffb3def5 }, ;
      { "white", 0xffffffff }, ;
      { "whitesmoke", 0xfff5f5f5 }, ;
      { "yellow", 0xff00ffff }, ;
      { "yellowgreen", 0xff32cd9a } ;
      }

   IF ValType( uPar ) == "C"
      uPar := Lower( AllTrim( uPar ) )
      AEval( aColors, {| x | if( x[ 1 ] == uPar, nColor := x[ 2 ], '' ) } )
   ELSEIF HB_ISNUMERIC( uPar ) .AND. uPar > 0 .AND. uPar <= Len( aColors )
       nColor := aColors[ uPar, 2 ]
   ENDIF

   RETURN iif( ::lReturnRGB, nColor % 0xff000000, nColor )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SetRGB( red, green, blue ) CLASS HBPrinter

   RETURN RR_SetRGB( red, green, blue )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SetTextCharExtra( col ) CLASS HBPrinter

   LOCAL p1 := ::Convert( { 0, 0 } ), p2 := ::Convert( { 0, col } ), nRet

   nRet := RR_SetTextCharExtra( p2[ 2 ] - p1[ 2 ], ::hData )
   ::Error := iif( nRet == 0x80000000, 1, 0 )

   RETURN nRet

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD GetTextCharExtra() CLASS HBPrinter

   LOCAL nRet := RR_GetTextCharExtra( ::hData )

   ::Error := iif( nRet == 0x80000000, 1, 0 )

   RETURN nRet

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SetTextJustification( col ) CLASS HBPrinter

   LOCAL p1 := ::Convert( { 0, 0 } ), p2 := ::Convert( { 0, col } )

   RETURN RR_SetTextJustification( p2[ 2 ] - p1[ 2 ], ::hData )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD GetTextJustification() CLASS HBPrinter

   RETURN RR_GetTextJustification( ::hData )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SetTextAlign( style ) CLASS HBPrinter

   LOCAL nRet := RR_SetTextAlign( style, ::hData )

   ::Error := iif( nRet == GDI_ERROR, 1, 0 )

   RETURN nRet

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD GetTextAlign() CLASS HBPrinter

   LOCAL nRet := RR_GetTextAlign( ::hData )

   ::Error := iif( nRet == GDI_ERROR, 1, 0 )

   RETURN nRet

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Picture( row, col, height, width, cpicture, exth, extw, lImageSize ) CLASS HBPrinter

   LOCAL lp1, lp2, lp3

   lp1 := ::Convert( { row, col } )

   IF height == NIL
      height := ::MaxRow
   ENDIF
   IF width == NIL
      width := ::MaxCol
   ENDIF
   lp2 := ::Convert( { height, width }, 1 )
   IF exth == NIL
      exth := 0   // height of the 'extension' to fill with image replicas
   ENDIF
   IF extw == NIL
      extw := 0   // width of the 'extension' to fill with image replicas
   ENDIF
   lp3 := ::Convert( { exth, extw } )

   RETURN ( ::Error := RR_DrawPicture( cpicture, lp1, lp2, lp3, lImageSize, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Bitmap( row, col, height, width, hbitmap, exth, extw, lImageSize ) CLASS HBPrinter

   LOCAL lp1, lp2, lp3

   lp1 := ::Convert( { row, col } )
   IF height == NIL
      height := ::MaxRow
   ENDIF
   IF width == NIL
      width := ::MaxCol
   ENDIF
   lp2 := ::Convert( { height, width }, 1 )
   IF exth == NIL
      exth := 0   // height of the 'extension' to fill with image replicas
   ENDIF
   IF extw == NIL
      extw := 0   // width of the 'extension' to fill with image replicas
   ENDIF
   lp3 := ::Convert( { exth, extw } )

   RETURN ( ::Error := RR_DrawBitmap( hbitmap, lp1, lp2, lp3, lImageSize, ::hData ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
FUNCTION RR_Str2File( ctxt, cfile )

   LOCAL hand, lrec

   hand := FCreate( cfile )
   IF hand < 0
      RETURN 0
   ENDIF
   lrec := FWrite( hand, ctxt )
   FClose( hand )

   RETURN lrec

/*--------------------------------------------------------------------------------------------------------------------------------*/
FUNCTION RR_SayConvert( ltxt )

   DO CASE
   CASE ValType( ltxt ) $ "MC"
      RETURN ltxt
   CASE HB_ISNUMERIC( ltxt )
      RETURN Str( ltxt )
   CASE ValType( ltxt ) == "T"
      RETURN TToC( ltxt )
   CASE HB_ISDATE( ltxt )
      RETURN DToC( ltxt )
   CASE HB_ISLOGICAL( ltxt )
      RETURN iif( ltxt, ".T.", ".F." )
   ENDCASE

   RETURN ""

/*--------------------------------------------------------------------------------------------------------------------------------*/
FUNCTION RR_Str2Arr( cList, cDelimiter )

   LOCAL nPos
   LOCAL aList := {}
   LOCAL nLen := 0
   LOCAL aSub

   DO CASE
   CASE ValType( cDelimiter ) == 'C'
      cDelimiter := iif( cDelimiter == NIL, ',', cDelimiter )
      nLen := Len( cDelimiter )
      DO WHILE ( nPos := At( cDelimiter, cList ) ) # 0
         AAdd( aList, SubStr( cList, 1, nPos - 1 ) )
         cList := SubStr( cList, nPos + nLen )
      ENDDO
      AAdd( aList, cList )
   CASE HB_ISNUMERIC( cDelimiter )
      DO WHILE Len( ( nPos := Left( cList, cDelimiter ) ) ) == cDelimiter
         AAdd( aList, nPos )
         cList := SubStr( cList, cDelimiter + 1 )
      ENDDO
   CASE HB_ISARRAY( cDelimiter )
      AEval( cDelimiter, {| X | nLen += X } )
      DO WHILE Len( ( nPos := Left( cList, nLen ) ) ) == nLen
         aSub := {}
         AEval( cDelimiter, {| x | AAdd( aSub, Left( nPos, x ) ), nPos := SubStr( nPos, x + 1 ) } )
         AAdd( aList, aSub )
         cList := SubStr( cList, nLen + 1 )
      ENDDO
   ENDCASE

   RETURN aList

#ifdef HB_DYNLIB
/*--------------------------------------------------------------------------------------------------------------------------------*/
STATIC FUNCTION NumAt( cSearch, cString )

   LOCAL n := 0, nAt, nPos := 0

   DO WHILE ( nAt := At( cSearch, SubStr( cString, nPos + 1 ) ) ) > 0
      nPos += nAt
      ++n
   ENDDO

   RETURN n
#endif

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD ReportData( l_x1, l_x2, l_x3, l_x4, l_x5, l_x6 ) CLASS HBPrinter

   SET DEVICE TO PRINT
   SET PRINTER TO "hbprinter.rep" ADDITIVE
   SET PRINTER ON
   SET CONSOLE OFF
   ? '-----------------', Date(), Time()
   ?
   ?? iif( ValType( l_x1 ) <> "U", l_x1, "," )
   ?? iif( ValType( l_x2 ) <> "U", l_x2, "," )
   ?? iif( ValType( l_x3 ) <> "U", l_x3, "," )
   ?? iif( ValType( l_x4 ) <> "U", l_x4, "," )
   ?? iif( ValType( l_x5 ) <> "U", l_x5, "," )
   ?? iif( ValType( l_x6 ) <> "U", l_x6, "," )
   ? 'HDC                      :', ::hDC
   ? 'HDCREF                   :', ::hDCREF
   ? 'PRINTERNAME              :', ::PrinterName
   ? 'PRINTEDEFAULT            :', ::PrinterDefault
   ? 'VERT X HORZ SIZE         :', ::DevCaps[ DI_VERT_SIZE ], "x", ::DevCaps[ DI_HORZ_SIZE ]
   ? 'VERT X HORZ RES          :', ::DevCaps[ DI_VERT_RES ], "x", ::DevCaps[ DI_HORZ_RES ]
   ? 'VERT X HORZ LOGPIX       :', ::DevCaps[ DI_VERT_LOGPIX ], "x", ::DevCaps[ DI_HORZ_LOGPIX ]
   ? 'VERT X HORZ PHYS. SIZE   :', ::DevCaps[ DI_VERT_PHYSIZE ], "x", ::DevCaps[ DI_HORZ_PHYSIZE ]
   ? 'VERT X HORZ PHYS. OFFSET :', ::DevCaps[ DI_VERT_PHYOFFS ], "x", ::DevCaps[ DI_HORZ_PHYOFFS ]
   ? 'VERT X HORZ FONT SIZE    :', ::DevCaps[ DI_VERT_FONTSIZE ], "x", ::DevCaps[ DI_HORZ_FONTSIZE ]
   ? 'MAX ROWS X COLS          :', ::DevCaps[ DI_ROWS ], "x", ::DevCaps[ DI_COLS ]
   ? 'ORIENTATION              :', ::DevCaps[ DI_ORIENTATION ]
   ? 'TEXT METRICS ASCENT      :', ::DevCaps[ DI_TMASCENT ]
   ? 'PAPER SIZE               :', ::DevCaps[ DI_TMASCENT ]
   SET PRINTER OFF
   SET PRINTER TO
   SET CONSOLE ON
   SET DEVICE TO SCREEN

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD InitMessages( cLang ) CLASS HBPrinter

   LOCAL nAt, i, cData

#ifndef NO_GUI
   IF ! ValType( cLang ) $ "CM" .OR. Empty( cLang )
      cLang := _OOHG_GetLanguage()
   ENDIF
#endif
   IF ! ValType( cLang ) $ "CM" .OR. Empty( cLang )
      cLang := Set( _SET_LANGUAGE )
   ENDIF
   IF ( nAt := At( ".", cLang ) ) > 0
      cLang := Left( cLang, nAt - 1 )
   ENDIF
   cLang := Upper( AllTrim( cLang ) )

   DO CASE
   CASE cLang == "FR"                                 // French
      ::aOpisy := { "Pr�visualisation", ;             // 01
         "&Abandonner", ;                             // 02
         "&Imprimer", ;                               // 03
         "&Enregistrer", ;                            // 04
         "&Premier", ;                                // 05
         "P&r�c�dent", ;                              // 06
         "&Suivant", ;                                // 07
         "&Dernier", ;                                // 08
         "Zoom +", ;                                  // 09
         "Zoom -", ;                                  // 10
         "&Options", ;                                // 11
         "Aller � la page:", ;                        // 12
         "Aper�u de la page", ;                       // 13
         "Aper�u affichettes", ;                      // 14
         "Page", ;                                    // 15
         "Imprimer la page en cours", ;               // 16
         "Pages:", ;                                  // 17
         "Plus de zoom !", ;                          // 18
         "Options d'impression", ;                    // 19
         "Imprimer de", ;                             // 20
         "�", ;                                       // 21
         "Copies", ;                                  // 22
         "Classement", ;                              // 23
         "Tout dans l'intervalle", ;                  // 24
         "Impair seulement", ;                        // 25
         "Pair seulement", ;                          // 26
         "Tout mais impair d'abord", ;                // 27
         "Tout mais pair d'abord", ;                  // 28
         "Impression ....", ;                         // 29
         "Attente de changement de papier...", ;      // 30
         "Appuyez sur OK pour continuer.", ;          // 31
         "Termin� !", ;                               // 32
         "Enregistrer sous...", ;                     // 33
         "Enregistrer tout", ;                        // 34
         "Fichiers EMF", ;                            // 35
         "Tous les fichiers", ;                       // 36
         "Param�tre non support�:", ;                 // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "S�lectionnez un dossier", ;                 // 50
         "Le rapport est vide!", ;                    // 51
         "&OK" }                                      // 52
   CASE cLang == "DEWIN" .OR. ;
        cLang == "DE"                                 // German
      ::aOpisy := { "Vorschau", ;                     // 01
         "&Abbruch", ;                                // 02
         "&Drucken", ;                                // 03
         "&Speichern", ;                              // 04
         "&Erste", ;                                  // 05
         "&Vorige", ;                                 // 06
         "&N�chste", ;                                // 07
         "&Letzte", ;                                 // 08
         "Ver&gr��ern", ;                             // 09
         "Ver&kleinern", ;                            // 10
         "&Optionen", ;                               // 11
         "Seite:", ;                                  // 12
         "Seitenvorschau", ;                          // 13
         "�berblick", ;                               // 14
         "Seite", ;                                   // 15
         "Aktuelle Seite drucken", ;                  // 16
         "Seiten:", ;                                 // 17
         "Maximum erreicht!", ;                       // 18
         "Druckeroptionen", ;                         // 19
         "Drucke von", ;                              // 20
         "bis", ;                                     // 21
         "Anzahl", ;                                  // 22
         "Bereich", ;                                 // 23
         "Alle Seiten", ;                             // 24
         "Ungerade Seiten", ;                         // 25
         "Gerade Seiten", ;                           // 26
         "Alles ungerade Seiten zuerst", ;            // 27
         "Alles gerade Seiten zuerst", ;              // 28
         "Druckt ....", ;                             // 29
         "Bitte Papier nachlegen...", ;               // 30
         "Dr�cken Sie OK, um fortzufahren.", ;        // 31
         "Getan!", ;                                  // 32
         "Speichern als...", ;                        // 33
         "Speichern alle", ;                          // 34
         "EMF files", ;                               // 35
         "Alle Dateien", ;                            // 36
         "Nicht unterst�tzte Einstellung:", ;         // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "W�hlen Sie einen Ordner", ;                 // 50
         "Bericht ist leer!", ;                       // 51
         "&OK" }                                      // 52
   CASE cLang == "IT"                                 // Italian
      ::aOpisy := { "Anteprima", ;                    // 01
         "&Cancella", ;                               // 02
         "S&tampa", ;                                 // 03
         "&Salva", ;                                  // 04
         "&Primo", ;                                  // 05
         "&Indietro", ;                               // 06
         "&Avanti", ;                                 // 07
         "&Ultimo", ;                                 // 08
         "Zoom In", ;                                 // 09
         "Zoom Out", ;                                // 10
         "&Opzioni", ;                                // 11
         "Pagina:", ;                                 // 12
         "Pagina anteprima ", ;                       // 13
         "Miniatura Anteprima", ;                     // 14
         "Pagina", ;                                  // 15
         "Stampa solo pagina attuale", ;              // 16
         "Pagine:", ;                                 // 17
         "Limite zoom !", ;                           // 18
         "Opzioni Stampa", ;                          // 19
         "Stampa da", ;                               // 20
         "a", ;                                       // 21
         "Copie", ;                                   // 22
         "Confronto", ;                               // 23
         "Tutte", ;                                   // 24
         "Solo dispari", ;                            // 25
         "Solo pari", ;                               // 26
         "Tutte iniziando dispari", ;                 // 27
         "Tutte iniziando pari", ;                    // 28
         "Stampa in corso ....", ;                    // 29
         "Attendere cambio carta...", ;               // 30
         "Premere OK per continuare.", ;              // 31
         "Fatto !", ;                                 // 32
         "Salva come...", ;                           // 33
         "Salva tutto", ;                             // 34
         "File EMF", ;                                // 35
         "Tutti i file", ;                            // 36
         "Impostazione non supportata:", ;            // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Seleziona una cartella", ;                  // 50
         "Il rapporto � vuoto!", ;                    // 51
         "&OK" }                                      // 52
   CASE cLang == "PLWIN" .OR. ;
        cLang == "PL852" .OR. ;
        cLang == "PLISO" .OR. ;
        cLang == "PLMAZ"                              // Polish
      ::aOpisy := { "Podgl�d", ;                      // 01
         "&Rezygnuj", ;                               // 02
         "&Drukuj", ;                                 // 03
         "Zapisz", ;                                  // 04
         "Pierwsza", ;                                // 05
         "Poprzednia", ;                              // 06
         "Nast�pna", ;                                // 07
         "Ostatnia", ;                                // 08
         "Powi�ksz", ;                                // 09
         "Pomniejsz", ;                               // 10
         "Opc&je", ;                                  // 11
         "Id� do strony:", ;                          // 12
         "Podgl�d strony", ;                          // 13
         "Podgl�d miniaturek", ;                      // 14
         "Strona", ;                                  // 15
         "Drukuj aktualn� stron�", ;                  // 16
         "Stron:", ;                                  // 17
         "Nie mozna wi�cej !", ;                      // 18
         "Opcje drukowania", ;                        // 19
         "Drukuj od", ;                               // 20
         "do", ;                                      // 21
         "Kopii", ;                                   // 22
         "Zakres", ;                                  // 23
         "Wszystkie z zakresu", ;                     // 24
         "Tylko nieparzyste", ;                       // 25
         "Tylko parzyste", ;                          // 26
         "Najpierw nieparzyste", ;                    // 27
         "Najpierw parzyste", ;                       // 28
         "Drukowanie...", ;                           // 29
         "Czekam na zmiane papieru...", ;             // 30
         "Nacisnij OK, aby kontynuowac.", ;           // 31
         "Gotowy !", ;                                // 32
         "Zapisz jako...", ;                          // 33
         "Zapisz wszystko", ;                         // 34
         "Pliki EMF", ;                               // 35
         "Wszystkie pliki", ;                         // 36
         "Nieobslugiwane ustawienie:", ;              // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Wybierz folder", ;                          // 50
         "Raport jest pusty!", ;                      // 51
         "&OK" }                                      // 52
   CASE cLang == "PT"                                 // Portuguese
      ::aOpisy := { "Inspe��o Pr�via", ;              // 01
         "&Cancelar", ;                               // 02
         "&Imprimir", ;                               // 03
         "&Salvar", ;                                 // 04
         "&Primera", ;                                // 05
         "&Anterior", ;                               // 06
         "Pr�ximo", ;                                 // 07
         "&�ltimo", ;                                 // 08
         "Zoom +", ;                                  // 09
         "Zoom -", ;                                  // 10
         "&Op��es", ;                                 // 11
         "Pag.:", ;                                   // 12
         "P�gina ", ;                                 // 13
         "Miniaturas", ;                              // 14
         "Pag.", ;                                    // 15
         "Imprimir somente a pag. atual", ;           // 16
         "P�ginas:", ;                                // 17
         "Zoom M�ximo/Minimo", ;                      // 18
         "Op��es de Impress�o", ;                     // 19
         "Imprimir de", ;                             // 20
         "para", ;                                    // 21
         "C�pias", ;                                  // 22
         "Agrupamento", ;                             // 23
         "Tudo a partir desta", ;                     // 24
         "S� �mpares", ;                              // 25
         "S� Pares", ;                                // 26
         "Todas as �mpares Primeiro", ;               // 27
         "Todas Pares primero", ;                     // 28
         "Imprimindo ....", ;                         // 29
         "Esperando por papel...", ;                  // 30
         "Pressione OK para continuar.", ;            // 31
         "Feito!", ;                                  // 32
         "Salvar como...", ;                          // 33
         "Salvar tudo", ;                             // 34
         "Arquivos EMF", ;                            // 35
         "Todos os arquivos", ;                       // 36
         "Configura��o n�o suportada:", ;             // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Selecione uma pasta", ;                     // 50
         "O relat�rio est� vazio!", ;                 // 51
         "&OK" }                                      // 52
   CASE cLang == "RUKOI8" .OR. ;
        cLang == "RU866"  .OR. ;
        cLang == "RUWIN"                              // Russian
      ::aOpisy := { '��������', ;                     // 01
         '�����', ;                                   // 02
         '������', ;                                  // 03
         '���������', ;                               // 04
         '������', ;                                  // 05
         '�����', ;                                   // 06
         '������', ;                                  // 07
         '�����', ;                                   // 08
         '���������', ;                               // 09
         '���������', ;                               // 10
         '�����', ;                                   // 11
         '��������:', ;                               // 12
         '�������� �������� ', ;                      // 13
         '���������', ;                               // 14
         '��������', ;                                // 15
         '�������� �������', ;                        // 16
         '�������:', ;                                // 17
         '��������� ������ ���������������!', ;       // 18
         '��������� ������', ;                        // 19
         '�������� �', ;                              // 20
         '��', ;                                      // 21
         '�����', ;                                   // 22
         '����������', ;                              // 23
         '��� ��������', ;                            // 24
         '��������', ;                                // 25
         '׸����', ;                                  // 26
         '���, �� ������� ��������', ;                // 27
         '���, �� ������� ������', ;                  // 28
         '������ ....', ;                             // 29
         '�������� ������...', ;                      // 30
         "Press OK to continue.", ;                   // 31
         "Done!", ;                                   // 32
         '��������� ���...', ;                        // 33
         '��������� ���', ;                           // 34
         '����� EMF', ;                               // 35
         '��� �����', ;                               // 36
         "Unsupported setting:", ;                    // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Select a folder", ;                         // 50
         "Report is empty!", ;                        // 51
         "&OK" }                                      // 52
   CASE cLang == "ES" .OR. ;
        cLang == "ESWIN"                              // Spanish
      ::aOpisy := { "Vista Previa", ;                 // 01
         "&Cerrar", ;                                 // 02
         "&Imprimir", ;                               // 03
         "&Guardar", ;                                // 04
         "&Primera", ;                                // 05
         "&Anterior", ;                               // 06
         "&Siguiente", ;                              // 07
         "&�ltima", ;                                 // 08
         "Zoom +", ;                                  // 09
         "Zoom -", ;                                  // 10
         "&Opciones", ;                               // 11
         "Ir a P�gina:", ;                            // 12
         "Vista previa", ;                            // 13
         "Miniaturas", ;                              // 14
         "P�gina", ;                                  // 15
         "Imprimir p�gina actual", ;                  // 16
         "P�ginas:", ;                                // 17
         "Zoom M�ximo/M�nimo", ;                      // 18
         "Opciones de Impresi�n", ;                   // 19
         "Imprimir de", ;                             // 20
         "a", ;                                       // 21
         "Copias", ;                                  // 22
         "Compaginaci�n", ;                           // 23
         "Todo, secuencial", ;                        // 24
         "Solo p�ginas impares", ;                    // 25
         "Solo p�ginas pares", ;                      // 26
         "Todo, p�ginas impares primero", ;           // 27
         "Todo, p�ginas pares primero", ;             // 28
         "Imprimiendo...", ;                          // 29
         "Esperando cambio de papel...", ;            // 30
         "Haga clic en OK para continuar.", ;         // 31
         "�Listo!", ;                                 // 32
         "Guardar co&mo...", ;                        // 33
         "Guardar &todo", ;                           // 34
         "Archivos EMF", ;                            // 35
         "Todos los archivos", ;                      // 36
         "Configuraci�n no soportada:", ;             // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Seleccione una carpeta", ;                  // 50
         "�El reporte est� vac�o!", ;                 // 51
         "&OK" }                                      // 52
   CASE cLang == "UK" .OR. ;
        cLang == "UA"                                 // Ukranian
      ::aOpisy := { '��������', ;                     // 01
         '���i�', ;                                   // 02
         '����', ;                                    // 03
         '��������', ;                                // 04
         '�������', ;                                 // 05
         '�����', ;                                   // 06
         '������', ;                                  // 07
         '�i����', ;                                  // 08
         '��i������', ;                               // 09
         '��������', ;                                // 10
         '���i�', ;                                   // 11
         '����i���:', ;                               // 12
         '�������� ����i��� ', ;                      // 13
         '�i�i�����', ;                               // 14
         '����i���', ;                                // 15
         '��������� �������', ;                       // 16
         '����i���:', ;                               // 17
         '��������� ���� �������������!', ;           // 18
         '��������� �����', ;                         // 19
         '����i��� �', ;                              // 20
         '��', ;                                      // 21
         '���i�', ;                                   // 22
         '�����������', ;                             // 23
         '��i ���i���', ;                             // 24
         '������i', ;                                 // 25
         '����i', ;                                   // 26
         '��i, ��� ������ ������i', ;                 // 27
         '��i, ��� ������ ����i', ;                   // 28
         '���� ....', ;                               // 29
         '���i�i�� ���i�...', ;                       // 30
         "Press OK to continue.", ;                   // 31
         "Done!", ;                                   // 32
         '�������� ��...', ;                          // 33
         '�������� ���', ;                            // 34
         '����� EMF', ;                               // 35
         '��i �����', ;                               // 36
         "Unsupported setting:", ;                    // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Select a folder", ;                         // 50
         "Report is empty!", ;                        // 51
         "&OK" }                                      // 52
   CASE cLang == "FI"                                 // Finnish
      ::aOpisy := { "Esikatsele", ;                   // 01
         "&Keskeyt�", ;                               // 02
         "&Tulosta", ;                                // 03
         "T&allenna", ;                               // 04
         "&Ensimm�inen", ;                            // 05
         "E&dellinen", ;                              // 06
         "&Seuraava", ;                               // 07
         "&Viimeinen", ;                              // 08
         "Suurenna", ;                                // 09
         "Pienenn�", ;                                // 10
         "&Optiot", ;                                 // 11
         "Mene sivulle:", ;                           // 12
         "Esikatsele sivu ", ;                        // 13
         "Esikatsele miniatyyrit", ;                  // 14
         "Sivu", ;                                    // 15
         "Tulosta t�m� sivu", ;                       // 16
         "Sivuja:", ;                                 // 17
         "Ei voi suurentaa !", ;                      // 18
         "Tulostus optiot", ;                         // 19
         "Alkaen", ;                                  // 20
         "->", ;                                      // 21
         "Kopiot", ;                                  // 22
         "Tulostus alue", ;                           // 23
         "Kaikki alueelta", ;                         // 24
         "Vain parittomat", ;                         // 25
         "Vain parilleset", ;                         // 26
         "Kaikki paitsi ensim. pariton", ;            // 27
         "Kaikki paitsi ensim. parillinen", ;         // 28
         "Tulostan ....", ;                           // 29
         "Odotan paperin vaihtoa...", ;               // 30
         "Jatka painamalla OK.", ;                    // 31
         "Valmis!", ;                                 // 32
         "Tallenna nimell�...", ;                     // 33
         "Tallenna kaikki", ;                         // 34
         "EMF Tiedostot", ;                           // 35
         "Kaikki Tiedostot", ;                        // 36
         "Asetusta ei tueta:", ;                      // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Valitse kansio", ;                          // 50
         "Raportti on tyhj�!", ;                      // 51
         "&OK" }                                      // 52
   CASE cLang == "NL"                                 // Dutch
      ::aOpisy := { 'Afdrukvoorbeeld', ;              // 01
         'Annuleer', ;                                // 02
         'Print', ;                                   // 03
         'Opslaan', ;                                 // 04
         'Eerste', ;                                  // 05
         'Vorige', ;                                  // 06
         'Volgende', ;                                // 07
         'Laatste', ;                                 // 08
         'Inzoomen', ;                                // 09
         'Uitzoomen', ;                               // 10
         'Opties', ;                                  // 11
         'Ga naar pagina:', ;                         // 12
         'Pagina voorbeeld ', ;                       // 13
         'Thumbnails voorbeeld', ;                    // 14
         'Pagina', ;                                  // 15
         'Print alleen huidige pagina', ;             // 16
         "Pagina's:", ;                               // 17
         'Geen zoom meer !', ;                        // 18
         'Print opties', ;                            // 19
         'Print van', ;                               // 20
         'tot', ;                                     // 21
         'Exemplaren', ;                              // 22
         "Pagina's", ;                                // 23
         "Alle pagina's", ;                           // 24
         'Alleen oneven', ;                           // 25
         'Alleen even', ;                             // 26
         'Alles maar oneven eerst', ;                 // 27
         'Alles maar even eerst', ;                   // 28
         'Printen ....', ;                            // 29
         'Wacht op papier wissel...', ;               // 30
         "Druk op OK om door te gaan.", ;             // 31
         "Gedaan!", ;                                 // 32
         'Be&waar als...', ;                          // 33
         'Bewaar &Alles', ;                           // 34
         'EMF-bestanden', ;                           // 35
         'Alle bestanden', ;                          // 36
         "Niet-ondersteunde instelling:", ;           // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Selecteer een map", ;                       // 50
         "Rapport is leeg!", ;                        // 51
         "&OK" }                                      // 52
   CASE cLang == "CS"                                 // Czech
      ::aOpisy := { "N�hled", ;                       // 01
         "&Storno", ;                                 // 02
         "&Tisk", ;                                   // 03
         "&Ulo�it", ;                                 // 04
         "&Prvn�", ;                                  // 05
         "P&�edchoz�", ;                              // 06
         "&Dal��", ;                                  // 07
         "P&osledn�", ;                               // 08
         "Z&v�t�it", ;                                // 09
         "&Zmen�it", ;                                // 10
         "&Mo�nosti", ;                               // 11
         "Uka� stranu:", ;                            // 12
         "N�hled strany ", ;                          // 13
         "N�hled v�ce str�n", ;                       // 14
         "Strana", ;                                  // 15
         "Tisk aktu�ln� strany", ;                    // 16
         "Str�n:", ;                                  // 17
         "Nemo�no d�le m�nit velikost!", ;            // 18
         "Mo�nosti tisku", ;                          // 19
         "Tisk od", ;                                 // 20
         "po", ;                                      // 21
         "K�pi�", ;                                   // 22
         "Tisk stran", ;                              // 23
         "V�echny stran", ;                           // 24
         "Jenom lich�", ;                             // 25
         "Jenom sud�", ;                              // 26
         "V�echny krom� prvn� lich�", ;               // 27
         "V�echny krom� prvn� sud�j", ;               // 28
         "Tisknu ...", ;                              // 29
         "�ek�m na pap�r ...", ;                      // 30
         "Pokracujte stisknut�m tlac�tka OK.", ;      // 31
         "Hotovo!", ;                                 // 32
         "Ulo�it &jako...", ;                         // 33
         "Ulo�it &v�echno", ;                         // 34
         "EMF soubor", ;                              // 35
         "V�echny soubory", ;                         // 36
         "Nepodporovan� nastaven�:", ;                // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Vyberte slo�ku", ;                          // 50
         "Zpr�va je pr�zdn�!", ;                      // 51
         "&OK" }                                      // 52
   CASE cLang == "SK"                                 // Slovak
      ::aOpisy := { "N�h�ad", ;                       // 01
         "&Storno", ;                                 // 02
         "&Tla�", ;                                   // 03
         "Ulo�it", ;                                  // 04
         "&Prv�", ;                                   // 05
         "P&redch�zaj�ca", ;                          // 06
         "&�al�ia", ;                                 // 07
         "Po&sledn�", ;                               // 08
         "Zoom +", ;                                  // 09
         "Zoom -", ;                                  // 10
         "&Mo�nosti", ;                               // 11
         "Uk� stranu:", ;                            // 12
         "N�h�ad strany ", ;                          // 13
         "N�h�ad viacer�ch str�nok", ;                // 14
         "Strana", ;                                  // 15
         "Tla� aktu�lnej strany", ;                   // 16
         "Strana:", ;                                 // 17
         "U� �iadne pribl�enie", ;                   // 18
         "Mo�nosti tla�e", ;                          // 19
         "Tla� od", ;                                 // 20
         "po", ;                                      // 21
         "K�pi�", ;                                   // 22
         "Tla� str�n", ;                              // 23
         "V�etky strany", ;                           // 24
         "Len nep�rne", ;                             // 25
         "Len p�rne", ;                               // 26
         "V�etko, najsk�r nep�rne str�nky", ;         // 27
         "V�etko, najsk�r p�rne str�nky", ;           // 28
         "Tla��m ...", ;                              // 29
         "�ak�m na papier ...", ;                     // 30
         "Pokracujte stlacen�m tlacidla OK. ", ;      // 31
         "Hotov�!", ;                                 // 32
         "Ulo�i ako...", ;                            // 33
         "Ulo�i v�etko", ;                            // 34
         "EMF s�bor", ;                               // 35
         "V�etky s�bory", ;                           // 36
         "Nepodporovan� nastavenie:", ;               // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Vyberte priecinok", ;                       // 50
         "Zpr�va je pr�zdn�!", ;                      // 51
         "&OK" }                                      // 52
   CASE cLang == "SLWIN" .OR. ;
        cLang == "SLISO" .OR. ;
        cLang == "SL852" .OR. ;
        cLang == "SL437"                              // Slovenian
      ::aOpisy := { 'Predgled', ;                     // 01
         'Prekini', ;                                 // 02
         'Natisni', ;                                 // 03
         'Shrani', ;                                  // 04
         'Prva', ;                                    // 05
         'Prej�nja', ;                                // 06
         'Naslednja', ;                               // 07
         'Zadnja', ;                                  // 08
         'Pove�aj', ;                                 // 09
         'Pomanj�aj', ;                               // 10
         'Mo�nosti', ;                                // 11
         'Skok na stran:', ;                          // 12
         'Predgled', ;                                // 13
         'Mini predgled', ;                           // 14
         'Stran', ;                                   // 15
         'Samo trenutna stran', ;                     // 16
         'Strani:', ;                                 // 17
         'Ni ve� pove�ave!', ;                        // 18
         'Mo�nosti tiskanja', ;                       // 19
         'Tiskaj od', ;                               // 20
         'do', ;                                      // 21
         'Kopij', ;                                   // 22
         'Tiskanje', ;                                // 23
         'Vse iz izbora', ;                           // 24
         'Samo neparne strani', ;                     // 25
         'Samo parne strani', ;                       // 26
         'Vse - neparne strani najprej', ;            // 27
         'Vse - parne strani najprej', ;              // 28
         'Tiskanje ....', ;                           // 29
         '�akanje na zamenjavo papirja...', ;         // 30
         "Pritisnite OK za nadaljevanje.", ;          // 31
         "Koncano!", ;                                // 32
         'Shrani kot...', ;                           // 33
         'Shrani vse', ;                              // 34
         'EMF datoteke', ;                            // 35
         'Vse datoteke', ;                            // 36
         "Nepodprta nastavitev:", ;                   // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Izberite mapo", ;                           // 50
         "Porocilo je prazno!", ;                     // 51
         "&OK" }                                      // 52
   CASE cLang == "HU"                                 // Hungarian
      ::aOpisy := { "El�n�zet", ;                     // 01
         "&M�gse", ;                                  // 02
         "Nyo&mtat�s", ;                              // 03
         "&Ment�s", ;                                 // 04
         "&Els�", ;                                   // 05
         "E&l�z�", ;                                  // 06
         "&K�vetkez�", ;                              // 07
         "&Utols�", ;                                 // 08
         "&Nagy�t�s", ;                               // 09
         "K&icsiny�t�s", ;                            // 10
         "&Opci�k", ;                                 // 11
         "Oldalt mutasd:", ;                          // 12
         "Oldal el�n�zete ", ;                        // 13
         "T�bb oldal el�n�zete", ;                    // 14
         "Oldal", ;                                   // 15
         "Aktu�lis oldal nyomtat�sa", ;               // 16
         "Oldal:", ;                                  // 17
         "A nagys�g tov�bb nem v�ltoztathat�!", ;     // 18
         "Nyomtat�si lehet�s�gek", ;                  // 19
         "Nyomtat�s ett�l", ;                         // 20
         "eddig", ;                                   // 21
         "M�solat", ;                                 // 22
         "Egyeztet�s", ;                              // 23
         "Minden oldalt", ;                           // 24
         "Csak a p�ratlan", ;                         // 25
         "Csak a p�ros", ;                            // 26
         "Mindet kiv�ve az els� p�ratlant", ;         // 27
         "Mindet kiv�ve az els� p�rost", ;            // 28
         "Nyomtatom ...", ;                           // 29
         "Pap�rra v�rok ...", ;                       // 30
         "A folytat�shoz nyomja meg az OK gombot.", ; // 31  ;
         "K�sz!", ;                                   // 32
         "Ment�s m�sk�nt ...", ;                      // 33
         "Mindet mentsd", ;                           // 34
         "EMF �llom�ny", ;                            // 35
         "Minden �llom�ny", ;                         // 36
         "Nem t�mogatott be�ll�t�s:", ;               // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "V�lasszon mapp�t", ;                        // 50
         "A jelent�s �res!", ;                        // 51
         "&OK" }                                      // 52
   CASE cLang == "EL"                                 // Greek - Ellinika
      ::aOpisy := { '�������', ;                      // 01
         '&�����', ;                                  // 02
         '&������', ;                                 // 03
         '&����', ;                                   // 04
         '&1�', ;                                     // 05
         '�&����/��', ;                               // 06
         '&�������', ;                                // 07
         '&������/�', ;                               // 08
         'Zoom +', ;                                  // 09
         'Zoom -', ;                                  // 10
         '&��������', ;                               // 11
         '������� ���:', ;                            // 12
         '������� ', ;                                // 13
         '������������', ;                            // 14
         '���.', ;                                    // 15
         '������ ���� ��� �������', ;                 // 16
         '�������:', ;                                // 17
         '��� ���� zoom !', ;                         // 18
         '��������', ;                                // 19
         '������ ���', ;                              // 20
         '���', ;                                     // 21
         '���������', ;                               // 22
         '����� ���������', ;                         // 23
         '���� ���', ;                                // 24
         '���� ����� ', ;                             // 25
         '���� �����', ;                              // 26
         '���� ����� ��� ��� 1� ����', ;              // 27
         '���� ����� ��� ��� 1� ����', ;              // 28
         '������ ....', ;                             // 29
         '������� ��� ������ �������...', ;           // 30
         "Press OK to continue.", ;                   // 31
         "Done!", ;                                   // 32
         '���������� ��..', ;                         // 33
         '���������� ����', ;                         // 34
         '������ EMF', ;                              // 35
         '��� �� ������', ;                           // 36
         "Unsupported setting:", ;                    // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Select a folder", ;                         // 50
         "Report is empty!", ;                        // 51
         "&OK" }                                      // 52
   CASE cLang == "BG"                                 // Bulgarian
      ::aOpisy := { '�������', ;                      // 01
         '�����', ;                                   // 02
         '�����', ;                                   // 03
         '�������', ;                                 // 04
         '������', ;                                  // 05
         '�����', ;                                   // 06
         '������', ;                                  // 07
         '����', ;                                    // 08
         '�������', ;                                 // 09
         '������', ;                                  // 10
         '�����', ;                                   // 11
         '��������:', ;                               // 12
         '������� �� ���������� ', ;                  // 13
         '���������', ;                               // 14
         '��������', ;                                // 15
         '�������� �� ������', ;                      // 16
         '��������:', ;                               // 17
         '��������� e ������� �� ����������!', ;      // 18
         '��������� �� �����', ;                      // 19
         '�������� ��', ;                             // 20
         '��', ;                                      // 21
         '�����', ;                                   // 22
         '���������', ;                               // 23
         '������ ��������', ;                         // 24
         '���������', ;                               // 25
         '�������', ;                                 // 26
         '������, �� ����� ���������', ;              // 27
         '������, �� ����� �������', ;                // 28
         '����� ....', ;                              // 29
         '��������� ������...', ;                     // 30
         "Press OK to continue.", ;                   // 31
         "Done!", ;                                   // 32
         '������� ����...', ;                         // 33
         '������� ������', ;                          // 34
         '������� EMF', ;                             // 35
         '������ �������', ;                          // 36
         "Unsupported setting:", ;                    // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Select a folder", ;                         // 50
         "Report is empty!", ;                        // 51
         "&OK" }                                      // 52
   CASE cLang == "HR852"                              // Croatian
      ::aOpisy := { "Pregled", ;                      // 01
         "Otkazati", ;                                // 02
         "Ispis", ;                                   // 03
         "U�tedjeti", ;                               // 04
         "Prvo", ;                                    // 05
         "Prethodni", ;                               // 06
         "Sljedeci", ;                                // 07
         "Posljednji", ;                              // 08
         "Zumirati", ;                                // 09
         "Umanji", ;                                  // 10
         "Opcije", ;                                  // 11
         "Idi na stranicu:", ;                        // 12
         "Pregled stranice", ;                        // 13
         "Pregledavanje slicica", ;                   // 14
         "Stranica", ;                                // 15
         "Ispis samo trenutne stranice", ;            // 16
         "Stranice:", ;                               // 17
         "Nema vi�e zumiranja!", ;                    // 18
         "Opcije ispisa", ;                           // 19
         "Ispis iz", ;                                // 20
         "->", ;                                      // 21
         "Kopije", ;                                  // 22
         "Raspon ispisa", ;                           // 23
         "Sve iz dometa", ;                           // 24
         "Samo neparno", ;                            // 25
         "Cak i samo", ;                              // 26
         "Sve osim neparno prvo", ;                   // 27
         "Sve, ali cak i prvo", ;                     // 28
         "Tisak ...", ;                               // 29
         "Ceka se promjena papira ...", ;             // 30
         "Pritisnite OK za nastavak.", ;              // 31
         "Gotovo!", ;                                 // 32
         "Spremi kao...", ;                           // 33
         "Spremi sve", ;                              // 34
         "EMF datoteke", ;                            // 35
         "Sve datoteke", ;                            // 36
         "Nepodr�ana postavka:", ;                    // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Odaberite mapu", ;                          // 50
         "Izvje�taj je prazan!", ;                    // 51
         "&OK" }                                      // 52
   CASE cLang == "EU"                                 // Basque
      ::aOpisy := { "Aurrebista", ;                   // 01
         "Utzi", ;                                    // 02
         "Inprimatu", ;                               // 03
         "Gorde", ;                                   // 04
         "Lehenik", ;                                 // 05
         "Aurrekoa", ;                                // 06
         "Hurrengoa", ;                               // 07
         "Azkena", ;                                  // 08
         "Zoom In", ;                                 // 09
         "Zoom handiagotu", ;                         // 10
         "Aukerak", ;                                 // 11
         "Joan Orrialdera:", ;                        // 12
         "Orriaren aurrebista", ;                     // 13
         "Miniatutako aurrebista", ;                  // 14
         "Orria", ;                                   // 15
         "Uneko orria inprimatu bakarrik", ;          // 16
         "Orrialdeak:", ;                             // 17
         "Ez gehiago zoom!", ;                        // 18
         "Inprimatzeko aukerak", ;                    // 19
         "Inprimatu", ;                               // 20
         "etik", ;                                    // 21
         "Kopiak", ;                                  // 22
         "Inprimatu barrutia", ;                      // 23
         "Guztiak barrutik", ;                        // 24
         "Bitxia bakarrik", ;                         // 25
         "Bakarrik", ;                                // 26
         "Lehenik eta bakoitiak", ;                   // 27
         "Guztiak, baina baita lehen ere", ;          // 28
         "Inprimaketa ...", ;                         // 29
         "Papera aldatzeko zain ...", ;               // 30
         "Sakatu OK jarraitzeko.", ;                  // 31
         "Egina!", ;                                  // 32
         "Gorde...", ;                                // 33
         "Gorde guztiak", ;                           // 34
         "EMF fitxategiak", ;                         // 35
         "Fitxategi guztiak", ;                       // 36
         "Ezarpenik gabeko ezarpena:", ;              // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Hautatu karpeta", ;                         // 50
         "Txostena hutsik dago!", ;                   // 51
         "&OK" }                                      // 52
   CASE cLang == "TR"                                 // Turkish
      ::aOpisy := { "�nizleme", ;                     // 01
         "Iptal", ;                                   // 02
         "Yazdir", ;                                  // 03
         "Kaydet", ;                                  // 04
         "Ilk", ;                                     // 05
         "�nceki", ;                                  // 06
         "Ileri", ;                                   // 07
         "Son", ;                                     // 08
         "Yakinlastir", ;                             // 09
         "Uzaklastir", ;                              // 10
         "Se�enekler", ;                              // 11
         "Sayfaya Git:", ;                            // 12
         "Sayfa �nizlemesi", ;                        // 13
         "K���k resimlerin �nizlemesi", ;             // 14
         "Sayfa", ;                                   // 15
         "Yalnizca ge�erli sayfayi yazdir", ;         // 16
         "Sayfalar:", ;                               // 17
         "Artik zoom yok!", ;                         // 18
         "Yazdirma se�enekleri", ;                    // 19
         "Yazdir", ;                                  // 20
         "kadar", ;                                   // 21
         "Kopya", ;                                   // 22
         "Karsilastirma", ;                           // 23
         "T�m araliktan", ;                           // 24
         "Sadece Garip", ;                            // 25
         "Sadece", ;                                  // 26
         "Ilk �nce garip olanlarin hepsi", ;          // 27
         "Ilk �nce hepsi bile", ;                     // 28
         "Yazdiriliyor ...", ;                        // 29
         "Kagit degisimi bekleniyor ...", ;           // 30
         "Devam etmek i�in OK tusuna basin.", ;       // 31
         "Bitti!", ;                                  // 32
         "Farkli kaydet ...", ;                       // 33
         "T�m�n� kaydet", ;                           // 34
         "EMF dosyalari", ;                           // 35
         "T�m dosyalar", ;                            // 36
         "Desteklenmeyen ayar:", ;                    // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Bir klas�r se�in", ;                        // 50
         "Rapor bos!", ;                              // 51
         "&OK" }                                      // 52
   OTHERWISE
      ::aOpisy := { "Preview", ;                      // 01
         "&Cancel", ;                                 // 02
         "&Print", ;                                  // 03
         "&Save", ;                                   // 04
         "&First", ;                                  // 05
         "P&revious", ;                               // 06
         "&Next", ;                                   // 07
         "&Last", ;                                   // 08
         "Zoom In", ;                                 // 09
         "Zoom Out", ;                                // 10
         "&Options", ;                                // 11
         "Go To Page:", ;                             // 12
         "Page preview ", ;                           // 13
         "Thumbnails preview", ;                      // 14
         "Page", ;                                    // 15
         "Print current page only", ;                 // 16
         "Pages:", ;                                  // 17
         "No more zoom!", ;                           // 18
         "Print options", ;                           // 19
         "Print from", ;                              // 20
         "to", ;                                      // 21
         "Copies", ;                                  // 22
         "Collation", ;                               // 23  HMG - Print range
         "Everything, sequential", ;                  // 24  HMG - All from range
         "Only odd pages", ;                          // 25
         "Only even pages", ;                         // 26
         "Everything, odd pages first", ;             // 27
         "Everything, even pages first", ;            // 28
         "Printing...", ;                             // 29
         "Waiting for paper change...", ;             // 30
         "Press OK to continue.", ;                   // 31
         "Done!", ;                                   // 32
         "Save as...", ;                              // 33
         "Save all", ;                                // 34
         "EMF files", ;                               // 35
         "All files", ;                               // 36
         "Unsupported setting:", ;                    // 37
         "UNKNOWN", ;                                 // 38
         "ORIENTATION", ;                             // 39
         "PAPERSIZE", ;                               // 40
         "SCALE", ;                                   // 41
         "COPIES", ;                                  // 42
         "DEFAULTSOURCE", ;                           // 43
         "PRINTQUALITY", ;                            // 44
         "COLOR", ;                                   // 45
         "DUPLEX", ;                                  // 46
         "COLLATE", ;                                 // 47
         "PAPERLENGTH", ;                             // 48
         "PAPERWIDTH", ;                              // 49
         "Select a folder", ;                         // 50
         "Report is empty!", ;                        // 51
         "&OK" }                                      // 52
   ENDCASE

   FOR i := 1 TO Len( ::aOpisy )
      IF ! Empty( cData := LoadString( i ) )
         ::aOpisy[ i ] := cData
      ENDIF
   NEXT i

   RETURN NIL

#ifndef NO_GUI
/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SaveMetaFiles( number, filename ) CLASS HBPrinter

   LOCAL n

   IF ::PreviewMode
      IF ! HB_ISNUMERIC( number ) .OR. number < 1 .OR. number > Len( ::MetaFiles )
         number := NIL
      ENDIF
      IF Empty( filename )
         IF Empty( filename := GetFolder( ::aOpisy[ 50 ] ) )
            RETURN NIL
         ENDIF
         IF Right( filename, 1 ) != "\"
            filename += "\"
         ENDIF
         IF Left( ::DocName, 1 ) != "\"
            filename += ::DocName + "_page_"
         ELSE
            filename += SubStr( ::DocName, 2 ) + "_page_"
         ENDIF
      ENDIF

      IF ::InMemory
         IF number == NIL
            AEval( ::MetaFiles, {| x, xi | RR_Str2File( x[ PG_FILE ], filename + AllTrim( Str( xi ) ) + ".emf" ) } )
         ELSE
            RR_Str2File( ::MetaFiles[ number, PG_FILE ], filename + AllTrim( Str( number ) ) + ".emf" )
         ENDIF
      ELSE
         IF number <> NIL
            COPY FILE ( ::BaseDoc + AllTrim( Str( number ) ) + '.emf' ) TO ( filename + AllTrim( Str( number ) ) + ".emf" )
         ELSE
            FOR n := 1 TO Len( ::MetaFiles )
               COPY FILE ( ::BaseDoc + AllTrim( Str( n ) ) + '.emf' ) TO ( filename + AllTrim( Str( n ) ) + ".emf" )
            NEXT
         ENDIF
      ENDIF

      IF ::NotifyOnSave
         MsgInfo( ::aOpisy[ 32 ], "" )
      ENDIF
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD PrevThumb( nclick ) CLASS HBPrinter

   LOCAL i, spage, oImage

   IF ::IloscStron < 2
      RETURN NIL
   ENDIF
   IF nclick <> NIL
      ::Page := ::nGroup * 15 + nclick
      ::oWinPreview:combo_1:value := ::Page
      RETURN NIL
   ENDIF
   IF Int( ( ::Page - 1 ) / 15 ) <> ::nGroup
      ::nGroup := Int( ( ::Page - 1 ) / 15 )
   ELSE
      RETURN NIL
   ENDIF
   spage := ::nGroup * 15

   FOR i := 1 TO 15
      oImage := GetControlObjectByHandle( ::aTH[ i, TH_HWND ] )
      IF i + spage > ::IloscStron
         oImage:Visible := .F.
      ELSE
         IF ::MetaFiles[ i + spage, PG_VERT_SIZE ] >= ::MetaFiles[ i + spage, PG_HORZ_SIZE ]
            ::aTH[ i, TH_HEIGHT ] := ::dy - 10
            ::aTH[ i, TH_WIDTH ] := ::aTH[ i, TH_HEIGHT ] * ::MetaFiles[ i + spage, PG_HORZ_SIZE ] / ::MetaFiles[ i + spage, PG_VERT_SIZE ]
         ELSE
            ::aTH[ i, TH_WIDTH ] := ::dx - 10
            ::aTH[ i, TH_HEIGHT ] := ::aTH[ i, TH_WIDTH ] * ::MetaFiles[ i + spage, PG_VERT_SIZE ] / ::MetaFiles[ i + spage, PG_HORZ_SIZE ]
         ENDIF

         oImage:SizePos( NIL, NIL, ::aTH[ i, TH_WIDTH ], ::aTH[ i, TH_HEIGHT ] )
         oImage:HBitMap := RR_PlayThumb( ::aTH[ i ], ::MetaFiles[ i + spage ], LTrim( Str( i + spage ) ), ::InMemory )
         oImage:Visible := .T.
      ENDIF
   NEXT

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD PrevShow() CLASS HBPrinter

   LOCAL spos

   IF ::Thumbnails
      ::PrevThumb()
   ENDIF

   spos := Array( 2 )
   IF Empty( ::aZoom[ 4 ] )
      spos[ 1 ] := 0
   ELSE
      spos[ 1 ] := GetScrollpos( ::aHS[ PREVIEW_PAGE_HWND ], SB_HORZ ) / ::aZoom[ 4 ]
   ENDIF
   IF Empty( ::aZoom[ 3 ] )
      spos[ 2 ] := 0
   ELSE
      spos[ 2 ] := GetScrollpos( ::aHS[ PREVIEW_PAGE_HWND ], SB_VERT ) / ::aZoom[ 3 ]
   ENDIF

   IF ::MetaFiles[ ::Page, PG_VERT_SIZE ] >= ::MetaFiles[ ::Page, PG_HORZ_SIZE ]
      ::aZoom[ 3 ] := ( ::aHS[ PREVIEW_PAGE_BOTTOM ] ) * ::Scale - 60
      ::aZoom[ 4 ] := ( ::aHS[ PREVIEW_PAGE_BOTTOM ] * ::MetaFiles[ ::Page, PG_HORZ_SIZE ] / ::MetaFiles[ ::Page, PG_VERT_SIZE ] ) * ::Scale - 60
   ELSE
      ::aZoom[ 3 ] := ( ::aHS[ PREVIEW_PAGE_RIGHT ] * ::MetaFiles[ ::Page, PG_VERT_SIZE ] / ::MetaFiles[ ::Page, PG_HORZ_SIZE ] ) * ::Scale - 60
      ::aZoom[ 4 ] := ( ::aHS[ PREVIEW_PAGE_RIGHT ] ) * ::Scale - 60
   ENDIF

   ::oWinPreview:StatusBar:Item( 1, ::aOpisy[ 15 ] + " " + AllTrim( Str( ::Page ) ) )

   IF ::aZoom[ 3 ] < 30
      ::Scale := ::Scale * 1.25
      ::PrevShow()
      MsgStop( ::aOpisy[ 18 ], "" )
   ENDIF

   WITH OBJECT ::oWinPagePreview
      :Visible := .F.
      :VirtualHeight := ::aZoom[ 3 ] + 20
      :VirtualWidth := ::aZoom[ 4 ] + 20
      :i1:SizePos( NIL, NIL, ::aZoom[ 4 ], ::aZoom[ 3 ] )
      :i1:HBitMap := RR_PlayPreview( :hWnd, ::MetaFiles[ ::Page ], ::aZoom, ::InMemory )
      :Visible := .T.
   END WIDTH

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD PrevPrint( nPage ) CLASS HBPrinter

   LOCAL i, ilkop, toprint := .T.

   IF ! Eval( ::BeforePrint )
      RETURN NIL
   ENDIF

   ::PreviewMode := .F.
   ::PrintingEMF := .T.
   RR_LaLaBye( 1, ::hData )
   IF nPage <> NIL
      ::StartDoc()
      ::SetPage( ::MetaFiles[ nPage, PG_ORIENTATION ], ::MetaFiles[ nPage, PG_PAPER_SIZE ] )
      ::StartPage()
      RR_PlayEnhMetaFile( ::MetaFiles[ nPage ], ::hDCRef, ::InMemory )
      ::EndPage()
      ::EndDoc()
   ELSE
      FOR ilkop = 1 TO ::nCopies
         IF ! Eval( ::BeforePrintCopy, ilkop )
            RR_LaLaBye( 0, ::hData )
            ::PrintingEMF := .F.
            ::PreviewMode := .T.
            RETURN NIL
         ENDIF
         ::StartDoc()
         FOR i := Max( 1, ::nFromPage ) TO Min( ::IloscStron, ::nToPage )
            DO CASE
            CASE ::PrintOpt == 1 ; toprint := .T.
            CASE ::PrintOpt == 2 .OR. ::PrintOpt == 4 ; toprint := !( i % 2 == 0 )
            CASE ::PrintOpt == 3 .OR. ::PrintOpt == 5 ; toprint := ( i % 2 == 0 )
            ENDCASE
            IF toprint
               toprint := .F.
               ::SetPage( ::MetaFiles[ i, PG_ORIENTATION ], ::MetaFiles[ i, PG_PAPER_SIZE ] )
               ::StartPage()
               RR_PlayEnhMetaFile( ::MetaFiles[ i ], ::hDCRef, ::InMemory )
               ::EndPage()
            ENDIF
         NEXT i
         ::EndDoc()
         IF ::PrintOpt == 4 .OR. ::PrintOpt == 5
            MsgBox( ::aOpisy[ 30 ], ::aOpisy[ 29 ] )
            ::StartDoc()
            FOR i := Max( 1, ::nFromPage ) TO Min( ::IloscStron, ::nToPage )
               DO CASE
               CASE ::PrintOpt == 4 ; toprint := ( i % 2 == 0 )
               CASE ::PrintOpt == 5 ; toprint := !( i % 2 == 0 )
               ENDCASE
               IF toprint
                  toprint := .F.
                  ::SetPage( ::MetaFiles[ i, PG_ORIENTATION ], ::MetaFiles[ i, PG_PAPER_SIZE ] )
                  ::StartPage()
                  RR_PlayEnhMetaFile( ::MetaFiles[ i ], ::hDCRef, ::InMemory )
                  ::EndPage()
               ENDIF
            NEXT i
            ::EndDoc()
         ENDIF
      NEXT ilkop
   ENDIF
   RR_LaLaBye( 0, ::hData )
   ::PrintingEMF := .F.
   ::PreviewMode := .T.
   Eval( ::AfterPrint )

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Preview( cParent, lWait, lSize ) CLASS HBPrinter

   LOCAL i, cName, oSplit, oPages, oImg

   IF ! ::PreviewMode
      RETURN NIL
   ENDIF

   ::IloscStron := Len( ::MetaFiles )
   IF ::IloscStron < 1
      MsgStop( ::aOpisy[ 51 ], "" )
      RETURN NIL
   ENDIF

   IF ! HB_ISLOGICAL( lWait )
      lWait := .T.
   ENDIF
   IF ! HB_ISLOGICAL( lSize )
      lSize := ! lWait
   ENDIF

   ::nGroup := -1
   ::Page := 1
   ::aTH := {}
   ::aHS := {}
   ::aZoom := { 0, 0, 0, 0 }
   ::Scale := ::PreviewScale
   ::nPages := {}

   IF ::nWhatToPrint < 2
      ::nToPage := ::IloscStron
   ELSE
      ::nToPage := Min( ::IloscStron, ::nToPage )
   ENDIF

   AAdd( ::aHS, { 0, 0, 0, 0, 0, 0, 0 } )
   IF ::PreviewRect[ 3 ] > 0 .AND. ::PreviewRect[ 4 ] > 0
      ::aHS[ PREVIEW_RECT_TOP ]    := ::PreviewRect[ 1 ]
      ::aHS[ PREVIEW_RECT_LEFT ]   := ::PreviewRect[ 2 ]
      ::aHS[ PREVIEW_RECT_BOTTOM ] := ::PreviewRect[ 3 ]
      ::aHS[ PREVIEW_RECT_RIGHT ]  := ::PreviewRect[ 4 ]
   ELSE
      RR_GetDesktopArea( ::aHS[ PREVIEW_RECT ] )
      ::aHS[ PREVIEW_RECT_TOP ] += 10
      ::aHS[ PREVIEW_RECT_LEFT ] += 10
      ::aHS[ PREVIEW_RECT_BOTTOM ] -= 10
      ::aHS[ PREVIEW_RECT_RIGHT ] -= 10
   ENDIF
   ::aHS[ PREVIEW_RECT_HEIGHT ] := ::aHS[ PREVIEW_RECT_BOTTOM ] - ::aHS[ PREVIEW_RECT_TOP ] + 1
   ::aHS[ PREVIEW_RECT_WIDTH ] := ::aHS[ PREVIEW_RECT_RIGHT ] - ::aHS[ PREVIEW_RECT_LEFT ] + 1

   IF lSize
      IF lWait
         DEFINE WINDOW 0 OBJ ::oWinPreview ;
            AT ::aHS[ PREVIEW_RECT_TOP ], ::aHS[ PREVIEW_RECT_LEFT ] ;
            WIDTH ::aHS[ PREVIEW_RECT_WIDTH ] ;
            HEIGHT ::aHS[ PREVIEW_RECT_HEIGHT ] ;
            TITLE ::aOpisy[ 1 ] ;
            ICON 'ZZZ_PRINTICON' ;
            MODAL
      ELSE
         DEFINE WINDOW 0 OBJ ::oWinPreview ;
            PARENT ( cParent ) ;
            AT ::aHS[ PREVIEW_RECT_TOP ], ::aHS[ PREVIEW_RECT_LEFT ] ;
            WIDTH ::aHS[ PREVIEW_RECT_WIDTH ] ;
            HEIGHT ::aHS[ PREVIEW_RECT_HEIGHT ] ;
            TITLE ::aOpisy[ 1 ] ;
            ICON 'ZZZ_PRINTICON' ;
            ON RELEASE ::CleanOnPrevClose()
      ENDIF
   ELSE
      IF lWait
         DEFINE WINDOW 0 OBJ ::oWinPreview ;
            AT ::aHS[ PREVIEW_RECT_TOP ], ::aHS[ PREVIEW_RECT_LEFT ] ;
            WIDTH ::aHS[ PREVIEW_RECT_WIDTH ] ;
            HEIGHT ::aHS[ PREVIEW_RECT_HEIGHT ] ;
            TITLE ::aOpisy[ 1 ] ;
            ICON 'ZZZ_PRINTICON' ;
            MODAL ;
            NOSIZE
      ELSE
         DEFINE WINDOW 0 OBJ ::oWinPreview ;
            PARENT ( cParent ) ;
            AT ::aHS[ PREVIEW_RECT_TOP ], ::aHS[ PREVIEW_RECT_LEFT ] ;
            WIDTH ::aHS[ PREVIEW_RECT_WIDTH ] ;
            HEIGHT ::aHS[ PREVIEW_RECT_HEIGHT ] ;
            TITLE ::aOpisy[ 1 ] ;
            ICON 'ZZZ_PRINTICON' ;
            NOSIZE ;
            ON RELEASE ::CleanOnPrevClose()
      ENDIF
   ENDIF

/*
   DEFINE WINDOW 0 OBJ ::oWinPreview ;
*/
      ON KEY ESCAPE      OF ( ::oWinPreview ) ACTION ::PrevClose( .T. )
      ON KEY ADD         OF ( ::oWinPreview ) ACTION ( ::Scale *= 1.25, ::PrevShow() )
      ON KEY SUBTRACT    OF ( ::oWinPreview ) ACTION ( ::Scale /= 1.25, ::PrevShow() )
      ON KEY CONTROL + P OF ( ::oWinPreview ) ACTION ( ::PrevPrint(), iif( ::ClsPreview, ::PrevClose( .F. ), NIL ) )
      ON KEY PRIOR       OF ( ::oWinPreview ) ACTION ( ::Page := iif( ::Page == 1, 1, ::Page - 1 ), ::oWinPreview:combo_1:value := ::Page )
      ON KEY NEXT        OF ( ::oWinPreview ) ACTION ( ::Page := iif( ::Page == ::IloscStron, ::Page, ::Page + 1 ), ::oWinPreview:combo_1:value := ::Page )

      DEFINE STATUSBAR
         STATUSITEM ::aOpisy[ 15 ] + " " + AllTrim( Str( ::Page ) ) WIDTH 100
         STATUSITEM ::aOpisy[ 16 ] WIDTH 200 ICON 'ZZZ_PRINTICON' ACTION ::PrevPrint( ::Page ) RAISED
         STATUSITEM ::aOpisy[ 17 ] + " " + AllTrim( Str( ::IloscStron ) ) WIDTH 100
      END STATUSBAR

      DEFINE SPLITBOX OBJ oSplit
         DEFINE TOOLBAR TB1 BUTTONSIZE iif( hb_osisWin10(), 56, 50 ), 37 SIZE 8 FLAT BREAK
            BUTTON B1 CAPTION ::aOpisy[ 02 ] PICTURE 'hbprint_close' ACTION ::PrevClose( .T. )
            BUTTON B2 CAPTION ::aOpisy[ 03 ] PICTURE 'hbprint_print' ACTION ( ::PrevPrint(), iif( ::ClsPreview, ::PrevClose( .F. ), NIL ) )
            IF ! ::NoButtonSave
               BUTTON B3 CAPTION ::aOpisy[ 04 ] PICTURE 'hbprint_save' WHOLEDROPDOWN SEPARATOR
               DEFINE DROPDOWN MENU BUTTON B3
                  ITEM ::aOpisy[ 04 ] ACTION ::SaveMetaFiles( ::Page )
                  ITEM ::aOpisy[ 33 ] ACTION { |fn| fn := PutFile( { { ::aOpisy[ 35 ], '*.emf' }, { ::aOpisy[ 36 ], '*.*' } }, NIL, GetStartUpFolder(), .T., ::DocName ), iif( Empty( fn ), NIL, ::SaveMetaFiles( ::Page, fn ) ) }
                  ITEM ::aOpisy[ 34 ] ACTION ::SaveMetaFiles()
              END MENU
            ENDIF
            IF ::IloscStron > 1
               BUTTON B4 CAPTION ::aOpisy[ 05 ] PICTURE 'hbprint_top' ACTION {|| ::Page := 1, ::oWinPreview:combo_1:value := ::Page }
               BUTTON B5 CAPTION ::aOpisy[ 06 ] PICTURE 'hbprint_back' ACTION {|| ::Page := iif( ::Page == 1, 1, ::Page - 1 ), ::oWinPreview:combo_1:value := ::Page }
               BUTTON B6 CAPTION ::aOpisy[ 07 ] PICTURE 'hbprint_next' ACTION {|| ::Page := iif( ::Page == ::IloscStron, ::Page, ::Page + 1 ), ::oWinPreview:combo_1:value := ::Page }
               BUTTON B7 CAPTION ::aOpisy[ 08 ] PICTURE 'hbprint_end' ACTION {|| ::Page := ::IloscStron, ::oWinPreview:combo_1:value := ::Page } SEPARATOR
            ENDIF
            BUTTON B8 CAPTION ::aOpisy[ 09 ] PICTURE 'hbprint_zoomin' ACTION {|| ::Scale *= 1.25, ::PrevShow() }
            IF ! ::NoButtonOptions
               BUTTON B9 CAPTION ::aOpisy[ 10 ] PICTURE 'hbprint_zoomout' ACTION {|| ::Scale /= 1.25, ::PrevShow() } SEPARATOR
               BUTTON B10 CAPTION ::aOpisy[ 11 ] PICTURE 'hbprint_option' ACTION {|| ::PrintOption() }
            ELSE
               BUTTON B9 CAPTION ::aOpisy[ 10 ] PICTURE 'hbprint_zoomout' ACTION {|| ::Scale /= 1.25, ::PrevShow() }
            ENDIF
         END TOOLBAR NOBREAK

         FOR i := 1 TO ::IloscStron
            AAdd( ::nPages, LTrim( Str( i ) ) )
         NEXT i

         COMBOBOX combo_1 OBJ oPages ;
            WIDTH 60 ITEMS ::nPages VALUE 1 GRIPPERTEXT ::aOpisy[ 12 ] DISPLAYEDIT ;
            ON ENTER {|n| n := oPages:ItemValue( oPages:DisplayValue ), iif( n >= 1 .AND. n <= ::IloscStron, oPages:Value := n, oPages:DisplayValue := "" ) } ;
            ON CHANGE {|| ::Page := oPages:Value, ::PrevShow(), ::oWinPagePreview:SetFocus() }
         oPages:AutoSize := .T.
         oPages:AutoSize := .F.
         oPages:lFixWidth := .T.
         oSplit:BandGripperOFF( 2 )

         DEFINE WINDOW 0 SPLITCHILD NOSYSMENU NOCAPTION WIDTH 10 HEIGHT 10
         END WINDOW
         oSplit:BandGripperOFF( 3 )

         FORCEBREAK

         AAdd( ::aHS, { 0, 0, 0, 0, 0, 0, ::oWinPreview:hWnd } )
         RR_GetClientRect( ::aHS[ PREVIEW_FORM ] )

         AAdd( ::aHS, { 0, 0, 0, 0, 0, 0, ::oWinPreview:TB1:hWnd } )
         RR_GetClientRect( ::aHS[ PREVIEW_TB ] )

         AAdd( ::aHS, { 0, 0, 0, 0, 0, 0, ::oWinPreview:StatusBar:hWnd } )
         RR_GetClientRect( ::aHS[ PREVIEW_SB ] )

         DEFINE WINDOW 0 OBJ ::oWinPagePreview ;
            WIDTH ::aHS[ PREVIEW_FORM_WIDTH ] - 15 ;
            HEIGHT ::aHS[ PREVIEW_FORM_HEIGHT ] - ::aHS[ PREVIEW_TB_HEIGHT ] - ::aHS[ PREVIEW_SB_HEIGHT ] - 10 ;
            VIRTUAL WIDTH ::aHS[ PREVIEW_FORM_WIDTH ] - 5 ;
            VIRTUAL HEIGHT ::aHS[ PREVIEW_FORM_HEIGHT ] - ::aHS[ PREVIEW_TB_HEIGHT ] - ::aHS[ PREVIEW_SB_HEIGHT ] ;
            TITLE ::aOpisy[ 13 ] ;
            SPLITCHILD ;
            GRIPPERTEXT "P" ;
            NOSYSMENU ;
            ON MOUSECLICK ::oWinPagePreview:setfocus()

            ::oWinPagePreview:VScrollbar:nLineSkip := 20
            ::oWinPagePreview:HScrollbar:nLineSkip := 20

            AAdd( ::aHS, { 0, 0, 0, 0, 0, 0, ::oWinPagePreview:hWnd } )
            RR_GetClientRect( ::aHS[ PREVIEW_PAGE ] )

            @ ::aHS[ PREVIEW_PAGE_TOP ] + 10, ::aHS[ PREVIEW_PAGE_LEFT ] + 10 IMAGE i1 ;
               PICTURE "" ;
               WIDTH ::aHS[ PREVIEW_PAGE_WIDTH ] - 10 ;
               HEIGHT ::aHS[ PREVIEW_PAGE_HEIGHT ] - 10

            AAdd( ::aHS, { 0, 0, 0, 0, 0, 0, ::oWinPagePreview:i1:hWnd } )
            RR_GetClientRect( ::aHS[ PREVIEW_IMAGE ] )

            ON KEY ESCAPE      ACTION ::PrevClose( .T. )
            ON KEY ADD         ACTION ( ::Scale *= 1.25, ::PrevShow() )
            ON KEY SUBTRACT    ACTION ( ::Scale /= 1.25, ::PrevShow() )
            ON KEY CONTROL + P ACTION ( ::PrevPrint(), iif( ::ClsPreview, ::PrevClose( .F. ), NIL ) )
            IF ::IloscStron > 1
               ON KEY PRIOR    ACTION ( ::Page := iif( ::Page == 1, 1, ::Page - 1 ), ::oWinPreview:combo_1:value := ::Page )
               ON KEY NEXT     ACTION ( ::Page := iif( ::Page == ::IloscStron, ::Page, ::Page + 1 ), ::oWinPreview:combo_1:value := ::Page )
               ON KEY END      ACTION ( ::Page := ::IloscStron, ::oWinPreview:combo_1:value := ::Page )
               ON KEY HOME     ACTION ( ::Page := 1, ::oWinPreview:combo_1:value := ::Page )
               ON KEY LEFT     ACTION ( ::Page := iif( ::Page == 1, 1, ::Page - 1 ), ::oWinPreview:combo_1:value := ::Page )
               ON KEY UP       ACTION ( ::Page := iif( ::Page == 1, 1, ::Page - 1 ), ::oWinPreview:combo_1:value := ::Page )
               ON KEY RIGHT    ACTION ( ::Page := iif( ::Page == ::IloscStron, ::Page, ::Page + 1 ), ::oWinPreview:combo_1:value := ::Page )
               ON KEY DOWN     ACTION ( ::Page := iif( ::Page == ::IloscStron, ::Page, ::Page + 1 ), ::oWinPreview:combo_1:value := ::Page )
            ENDIF
         END WINDOW

         IF ::Thumbnails .AND. ::IloscStron > 1
            DEFINE WINDOW 0 OBJ ::oWinThumbs ;
               WIDTH ::aHS[ PREVIEW_FORM_WIDTH ] - 15 ;
               HEIGHT ::aHS[ PREVIEW_FORM_HEIGHT ] - ::aHS[ PREVIEW_TB_HEIGHT ] - ::aHS[ PREVIEW_SB_HEIGHT ] - 10 ;
               TITLE ::aOpisy[ 14 ] ;
               SPLITCHILD ;
               GRIPPERTEXT "T"

               AAdd( ::aHS, { 0, 0, 0, 0, 0, 0, ::oWinThumbs:hWnd } )
               RR_GetClientRect( ::aHS[ PREVIEW_THUMBS ] )

               ::dx := ( ::oWinPagePreview:ClientWidth - 10 ) / 5
               ::dy := ( ::oWinPagePreview:ClientHeight - 10 ) / 3
               FOR i := 1 TO 15
                  AAdd( ::aTH, { 0, 0, 0, 0, 0 } )
                  IF ::MetaFiles[ 1, PG_VERT_SIZE ] >= ::MetaFiles[ 1, PG_HORZ_SIZE ]
                     ::aTH[ i, TH_HEIGHT ] := ::dy - 10
                     ::aTH[ i, TH_WIDTH ] := ::aTH[ i, TH_HEIGHT ] * ::MetaFiles[ 1, PG_HORZ_SIZE ] / ::MetaFiles[ 1, PG_VERT_SIZE ]
                  ELSE
                     ::aTH[ i, TH_WIDTH ] := ::dx - 10
                     ::aTH[ i, TH_HEIGHT ] := ::aTH[ i, TH_WIDTH ] * ::MetaFiles[ 1, PG_VERT_SIZE ] / ::MetaFiles[ 1, PG_HORZ_SIZE ]
                  ENDIF
                  ::aTH[ i, TH_ROW ] := 10 + Int( ( i - 1 ) / 5 ) * ::dy
                  ::aTH[ i, TH_COL ] := 10 + ( ( i - 1 ) % 5 ) * ::dx
               NEXT

               @ ::aTH[  1, TH_ROW ], ::aTH[  1, TH_COL ] IMAGE it1  ACTION {|| ::PrevThumb(  1 ) } WIDTH ::aTH[  1, TH_WIDTH ] HEIGHT ::aTH[  1, TH_HEIGHT ]
               @ ::aTH[  2, TH_ROW ], ::aTH[  2, TH_COL ] IMAGE it2  ACTION {|| ::PrevThumb(  2 ) } WIDTH ::aTH[  2, TH_WIDTH ] HEIGHT ::aTH[  2, TH_HEIGHT ]
               @ ::aTH[  3, TH_ROW ], ::aTH[  3, TH_COL ] IMAGE it3  ACTION {|| ::PrevThumb(  3 ) } WIDTH ::aTH[  3, TH_WIDTH ] HEIGHT ::aTH[  3, TH_HEIGHT ]
               @ ::aTH[  4, TH_ROW ], ::aTH[  4, TH_COL ] IMAGE it4  ACTION {|| ::PrevThumb(  4 ) } WIDTH ::aTH[  4, TH_WIDTH ] HEIGHT ::aTH[  4, TH_HEIGHT ]
               @ ::aTH[  5, TH_ROW ], ::aTH[  5, TH_COL ] IMAGE it5  ACTION {|| ::PrevThumb(  5 ) } WIDTH ::aTH[  5, TH_WIDTH ] HEIGHT ::aTH[  5, TH_HEIGHT ]
               @ ::aTH[  6, TH_ROW ], ::aTH[  6, TH_COL ] IMAGE it6  ACTION {|| ::PrevThumb(  6 ) } WIDTH ::aTH[  6, TH_WIDTH ] HEIGHT ::aTH[  6, TH_HEIGHT ]
               @ ::aTH[  7, TH_ROW ], ::aTH[  7, TH_COL ] IMAGE it7  ACTION {|| ::PrevThumb(  7 ) } WIDTH ::aTH[  7, TH_WIDTH ] HEIGHT ::aTH[  7, TH_HEIGHT ]
               @ ::aTH[  8, TH_ROW ], ::aTH[  8, TH_COL ] IMAGE it8  ACTION {|| ::PrevThumb(  8 ) } WIDTH ::aTH[  8, TH_WIDTH ] HEIGHT ::aTH[  8, TH_HEIGHT ]
               @ ::aTH[  9, TH_ROW ], ::aTH[  9, TH_COL ] IMAGE it9  ACTION {|| ::PrevThumb(  9 ) } WIDTH ::aTH[  9, TH_WIDTH ] HEIGHT ::aTH[  9, TH_HEIGHT ]
               @ ::aTH[ 10, TH_ROW ], ::aTH[ 10, TH_COL ] IMAGE it10 ACTION {|| ::PrevThumb( 10 ) } WIDTH ::aTH[ 10, TH_WIDTH ] HEIGHT ::aTH[ 10, TH_HEIGHT ]
               @ ::aTH[ 11, TH_ROW ], ::aTH[ 11, TH_COL ] IMAGE it11 ACTION {|| ::PrevThumb( 11 ) } WIDTH ::aTH[ 11, TH_WIDTH ] HEIGHT ::aTH[ 11, TH_HEIGHT ]
               @ ::aTH[ 12, TH_ROW ], ::aTH[ 12, TH_COL ] IMAGE it12 ACTION {|| ::PrevThumb( 12 ) } WIDTH ::aTH[ 12, TH_WIDTH ] HEIGHT ::aTH[ 12, TH_HEIGHT ]
               @ ::aTH[ 13, TH_ROW ], ::aTH[ 13, TH_COL ] IMAGE it13 ACTION {|| ::PrevThumb( 13 ) } WIDTH ::aTH[ 13, TH_WIDTH ] HEIGHT ::aTH[ 13, TH_HEIGHT ]
               @ ::aTH[ 14, TH_ROW ], ::aTH[ 14, TH_COL ] IMAGE it14 ACTION {|| ::PrevThumb( 14 ) } WIDTH ::aTH[ 14, TH_WIDTH ] HEIGHT ::aTH[ 14, TH_HEIGHT ]
               @ ::aTH[ 15, TH_ROW ], ::aTH[ 15, TH_COL ] IMAGE it15 ACTION {|| ::PrevThumb( 15 ) } WIDTH ::aTH[ 15, TH_WIDTH ] HEIGHT ::aTH[ 15, TH_HEIGHT ]

               cName := ::oWinThumbs:Name
               FOR i := 1 TO Min( ::IloscStron, 15 )
                  oImg := GetControlObject( "it" + AllTrim( Str( i ) ), cName )
                  ::aTH[ i, TH_HWND ] := oImg:hWnd
                  oImg:HBitMap := RR_PlayThumb( ::aTH[ i ], ::MetaFiles[ i ], LTrim( Str( i ) ), ::InMemory )
               NEXT
            END WINDOW
         ENDIF
      END SPLITBOX
   END WINDOW

   ::PrevShow()
   ::oWinPagePreview:i1:SetFocus()
   ::oWinPreview:Activate( ! lWait )

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD PrevClose( lEsc ) CLASS HBPrinter

   ::lEscaped := lEsc
   ::oWinPreview:Release()

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD CleanOnPrevClose() CLASS HBPrinter

   ::oWinPagePreview:Release()
   IF ::IloscStron > 1 .AND. ::Thumbnails
      ::oWinThumbs:Release()
   ENDIF
   ::oWinPagePreview := NIL
   ::oWinThumbs := NIL
   ::oWinPreview := NIL

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD PrintOption() CLASS HBPrinter

   LOCAL nLen := Len( LTrim( Str( ::IloscStron ) ) ), oFrom, oTo, oCopies, oWinPrOpt

   DEFINE WINDOW 0 OBJ oWinPrOpt ;
      AT 270, 346 ;
      WIDTH 390 HEIGHT 150 ;
      CLIENTAREA ;
      TITLE ::aOpisy[ 19 ] ;
      ICON 'ZZZ_PRINTICON' ;
      MODAL NOSIZE NOSYSMENU SIZE 9

      @ 002, 005 FRAME PrOptFrame WIDTH 380 HEIGHT 133

      @ 020, 010 LABEL label_11 WIDTH 120 HEIGHT 21 VALUE ::aOpisy[ 20 ] BOLD VCENTERALIGN
      @ 020, 135 TEXTBOX textFrom OBJ oFrom WIDTH 33 HEIGHT 21 NUMERIC MAXLENGTH nLen RIGHTALIGN ;
         VALUE Max( ::nFromPage, 1 ) VALID oFrom:Value > 0 .AND. oFrom:Value <= oTo:Value
      @ 020, 173 LABEL label_12 WIDTH 40 HEIGHT 21 VALUE ::aOpisy[ 21 ] BOLD CENTERALIGN VCENTERALIGN
      @ 020, 218 TEXTBOX textTo OBJ oTo WIDTH 33 HEIGHT 21 NUMERIC MAXLENGTH nLen RIGHTALIGN ;
         VALUE ::nToPage VALID oTo:Value >= oFrom:Value .AND. oTo:Value <= ::nToPage

      @ 020, 260 LABEL label_18 WIDTH 80 HEIGHT 21 VALUE ::aOpisy[ 22 ] BOLD VCENTERALIGN
      @ 020, 350 TEXTBOX textCopies OBJ oCopies WIDTH 30 HEIGHT 21 NUMERIC MAXLENGTH 6 RIGHTALIGN ;
         VALUE ::nCopies VALID oCopies:Value > 0
      @ 060, 010 LABEL label_13 WIDTH 100 HEIGHT 21 VALUE ::aOpisy[ 23 ] BOLD VCENTERALIGN
      @ 060, 115 COMBOBOX prnCombo WIDTH 265 VALUE ::PrintOpt ITEMS { ::aOpisy[ 24 ], ::aOpisy[ 25 ], ::aOpisy[ 26 ], ::aOpisy[ 27 ], ::aOpisy[ 28 ] }

      @ 100, 160 BUTTON button_14 WIDTH 95 HEIGHT 24 CAPTION ::aOpisy[ 52 ] ;
         ACTION {|| ::nFromPage := oWinPrOpt:textFrom:Value, ;
         ::nToPage := oWinPrOpt:textTo:Value, ;
         ::nCopies := Max( oWinPrOpt:textCopies:Value, 1 ), ;
         ::PrintOpt := oWinPrOpt:prnCombo:Value, ;
         oWinPrOpt:Release() }

      @ 100, 285 BUTTON button_15 CAPTION ::aOpisy[ 02 ] ;
         ACTION oWinPrOpt:Release() ;
         WIDTH 95 HEIGHT 24

      ON KEY ESCAPE ACTION oWinPrOpt:Release()
   END WINDOW

   oWinPrOpt:Activate( .F. )

   RETURN .T.
#endif /* NO_GUI */

/*--------------------------------------------------------------------------------------------------------------------------------*/
#pragma BEGINDUMP

#include "oohg.h"
#include <olectl.h>
#include <ocidl.h>
#include <winuser.h>
#include <wingdi.h>
#include "hbvm.h"
#include "hbapiitm.h"

// For devcaps
#define DI_VERT_SIZE          1
#define DI_HORZ_SIZE          2
#define DI_VERT_RES           3
#define DI_HORZ_RES           4
#define DI_VERT_LOGPIX        5
#define DI_HORZ_LOGPIX        6
#define DI_VERT_PHYSIZE       7
#define DI_HORZ_PHYSIZE       8
#define DI_VERT_PHYOFFS       9
#define DI_HORZ_PHYOFFS       10
#define DI_VERT_FONTSIZE      11
#define DI_HORZ_FONTSIZE      12
#define DI_ROWS               13
#define DI_COLS               14
#define DI_ORIENTATION        15
#define DI_TMASCENT           16
#define DI_PAPERSIZE          17

typedef struct _HBPRINTERDATA
{
   HDC              hDC;
   HDC              hDCRef;
   HDC              hDCtemp;
   HANDLE           hPrinter;
   PRINTER_DEFAULTS pd;
   PRINTDLG         pdlg;
   DOCINFO          di;
   int              nFromPage;
   int              nToPage;
   DWORD            charset;
   HFONT            hfont;
   HPEN             hpen;
   HBRUSH           hbrush;
   int              textjust;
   int              polyfillmode;
   HRGN             hrgn;
   DEVMODE *        pDevMode;
   DEVMODE *        pDevMode2;
   DEVNAMES *       pDevNames;
   PRINTER_INFO_2 * pi2;
   PRINTER_INFO_2 * pi22;
   char             PrinterName[ 128 ];
   char             PrinterDefault[ 128 ];
   int              devcaps[ 18 ];
   OSVERSIONINFO    osvi;
} HBPRINTERDATA, * LPHBPRINTERDATA;

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_CREATEHBPRINTERDATA )          /* FUNCTION RR_CreateHBPrinterData() -> hData */
{
   LPHBPRINTERDATA lpData = (HBPRINTERDATA *) hb_xgrab( ( sizeof( HBPRINTERDATA ) ) );

   memset( lpData, 0, sizeof( HBPRINTERDATA ) );

   lpData->charset = DEFAULT_CHARSET;
   lpData->devcaps[ DI_ORIENTATION ] = 1;
   lpData->polyfillmode = 1;
   lpData->osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
   GetVersionEx( &lpData->osvi );

   HANDLEret( lpData );
}

static far int nFontIndex = 0;
static far BOOL bGetName = FALSE;

/*--------------------------------------------------------------------------------------------------------------------------------*/
static int CALLBACK EnumFontsCallBack( LOGFONT FAR *lpLogFont, TEXTMETRIC FAR *lpTextMetric, int nFontType, LPARAM lParam )
{
   HB_SYMBOL_UNUSED( lpTextMetric );
   HB_SYMBOL_UNUSED( nFontType );
   HB_SYMBOL_UNUSED( lParam );

   ++nFontIndex;
   if( bGetName )
   {
      HB_STORC( lpLogFont->lfFaceName, -1, nFontIndex );
   }
   return 1;
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETFONTNAMES )          /* FUNCTION RR_GetFontNames() -> aNames */
{
   HDC hDC;
   FONTENUMPROC lpEnumFontsCallBack;

   WaitForSingleObject( _OOHG_GlobalMutex(), INFINITE );

   hDC = GetDC( NULL );
   lpEnumFontsCallBack = (FONTENUMPROC) MakeProcInstance( EnumFontsCallBack, GetModuleHandle( NULL ) );

   // Get the number of fonts
   nFontIndex = 0;
   bGetName = FALSE;
   EnumFonts( hDC, NULL, lpEnumFontsCallBack, (LPARAM) NULL );

   // Get the font names into an unsorted array
   hb_reta( nFontIndex );
   nFontIndex = 0;
   bGetName = TRUE;
   EnumFonts( hDC, NULL, lpEnumFontsCallBack, (LPARAM) NULL );

   ReleaseDC( NULL, hDC );

   ReleaseMutex( _OOHG_GlobalMutex() );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_FINISH )          /* FUNCTION RR_Finish( hData ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   ClosePrinter( lpData->hPrinter );
   hb_xfree( lpData );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_PRINTERNAME )          /* FUNCTION RR_PrintName( hData ) -> cName */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   hb_retc( lpData->PrinterName );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
static void RR_GetDevmode( HBPRINTERDATA *lpData )
{
   DWORD dwNeeded = 0;

   memset( &lpData->pd, 0, sizeof( lpData->pd ) );
   lpData->pd.DesiredAccess = PRINTER_ALL_ACCESS;
   OpenPrinter( lpData->PrinterName, &lpData->hPrinter, NULL );
   GetPrinter( lpData->hPrinter, 2, 0, 0, &dwNeeded );
   lpData->pi2 = (PRINTER_INFO_2 *) GlobalAlloc( GPTR, dwNeeded );
   GetPrinter( lpData->hPrinter, 2, (LPBYTE) lpData->pi2, dwNeeded, &dwNeeded );
   lpData->pi22 = (PRINTER_INFO_2 *) GlobalAlloc( GPTR, dwNeeded );
   GetPrinter( lpData->hPrinter, 2, (LPBYTE) lpData->pi22, dwNeeded, &dwNeeded );

   if( lpData->pDevMode )
   {
      lpData->pi2->pDevMode = lpData->pDevMode;
   }
   else
   {
      if( lpData->pi2->pDevMode == NULL )
      {
         dwNeeded = DocumentProperties( NULL, lpData->hPrinter, lpData->PrinterName, NULL, NULL, 0 );
         lpData->pDevMode2 = (DEVMODE *) GlobalAlloc( GPTR, dwNeeded );
         DocumentProperties( NULL, lpData->hPrinter, lpData->PrinterName, lpData->pDevMode2, NULL, DM_OUT_BUFFER );
         lpData->pi2->pDevMode = lpData->pDevMode2;
      }
   }
   lpData->hfont = (HFONT) GetCurrentObject( lpData->hDC, OBJ_FONT );
   lpData->hbrush = (HBRUSH) GetCurrentObject( lpData->hDC, OBJ_BRUSH );
   lpData->hpen = (HPEN) GetCurrentObject( lpData->hDC, OBJ_PEN );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_PRINTDIALOG )          /* FUNCTION RR_PrintDialog( { @nFromPage, @nToPage, @nCopies, @nWhatToPrint }, hData ) -> cName */
{
   LPCTSTR pDevice;
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   memset( &lpData->pdlg, 0, sizeof( lpData->pdlg ) );
   lpData->pdlg.lStructSize = sizeof( lpData->pdlg );
   lpData->pdlg.Flags = PD_RETURNDC | PD_ALLPAGES;
   lpData->pdlg.nFromPage = 1;
   lpData->pdlg.nToPage = -1;
   lpData->pdlg.nMinPage = 1;
   lpData->pdlg.nMaxPage = -1;
   lpData->pdlg.nCopies = 1;
   lpData->pdlg.hwndOwner = GetActiveWindow();

   if( PrintDlg( &lpData->pdlg ) )
   {
      lpData->hDC = lpData->pdlg.hDC;

      if( lpData->hDC == NULL )
      {
         strcpy( lpData->PrinterName, "" );
      }
      else
      {
         lpData->pDevMode = (LPDEVMODE) GlobalLock( lpData->pdlg.hDevMode );
         lpData->pDevNames = (LPDEVNAMES) GlobalLock( lpData->pdlg.hDevNames );
         /* Note: pDevMode->dmDeviceName is limited to 32 characters.
          * If the length of the printer's name is greater than 32,
          * e.g. network printers, the RR_GetDC() function returns a
          * null handle. So, I'm using pDevNames->wDeviceOffset instead
          * of pDevMode->dmDeviceName. (E.F.)
          */
         pDevice = (LPCTSTR) lpData->pDevNames + lpData->pDevNames->wDeviceOffset;
         strcpy( lpData->PrinterName, pDevice );

         HB_STORNL3( (long) lpData->pdlg.nFromPage, 1, 1 );
         HB_STORNL3( (long) lpData->pdlg.nToPage, 1, 2 );
         HB_STORNL3( (long) lpData->pDevMode->dmCopies > 1 ? lpData->pDevMode->dmCopies : lpData->pdlg.nCopies, 1, 3 );
         if( ( lpData->pdlg.Flags & PD_PAGENUMS ) == PD_PAGENUMS )
         {
            HB_STORNL3( 2, 1, 4 );
         }
         else
         {
            if( ( lpData->pdlg.Flags & PD_SELECTION ) == PD_SELECTION )
            {
               HB_STORNL3( 1, 1, 4 );
            }
            else
            {
               HB_STORNL3( 0, 1, 4 );
            }
         }
         RR_GetDevmode( lpData );

         GlobalUnlock( lpData->pdlg.hDevMode );
         GlobalUnlock( lpData->pdlg.hDevNames );
      }
   }
   else
   {
      lpData->hDC = NULL;
   }

   lpData->hDCRef = lpData->hDC;

   HDCret( lpData->hDC );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETDC )          /* FUNCTION RR_GetDC( cPrinterName, hData ) -> hDC */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   if( lpData->osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
   {
      lpData->hDC = CreateDC( "WINSPOOL", hb_parc( 1 ), NULL, NULL );
   }
   else
   {
      lpData->hDC = CreateDC( NULL, hb_parc( 1 ), NULL, NULL );
   }

   if( lpData->hDC )
   {
      strcpy( lpData->PrinterName, hb_parc( 1 ) );
      RR_GetDevmode( lpData );
   }

   lpData->hDCRef = lpData->hDC;

   HDCret( lpData->hDC );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_RESETPRINTER )          /* FUNCTION RR_ResetPrinter( hData ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   if( lpData->pi22 )
   {
      SetPrinter( lpData->hPrinter, 2, (LPBYTE) lpData->pi22, 0 );
      GlobalFree( lpData->pi22 );
      lpData->pi22 = NULL;
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_DELETEDC )          /* FUNCTION RR_DeleteDC( hData ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   if( lpData->pdlg.hDevMode )
      GlobalUnlock( lpData->pdlg.hDevMode );
   if( lpData->pdlg.hDevNames )
      GlobalUnlock( lpData->pdlg.hDevNames );
   if( lpData->pDevMode2 )
      GlobalFree( lpData->pDevMode2 );
   if( lpData->pi2 )
      GlobalFree( lpData->pi2 );

   DeleteObject( lpData->hfont );
   DeleteObject( lpData->hpen );
   DeleteObject( lpData->hbrush );
   DeleteObject( lpData->hrgn );
   DeleteDC( lpData->hDCRef );
   lpData->hDCRef = NULL;
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETDEVICECAPS )          /* FUNCTION RR_GetDeviceCaps( @aDeviceCaps, hFont, hData ) -> NIL */
{
   TEXTMETRIC tm;
   UINT i;
   HFONT xfont = HFONTparam( 2 );
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 3 );

   if( xfont )
   {
      SelectObject( lpData->hDCRef, xfont );
   }

   GetTextMetrics( lpData->hDCRef, &tm );

   lpData->devcaps[ DI_VERT_SIZE ]     = GetDeviceCaps( lpData->hDCRef, VERTSIZE );
   lpData->devcaps[ DI_HORZ_SIZE ]     = GetDeviceCaps( lpData->hDCRef, HORZSIZE );
   lpData->devcaps[ DI_VERT_RES ]      = GetDeviceCaps( lpData->hDCRef, VERTRES );
   lpData->devcaps[ DI_HORZ_RES ]      = GetDeviceCaps( lpData->hDCRef, HORZRES );
   lpData->devcaps[ DI_VERT_LOGPIX ]   = GetDeviceCaps( lpData->hDCRef, LOGPIXELSY );
   lpData->devcaps[ DI_HORZ_LOGPIX ]   = GetDeviceCaps( lpData->hDCRef, LOGPIXELSX );
   lpData->devcaps[ DI_VERT_PHYSIZE ]  = GetDeviceCaps( lpData->hDCRef, PHYSICALHEIGHT );
   lpData->devcaps[ DI_HORZ_PHYSIZE ]  = GetDeviceCaps( lpData->hDCRef, PHYSICALWIDTH );
   lpData->devcaps[ DI_VERT_PHYOFFS ]  = GetDeviceCaps( lpData->hDCRef, PHYSICALOFFSETY );
   lpData->devcaps[ DI_HORZ_PHYOFFS ]  = GetDeviceCaps( lpData->hDCRef, PHYSICALOFFSETX );
   lpData->devcaps[ DI_VERT_FONTSIZE ] = tm.tmHeight;
   lpData->devcaps[ DI_HORZ_FONTSIZE ] = tm.tmAveCharWidth;
   lpData->devcaps[ DI_ROWS ]          = (int) ( ( lpData->devcaps[ 3 ] - tm.tmAscent ) / tm.tmHeight );
   lpData->devcaps[ DI_COLS ]          = (int) ( lpData->devcaps[ 4 ] / tm.tmAveCharWidth );
   lpData->devcaps[ DI_ORIENTATION ]   = lpData->pi2->pDevMode->dmOrientation;
   lpData->devcaps[ DI_TMASCENT ]      = (int) tm.tmAscent;
   lpData->devcaps[ DI_PAPERSIZE ]     = (int) lpData->pi2->pDevMode->dmPaperSize;

   for( i = 1; i <= hb_parinfa( 1, 0 ); i ++ )
   {
      HB_STORNI( lpData->devcaps[ i ], 1, i );
   }

   if( xfont )
   {
      SelectObject( lpData->hDCRef, lpData->hfont );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SETDEVMODE )          /* FUNCTION RR_SetDevMode( nProperty, nValue, lGlobal, hData ) -> hDC */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 4 );
   DWORD what = hb_parnl( 1 );

   if( what == ( lpData->pi2->pDevMode->dmFields & what ) )
   {
      if( what == DM_ORIENTATION )
         lpData->pi2->pDevMode->dmOrientation = (SHORT) hb_parni( 2 );
      if( what == DM_PAPERSIZE )
         lpData->pi2->pDevMode->dmPaperSize = (SHORT) hb_parni( 2 );
      if( what == DM_SCALE )
         lpData->pi2->pDevMode->dmScale = (SHORT) hb_parni( 2 );
      if( what == DM_COPIES )
         lpData->pi2->pDevMode->dmCopies = (SHORT) hb_parni( 2 );
      if( what == DM_DEFAULTSOURCE )
         lpData->pi2->pDevMode->dmDefaultSource = (SHORT) hb_parni( 2 );
      if( what == DM_PRINTQUALITY )
         lpData->pi2->pDevMode->dmPrintQuality = (SHORT) hb_parni( 2 );
      if( what == DM_COLOR )
         lpData->pi2->pDevMode->dmColor = (SHORT) hb_parni( 2 );
      if( what == DM_DUPLEX )
         lpData->pi2->pDevMode->dmDuplex = (SHORT) hb_parni( 2 );
      if( what == DM_COLLATE )
         lpData->pi2->pDevMode->dmCollate = (SHORT) hb_parni( 2 );
      if( what == DM_PAPERLENGTH )
         lpData->pi2->pDevMode->dmPaperLength = (SHORT) hb_parni( 2 );
      if( what == DM_PAPERWIDTH )
         lpData->pi2->pDevMode->dmPaperWidth = (SHORT) hb_parni( 2 );

      DocumentProperties( NULL, lpData->hPrinter, lpData->PrinterName, lpData->pi2->pDevMode, lpData->pi2->pDevMode, DM_IN_BUFFER | DM_OUT_BUFFER );
      if( hb_parl( 3 ) )
      {
         SetPrinter( lpData->hPrinter, 2, (LPBYTE) lpData->pi2, 0 );
      }
      if( ResetDC( lpData->hDCRef, lpData->pi2->pDevMode ) )
      {
         HDCret( lpData->hDCRef );
      }
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SETUSERMODE )          /* FUNCTION RR_SetUserMode( nProperty, nValue, nValue2, hData ) -> hDC */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 4 );
   DWORD what = hb_parnl( 1 );

   if( what == ( lpData->pi2->pDevMode->dmFields & DMPAPER_USER ) )
   {
      lpData->pi2->pDevMode->dmFields      = lpData->pi2->pDevMode->dmFields | DM_PAPERSIZE | DM_PAPERWIDTH | DM_PAPERLENGTH;
      lpData->pi2->pDevMode->dmPaperSize   = DMPAPER_USER;
      lpData->pi2->pDevMode->dmPaperWidth  = (SHORT) hb_parnl( 2 );
      lpData->pi2->pDevMode->dmPaperLength = (SHORT) hb_parnl( 3 );

      DocumentProperties( NULL, lpData->hPrinter, lpData->PrinterName, lpData->pi2->pDevMode, lpData->pi2->pDevMode, DM_IN_BUFFER | DM_OUT_BUFFER );
      SetPrinter( lpData->hPrinter, 2, (LPBYTE) lpData->pi2, 0 );
      if( ResetDC( lpData->hDCRef, lpData->pi2->pDevMode ) )
      {
         HDCret( lpData->hDCRef );
      }
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETDEFAULTPRINTER )          /* FUNCTION RR_GetDefaultPrinter( hData ) -> cName */
{
   DWORD Needed, Returned;
   DWORD BuffSize = 256;
   LPPRINTER_INFO_5 PrinterInfo;
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   if( lpData->osvi.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS )
   {
      EnumPrinters( PRINTER_ENUM_DEFAULT, NULL, 5, NULL, 0, &Needed, &Returned );
      PrinterInfo = (LPPRINTER_INFO_5) LocalAlloc( LPTR, Needed );
      EnumPrinters( PRINTER_ENUM_DEFAULT, NULL, 5, (LPBYTE) PrinterInfo, Needed, &Needed, &Returned );
      strcpy( lpData->PrinterDefault, PrinterInfo->pPrinterName );
      LocalFree( PrinterInfo );
   }
   else if( lpData->osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
   {
      if( lpData->osvi.dwMajorVersion >= 5 ) /* Windows 2000 or later */
      {
         GetProfileString( "windows", "device", "", lpData->PrinterDefault, BuffSize );
         strtok( lpData->PrinterDefault, "," );
      }
      else /* Windows NT 4.0 or earlier */
      {
         GetProfileString( "windows", "device", "", lpData->PrinterDefault, BuffSize);
         strtok( lpData->PrinterDefault, "," );
      }
   }
   else
   {
      strcpy( lpData->PrinterDefault, "" );
   }
   hb_retc( lpData->PrinterDefault );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETPRINTERS )          /* FUNCTION RR_GetPrinters( hData ) -> cPrintersData */
{
   DWORD dwSize = 0;
   DWORD dwPrinters = 0;
   DWORD i;
   char * pBuffer;
   char * cBuffer;
   PRINTER_INFO_4 * pInfo4;
   PRINTER_INFO_5 * pInfo5;
   DWORD level;
   DWORD flags;
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   if( lpData->osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
   {
      level = 4;
      flags = PRINTER_ENUM_CONNECTIONS | PRINTER_ENUM_LOCAL;
   }
   else
   {
      level = 5;
      flags = PRINTER_ENUM_LOCAL;
   }

   EnumPrinters( flags, NULL, level, NULL, 0, &dwSize, &dwPrinters );

   pBuffer = (char *) GlobalAlloc( GPTR, dwSize );
   if( pBuffer == NULL )
   {
      hb_retc( ",," );
      return;
   }
   EnumPrinters( flags, NULL, level, (BYTE *) pBuffer, dwSize, &dwSize, &dwPrinters );

   if( dwPrinters == 0 )
   {
      hb_retc( ",," );
      return;
   }
   cBuffer = (char *) GlobalAlloc( GPTR, dwPrinters * 256 );

   if( lpData->osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
   {
      pInfo4 = (PRINTER_INFO_4 *) pBuffer;

      for( i = 0; i < dwPrinters; i++ )
      {
         strcat( cBuffer, pInfo4->pPrinterName );
         strcat( cBuffer, "," );
         if( pInfo4->Attributes == PRINTER_ATTRIBUTE_LOCAL )
         {
            strcat( cBuffer, "local printer" );
         }
         else
         {
            strcat( cBuffer, "network printer" );
         }

         pInfo4++;

         if( i < dwPrinters - 1 )
         {
            strcat( cBuffer, ",," );
         }
      }
   }
   else
   {
      pInfo5 = (PRINTER_INFO_5 *) pBuffer;

      for( i = 0; i < dwPrinters; i++ )
      {
         strcat( cBuffer, pInfo5->pPrinterName );
         strcat( cBuffer, "," );
         strcat( cBuffer, pInfo5->pPortName );

         pInfo5++;

         if( i < dwPrinters - 1 )
         {
            strcat( cBuffer, ",," );
         }
      }
   }

   hb_retc( cBuffer );
   GlobalFree( pBuffer );
   GlobalFree( cBuffer );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_STARTDOC )          /* FUNCTION RR_StartDoc( cDocName, hData ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   memset( &lpData->di, 0, sizeof( lpData->di ) );
   lpData->di.cbSize = sizeof( lpData->di );
   lpData->di.lpszDocName = hb_parc( 1 );
   StartDoc( lpData->hDC, &lpData->di );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_STARTPAGE )          /* FUNCTION RR_StartPage( hData ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   StartPage( lpData->hDC );
   SetTextAlign( lpData->hDC, TA_BASELINE );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_ENDPAGE )          /* FUNCTION RR_EndPage( hData ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   EndPage( lpData->hDC );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_ENDDOC )          /* FUNCTION RR_EndDoc( hData ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   EndDoc( lpData->hDC );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_ABORTDOC )          /* FUNCTION RR_AbortDoc( hData ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   AbortDoc( lpData->hDC );
   DeleteDC( lpData->hDC );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_DEVICECAPABILITIES )          /* FUNCTION RR_DeviceCapabilities( @cPaperNames, @cBinNames, hData ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 3 );
   HGLOBAL cBuf, pBuf, nBuf, sBuf, bnBuf, bwBuf, bcBuf;
   char * cBuffer, * pBuffer, * nBuffer, * sBuffer, * bnBuffer, * bwBuffer, * bcBuffer;
   DWORD numpapers, numbins, i;
   LPPOINT lp;
   char buffer[ sizeof(long) * 8 + 1 ];

   numbins = DeviceCapabilities( lpData->pi2->pPrinterName, lpData->pi2->pPortName, DC_BINNAMES, NULL, NULL );
   numpapers = DeviceCapabilities( lpData->pi2->pPrinterName, lpData->pi2->pPortName, DC_PAPERNAMES, NULL, NULL );
   if( numpapers != (DWORD) 0 && numpapers != (DWORD) ( ~ 0 ) )
   {
      pBuf = GlobalAlloc( GPTR, numpapers * 64 );
      nBuf = GlobalAlloc( GPTR, numpapers * sizeof( WORD ) );
      sBuf = GlobalAlloc( GPTR, numpapers * sizeof( POINT ) );
      cBuf = GlobalAlloc( GPTR, numpapers * 128 );
      pBuffer = (char *) pBuf;
      nBuffer = (char *) nBuf;
      sBuffer = (char *) sBuf;
      cBuffer = (char *) cBuf;
      DeviceCapabilities( lpData->pi2->pPrinterName, lpData->pi2->pPortName, DC_PAPERNAMES, pBuffer, lpData->pi2->pDevMode );
      DeviceCapabilities( lpData->pi2->pPrinterName, lpData->pi2->pPortName, DC_PAPERS, nBuffer, lpData->pi2->pDevMode );
      DeviceCapabilities( lpData->pi2->pPrinterName, lpData->pi2->pPortName, DC_PAPERSIZE, sBuffer, lpData->pi2->pDevMode );
      cBuffer[ 0 ] = 0;
      for( i = 0; i < numpapers; i++ )
      {
         strcat( cBuffer, pBuffer );
         strcat( cBuffer, "," );
         strcat( cBuffer, _OOHG_ITOA( * nBuffer, buffer, 10 ) );
         strcat( cBuffer, "," );

         lp = (LPPOINT) sBuffer;
         strcat( cBuffer, _OOHG_LTOA( lp->x, buffer, 10 ) );
         strcat( cBuffer, "," );
         strcat( cBuffer, _OOHG_LTOA( lp->y, buffer, 10 ) );
         if( i < numpapers - 1 )
         {
            strcat( cBuffer, ",," );
         }
         pBuffer += 64;
         nBuffer += sizeof( WORD );
         sBuffer += sizeof( POINT );
      }

      hb_storc( cBuffer, 1 );

      GlobalFree( cBuf );
      GlobalFree( pBuf );
      GlobalFree( nBuf );
      GlobalFree( sBuf );
   }
   else
   {
      hb_storc( "", 1 );
   }

   if( numbins != (DWORD) 0 && numbins != (DWORD) ( ~ 0 ) )
   {
      bnBuf = GlobalAlloc( GPTR, numbins * 24 );
      bwBuf = GlobalAlloc( GPTR, numbins * sizeof( WORD ) );
      bcBuf = GlobalAlloc( GPTR, numbins * 64 );
      bnBuffer = (char *) bnBuf;
      bwBuffer = (char *) bwBuf;
      bcBuffer = (char *) bcBuf;
      DeviceCapabilities( lpData->pi2->pPrinterName, lpData->pi2->pPortName, DC_BINNAMES, bnBuffer, lpData->pi2->pDevMode );
      DeviceCapabilities( lpData->pi2->pPrinterName, lpData->pi2->pPortName, DC_BINS, bwBuffer, lpData->pi2->pDevMode );
      bcBuffer[ 0 ] = 0;
      for( i = 0; i < numbins; i++ )
      {
         strcat( bcBuffer, bnBuffer );
         strcat( bcBuffer, "," );
         strcat( bcBuffer, _OOHG_ITOA( * bwBuffer, buffer, 10 ) );

         if( i < numbins - 1 )
         {
            strcat( bcBuffer, ",," );
         }
         bnBuffer += 24;
         bwBuffer += sizeof( WORD );
      }

      hb_storc( bcBuffer, 2 );

      GlobalFree( bnBuf );
      GlobalFree( bwBuf );
      GlobalFree( bcBuf );
   }
   else
   {
      hb_storc( "", 2 );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SETPOLYFILLMODE )          /* FUNCTION RR_SetPolyFillMode( nMode, hData ) -> nPrevious */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   if( SetPolyFillMode( lpData->hDC, hb_parni( 1 ) ) )
   {
      hb_retni( hb_parni( 1 ) );
   }
   else
   {
      hb_retni( GetPolyFillMode( lpData->hDC ) );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SETTEXTCOLOR )          /* FUNCTION RR_SetTextColor( nColor, hData ) -> nColor */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   if( SetTextColor( lpData->hDC, (COLORREF) hb_parnl( 1 ) ) != CLR_INVALID )
   {
      hb_retnl( hb_parnl( 1 ) );
   }
   else
   {
      hb_retnl( (long) GetTextColor( lpData->hDC ) );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SETBKCOLOR )          /* FUNCTION RR_SetBackColor( nColor, hData ) -> nColor */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   if( SetBkColor( lpData->hDC, (COLORREF) hb_parnl( 1 ) ) != CLR_INVALID )
   {
      hb_retnl( hb_parnl( 1 ) );
   }
   else
   {
      hb_retnl( (long) GetBkColor( lpData->hDC ) );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SETBKMODE )          /* FUNCTION RR_SetBkMode( nMode, hData ) -> nPrevious */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   if( hb_parni( 1 ) == 1 )
   {
      hb_retni( SetBkMode( lpData->hDC, TRANSPARENT ) );
   }
   else
   {
      hb_retni( SetBkMode( lpData->hDC, OPAQUE ) );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_DELETEOBJECTS )          /* FUNCTION RR_DeleteObjects( aGDIObjects ) -> NIL */
{
   UINT i;

   for( i = 2; i <= hb_parinfa( 1, 0 ); i++ )
      DeleteObject( HGDIOBJparam2( 1, i ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_DELETEIMAGELISTS )          /* FUNCTION RR_DeleteImageLists( aImageLists ) -> NIL */
{
   UINT i;

   for( i = 1; i <= hb_parinfa( 1, 0 ); i++ )
      ImageList_Destroy( HIMAGELISTparam3( 1, i, 1 ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SAVEMETAFILE )          /* FUNCTION RR_SaveMetaFile( hOldEMF, cName ) -> hNewEMF */
{
   HEMFret( CopyEnhMetaFile( HEMFparam( 1 ), hb_parc( 2 ) ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETCURRENTOBJECT )          /* FUNCTION RR_GetCurrentObject( nObject, hData ) -> hObject */
{
   int what = hb_parni( 1 );
   HGDIOBJ hand;
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   if( what == 1 )
   {
      hand = GetCurrentObject( lpData->hDC, OBJ_FONT );
   }
   else
   {
      if( what == 2 )
      {
         hand = GetCurrentObject( lpData->hDC, OBJ_BRUSH );
      }
      else
      {
         hand = GetCurrentObject( lpData->hDC, OBJ_PEN );
      }
   }
   HGDIOBJret( hand );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETSTOCKOBJECT )          /* FUNCTION RR_GetStockObject( nObject ) -> hObject */
{
   HGDIOBJret( GetStockObject( hb_parni( 1 ) ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_CREATEPEN )          /* FUNCTION RR_CreatePen( nStyle, nWidth, nColor ) -> hPen */
{
   HPENret( CreatePen( hb_parni( 1 ), hb_parni( 2 ), (COLORREF) hb_parnl( 3 ) ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_MODIFYPEN )          /* FUNCTION RR_ModifyPen( hPen, nStyle, nWidth, nColor ) -> hPen */
{
   LOGPEN ppn;
   int i;
   HPEN hp;

   memset( &ppn, 0, sizeof( LOGPEN ) );
   i = GetObject( HPENparam( 1 ), sizeof( LOGPEN ), &ppn );
   if( i > 0 )
   {
      if( hb_parni( 2 ) >= 0 )
      {
         ppn.lopnStyle = (UINT) hb_parni( 2 );
      }
      if( hb_parnl( 3 ) >= 0 )
      {
         ppn.lopnWidth.x = hb_parnl( 3 );
      }
      if( hb_parnl( 4 ) >= 0 )
      {
         ppn.lopnColor = (COLORREF) hb_parnl( 4 );
      }

      hp = CreatePenIndirect( &ppn );
      if( hp != NULL )
      {
         DeleteObject( HPENparam( 1 ) );
         HPENret( hp );
      }
      else
      {
         HPENret( HPENparam( 1 ) );
      }
   }
   else
   {
      HPENret( HPENparam( 1 ) );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SELECTPEN )          /* FUNCTION RR_SelectPen( hPen, hData ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   SelectObject( lpData->hDC, HPENparam( 1 ) );
   lpData->hpen = HPENparam( 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_CREATEBRUSH )          /* FUNCTION RR_CreateBrush( nStyle, nColor, nHatch ) -> hBrush */
{
   LOGBRUSH pbr;

   pbr.lbColor = (COLORREF) hb_parnl( 2 );
   pbr.lbStyle = (UINT) hb_parni( 1 );
   switch( pbr.lbStyle )
   {
      case BS_DIBPATTERN:
      case BS_DIBPATTERNPT:
         pbr.lbHatch = (ULONG_PTR) HANDLEparam( 3 );
         break;
      case BS_HATCHED:
         pbr.lbHatch = (ULONG_PTR) hb_parnl( 3 );
         break;
      case BS_PATTERN:
         pbr.lbHatch = (ULONG_PTR) HBITMAPparam( 3 );
         break;
      case BS_SOLID:
      case BS_HOLLOW:
         pbr.lbHatch = (ULONG_PTR) NULL;
         break;
      default:
         pbr.lbHatch = (ULONG_PTR) NULL;
         break;
   }
   HBRUSHret( CreateBrushIndirect( &pbr ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_MODIFYBRUSH )          /* FUNCTION RR_ModifyBrush( hBrush, nStyle, nColor, nHatch ) -> hBrush */
{
   LOGBRUSH ppn;
   int i;
   HBRUSH hb;

   memset( &ppn, 0, sizeof( LOGBRUSH ) );
   i = GetObject( HBRUSHparam( 1 ), sizeof( LOGBRUSH ), &ppn );
   if( i > 0 )
   {
      if( hb_parni( 2 ) >= 0 )
      {
         ppn.lbStyle = (UINT) hb_parni( 2 );
      }
      if( hb_parnl( 3 ) >= 0 )
      {
         ppn.lbColor = (COLORREF) hb_parnl( 3 );
      }
      if( hb_parnl( 4 ) >= 0 )
      {
         ppn.lbHatch = ULONG_PTRparam( 4 );
      }

      hb = CreateBrushIndirect( &ppn );
      if( hb != NULL )
      {
         DeleteObject( HBRUSHparam( 1 ) );
         HBRUSHret( hb );
      }
      else
      {
         HBRUSHret( HBRUSHparam( 1 ) );
      }
   }
   else
   {
      HBRUSHret( HBRUSHparam( 1 ) );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SELECTBRUSH )          /* FUNCTION RR_SelectBrush( hBrush, hData ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   SelectObject( lpData->hDC, HBRUSHparam( 1 ) );
   lpData->hbrush = HBRUSHparam( 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_CREATEFONT )          /* FUNCTION RR_CreateFont( cName, nSize, nWidth, nAngle, nWeight, nItalic, nUnder, nStrike, hData ) -> hFont */
{
   const char * FontName = hb_parc( 1 );
   int FontSize = hb_parni( 2 );
   long FontWidth = hb_parnl( 3 );
   long Orient = hb_parnl( 4 );
   long Weight = hb_parnl( 5 );
   int Italic = hb_parni( 6 );
   int Underline = hb_parni( 7 );
   int Strikeout = hb_parni( 8 );
   HFONT oldfont, hxfont;
   long newWidth, FontHeight;
   TEXTMETRIC tm;
   BYTE bItalic, bUnderline, bStrikeOut;
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 9 );

   newWidth = FontWidth;
   if( FontSize <= 0 )
   {
      FontSize = 10;
   }
   if( FontWidth < 0 )
   {
      newWidth = 0;
   }
   if( Orient <= 0 )
   {
      Orient = 0;
   }
   if( Weight <= 0 )
   {
      Weight = FW_NORMAL;
   }
   else
   {
      Weight = FW_BOLD;
   }
   if( Italic <= 0 )
   {
      bItalic = 0;
   }
   else
   {
      bItalic = 1;
   }
   if( Underline <= 0 )
   {
      bUnderline = 0;
   }
   else
   {
      bUnderline = 1;
   }
   if( Strikeout <= 0 )
   {
      bStrikeOut = 0;
   }
   else
   {
      bStrikeOut = 1;
   }

   FontHeight = - MulDiv( FontSize, lpData->devcaps[ DI_VERT_LOGPIX ], 72 );
   hxfont = CreateFont( FontHeight, newWidth, Orient, Orient, Weight, bItalic, bUnderline, bStrikeOut, lpData->charset,
                        OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, FF_DONTCARE, FontName );
   if( FontWidth < 0 )
   {
      oldfont = (HFONT) SelectObject( lpData->hDC, hxfont );
      GetTextMetrics( lpData->hDC, &tm );
      SelectObject( lpData->hDC, oldfont );
      DeleteObject( hxfont );
      newWidth = (int) ( (float) - ( tm.tmAveCharWidth + tm.tmOverhang ) * FontWidth / 100 );
      hxfont = CreateFont( FontHeight, newWidth, Orient, Orient, Weight, bItalic, bUnderline, bStrikeOut, lpData->charset,
                           OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, FF_DONTCARE, FontName );
   }

   HFONTret( hxfont );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_MODIFYFONT )          /* FUNCTION RR_CreateFont( hFont, cName, nSize, nWidth, nAngle, nBold, nItalic, nUnder, nStrike, hData ) -> hFont */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 10 );
   LOGFONT ppn;
   int i;
   HFONT hf;
   long nHeight;

   memset( &ppn, 0, sizeof( LOGFONT ) );
   i = GetObject( HFONTparam( 1 ), sizeof( LOGFONT ), &ppn );
   if( i > 0 )
   {
      if( hb_parni( 3 ) > 0 )
      {
         nHeight = - MulDiv( hb_parni( 3 ), GetDeviceCaps( lpData->hDC, LOGPIXELSY ), 72 );
         ppn.lfHeight = nHeight;
      }
      if( hb_parnl( 4 ) >= 0 )
      {
         ppn.lfWidth = (long) hb_parnl( 4 ) * ppn.lfWidth / 100;
      }
      if( hb_parnl( 5 ) >= 0 )
      {
         ppn.lfOrientation = hb_parnl( 5 );
         ppn.lfEscapement = hb_parnl( 5 );
      }
      if( hb_parnl( 6 ) == 0 )
      {
         ppn.lfWeight = FW_NORMAL;
      }
      if( hb_parnl( 6 ) > 0 )
      {
         ppn.lfWeight = FW_BOLD;
      }
      if( hb_parni( 7 ) >= 0 )
      {
         ppn.lfItalic = (BYTE) hb_parni( 7 );
      }
      if( hb_parni( 8 ) >= 0 )
      {
         ppn.lfUnderline = (BYTE) hb_parni( 8 );
      }
      if( hb_parni( 9 ) >= 0 )
      {
         ppn.lfStrikeOut = (BYTE) hb_parni( 9 );
      }

      hf = CreateFontIndirect( &ppn );
      if( hf != NULL )
      {
         DeleteObject( HFONTparam( 1 ) );
         HFONTret( hf );
      }
      else
      {
         HFONTret( HFONTparam( 1 ) );
      }
   }
   else
   {
      HFONTret( HFONTparam( 1 ) );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SELECTFONT )          /* FUNCTION RR_SelectFont( hfont, hData ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   SelectObject( lpData->hDC, HFONTparam( 1 ) );
   lpData->hfont = HFONTparam( 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SETCHARSET )          /* FUNCTION RR_SetCharSet( nCharSet, hData ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   lpData->charset = (DWORD) hb_parnl( 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_TEXTOUT )          /* FUNCTION RR_TextOut( cText, aPoint, hFont, nSpaces, hData ) -> nError */
{
   HFONT xfont = HFONTparam( 3 );
   HFONT prevfont = NULL;
   SIZE szMetric;
   int lspace = hb_parni( 4 );
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 5 );

   if( xfont )
   {
      prevfont = (HFONT) SelectObject( lpData->hDC, xfont);
   }
   if( lpData->textjust > 0 )
   {
      GetTextExtentPoint32( lpData->hDC, hb_parc( 1 ), hb_parclen( 1 ), &szMetric );
      if( szMetric.cx < lpData->textjust )
      {
         if( lspace > 0 )
         {
            SetTextJustification( lpData->hDC, (int) ( lpData->textjust - szMetric.cx ), lspace );
         }
      }
   }

   hb_retni( TextOut( lpData->hDC, HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ) + lpData->devcaps[ DI_TMASCENT ], hb_parc( 1 ), hb_parclen( 1 ) ) ? 0 : 1 );

   if( xfont )
   {
      SelectObject( lpData->hDC, prevfont );
   }
   if( lpData->textjust > 0 )
   {
      SetTextJustification( lpData->hDC, 0, 0 );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_DRAWTEXT )          /* FUNCTION RR_DrawText( aPoint, aPoint, cText, nStyle, hFont, lNoBreak, hData ) -> nError */
{
   HFONT xfont = HFONTparam( 5 );
   HFONT prevfont = NULL;
   RECT rect;
   UINT uFormat;
   SIZE  sSize;
   const char * pszData = hb_parc( 3 );
   int iLen = strlen( pszData );
   int iStyle = hb_parni( 4 );
   int iAlign = 0, iNoWordBreak;
   long w, h;
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 7 );

   SetRect( &rect, HB_PARNL2( 1, 2 ), HB_PARNL2( 1, 1 ), HB_PARNL2( 2, 2 ), HB_PARNL2( 2, 1 ) );
   iNoWordBreak = hb_parl( 6 );

   if( xfont )
   {
      prevfont = (HFONT) SelectObject( lpData->hDC, xfont );
   }

   uFormat = DT_NOPREFIX;

   if( iNoWordBreak )
   {
      iAlign = GetTextAlign( lpData->hDC );
      SetTextAlign( lpData->hDC, TA_TOP );
   }
   else
   {
      uFormat |= DT_NOCLIP | DT_WORDBREAK | DT_END_ELLIPSIS;

      GetTextExtentPoint32( lpData->hDC, pszData, iLen, &sSize );
      w = (long) sSize.cx; /* text width */
      h = (long) sSize.cy; /* text height */

      /* Center text vertically within rectangle */
      if( w < rect.right - rect.left )
      {
         rect.top = rect.top + ( rect.bottom - rect.top + h / 2 ) / 2;
      }
      else
      {
         rect.top = rect.top + ( rect.bottom - rect.top - h / 2 ) / 2;
      }
   }

   if( iStyle == 0 )
   {
      uFormat = uFormat | DT_LEFT;
   }
   else if( iStyle == 2 )
   {
      uFormat = uFormat | DT_RIGHT;
   }
   else if( iStyle == 1 )
   {
      uFormat = uFormat | DT_CENTER;
   }

   hb_retni( DrawText( lpData->hDC, pszData, -1, &rect, uFormat ) ? 0 : 1 );

   if( xfont )
   {
      SelectObject( lpData->hDC, prevfont );
   }

   if( iNoWordBreak )
   {
      SetTextAlign( lpData->hDC, iAlign );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_RECTANGLE )          /* FUNCTION RR_Rectangle( aPoint, aPoint, hPen, hBrush, hData ) ) -> nError */
{
   HPEN xpen = HPENparam( 3 );
   HBRUSH xbrush = HBRUSHparam( 4 );
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 5 );

   if( xpen )
   {
      SelectObject( lpData->hDC, xpen );
   }
   if( xbrush )
   {
      SelectObject( lpData->hDC, xbrush );
   }

   hb_retni( Rectangle( lpData->hDC, HB_PARNL2( 1, 2 ), HB_PARNL2( 1, 1 ), HB_PARNL2( 2, 2 ), HB_PARNL2( 2, 1 ) ) ? 0 : 1 );

   if( xpen )
   {
      SelectObject( lpData->hDC, lpData->hpen );
   }
   if( xbrush )
   {
      SelectObject( lpData->hDC, lpData->hbrush );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_CLOSEMFILE )          /* FUNCTION RR_CloseEMFile( hData ) ) -> nSize */
{
   UINT size;
   HENHMETAFILE hh;
   char * eBuffer;
   LPENHMETAHEADER eHeader;
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   hh = CloseEnhMetaFile( lpData->hDC );
   size = GetEnhMetaFileBits( hh, 0, NULL );
   eBuffer = (char *) GlobalAlloc( GPTR, (DWORD) size );
   GetEnhMetaFileBits( hh, size, (BYTE *) eBuffer);
   eHeader = (LPENHMETAHEADER) eBuffer;
   eHeader->szlDevice.cx = lpData->devcaps[ DI_HORZ_RES ];
   eHeader->szlDevice.cy = lpData->devcaps[ DI_VERT_RES ];
   eHeader->szlMillimeters.cx = lpData->devcaps[ DI_HORZ_SIZE ];
   eHeader->szlMillimeters.cy = lpData->devcaps[ DI_VERT_SIZE ];
   hb_retclen( eBuffer, ( ULONG ) size );
   DeleteEnhMetaFile( hh );
   GlobalFree( eBuffer );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_CLOSEFILE )          /* FUNCTION RR_CloseEMFile( hData ) ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   DeleteEnhMetaFile( CloseEnhMetaFile( lpData->hDC ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_CREATEMFILE )          /* FUNCTION RR_CreatEMFile( cFile, hData ) ) -> hDC */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );
   RECT emfrect;

   SetRect( &emfrect, 0, 0, lpData->devcaps[ DI_HORZ_SIZE ] * 100, lpData->devcaps[ DI_VERT_SIZE ] * 100 );
   if( hb_parclen( 1 ) > 0 )
   {
      lpData->hDC = CreateEnhMetaFile( lpData->hDCRef, hb_parc( 1 ), &emfrect, "hbprinter\0emf file\0\0" );
   }
   else
   {
      lpData->hDC = CreateEnhMetaFile( lpData->hDCRef, NULL, &emfrect, "hbprinter\0emf file\0\0" );
   }
   SetTextAlign( lpData->hDC, TA_BASELINE );

   HDCret( lpData->hDC );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_DELETECLIPRGN )          /* FUNCTION RR_DeleteClipRgn( hData ) ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   SelectClipRgn( lpData->hDC, NULL );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_CREATERGN )          /* FUNCTION RR_CreateRgn( aPoint, aPoint, nType, aPoint, hData ) ) -> hRgn */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 5 );
   POINT lpp;
   GetViewportOrgEx( lpData->hDC, &lpp );

   if( hb_parni( 3 ) == 2 )
   {
      HRGNret( CreateEllipticRgn( HB_PARNI( 1, 2 ) + lpp.x, HB_PARNI( 1, 1 ) + lpp.y,
                                  HB_PARNI( 2, 2 ) + lpp.x, HB_PARNI( 2, 1 ) + lpp.y ) );
   }
   else
   {
      if( hb_parni( 3 ) == 3 )
      {
         HRGNret( CreateRoundRectRgn( HB_PARNI( 1, 2 ) + lpp.x, HB_PARNI( 1, 1 ) + lpp.y,
                                      HB_PARNI( 2, 2 ) + lpp.x, HB_PARNI( 2, 1 ) + lpp.y,
                                      HB_PARNI( 4, 2 ) + lpp.x, HB_PARNI( 4, 1 ) + lpp.y ) );
      }
      else
      {
         HRGNret( CreateRectRgn( HB_PARNI( 1, 2 ) + lpp.x, HB_PARNI( 1, 1 ) + lpp.y,
                                 HB_PARNI( 2, 2 ) + lpp.x, HB_PARNI( 2, 1 ) + lpp.y ) );
      }
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_CREATEPOLYGONRGN )          /* FUNCTION RR_CreatePolygonRgn( aPoints ) -> hRgn */
{
   int number = hb_parinfa( 1, 0 );
   int i;
   POINT apoints[ 1024 ];

   for( i = 0; i <= number - 1; i++ )
   {
      apoints[ i ].x = HB_PARNL2( 1, i + 1 );
      apoints[ i ].y = HB_PARNL2( 2, i + 1 );
   }
   HRGNret( CreatePolygonRgn( apoints, number, hb_parni( 3 ) ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_COMBINERGN )          /* FUNCTION RR_CombineRgn( hRgn, hRgn, nStyle ) -> hRgn */
{
   HRGN rgnnew = CreateRectRgn( 0, 0, 1, 1 );

   CombineRgn( rgnnew, HRGNparam( 1 ), HRGNparam( 2 ), hb_parni( 3 ) );
   HRGNret( rgnnew );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SELECTCLIPRGN )          /* FUNCTION RR_SelectClipRgn( hRgn, hData ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   SelectClipRgn( lpData->hDC, HRGNparam( 1 ) );
   lpData->hrgn = HRGNparam( 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SETVIEWPORTORG )          /* FUNCTION RR_SetViewportOrg( aPoint, hData ) -> nError */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   hb_retni( SetViewportOrgEx( lpData->hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), NULL ) ? 0 : 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETVIEWPORTORG )          /* FUNCTION RR_GetViewportOrg( @aPoint, hData ) -> nError */
{
   POINT lpp;
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   hb_retni( GetViewportOrgEx( lpData->hDC, &lpp ) ? 0 : 1 );
   HB_STORNL3( lpp.x, 1, 2 );
   HB_STORNL3( lpp.y, 1, 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SETRGB )          /* FUNCTION RR_SetRGB( nRed, nGreen, nBlue ) -> nColor */
{
   hb_retnl( RGB( hb_parni( 1 ), hb_parni( 2 ), hb_parni( 3 ) ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SETTEXTCHAREXTRA )          /* FUNCTION RR_SetTextCharExtra( nSpace, hData ) -> nPrevious */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   hb_retni( SetTextCharacterExtra( lpData->hDC, hb_parni( 1 ) ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETTEXTCHAREXTRA )          /* FUNCTION RR_GetTextCharExtra( hData ) -> nSpace */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   hb_retni( GetTextCharacterExtra( lpData->hDC ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SETTEXTJUSTIFICATION )          /* FUNCTION RR_SetTextJustification( nJust, hData ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   lpData->textjust = hb_parni( 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETTEXTJUSTIFICATION )          /* FUNCTION RR_GetTextJustification( hData ) -> nJust */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   hb_retni( lpData->textjust );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETTEXTALIGN )          /* FUNCTION RR_GetTextAlign( hData ) -> nAlign */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 1 );

   hb_retni( GetTextAlign( lpData->hDC ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_SETTEXTALIGN )          /* FUNCTION RR_SetTextAlign( nAlign, hData ) -> nPrevious */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   hb_retni( SetTextAlign( lpData->hDC, TA_BASELINE | hb_parni( 1 ) ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
static LPVOID RR_LoadPictureFromResource( const char * resname, long * lwidth, long * lheight )
{
   HBITMAP hbmpx;
   IPicture * iPicture = NULL;
   IStream * iStream = NULL;
   PICTDESC picd;
   HGLOBAL hGlobalres;
   HGLOBAL hGlobal;
   HRSRC hSource;
   LPVOID lpVoid;
   HINSTANCE hinstance = GetModuleHandle( NULL );
   int nSize;

   hbmpx = (HBITMAP) LoadImage( hinstance, resname, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION );
   if( hbmpx != NULL )
   {
      picd.cbSizeofstruct = sizeof( PICTDESC );
      picd.picType = PICTYPE_BITMAP;
      picd.bmp.hbitmap = hbmpx;
      OleCreatePictureIndirect( &picd, &IID_IPicture, TRUE, (LPVOID *) &iPicture );
   }
   else
   {
      hSource = FindResource( hinstance, resname, "HMGPICTURE" );
      if( ! hSource )
      {
         hSource = FindResource( hinstance, resname, "JPG" );
         if( ! hSource )
         {
            hSource = FindResource( hinstance, resname, "JPEG" );
            if( ! hSource )
            {
               hSource = FindResource( hinstance, resname, "GIF" );
               if( ! hSource )
               {
                  hSource = FindResource( hinstance, resname, "BMP" );
                  if( ! hSource )
                  {
                     hSource = FindResource( hinstance, resname, "BITMAP" );
                     if( ! hSource )
                     {
                        hSource = FindResource( hinstance, resname, "PNG" );
                        if( ! hSource )
                        {
                           hSource = FindResource( hinstance, resname, "TIFF" );
                           if( ! hSource )
                           {
                              return NULL;
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      hGlobalres = LoadResource( hinstance, hSource );
      if( hGlobalres == NULL )
      {
         return NULL;
      }
      lpVoid = LockResource( hGlobalres );
      if( lpVoid == NULL )
      {
         return NULL;
      }
      nSize = SizeofResource( hinstance, hSource );
      hGlobal = GlobalAlloc( GPTR, nSize );
      if( hGlobal == NULL )
      {
         return NULL;
      }
      memcpy( hGlobal, lpVoid, nSize );
      FreeResource( hGlobalres );
      CreateStreamOnHGlobal( hGlobal, TRUE, &iStream );
      if( iStream == NULL )
      {
         GlobalFree( hGlobal );
         return NULL;
      }
      OleLoadPicture( iStream, nSize, TRUE, &IID_IPicture, (LPVOID *) &iPicture );
      iStream->lpVtbl->Release( iStream );
      GlobalFree( hGlobal );
   }
   if( iPicture != NULL )
   {
      iPicture->lpVtbl->get_Width( iPicture, lwidth );
      iPicture->lpVtbl->get_Height( iPicture, lheight );
   }
   return iPicture;
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
static LPVOID RR_LoadPicture( const char * filename, long * lwidth, long * lheight )
{
   IStream * iStream = NULL;
   IPicture * iPicture = NULL;
   HGLOBAL hGlobal;
   void * pGlobal;
   HANDLE hFile;
   DWORD nFileSize, nReadByte;

   hFile = CreateFile( filename, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL );
   if( hFile == INVALID_HANDLE_VALUE )
   {
      return NULL;
   }
   nFileSize = GetFileSize( hFile, NULL );
   hGlobal = GlobalAlloc( GMEM_MOVEABLE, nFileSize + 4096 );
   pGlobal = GlobalLock( hGlobal );
   ReadFile( hFile, pGlobal, nFileSize, &nReadByte, NULL );
   CloseHandle( hFile );
   CreateStreamOnHGlobal( hGlobal, TRUE, &iStream );
   if( iStream == NULL )
   {
      GlobalUnlock( hGlobal );
      GlobalFree( hGlobal );
      return NULL;
   }
   OleLoadPicture( iStream, nFileSize, TRUE, &IID_IPicture, (LPVOID *) &iPicture );
   GlobalUnlock( hGlobal );
   GlobalFree( hGlobal );
   iStream->lpVtbl->Release( iStream );
   iStream = NULL;
   if( iPicture != NULL )
   {
      iPicture->lpVtbl->get_Width( iPicture, lwidth );
      iPicture->lpVtbl->get_Height( iPicture, lheight );
   }
   return iPicture;
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
static int RR_DrawIPicture( IPicture * ipic, long lwidth, long lheight, long r, long c, long dr, long dc, long tor, long toc, BOOL bImgSize, LPHBPRINTERDATA lpData )
{
   long x, y, xe, ye;
   RECT lrect;
   HRGN hrgn1;
   POINT lpp;
   long lw, lh;
   int error = 0;

   lw = MulDiv( lwidth, lpData->devcaps[ DI_HORZ_LOGPIX ], 2540 );
   lh = MulDiv( lheight, lpData->devcaps[ DI_VERT_LOGPIX ], 2540 );

   if( bImgSize )
   {
      dr = lh;
      dc = lw;
   }
   else
   {
      if( dc == 0 )
      {
         dc = (int) ( (float) dr * lw / lh );
      }
      if( dr == 0 )
      {
         dr = (int) ( (float) dc * lh / lw );
      }
   }
   if( tor <= 0 )
   {
      tor = dr;
   }
   if( toc <= 0 )
   {
      toc = dc;
   }

   x = c;
   y = r;
   xe = c + toc - 1;
   ye = r + tor - 1;
   GetViewportOrgEx( lpData->hDC, &lpp );

   hrgn1 = CreateRectRgn( c + lpp.x, r + lpp.y, xe + lpp.x, ye + lpp.y );
   if( lpData->hrgn == NULL )
   {
      SelectClipRgn( lpData->hDC, hrgn1 );
   }
   else
   {
      ExtSelectClipRgn( lpData->hDC, hrgn1, RGN_AND );
   }
   while( x < xe )
   {
      while( y < ye )
      {
         SetRect( &lrect, x, y, dc + x, dr + y );
         if( ipic->lpVtbl->Render( ipic, lpData->hDC, x, y, dc, dr, 0, lheight, lwidth, -lheight, &lrect ) != S_OK )
         {
            error = 1;
         }
         y += dr;
      }
      y = r;
      x += dc;
   }

   ipic->lpVtbl->Release( ipic );
   SelectClipRgn( lpData->hDC, lpData->hrgn );
   DeleteObject( hrgn1 );
   return error;
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_DRAWPICTURE )          /* RR_DrawPicture( cPicture, aPoint, aPoint, aPoint, lImgSize, hData ) -> nSuccess */
{
   IPicture * ipic;
   long lwidth = 0;
   long lheight = 0;

   if( ! hb_parclen( 1 ) )
   {
      hb_retni( 1 );
      return;
   }
   ipic = (IPicture *) RR_LoadPicture( hb_parc( 1 ), &lwidth, &lheight );
   if( ! ipic )
   {
      ipic = (IPicture *) RR_LoadPictureFromResource( hb_parc( 1 ), &lwidth, &lheight );
   }
   if( ! ipic )
   {
      hb_retni( 1 );
      return;
   }

   hb_retni( RR_DrawIPicture( ipic, lwidth, lheight,
             HB_PARNL2( 2, 1 ), HB_PARNL2( 2, 2 ), HB_PARNL2( 3, 1 ), HB_PARNL2( 3, 2 ), HB_PARNL2( 4, 1 ), HB_PARNL2( 4, 2 ),
             hb_parl( 5 ), HBPRINTERDATAparam( 6 ) ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_DRAWBITMAP )          /* FUNCTION RR_DrawBitMap( hBitmap, aPoint, aPoint, aPoint, lImgSize, hData ) -> nSuccess */
{
   HBITMAP hBitmap;
   PICTDESC picd;
   IPicture * ipic;
   long lwidth = 0;
   long lheight = 0;

   hBitmap = (HBITMAP) HWNDparam( 1 );
   if( ! hBitmap )
   {
      hb_retni( 1 );
      return;
   }
   picd.cbSizeofstruct = sizeof( PICTDESC );
   picd.picType = PICTYPE_BITMAP;
   picd.bmp.hbitmap = hBitmap;
   if( OleCreatePictureIndirect( &picd, &IID_IPicture, FALSE, (LPVOID *) &ipic ) != S_OK )
   {
      hb_retni( 1 );
      return;
   }
   ipic->lpVtbl->get_Width( ipic, &lwidth );
   ipic->lpVtbl->get_Height( ipic, &lheight );

   hb_retni( RR_DrawIPicture( ipic, lwidth, lheight,
             HB_PARNL2( 2, 1 ), HB_PARNL2( 2, 2 ), HB_PARNL2( 3, 1 ), HB_PARNL2( 3, 2 ), HB_PARNL2( 4, 1 ), HB_PARNL2( 4, 2 ),
             hb_parl( 5 ), HBPRINTERDATAparam( 6 ) ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_CREATEIMAGELIST )          /* FUNCTION RR_CreateImageList( cImage, nIcons, @width, @height ) ) -> hIml */
{
   HBITMAP hbmpx;
   BITMAP bm;
   HIMAGELIST himl = NULL;
   int dx, number;

   hbmpx = (HBITMAP) LoadImage( 0, hb_parc( 1 ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_CREATEDIBSECTION );
   if( hbmpx == NULL )
   {
      hbmpx = (HBITMAP) LoadImage( GetModuleHandle( NULL ), hb_parc( 1 ), IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION );
   }
   if( hbmpx != NULL )
   {
      GetObject( hbmpx, sizeof( BITMAP ), &bm );
      number = hb_parni( 2 );
      if( number == 0 )
      {
         number = (int) bm.bmWidth / bm.bmHeight;
         dx = bm.bmHeight;
      }
      else
      {
         dx = (int) bm.bmWidth / number;
      }
      himl = ImageList_Create( dx, bm.bmHeight, ILC_COLOR24 | ILC_MASK, number, 0 );
      ImageList_AddMasked( himl, hbmpx, CLR_DEFAULT );
      hb_storni( dx, 3 );
      hb_storni( bm.bmHeight, 4 );
      DeleteObject( hbmpx );
   }
   HIMAGELISTret( himl );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_DRAWIMAGELIST )          /* FUNCTION RR_DrawImageList( hIml, nIcon, aStart, aEnd, nWidth, nHeight, nStyle, nColor, hData ) -> nError */
{
   HIMAGELIST himl = HIMAGELISTparam( 1 );
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 9 );
   HDC tempdc, temp2dc;
   HBITMAP hbmpx;
   RECT rect;
   HWND hwnd = GetActiveWindow();

   rect.left = HB_PARNL2( 3, 2 );
   rect.top = HB_PARNL2( 3, 1 );
   rect.right = HB_PARNL2( 4, 2 );
   rect.bottom = HB_PARNL2( 4, 1 );
   temp2dc = GetWindowDC( hwnd );
   tempdc = CreateCompatibleDC( temp2dc );
   hbmpx = CreateCompatibleBitmap( temp2dc, hb_parni( 5 ), hb_parni( 6 ) );
   ReleaseDC( hwnd, temp2dc );
   SelectObject( tempdc, hbmpx );
   BitBlt( tempdc, 0, 0, hb_parni( 5 ), hb_parni( 6 ), tempdc, 0, 0, WHITENESS );
   if( hb_parnl( 8 ) >= 0 )
   {
      ImageList_SetBkColor( himl, (COLORREF) hb_parnl( 8 ) );
   }
   ImageList_Draw( himl, hb_parni( 2 ) - 1, tempdc, 0, 0, (UINT) hb_parni( 7 ) );
   if( hb_parnl( 8 ) >= 0 )
   {
      ImageList_SetBkColor( himl, CLR_NONE );
   }
   hb_retni( StretchBlt( lpData->hDC, rect.left, rect.top, rect.right, rect.bottom, tempdc, 0, 0, hb_parni( 5 ), hb_parni( 6 ), SRCCOPY ) ? 0 : 1 );
   DeleteDC( tempdc );
   DeleteObject( hbmpx );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_POLYGON )          /* FUNCTION RR_Polygon( aCols, aRows, hPen, hBrush, nMode, hData ) -> nError */
{
   int number = (int) hb_parinfa( 1, 0 );
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 6 );
   int i;
   int styl = GetPolyFillMode( lpData->hDC );
   POINT apoints[ 1024 ];
   HPEN xpen = HPENparam( 3 );
   HBRUSH xbrush = HBRUSHparam( 4 );

   for( i = 0; i <= number-1; i++ )
   {
      apoints[ i ].x = HB_PARNL2( 1, i + 1 );
      apoints[ i ].y = HB_PARNL2( 2, i + 1 );
   }

   if( xpen )
   {
      SelectObject( lpData->hDC, xpen );
   }
   if( xbrush )
   {
      SelectObject( lpData->hDC, xbrush );
   }
   SetPolyFillMode( lpData->hDC, hb_parni( 5 ) );

   hb_retni( Polygon( lpData->hDC, apoints, number ) ? 0 : 1 );

   if( xpen )
   {
      SelectObject( lpData->hDC, lpData->hpen );
   }
   if( xbrush )
   {
      SelectObject( lpData->hDC, lpData->hbrush );
   }
   SetPolyFillMode( lpData->hDC, styl );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_POLYBEZIER )          /* FUNCTION RR_PolyBezier( aCols, aRows, hPen, hData ) -> nError */
{
   DWORD number = (DWORD) hb_parinfa( 1, 0 );
   DWORD i;
   POINT apoints[ 1024 ];
   HPEN xpen = HPENparam( 3 );
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 4 );

   for( i = 0; i <= number - 1; i++ )
   {
      apoints[ i ].x = HB_PARNL2( 1, i + 1 );
      apoints[ i ].y = HB_PARNL2( 2, i + 1 );
   }

   if( xpen )
   {
     SelectObject( lpData->hDC, xpen );
   }

   hb_retni( PolyBezier( lpData->hDC, apoints, number ) ? 0 : 1 );

   if( xpen )
   {
      SelectObject( lpData->hDC, lpData->hpen );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_POLYBEZIERTO )          /* FUNCTION RR_PolyBezier( aCols, aRows, hPen, hData ) -> nError */
{
   DWORD number = (DWORD) hb_parinfa( 1, 0 );
   DWORD i;
   POINT apoints[ 1024 ];
   HPEN xpen = HPENparam( 3 );
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 4 );

   for( i = 0; i <= number-1; i++ )
   {
      apoints[ i ].x = HB_PARNL2( 1, i + 1 );
      apoints[ i ].y = HB_PARNL2( 2, i + 1 );
   }

   if( xpen )
   {
      SelectObject( lpData->hDC, xpen );
   }

   hb_retni( PolyBezierTo( lpData->hDC, apoints, number ) ? 0 : 1 );

   if( xpen )
   {
      SelectObject( lpData->hDC, lpData->hpen );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETTEXTEXTENT )          /* FUNCTION RR_GetTextExtent( cText, @aPoint, hFont, hData ) -> nError */
{
   HFONT xfont = HFONTparam( 3 );
   SIZE szMetric;
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 4 );

   if( xfont )
   {
      SelectObject( lpData->hDC, xfont );
   }

   hb_retni( GetTextExtentPoint32( lpData->hDC, hb_parc( 1 ), (int) hb_parclen( 1 ), &szMetric ) ? 0 : 1 );

   HB_STORNL3( szMetric.cy, 2, 1 );
   HB_STORNL3( szMetric.cx, 2, 2 );

   if( xfont )
   {
      SelectObject( lpData->hDC, lpData->hfont );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_ROUNDRECT )          /* FUNCTION RR_RoundRect( aPoint, aPoint, aSize, hPen, hBrush, hData ) -> nError */
{
   HPEN xpen = HPENparam( 4 );
   HBRUSH xbrush = HBRUSHparam( 5 );
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 6 );

   if( xpen )
   {
      SelectObject( lpData->hDC, xpen );
   }
   if( xbrush )
   {
      SelectObject( lpData->hDC, xbrush );
   }

   hb_retni( RoundRect( lpData->hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ), HB_PARNI( 3, 2 ), HB_PARNI( 3, 1 ) ) ? 0 : 1 );

   if( xbrush )
   {
      SelectObject( lpData->hDC, lpData->hbrush );
   }
   if( xpen )
   {
      SelectObject( lpData->hDC, lpData->hpen );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_ELLIPSE )          /* FUNCTION RR_Ellipse( aPoint, aPoint, hPen, hBrush, hData ) -> nError */
{
   HPEN xpen = HPENparam( 3 );
   HBRUSH xbrush = HBRUSHparam( 4 );
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 5 );

   if( xpen )
   {
      SelectObject( lpData->hDC, xpen );
   }
   if( xbrush )
   {
      SelectObject( lpData->hDC, xbrush );
   }

   hb_retni( Ellipse( lpData->hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ) ) ? 0 : 1 );

   if( xpen )
   {
      SelectObject( lpData->hDC, lpData->hpen );
   }
   if( xbrush )
   {
      SelectObject( lpData->hDC, lpData->hbrush );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_CHORD )          /* FUNCTION RR_Ellipse( aPoint, aPoint, aPoint, aPoint, hPen, hBrush, hData ) -> nError */
{
   HPEN xpen = HPENparam( 5 );
   HBRUSH xbrush = HBRUSHparam( 6 );
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 7 );

   if( xpen )
   {
      SelectObject( lpData->hDC, xpen );
   }
   if( xbrush )
   {
      SelectObject( lpData->hDC, xbrush );
   }

   hb_retni( Chord( lpData->hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ),
                    HB_PARNI( 3, 2 ), HB_PARNI( 3, 1 ), HB_PARNI( 4, 2 ), HB_PARNI( 4, 1 ) ) ? 0 : 1 );

   if( xpen )
   {
      SelectObject( lpData->hDC, lpData->hpen );
   }
   if( xbrush )
   {
      SelectObject( lpData->hDC, lpData->hbrush );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_ARCTO )          /* FUNCTION RR_ArcTo( aPoint, aPoint, aPoint, aPoint, hPen, hData ) -> nError */
{
   HPEN xpen = HPENparam( 5 );
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 6 );

   if( xpen )
   {
      SelectObject( lpData->hDC, xpen );
   }

    hb_retni( ArcTo( lpData->hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ),
                     HB_PARNI( 3, 2 ), HB_PARNI( 3, 1 ), HB_PARNI( 4, 2 ), HB_PARNI( 4, 1 ) ) ? 0 : 1 );

   if( xpen )
   {
      SelectObject( lpData->hDC, lpData->hpen );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_ARC )          /* FUNCTION RR_ArcTo( aPoint, aPoint, aPoint, aPoint, hPen, hData ) -> nError */
{
   HPEN xpen = HPENparam( 5 );
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 6 );

   if( xpen )
   {
      SelectObject( lpData->hDC, xpen );
   }

   hb_retni( Arc( lpData->hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ),
                  HB_PARNI( 3, 2 ), HB_PARNI( 3, 1 ), HB_PARNI( 4, 2 ), HB_PARNI( 4, 1 ) ) ? 0 : 1 );

   if( xpen )
   {
      SelectObject( lpData->hDC, lpData->hpen );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_PIE )          /* FUNCTION RR_Pie( aPoint, aPoint, aPoint, aPoint, hPen, hBrush, hData ) -> nError */
{
   HPEN xpen = HPENparam( 5 );
   HBRUSH xbrush = HBRUSHparam( 6 );
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 7 );

   if( xpen )
   {
      SelectObject( lpData->hDC, xpen );
   }
   if( xbrush )
   {
      SelectObject( lpData->hDC, xbrush );
   }

   hb_retni( Pie( lpData->hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ),
                  HB_PARNI( 3, 2 ), HB_PARNI( 3, 1 ), HB_PARNI( 4, 2 ), HB_PARNI( 4, 1 ) ) ? 0 : 1 );

   if( xpen )
   {
      SelectObject( lpData->hDC, lpData->hpen );
   }
   if( xbrush )
   {
      SelectObject( lpData->hDC, lpData->hbrush );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_FILLRECT )          /* FUNCTION RR_FillRect( aPoint, aPoint, hBrush, hData ) -> nError */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 4 );
   RECT rect;

   rect.left = HB_PARNL2( 1, 2 );
   rect.top = HB_PARNL2( 1, 1 );
   rect.right = HB_PARNL2( 2, 2 );
   rect.bottom = HB_PARNL2( 2, 1 );

   hb_retni( FillRect( lpData->hDC, &rect, HBRUSHparam( 3 ) ) ? 0 : 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_FRAMERECT )          /* FUNCTION RR_FrameRect( aPoint, aPoint, hBrush, hData ) -> nError */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 4 );
   RECT rect;

   rect.left = HB_PARNL2( 1, 2 );
   rect.top = HB_PARNL2( 1, 1 );
   rect.right = HB_PARNL2( 2, 2 );
   rect.bottom = HB_PARNL2( 2, 1 );

   hb_retni( FrameRect( lpData->hDC, &rect, HBRUSHparam( 3 ) ) ? 0 : 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_MOVETO )          /* FUNCTION RR_MoveTo( aPoint, hData, @aPoint ) -> nError */
{
   POINT lpp;
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   hb_retni( MoveToEx( lpData->hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), &lpp ) ? 0 : 1 );

   HB_STORNL3( lpp.x, 3, 2 );
   HB_STORNL3( lpp.y, 3, 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_LINE )          /* FUNCTION RR_Line( aPoint, aPoint, hPen, hData ) -> nError */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 4 );
   HPEN xpen = HPENparam( 3 );

   if( xpen )
   {
      SelectObject( lpData->hDC, xpen );
   }

   MoveToEx( lpData->hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), NULL );
   hb_retni( LineTo( lpData->hDC, HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ) ) ? 0 : 1 );

   if( xpen )
   {
      SelectObject( lpData->hDC, lpData->hpen );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_LINETO )          /* FUNCTION RR_LineTo( aPoint, hPen, hData ) -> nError */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 3 );
   HPEN xpen = HPENparam( 2 );

   if( xpen )
   {
      SelectObject( lpData->hDC, xpen );
   }

   hb_retni( LineTo( lpData->hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ) ) ? 0 : 1 );

   if( xpen )
   {
      SelectObject( lpData->hDC, lpData->hpen );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_INVERTRECT )          /* FUNCTION RR_InvertRect( aPoint, aPoint, hData ) -> nError */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 3 );
   RECT rect;

   rect.left = HB_PARNL2( 1, 2 );
   rect.top = HB_PARNL2( 1, 1 );
   rect.right = HB_PARNL2( 2, 2 );
   rect.bottom = HB_PARNL2( 2, 1 );

   hb_retni( InvertRect( lpData->hDC, &rect ) ? 0 : 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETDESKTOPAREA )          /* FUNCTION RR_GetDesktopArea( @aData ) -> NIL */
{
   RECT rect;

   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

   HB_STORNL3( rect.top, 1, 1 );
   HB_STORNL3( rect.left, 1, 2 );
   HB_STORNL3( rect.bottom, 1, 3 );
   HB_STORNL3( rect.right, 1, 4 );
   HB_STORNL3( rect.bottom - rect.top + 1, 1, 5 );
   HB_STORNL3( rect.right - rect.left + 1, 1, 6 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETWINDOWRECT )          /* FUNCTION RR_GetWindowRect( @aData ) -> NIL */
{
   RECT rect;
   HWND hwnd = HWNDparam2( 1, 7 );

   if( hwnd == 0 )
   {
      hwnd = GetDesktopWindow();
   }
   GetWindowRect( hwnd, &rect );
   HB_STORNL3( rect.top, 1, 1 );
   HB_STORNL3( rect.left, 1, 2 );
   HB_STORNL3( rect.bottom, 1, 3 );
   HB_STORNL3( rect.right, 1, 4 );
   HB_STORNL3( rect.bottom - rect.top + 1, 1, 5 );
   HB_STORNL3( rect.right - rect.left + 1, 1, 6 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETCLIENTRECT )          /* FUNCTION RR_ClientRect( @aData ) -> NIL */
{
   RECT rect;

   GetClientRect( HWNDparam2( 1, 7 ), &rect );
   HB_STORNL3( rect.top, 1, 1 );
   HB_STORNL3( rect.left, 1, 2 );
   HB_STORNL3( rect.bottom, 1, 3 );
   HB_STORNL3( rect.right, 1, 4 );
   HB_STORNL3( rect.bottom - rect.top + 1, 1, 5 );
   HB_STORNL3( rect.right - rect.left + 1, 1, 6 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_PLAYPREVIEW )          /* FUNCTION RR_PlayPreview( hWnd, aEMFData, aZoom, lInMemory ) -> hBitmap */
{
   HWND hwnd;
   HDC imgDC, tmpDC;
   RECT rect;
   HBITMAP holdbmp, himgbmp = NULL;
   HENHMETAFILE hh;
   ENHMETAHEADER emh;
   HBRUSH hnewbsh, holdbsh;
   LPBYTE lpBitmapBits = NULL;
   BITMAPINFO bi;
   POINT Point;

   hwnd = HWNDparam( 1 );
   imgDC = GetWindowDC( hwnd );
   if( imgDC != NULL )
   {
      tmpDC = CreateCompatibleDC( imgDC );
      if( tmpDC != NULL )
      {
         if( hb_parl( 4 ) )
         {
            hh = SetEnhMetaFileBits( (UINT) HB_PARCLEN( 2, 1 ), (const BYTE *) HB_PARC( 2, 1 ) );
         }
         else
         {
            hh = GetEnhMetaFile( HB_PARC( 2, 1 ) );
         }
         if( hh != NULL )
         {
            memset( &emh, 0, sizeof( ENHMETAHEADER ) );
            emh.nSize = sizeof( ENHMETAHEADER );
            if( GetEnhMetaFileHeader( hh, sizeof( ENHMETAHEADER ), &emh ) != 0 )
            {
               SetRect( &rect, 0, 0, HB_PARNL2( 3, 4 ), HB_PARNL2( 3, 3 ) );
               bi.bmiHeader.biSize          = sizeof( BITMAPINFOHEADER );
               bi.bmiHeader.biWidth         = rect.right;
               bi.bmiHeader.biHeight        = - rect.bottom;
               bi.bmiHeader.biPlanes        = 1;
               bi.bmiHeader.biBitCount      = 24;
               bi.bmiHeader.biCompression   = BI_RGB;
               bi.bmiHeader.biSizeImage     = 0;
               bi.bmiHeader.biXPelsPerMeter = 0;
               bi.bmiHeader.biYPelsPerMeter = 0;
               bi.bmiHeader.biClrUsed       = 0;
               bi.bmiHeader.biClrImportant  = 0;
               himgbmp = CreateDIBSection( tmpDC, &bi, DIB_RGB_COLORS, (void **) &lpBitmapBits, NULL, 0 );
               if( lpBitmapBits )
               {
                  holdbmp = (HBITMAP) SelectObject( tmpDC, himgbmp );
                  hnewbsh = (HBRUSH) GetStockObject( WHITE_BRUSH );
                  holdbsh = (HBRUSH) SelectObject( tmpDC, hnewbsh );
                  FillRect( tmpDC, &rect, hnewbsh );
                  GetBrushOrgEx( tmpDC, &Point );
                  SetStretchBltMode( tmpDC, HALFTONE );
                  SetBrushOrgEx( tmpDC, Point.x, Point.y, NULL );
                  PlayEnhMetaFile( tmpDC, hh, &rect );
                  SelectObject( tmpDC, holdbsh );
                  SelectObject( tmpDC, holdbmp );
               }
            }
            DeleteEnhMetaFile( hh );
         }
         DeleteDC( tmpDC );
      }
      ReleaseDC( hwnd, imgDC );
   }
   HBITMAPret( himgbmp );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_PLAYTHUMB )          /* FUNCTION RR_PlayThumb( aWinThumbsData, aEMFData, cText, lInMemory ) -> hBitmap */
{
   HWND hwnd;
   HDC imgDC, tmpDC;
   RECT rect;
   HBITMAP holdbmp, himgbmp = NULL;
   HENHMETAFILE hh;
   ENHMETAHEADER emh;
   HBRUSH hnewbsh, holdbsh;
   LPBYTE lpBitmapBits = NULL;
   BITMAPINFO bi;
   POINT Point;

   hwnd = HWNDparam2( 1, 5 );
   imgDC = GetWindowDC( hwnd );
   if( imgDC != NULL )
   {
      tmpDC = CreateCompatibleDC( imgDC ); // or NULL
      if( tmpDC != NULL )
      {
         if( hb_parl( 4 ) )
         {
            hh = SetEnhMetaFileBits( (UINT) HB_PARCLEN( 2, 1 ), (const BYTE *) HB_PARC( 2, 1 ) );
         }
         else
         {
            hh = GetEnhMetaFile( HB_PARC( 2, 1 ) );
         }
         if( hh != NULL )
         {
            memset( &emh, 0, sizeof( ENHMETAHEADER ) );
            emh.nSize = sizeof( ENHMETAHEADER );
            if( GetEnhMetaFileHeader( hh, sizeof( ENHMETAHEADER ), &emh ) != 0 )
            {
               SetRect( &rect, 0, 0, HB_PARNL2( 1, 4 ), HB_PARNL2( 1, 3 ) );
               bi.bmiHeader.biSize          = sizeof( BITMAPINFOHEADER );
               bi.bmiHeader.biWidth         = rect.right;
               bi.bmiHeader.biHeight        = - rect.bottom;
               bi.bmiHeader.biPlanes        = 1;
               bi.bmiHeader.biBitCount      = 24;
               bi.bmiHeader.biCompression   = BI_RGB;
               bi.bmiHeader.biSizeImage     = 0;
               bi.bmiHeader.biXPelsPerMeter = 0;
               bi.bmiHeader.biYPelsPerMeter = 0;
               bi.bmiHeader.biClrUsed       = 0;
               bi.bmiHeader.biClrImportant  = 0;
               himgbmp = CreateDIBSection( tmpDC, &bi, DIB_RGB_COLORS, (void **) &lpBitmapBits, NULL, 0 );
               if( lpBitmapBits )
               {
                  holdbmp = (HBITMAP) SelectObject( tmpDC, himgbmp );
                  hnewbsh = (HBRUSH) GetStockObject( WHITE_BRUSH );
                  holdbsh = (HBRUSH) SelectObject( tmpDC, hnewbsh );
                  FillRect( tmpDC, &rect, hnewbsh );
                  GetBrushOrgEx( tmpDC, &Point );
                  SetStretchBltMode( tmpDC, HALFTONE );
                  SetBrushOrgEx( tmpDC, Point.x, Point.y, NULL );
                  PlayEnhMetaFile( tmpDC, hh, &rect );
                  TextOut( tmpDC, (int) ( rect.right / 2 - 5 ), (int) ( rect.bottom / 2 - 5 ), hb_parc( 3 ), (int) hb_parclen( 3 ) );
                  SelectObject( tmpDC, holdbsh );
                  SelectObject( tmpDC, holdbmp );
               }
            }
            DeleteEnhMetaFile( hh );
         }
         DeleteDC( tmpDC );
      }
      ReleaseDC( hwnd, imgDC );
   }
   HBITMAPret( himgbmp );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_PLAYENHMETAFILE )          /* FUNCTION RR_PlayEnhMetaFile( aData, hDC, lInMemory ) -> hBitmap */
{
   HENHMETAFILE hh;
   ENHMETAHEADER emh;
   RECT rect;
   HDC hDC = HDCparam( 2 );

   if( hb_parl( 3 ) )
   {
      hh = SetEnhMetaFileBits( (UINT) HB_PARCLEN( 1, 1 ), (const BYTE *) HB_PARC( 1, 1 ) );
   }
   else
   {
      hh = GetEnhMetaFile( HB_PARC( 1, 1 ) );
   }
   if( hh != NULL )
   {
      memset( &emh, 0, sizeof( ENHMETAHEADER ) );
      emh.nSize = sizeof( ENHMETAHEADER );
      if( GetEnhMetaFileHeader( hh, sizeof( ENHMETAHEADER ), &emh ) != 0 )
      {
         SetRect( &rect, 0, 0, HB_PARNL2( 1, 5 ), HB_PARNL2( 1, 4 ) );
         PlayEnhMetaFile( hDC, hh, &rect );
         DeleteEnhMetaFile( hh );
      }
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_LALABYE )          /* FUNCTION RR_LaLaBye( nCase ) -> NIL */
{
   LPHBPRINTERDATA lpData = HBPRINTERDATAparam( 2 );

   if( hb_parni( 1 ) == 1 )
   {
      lpData->hDCtemp = lpData->hDC;
      lpData->hDC = lpData->hDCRef;
   }
   else
   {
      lpData->hDC = lpData->hDCtemp;
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_LOADSTRING )          /* FUNCTION RR_LoadString( nIdentifier ) -> cString */
{
   char * cBuffer;

   cBuffer = (char *) GlobalAlloc( GPTR, 255 );
   LoadString( GetModuleHandle( NULL ), (UINT) hb_parni( 1 ), (LPSTR) cBuffer, 254 );
   hb_retc( cBuffer );
   GlobalFree( cBuffer );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETTEMPFOLDER )          /* FUNCTION RR_GetTempFolder() -> cFolder */
{
   char szBuffer[ MAX_PATH + 1 ] = { 0 };

   GetTempPath( MAX_PATH, szBuffer );
   hb_retc( szBuffer );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( RR_GETPIXELCOLOR )          /* FUNCTION RR_GetPixelColor( hBitmap, nRow, nCol ) -> nColor */
{
   HDC memDC;
   COLORREF color;
   HBITMAP hOld;
   HBITMAP hBmp = (HBITMAP) HWNDparam( 1 );

   if( hBmp )
   {
      memDC = CreateCompatibleDC( NULL );
      hOld = (HBITMAP) SelectObject( memDC, hBmp );
      color = GetPixel( memDC, hb_parni( 2 ), hb_parni( 3 ) );
      SelectObject( memDC, hOld );
      DeleteDC( memDC );
   }
   else
   {
      color = -1;
   }
   hb_retnl( (long) color );
}

#pragma ENDDUMP
