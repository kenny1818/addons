/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * Copyright 2021 Verchenko Andrey <verchenkoag@gmail.com>
 *
*/

#include "minigui.ch"
#include "tsbrowse.ch"

///////////////////////////////////////////////////////////////////////////////
FUNCTION myTableBackColor(nI)   // ����� ���� ��� ������
   LOCAL aTblBClr

   aTblBClr := { { 159, 191, 236 } , { 255, 178, 178 } , { 195, 224, 133 } ,;
                 { 178, 135, 214 } , { 250, 253, 214 } }

RETURN aTblBClr[nI]

///////////////////////////////////////////////////////////////////////////////
FUNCTION myTableButtonUp(nI)           // ������ ����� �����
   LOCAL a4Dim, aBtnCap, aBtnIco, aBtnClr, aBtnPst

   aBtnCap := { "������", "��������", "�����", "������", "���������", "�����" }

   aBtnIco := { {"iHelp128x1"   , "iHelp128x2"   } ,;
                {"iReport128x1" , "iReport128x2" } ,;
                {"iSeach128x1"  , "iSeach128x2"  } ,;
                {"iPrint128x1"  , "iPrint128x2"  } ,;
                {"iConfig128x1" , "iConfig128x2" } ,;
                {"iExit128x1"   , "iExit128x2"   }     }

   aBtnClr := { { 231, 178,  30 }  ,;   // 1   ������
                {  64, 108, 106 }  ,;   // 2   ��������
                {   0, 176, 240 }  ,;   // 3   �����
                {  94,  59, 185 }  ,;   // 4   ������
                {  40, 122, 237 }  ,;   // 5   ���������
                { 189,  30,  73 }  }    // 6   �����

   aBtnPst := { 10, 11, 12, 13, 14, 90 } // _wPost(�) - ����� ������� �� ������

   IF     nI == 1    // ���� 1
       aBtnCap := {"Help", "Card", "Search", "Print", "Settings", "Exit"}
   ELSEIF nI == 2    // ���� 2
       aBtnCap := {"��������", "������", "�����", "����", "������������", "�����"}
   ELSEIF nI == 3    // ���� 3
   ELSEIF nI == 4    // ���� 4
       // ������� ��� ������ � �������� �������
       AINS(aBtnCap, 3, '������'                , .T. )
       AINS(aBtnIco, 3, {"iDebug64","iDebug64"} , .T. )
       AINS(aBtnClr, 3, LGREEN                  , .T. )
       AINS(aBtnPst, 3, 50                      , .T. )
   ELSEIF nI == 5    // ���� 5
       // ������� ��� ������ � �������� �������
       AINS(aBtnCap, 3, '���� 1'                , .T. )
       AINS(aBtnIco, 3, {"iDebug64","iDebug64"} , .T. )
       AINS(aBtnClr, 3, LGREEN                  , .T. )
       AINS(aBtnPst, 3, 51                      , .T. )
       // ������� ��� ������ � �������� �������
       AINS(aBtnCap, 4, '���� 2'                , .T. )
       AINS(aBtnIco, 4, {"iDebug64","iDebug64"} , .T. )
       AINS(aBtnClr, 4, ORANGE                  , .T. )
       AINS(aBtnPst, 4, 52                      , .T. )
   ENDIF

   a4Dim := { aBtnCap, aBtnIco, aBtnClr, aBtnPst }

RETURN a4Dim

///////////////////////////////////////////////////////////////////////////////
FUNCTION myTableUse(nI)           // ����
   LOCAL a3Dim

   IF     nI == 1    // ���� 1
      a3Dim := { "Customer.dbf"  , "CUSTOM" , "EN"     }
   ELSEIF nI == 2    // ���� 2
      a3Dim := { "street-ukr.dbf", "STREET" , "UA1251" }
   ELSEIF nI == 3    // ���� 3
      a3Dim := { "Oborud.dbf"    , "OBORUD3", "RU866"  }
   ELSEIF nI == 4    // ���� 4
      a3Dim := { "Oborud.dbf"    , "OBORUD4", "RU866"  }
   ELSEIF nI == 5    // ���� 5
      a3Dim := { "Oborud.dbf"    , "OBORUD5", "RU866"  }
   ENDIF

RETURN a3Dim

///////////////////////////////////////////////////////////////////////////////
FUNCTION myTableDatos(nI,nParam)
   LOCAL aDatos, aHead, aFSize, aFoot, aPict, aAlign, aName, aField, aFAlign
   LOCAL aDbf, nJ, nK, aEdit

   // aHead     // ������ ����� ������� �������
   // aFSize    // ������ ������� �������
   // aFoot     // ������ ������� ������� �������
   // aPict     // ������ PICTURE ������� �������
   // aAlign    // ������ ������� ������� �������
   // aName     // ������ ����� ���� ������� �������
   // aField    // ������ ����� ���� ������� �������
   // aFAlign   // ������ ������� ������� ������� �������

   aFSize := NIL    //  ������ ����� ������� �������� ��� tsbrowse
   aDbf   := {}

   IF     nI == 1    // ���� 1 - Customer.dbf
      AADD( aDbf, { "CUSTNO"    , "N", 15, 0, "", .T. } )
      AADD( aDbf, { "COMPANY"   , "C", 30, 0, "", .T. } )
      AADD( aDbf, { "ADDR1"     , "C", 30, 0, "", .T. } )
      AADD( aDbf, { "ADDR2"     , "C", 30, 0, "", .T. } )
      AADD( aDbf, { "CITY"      , "C", 15, 0, "", .T. } )
      AADD( aDbf, { "STATE"     , "C", 20, 0, "", .T. } )
      AADD( aDbf, { "ZIP"       , "C", 10, 0, "", .T. } )
      AADD( aDbf, { "COUNTRY"   , "C", 20, 0, "", .T. } )
      AADD( aDbf, { "PHONE"     , "C", 15, 0, "", .T. } )
      AADD( aDbf, { "FAX"       , "C", 15, 0, "", .T. } )
      AADD( aDbf, { "TAXRATE"   , "N", 19, 4, "", .T. } )
      AADD( aDbf, { "CONTACT"   , "C", 20, 0, "", .T. } )
      AADD( aDbf, { "LASTINVOIC", "C", 30, 0, "", .T. } )

   ELSEIF nI == 2    // ���� 2 - street-ukr.dbf
      AADD( aDbf, { "KSTREET", "N",  4, 0, "��� ������"  , .T.} )
      AADD( aDbf, { "STREET" , "C", 38, 0, "����� ������", .T.} )
      AADD( aDbf, { "KCITY"  , "N",  3, 0, "��� ����"   , .T.} )
      AADD( aDbf, { "TYPE"   , "C",  6, 0, "��� ������"  , .T.} )
      AADD( aDbf, { "KVIEW"  , "N",  1, 0, "��� ������"  , .T.} )

   ELSEIF nI == 3 .OR. nI == 4 .OR. nI == 5   // ���� 3,4,5 - Oborud.dbf
      AADD( aDbf, { "KOBORUD" , "N",  6, 0, "���;������."                , .F. } )
      AADD( aDbf, { "OBORUD"  , "C", 40, 0, "�������� ������������"      , .T. } )
      AADD( aDbf, { "LPRINT"  , "L",  1, 0, "���;������"                 , .T. } )
      AADD( aDbf, { "CENA_ALL", "N", 10, 2, "�����;����"                 , .T. } )
      AADD( aDbf, { "CENAOBOR", "N", 10, 2, "����;������������"          , .T. } )
      AADD( aDbf, { "CENAMAST", "N", 10, 2, "����;����������"            , .T. } )
      AADD( aDbf, { "CENASEBE", "N", 10, 2, "����;�������������"         , .T. } )
      AADD( aDbf, { "KVIEW"   , "N",  1, 0, "���;������"                 , .T. } )
      AADD( aDbf, { "LCHK"    , "L",  1, 0, "���;��������"               , .F. } )
      AADD( aDbf, { "KOPERAT" , "N",  3, 0, "Not-show"                   , .T. } )
      AADD( aDbf, { "KOB1ZAIV", "N",  3, 0, "Not-show"                   , .T. } )
      AADD( aDbf, { "KOB2WORK", "N",  3, 0, "���;������"                 , .T. } )
      AADD( aDbf, { "KOB3GRUP", "N",  3, 0, "��� ������;��������."       , .T. } )
      AADD( aDbf, { "KOLVO"   , "N",  8, 2, "���-��"                     , .T. } )
      AADD( aDbf, { "DATEPRIX", "D",  8, 0, "����;�������"               , .T. } )
      AADD( aDbf, { "SUM_ALL" , "N", 10, 2, "Not-show"                   , .F. } )
      AADD( aDbf, { "SUMOBOR" , "N", 10, 2, "Not-show"                   , .F. } )
      AADD( aDbf, { "SUMMAST" , "N", 10, 2, "Not-show"                   , .F. } )
      AADD( aDbf, { "SUMSEBE" , "N", 10, 2, "Not-show"                   , .F. } )
      AADD( aDbf, { "PRINT"   , "C",  1, 0, "Not-show"                   , .F. } )
      AADD( aDbf, { "PRINT2"  , "C",  1, 0, "Not-show"                   , .F. } )
      AADD( aDbf, { "PRINT3"  , "C",  1, 0, "Not-show"                   , .F. } )
      AADD( aDbf, { "NORMTIME", "N",  4, 0, "�����;�������"              , .T. } )
      AADD( aDbf, { "DATETIME", "@",  8, 0, "���� � �����;������ ������" , .T. } )
      AADD( aDbf, { "ID"      , "+",  4, 0, "ID (+);���������"           , .T. } )
      AADD( aDbf, { "DT"      , "=",  8, 0, "DT (=);���������-������ ������", .T. } )
      AADD( aDbf, { "DC"      , "^",  8, 0, "DC (^);���������"           , .T. } )

   ENDIF

   nK      := LEN(aDbf)
   aHead   := ARRAY(nK)
   aFoot   := ARRAY(nK)
   aPict   := ARRAY(nK)
   aName   := ARRAY(nK)
   aAlign  := ARRAY(nK)
   aField  := ARRAY(nK)
   aFSize  := ARRAY(nK)
   aFAlign := ARRAY(nK)
   aEdit   := ARRAY(nK)  // �������������� ����

   FOR nJ := 1 TO nK
      IF LEN(aDbf[nJ,5]) == 0
         aHead[ nJ ] := aDbf[nJ,1]
      ELSE
         aHead[ nJ ] := aDbf[nJ,5]
      ENDIF
      aFoot  [ nJ ] := "[ " + aDbf[nJ,1] + " ]"
      aName  [ nJ ] := aDbf[nJ,1]
      aField [ nJ ] := aDbf[nJ,1]
      aFAlign[ nJ ] := DT_CENTER
      aAlign [ nJ ] := DT_CENTER
      IF aDbf[nJ,2] == 'C' .OR. aDbf[nJ,2] == 'M'
         aAlign[ nJ ] := DT_LEFT
      ELSEIF aDbf[nJ,2] == 'N'
         aAlign[ nJ ] := DT_RIGHT
      ENDIF
      aEdit[ nJ ] := aDbf[nJ,6]
   NEXT

   aDatos := { aHead, aFSize, aFoot, aPict, aAlign, aName, aField, aFAlign, aEdit }

RETURN aDatos[nParam]
