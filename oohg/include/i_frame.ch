/*
 * $Id: i_frame.ch $
 */
/*
 * ooHG source code:
 * Frame definitions
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


#xcommand @ <row>, <col> FRAME <name> ;
      [ OBJ <obj> ] ;
      [ <dummy: OF, PARENT> <parent> ] ;
      [ CAPTION <caption> ] ;
      [ WIDTH <width> ] ;
      [ HEIGHT <height> ] ;
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold: BOLD> ] ;
      [ <italic: ITALIC> ] ;
      [ <underline: UNDERLINE> ] ;
      [ <strikeout: STRIKEOUT> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ <opaque: OPAQUE> ] ;
      [ <transparent: TRANSPARENT> ] ;
      [ <rtl: RTL> ] ;
      [ <invisible: INVISIBLE> ] ;
      [ <disabled: DISABLED> ] ;
      [ SUBCLASS <subclass> ] ;
      [ TOOLTIP <tooltip> [ EXCLUDEAREA <area> [ OF <coord: CONTROL, FORM> ] ] [ <pp: POSTPARENT> ] ] ;
   => ;
      [ <obj> := ] _OOHG_SelectSubClass( TFrame(), [ <subclass>() ] ): ;
         Define( <(name)>, <(parent)>, <row>, <col>, <width>, <height>, <caption>, ;
         <fontname>, <fontsize>, <.opaque.>, <.bold.>, <.italic.>, ;
         <.underline.>, <.strikeout.>, <backcolor>, <fontcolor>, ;
         <.transparent.>, <.rtl.>, <.invisible.>, <.disabled.>, <tooltip>, ;
         <area>, <"coord">, NIL, .F., <.pp.> )

#xcommand DEFINE GROUPBOX <name> ;
      [ AT <row>, <col> ] ;
      [ OBJ <obj> ] ;
      [ <dummy: OF, PARENT> <parent> ] ;
      [ CAPTION <caption> ] ;
      [ WIDTH <width> ] ;
      [ HEIGHT <height> ] ;
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold: BOLD> ] ;
      [ <italic: ITALIC> ] ;
      [ <underline: UNDERLINE> ] ;
      [ <strikeout: STRIKEOUT> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ <opaque: OPAQUE> ] ;
      [ <transparent: TRANSPARENT> ] ;
      [ <rtl: RTL> ] ;
      [ <invisible: INVISIBLE> ] ;
      [ <disabled: DISABLED> ] ;
      [ SUBCLASS <subclass> ] ;
      [ TOOLTIP <tooltip> [ EXCLUDEAREA <area> [ OF <coord: CONTROL, FORM> ] ] [ <pp: POSTPARENT> ] ] ;
      [ <noauto: NOAUTOEXCLUDE> ] ;
   => ;
      [ <obj> := ] _OOHG_SelectSubClass( TFrame(), [ <subclass>() ] ): ;
         Define( <(name)>, <(parent)>, <row>, <col>, <width>, <height>, <caption>, ;
         <fontname>, <fontsize>, <.opaque.>, <.bold.>, <.italic.>, ;
         <.underline.>, <.strikeout.>, <backcolor>, <fontcolor>, ;
         <.transparent.>, <.rtl.>, <.invisible.>, <.disabled.>, <tooltip>, ;
         <area>, <"coord">, <.noauto.>, .T., <.pp.> )

#xcommand END GROUPBOX [ <x> ] ;
   => ;
      _EndGroupBox()
