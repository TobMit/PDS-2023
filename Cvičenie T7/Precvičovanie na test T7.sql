-- 1. výpíšte predmety ktoré garantoval vždy ten istý človek
select CIS_PREDM
    from PREDMET_BOD pb join UCITEL uc on pb.GARANT = uc.OS_CISLO
        group by CIS_PREDM
            having count(distinct uc.OS_CISLO) = 1;

-- 2. výpíšte učiteľov ktorý učili najviac 2 predmety
select uc.OS_CISLO
    from UCITEL uc join ZAP_PREDMETY pred on uc.OS_CISLO = pred.PREDNASAJUCI
        group by uc.OS_CISLO
            having count(distinct CIS_PREDM) <= 2;

-- 3. vypíšte študentov, ktorý išli vždy na skúšku po viac ako 3 dňoch od zápočtu

select meno, PRIEZVISKO, rod_cislo
    from OS_UDAJE
        where ROD_CISLO in (
            select ROD_CISLO
                from STUDENT join ZAP_PREDMETY using(OS_CISLO)
                    where DATUM_SK - 3 > ZAPOCET
            )
        group by meno, PRIEZVISKO, rod_cislo
        order by MENO, PRIEZVISKO;

-- 4. vypíšte študenta ktorý má najviac áčok zo skúšok

select meno, PRIEZVISKO
    from OS_UDAJE join STUDENT st using (rod_cislo)
        where os_cislo in (select OS_CISLO
    from ZAP_PREDMETY
        where VYSLEDOK = 'A'
            group by OS_CISLO
                having count(VYSLEDOK) = (select (max(count(VYSLEDOK)))
                                            from ZAP_PREDMETY
                                                where VYSLEDOK = 'A'
                                                    group by OS_CISLO));

-- 5. pre každý odbor vypíšte roční, v ktorom je najviac študentov
select * from (
    select ST_ODBOR, ROCNIK, count(os_cislo), row_number() over (partition by ST_ODBOR order by count(os_cislo)desc ) poradie
    from ST_ODBORY join STUDENT using (st_odbor)
        group by ST_ODBOR, ROCNIK
        order by ST_ODBOR, ROCNIK
              )
    where poradie = 1;

-- 6. Vypíšte zoznam učiteľov ktorý prednášali rovanký predmet aspoň 3 roky po sebe
select MENO, PRIEZVISKO, CIS_PREDM, count(rank)
from (select meno,
             PRIEZVISKO,
             CIS_PREDM,
             SKROK,
             SKROK - rank() over (partition by CIS_PREDM order by SKROK) rank
      from UCITEL uc
               join ZAP_PREDMETY zp on uc.OS_CISLO = zp.PREDNASAJUCI
                group by meno, PRIEZVISKO, CIS_PREDM, SKROK)
        group by MENO, PRIEZVISKO, CIS_PREDM, rank
            having count(rank) >= 3
            order by CIS_PREDM;
-- 7. Vypíšte všetky osoby, k nim informácie o štúdiu – ročník a osobné číslo. V prípade, že je
-- študent tretiak na bakalárskom štúdiu alebo druhák na inžinerskom štúdiu, vypíšte aj
-- počet zapísaných predmetov (ak je bakalár, hodnota študíjneho odboru je z intervalu <100; 199>,
-- ak je inžinier, tak hodnota študíjneho odboru je z intervalu <200; 299>).

select meno, PRIEZVISKO, rocnik, os_cislo, case when rocnik = 2 and st_odbor between 100 and 199 then count(cis_predm)
                                                when rocnik = 2 and st_odbor between 200 and 299 then count(cis_predm)
                                                else null
                                                end
    from OS_UDAJE join STUDENT using (rod_cislo) join ZAP_PREDMETY using (os_cislo)
        group by meno, PRIEZVISKO, rocnik, os_cislo, st_odbor;

-- 8. Pre každý odbor vypýšte počet študentov
select ST_ODBOR, POPIS_ODBORU, sum(case when rocnik = 1 then 1 else 0 end )as pocet_prvakov,
                               sum(case when rocnik = 2 then 1 else 0 end )as pocet_druhakov,
                               sum(case when rocnik = 3 then 1 else 0 end )as pocet_tretiakov
    from ST_ODBORY join STUDENT using (st_odbor)
        group by ST_ODBOR, POPIS_ODBORU
            order by ST_ODBOR;

-- 9. Vypíšte zoznam všetkých predmetov. Ak je to predmet, ktorý má v názve slovo “data”, tak vypíšte aj počet zapísaných študentov (potlačte duplicity), inak NULL.
select NAZOV, case when NAZOV like '%data%' then count(distinct os_cislo) else null end as pocet_zakov
    from PREDMET join ZAP_PREDMETY using (cis_predm)
        group by NAZOV;

-- 10. Vygenerujte príkaz na rebuildovanie všetkých indexov – Alter index index_name rebuild;
select 'alter index'  || index_name || ' rebuild' from USER_INDEXES;

declare
    cursor curs is (select 'alter index ' || index_name || ' rebuild' from USER_INDEXES);
    line varchar(100);
begin
    open curs;
    loop
        fetch curs into line;
        exit when curs%notfound;
        DBMS_OUTPUT.PUT_LINE(line);
        --execute immediate row;
    end loop;
    close curs;
end;
/

-- 11. Vygenerujte príkaz na rekompiláciu procedúr a funkcií – Alter procedure/function name
-- compile; Na získanie zoznamu metód použite systémovú tabuľku user_procedures
-- a atribúty object_name a object_type.

select *
from USER_PROCEDURES;

select  'alter ' || object_type || ' ' || OBJECT_NAME || ' compile' from USER_PROCEDURES;

begin
    for proc in (select  OBJECT_NAME, OBJECT_TYPE from USER_PROCEDURES) loop
        execute immediate 'alter ' || proc.object_type || ' ' || proc.OBJECT_NAME || ' compile';
    end loop;
end;

-- 12. Vygenerujte príkazy na premenovanie atribútu nazov na nazov_svk vo všetkých tabuľkách
--alter table os_udaje rename column rod_cislo to rod_cislo;
select *
from USER_TABLES;

select *
    from USER_TAB_COLUMNS
        order by TABLE_NAME;

select table_name, column_name
    from USER_TABLES join USER_TAB_COLUMNS using (table_name)
        where LOWER(COLUMN_NAME) = 'nazov';

select 'alter table ' || table_name || ' rename column ' || column_name || ' to nazov_svk;'
    from USER_TABLES join USER_TAB_COLUMNS using (table_name)
        where LOWER(COLUMN_NAME) = 'nazov';

declare
    cursor cur is (select 'alter table ' || table_name || ' rename column ' || column_name || ' to nazov_svk;'
                    from USER_TABLES join USER_TAB_COLUMNS using (table_name)
                        where LOWER(COLUMN_NAME) = 'nazov');
    row varchar2(100);
begin
    open cur;
    loop
        fetch cur into row;
        exit when cur%notfound;
        DBMS_OUTPUT.PUT_LINE(row);
        --execute immediate row;
    end loop;
    close cur;
end;

--13. Vypíšte ku každému odboru zoznam jednotlivých zameraní. Použite agregačnú funkciu listagg
