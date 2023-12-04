-- Keď chcem najaké záznami od určitého riadku tak pomocou fetch alebo row number


-- Vytvorte si kolekciu ako typ, ktorú koľvek chceme

create or replace type o_osoba as object
(
    meno varchar2(20),
    priezvisko varchar2(20),

    map member function tried return integer
);
/

create or replace type body o_osoba as
    map member function tried return integer is
    begin
        return length(PRIEZVISKO);
    end;
end;
/

create or replace type nested_table is table of o_osoba;
create table osoba_table
(
    rocnik integer,
    collection nested_table
) nested table collection store as coll;

-- objekt ktorý bude volať meno a priezvisko, (konštruktor) a potom z tých jednotlivých záznaomov spravim kolekciu
select o_osoba(n.meno, n.PRIEZVISKO) from OS_UDAJE n; -- vytvoril som si pomocou konštruktora objekty
-- teraz potrebujem ich vložíť do kolekcie pomocou COLLECT problém je že to vráti any date preto to potrebujem pomocou CAST pretypovať
select cast(COLLECT( o_osoba(n.meno, n.PRIEZVISKO)) as nested_table) from OS_UDAJE n;
-- mám kolelkciu, teraz chcem pre každý ročník vytvoriť kolekciu, COLLECT je agregačná funkcia, takže použijem GROUP BY
select cast(COLLECT( o_osoba(n.meno, n.PRIEZVISKO)) as nested_table), rocnik
    from OS_UDAJE n join STUDENT s  on n.ROD_CISLO = s.ROD_CISLO
        group by rocnik;

-- aktualizujeme krstné mená tak aby sa všetci prváci volali michal
-- najskôr vložíme do tabuľky a potom aktualizujeme kolekciu
insert into osoba_table (select rocnik, cast(COLLECT( o_osoba(n.meno, n.PRIEZVISKO)) as nested_table)
    from OS_UDAJE n join STUDENT s  on n.ROD_CISLO = s.ROD_CISLO
        group by rocnik);

-- teraz aktualizujeme kolekciu
update table ( select collection from osoba_table where rocnik = 1) set meno = 'Michal';

-- uložíme celú kolekciu prvákov do premennej a plus vypýšem obsah kolekcie
declare
    obj nested_table;
begin
    select collection into obj from osoba_table where rocnik = 1;
    for i in 1..obj.LAST
        loop
            dbms_output.put_line(obj(i).meno || ' ' || obj(i).priezvisko);
        end loop;
end;
/

-- potredenie kolekcie je lepšie v tom inserte, celý objekt by som dal do selektu a vonkajší by som dal už len do selektu
-- select rocnik, cast collect (select konštruktor objektu meno, priezvisko order by... pretože máme funkciu

select * from ( select typ(meno, PRIEZVISKO) from os_udaje) obj order by obj.priezvisko; -- takto nejak by to bolo

-- chceme osobu s najdlhším priezviskom pre každý ročník osobytne
select meno, PRIEZVISKO, dlzka, rocnik, poradie
    from (select meno, PRIEZVISKO, length(PRIEZVISKO) as dlzka, rocnik, row_number() over (partition by rocnik order by length(PRIEZVISKO) desc ) as poradie
            from OS_UDAJE join STUDENT using (rod_cislo) order by ROCNIK, Poradie)
    where poradie = 1;

-- dalo by sa to aj bez partition by
select m, p dlzka(...)
    from ...
        where lenght(p) in select max(length(p) from ... zhora.rocnik == tento.rocnik)

-- budem chcieť xml mať meno a priezvisko ako 2 elementy, potom ktorý má odbor a atrybýt os číslo, daľej element štúdium a ktorý on študoval
select xmlroot(
            xmlelement("osoba",
                xmlelement(
                "meno", meno
                ),
            xmlelement(
                "priezvisko", priezvisko
                ),
            xmlelement("studium",
                XMLAGG(
                    xmlelement(
                    "odbor",
                        xmlattributes (os_cislo as "os_cislo"),
                        st_odbor
                        )
                    )
                )
            )
           , version '1.0')
    from OS_UDAJE join STUDENT using (rod_cislo)
        group by MENO, PRIEZVISKO, rod_cislo
            having count(*) > 1; -- toto tu nemá byť je to len na to aby som si odfiltroval záznami s viac os_cislami

-- chcme to vložiť do tabuľky
create table obor_xml_ty of xmltype;

insert into obor_xml_ty (select xmlroot(
            xmlelement("osoba",
                xmlelement(
                "meno", meno
                ),
            xmlelement(
                "priezvisko", priezvisko
                ),
            xmlelement("studium",
                XMLAGG(
                    xmlelement(
                    "odbor",
                    xmlattributes (os_cislo as "os_cislo"),
                    st_odbor
                    )
                )
                )
            )
           , version '1.0')
    from OS_UDAJE join STUDENT using (rod_cislo)
        group by MENO, PRIEZVISKO, rod_cislo);

drop table obor_xml_ty;

select *
from obor_xml_ty;

select extractvalue(value (oxt), 'osoba/priezvisko') from obor_xml_ty oxt;

-- vypýsať osobné čísla
-- ako na to, spraviť z toho kolekciu a potom to pretypovať na klasickú tabuľku

-- agregačné funkcie null ignorujä
select rocnik, count (case when substr(rod_cislo, 3, 1) in  ('5',  '6') then 1 else null end) as pocet_zien,
       sum (case when substr(rod_cislo, 3, 1) in  ('1',  '0') then 1 else 0 end)as pocet_muzov
    from STUDENT
        group by rocnik;

-- percentá
select *
    from (select rocnik, OS_CISLO, meno, priezvisko, row_number() over (partition by rocnik order by null) as rn
    from OS_UDAJE join STUDENT using (rod_cislo))
        where rn <= (select 0.1*count(*) from student);

-- order by null je náhodných 10 precent záznamov
-- toto je pre každý ročník
select *
    from (select rocnik, OS_CISLO, meno, priezvisko, row_number() over (partition by rocnik order by null) as rn
    from OS_UDAJE join STUDENT using (rod_cislo))s1
        where rn <= (select trunc(0.1*count(*)) + 1 from student s2 where s1.rocnik = s2.rocnik);
