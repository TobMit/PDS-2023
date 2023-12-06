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

select id_okresu, okres.nazov, sum(case when getvek(rod_cislo) between 18 and 45 then 1 else 0 end) as od_18_do_45,
        sum(case when getvek(rod_cislo) between 45 and 60 then 1 else 0 end) as od_45_do_60,
        sum(case when getvek(rod_cislo) > 60  then 1 else 0 end) as viac_ako_60
    from mesto left join OSOBA using (psc) left join OKRES using (id_okresu)
        where substr(rod_cislo, 3,1) = '0' or substr(rod_cislo, 3,1) = '1'
            group by id_okresu, okres.nazov
                order by id_okresu;


-- 3. TOP 10 najviac pozicanych aut podla poctu pozicanych dni
SELECT ID_VOZIDLA,  sum(DAT_DO - DAT_OD) as pocet_dni
    from TRANSAKCIA
        where dat_do is not null
            group by ID_VOZIDLA
                order BY sum(DAT_DO - DAT_OD) desc fetch first 10 rows with TIES;


-- DB link na asterixovi
create database link semestrakla_link
CONNECT TO mitala1 IDENTIFIED BY hesloXDDDDD -- tu treba dať vlastné helso a miesto mitala1 dať svoj login
using '(DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = obelix.fri.uniza.sk)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl.fri.uniza.sk)
    )
  )
';
/

drop database link semestrakla_link;

select *
    from OS_UDAJE join STUDENT@semestrakla_link using(ROD_CISLO);

-- 22. Ku každej študíjnej skupine vypíšte 2 študentov, ktorí sa zapísali v minulosti
select st_skupina, listagg(rnk || '. ' || meno || ' ' || priezvisko, ', ') within group (order by rnk, meno, priezvisko) from (
    select st_skupina, meno, priezvisko, row_number() over (partition by st_skupina order by dat_zapisu) rnk from os_udaje
    join STUDENT@semestrakla_link using(rod_cislo)
)
where rnk <= 2
group by  st_skupina;