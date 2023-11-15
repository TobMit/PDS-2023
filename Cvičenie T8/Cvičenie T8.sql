select rownum
    from student
        where rownum < 12;

select ROWNUM
    from dual
        connect by level <= 100000;

select count(*)
    from STUDENT
        connect by level < 5; -- nepoužívať moc nad reálnmi tabuľkami

select trunc(sysdate, 'YYYY') + level - 1
    from dual
        connect by level < 365;

-- tabulka s rekurziou
create table person_rec(person_id integer primary key,
name varchar2(20),
surname varchar2(20),
mother_id integer,
father_id integer);

alter table person_rec add foreign key (mother_id)
  references person_rec(person_id);

alter table person_rec add foreign key (father_id)
   references person_rec(person_id);

insert into person_rec values(1,'Emily','Burney',null,null);
insert into person_rec values(2,'Adam','Smith',null,null);
insert into person_rec values(3,'Grace','Smith',1,2);
insert into person_rec values(4,'Daniel','Phue',null,null);
insert into person_rec values(5,'Harry','Smith',1,2);
insert into person_rec values(6,'Olivia','Clarke',null,null);
insert into person_rec values(7,'Bella','Smith',1,2);
insert into person_rec values(8,'Peter','Roger',null,null);
insert into person_rec values(9,'James','Smith',6,5);
insert into person_rec values(10,'Sofia','Smith',6,5);
insert into person_rec values(11,'Lautaro','Smith',6,5);
insert into person_rec values(12,'Jack','Robinson',null,null);
insert into person_rec values(13,'Jacob','Robinson',10,12);
insert into person_rec values(14,'William','Robinson',10,12);

-- vypýať ku každej osobe súrodenca
select osoba.name , osoba.surname, surodenec.name, surodenec.surname
    from person_rec osoba join person_rec surodenec using (mother_id)
        where osoba.person_id != surodenec.person_id;

-- keď by som chcel iba nad hlvanou diagonálov tak dam väčší
select osoba.name , osoba.surname, surodenec.name, surodenec.surname
    from person_rec osoba join person_rec surodenec using (mother_id)
        where osoba.person_id > surodenec.person_id;

-- ku ku každej osobe vypýsať matku

select osoba.name, osoba.surname, matka.name, matka.surname
    from person_rec osoba left join person_rec matka
        on (osoba.mother_id = matka.person_id);

-- budem chcieť vypýsať v hierarchý rodokemna tak si to budem posúvať medzerami z ľava pomocou rekurzie
select lpad(' ', 2*level) || name || ' ' || surname
    from person_rec
    connect by prior person_id = mother_id; -- poradie atribútov je veľmi dôležité ak by som to vymenil tak by rodokmeň išiel od detí k rodičom

-- todo zobrať našú fakutlu, každá fakulta má prodekana, dekan má nad sebo prodekana a takto spraviť podobný výpis za 2 bonusové body...