/*
 * $Id: h_editbox.prg $
 */
/*
 * ooHG source code:
 * EditBox control
 *
 * Copyright 2005-2021 Vicente Guerra <vicente@guerra.com.mx> and contributors of
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
#include "common.ch"
#include "i_windefs.ch"
#include "hbclass.ch"

CLASS TEdit FROM TText

   DATA Type             INIT "EDIT" READONLY
   DATA nOnFocusPos      INIT -4
   DATA OnHScroll        INIT Nil
   DATA OnVScroll        INIT Nil
   DATA nWidth           INIT 120
   DATA nHeight          INIT 240

   METHOD Define
   METHOD LookForKey
   METHOD Events_Command
   METHOD Events_Enter   BLOCK { || Nil }

   ENDCLASS

METHOD Define( ControlName, ParentForm, x, y, w, h, value, fontname, ;
               fontsize, tooltip, maxlength, gotfocus, change, lostfocus, ;
               readonly, break, HelpId, invisible, notabstop, bold, italic, ;
               underline, strikeout, field, backcolor, fontcolor, novscroll, ;
               nohscroll, lRtl, lNoBorder, OnFocusPos, OnHScroll, OnVScroll, ;
               lDisabled, nInsType ) CLASS TEdit

   Local nStyle := ES_MULTILINE + ES_WANTRETURN, nStyleEx := 0

   ASSIGN ::nWidth  VALUE w TYPE "N"
   ASSIGN ::nHeight VALUE h TYPE "N"

   nStyle += IF( HB_IsLogical( novscroll ) .AND. novscroll, ES_AUTOVSCROLL, WS_VSCROLL ) + ;
             IF( HB_IsLogical( nohscroll ) .AND. nohscroll, 0,              WS_HSCROLL )

   ::SetSplitBoxInfo( Break )

   ::Define2( ControlName, ParentForm, x, y, ::nWidth, ::nHeight, value, ;
              fontname, fontsize, tooltip, maxlength, .f., ;
              lostfocus, gotfocus, change, nil, .f., HelpId, ;
              readonly, bold, italic, underline, strikeout, field, ;
              backcolor, fontcolor, invisible, notabstop, nStyle, lRtl, ;
              .F., nStyleEx, lNoBorder, OnFocusPos, lDisabled, ;
              NIL, NIL, NIL, NIL, NIL, NIL, ;
              NIL, NIL, nInsType ) 

   ASSIGN ::OnHScroll VALUE OnHScroll TYPE "B"
   ASSIGN ::OnVScroll VALUE OnVScroll TYPE "B"

   Return Self

METHOD LookForKey( nKey, nFlags ) CLASS TEdit

   Local lDone

   lDone := ::Super:LookForKey( nKey, nFlags )
   If nKey == VK_ESCAPE .and. nFlags == 0
      lDone := .T.
   EndIf

   Return lDone

METHOD Events_Command( wParam ) CLASS TEdit

   Local Hi_wParam := HiWord( wParam )

   If Hi_wParam == EN_HSCROLL
      ::DoEvent( ::OnHScroll, "HSCROLL" )
      Return Nil

   ElseIf Hi_wParam == EN_VSCROLL
      ::DoEvent( ::OnVScroll, "VSCROLL" )
      Return Nil
   EndIf

   Return ::Super:Events_Command( wParam )