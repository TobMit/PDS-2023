-- prior keď dáme 0 tak várti null
-- next keď dáme akékovek záporné čislo tak vrati 1
-- ak ak si priradím jedno pole do druhého taže mám 2 polia rovnaké, tak keď zmažem niečo v jednom tak sa to nezmaže v druhom

-- Typ čo bude nested table celých čísel
create type t_cisla is table of integer;
create table cisla_tab
(
    id integer primary key,
    pole t_cisla
) nested table pole store as cisla_neted;

insert into cisla_tab values (1, t_cisla(1,2,3));
insert into cisla_tab values (2, t_cisla(4,5,6));

commit;

-- pridame cislo do tejto kolekcie
declare
    tem_cislata t_cisla;
begin
    select pole into tem_cislata from cisla_tab where id = 1;
    tem_cislata.extend;
    tem_cislata(tem_cislata.last) := 7;
    update cisla_tab set pole = tem_cislata where id = 1;
end;
/

select *
from cisla_tab;

-- druhej kolekcie všetky neparne čilsa nahradime nulov
declare
    tem_cislata t_cisla;
begin
    select pole into tem_cislata from cisla_tab where id = 2;
    for i in 1..tem_cislata.LAST loop
        if tem_cislata.EXISTS(i) then
            if mod(tem_cislata(i), 2) = 1 then
                tem_cislata(i) := 0;
            end if;
        end if;
    end loop;

    update cisla_tab set pole = tem_cislata where id = 2;
end;
/

commit;

-- pridať nový prvok do kolekcie pre druhý záznam ale urobyť to v jazyku SQL
-- keď to robím v jazyku v PLSQL tak sa to musi transformovať čo zaberá zdroje
insert into table(select pole from cisla_tab where id = 2) values (8);
-- ja si musím sprístupniť "tabuľku" v tabuľke a potom do nej vložiť hodnotu

select *
from cisla_tab;

-- podobne ako sme hore nastavovali nepárne na nulu tak teraz párne na -1 iba pomocou sql

update TABLE (select pole from cisla_tab where id = 2) set column_value = -1 where mod(column_value, 2) = 0;

select *
from table ( select pole from cisla_tab where id = 2 );

drop table cisla_tab;

-- vytvorte funkciu ktorá vráti vek osoby z rodného čisla

create or replace function vek_frock_rc(RC varchar2) return integer
is
    den integer;
    mesiac integer;
    rok integer;
    vek integer;
begin
    rok:= substr(rc, 1,2);

    if rok > 23 then
        rok:= 19 || rok;
    end if;

    if rok <= 23 then
        rok:= 20 || rok;
    end if;

    mesiac:= substr(rc, 3,2);

    if mesiac > 12 then
        mesiac:= mesiac - 50;
    end if;

    den:= substr(rc, 5,2);

    select months_between(sysdate, to_date(den || '.' || mesiac || '.' || rok, 'DD.MM.YYYY' )) / 12 into vek from dual;

    return vek;

    EXCEPTION when others then return -1;


end;
/

select vek_frock_rc(ROD_CISLO) from OS_UDAJE;

-- vypýsať 3 najstaršich študentova
-- musí tam byť aj namiesto only with ties, lebo ak by boli viacerý rovnaký s rovnakým vekom tak by sa nevypýsali
-- pre test môže byť
select meno, PRIEZVISKO, vek_frock_rc(ROD_CISLO) as vek
    from OS_UDAJE
        order by vek desc fetch first 3 rows with ties;

-- vypýsať 3 najstarších študentov v každom ročníku
-- Navod:
    -- musí sime očislovať každého študenta v ročníku
    -- rownumber, rank, dense_rank
    -- musím si to ešte aj sgroopovať pomocou partition by a pre každý ročník
select * from (
    select meno, PRIEZVISKO, vek_frock_rc(ROD_CISLO) as vek, rocnik, row_number() over (partition by rocnik order by vek_frock_rc(ROD_CISLO) desc) as poradie
        from os_udaje join STUDENT using (rod_cislo)
        )
    where poradie <= 3;



-----------------------------------------------------
create table rekonstrukcia(datum date, aktivita varchar2(100));

insert into rekonstrukcia values(trunc(sysdate -30), 'obhliadka domu');
insert into rekonstrukcia values(trunc(sysdate -29), 'škriabanie stien');
insert into rekonstrukcia values(trunc(sysdate -28), 'škriabanie stien');
insert into rekonstrukcia values(trunc(sysdate -27), 'sekanie drážok na elektriku');
insert into rekonstrukcia values(trunc(sysdate -26), 'sekanie drážok na elektriku');
insert into rekonstrukcia values(trunc(sysdate -25), 'sekanie drážok na elektriku');
insert into rekonstrukcia values(trunc(sysdate -24), 'sekanie drážok na elektriku');
insert into rekonstrukcia values(trunc(sysdate -23), 'elektroinštaláčné práce');
insert into rekonstrukcia values(trunc(sysdate -22), 'murovanie');
insert into rekonstrukcia values(trunc(sysdate -21), 'murovanie');
insert into rekonstrukcia values(trunc(sysdate -20), 'vodoinštalatérske práce');
insert into rekonstrukcia values(trunc(sysdate -19), 'murovanie');
insert into rekonstrukcia values(trunc(sysdate -18), 'penetrácia a kožovanie stien');
insert into rekonstrukcia values(trunc(sysdate -17), 'penetrácia a kožovanie stien');
insert into rekonstrukcia values(trunc(sysdate -16), 'penetrácia a kožovanie stien');
insert into rekonstrukcia values(trunc(sysdate -15), 'čakanie - schnutie');
insert into rekonstrukcia values(trunc(sysdate -14), 'čakanie - schnutie');
insert into rekonstrukcia values(trunc(sysdate -13), 'maľovanie radiátorov a stien');
insert into rekonstrukcia values(trunc(sysdate -12), 'maľovanie radiátorov a stien');
insert into rekonstrukcia values(trunc(sysdate -11), 'čakanie - schnutie');
insert into rekonstrukcia values(trunc(sysdate -10), 'čakanie - schnutie');
insert into rekonstrukcia values(trunc(sysdate -9), 'elektroinštaláčné práce');
insert into rekonstrukcia values(trunc(sysdate -8), 'vodoinštalatérske práce');
insert into rekonstrukcia values(trunc(sysdate -7), 'finalizácia práce');
insert into rekonstrukcia values(trunc(sysdate -6), 'odovzdanie diela');

commit;
----------------------------------------------------------------------------------------
create table teplota_tab(datum date, hodnota integer);
insert into teplota_tab values(trunc(sysdate) + interval '6' hour, 24);
insert into teplota_tab values(trunc(sysdate) + interval '7' hour, 24);
insert into teplota_tab values(trunc(sysdate) + interval '8' hour, 25);
insert into teplota_tab values(trunc(sysdate) + interval '9' hour, 27);
insert into teplota_tab values(trunc(sysdate) + interval '10' hour, 28);
insert into teplota_tab values(trunc(sysdate) + interval '11' hour, 28);
insert into teplota_tab values(trunc(sysdate) + interval '12' hour, 29);
insert into teplota_tab values(trunc(sysdate) + interval '13' hour, 29);
insert into teplota_tab values(trunc(sysdate) + interval '14' hour, 30);
insert into teplota_tab values(trunc(sysdate) + interval '15' hour, 29);
insert into teplota_tab values(trunc(sysdate) + interval '16' hour, 27);
insert into teplota_tab values(trunc(sysdate) + interval '17' hour, 26);
insert into teplota_tab values(trunc(sysdate) + interval '18' hour, 25);
insert into teplota_tab values(trunc(sysdate) + interval '19' hour, 23);
insert into teplota_tab values(trunc(sysdate) + interval '20' hour, 22);
insert into teplota_tab values(trunc(sysdate) + interval '21' hour, 21);
insert into teplota_tab values(trunc(sysdate) + interval '22' hour, 21);
insert into teplota_tab values(trunc(sysdate) + interval '23' hour, 21);
commit;

-- chceme spraviť aktivitu ktorá bude vypisovať koľko aktivita trvala
-- návod:
    -- min a max budú hranice
    -- musím si správne agregovať tak aby sa vytvarali skupiny čiže ak aktivita ide A1, A1, B, C, A1, D takže výipis bude A1 - bolo 2 dni, B - 1 den, C - 1 den, A1 - 1 den, D - 1 den
    -- v grub by bude aktivita a aj rozdel medzi dňami
select min(datum), max(datum), aktivita
from
    (select datum, aktivita, datum - row_number() over (partition by aktivita order by datum) as rozdiel
    from rekonstrukcia
        order by datum)
        group by aktivita, rozdiel
            order by min(datum);

-- na doma, je tam tabuľka teplôt a ja chcem pre každú hodinu zýskať informáciu, či sa teplota zvýšila, znižila alebo ostala rovnaká
-- Návod: zoberiem tabuľku a očíslujem si ju
        -- urobim 2 reprezentácie ich a rozdiel podľa toho porovnám či sa znižuje alebo znižuje
