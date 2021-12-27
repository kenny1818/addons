/*
 * $Id: h_checklist.prg $
 */
/*
 * ooHG source code:
 * CheckList control
 *
 * Copyright 2012-2021 Fernando Yurisich <fyurisich@oohg.org> and contributors of
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

CLASS TCheckList FROM TGrid

   DATA Type                   INIT "CHECKLIST" READONLY
   DATA lCheckBoxes            INIT .T. READONLY
   DATA FullMove               INIT .F. READONLY
   DATA InPlace                INIT .F. READONLY
   DATA AllowEdit              INIT .F. READONLY
   DATA LastChangedItem        INIT 0

   METHOD Define
   METHOD Value                SETGET
   METHOD Events
   METHOD Events_Notify
   METHOD Width                SETGET
   METHOD CheckItem            SETGET
   METHOD DeleteAllItems
   METHOD AddItem
   METHOD InsertItem
   METHOD Sort
   METHOD DeleteItem
   METHOD ItemVisible
   METHOD Item
   METHOD SetRangeColor
   METHOD ItemCaption          SETGET
   METHOD ItemImage            SETGET
   METHOD DoChange

   /*
   This methods of TGrid class are also available:

   METHOD BackColor            SETGET
   METHOD CountPerPage         BLOCK { | Self | ListViewGetCountPerPage( ::hWnd ) }
   METHOD Define2
   METHOD Events_Enter
   METHOD FirstSelectedItem    BLOCK { | Self | ListView_GetFirstItem( ::hWnd ) }
   METHOD FontColor            SETGET
   METHOD InsertBlank
   METHOD ItemCount            BLOCK { | Self | ListViewGetItemCount( ::hWnd ) }
   METHOD OnEnter
   METHOD Release
   METHOD SetItemColor
   METHOD SetSelectedColors
   */

   ENDCLASS

METHOD Define( ControlName, ParentForm, x, y, w, h, aRows, v, fontname, ;
               fontsize, tooltip, change, gotfocus, lostfocus, aImage, just, ;
               break, HelpId, bold, italic, underline, strikeout, backcolor, ;
               fontcolor, lRtl, lDisabled, lNoTabStop, lInvisible, sort, ;
               descending, aSelectedColors, dblbffr, click ) CLASS TCheckList

   LOCAL aHdr, aWidth, aJust, aPic, aEdC

   ASSIGN w          VALUE w          TYPE "N" DEFAULT ::nWidth
   ASSIGN v          VALUE v          TYPE "A" DEFAULT {}
   ASSIGN sort       VALUE sort       TYPE "L" DEFAULT .F.
   ASSIGN descending VALUE descending TYPE "L" DEFAULT .F.

   If HB_IsArray( aImage ) .AND. Len( aImage ) > 0
      aHdr := {''}
      aWidth := { 0 }
      aJust := { just }
      aPic := {.T.}
      aEdC := { {'IMAGEDATA', {'TEXTBOX', 'CHARACTER'}} }

      If HB_IsArray( aRows )
         If aScan( aRows, { |a| ! HB_IsArray( a ) .OR. ;
                                Len( a ) # 2 .OR. ;
                                ! ValType( a[1] ) $ "CM" .OR. ;
                                ValType( a[2] ) # "N" } ) > 0
            OOHG_MsgError( "TCheckList.Define: ITEMS array is not valid. Program terminated." )
         EndIf
      Else
         aRows := {}
      EndIf
   Else
      aHdr := {''}
      aWidth := { 0 }
      aJust := { just }
      aImage := Nil
      aPic := Nil
      aEdC := { {'TEXTBOX', 'CHARACTER'} }

      If HB_IsArray( aRows )
         If aScan( aRows, { |a| ! ValType( a ) $ "CM" } ) > 0
            OOHG_MsgError( "TCheckList.Define: ITEMS array is not valid. Program terminated." )
         EndIf
      Else
         aRows := {}
      EndIf
   EndIf

   ::Super:Define( ControlName, ParentForm, x, y, w, h, aHdr, aWidth, ;
                   {}, Nil, fontname, fontsize, tooltip, change, Nil, ;
                   Nil, gotfocus, lostfocus, .T., aImage, aJust, ;
                   break, HelpId, bold, italic, underline, strikeout, .F., ;
                   Nil, Nil, .F., backcolor, fontcolor, ;
                   Nil, Nil, aPic, lRtl, .F., ;
                   aEdC, .T., Nil, Nil, Nil, ;
                   Nil, lDisabled, lNoTabStop, lInvisible, .F., ;
                   Nil, Nil, Nil, .F., ;
                   aSelectedColors, Nil, .T., Nil, dblbffr, ;
                   .F., .F., .T., Nil, click, .T., ;
                   Nil, Nil, Nil, Nil, ;
                   Nil, Nil, Nil, Nil, Nil, ;
                   Nil, Nil, Nil, Nil, Nil, Nil, ;
                   .T., Nil, Nil, Nil, ;
                   Nil, Nil, .F., .F., .F. )

   aEval( aRows, { |u| ::AddItem( u ) } )

   ::Width := w

   If Sort
     ::Sort( descending )
   EndIf

   ::Value := v

   Return Self

METHOD Value( aValue ) CLASS TCheckList

   LOCAL lChanged, i, lOld, lSet, nFirst, aItems

   If HB_IsArray( aValue )
      // do not use ::CheckItem to set the new value to avoid firing OnChange event more than once
      lChanged := .F.
      nFirst := 0

      For i := 1 to ::ItemCount
         lOld := ListView_GetCheckState( ::hWnd, i )
         lSet := ( aScan( aValue, i ) > 0 )

         If lSet # lOld
            If ListView_SetCheckState( ::hWnd, i, lSet ) == lSet
               lChanged := .T.
               ::LastChangedItem := i
               If lSet .and. nFirst == 0
                 nFirst := i
               EndIf
            EndIf
         EndIf
      Next i

      If lChanged
         If nFirst > 0
            ::ItemVisible( nFirst )
         EndIf

         ::DoChange()
      EndIf
   EndIf

   aItems := {}
   For i := 1 to ::ItemCount
      If ListView_GetCheckState( ::hWnd, i )
         aAdd( aItems, i )
      EndIf
   Next

   Return aItems

METHOD Events( hWnd, nMsg, wParam, lParam ) CLASS TCheckList

   Local nNext

   If nMsg == WM_LBUTTONDBLCLK
      // ignore double click on checkbox, it was processed as single click
      If ListView_HitOnCheckBox( ::hWnd, GetCursorRow() - GetWindowRow( ::hWnd ), GetCursorCol() - GetWindowCol( ::hWnd ) ) == 0
         If HB_IsBlock( ::OnDblClick )
            ::DoEventMouseCoords( ::OnDblClick, "DBLCLICK" )
         EndIf
      EndIf
      Return 1

   ElseIf nMsg == WM_CONTEXTMENU
      // ignore right click on checkbox
      If ListView_HitOnCheckBox( ::hWnd, GetCursorRow() - GetWindowRow( ::hWnd ), GetCursorCol() - GetWindowCol( ::hWnd ) ) > 0
         Return 1
      EndIf

   ElseIf nMsg == WM_MOUSEWHEEL
      If GET_WHEEL_DELTA_WPARAM( wParam ) > 0
         nNext := ::FirstSelectedItem - 1
         If nNext > 0
            ListView_SetCursel( ::hWnd, nNext )
            ListView_EnsureVisible( ::hWnd, nNext )
         EndIf
      Else
         nNext := ::FirstSelectedItem + 1
         If nNext <= ::ItemCount
            ListView_SetCursel( ::hWnd, nNext )
            ListView_EnsureVisible( ::hWnd, nNext )
         EndIf
      EndIf
      Return 1

   EndIf

   Return ::Super:Events( hWnd, nMsg, wParam, lParam )

METHOD Events_Notify( wParam, lParam ) CLASS TCheckList

   Local nNotify := GetNotifyCode( lParam )
   Local uValue, uRet, nItem

   HB_SYMBOL_UNUSED( wParam )

   If nNotify == NM_CUSTOMDRAW
      // hide the horizontal scrollbar if any is shown
      If ::ColumnWidth( 1 ) # ::ClientWidth
         ::ColumnWidth( 1, ::ClientWidth )
      EndIf

      // this is the same as TGrid's
      uValue := ::FirstSelectedItem
      uRet := TGrid_Notify_CustomDraw( Self, lParam, .F., uValue, 0, ::lCheckBoxes, ::lFocusRect, ::lNoGrid, ::lPLM )
      ListView_SetCursel( ::hWnd, uValue )
      Return uRet

   ElseIf nNotify == LVN_KEYDOWN .AND. GetGridvKey( lParam ) == VK_SPACE
      // detect item
      nItem := ::FirstSelectedItem
      If nItem > 0
         // change check mark
         ::CheckItem( nItem, ! ::CheckItem( nItem ) )
         // skip default action
         Return 1
      EndIf

   ElseIf nNotify == LVN_ENDSCROLL
      // There is a bug in ListView under XP that causes the gridlines to be
      // incorrectly scrolled when the left button is clicked to scroll.
      // This is supposedly documented at KB 813791.
      RedrawWindow( ::hWnd )

   ElseIf nNotify == NM_CLICK
      // detect item
      nItem := ListView_HitOnCheckBox( ::hWnd, GetCursorRow() - GetWindowRow( ::hWnd ), GetCursorCol() - GetWindowCol( ::hWnd ) )
      If nItem > 0
         // change check mark
         ::CheckItem( nItem, ! ::CheckItem( nItem ) )
      Else
         If HB_IsBlock( ::OnClick )
            If ! ::NestedClick
               ::NestedClick := ! _OOHG_NestedSameEvent()
               ::DoEventMouseCoords( ::OnClick, "CLICK" )
               ::NestedClick := .F.
            EndIf
         EndIf
      EndIf
      // skip default action
      Return 1

   ElseIf nNotify == NM_RCLICK
      // detect item
      nItem := ListView_HitOnCheckBox( ::hWnd, GetCursorRow() - GetWindowRow( ::hWnd ), GetCursorCol() - GetWindowCol( ::hWnd ) )
      If nItem > 0
         // change check mark
         ::CheckItem( nItem, ! ::CheckItem( nItem ) )
         // this changes the checkbox
         Return 1
      Else
         If HB_IsBlock( ::OnRClick )
            ::DoEventMouseCoords( ::OnRClick, "RCLICK" )
         EndIf
      EndIf

   ElseIf nNotify == NM_KILLFOCUS
      Return ::DoLostFocus()

   ElseIf nNotify == NM_SETFOCUS
      GetFormObjectByHandle( ::ContainerhWnd ):LastFocusedControl := ::hWnd
      ::FocusEffect()
      ::DoEvent( ::OnGotFocus, "GOTFOCUS" )

   ElseIf nNotify == LVN_INSERTITEM
      IF ::Container != NIL
         RedrawWindow( ::ContainerhWnd )
      ENDIF

   EndIf

   // TGrid's Events_Notify method must be skipped

   Return Nil

METHOD Width( nWidth ) CLASS TCheckList

   If pcount() > 0
      ::Super:Width( nWidth )
      ::ColumnWidth( 1, ::ClientWidth )
   EndIf

   Return ::nWidth

METHOD CheckItem( nItem, lChecked ) CLASS TCheckList

   Local lRet, lOld

   If HB_IsNumeric( nItem ) .AND. nItem >= 1 .AND. nItem <= ::ItemCount
      lOld := ListView_GetCheckState( ::hWnd, nItem )

      If HB_IsLogical( lChecked ) .AND. lChecked # lOld
         ListView_SetCheckState( ::hWnd, nItem, lChecked )

         lRet := ListView_GetCheckState( ::hWnd, nItem )

         If lRet # lOld
            ::LastChangedItem := nItem
            ::DoChange()
         EndIf
      Else
         lRet := lOld
      EndIf
   Else
      lRet := .F.
   EndIf

   Return lRet

METHOD DeleteAllItems() CLASS TCheckList

   Local aValue

   If ::ItemCount > 0
      aValue := ::Value

      ListViewReset( ::hWnd )
      ::GridForeColor := Nil
      ::GridBackColor := Nil

      ::LastChangedItem := 0

      If ! ArraysAreEqual( ::Value, aValue )
         ::DoChange()
      EndIf
   EndIf

   Return Nil

METHOD AddItem( uItem, lChecked, uForeColor, uBackColor ) CLASS TCheckList

   Local aRow

   If ValidHandler( ::ImageList )
      IF ! HB_ISARRAY( uItem ) .OR. Len( uItem ) # 2 .OR. ! ValType( uItem[1] ) $ "CM" .OR. ValType( uItem[2] ) # "N"
         OOHG_MsgError( "TCheckList.AddItem: Item is not valid. Program terminated." )
      ENDIF
   Else
      If ! ValType( uItem ) $ "CM"
         OOHG_MsgError( "TCheckList.AddItem: Item is not a string. Program terminated." )
      EndIf
   EndIf
   aRow := { uItem }

   ::Super:AddItem( aRow, uForeColor, uBackColor )

   // because the new item is added at the end of the list,
   // it's not necessary to change ::LastChangedItem unless
   // the new item is checked

   If HB_IsLogical( lChecked ) .and. lChecked
      ::CheckItem( ::ItemCount, .T. )
   EndIf

   Return ::ItemCount

METHOD InsertItem( nItem, uItem, lChecked, uForeColor, uBackColor ) CLASS TCheckList

   Local aRow, aValue

   If ValidHandler( ::ImageList )
      IF ! HB_ISARRAY( uItem ) .OR. Len( uItem ) # 2 .OR. ! ValType( uItem[1] ) $ "CM" .OR. ValType( uItem[2] ) # "N"
         OOHG_MsgError( "TCheckList.InsertItem: Item is not valid. Program terminated." )
      ENDIF
   Else
      If ! ValType( uItem ) $ "CM"
         OOHG_MsgError( "TCheckList.InsertItem: Item is not a string. Program terminated." )
      EndIf
   EndIf
   aRow := { uItem }

   aValue := ::Value

   nItem := ::Super:InsertItem( nItem, aRow, uForeColor, uBackColor )

   If nItem > 0
      If HB_IsLogical( lChecked ) .and. lChecked
         ::CheckItem( nItem, .T. )
      ElseIf ! ArraysAreEqual( ::Value, aValue )
         ::LastChangedItem := nItem
         ::DoChange()
      EndIf
   EndIf

   Return nItem

METHOD Sort( lDescending ) CLASS TCheckList

   Local aValue, lRet

   ASSIGN lDescending VALUE lDescending TYPE "L" DEFAULT .F.
   aValue := ::Value

   lRet := ::Super:SortColumn( 1, lDescending )

   If ! ArraysAreEqual( ::Value, aValue )
      ::LastChangedItem := 0
      ::DoChange()
   EndIf

   Return lRet

METHOD DeleteItem( nItem ) CLASS TCheckList

   Local lChanged

   lChanged := ( aScan( ::Value, nItem ) > 0 )

   ::Super:DeleteItem( nItem )

   ::LastChangedItem := 0

   If lChanged
      ::DoChange()
   EndIf

   Return Nil

METHOD ItemVisible( nItem ) CLASS TCheckList

   Return ListView_EnsureVisible( ::hWnd, nItem )

METHOD Item( nItem, uItem, lChecked, uForeColor, uBackColor ) CLASS TCheckList

   Local aRow

   If ValidHandler( ::ImageList )
      IF ! HB_ISARRAY( uItem ) .OR. Len( uItem ) # 2 .OR. ! ValType( uItem[1] ) $ "CM" .OR. ValType( uItem[2] ) # "N"
         OOHG_MsgError( "TCheckList.Item: Item is not valid. Program terminated." )
      ENDIF
   Else
      If ! ValType( uItem ) $ "CM"
         OOHG_MsgError( "TCheckList.Item: Item is not a string. Program terminated." )
      EndIf
   EndIf
   aRow := { uItem }

   uItem := ::Super:Item( nItem, aRow, uForeColor, uBackColor)

   If HB_IsLogical( lChecked )
      ::CheckItem( nItem, lChecked )
   EndIf

   Return uItem

METHOD SetRangeColor( uForeColor, uBackColor, nTop, nBottom ) CLASS TCheckList

   Return ::Super:SetRangeColor( uForeColor, uBackColor, nTop, 1, nBottom, 1 )

METHOD DoChange() CLASS TCheckList

   Local xValue, cType, cOldType

   xValue   := ::Value
   cType    := VALTYPE( xValue )
   cOldType := VALTYPE( ::xOldValue )
   cType    := IF( cType    == "M", "C", cType )
   cOldType := IF( cOldType == "M", "C", cOldType )
   IF cOldType == "U" .OR. ;
      ! cType == cOldType .OR. ;
      IF( cType == "A", ;
          ! ArraysAreEqual( xValue, ::xOldValue ), ;
          ! xValue == ::xOldValue )
      ::OldValue  := ::xOldValue
      ::xOldValue := xValue
      ::DoEvent( ::OnChange, "CHANGE" )
   ENDIF

   Return nil

METHOD ItemCaption( nItem, cCaption ) CLASS TCheckList

   If nItem < 1 .OR. nItem > ::ItemCount
      // return the same value as if the item exist and has no caption
      Return ""
   EndIf

   Return ::Super:CellCaption( nItem, 1, cCaption )

METHOD ItemImage( nItem, nImage ) CLASS TCheckList

   If nItem < 1 .OR. nItem > ::ItemCount
      // return the same value as if the item exist and has no image
      Return -1
   EndIf

   Return ::Super:CellImage( nItem, 1, nImage )
