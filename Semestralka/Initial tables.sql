create or REPLACE type typAuta as object
(
    id_typu NUMBER,
    nazov_typu VARCHAR2(50)
) not final;
/

create table typ_auta of typAuta (primary key (id_typu));


create or REPLACE type stavAuta as object
(
    id_stavu NUMBER,
    nazov_stavu VARCHAR2(50)
)not final;
/

create table stav_auta of stavAuta (primary key (id_stavu));


create or REPLACE type znackyAut as object
(
    id_znacky NUMBER,
    nazov_znacky VARCHAR2(50)
)not final;
/

create table znacky_aut of znackyAut (primary key (id_znacky));


create type adresaObject as object
(
    psc varchar2(5),
    mesto VARCHAR2(50)
)not final;
/

create table adresa of adresaObject (primary key (psc));


create type osobaObject as object
(
    id_osoby number(10),
    meno VARCHAR2(50),
    priezvisko varchar2(50),
    rod_cislo varchar2(10),
    cislo_obcianskeho varchar2(8),
    ulica varchar2(50),
    psc varchar2(5)
)not final;
/

create table osoba of osobaObject (primary key (id_osoby));
ALTER TABLE osoba
    ADD CONSTRAINT fk_osoba_psc FOREIGN KEY (psc) REFERENCES adresa(psc);


create type vozidlaObjects as object
(
    seriove_cislo_vozidla varchar2(6),
    znacka_auta number,
    typ_auta number,
    stav_vozidla number,
    ecv varchar2(7),
    pocet_miest_na_sedenia number(2),
    fotka blob,
    rok_vyroby number(10),
    pocet_najazdenych_km number(10),
    typ_motora varchar2(1)
)not final;
/

create table vozidla of vozidlaObjects (primary key (seriove_cislo_vozidla));
ALTER TABLE vozidla
    ADD CONSTRAINT fk_vozidla_znacka_auta FOREIGN KEY (znacka_auta) REFERENCES znacky_aut(id_znacky);
ALTER TABLE vozidla
    ADD CONSTRAINT fk_vozidla_typ_auta FOREIGN KEY (typ_auta) REFERENCES typ_auta(id_typu);
ALTER TABLE vozidla
    ADD CONSTRAINT fk_vozidla_stav_vozidla FOREIGN KEY (stav_vozidla) REFERENCES stav_auta(id_stavu);


create type transakcieObject as object
(
    id_osoby number(10),
    id_vozidla varchar2(6),
    dat_od date,
    dat_do date,
    suma number(10,2)
)not final;
/
create table transakcie of transakcieObject (primary key (id_osoby, id_vozidla));
ALTER TABLE transakcie
    ADD CONSTRAINT fk_transakcie_id_osoby FOREIGN KEY (id_osoby) REFERENCES osoba(id_osoby);
ALTER TABLE transakcie
    ADD CONSTRAINT fk_transakcie_id_vozidla FOREIGN KEY (id_vozidla) REFERENCES vozidla(seriove_cislo_vozidla);
