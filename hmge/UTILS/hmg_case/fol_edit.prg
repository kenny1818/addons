/*
 * This program is generated by HMGCASE
 * developed by Dragan Cizmarevic < dragancesu(at)gmail.com > 
 */

#include <hmg.ch>

PROCEDURE edit_folder

   PUBLIC NewRec := .F., EditRec := .F.,  FindRec := .F., FiltRec := .F., _qry_exp := ""

   set navigation extended    // for test  
   set deleted on             // for test  

   set date german            // for test  
   set century on            // for test  

   open_folder()             
   pre_folder()
   
   *set procedure to sbr_lov 

   open_f_dbf() 

   DEFINE WINDOW Win_fold ;
      AT 0,0 ;
      WIDTH 1000 ;
      HEIGHT 700 ;
      TITLE "DBF data folder" ;
      MODAL ;
      ON RELEASE dbcloseall() ;
      BACKCOLOR { 230, 230, 230 }

      ON KEY ESCAPE ACTION CancelEdit_f_dbf() 

      ON KEY F4   ACTION ( FiltRec := .F., EditRec := .T., NewRec := .F., If ( RecordStatus_f_dbf(), EnableField_f_dbf(), Nil ))
      ON KEY F6   ACTION ( FiltRec := .F., NewRec := .T., EditRec = .F., NewRecord_f_dbf() )
      ON KEY F8   ACTION ( FiltRec := .F., RecordStatus_f_dbf(), DeleteRecord_f_dbf(), Nil )
      ON KEY F10  ACTION Win_fold.Release

      DEFINE STATUSBAR FONT "Arial" SIZE 12
         STATUSITEM "data folder"
      END STATUSBAR

      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 50,50 IMAGESIZE 24,24 FLAT BORDER

      BUTTON EDIT_f_dbf ;
         CAPTION "[F4] Edit" ;
         PICTURE "edit_edit" ;
         ACTION ( FiltRec := .F., EditRec := .T., NewRec := .F., If ( RecordStatus_f_dbf(), EnableField_f_dbf(), Nil ))

      BUTTON NEW_f_dbf ;
         CAPTION "[F6] New" ;
         PICTURE "edit_new" ;
         ACTION ( FiltRec := .F., NewRec := .T., EditRec = .F., NewRecord_f_dbf() )

      BUTTON DELETE_f_dbf ;
         CAPTION "[F8] Delete" ;
         PICTURE "edit_delete" ;
         ACTION ( FiltRec := .F., RecordStatus_f_dbf(), DeleteRecord_f_dbf(), Nil )

      BUTTON EXIT_f_dbf ;
         CAPTION "[F10] Exit" ;
         PICTURE "edit_close" ;
         ACTION Win_fold.Release

      END TOOLBAR

      PaintDisplay_f_dbf()
	  PaintDisplay_f_fol()

      @ 90, 60 BROWSE Browse_1 ;
         OF Win_fold ;
         WIDTH 300 ;
         HEIGHT 350 ;
         FONT "Arial" ; 
         SIZE 10 ;
         HEADERS { "DBF_NAME","APL" } ;
         WIDTHS { 110,40 } ;
         WORKAREA _DBF_FOL ;
         FIELDS { "DBF_NAME","APL" } ;
         ON CHANGE LoadData_f_dbf() ;
         ON DBLCLICK ( EnableField_f_dbf(), If ( ! RecordStatus_f_dbf(), DisableField_f_dbf(), Nil ) ) ;
         JUSTIFY { , , , } 
		 
      @ 580, 100 BUTTON SAVE_f_dbf ;
         CAPTION "Save" ;
         PICTURE "ok" RIGHT ;
         ACTION SaveRecord_f_dbf() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580, 200 BUTTON CANCEL_f_dbf ;
         CAPTION "Cancel" ;
         PICTURE "cancel" RIGHT ;
         ACTION CancelEdit_f_dbf() ;
         WIDTH 100 ;
         HEIGHT 40 
		 		 
	  @ 90, 410 BROWSE Browse_fol ;
         OF Win_fold ;
         WIDTH 500 ;
         HEIGHT 350 ;
         FONT "Arial" ; 
         SIZE 10 ;
         HEADERS { "APL","APLICATION","FOLDER" } ;
         WIDTHS { 40,100,300 } ;
         WORKAREA _FOLDER ;
         FIELDS { "APL","APLICATION","FOLDER" } ;
         ON CHANGE LoadData_f_fol() ;
         ON DBLCLICK ( EnableField_f_fol(), If ( ! RecordStatus_f_fol(), DisableField_f_fol(), Nil ) ) ;
         JUSTIFY { , , , } 	 
		
      @ 520, 810 BUTTON SELECT_f_fol ;
         CAPTION "Select Folder" ;
         ACTION Select_f_fol() ;
         WIDTH 90 ;
         HEIGHT 25 
		 
	  @ 580, 450 BUTTON SAVE_f_fol ;
         CAPTION "Save" ;
         PICTURE "ok" RIGHT ;
         ACTION SaveRecord_f_fol() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580, 550 BUTTON CANCEL_f_fol ;
         CAPTION "Cancel" ;
         PICTURE "cancel" RIGHT ;
         ACTION CancelEdit_f_fol() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 450, 680 BUTTON PLUS_f_fol ;
         PICTURE "form_new" ;
         ACTION ( FiltRec := .F., NewRec := .T., EditRec = .F., NewRecord_f_fol() ) ;
         WIDTH 60 ;
         HEIGHT 25 
		 
      @ 450, 750 BUTTON MINUS_f_fol ;
         PICTURE "form_del" ;
         ACTION ( FiltRec := .F., RecordStatus_f_fol(), DeleteRecord_f_fol(), Nil ) ; 
         WIDTH 60 ;
         HEIGHT 25 
		 
   END WINDOW

   DisableField_f_dbf()
   DisableField_f_fol()

   Win_fold.Browse_1.SetFocus
   Win_fold.Browse_1.Value := _DBF_FOL->(RecNo())

   ACTIVATE WINDOW Win_fold

RETURN
*:---------------------------------------------*
FUNCTION open_f_dbf()

   use_FOLDER()
   Use_dbf_fol() 

RETURN
*:---------------------------------------------*
PROCEDURE DisableField_f_dbf

   Win_fold.Browse_1.Enabled      := .T.
   
   Win_fold.mDBF_NAME.Enabled     := .F.
   Win_fold.mAPL.Enabled          := .F.
   Win_fold.dAPLNAME.Enabled      := .F.

   Win_fold.Save_f_dbf.Enabled     := .F.
   Win_fold.Cancel_f_dbf.Enabled   := .F.
   Win_fold.Toolbar_1.Enabled     := .T.
   Win_fold.Browse_1.SetFocus

RETURN
*:---------------------------------------------*
PROCEDURE EnableField_f_dbf

   Win_fold.Browse_1.Enabled      := .F.

   Win_fold.mDBF_NAME.Enabled     := .T.
   Win_fold.mAPL.Enabled          := .T.

   Win_fold.Save_f_dbf.Enabled     := .T.
   Win_fold.Cancel_f_dbf.Enabled   := .T.
   Win_fold.Toolbar_1.Enabled     := .F.
   Win_fold.mAPL.SetFocus

RETURN
*:---------------------------------------------*
FUNCTION RecordStatus_f_dbf()

   Local RetVal

   _DBF_FOL->( dbGoTo ( Win_fold.Browse_1.Value ) )

   IF _DBF_FOL->(RLock())
      RetVal := .T.
   ELSE
      MsgExclamation ("Record LOCKED, try again later")
      RetVal := .F.
   ENDIF

RETURN RetVal
*:---------------------------------------------*
PROCEDURE LoadData_f_dbf

   _DBF_FOL->( dbGoTo ( Win_fold.Browse_1.Value ) )

   Win_fold.mDBF_NAME.Value     := _DBF_FOL->DBF_NAME  
   Win_fold.mAPL.Value          := _DBF_FOL->APL       

   SELECT _FOLDER
   SEEK Win_fold.mAPL.Value
   IF FOUND()
      Win_fold.dAPLNAME.Value := APLICATION
   ELSE
      Win_fold.dAPLNAME.Value := "???"
   ENDIF

   SELECT _DBF_FOL

RETURN
*:---------------------------------------------*
PROCEDURE CancelEdit_f_dbf

   DisableField_f_dbf()
   LoadData_f_dbf()
   UNLOCK
   NewRec := .F.
   Win_fold.Browse_1.SetFocus

RETURN
*:---------------------------------------------*
PROCEDURE SaveRecord_f_dbf

   Local NewRecNo

   DisableField_f_dbf()

   IF NewRec == .T.
      _DBF_FOL->(dbAppend())
      NewRec := .F.
   ELSE
      _DBF_FOL->(dbGoto ( Win_fold.Browse_1.Value ) )
   ENDIF

   NewRecNo := _DBF_FOL->( RecNo() )

   _DBF_FOL->DBF_NAME   := Win_fold.mDBF_NAME.Value
   _DBF_FOL->APL        := Win_fold.mAPL.Value

   Win_fold.Browse_1.Refresh
   IF NewRec == .T.
      Win_fold.Browse_1.Value := NewRecNo 
   ENDIF

   UNLOCK
   dbCommitall()

   Win_fold.StatusBar.Item(1) := "Save Record" 

RETURN
*:---------------------------------------------*
PROCEDURE NewRecord_f_dbf

   Win_fold.StatusBar.Item(1) := "Inserting" 

   SET ORDER TO 1
   dbGoBottom()

   Win_fold.mDBF_NAME.Value     := "DBF"
   Win_fold.mAPL.Value          := "."

   EnableField_f_dbf()

   Win_fold.mDBF_NAME.SetFocus

RETURN
*:---------------------------------------------*
PROCEDURE DeleteRecord_f_dbf

   IF MsgYesNo ( "Are you sure do you want delete record?" )
      IF _DBF_FOL->(FLock())
         DELETE
         Win_fold.Browse_1.Refresh
         UNLOCK
      ENDIF
   ENDIF

RETURN
*:---------------------------------------------*
PROCEDURE PaintDisplay_f_dbf

   @ 500, 60 LABEL Label_1 VALUE "DBF_NAME" TRANSPARENT 
   @ 500, 170 LABEL Label_2 VALUE "APL" TRANSPARENT 
   @ 1070, 320 LABEL Label_3 VALUE "" TRANSPARENT 

   @ 520, 60 TEXTBOX  mDBF_NAME    WIDTH 100 UPPERCASE 
   @ 520, 170 TEXTBOX  mAPL         WIDTH 20 UPPERCASE  on enter valid_1_2("E") on lostfocus valid_1_2("F")
   @ 520, 200 TEXTBOX  dAPLNAME     WIDTH 100

RETURN
*:*********************************
FUNCTION valid_1_2 ( _p1 )

   IF FindRec 
      RETURN .T. 
   ENDIF 

SELECT _FOLDER    
SEEK Win_fold.mAPL.Value
IF FOUND()
   Win_fold.dAPLNAME.Value := APLICATION
   SELECT _DBF_FOL 
   RETURN .T.
ELSE
   IF _p1 = "E"
      SEEK Win_fold.mAPL.Value 
      IF !FOUND()
         Win_fold.mAPL.Value := lov_func ( "_FOLDER","APL","APLICATION" )
      ENDIF

      dbcloseall()
      open_f_dbf()

      SELECT _DBF_FOL 
      RETURN .T.
   ENDIF
ENDIF

RETURN .F.
*:---------------------------------------------*
PROCEDURE DisableField_f_fol

   Win_fold.Browse_fol.Enabled      := .T.
   
   Win_fold.m2apl.Enabled          := .F.
   Win_fold.m2aplICATION.Enabled   := .F.
   Win_fold.m2folder.Enabled       := .F.

   Win_fold.Select_f_fol.Enabled    := .F.
   Win_fold.Save_f_fol.Enabled     := .F.
   Win_fold.Cancel_f_fol.Enabled   := .F.
   Win_fold.Browse_fol.SetFocus

RETURN
*:---------------------------------------------*
PROCEDURE EnableField_f_fol

   Win_fold.Browse_fol.Enabled      := .F.

   Win_fold.m2apl.Enabled          := .T.
   Win_fold.m2aplICATION.Enabled   := .T.
   Win_fold.m2folder.Enabled       := .T.

   Win_fold.Select_f_fol.Enabled    := .T.
   Win_fold.Save_f_fol.Enabled     := .T.
   Win_fold.Cancel_f_fol.Enabled   := .T.
   Win_fold.m2aplICATION.SetFocus

RETURN
*:---------------------------------------------*
FUNCTION RecordStatus_f_fol()

   Local RetVal

   _FOLDER->( dbGoTo ( Win_fold.Browse_fol.Value ) )

   IF _FOLDER->(RLock())
      RetVal := .T.
   ELSE
      MsgExclamation ("Record LOCKED, try again later")
      RetVal := .F.
   ENDIF

RETURN RetVal
*:---------------------------------------------*
PROCEDURE LoadData_f_fol

   _FOLDER->( dbGoTo ( Win_fold.Browse_fol.Value ) )

   Win_fold.m2apl.Value          := _FOLDER->APL       
   Win_fold.m2aplICATION.Value   := _FOLDER->APLICATION
   Win_fold.m2folder.Value       := _FOLDER->FOLDER    

RETURN
*:---------------------------------------------*
PROCEDURE CancelEdit_f_fol

   DisableField_f_fol()
   LoadData_f_fol()
   UNLOCK
   NewRec := .F.
   Win_fold.Browse_fol.SetFocus

RETURN
*:---------------------------------------------*
PROCEDURE SaveRecord_f_fol

   Local NewRecNo

   DisableField_f_fol()

   IF NewRec == .T.
      _FOLDER->(dbAppend())
      NewRec := .F.
   ELSE
      _FOLDER->(dbGoto ( Win_fold.Browse_fol.Value ) )
   ENDIF

   NewRecNo := _FOLDER->( RecNo() )

   _FOLDER->APL        := Win_fold.m2apl.Value
   _FOLDER->APLICATION := Win_fold.m2aplICATION.Value
   _FOLDER->FOLDER     := Win_fold.m2folder.Value

   Win_fold.Browse_fol.Refresh
   IF NewRec == .T.
      Win_fold.Browse_fol.Value := NewRecNo 
   ENDIF

   UNLOCK
   dbCommitall()

   *Win_fold.StatusBar.Item(1) := "Save Record" 

RETURN
*:---------------------------------------------*
PROCEDURE NewRecord_f_fol

   *Win_fold.StatusBar.Item(1) := "Inserting" 

   SET ORDER TO 1
   dbGoBottom()

   Win_fold.m2apl.Value          := "."
   Win_fold.m2aplICATION.Value   := "NEW"
   Win_fold.m2folder.Value       := "."

   EnableField_f_fol()

   Win_fold.m2apl.SetFocus

RETURN
*:---------------------------------------------*
PROCEDURE DeleteRecord_f_fol

   IF MsgYesNo ( "Are you sure do you want delete record?" )
      IF _FOLDER->(FLock())
         DELETE
         Win_fold.Browse_fol.Refresh
         UNLOCK
      ENDIF
   ENDIF

RETURN
*:---------------------------------------------*
PROCEDURE PaintDisplay_f_fol

   @ 500, 410 LABEL Label_1b VALUE "APL" TRANSPARENT 
   @ 500, 440 LABEL Label_2b VALUE "APLICATION" TRANSPARENT 
   @ 500, 550 LABEL Label_3b VALUE "FOLDER" TRANSPARENT 

   @ 520, 410 TEXTBOX  m2apl         WIDTH 20 UPPERCASE 
   @ 520, 440 TEXTBOX  m2aplICATION  WIDTH 100 UPPERCASE 
   @ 520, 550 TEXTBOX  m2folder      WIDTH 250 UPPERCASE 

RETURN
*:---------------------------------------------*
function pre_folder

dbcloseall()

use_dbf_fol()

use _dbf new

do while .not. eof()

_dbf_name = dbf_name

select _dbf_fol
seek _dbf_name
if !found()
   dbappend()
   replace dbf_name with _dbf_name
   replace apl with '.'
endif

select _dbf
dbskip()
enddo

dbcloseall()

return
*-----------------------------------------------*
PROCEDURE USE_DBF_FOL

   USE _dbf_fol INDEX _dbf_fol NEW 

RETURN
*-----------------------------------------------*
PROCEDURE USE_FOLDER

   USE _folder INDEX _folder NEW 

RETURN
*-----------------------------------------------*
PROCEDURE open_folder

LOCAL alist_fld

if ! file ("_DBF_FOL.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"DBF_NAME","C",8,0})
   aadd(alist_fld,{"APL","C",1,0})
   dbcreate("_DBF_FOL",alist_fld)
endif

if ! file ("_FOLDER.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"APL","C",1,0})
   aadd(alist_fld,{"APLICATION","C",10,0})
   aadd(alist_fld,{"FOLDER","C",40,0})
   dbcreate("_FOLDER",alist_fld)
endif

if ! file ("_DBF_FOL.ntx")
   use _DBF_FOL
   index on DBF_NAME to _DBF_FOL
   use 
endif

if ! file ("_FOLDER.ntx")
   use _FOLDER
   index on APL to _FOLDER
   use 
endif

use _folder index _folder
seek '.'
if !found()
   dbappend()
   replace apl with '.'
   replace aplication with 'this'
   replace folder with '.'
endif

dbcloseall()

RETURN
*:-------------------------------------------------------------
FUNCTION Select_f_fol ()

   Win_fold.m2folder.Value := GetFolder ( )

RETURN