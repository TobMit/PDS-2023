-- Napíšte najvhodnejší index pre tabuľku P_ODVOD_PLATBA pre nasledovný dotaz: select rod_cislo, meno, priezvisko,
-- sum(suma) from p_osoba JOIN p_poistenie USING ( rod_cislo ) JOIN p_odvod_platba USING ( id_poistenca ) where
-- to_char(obdobie, 'YYYY') = 2016 group by rod_cislo, meno, priezvisko
create index index_name on P_ODVOD_PLATBA(ID_POISTENCA, to_char(obdobie, 'YYYY'), SUMA);

-- K jednotlivým názvom krajom zo štátu Česko vypíšte percentuálne zloženie samoplatcom a klasických zamestnancov. (4 b):
select N_KRAJA, sum(case when ID_PLATITELA = ROD_CISLO then 1 else 0 end) / count(*) * 100 as samoplatca,
       sum(case when ID_PLATITELA != ROD_CISLO then 1 else 0 end) / count(*) * 100 as zamestnanec
    from P_KRAJ join P_KRAJINA using (id_krajiny)
            join P_OKRES using (id_kraja)
            JOIN P_MESTO USING (id_okresu)
            JOIN P_OSOBA using (PSC)
            JOIN P_POISTENIE using (rod_cislo)
    where N_KRAJINY like 'Cesko%'
        group by N_KRAJA;

-- Pre každý typ postihnutia vypíšte 3 osoby podľa dĺžky poberanie daného príspevku. Ak osoba poberala daný príspevok viackrát,
-- dobu spočítajte (p_ztp).
select *
    from (
        select pzp.*, row_number() over (partition by NAZOV_POSTIHNUTIA order by celkova_dlzka desc) as poradie
            from (
                select NAZOV_POSTIHNUTIA, meno, priezvisko, ROD_CISLO, sum(nvl(pob.dat_do, sysdate) - pob.dat_od) celkova_dlzka
                    from P_TYP_POSTIHNUTIA join P_ZTP using(id_postihnutia)
                        join p_osoba using (rod_cislo)
                        join P_POBERATEL pob using (rod_cislo)
                            group by NAZOV_POSTIHNUTIA, meno, priezvisko, ROD_CISLO
                 ) pzp
         )
            where poradie <= 3;


--Pred ktorými príkazmi začína nová transakcia? (stačí napísať čísla riadkov) -- pripojenie a vytvorenie session...
-- 1 insert into pom values (1,2,'dnes');
-- 2 SAVEPOINT sp1; 3 insert into pom ( 2,2,'vcera');
-- 4 ROLLBACK TO sp1;
-- 5 select * from pom;
-- 6 create table pom_ou as select * from os_udaje where rod_cislo like '79%';
-- 7 select * from pom_ou;
-- 8 COMMIT;
-- 9 select * from pom; (2 b):

--Pre jednotlivé mestá Nitrianskeho kraja vypíšte percentuálne rozloženie mužov a žien.
select N_MESTA, sum(case when substr(rod_cislo, 3,1) between 0 and 1 then 1 else 0 end) / count(*) * 100 as perceno_muzov,
                sum(case when substr(rod_cislo, 3,1) between 5 and 6 then 1 else 0 end) / count(*) * 100 as perceno_zien
    from P_MESTO join P_OKRES using (id_okresu)
            join P_KRAJ using (id_kraja)
            join p_osoba using (psc)
                where N_KRAJA like 'Nitrians%'
                    group by N_MESTA;

