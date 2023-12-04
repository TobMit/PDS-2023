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
select ST_ODBOR, ST_ZAMERANIE, POPIS_ODBORU, listagg( ST_ZAMERANIE, ',') within group (  order by ST_ZAMERANIE)
    from ST_ODBORY
        group by ST_ODBOR, ST_ZAMERANIE, POPIS_ODBORU;

--14. Ku každému predmetu vypíšte počet kreditov, ktoré sme prideľovali v jednotlivých akademických rokoch (tab. predmet_bod). Použite listagg.

select distinct CIS_PREDM, NAZOV, SKROK
    from PREDMET left join ZAP_PREDMETY using(cis_predm)
        order by NAZOV;

select CIS_PREDM, NAZOV, listagg( SKROK || ' - ' || ECTS, ',') within group ( order by SKROK)
    from (select distinct CIS_PREDM, NAZOV, SKROK, ECTS
            from PREDMET left join ZAP_PREDMETY using(cis_predm)
                order by NAZOV)
        group by CIS_PREDM, NAZOV;

-- 15. Pre jednotlivé predmety vypíšte zoznam katedier, ktoré daný predmet garantovali. Použite listagg.
select distinct CIS_PREDM, NAZOV, KATEDRA
    from PREDMET join PREDMET_BOD pd using (cis_predm) left join UCITEL uc on pd.GARANT = uc.OS_CISLO
        order by NAZOV;

select CIS_PREDM, NAZOV, listagg(KATEDRA, ',') within group ( order by KATEDRA)
    from (select CIS_PREDM, NAZOV, KATEDRA
            from PREDMET join PREDMET_BOD pd using (cis_predm)
                left join UCITEL uc on pd.GARANT = uc.OS_CISLO
                    order by NAZOV)
            group by CIS_PREDM, NAZOV
                order by NAZOV;

-- alebo pre neopakujúcesa zázami
select CIS_PREDM, NAZOV, listagg(KATEDRA, ',') within group ( order by KATEDRA)
    from (select distinct CIS_PREDM, NAZOV, KATEDRA
            from PREDMET join PREDMET_BOD pd using (cis_predm)
                left join UCITEL uc on pd.GARANT = uc.OS_CISLO
                    order by NAZOV)
            group by CIS_PREDM, NAZOV
                order by NAZOV;

-- 16. Vytvorte procedúru, ktorá v kurzore spracuje a vypíše osoby narodené v danom mesiaci (mesiac bude parametrom funkcie).
create or replace procedure osoby_proc (
    mesiac number
)
is
    cursor cur is (select meno, PRIEZVISKO from OS_UDAJE where mod(substr(ROD_CISLO, 3,2), 50) = mesiac);
    osoba cur%rowtype;
begin
    open cur;
        loop
            fetch cur into osoba;
            exit when cur%notfound;
            DBMS_OUTPUT.PUT_LINE(osoba.MENO || ' ' || osoba.PRIEZVISKO );
        end loop;
    close cur;
end;
/

begin
    osoby_proc(12);
end;
/

-- 17. Vytvorte funkciu, ktorá vráti rodné číslo najstaršej osoby. Ak je ich viac s rovnakým vekom, potom ich vráťte ako reťazec viacerých rodných čísel oddelených medzerou.

select 1900 + to_number(substr(ROD_CISLO, 1,2)) as vek
    from OS_UDAJE
        order by vek;

select ROD_CISLO
    from OS_UDAJE
        where to_number(substr(ROD_CISLO, 1,2)) + 1900 = (select min(1900 + to_number(substr(ROD_CISLO, 1,2)))
                            from OS_UDAJE);

select listagg(ROD_CISLO, ',') within group ( order by 1900 + to_number(substr(ROD_CISLO, 1,2)) asc)
    from OS_UDAJE
        where to_number(substr(ROD_CISLO, 1,2)) + 1900 = (select min(1900 + to_number(substr(ROD_CISLO, 1,2)))
                            from OS_UDAJE);

select *
from OS_UDAJE;

create or replace function oldest_rod_cislo return varchar2 is
    v_rod_cisla varchar2(1000);
begin
    select listagg(ROD_CISLO, ',') within group ( order by 1900 + to_number(substr(ROD_CISLO, 1,2)) asc) into v_rod_cisla
        from OS_UDAJE
            where to_number(substr(ROD_CISLO, 1,2)) + 1900 = (select min(1900 + to_number(substr(ROD_CISLO, 1,2)))
                                from OS_UDAJE);
    return v_rod_cisla;
end;
/

select meno, PRIEZVISKO
    from OS_UDAJE
        where ROD_CISLO = oldest_rod_cislo();

-- 18. Vytvorte funkciu, ktorej vstupom bude číslo predmetu. Výsledkom bude názov predmetu. Ošetrite výnimku, ak by taký predmet neexistoval.
create or replace function najst_predmet (cislo_predmetu varchar2) return varchar2 is
    nazov_predmetu varchar2(200);
begin
    select NAZOV into nazov_predmetu
        from PREDMET where CIS_PREDM like cislo_predmetu;
    return nazov_predmetu;
    exception
        when no_data_found then
            return 'Predmet neexistuje';
end najst_predmet;
/

select najst_predmet('IS09') from DUAL;

-- 19. Vytvorte funkciu, ktorej parametrom bude mesiac, návratovou hodnotou bude počet osôb narodených v danom mesiaci. Ak zadaný mesiac nie je korektný, vyvolajte výnimku a vráťte hdonotu -1.
select count (*)
    from OS_UDAJE
        where mod(to_nchar(substr(ROD_CISLO, 3, 2)), 50) = 4;

create or replace function pocet_osob_v_mesiaci(p_mesiac number) return number is
    return_pocet number;
begin
    if p_mesiac between 1 and 12 then
        select count (*) into return_pocet
            from OS_UDAJE
                where mod(to_nchar(substr(ROD_CISLO, 3, 2)), 50) = p_mesiac;
    return return_pocet;
    else
        raise_application_error(-20001, 'Zadali ste neplatny mesiac.');
        return -1;
    end if;
end;
/

select pocet_osob_v_mesiaci(4) from DUAL;

-- 20. Ku každému predmetu vypíšte 3 najlepších študentov podľa známky.

select NAZOV
    from PREDMET;

select nazov, CIS_PREDM, meno, PRIEZVISKO, VYSLEDOK, row_number() over (partition by CIS_PREDM order by VYSLEDOK) as poradie
    from OS_UDAJE join STUDENT using (rod_cislo)
        join ZAP_PREDMETY using (os_cislo) join PREDMET using (cis_predm)
                order by CIS_PREDM, poradie;

select nazov, CIS_PREDM, meno, PRIEZVISKO
    from (select nazov, CIS_PREDM, meno, PRIEZVISKO, VYSLEDOK, row_number() over (partition by CIS_PREDM order by VYSLEDOK) as poradie
    from OS_UDAJE join STUDENT using (rod_cislo)
        join ZAP_PREDMETY using (os_cislo) join PREDMET using (cis_predm)
                order by CIS_PREDM, poradie)
            where poradie <= 3
                order by NAZOV;

-- 21. Ku každému ročníku vypíšte 10% najmladších študentov.

create or replace function GetVek(p_rc char)
    return number
is
    vstupny_ret char(10);
    datum_narodenia date;
BEGIN
    vstupny_ret:=substr(p_rc, 5, 2) || '.'
                || mod(substr(p_rc, 3, 2),50)
                || '.19' || substr(p_rc, 1, 2);
    datum_narodenia:= to_date(vstupny_ret,'DD.MM.YYYY');
    return months_between(sysdate, datum_narodenia)/12;
    EXCEPTION
        when others then return -1;
end;
/

select rocnik, meno, PRIEZVISKO, ROD_CISLO, GETVEK(ROD_CISLO) as vek, row_number() over (partition by rocnik order by GETVEK(ROD_CISLO)) as riadky
    from OS_UDAJE join STUDENT using (rod_cislo)
        order by rocnik, vek;


select *
    from (select ROCNIK, meno, PRIEZVISKO, riadky
        from (select rocnik, meno, PRIEZVISKO, ROD_CISLO, GETVEK(ROD_CISLO) as vek, row_number() over (partition by rocnik order by GETVEK(ROD_CISLO)) as riadky
            from OS_UDAJE join STUDENT using (rod_cislo)
                order by rocnik, riadky)) st
        where riadky <= (select 0.1*count(*)+1 from STUDENT stu where st.rocnik = stu.ROCNIK);


-- 22. Ku každej študíjnej skupine vypíšte 2 študentov, ktorí sa zapísali v minulosti (vyhodnotenie podľa atribútu dat_zapisu).
select st_skupina, listagg(rnk || '. ' || meno || ' ' || priezvisko, ', ') within group (order by rnk, meno, priezvisko) from (
    select st_skupina, meno, priezvisko, row_number() over (partition by st_skupina order by dat_zapisu) rnk from os_udaje
    join student using(rod_cislo)
)
where rnk <= 2
group by  st_skupina;

-- 23. Ku každému odboru vypíšte 10 najlepších študentov podľa váženého študijného priemeru.
select st_odbor, listagg(os_cislo, ', ') within group (order by os_cislo) from (
select st_odbor, os_cislo, vap, row_number() over (partition by st_odbor order by vap) rnk from (
    select st_odbor, os_cislo, sum(ects * case vysledok
                    when 'A' then 1
                    when 'B' then 1.5
                    when 'C' then 2
                    when 'D' then 2.5
                    when 'E' then 3
                    else 4 end) / sum(ects) vap from student
    join zap_predmety using(os_cislo)
    group by os_cislo, st_odbor
))
where rnk <= 10
group by st_odbor;

-- 25. Vytvorte typ ako kolekciu čísel. Vytvorte tabuľku, ktorá bude obsahovať dva atribúty – rodné číslo a kolekciu osobných čísel danej osoby. Naplňte tabuľku.
create or replace type col_of_number as table of number;

create table os_student (
        rod_cislo varchar2(30),
        os_cislo col_of_number
) nested table os_cislo store as os_cisla_col;
/

insert into  os_student (select rod_cislo, cast(COLLECT(os_cislo) as col_of_number) from STUDENT group by rod_cislo);

select *
    from os_student;

-- 26. Z tabuľky vytvorenej v predchádzajúcej úlohy vymažte všetky osobné čísla, ak už študent ukončil štúdium.
update os_student
    set os_cislo = null
        where rod_cislo not in (select rod_cislo from STUDENT where ukoncenie is null);

select *
    from os_student;

-- 27. Vytvorte objektový typ, ktorý bude obsahovať číslo predmetu a názov. Doplňte metódu na triedenie podľa počtu zapísaných študentov na daný predmet.
create or replace type predme_nazov as object
(
    cis_predm char(4),
    nazov varchar2(100),

    map member function triedenie return integer
)
/

create or replace type body predme_nazov is
    map member function triedenie return integer
    is
        pocet integer;
    begin
        select count(*) into pocet from ZAP_PREDMETY z where z.CIS_PREDM like SELF.CIS_PREDM;
        return pocet;
    end;
end;
/

-- 28 Vytvorte tabuľku objektov, ktorá bude obsahovať predmety povinné v 2. ročníku bc. štúdia Informatiky (st_odbor je 100, st_zameranie je 0). Zotrieďte záznamy podľa objektu.

create table table_of_predm of predme_nazov;

delete
    from table_of_predm;

insert into table_of_predm (select distinct CIS_PREDM, NAZOV
                                from PREDMET join ST_PROGRAM using (cis_predm)
                                    where ST_ODBOR = 100 and ST_ZAMERANIE = 0 and TYP_POVIN = 'P'
                                        and CIS_PREDM in (select CIS_PREDM from STUDENT where ROCNIK = 2));

select *
    from table_of_predm t order by value(t);

-- 29. Vytvorte tabuľku, kde objekt bude ako atribút. Naplňte ju obsahom tabuľky, ktorú ste vytvorili v predchádzajúcom bode.

create table dalsia_tabulka(
    atrb predme_nazov
);
/

insert into dalsia_tabulka (select value(t) from table_of_predm t);

select *
    from dalsia_tabulka;

-- 30. Vytvorte tabuľku XML dokumentov, ktorá bude obsahovať – koreňový element predmet,
-- ktorý bude obsahovať atribút – číslo predmetu a názov. Hodnotou daného elementu bude zoznam študentov,
-- ktorí majú daný predmet zapísaný. K nim budeme evidovať tieto elementy: meno, priezvisko, rodné číslo (ktoré bude mať ako atribúit osobné číslo).

select xmlroot( XMLELEMENT(
        "predmet",
        xmlattributes(CIS_PREDM as "cis_p", NAZOV as "nazov"),
        XMLAGG(
            xmlelement(
                    "student",
                    xmlforest(
                            meno as "meno",
                            priezvisko as "priezviesko"
                        ),
                    xmlelement(
                            "rod_cislo",
                            xmlattributes(os_cislo as "os_cislo"),
                            rod_cislo
                        )
                )
            )
    ),version '1.0')  as document from predmet join zap_predmety using(cis_predm)
        join student using(os_cislo)
            join os_udaje using(rod_cislo)
                group by cis_predm, nazov
