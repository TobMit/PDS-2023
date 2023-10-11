-- akým spôsobom viem zadefinovať nejaký typ objektový
create type t_kniha as object
(
    nazov varchar2(30),
    zaner varchar2(30),
    vydavatelstvo varchar2(30),
    rok_vydania integer
);
/

alter type t_kniha
    add member function vypis return varchar;
/

create or replace type body t_kniha
is
    member function vypis return varchar
    is
    begin
        -- rpad použijeme na krajší vypís prvé je čo sa ma vypísať a drhý parameter je koľko znakov sa ma vypísať (pripadne aj white znakov)
        return rpad(nazov, 20) || rpad(ZANER, 20) || rpad(VYDAVATELSTVO, 20) || rok_vydania;
    end;
end;
/

set serverouput on; -- toto v nastavení konzole pre DG

declare
    v_book t_kniha;
    v_result varchar2(200);
begin
    v_book := t_kniha('kniha', 'scifi', 'ja',2001);
    DBMS_OUTPUT.PUT_LINE(v_book.VYPIS());
    -- alebo
    v_result := v_book.VYPIS();
    DBMS_OUTPUT.PUT_LINE(v_result);
    -- alebo
    select v_book.VYPIS() into v_result from dual;
    DBMS_OUTPUT.PUT_LINE(v_result);
end;
/

create table kniha_tab of t_kniha;

desc kniha_tab;

alter table kniha_tab
    add constraint kniha_tab_pk primary key (NAZOV);

insert into kniha_tab
    values ('PDBS', 'ucebnica', 'edis', '2020');

insert into kniha_tab
    values (t_kniha('DO', 'ucebnica', 'edis','2007'));

select *
    from kniha_tab;

select value(k).vypis(), value(k).zaner from kniha_tab k;

select value(k)
    from kniha_tab k;

select *
from kniha_tab k
    order by value(k);

alter type t_kniha
    add map member function tried return integer cascade ; -- keďže sú už nejaké objekty na tomto type závislé, npreto to musíme pomocou cascade upraviť všade
/

create or replace type body t_kniha
is
    member function vypis return varchar
    is
    begin
        -- rpad použijeme na krajší vypís prvé je čo sa ma vypísať a drhý parameter je koľko znakov sa ma vypísať (pripadne aj white znakov)
        return rpad(nazov, 20) || rpad(ZANER, 20) || rpad(VYDAVATELSTVO, 20) || rok_vydania;
    end;

    map member function tried return integer
    is
        poradie integer;
    begin
        select case lower(zaner)
            when 'ucebnica' then 1
            when 'e-book' then 2
            else 3 end into poradie from DUAL;
        return poradie || ascii(nazov); -- ak sú obe rovnaké tak potom podla asi kódu
    end;
end;
/

-- teraz to už nespadne
select *
from kniha_tab k
    order by value(k);

select value(k) from kniha_tab k
    order by value(k);

-- na začiatu to nezbehne pretože t_kniha je defaultne final
create type t_ebook under t_kniha
(
    format char(4)
);
/
-- po tomto to zbehne
alter type t_kniha not final cascade;

alter type t_ebook
    add overriding member function vypis return varchar;
/

create or replace type body t_ebook
is
    overriding member function vypis return varchar
    is
    begin
        -- rpad použijeme na krajší vypís prvé je čo sa ma vypísať a drhý parameter je koľko znakov sa ma vypísať (pripadne aj white znakov)
        return (SELF as t_kniha). VYPIS() || format;
    end;
end;
/

insert into kniha_tab values (t_ebook('Harry Potter', 'fantasy', 'edis', 2023, 'PDF')); -- toto nezbehne lebo to je buch v oracle DB

-- jediné riešenie ja nanovo vytvoriť tabuľku
create table kniha_tab2 of t_kniha;

insert into kniha_tab2 select value(k) from kniha_tab k;

select *
from kniha_tab2;

insert into kniha_tab2 values (t_ebook('Harry Potter', 'fantasy', 'edis', 2023, 'PDF')); -- toto nezbehne lebo to je buch v oracle DB

select value(k).vypis() from kniha_tab2 k
    order by value(k);

select k.*, treat(value(k) as t_ebook).FORMAT from kniha_tab2 k
    order by value(k);

select k.*, treat(value(k) as t_ebook).FORMAT from kniha_tab2 k
    where value(k) is of (only T_KNIHA)
        order by value(k);

create table kniha_tab_atr
(
    id integer,
    kniha t_kniha
);

create sequence seq_kniha;
insert into kniha_tab_atr select seq_kniha.nextval, value(k) from kniha_tab2 k;

select *
    from kniha_tab_atr
        order by kniha;

select k.kniha.NAZOV -- musím mať tam aj alias tej tabuľky
    from kniha_tab_atr k;