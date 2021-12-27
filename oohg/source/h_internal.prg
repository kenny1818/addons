/*
 * $Id: h_internal.prg $
 */
/*
 * ooHG source code:
 * Internal Window control
 *
 * Copyright 2006-2021 Vicente Guerra <vicente@guerra.com.mx> and contributors of
 * the Object Oriented (x)Harbour GUI (aka OOHG) Project, https://oohg.github.io/
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


#include "oohg.ch"
#include "hbclass.ch"
#include "i_windefs.ch"
#include "common.ch"

CLASS TInternal FROM TControl

   DATA Type      INIT "INTERNAL" READONLY
   DATA nVirtualHeight INIT 0
   DATA nVirtualWidth  INIT 0
   DATA RangeHeight    INIT 0
   DATA RangeWidth     INIT 0
   DATA OnScrollUp     INIT nil
   DATA OnScrollDown   INIT nil
   DATA OnScrollLeft   INIT nil
   DATA OnScrollRight  INIT nil
   DATA OnHScrollBox   INIT nil
   DATA OnVScrollBox   INIT nil

   METHOD Define
   METHOD Events_VScroll
   METHOD Events_HScroll
   METHOD VirtualWidth        SETGET
   METHOD VirtualHeight       SETGET
   METHOD SizePos
   METHOD ScrollControls
   METHOD Events
   METHOD BackColor           SETGET
   METHOD BackColorCode       SETGET

   ENDCLASS

METHOD Define( ControlName, ParentForm, x, y, OnClick, w, h, ;
               backcolor, tooltip, gotfocus, lostfocus, ;
               Transparent, border, clientedge, icon, ;
               Virtualheight, VirtualWidth, ;
               MouseDragProcedure, MouseMoveProcedure, ;
               NoTabStop, HelpId, invisible, lRtl ) CLASS TInternal

   Local ControlHandle, nStyle, nStyleEx, nError

   ASSIGN ::nCol        VALUE x TYPE "N"
   ASSIGN ::nRow        VALUE y TYPE "N"
   ASSIGN ::nWidth      VALUE w TYPE "N"
   ASSIGN ::nHeight     VALUE h TYPE "N"
   ASSIGN ::Transparent VALUE Transparent TYPE "L" DEFAULT .F.

   if valtype( VirtualHeight ) != "N"
      VirtualHeight := 0
   endif

   if valtype( VirtualWidth ) != "N"
      VirtualWidth := 0
   endif

   ::SetForm( ControlName, ParentForm,,,, backcolor,, lRtl )

   nStyle := ::InitStyle( NIL, NIL, Invisible, NoTabStop ) + ;
             iif( ValType( border ) == "L" .AND. border, WS_BORDER, 0 )

   nStyleEx := WS_EX_CONTROLPARENT
   nStyleEx += iif( ValType( clientedge ) == "L" .AND. clientedge, WS_EX_CLIENTEDGE, 0 )
   nStyleEx += iif( ::Transparent, WS_EX_TRANSPARENT, 0 )

   IF ( nError := _OOHG_TInternal_Register() ) # 0
      OOHG_MsgError( OOHG_MsgReplace( "TInternal.Define: Registration of _OOHG_TINTERNAL class failed with error @1. Program terminated.", { { "@1", hb_ntos( nError ) } } ) )
   ENDIF

   Controlhandle := InitInternal( ::ContainerhWnd, ::ContainerCol, ::ContainerRow, ::nWidth, ::nHeight, nStyle, nStyleEx, ::lRtl )

   ::Register( ControlHandle, ControlName, HelpId,, ToolTip )

   ::HScrollBar := TScrollBar():Define( "0", Self,,,,,,,, ;
                   { |Scroll| _OOHG_Eval( ::OnScrollLeft, Scroll ) }, ;
                   { |Scroll| _OOHG_Eval( ::OnScrollRight, Scroll ) }, ;
                   { |Scroll| _OOHG_Eval( ::OnHScrollBox, Scroll ) }, ;
                   { |Scroll| _OOHG_Eval( ::OnHScrollBox, Scroll ) }, ;
                   { |Scroll| _OOHG_Eval( ::OnHScrollBox, Scroll ) }, ;
                   { |Scroll| _OOHG_Eval( ::OnHScrollBox, Scroll ) }, ;
                   { |Scroll,n| _OOHG_Eval( ::OnHScrollBox, Scroll, n ) }, ;
                   ,,,,,, SB_HORZ, .T. )
   ::HScrollBar:nLineSkip  := 1
   ::HScrollBar:nPageSkip  := 20

   ::VScrollBar := TScrollBar():Define( "0", Self,,,,,,,, ;
                   { |Scroll| _OOHG_Eval( ::OnScrollUp, Scroll ) }, ;
                   { |Scroll| _OOHG_Eval( ::OnScrollDown, Scroll ) }, ;
                   { |Scroll| _OOHG_Eval( ::OnVScrollBox, Scroll ) }, ;
                   { |Scroll| _OOHG_Eval( ::OnVScrollBox, Scroll ) }, ;
                   { |Scroll| _OOHG_Eval( ::OnVScrollBox, Scroll ) }, ;
                   { |Scroll| _OOHG_Eval( ::OnVScrollBox, Scroll ) }, ;
                   { |Scroll,n| _OOHG_Eval( ::OnVScrollBox, Scroll, n ) }, ;
                   ,,,,,, SB_VERT, .T. )
   ::VScrollBar:nLineSkip  := 1
   ::VScrollBar:nPageSkip  := 20

   ::nVirtualHeight := VirtualHeight
   ::nVirtualWidth  := VirtualWidth
   ValidateScrolls( Self, .F. )

   ::hCursor := LoadCursorFromFile( icon )

   If ::Transparent
      RedrawWindowControlRect( ::ContainerhWnd, ::ContainerRow, ::ContainerCol, ::ContainerRow + ::Height, ::ContainerCol + ::Width )
   EndIf

   ::ContainerhWndValue := ::hWnd
   _OOHG_AddFrame( Self )

   ASSIGN ::OnClick     VALUE OnClick   TYPE "B"
   ASSIGN ::OnLostFocus VALUE LostFocus TYPE "B"
   ASSIGN ::OnGotFocus  VALUE GotFocus  TYPE "B"
   ::OnMouseDrag := MouseDragProcedure
   ::OnMouseMove := MouseMoveProcedure

   Return Self

METHOD Events_VScroll( wParam  ) CLASS TInternal

   Local uRet

   uRet := ::VScrollBar:Events_VScroll( wParam  )
   ::RowMargin := - ::VScrollBar:Value
   ::ScrollControls()

   Return uRet

METHOD Events_HScroll( wParam  ) CLASS TInternal

   Local uRet

   uRet := ::HScrollBar:Events_HScroll( wParam  )
   ::ColMargin := - ::HScrollBar:Value
   ::ScrollControls()

   Return uRet

METHOD VirtualWidth( nSize ) CLASS TInternal

   If valtype( nSize ) == "N"
      ::nVirtualWidth := nSize
      ValidateScrolls( Self, .T. )
   EndIf

   Return ::nVirtualWidth

METHOD VirtualHeight( nSize ) CLASS TInternal

   If valtype( nSize ) == "N"
      ::nVirtualHeight := nSize
      ValidateScrolls( Self, .T. )
   EndIf

   Return ::nVirtualHeight

METHOD SizePos( Row, Col, Width, Height ) CLASS TInternal

   LOCAL uRet

   uRet := ::Super:SizePos( Row, Col, Width, Height )
   ValidateScrolls( Self, .T. )

   RETURN uRet

METHOD ScrollControls() CLASS TInternal

   AEVAL( ::aControls, { |o| If( o:Container:hWnd == ::hWnd, o:SizePos(), ) } )
   ReDrawWindow( ::hWnd )

   RETURN Self

Function _EndInternal()

   Return _OOHG_DeleteFrame( "INTERNAL" )


#pragma BEGINDUMP

#include "oohg.h"
#include "hbapiitm.h"
#include "hbvm.h"
#include "hbstack.h"

#define s_Super s_TControl

/*--------------------------------------------------------------------------------------------------------------------------------*/
static WNDPROC _OOHG_TInternal_lpfnOldWndProc( LONG_PTR lp )
{
   static LONG_PTR lpfnOldWndProc = 0;

   WaitForSingleObject( _OOHG_GlobalMutex(), INFINITE );
   if( ! lpfnOldWndProc )
   {
      lpfnOldWndProc = lp;
   }
   ReleaseMutex( _OOHG_GlobalMutex() );

   return (WNDPROC) lpfnOldWndProc;
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
static LRESULT APIENTRY SubClassFunc( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam )
{
   return _OOHG_WndProcCtrl( hWnd, msg, wParam, lParam, _OOHG_TInternal_lpfnOldWndProc( 0 ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
static LRESULT CALLBACK _OOHG_TInternal_WndProc( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
   return DefWindowProc( hWnd, message, wParam, lParam );
}

static BOOL bRegistered = FALSE;

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( _OOHG_TINTERNAL_UNREGISTER )          /* FUNCTION _OOHG_TInternal_UnRegister() -> lRegisteredStatus */
{
   if( bRegistered )
   {
      if( UnregisterClass( "_OOHG_TINTERNAL", GetModuleHandle( NULL ) ) )
      {
         bRegistered = FALSE;
      }
   }

   hb_retl( bRegistered );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( _OOHG_TINTERNAL_REGISTER )          /* FUNCTION _OOHG_TInternal_Register() -> nError */
{
   if( ! bRegistered )
   {
      WNDCLASS WndClass;
      memset( &WndClass, 0, sizeof( WndClass ) );
      WndClass.style         = CS_HREDRAW | CS_VREDRAW | CS_OWNDC | CS_DBLCLKS;
      WndClass.lpfnWndProc   = _OOHG_TInternal_WndProc;
      WndClass.lpszClassName = "_OOHG_TINTERNAL";
      WndClass.hInstance     = GetModuleHandle( NULL );
      WndClass.hbrBackground = ( HBRUSH )( COLOR_BTNFACE + 1 );

      if( ! RegisterClass( &WndClass ) )
      {
         hb_retni( (int) GetLastError() );
      }

      bRegistered = TRUE;
   }

   hb_retni( 0 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( INITINTERNAL )
{
   int Style = hb_parni( 6 ) | WS_CHILD | SS_NOTIFY;
   int StyleEx = hb_parni( 7 ) | _OOHG_RTL_Status( hb_parl( 8 ) );

   HWND hCtrl = CreateWindowEx( StyleEx, "_OOHG_TINTERNAL", "", Style, hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ),
                                hb_parni( 5 ), HWNDparam( 1 ), NULL, GetModuleHandle( NULL ), NULL );

   _OOHG_TInternal_lpfnOldWndProc( SetWindowLongPtr( hCtrl, GWLP_WNDPROC, (LONG_PTR) SubClassFunc ) );

   HWNDret( hCtrl );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC_STATIC( TINTERNAL_EVENTS )          /* METHOD Events( hWnd, nMsg, wParam, lParam ) CLASS TInternal */
{
   HWND hWnd      = HWNDparam( 1 );
   UINT message   = (UINT)   hb_parni( 2 );
   WPARAM wParam  = WPARAMparam( 3 );
   LPARAM lParam  = LPARAMparam( 4 );
   PHB_ITEM pSelf = hb_stackSelfItem();

   switch( message )
   {
      case WM_GETDLGCODE:
         {
            hb_retni( DLGC_WANTTAB );
         }
         break;

      case WM_MOUSEWHEEL:
         {
            _OOHG_Send( pSelf, s_Events_VScroll );
            hb_vmPushLong( ( GET_WHEEL_DELTA_WPARAM( wParam  ) > 0 ) ? SB_LINEUP : SB_LINEDOWN );
            hb_vmSend( 1 );
         }
         hb_retni( 1 );
         break;

      case WM_ERASEBKGND:
         {
            POCTRL oSelf = _OOHG_GetControlInfo( pSelf );
            HBRUSH hBrush;
            RECT rect;
            GetClientRect( hWnd, &rect );
            hBrush = oSelf->BrushHandle ? oSelf->BrushHandle : ( HBRUSH ) ( COLOR_BTNFACE + 1 );
            FillRect( (HDC) wParam, &rect, hBrush );
            hb_retni( 1 );
         }
         break;

      case WM_LBUTTONUP:
         {
            SendMessage( GetParent( hWnd ), WM_COMMAND, MAKEWORD( STN_CLICKED, 0 ), (LPARAM) hWnd );
         }
         break;

      default:
         _OOHG_Send( pSelf, s_Super );
         hb_vmSend( 0 );
         _OOHG_Send( hb_param( -1, HB_IT_OBJECT ), s_Events );
         HWNDpush( hWnd );
         hb_vmPushLong( message );
         hb_vmPushNumInt( wParam  );
         hb_vmPushNumInt( lParam );
         hb_vmSend( 4 );
         break;
   }
}

HB_FUNC_STATIC( TINTERNAL_BACKCOLOR )
{
   PHB_ITEM pSelf = hb_stackSelfItem();
   POCTRL oSelf = _OOHG_GetControlInfo( pSelf );

   if( _OOHG_DetermineColorReturn( hb_param( 1, HB_IT_ANY ), &oSelf->lBackColor, ( hb_pcount() >= 1 ) ) )
   {
      if( oSelf->BrushHandle )
      {
         DeleteObject( oSelf->BrushHandle );
      }
      oSelf->BrushHandle = ( oSelf->lBackColor == -1 ) ? 0 : CreateSolidBrush( oSelf->lBackColor );
      if( ValidHandler( oSelf->hWnd ) )
      {
         RedrawWindow( oSelf->hWnd, NULL, NULL, RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
      }
   }

   /* Return value was set in _OOHG_DetermineColorReturn() */
}

HB_FUNC_STATIC( TINTERNAL_BACKCOLORCODE )
{
   PHB_ITEM pSelf = hb_stackSelfItem();
   POCTRL oSelf = _OOHG_GetControlInfo( pSelf );

   if( hb_pcount() >= 1 )
   {
      if( ! _OOHG_DetermineColor( hb_param( 1, HB_IT_ANY ), &oSelf->lBackColor ) )
      {
         oSelf->lBackColor = -1;
      }
      if( oSelf->BrushHandle )
      {
         DeleteObject( oSelf->BrushHandle );
      }
      oSelf->BrushHandle = ( oSelf->lBackColor == -1 ) ? 0 : CreateSolidBrush( oSelf->lBackColor );
      if( ValidHandler( oSelf->hWnd ) )
      {
         RedrawWindow( oSelf->hWnd, NULL, NULL, RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
      }
   }

   hb_retnl( oSelf->lBackColor );
}

#pragma ENDDUMP
