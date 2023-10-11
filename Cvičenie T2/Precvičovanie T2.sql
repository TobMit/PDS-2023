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

---- soc poisťovňa ------
-- Vypíšte koľko zamestnanocov má zamestávateľ Tesco.
select nazov, count(*) as Pocet_Zamestnancov
    from P_ZAMESTNANEC join P_ZAMESTNAVATEL on P_ZAMESTNANEC.ID_ZAMESTNAVATELA = P_ZAMESTNAVATEL.ICO
        where NAZOV = 'Tesco'
            group by nazov;

-- alebo len výpis
select count(*) as Pocet_Zamestnancov
    from P_ZAMESTNANEC join P_ZAMESTNAVATEL on P_ZAMESTNANEC.ID_ZAMESTNAVATELA = P_ZAMESTNAVATEL.ICO
        where NAZOV = 'Tesco';

-- ku každému veku vypíšte počet osôb, ktoré sú oslobodené od poistenia (kažú osobu počítajte raz)
select (
    case when substr(ROD_CISLO, 1,2) < to_char(sysdate, 'YY') then to_char(sysdate, 'YY') - substr(ROD_CISLO, 1,2)
            else 100 + to_char(sysdate, 'YY') - substr(ROD_CISLO, 1,2) end) as rok_narodenia, count(distinct P_POISTENIE.ROD_CISLO) as pocet
    from P_POISTENIE
        where OSLOBODENY = 'A' or OSLOBODENY = 'a'
            group by substr(ROD_CISLO, 1,2)
                order by 1;


-- vypýšte zoznam osôb, ktoré súčastne poberajú viac ako jeden typ príspevku
select ROD_CISLO, count (ID_TYPU)
    from P_POBERATEL
        group by ROD_CISLO
            having count(ID_TYPU) > 1
            order by count(ID_TYPU);

-- vypýšte menný zoznam platných poistencov, ktorí nemajú zaplatený ani jeden odvod za posledných 6 meiasov
select meno, PRIEZVISKO, DAT_DO, DAT_OD, ID_POISTENCA
    from P_OSOBA join P_POISTENIE poistenie using (rod_cislo)
        where DAT_DO is null or DAT_DO > sysdate and not exists(select 'x' from P_ODVOD_PLATBA pladba
                                where poistenie.ID_POISTENCA = pladba.ID_POISTENCA
                                    and extract(month from DAT_PLATBY) > extract(month from sysdate) - 6 );

------------------------------------------- Z PONDELKA -------------------------------------------

-- Vypísať zamestnancov čo začali a skončili pracovný pomer v rovnakom mesiaci a roku.
select *
    from P_ZAMESTNANEC
        where extract(month from DAT_OD) = extract(month from DAT_DO)
            and extract(year from DAT_OD) = extract(year from DAT_DO);

-- Vypýsať mestá, v ktorých nebýva nikto s duševnou poruchou
select *
    from P_MESTO mesto
        where not exists(select 'x'
                            from P_OSOBA os join P_ZTP using (rod_cislo) join P_TYP_POSTIHNUTIA using (id_postihnutia)
                                where ID_POSTIHNUTIA = 5 and mesto.PSC = os.PSC);

-- Vypýsať mestá a ku každému mestu človeka s najdlhším priezviskom
select distinct N_MESTA, PRIEZVISKO, ps.PSC
    from P_MESTO ps left join P_OSOBA on ps.PSC = P_OSOBA.PSC
        group by N_MESTA, PRIEZVISKO, ps.PSC
            having length(PRIEZVISKO) = (select max( distinct dlzka) as length
                                            from  (select length(PRIEZVISKO) as dlzka
                                                from P_OSOBA
                                                    where PSC = ps.PSC))
                order by N_MESTA;


-- Vypísať meno, priezvisko rod číslo pre všetky osoby, ak je osoba ZTP vypísať jej ID a dátum od kedy jej ZTP, vypísať aj osoby ktoré nie sú ZTP
select distinct MENO, PRIEZVISKO, os.ROD_CISLO, ID_ZTP, DAT_OD
    from P_OSOBA os left join P_ZTP ztp on os.ROD_CISLO = ztp.ROD_CISLO
        order by MENO;