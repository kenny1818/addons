/*
  sistema     : ordem de servi�o
  programa    : calend�rio
  compilador  : harbour
  lib gr�fica : minigui extended
*/

#include 'minigui.ch'

FUNCTION Calendario()

   DEFINE WINDOW form_calendario ;
         AT 000, 000 ;
         WIDTH 780 ;
         HEIGHT 640 ;
         TITLE 'Calend�rio' ;
         ICON 'icone' ;
         modal ;
         NOSIZE

      @ 0, 0 monthcalendar month1

      form_calendario.month1.WIDTH := form_calendario.WIDTH
      form_calendario.month1.HEIGHT := form_calendario.HEIGHT

      ON KEY ESCAPE ACTION form_calendario.RELEASE

   END WINDOW

   form_calendario.CENTER
   form_calendario.ACTIVATE

return( nil )
