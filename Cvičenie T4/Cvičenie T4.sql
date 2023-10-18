-- vytvorte tabulku kontakty
create table kontakty (
    rod_cislo char(11),
    typ_kontaktu char(1) check ( typ_kontaktu in ('m', 'e') ),
    hodnota varchar(100)
);

drop table kontakty;

insert into kontakty((select rod_cislo, 'm', meno || priezvisko || '@uniza.sk' from os_udaje));

commit;

insert into kontakty((select null, 'e', '@uniza.sk' from os_udaje));

select *
    from os_udaje
        where not exists(
            Select 1 from kontakty where kontakty.rod_cislo = os_udaje.ROD_CISLO
        );

select *
    from os_udaje
        where ROD_CISLO not in ( select kontakty.rod_cislo from kontakty );

select *
    from OS_UDAJE
        where ROD_CISLO not in (
            select nvl(kontakty.rod_cislo, 'null') from kontakty
            );

insert into OS_UDAJE values ('1111111', 'Peter', 'Peter', 'abc', '12345', 'cab');

-- vytvorte tabuľku ktorá bude mať 2 atribúty, rodné čislo a xml dokument
create table tablex (
    rod_cislo varchar2(11),
    xml xmltype
);

-- v xml budeme mať ročník a začiatok a koniec štúdia
-- vyrobíme element ktorý sa volá údaj
select xmlroot(xmlelement("udaj",
    xmlelement("rocnik", rocnik),
    xmlelement("zaciatok", dat_zapisu),
    xmlelement("koniec", ukoncenie)), version '1.0')
    from STUDENT;

