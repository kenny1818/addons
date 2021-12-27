/*
 * This sample tests working with dbf files
 * Just change the cPath value to that one you need.
 */
//REQUEST ORDLISTCLEAR, ORDBAGCLEAR
//REQUEST DBFCDX, DBFNTX
//REQUEST LETO  // else done by using letodb.hbc */

#define _HMG_OUTLOG

#include "hmg.ch"
#include "dbinfo.ch"

Function Test_dbfe( oWnd, cPath )
 LOCAL aNames := { "Petr", "Ivan", "Alexander", "Pavel", "Alexey", "Fedor", ;
                   "Konstantin", "Vladimir", "Nikolay", "Andrey", "Dmitry", "Sergey" }
 LOCAL i, aStru
 LOCAL nPort := 2812
 LOCAL nHotbuf := 100
 LOCAL nTimeOut := 6000
 LOCAL nKey
 LOCAL lFresh
 LOCAL cOrderExt, cMemoExt
 FIELD NAME, NUM, INFO, DINFO, MINFO, FLOAT, LONG, LLONG

   oWnd:SendMsg(20)
   oWnd:Action := .F.
   fErase('_Msglog.txt')
   
   ? Procname()+'()'
   ? repl('=', len(Procname())+2)
 
//   SET DATE FORMAT "dd/mm/yy"
//   ALTD()

   IF Empty( cPath )
      cPath := ""
      RDDSETDEFAULT( "DBFNTX" )
   ELSE
      cPath := "//" + cPath + IiF( ":" $ cPath, "", ":" + ALLTRIM( STR( nPort ) ) )
      cPath += Iif( Right(cPath,1) == "/", "", "/" )
   ENDIF

   IF ! EMPTY( cPath )
      IF leto_Connect( cPath, /*user*/, /*pass*/, nTimeOut /*timeout*/, nHotBuf /*hot buffer*/ ) == -1
//         ALERT("NO LETODB SERVER FOUND - Fehler: " + leto_Connect_Err( .T. ) )
//         QUIT

         ? "NO LETODB SERVER FOUND - Fehler: " + leto_Connect_Err( .T. )

         oWnd:Action := .T.
         oWnd:PostMsg(21)
         DO EVENTS
         RETURN
      ELSE
         ? LETO_GetServerVersion(), " at address: ", Leto_getLocalIP( .T. )
         // LETO_DBDRIVER( "DBFCDX", "SMT", 512 )
         LETO_DBDRIVER( "DBFNTX", "SMT", 512 )
         /* alternative: RddInfo( RDDI_MEMOTYPE, DB_MEMO_SMT ); RddInfo( RDDI_MEMOBLOCKSIZE, 512 ) */
         ? "DBF DATABASE DRIVER        :", LETO_DBDRIVER()[ 1 ], "MEMOTYPE:", LETO_DBDRIVER()[ 2 ]
         LETO_TOGGLEZIP( 1 )
         ? "NETWORK TRAFFIC COMPRESSION:", Iif( LETO_TOGGLEZIP() > 0, "ON", "OFF" )
      ENDIF
   ENDIF

   ? "RDD: ", RddSetDefault(),  " , DBF EXTENSION:", hb_rddInfo( RDDI_TABLEEXT )

   ? "File test1.dbf"
   IF ! DbExists( "test1.dbf" )
      IF dbCreate( "test1", { { "NAME",  "C", 10, 0 },;
                              { "NUM",   "N",  6, 0 },;
                              { "LONG",  "N", 17, 8 },;
                              { "LLONG", "N", 20, 0 },;
                              { "FLOAT", "F", 17, 8 },;
                              { "INFO",  "C", 32, 0 },;
                              { "DINFO", "D",  8, 0 },;
                              { "TINFO", "@",  8, 0 },;
                              { "MINFO", "M", 10, 0 } },, .T., "TEST1" )
         ?? " have been new created, left open"
      ELSE
//         ALERT( "DBF CREATE FAILED" + IIF( NetErr(), ", TABLE IN USE BY OTHER", "" ) )
//         QUIT
         ? "DBF CREATE FAILED" + IIF( NetErr(), ", TABLE IN USE BY OTHER", "" )
         oWnd:Action := .T.
         oWnd:PostMsg(21)
         DO EVENTS
         RETURN
      ENDIF
   ELSE
      USE ( "test1" ) SHARED NEW
      ?? " existed, opened"
   ENDIF


   IF ! NetErr() .AND. ! EMPTY( ALIAS() )
      ?? " successful !"
   ELSE
      ? "ERROR opening database! -- press any key to quit"
//      Inkey( 0 )
//      QUIT
      oWnd:Action := .T.
      oWnd:PostMsg(21)
      DO EVENTS
      RETURN
   ENDIF

   ? "Lockscheme    :", hb_rddInfo( RDDI_LOCKSCHEME ),;
     IiF( RddSetDefault() == "LETO", Leto_UDF( "DbInfo", DBI_LOCKSCHEME ), DbInfo( DBI_LOCKSCHEME ) )
   cMemoExt := DbInfo( DBI_MEMOEXT )
   ? "Memo extension:", Padl( hb_rddInfo( RDDI_MEMOEXT ), 10 ), Padl( cMemoExt, 10 )
   ? "     blocksize:", hb_rddInfo( RDDI_MEMOBLOCKSIZE ),;
     IiF( RddSetDefault() == "LETO", Leto_UDF( "DbInfo", DBI_MEMOBLOCKSIZE ), DbInfo( DBI_MEMOBLOCKSIZE ) )

   aStru := dbStruct()
   ? "Fields:", Len( aStru )
   FOR i := 1 TO Len( aStru )
      ? i, PadR( aStru[ i, 1 ], 10 ), aStru[ i, 2 ], aStru[ i, 3 ], aStru[ i, 4 ]
   NEXT

   ?
   ? "Press any key to continue..."
//   Inkey( 0 )

   IF ! RDDInfo( RDDI_STRUCTORD )
      RDDInfo( RDDI_STRUCTORD, .T. )  /* activate AUTOPEN for NTX */
   ENDIF

   IF RecCount() == 0
      FOR i := 1 TO Len( aNames )
         APPEND BLANK
         REPLACE NAME  WITH aNames[ i ],;
                 NUM   WITH i + 1000,;
                 LONG  WITH 12345678.12345678,;
                 LLONG WITH IIF( i % 2 == 0, 9223372036854775807, 9223372036854775807 * -1 ),;
                 FLOAT WITH 87654321.87654321,;
                 INFO  WITH "This is a record number "+Ltrim(Str(i)),;
                 DINFO WITH Date() + i - 1,;
                 MINFO WITH "elk test" + STR( i, 10, 0)
      NEXT i
      DbUnlock()
      ? LEN( aNames ), "Records has been added"
      IF LASTREC() == LEN( aNames )
         ?? " (ok)"
      ELSE
         ?? " fail"
      ENDIF
      INDEX ON NAME TAG NAME
      ? "INDEX KEY 1:", IIF( indexord() == 1, "(ok)", "(fail)" ), indexkey( 1 )
      INDEX ON Str(NUM,4) TAG NUMS
      ? "INDEX KEY 2:", IIF( indexord() == 2, "(ok)", "(fail)" ), indexkey( 2 )
      INDEX ON NUM TAG NUMI TO test2
      ? "INDEX KEY 3:", IIF( indexord() == 3, "(ok)", "(fail)" ), indexkey( 3 )
      INDEX ON DINFO TAG DINFO
      ? "INDEX KEY 4:", IIF( indexord() == 3, "(ok)", "(fail)" ), indexkey( 3 )
      ? "Table now indexed"
      IF RDDINFO( RDDI_MULTITAG )
         ?? ", all in one file"
      ENDIF
      ?? " with extension: ", RDDInfo( RDDI_ORDEREXT ), ";"
      lFresh := .T.
   ELSE
      IF ! DbExists( "test2" + RDDInfo( RDDI_ORDEREXT ) )
         ? "INDEX KEY 2:", IIF( indexord() == 0, "(ok)", "(fail)" ), indexkey( 2 )
         INDEX ON NUM TAG NUMI TO test2
         DbSetIndex( "test2" )
         DbSetIndex( "test1" )
      ELSE
         ? "File was indexed"
         DbSetIndex( "test2" )
         DbSetIndex( "test1" )
      ENDIF
      lFresh := .F.
   ENDIF
   ?? STR( DBORDERINFO( DBOI_ORDERCOUNT ), 2, 0 )
   ?? " orders active "
   ?? Iif( DBORDERINFO( DBOI_ORDERCOUNT ) == IiF( ! lFresh, 4, 3 ), "- Ok","- Failure" )
   cOrderExt := DbOrderInfo( DBOI_BAGEXT )
   DBSETORDER( 0 )
   ? "table locked", IIF( FLock(), "(Ok)", "Failure" )

   i := RecCount()
   ? "Reccount ", i, Iif( i == Len( aNames ), "- Ok","- Failure" )

   GO TOP
   ? "go top    ", NUM, NAME, DINFO, Iif( NUM == 1001, "- Ok"," - Failure" )
   ? "float, long", LLONG, LONG, FLOAT
   ?? Iif( LONG == 12345678.12345678 .AND. FLOAT == 87654321.87654321 .AND. LLONG == -9223372036854775807, " - Ok","- Failure" )
   REPLACE INFO WITH "First", MINFO WITH "First"

   GO BOTTOM
   ? "go bottom ", NUM, NAME, DINFO, Iif( NUM == 1012 .AND. LLONG == 9223372036854775807, "- Ok","- Failure" )
   REPLACE INFO WITH "Last", MINFO WITH "Last"

   DbUnlock()
   SET DELETED ON
   ? 'ordSetFocus( "NAME" )'
   ordSetFocus( "NAME" )
   GO TOP
   ? "go top    ", NUM, NAME, DINFO, Iif( NUM == 1003, "- Ok","- Failure" )

   SKIP 1
   ? "skip      ", NUM, NAME, DINFO, Iif( NUM == 1005, "- Ok","- Failure" )
   SKIP 3; SKIP -3
   SKIP 6; SKIP -6
   SKIP 2; SKIP -2
   SKIP 11; SKIP -11
   SKIP -1

   GO BOTTOM
   ? "go bottom ", NUM, NAME, DINFO, Iif( NUM == 1008, "- Ok","- Failure" )

   SKIP -1
   ? "skip -1   ", NUM, NAME, DINFO, Iif( NUM == 1012, "- Ok","- Failure" )

   SKIP -5
   SKIP 5

   SKIP 1
   ? "skip 1    ", NUM, NAME, DINFO, Iif( NUM == 1008, "- Ok","- Failure" )

   SEEK "Petr"
   ? "seek      ", NUM, NAME, DINFO, Iif( NUM == 1001, "- Ok","- Failure" )
   SEEK "Andre"
   ? "seek      ", NUM, NAME, DINFO, Iif( NUM == 1010, "- Ok","- Failure" )

   SET FILTER TO NUM >= 1004 .AND. NUM <= 1010
   ?
   ? "SET FILTER TO NUM >= 1004 .AND. NUM <= 1010"
   GO TOP
   ? "go top    ", NUM, NAME, DINFO, Iif( NUM == 1005, "- Ok","- Failure" )

   SKIP
   ? "skip      ", NUM, NAME, DINFO, Iif( NUM == 1010, "- Ok","- Failure" )

   GO BOTTOM
   ? "go bottom ", NUM, NAME, DINFO, Iif( NUM == 1008, "- Ok","- Failure" )

   SKIP -1
   ? "skip -1   ", NUM, NAME, DINFO, Iif( NUM == 1004, "- Ok","- Failure" )

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

   SET FILTER TO NUM >= 1009
   ?
   ? 'ordSetFocus( "NUMS" ), SET SCOPE TO "1009", "1011"'
   ordSetFocus( "NUMS" )
   SET SCOPE TO "1009", "1011"

   GO TOP
   ? "go top    ", NUM, NAME, DINFO, Iif( NUM == 1009, "- Ok","- Failure" )

   SKIP
   ? "skip      ", NUM, NAME, DINFO, Iif( NUM == 1010, "- Ok","- Failure" )

   SKIP
   ? "skip      ", NUM, NAME, DINFO, Iif( NUM == 1011, "- Ok","- Failure" )

   SKIP
   ? "skip      ", NUM, NAME, DINFO, Iif( Eof(), "- Ok","- Failure" )

   SET FILTER TO NUM >= 1009
   ?
   ? 'ordSetFocus( "NUMS" ), SET FILTER TO NUM >= 1009, SET SCOPE TO NIL, "1011"'
   ordSetFocus( "NUMS" )
   SET SCOPE TO
   SET SCOPE TO , "1011"

   GO TOP
   ? "go top    ", NUM, NAME, DINFO, Iif( NUM == 1009, "- Ok","- Failure" )

   SKIP
   ? "skip      ", NUM, NAME, DINFO, Iif( NUM == 1010, "- Ok","- Failure" )

   SKIP
   ? "skip      ", NUM, NAME, DINFO, Iif( NUM == 1011, "- Ok","- Failure" )

   SKIP
   ? "skip      ", NUM, NAME, DINFO, Iif( Eof(), "- Ok","- Failure" )

   DbCloseAll()
   ?
   ? "Press any key to continue..."
//   Inkey( 0 )

   ?
   SET AUTOPEN OFF
   SET AUTORDER TO 0
   USE ( "test1" ) SHARED New
   i := DBORDERINFO( DBOI_ORDERCOUNT )
   ? "AutOpen off " + IIF( i == 0, "- Ok", "- Failure" )
   USE

   SET AUTORDER TO 1
   SET AUTOPEN ON
   USE ( "test1" ) SHARED New
   i := 0
   ? "AutoOpened Tags:"
   DO WHILE ! Empty( Ordkey( ++i ) )
      ? i, ordKey( i )
   ENDDO
   i := DBORDERINFO( DBOI_ORDERCOUNT )
   IF RDDInfo( RDDI_STRUCTORD )
      ? "Active orders ", i, Iif( i == 3, "- Ok","- Failure" )
      ? "Focus set to  ", indexord(), Iif( indexord() == SET( _SET_AUTORDER ), "- Ok","- Failure" )
   ELSE
      ? "Indextype does not support to auto-open index, found:", STR( i, 1, 0 ), " TAGs"
   ENDIF

   OrdListAdd( "test2" )
   ? "Destroy singular TAG <NUMI> in BAG <test2>", IIF( OrdDestroy( "NUMI" ) .AND. ! hb_dbExists( "test2.cdx" ), "- Ok","- Failure" )

   DBCLOSEALL()

   ?
   ? "Press ENTER to delete test DBF, any other key to finish, ..."
//   nKey := Inkey( 0 )
   nKey := 13
   
   IF nKey == 13
      hb_dbDrop( "test1.dbf" )
      IF hb_dbexists( "test1.dbf" ) .OR.;
         hb_dbExists( "test1" + cOrderExt ) .OR.;
         hb_dbexists( "test1" + cMemoExt )
         ? "drop dbf: - Failure "
      ELSE
         ? "drop dbf: -  Ok"
      ENDIF

      ?
      ? "Press any key to finish ..."
//      INKEY( 0 )
   ENDIF

   IF RDDSETDEFAULT() == "LETO"
      leto_Disconnect()
   ENDIF

   oWnd:Action := .T.
   oWnd:SendMsg(21)
   DO EVENTS
   fErase('_Msglog.txt')

Return Nil

