/*
 * $Id: i_hb_compat.ch $
 */
/*
 * ooHG source code:
 * Harbour compatibility commands
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


#ifndef __XHARBOUR__                                 // This pp rules are only needed for Harbour compilers

   #include "hbver.ch"

   #xtranslate IsExe64() ;
      => ;
         ( hb_Version( HB_VERSION_BITWIDTH ) == 64 )

   #xtranslate AScan( <a>, <b>, [ <c> ], [ <d> ], <e> ) ;
      => ;
         hb_AScan( <a>, <b>, <c>, <d>, <e> )

   #xtranslate GetThreadId( [<x, ...>] ) ;
      => ;
         hb_threadID( <x> )

   #xtranslate ValToPrgExp( [<x, ...>] ) ;
      => ;
         hb_ValToExp( <x> )

   #xtranslate HexToNum( [<x>] ) ;
      => ;
         hb_HexToNum( <x> )

   #xtranslate i18n( <x> ) ;
      => ;
         hb_i18n_gettext( <x> )

   #xtranslate NumToHex( [<n, ...>] ) ;
      => ;
         hb_NumToHex( <n> )

   #xtranslate CurDrive( [<x>] ) ;
      => ;
         hb_CurDrive( <x> )

   #xtranslate TToC( [<x, ...>] ) ;
      => ;
         hb_TToC( <x> )

   #xtranslate CToT( [<x, ...>] ) ;
      => ;
         hb_CToT( <x> )

   #xtranslate TToS( [<x, ...>] ) ;
      => ;
         hb_TToS( <x> )

   #xtranslate SToT( [<x, ...>] ) ;
      => ;
         hb_SToT( <x> )

   #xtranslate DateTime() ;
      => ;
         hb_DateTime()

   #xtranslate PrintFileRaw( [<x, ...>] ) ;
      => ;
         win_PrintFileRaw( <x> )

   #xtranslate GetDefaultPrinter( [<x, ...>] ) ;
      => ;
         win_PrinterGetDefault( <x> )

   #if ( __HARBOUR__ - 0 > 0x030200 )                // This pp rules are only needed for Harbour 3.4 version

      #xtranslate hb_OEMToANSI( <arg1> ) ;
         => ;
            win_OEMToANSI( <arg1> )

      #xtranslate hb_ANSIToOEM( <arg1> ) ;
         => ;
            win_ANSIToOEM( <arg1> )

   #else                                             // This pp rules are only needed for Harbour 3.0 and 3.2 versions

      #xtranslate win_OEMToANSI( <arg1> ) ;
         => ;
            hb_OEMToANSI( <arg1> )

      #xtranslate win_ANSIToOEM( <arg1> ) ;
         => ;
            hb_ANSIToOEM( <arg1> )

      #if ( __HARBOUR__ - 0 < 0x030200 )             // This pp rule is only needed for Harbour 3.0 version

         #xtranslate tip_HtmlToStr( <arg1> ) ;
            => ;
               HtmlToOEM( <arg1> )

      #endif   // #if ( __HARBOUR__ - 0 < 0x030200 )

   #endif   // #if ( __HARBOUR__ - 0 > 0x030200 )

#endif   // #ifndef __XHARBOUR__
