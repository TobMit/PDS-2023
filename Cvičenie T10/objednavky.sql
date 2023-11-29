--------------------------------------------------------
--  File created - Pondelok-novembra-16-2023   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table OBJEDNAVKY
--------------------------------------------------------

  CREATE TABLE OBJEDNAVKY  
   (	ID_ZAK NUMBER(*,0), 
	MENO_ZAK VARCHAR2(20 CHAR), 
	ID_OBJ NUMBER(*,0), 
	ID_PROD NUMBER(*,0), 
	NAZOV_PROD VARCHAR2(20 CHAR), 
	MNOZSTVO NUMBER
   ) ;
--------------------------------------------------------
--  DDL for Table OBJEDNAVKY2
--------------------------------------------------------

  CREATE TABLE OBJEDNAVKY2  
   (	ID_ZAK NUMBER(*,0), 
	MENO_ZAK VARCHAR2(20 CHAR), 
	ID_OBJ NUMBER(*,0), 
	ID_PROD NUMBER(*,0), 
	NAZOV_PROD VARCHAR2(20 CHAR), 
	MNOZSTVO NUMBER
   ) ;
REM INSERTING into OBJEDNAVKY
SET DEFINE OFF;
Insert into OBJEDNAVKY (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('50042','Peter Sedlacek','421','4280','Tehly-paleta','110');
Insert into OBJEDNAVKY (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('50042','Peter Sedlacek','421','6520','Dlazobne kocky','140');
REM INSERTING into OBJEDNAVKY2
SET DEFINE OFF;
Insert into OBJEDNAVKY2 (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('51069','Emil Krsak','422','4280','Tehly-paleta','80');
Insert into OBJEDNAVKY2 (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('51069','Emil Krsak','422','6520','Dlazobne kocky','80');
Insert into OBJEDNAVKY2 (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('50741','Stefan Toth','423','4280','Tehly-paleta','60');
Insert into OBJEDNAVKY2 (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('50741','Stefan Toth','423','6520','Dlazobne kocky','40');
--------------------------------------------------------
--  Constraints for Table OBJEDNAVKY
--------------------------------------------------------

  ALTER TABLE OBJEDNAVKY MODIFY (MENO_ZAK NOT NULL ENABLE);
  ALTER TABLE OBJEDNAVKY MODIFY (ID_PROD NOT NULL ENABLE);
  ALTER TABLE OBJEDNAVKY MODIFY (NAZOV_PROD NOT NULL ENABLE);
  ALTER TABLE OBJEDNAVKY MODIFY (MNOZSTVO NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table OBJEDNAVKY2
--------------------------------------------------------

  ALTER TABLE OBJEDNAVKY2 MODIFY (MENO_ZAK NOT NULL ENABLE);
  ALTER TABLE OBJEDNAVKY2 MODIFY (ID_PROD NOT NULL ENABLE);
  ALTER TABLE OBJEDNAVKY2 MODIFY (NAZOV_PROD NOT NULL ENABLE);
  ALTER TABLE OBJEDNAVKY2 MODIFY (MNOZSTVO NOT NULL ENABLE);
