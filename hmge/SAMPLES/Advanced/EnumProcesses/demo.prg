/*
 * HMG - Harbour Win32 GUI library Demo
 *
 * Copyright 2014 Dr. Claudio Soto <srvet@adinet.com.uy>
 *
 * The double click allow you terminate the process
 *
 * Used functions:
   - GetCurrentProcessId() --> return nProcessID
   - EnumProcessesID () ---> return array { nProcessID1, nProcessID2, ... }
   - GetProcessName ( [ nProcessID ] ) --> return cProcessName
   - GetProcessFullName ( [ nProcessID ] ) --> return cProcessFullName
   - GetWindowThreadProcessId (hWnd, @nThread, @nProcessID)
   - IsWow64Process ( [ nProcessID ] ) --> return lBoolean
     - return TRUE  if a 32-bit application is running under 64-bit Windows (WOW64)
     - return FALSE if a 32-bit application is running under 32-bit Windows
     - return FALSE if a 64-bit application is running under 64-bit Windows
     - WOW64 is the x86 emulator that allows 32-bit Windows-based applications to running on 64-bit Windows
*/

*************************************************************************************
* Attention: to detect processes 32 and 64 bits you should compiling with HMG-64 bits
*************************************************************************************

#include "hmg.ch"

#define WIN32_PREFIX "*32"


FUNCTION MAIN

   LOCAL aRows := {}, i
   LOCAL nID, c32, cName, cNameFull
   LOCAL fColor, bColor
   LOCAL aProcessesID := EnumProcessesID ()

   FOR i = 1 TO Len ( aProcessesID )
      nID := aProcessesID[ i ]
      c32 := iif ( IsWow64Process( nID ), WIN32_PREFIX, "" )
      cName := GetProcessName( nID )
      cNameFull := GetProcessFullName( nID )
      IF .NOT. Empty ( cNameFull )
         AAdd ( aRows, { hb_ntos( nID ), cName + c32, cNameFull } )
      ENDIF
   NEXT

   ASort ( aRows, , , {| x, y | Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )

   DEFINE WINDOW Form_1 ;
      WIDTH 800 ;
      HEIGHT 550 ;
      BACKCOLOR TEAL ;
      TITLE 'EnumProcesses' ;
      MAIN

      fColor := {|| iif ( GetCurrentProcessID() == Val ( Form_1.Grid_1.Cell ( This.CellRowIndex, 1 ) ), AQUA, iif ( This.CellColIndex == 2 .AND. Right ( This.CellValue, Len ( WIN32_PREFIX ) ) == WIN32_PREFIX, RED, BLUE ) ) }
      bColor := {|| iif ( GetCurrentProcessID() == Val ( Form_1.Grid_1.Cell ( This.CellRowIndex, 1 ) ), GRAY, SILVER ) }

      @ 30, 10 GRID Grid_1 ;
         WIDTH 760 ;
         HEIGHT 450 ;
         BACKCOLOR SILVER ;
         FONT "Courier New" SIZE 12 ;
         HEADERS { 'ID', 'Name', 'Full Name' } ;
         WIDTHS { 100, 0, 0 } ;
         ITEMS aRows ;
         VALUE { 1, 1 } ;
         ON DBLCLICK PROC_Terminate_Process() ;
         DYNAMICFORECOLOR { fColor, fColor, fColor } ;
         DYNAMICBACKCOLOR { bColor, bColor, bColor } ;
         JUSTIFY { GRID_JTFY_RIGHT, NIL, NIL } ;
         CELLNAVIGATION

      Form_1.Grid_1.ColumnAutoFit ( 2 )
      Form_1.Grid_1.ColumnAutoFit ( 3 )

      ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN NIL


PROCEDURE PROC_Terminate_Process

   LOCAL nCellRow := GetProperty ( "Form_1", "Grid_1", "CellRowFocused" )
   LOCAL nID := Val ( Form_1.Grid_1.Cell ( nCellRow, 1 ) )

   IF MsgYesNo ( { nID, " : ", Form_1.Grid_1.Cell ( nCellRow, 2 ) }, "Terminate Process" ) == .T.
      TerminateProcess ( nID )
      Form_1.Grid_1.DeleteItem ( nCellRow )
   ENDIF

RETURN


#pragma BEGINDUMP

#include <mgdefs.h>
#include "hbapiitm.h"

#ifdef UNICODE
   LPSTR WideToAnsi( LPWSTR );
#endif


//        IsWow64Process ( [ nProcessID ] ) --> return lBoolean
HB_FUNC ( ISWOW64PROCESS )
{
   typedef BOOL (WINAPI *Func_IsWow64Process) (HANDLE, BOOL*);   // minimun: Windows XP with SP2
   static Func_IsWow64Process pIsWow64Process = NULL;

   BOOL IsWow64 = FALSE;

   if (pIsWow64Process == NULL)
       pIsWow64Process = (Func_IsWow64Process) GetProcAddress (GetModuleHandle (_TEXT("kernel32")), "IsWow64Process");

   if (pIsWow64Process != NULL)
   {
      if (HB_ISNUM (1) == FALSE)
         pIsWow64Process (GetCurrentProcess(), &IsWow64);
      else
      {
         DWORD ProcessID = (DWORD) hb_parnl (1);
         HANDLE hProcess = OpenProcess ( PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, ProcessID );
         if ( hProcess != NULL )
         {
             pIsWow64Process (hProcess, &IsWow64);
             CloseHandle (hProcess);
         }
      }
   }
   hb_retl ((BOOL) IsWow64 );
}


//        GetCurrentProcessId() --> return nProcessID
HB_FUNC ( GETCURRENTPROCESSID )
{
   hb_retni ((INT) GetCurrentProcessId());
}


//        EnumProcessesID () ---> return array { nProcessID1, nProcessID2, ... }
HB_FUNC ( ENUMPROCESSESID )
{
   typedef BOOL (WINAPI *Func_EnumProcesses) (DWORD*, DWORD, DWORD*);
   static Func_EnumProcesses pEnumProcesses = NULL;

   DWORD i, aProcessesID [1024*5], cbNeeded, nProcesses;

   PHB_ITEM pArray = hb_itemArrayNew (0);

   if (pEnumProcesses == NULL)
   {   HMODULE hLib = LoadLibrary (_TEXT("Psapi.dll"));
       pEnumProcesses = (Func_EnumProcesses) GetProcAddress(hLib, "EnumProcesses");
   }

   if (pEnumProcesses == NULL)
       return;

   if (pEnumProcesses ( aProcessesID, sizeof(aProcessesID), &cbNeeded ) == FALSE)
        return;

   nProcesses = cbNeeded / sizeof(DWORD);

   for (i = 0; i < nProcesses; i++ )
   {   if (aProcessesID [i] != 0)
      {
         PHB_ITEM pItem = hb_itemPutNL (NULL, (LONG) aProcessesID [i]);
         hb_arrayAddForward (pArray, pItem);
         hb_itemRelease ( pItem );
      }
   }

   hb_itemReturnRelease (pArray);
}


//        GetWindowThreadProcessId (hWnd, @nThread, @nProcessID)
HB_FUNC ( GETWINDOWTHREADPROCESSID )
{
   HWND hWnd = (HWND) HB_PARNL (1);
   DWORD nThread, nProcessID;

   nThread = GetWindowThreadProcessId (hWnd, &nProcessID);

   if ( HB_ISBYREF(2) )
        hb_storni (nThread, 2);
   if ( HB_ISBYREF(3) )
        hb_storni (nProcessID, 3);
}


//        GetProcessName ( [ nProcessID ] ) --> return cProcessName
HB_FUNC ( GETPROCESSNAME )
{
   typedef BOOL (WINAPI *Func_EnumProcessModules) (HANDLE, HMODULE*, DWORD, LPDWORD);
   static Func_EnumProcessModules pEnumProcessModules = NULL;

   typedef DWORD (WINAPI *Func_GetModuleBaseName) (HANDLE, HMODULE, LPTSTR, DWORD);
   static Func_GetModuleBaseName pGetModuleBaseName = NULL;

#ifdef UNICODE
   LPSTR pStr;
#endif
   DWORD ProcessID = HB_ISNUM (1) ? (DWORD) hb_parnl(1) : GetCurrentProcessId();
   TCHAR cProcessName [ MAX_PATH ] = _TEXT ("");
   HANDLE hProcess;

   if (pEnumProcessModules == NULL)
   {   HMODULE hLib = LoadLibrary (_TEXT("Psapi.dll"));
       pEnumProcessModules = (Func_EnumProcessModules) GetProcAddress(hLib, "EnumProcessModules");
   }

   if (pEnumProcessModules == NULL)
       return;

   if (pGetModuleBaseName == NULL)
   {   HMODULE hLib = LoadLibrary (_TEXT("Psapi.dll"));

       #ifdef UNICODE
          pGetModuleBaseName = (Func_GetModuleBaseName) GetProcAddress(hLib, "GetModuleBaseNameW");
       #else
          pGetModuleBaseName = (Func_GetModuleBaseName) GetProcAddress(hLib, "GetModuleBaseNameA");
       #endif
   }

   if (pGetModuleBaseName == NULL)
       return;

   hProcess = OpenProcess ( PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, ProcessID );
   if ( hProcess != NULL )
   {   HMODULE hMod;
       DWORD cbNeeded;
       if ( pEnumProcessModules (hProcess, &hMod, sizeof(hMod), &cbNeeded) )
            pGetModuleBaseName (hProcess, hMod, cProcessName, sizeof(cProcessName)/sizeof(TCHAR));

       CloseHandle (hProcess);
#ifndef UNICODE
       hb_retc (cProcessName);
#else
       pStr = WideToAnsi( cProcessName );
       hb_retc (pStr);
       hb_xfree( pStr );
#endif
   }
}


//        GetProcessFullName ( [ nProcessID ] ) --> return cProcessFullName
HB_FUNC ( GETPROCESSFULLNAME )
{
   typedef BOOL (WINAPI *Func_EnumProcessModules) (HANDLE, HMODULE*, DWORD, LPDWORD);
   static Func_EnumProcessModules pEnumProcessModules = NULL;

   typedef DWORD (WINAPI *Func_GetModuleFileNameEx) (HANDLE, HMODULE, LPTSTR, DWORD);
   static Func_GetModuleFileNameEx pGetModuleFileNameEx = NULL;

#ifdef UNICODE
   LPSTR pStr;
#endif
   DWORD ProcessID = HB_ISNUM (1) ? (DWORD) hb_parnl(1) : GetCurrentProcessId();
   TCHAR cProcessFullName [ MAX_PATH ] = _TEXT ("");
   HANDLE hProcess;

   if (pEnumProcessModules == NULL)
   {   HMODULE hLib = LoadLibrary (_TEXT("Psapi.dll"));
       pEnumProcessModules = (Func_EnumProcessModules) GetProcAddress(hLib, "EnumProcessModules");
   }

   if (pEnumProcessModules == NULL)
       return;

   if (pGetModuleFileNameEx == NULL)
   {   HMODULE hLib = LoadLibrary (_TEXT("Psapi.dll"));

       #ifdef UNICODE
          pGetModuleFileNameEx = (Func_GetModuleFileNameEx) GetProcAddress(hLib, "GetModuleFileNameExW");
       #else
          pGetModuleFileNameEx = (Func_GetModuleFileNameEx) GetProcAddress(hLib, "GetModuleFileNameExA");
       #endif
   }

   if (pGetModuleFileNameEx == NULL)
       return;

   hProcess = OpenProcess ( PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, ProcessID );
   if ( hProcess != NULL )
   {   HMODULE hMod;
       DWORD cbNeeded;
       if ( pEnumProcessModules (hProcess, &hMod, sizeof(hMod), &cbNeeded) )
            pGetModuleFileNameEx (hProcess, hMod, cProcessFullName, sizeof(cProcessFullName)/sizeof(TCHAR));

       CloseHandle (hProcess);
#ifndef UNICODE
       hb_retc (cProcessFullName);
#else
       pStr = WideToAnsi( cProcessFullName );
       hb_retc (pStr);
       hb_xfree( pStr );
#endif
   }
}


//        TerminateProcess ( [ nProcessID ] , [ nExitCode ] )
HB_FUNC ( TERMINATEPROCESS )
{
   DWORD ProcessID = HB_ISNUM (1) ? (DWORD) hb_parnl(1) : GetCurrentProcessId();
   UINT  uExitCode = (UINT) hb_parnl (2);
   HANDLE hProcess = OpenProcess ( PROCESS_TERMINATE, FALSE, ProcessID );

   if ( hProcess != NULL )
   {   if ( TerminateProcess (hProcess, uExitCode) == FALSE )
           CloseHandle (hProcess);
   }
}

#pragma ENDDUMP
