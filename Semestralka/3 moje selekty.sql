-- Select 1:  Troch zakaznikov, ktory si pozicali v danom roku najviac aut
select rok, id_osoby, meno, priezvisko
    from (
        select extract(year from dat_od) as rok, id_osoby, meno, priezvisko, count(*) as pocet_pozicani, row_number() over (partition by extract(year from dat_od) order by count(*) desc) as poradie
            from osoba join transakcia using (id_osoby)
                group by extract(year from dat_od), id_osoby, meno, priezvisko
                    order by rok, pocet_pozicani desc
                        )
        where poradie <= 3;

-- Select 2: Pocet muzov v jednotlivych okresoch podla demografie (18-45, 45-60, 60+)

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

select psc, mesto, sum(case when getvek(rod_cislo) between 18 and 45 then 1 else 0 end) as od_18_do_45,
        sum(case when getvek(rod_cislo) between 45 and 60 then 1 else 0 end) as od_45_do_60,
        sum(case when getvek(rod_cislo) > 60  then 1 else 0 end) as viac_ako_60
    from ADRESA left join OSOBA using (psc)
        group by psc, mesto
        order by psc;

-- 3. TOP 10 najviac pozicanych aut podla poctu pozicanych dni
SELECT ID_VOZIDLA,  sum(DAT_DO - DAT_OD) as pocet_dni
    from TRANSAKCIA
        where dat_do is not null
            group by ID_VOZIDLA
                order BY sum(DAT_DO - DAT_OD) desc fetch first 10 rows with TIES;