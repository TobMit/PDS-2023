--vypísať študentov s najviac získanými bodmi podľa štúdijného programu
select st_odbor, POPIS_ODBORU, MENO, PRIEZVISKO, rod_cislo
from (select st_odbor,
             POPIS_ODBORU,
             MENO,
             PRIEZVISKO,
             rod_cislo,
             row_number() over (partition by st_odbor order by sucet) as pozicia
      from (select st_odbor, POPIS_ODBORU, meno, priezvisko, rod_cislo, sum(ects) as sucet
            from ST_ODBORY
                     join STUDENT using (st_odbor)
                     join OS_UDAJE using (rod_cislo)
                     join ZAP_PREDMETY using (os_cislo)
            group by st_odbor, POPIS_ODBORU, meno, rod_cislo, priezvisko))
where pozicia = 1;

-- predmet, ktorý bol najmenej vyberaný študentami zo štúdijných programov / odborov (berú sa aj predmety, ktoré nemali zapísaných žiadnych študentov)

select *
from (select CIS_PREDM, NAZOV, pocet, dense_rank() over (order by pocet) as pozicia
      from (select CIS_PREDM, NAZOV, (select count(*) from zap_predmety zp where zp.cis_predm = p.CIS_PREDM) as pocet
            from PREDMET p))
where pozicia = 1;

-- alebo

select *
from (select CIS_PREDM,
             NAZOV,
             dense_rank() over ( order by (select count(*)
                                           from zap_predmety zp
                                           where zp.cis_predm = p.CIS_PREDM)) as pozicia
      from PREDMET p)
where pozicia = 1
order by CIS_PREDM;
-- alebo
select CIS_PREDM, NAZOV, count(OS_CISLO) as pocet
from PREDMET p
         left join ZAP_PREDMETY using (cis_predm)
group by CIS_PREDM, NAZOV
having count(OS_CISLO) = 0
order by pocet, CIS_PREDM;

-- z každého ročníka vypísať počet žien a počet mužov

select rocnik,
       sum(case when substr(rod_cislo, 3, 1) = 0 or substr(rod_cislo, 3, 4) = 1 then 1 else 0 end) as pocet_muzov,
       sum(case when substr(rod_cislo, 3, 1) = 5 or substr(rod_cislo, 3, 4) = 6 then 1 else 0 end) as pocet_zien
from STUDENT
group by rocnik
order by rocnik;

-- Vypísať 5 najstarších študentov z každého odboru.

select *
from (select st_odbor,
             ROD_CISLO,
             MENO,
             PRIEZVISKO,
             vek,
             row_number() over (partition by st_odbor order by floor(months_between(sysdate, datum_narodenia) / 12) desc ) as poradie
      from (select distinct st_odbor,
                            ROD_CISLO,
                            MENO,
                            PRIEZVISKO,
                            datum_narodenia,
                            floor(months_between(sysdate, datum_narodenia) / 12) as vek
            from (select ROD_CISLO,
                         MENO,
                         PRIEZVISKO,
                         to_date(substr(ROD_CISLO, 5, 2) || '.' ||
                                 (case
                                      when TO_NUMBER(substr(ROD_CISLO, 3, 1)) > 1
                                          then to_number(substr(ROD_CISLO, 3, 1)) - 5
                                      else to_number(substr(ROD_CISLO, 3, 1)) end) ||
                                 substr(ROD_CISLO, 4, 1) || '.' || (case
                                                                        when to_number(substr(ROD_CISLO, 0, 2)) > 50
                                                                            then 19 || substr(ROD_CISLO, 0, 2)
                                                                        else 20 || substr(ROD_CISLO, 0, 2) end)
                             , 'DD.MM.YYYY') as datum_narodenia
                  from OS_UDAJE)
                     join STUDENT using (rod_cislo)))
where poradie <= 5
order by st_odbor;
;

-- Pre každý ročník vypísať 10 % študentov s najhoršími známkami (podľa priemeru známok).
select *
from (select rocnik,
             rod_cislo,
             meno,
             PRIEZVISKO,
             os_cislo,
             priemer,
             row_number() over (partition by rocnik order by priemer desc) as poradie
      from (select rocnik,
                   rod_cislo,
                   meno,
                   priezvisko,
                   OS_CISLO,
                   (select sum(
                                   case VYSLEDOK
                                       when 'A' then 1
                                       when 'B' then 1.5
                                       when 'C' then 2
                                       when 'D' then 3
                                       when 'E' then 3.5
                                       else 4
                                       end
                               )
                    from ZAP_PREDMETY zp
                    where zp.OS_CISLO = s.OS_CISLO) /
                   (select count(*) from ZAP_PREDMETY zp where zp.OS_CISLO = s.OS_CISLO) as priemer
            from OS_UDAJE
                     join STUDENT s using (rod_cislo))
      order by rocnik) s
where poradie <= ((select count(*) from STUDENT st where st.ROCNIK = s.rocnik) / 10) + 1

-- vytvoriť index nad tabuľkou študent
create index student_index on student (rod_cislo);
-- vytvoriť index nad tabuľkou osoba
create index osoba_index on os_udaje (MENO);

-- vyvoriť objekty typu osoba
-- vytvoriť tabuľku osôb (osoba bude objektový atribút) a do tejto tabuľky vložiť mužov a ženy z tabuľky os_udaje, pričom muž a žena budú podtyp osoby
-- potriediť ich napríklad podľa dátumu narodenia

create or replace type osoba_obj as object
(
    meno       varchar2(30),
    priezvisko varchar2(30),
    rod_cislo  varchar2(11)
)
/;

create or replace type muz_obj under osoba_obj;
create or replace type zena_ojb under osoba_obj;

create table osoba_tab
(
    rod_cislo varchar2(11) primary key,
    osoba     osoba_obj
);
/

create table osoba_tab2 of osoba_obj;


insert into osoba_tab2
select osoba_obj(meno, PRIEZVISKO, rod_cislo)
from OS_UDAJE;

select rod_cislo, ot.osoba.MENO, ot.osoba.PRIEZVISKO, ot.osoba.ROD_CISLO
from osoba_tab ot
order by ot.osoba.ROD_CISLO;

-- vytvoriť tabuľku s id typu integer a JSON atribútom obsahujúcim meno, priezvisko,
-- rodné číslo študenta a ako pole obsahovať všetky dokončené skúšky ktoré bude obsahovať názov a známku daného predmetu .
-- vypíšte s tabuľky s úlohy 1 všetkých študentov a jeho dokončene predmety s poľa.

create table json_table
(
    id       integer,
    json_obj clob check ( json_obj is json)
)
/

create sequence json_table_seqence
    increment by 1
    start with 1;


-- noinspection SqlInsertValues
insert into json_table
select ROWNUM, jsonObj
from (select JSON_OBJECT(
                     'meno' value meno,
                     'priezvisko' value PRIEZVISKO,
                     'rod_cislo' value ROD_CISLO,
                     'ukoncene_predmety' value json_arrayagg(
                             JSON_OBJECT(
                                     'nazov_predmetu' value NAZOV,
                                     'znamka' value VYSLEDOK
                                 )
                         )
                 ) as jsonobj
      from os_udaje
               left join STUDENT using (rod_cislo)
               left join ZAP_PREDMETY using (os_cislo)
               join PREDMET using (cis_predm)
      where ECTS > 0
      group by MENO, PRIEZVISKO, rod_cislo);

select row meno, PRIEZVISKO, rod_cislo
from os_udaje;

select *
from json_table
order by id;

delete from json_table;

-- zmeniť text v zadanej tabuľke z typu long na typ clob

create table test_table (
    id integer primary key,
    text long
);
/

create table test_table_new (
    id integer primary key,
    text clob
);
/

insert into test_table_new (id, text) SELECT id, to_lob(text) from test_table;

drop table test_table;
drop table test_table_new;

-- zmeniť LOB z basicfile na secretfile (nastaviť ktorýkoľvek z troch atribútov secretfile)

-- Zmena typu stĺpca LOB z BASICFILE na SECUREFILE
ALTER TABLE my_table MODIFY LOB (my_lob_column) (SECUREFILE);

-- Alebo môžete nastaviť konkrétny atribút SECUREFILE, napríklad:
-- ALTER TABLE my_table MODIFY LOB (my_lob_column) (CACHE);
-- ALTER TABLE my_table MODIFY LOB (my_lob_column) (NOLOGGING);
-- ALTER TABLE my_table MODIFY LOB (my_lob_column) (COMPRESS HIGH);


-- vygenerujte toľko náhodných čísel koľko je záznamov v tabuľke os_udaje
select DBMS_RANDOM.VALUE() from DUAL connect by LEVEL <= (select count(*) from OS_UDAJE);

select level from dual connect by level <= 5; -- level toto vypíše čísla od 1 do 5


-- Vygenerujte kalendár pre posledných 5 rokov, berte do úvahy priestupné roky.
select sysdate - (level - 1) datum
    from dual
        connect by level <= (5 * 365) + 1
            order by sysdate - (level - 1);

select * from PERSON_REC;

 -- budem chcieť vypýsať v hierarchý rodokemna tak si to budem posúvať medzerami z ľava pomocou rekurzie

select lpad(' ', 4*level) || NAME || ' ' || 'priezvisko' as mena
    from PERSON_REC
        connect by prior PERSON_ID = MOTHER_ID;

-- Vypisat studentov v XML (meno, priezvisko, os_cislo), a zoznam predmetov ktore studuju. (pole musi obsahovat element aj atribut)
-- Vypisat studentov a ake znamky dostali v XML.

create table xmlTest of xmltype;

insert into xmlTest select xmlroot(
    XMLELEMENT(
        "student",
        xmlforest(
            meno as "meno",
            PRIEZVISKO as "PRIEZVISKO"
            ),
            xmlelement(
                "zap_premd",
                XMLAGG(
                    XMLELEMENT(
                        "cislo_predm",
                        CIS_PREDM
                        )
                )
            )
        )
    , version '1.0')
        from OS_UDAJE join STUDENT using(rod_cislo) join ZAP_PREDMETY using (os_cislo)
            group by meno, PRIEZVISKO, os_cislo;


select extractvalue(value(t),'/student/meno') as meno,
       extractvalue(value(t),'/student/PRIEZVISKO') as priezvisko,
       listagg(extractvalue(zapp.column_value, 'cislo_predm') || ', ') within group (order by extractvalue(value(t),'/student/meno')) as cislo_predm
    from xmlTest t, table (XMLSEQUENCE(extract(value(t), '/student/zap_premd/cislo_predm'))) zapp
        group by extractvalue(value(t),'/student/meno'), extractvalue(value(t),'/student/PRIEZVISKO');

select meno, PRIEZVISKO, os_cislo, listagg(CIS_PREDM || ', ') within group ( order by meno,PRIEZVISKO, os_cislo)
    from OS_UDAJE join STUDENT using(rod_cislo) join ZAP_PREDMETY using (os_cislo)
        group by meno, PRIEZVISKO, os_cislo;


-- Vytvor tabulku, ktorá bude mať vzťah s predmetom. Do tejto tabulky budeme ukladat bloby (pdfka, word dokumenty, obrázky a podobne).
-- V hore vytvorenej tabulke, najdi 3 predmety, ktoré spolu zaberajú najväčšiu kapacitu a vypíš ich.

create table loby_table(
    id integer primary key,
    pripona varchar2(5),
    subor blob
);
/

drop table loby_table;

-- Kvet analytika
create table basketbal(stvrtina integer, cas date, hrac varchar(20), body integer);
insert into basketbal values(1, sysdate-3/24, 'Michal', 1);
insert into basketbal values(1, sysdate-3/24, 'Marek',  2);
insert into basketbal values(1, sysdate-3/24, 'Peter',  3);
insert into basketbal values(1, sysdate-3/24, 'Martin', 2);
insert into basketbal values(1, sysdate-3/24, 'Martin', 2);
insert into basketbal values(1, sysdate-3/24, 'Stefan', 3);
insert into basketbal values(1, sysdate-3/24, 'Karol',  1);
insert into basketbal values(1, sysdate-3/24, 'Karol',  1);



insert into basketbal values(2, sysdate-2/24, 'Marek',   1);
insert into basketbal values(2, sysdate-2/24, 'Peter',   2);
insert into basketbal values(2, sysdate-2/24, 'Pavol',   1);
insert into basketbal values(2, sysdate-2/24, 'Michal',  1);
insert into basketbal values(2, sysdate-2/24, 'Michal',  3);
insert into basketbal values(2, sysdate-2/24, 'Stefan',  3);
insert into basketbal values(2, sysdate-2/24, 'Marek',   2);
insert into basketbal values(2, sysdate-2/24, 'Michal',  1);



insert into basketbal values(3, sysdate-1/24, 'Stefan',   1);
insert into basketbal values(3, sysdate-1/24, 'Peter',   2);
insert into basketbal values(3, sysdate-1/24, 'Karol',   1);
insert into basketbal values(3, sysdate-1/24, 'Marek',   2);
insert into basketbal values(3, sysdate-1/24, 'Michal',  1);



insert into basketbal values(4, sysdate, 'Karol',  1);
insert into basketbal values(4, sysdate, 'Karol',  3);
insert into basketbal values(4, sysdate, 'Stefan',  3);
insert into basketbal values(4, sysdate, 'Marek',   2);
insert into basketbal values(4, sysdate, 'Michal',  1);

--Vypíšte počet bodov pre každého hráča a každú štvrtinu (každú, aj tú, v ktorej nehral).

select stvrtina, hrac,
       sum(body) as sucet_bodov
            from basketbal
                group by stvrtina, hrac
                order by stvrtina, sucet_bodov;
--Vypíšte poradie hráčov podľa výsledkov.
select hrac,
       sum(body) as sucet_bodov,
        row_number() over (order by sum(body) desc ) as poradie
            from basketbal
                group by hrac
                order by poradie;
--Aký rank by mal hráč, ktorý získal 7 bodov?
select distinct rank
    from (
        select hrac,
           sum(body) as sucet_bodov,
            rank() over (order by sum(body) desc ) as rank
                from basketbal
                    group by hrac
                    order by rank
         )
            where sucet_bodov = 7;
--Vypíšte podpriemerných hráčov v zápase.
select hrac, sucet_bodov, rank,
       (select sum(body_hrac) from (select sum(body) as body_hrac from basketbal b group by b.hrac)) as celkovy_pocet_bodov,
       (select count(distinct hrac) from basketbal) as pocet_hracov
    from (
        select hrac,
           sum(body) as sucet_bodov,
            rank() over (order by sum(body) desc ) as rank
                from basketbal
                    group by hrac
                    order by rank
         )
            where sucet_bodov < ceil(
                (select sum(body_hrac) from (select sum(body) as body_hrac from basketbal b group by b.hrac)) /
                (select count(distinct hrac) from basketbal)
                );

select sum(body) from (select sum(body) as body from basketbal b group by b.hrac);

--Z predchádzajúceho bodu vyrobte JSON pole.
select json_object(
        'hrac' value hrac,
        'sucet_bodov' value sucet_bodov
           )
    from (
        select hrac,
           sum(body) as sucet_bodov,
            rank() over (order by sum(body) desc ) as rank
                from basketbal
                    group by hrac
                    order by rank
         )
            where sucet_bodov < ceil(
                (select sum(body_hrac) from (select sum(body) as body_hrac from basketbal b group by b.hrac)) /
                (select count(distinct hrac) from basketbal)
                );

create table test_table_name  (id integer);/
create table test_table_name2  (id integer);/
create table test_table_name3  (id integer);/
create table test_table_name4  (id integer);/

alter table test_table_name rename to mitala1_test_table_name;
select *
    from USER_TABLES
        where user like 'MITALA1' and TABLE_NAME like '%TEST_TABLE%';

select 'alter table ' || table_name || ' rename to ' || 'MITALA1_' || table_name || ';'
    from USER_TABLES
        where user like 'MITALA1' and TABLE_NAME like '%TEST_TABLE%';

-- Uveďte príklad, v ktorom bude metóda Index Range Scan poskytovať horšie výsledky ako Table Access Full z pohľadu nákladov a doby spracovania.
    -- keď pristupujeme k takmer celej tabuľke a v tedy ten index musel prechádzať od jedného k druhému

-- hinty
-- select /*+ Index(table_name index_name) */

-- Ku každému študentovi uchovávajte kolekciu predmetov, ktoré mal zapísané. Pre predmet evidujte názov, číslo predmetu, známku a dátum skúšky.
-- Pri výpise predmetov ich trieďte podľa priezviska garanta.