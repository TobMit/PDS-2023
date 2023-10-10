-- študenti ktorý sú študentmi + "dešifrovať" umiestnenie a zotried podla mena, priezviska a čisl skupiny
select meno, PRIEZVISKO, ukoncenie, rocnik, case substr(stud.st_skupina, 2,1)
            when 'Z' then 'Zilina'
            when 'P' then 'Prievidza'
            when 'R' then  'Ruzomberok'
        end
    from OS_UDAJE os join STUDENT stud on stud.ROD_CISLO = os.ROD_CISLO
        where stud.UKONCENIE is null
            order by meno, PRIEZVISKO, st_skupina;

-- vypis mena ucitelov ktoré nem žiadny študent

select meno, PRIEZVISKO
    from UCITEL
        where not exists(select 'x'
                            from ZAP_PREDMETY);

-- select výpis priezviska učiteľa ktorý nemá žiadneho menovca medzi študentmi
select PRIEZVISKO
    from UCITEL
        where not exists(select 'x'
                          from STUDENT st join OS_UDAJE os on st.ROD_CISLO = os.ROD_CISLO
                            where os.PRIEZVISKO = UCITEL.PRIEZVISKO);

-- predmety ktoré neboli zapísane
select NAZOV
    from PREDMET
        where not exists(select 'x'
                          from ZAP_PREDMETY
                            where PREDMET.CIS_PREDM = ZAP_PREDMETY.CIS_PREDM);

--mená ludí ktorý sa narodil v decembr
select MENO, PRIEZVISKO
    from OS_UDAJE
        where substr(ROD_CISLO, 3,2) = 62 or substr(ROD_CISLO, 3,2) = 12;

-- vypise os cislo studenta ktory ma predmet s 3 a
select *
    from STUDENT st
        join ZAP_PREDMETY zp on st.OS_CISLO = zp.OS_CISLO
            join PREDMET prd on zp.CIS_PREDM = prd.CIS_PREDM
                where NAZOV like 'a%a%a';