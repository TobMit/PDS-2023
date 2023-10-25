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
