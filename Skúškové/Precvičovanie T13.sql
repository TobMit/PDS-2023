-- K jednotlivým krajom Slovenskej republiky a mesiacom prvého kvartálu roku 2008 vypíšte celkovú sumu odvedenú samoplatcami.
select N_KRAJA as kraj,
    sum(case when extract(month from OBDOBIE) = 1 then SUMA else 0 end) as "1. mesiac",
    sum(case when extract(month from OBDOBIE) = 2 then SUMA else 0 end) as "2. mesiac",
    sum(case when extract(month from OBDOBIE) = 3 then SUMA else 0 end) as "3. mesiac"
    from P_KRAJ
        left join p_okres using(id_kraja)
        join p_mesto using (id_okresu)
        join P_OSOBA using (psc)
        join P_POISTENIE p using (rod_cislo)
        join P_ODVOD_PLATBA using (id_poistenca)
            where ROD_CISLO = ID_PLATITELA and extract(year from OBDOBIE) = 2008
                group by N_KRAJA, ID_KRAJA;

-- Vypíšte názvy typov príspevkov, ktoré NEBOLI vyplácané minulý kalendárny mesiac. Použite EXISTS.
select *
    from P_TYP_PRISPEVKU t
        where not exists(
            select 'x'
                from P_PRISPEVKY p
                    where t.ID_TYPU = p.ID_TYPU
                      and extract(month from OBDOBIE) = extract(month from add_months(sysdate, -1))
                      and extract(year from OBDOBIE) = extract(year from sysdate)
        );

-- Vypíšte kraje, kde býva viac žien ako mužov.
select NAZOV
    from (
        select N_KRAJA as nazov,
           sum(case when substr(ROD_CISLO, 3,1) between 0 and 1 then 0 else 1 end) as zeny,
           sum(case when substr(ROD_CISLO, 3,1) between 0 and 1 then 1 else 0 end) as muzi
            from P_KRAJ
                join P_OKRES using (id_kraja)
                join P_MESTO using (id_okresu)
                join P_OSOBA using (psc)
                    group by N_KRAJA
         )
        where zeny > muzi;

-- Horizontálne fragmentujte aspoň na 3 fragmenty reláciu P_PRISPEVKY podľa typu príspevku.
DEFINE FRAGMENT P1 as select * from P_PRISPEVKY where ID_TYPU = 1;
DEFINE FRAGMENT P2 as select * from P_PRISPEVKY where ID_TYPU = 2;
DEFINE FRAGMENT P3 as select * from P_PRISPEVKY where ID_TYPU > 2;

-- Ku každému držiteľovi ZTP vypíšte sumu príspevkov, ktoré dostal za minulý kalendárny rok.
select ID_ZTP, meno, priezvisko, ROD_CISLO,
       sum(case when extract(year from KEDY) = (extract(year from sysdate) - 1) then SUMA else 0 end) as suma
    from P_OSOBA join P_ZTP using (rod_cislo)
        left join P_POBERATEL using (rod_cislo)
        join P_PRISPEVKY using (id_poberatela)
            group by ID_ZTP,meno, PRIEZVISKO, ROD_CISLO;

-- K jednotlivým názvom zamestnávateľov a kvartálom minulého roka vypíšte počet prijatých osôb do zamestnania.

select to_number(to_char(sysdate, 'Q')) from dual; -- takto sa zýska quartál

select ICO, NAZOV,
       sum(case when to_number(to_char(DAT_OD, 'Q')) = 1 then 1 else 0 end) as "1. kvartal",
       sum(case when to_number(to_char(DAT_OD, 'Q')) = 2 then 1 else 0 end) as "2. kvartal",
       sum(case when to_number(to_char(DAT_OD, 'Q')) = 3 then 1 else 0 end) as "3. kvartal",
       sum(case when to_number(to_char(DAT_OD, 'Q')) = 4 then 1 else 0 end) as "4. kvartal"
    from P_ZAMESTNAVATEL firm join P_ZAMESTNANEC zam on firm.ICO = zam.ID_ZAMESTNAVATELA
        where extract(year from DAT_OD) = extract(year from sysdate) - 1
            group by ICO, NAZOV;


-- Pre každý okres vypíšte osobu, ktorá bola poistencom najdlhšie. Ak bola evidovaná viackrát, intervaly sčítajte.
select N_OKRESU, MENO, PRIEZVISKO, ROD_CISLO
    from (
        select osoba.*, row_number() over (partition by okr.ID_OKRESU order by trvanie desc) as poradie, okr.N_OKRESU
            from (
                select psc, MENO, PRIEZVISKO, ROD_CISLO,
                        sum(nvl(DAT_DO, sysdate) - DAT_OD) as trvanie
                    from P_OSOBA join P_POBERATEL using (rod_cislo)
                        group by psc, MENO, PRIEZVISKO, ROD_CISLO
                 ) osoba join P_MESTO mes on osoba.PSC = mes.PSC
                    join P_OKRES okr on mes.ID_OKRESU = okr.ID_OKRESU
         )
    where poradie = 1;

-- Pomocou SQL príkazu generujte príkazy na pridelenie práva "create any directory" všetkým užívateľom z predmetu II07 v šk. roku 2005.

select distinct 'grant create any director to ' || ROD_CISLO || ';'
    from OS_UDAJE join STUDENT using (rod_cislo)
        join ZAP_PREDMETY using (os_cislo)
            where CIS_PREDM like '%II07%' and SKROK = 2005;

-- Pre jednotlivé mestá Nitrianskeho kraja vypíšte percentuálne rozloženie mužov a žien.
select N_MESTA,
       (pocet_zien * 100) / pocet_ludi ||'%' as perceno_zeny,
       (pocet_muzov * 100) / pocet_ludi ||'%' as percento_muzi
    from (
        select N_MESTA,
               sum(case when substr(ROD_CISLO, 3,1) between 0 and 1 then 0 else 1 end) as pocet_zien,
               sum(case when substr(ROD_CISLO, 3,1) between 0 and 1 then 1 else 0 end) as pocet_muzov,
               count(ROD_CISLO) as pocet_ludi
            from P_MESTO join P_OKRES using (id_okresu)
                        join P_KRAJ using (id_kraja)
                        join P_OSOBA using (psc)
                where N_KRAJA like '%Nitria%'
                    group by N_MESTA
         );

-- Vypíšte 5% obyvateľov s najväčšími odvodmi do poisťovne pre každé mesto osobitne.
select os.*
    from (
        select o.*, row_number() over (partition by N_MESTA order by odvod desc ) as poradie
            from (
                select N_MESTA, meno, PRIEZVISKO, ROD_CISLO, sum(suma) as odvod
                    from P_MESTO join P_OSOBA using (psc)
                        join p_poistenie using (rod_cislo)
                        join P_ODVOD_PLATBA using (id_poistenca)
                            group by N_MESTA, meno, PRIEZVISKO, ROD_CISLO
                 ) o
         ) os where poradie <= 1+((select count(distinct ROD_CISLO)
                                    from P_MESTO join P_OSOBA using (psc)
                                        join P_POISTENIE using (rod_cislo)
                                        join P_ODVOD_PLATBA using (id_poistenca)
                                        where P_MESTO.N_MESTA = os.N_MESTA)*0.05);

-- Vertikálne fragmentujte reláciu P_PRISPEVKY aspoň na 2 fragmenty.
-- Fragment 1
CREATE TABLE P_PRISPEVKY_Fragment1 AS
    SELECT ID_POBERATELA, OBDOBIE, ID_TYPU
        FROM P_PRISPEVKY;

select *
    from P_PRISPEVKY_FRAGMENT1;

-- Fragment 2
CREATE TABLE P_PRISPEVKY_Fragment2 AS
    SELECT ID_POBERATELA, KEDY, SUMA
        FROM P_PRISPEVKY;


