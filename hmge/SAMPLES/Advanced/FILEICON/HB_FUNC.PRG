
#pragma BEGINDUMP

#include <ShObjIdl.h>
#include <mgdefs.h>

HB_FUNC( ISHICON )  // IsHIcon( hIcon ) --> lIsHIcon
{
   HICON    hIcon;
   ICONINFO iconinfo;
   BOOL     bTrue;

   hIcon = ( HICON ) HB_PARNL( 1 );

   bTrue = GetIconInfo( hIcon, &iconinfo );
   if( bTrue )
      bTrue = iconinfo.fIcon;

   hb_retl( bTrue );
}

HB_FUNC( GETICOINDEX )
{
   SHFILEINFO sfi = { 0 };

   SHGetFileInfo( hb_parc( 1 ), 0, &sfi, sizeof( SHFILEINFO ), SHGFI_ICON | SHGFI_SYSICONINDEX | SHGFI_SMALLICON );

   hb_retnl( ( LONG ) sfi.iIcon );

   HB_STORNL( ( LONG_PTR ) ( HICON ) sfi.hIcon, 2 );
}

HMG_DEFINE_DLL_FUNC( win_Shell_GetImageLists,                              // user function name
                     "Shell32.dll",                                        // dll name
                     BOOL,                                                 // function return type
                     WINAPI,                                               // function type
                     "Shell_GetImageLists",                                // dll function name
                     ( HIMAGELIST * phimlLarge, HIMAGELIST * phimlSmall ), // dll function parameters (types and names)
                     ( phimlLarge, phimlSmall ),                           // function parameters (only names)
                     FALSE                                                 // return value if fail call function of dll
                     )

//        BT_ImageListGetSystemIcon ( [ lLargeIcon ] ) --> hImageList
HB_FUNC( BT_IMAGELISTGETSYSTEMICON )
{
   BOOL       lLargeIcon = ( BOOL ) hb_parl( 1 );
   HIMAGELIST himlLarge  = NULL;
   HIMAGELIST himlSmall  = NULL;

   win_Shell_GetImageLists( &himlLarge, &himlSmall );

   if( lLargeIcon )
      HB_RETNL( ( LONG_PTR ) himlLarge );
   else
      HB_RETNL( ( LONG_PTR ) himlSmall );
}

//        ListView_SetImageList ( hWnd , hImageList , [iImageList] )
HB_FUNC( LISTVIEW_SETIMAGELIST )
{
   HWND       hWnd       = ( HWND ) HB_PARNL( 1 );
   HIMAGELIST hImageList = ( HIMAGELIST ) HB_PARNL( 2 );
   int        iImageList = HB_ISNIL( 3 ) ? LVSIL_SMALL : hb_parni( 3 );

   HIMAGELIST hImageListPrevious = ListView_SetImageList( hWnd, hImageList, iImageList );

   HB_RETNL( ( LONG_PTR ) hImageListPrevious );
}

//        ListView_SetItemImageIndex ( hWnd , nRow , nCol, [ nImageIndex ] )
HB_FUNC( LISTVIEW_SETITEMIMAGEINDEX )
{
   HWND hWnd   = ( HWND ) HB_PARNL( 1 );
   int  nRow   = ( int ) hb_parni( 2 );
   int  nCol   = ( int ) hb_parni( 3 );
   int  iImage = HB_ISNIL( 4 ) ? -1 : hb_parni( 4 );

   LV_ITEM LV;

   LV.mask      = LVIF_IMAGE;
   LV.state     = 0;
   LV.stateMask = 0;
   LV.iImage    = iImage;
   LV.iSubItem  = nCol - 1;
   LV.iItem     = nRow - 1;

   ListView_SetItem( hWnd, &LV );
}

#pragma ENDDUMP

*
* EOF
*