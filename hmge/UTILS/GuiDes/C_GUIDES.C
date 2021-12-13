#define HB_OS_WIN_32_USED

#define _WIN32_WINNT   0x0400

#include <shlobj.h>

#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "winreg.h"
#include "tchar.h"
#include "item.api"

HB_FUNC( GETCLIENTPOS )
{
	HWND hwnd;
   DWORD pos;
   POINT mypoint ;

   PHB_ITEM aMetr = _itemArrayNew( 2 );
   PHB_ITEM temp;

	hwnd = (HWND) hb_parnl (1);
   pos = GetMessagePos();

   mypoint.x = LOWORD(pos);
   mypoint.y = HIWORD(pos);

   ScreenToClient( hwnd, &mypoint );

   temp = _itemPutNL( NULL, mypoint.y );
   _itemArrayPut( aMetr, 1, temp );
   _itemRelease( temp );

   temp = _itemPutNL( NULL, mypoint.x );
   _itemArrayPut( aMetr, 2, temp );
   _itemRelease( temp );

   _itemReturn( aMetr );
   _itemRelease( aMetr );

}

