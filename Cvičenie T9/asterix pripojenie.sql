select *
from OS_UDAJE;

create database link studentAdm
CONNECT TO student09 IDENTIFIED BY student09
using '(DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = obelix.fri.uniza.sk)(PORT = 1522))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcladm.fri.uniza.sk)
    )
  )
';
/

select * from originalTobias.moj_tabulka@studentAdm;