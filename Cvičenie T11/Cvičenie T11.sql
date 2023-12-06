
-- Analytika
-- vypýsať 10% najúspešnejšich predmetov, (maju najviac A-čok)
-- ku každému odboru vypýsať 3 najoblúbenejšie predmety (najviac zapisované predmety)

select *
    from kvet3.osoba_tab;

create table osoba_tab as (select * from kvet3.osoba_tab);

select * from osoba_tab;

drop index osoba_primary_index;
--create index osoba_primary_index on osoba_tab(ROD_CISLO);
select * from USER_INDEXES where TABLE_NAME = 'OSOBA_TAB';
-- 3.
alter table osoba_tab add primary key (rod_cislo);
-- 4.
create index osoba_name_surename on osoba_tab(MENO, PRIEZVISKO);
-- 5.
create index osoba_surename_name on osoba_tab(PRIEZVISKO, meno);
-- 6.
select * from USER_INDEXES where TABLE_NAME = 'OSOBA_TAB';
-- 7.
select * from USER_CONSTRAINTS where TABLE_NAME = 'OSOBA_TAB'; -- 1.
-- 8.
select * from USER_IND_COLUMNS where TABLE_NAME = 'OSOBA_TAB';
-- 9.
create table muzy_tab as (select * from osoba_tab where substr(rod_cislo, 3, 1) <= 1);
select *
    from muzy_tab;
select * from USER_INDEXES where TABLE_NAME = 'MUZY_TAB';
    -- 0
-- 10.
explain plan for select * from osoba_tab where rod_cislo = '660227/4987';
select * from table (DBMS_XPLAN.DISPLAY);
    -- index unique scan sys..
-- 11.
explain plan for select * from osoba_tab where priezvisko like 'Jurisin';
select * from table (DBMS_XPLAN.Display);
    -- inex range scan
-- 12.
explain plan for select * from osoba_tab where meno like 'Michal';
select * from table (DBMS_XPLAN.Display);