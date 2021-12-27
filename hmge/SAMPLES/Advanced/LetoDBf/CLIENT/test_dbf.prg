/*
 * This sample tests working with dbf files
 * Just change the cPath value to that one you need.
 */

//REQUEST LETO
//REQUEST DBFCDX
#define _HMG_OUTLOG

#include "hmg.ch"
#include "dbinfo.ch"

Function Test_dbf( oWnd, cPath )
 LOCAL aNames := { "Petr", "Ivan", "Alexander", "Pavel", "Alexey", "Elch", ;
                  "Konstantin", "Vladimir", "Nikolay", "Andrey", "Dmitry", "Sergey" }
 LOCAL i, aStru, aServerDriver
 LOCAL nPort := 2812
 FIELD NAME, NUM, INFO, DINFO, MINFO, TINFO

   oWnd:SendMsg(20)
   oWnd:Action := .F.

   fErase('_Msglog.txt')

   ? Procname()+'()'
   ? repl('=', len(Procname())+2)

//   ALTD()
//   SET DATE FORMAT "dd/mm/yy"
   
   IF Empty( cPath )
      cPath := ""
      RDDSETDEFAULT( "DBFCDX" )
   ELSE
      cPath := "//" + cPath + IiF( ":" $ cPath, "", ":" + ALLTRIM( STR( nPort ) ) )
      cPath += Iif( Right(cPath,1) == "/", "", "/" )
      RDDSETDEFAULT( "LETO" )
   ENDIF
   
   ? "RDD", RDDSETDEFAULT()
   ? "File created", cPath + "test1"
   IF dbCreate( cPath + "test1", { { "NAME",  "C", 10, 0 },;
                                   { "NUM" ,  "N",  4, 0 },;
                                   { "INFO",  "C", 32, 0 },;
                                   { "DINFO", "D",  8, 0 },;
                                   { "TINFO", "@",  8, 0 },;
                                   { "MINFO", "M", 10, 0 } } )
      ? "File has been created"
   ENDIF

   USE ( cPath + "test1" ) NEW
   IF ! NetErr() .AND. ! EMPTY( ALIAS() )
      ? "File has been opened"
   ELSE
      ? "ERROR opening database! -- press any key to quit"
//      Inkey( 0 )
//      QUIT
      oWnd:Action := .T.
      oWnd:PostMsg(21)
      DO EVENTS
      RETURN
   ENDIF
   aStru := dbStruct()
   ? "Fields:", Len( aStru )
   FOR i := 1 TO Len( aStru )
      ? i, aStru[i,1], aStru[i,2], aStru[i,3], aStru[i,4]
   NEXT

   FOR i := 1 TO Len( aNames )
      APPEND BLANK
      REPLACE NAME  WITH aNames[ i ],;
              NUM   WITH i + 1000,;
              INFO  WITH "This is a record number " + Ltrim( Str( i ) ),;
              DINFO WITH Date() + i - 1,;
              MINFO WITH aNames[ i ]
#ifndef __XHARBOUR__
      REPLACE TINFO WITH IIF( i == 6, HB_STRTOTS( "" ), hb_DToT( DATE() + i, TIME() ) )
#else
      REPLACE TINFO WITH IIF( i == 6, STOT( "00000000000000.000" ),;
                                      STOT( DTOS( DATE() + i ) + LEFT( TIME(), 2 ) + SUBSTR( TIME(),4,2) + RIGHT(TIME(),2) + ".321" ) )
#endif
   NEXT
   ? LEN( aNames ), "Records has been added"
   INDEX ON NAME TAG NAME
   ? "INDEX KEY 1:", indexkey( 1 )
   INDEX ON STR( NUM, 4 ) TAG NUM
   ? "INDEX KEY 2:", indexkey( 2 )
   INDEX ON TINFO TAG TS
   ? "INDEX KEY 3:", indexkey( 3 )
   INDEX ON INFO TAG ASH
   ? "INDEX KEY 3:", indexkey( 4 )
   ? "File has been indexed, "
   ?? DBORDERINFO( DBOI_ORDERCOUNT )
   ?? " active orders "
   ?? Iif( DBORDERINFO( DBOI_ORDERCOUNT ) == 4, "- Ok","- Failure" )

   ?
   ? "Press any key to continue..."
//   Inkey( 0 )

   i := RecCount()
   ? "Reccount ", i, Iif( i == Len( aNames ), "- Ok","- Failure" )

   DbSetOrder( 0 )
   GO TOP
   ? "go top   ", NUM, NAME, DINFO, Iif( NUM == 1001, "- Ok","- Failure" )
   REPLACE INFO WITH "First", MINFO WITH "First"

   DbGoTo( 5 )
   REPLACE INFO WITH ""

   GO BOTTOM
   ? "go bottom", NUM, NAME, DINFO, Iif( NUM == 1012, "- Ok","- Failure" )
   REPLACE INFO WITH "Last", MINFO WITH "Last"

   ?
   ? 'ordSetFocus( "NAME" )'
   ordSetFocus( "NAME" )
   GO TOP
   ? "go top   ", NUM, NAME, DINFO, Iif( NUM == 1003, "- Ok","- Failure" )

   SKIP
   ? "skip     ", NUM, NAME, DINFO, Iif( NUM == 1005, "- Ok","- Failure" )

   GO BOTTOM
   ? "go bottom", NUM, NAME, DINFO, Iif( NUM == 1008, "- Ok","- Failure" )

   SKIP -1
   ? "skip -1  ", NUM, NAME, DINFO, Iif( NUM == 1012, "- Ok","- Failure" )

   DbSetOrder( 4 )
   DBGOBOTTOM()
   DBSEEK( "", .T. )
   ? "DbSeek( '',.T. )      ", NUM, NAME, DINFO, Iif( NUM == 1005, "- Ok","- Failure" )
   DbSetOrder( 1 )

   DBGOBOTTOM()
   DBSEEK( "Petr", .F. )
   ? "DbSeek( 'Petr',.F. )  ", NUM, NAME, DINFO, Iif( NUM == 1001, "- Ok","- Failure" )

   DBGOBOTTOM()
   DBSEEK( "Petr", .T. )
   ? "DbSeek( 'Petr',.F. )  ", NUM, NAME, DINFO, Iif( NUM == 1001, "- Ok","- Failure" )

   DBGOBOTTOM()
   DBSEEK( "Pe", .T. )
   ? "DbSeek( 'Pe',.T. )    ", NUM, NAME, DINFO, Iif( NUM == 1001, "- Ok","- Failure" )

   DbSetOrder( 3 )
   DBGOBOTTOM()
#ifndef __XHARBOUR__
   DBSeek( hb_DToT( DATE() + 5 ), .T. )
#else
   DBSeek( STOT( DTOS( DATE() + 5 ) + "000000.000" ), .T. )
#endif
   ? "DbSeek( TS,.T. )      ", NUM, NAME, DINFO, Iif( NUM == 1005, "- Ok","- Failure" )

   DBGOBOTTOM()
#ifndef __XHARBOUR__
   DBSeek( hb_DToT( DATE() + 5 ), .F. )
#else
   DBSeek( STOT( DTOS( DATE() + 5 ) + "000000.000" ), .F. )
#endif
   ? "DbSeek( TS,.F. )      ", NUM, NAME, DINFO, Iif( EOF(), "- Ok","- Failure" )
   DbSetOrder( 1 )

   DBGOTOP()
   DBSEEK( "Sergey", .F. )
   ? "DbSeek( 'Sergey',.F. )", NUM, NAME, DINFO, Iif( NUM == 1012, "- Ok","- Failure" )

   DBGOTOP()
   DBSEEK( "Ser", .T. )
   ? "DbSeek( 'Sergey',.T. )", NUM, NAME, DINFO, Iif( NUM == 1012, "- Ok","- Failure" )

   DBGOTOP()
   DBSEEK( "Sergez", .F. )
   ? "DbSeek( 'Sergez',.F. )", NUM, NAME, DINFO, Iif( EOF(), "- Ok","- Failure" )

   SET FILTER TO NUM >= 1004 .AND. NUM <= 1010
   ?
   ? "SET FILTER TO NUM >= 1004 .AND. NUM <= 1010"
   GO TOP
   ? "go top   ", NUM, NAME, DINFO, Iif( NUM == 1005, "- Ok","- Failure" )

   SKIP
   ? "skip     ", NUM, NAME, DINFO, Iif( NUM == 1010, "- Ok","- Failure" )

   GO BOTTOM
   ? "go bottom", NUM, NAME, DINFO, Iif( NUM == 1008, "- Ok","- Failure" )

   SKIP -1
   ? "skip -1  ", NUM, NAME, DINFO, Iif( NUM == 1004, "- Ok","- Failure" )

   ? "Press any key to continue..."
//   Inkey( 0 )

   ?
   ? "SET FILTER TO, SET ORDER TO 0"
   SET FILTER TO
   SET ORDER TO 0

   GO TOP
   ? "First record", Iif( ALLTRIM( INFO ) == "First" .AND. MINFO == "First", "- Ok","- Failure" )

   GO BOTTOM
   ? "Last record ", Iif( ALLTRIM( INFO ) == "Last" .AND. MINFO == "Last", "- Ok","- Failure" )

   ?
   ? 'ordSetFocus( "NUM" ), SET SCOPE TO "1009", "1011"'
   ordSetFocus( "NUM" )
   SET SCOPE TO "1009", "1011"

   GO TOP
   ? "go top", NUM, NAME, DINFO, Iif( NUM == 1009, "- Ok","- Failure" )

   SKIP
   ? "skip  ", NUM, NAME, DINFO, Iif( NUM == 1010, "- Ok","- Failure" )

   SKIP
   ? "skip  ", NUM, NAME, DINFO, Iif( NUM == 1011, "- Ok","- Failure" )

   SKIP
   ? "skip  ", NUM, NAME, DINFO, Iif( Eof(), "- Ok","- Failure" )

   dbCloseAll()

   ?
   ? "Press any key to continue..."
//   Inkey( 0 )

   IF RDDSETDEFAULT() == "LETO"
      aServerDriver := leto_DbDriver()
   ENDIF
   IF "CDX" $ RDDSETDEFAULT() .OR. ( VALTYPE( aServerDriver ) == "A" .AND. "CDX" $ aServerDriver[ 1 ] )
      USE ( cPath + "test1" ) NEW
      i := 0
      ? "auto opened index Tags:"
      DO WHILE ! Empty( Ordkey( ++i ) )
         ? i, ordKey( i )
      ENDDO
      OrdSetFocus( 3 )
      OrdDestroy( "TS" )
      ? "Indexord after OrdDestroy():", INDEXORD(), IIF( INDEXORD() == 0, " - Ok", " - Failure" )
   ENDIF

   dbCloseAll()
   ?
   ? "dropping test DBF: "
   ?? Iif( DbDrop( cPath + "test1" ), "- Ok","- Failure" )

   ?
   ? "Press any key to finish ..."
//   Inkey( 0 )
   oWnd:Action := .T.
   oWnd:SendMsg(21)
   DO EVENTS
   fErase('_Msglog.txt')

Return Nil

