-- vyrobyť xaml dokument typu z tamsu
select xmlroot(
        XMLELEMENT(
                "osoba",
                xmlforest(
                        MENO as "meno",
                        PRIEZVISKO as "priezvisko"
                    ),
            xmlelement(
                "studium",
                XMLAGG(
                      xmlelement( "odbor", xmlattributes(os_cislo as "os_cislo"), st_odbor)
                    )
            )
        )
    ,version '1.0')
    from OS_UDAJE join STUDENT using (rod_cislo)
        group by rod_cislo, meno, priezvisko;


-- obsah tothoto selektu uložíme do tabulky dokumentov
create table table_of_xml of xmltype;

insert into table_of_xml (select xmlroot(
        XMLELEMENT(
                "osoba",
                xmlforest(
                        MENO as "meno",
                        PRIEZVISKO as "priezvisko"
                    ),
            xmlelement(
                "studium",
                XMLAGG(
                      xmlelement( "odbor", xmlattributes(os_cislo as "os_cislo"), st_odbor)
                    )
            )
        )
    ,version '1.0')
    from OS_UDAJE join STUDENT using (rod_cislo)
        group by rod_cislo, meno, priezvisko);

commit;

-- urobte analogickú štruktúru ale pre json dokument
    -- bude tam meno, priezvisko ako je tu ale urobím json pole nejakých elementov

select *
from table_of_xml;

select
    JSON_OBJECT(
        'meno' value meno,
        'priezvisko' value PRIEZVISKO,
        'studium' value json_arrayagg(json_object(
            'oc' value os_cislo,
            'odbor' value st_odbor
            ))
        )
        from OS_UDAJE join student using(rod_cislo)
            group by meno, PRIEZVISKO, rod_cislo;

-- upravte to tak aby zdrojom bola tá xml tabuľka

-- sprevíme to dvojfázovo, najskôr spravíme tabuľku ktorá a potom tú budem davať do json
    -- ziskanie odborov spravím tak že si spravim kolekciu doborov

select extractvalue(value (t), 'osoba/meno') as meno,
       extractvalue(value (t), 'osoba/priezvisko') as priezvisko,
       extractvalue(odbor_table.column_value, 'odbor') as odbor,
       extractvalue(odbor_table.column_value, 'odbor/@os_cislo') as os_cislo

    from table_of_xml t, table(XMLSEQUENCE(extract(value(t), 'osoba/studium/odbor'))) odbor_table;



select
    JSON_OBJECT(
        'meno' value meno,
        'priezvisko' value priezvisko,
        'studium' value json_arrayagg(json_object(
            'oc' value os_cislo,
            'odbor' value st_odbor
            ))
        )
        from (
            select extractvalue(value (t), 'osoba/meno') as meno,
                    extractvalue(value (t), 'osoba/priezvisko') as priezvisko,
                    extractvalue(odbor_table.column_value, 'odbor') as st_odbor,
                    extractvalue(odbor_table.column_value, 'odbor/@os_cislo') as os_cislo

                from table_of_xml t, table(XMLSEQUENCE(extract(value(t), 'osoba/studium/odbor'))) odbor_table
             )
        group by meno, priezvisko;

-- data vložíme do tabuľky

create table json_tab (
    data clob check (data is json)
)
/

insert into json_tab (
    select
        JSON_OBJECT(
            'meno' value meno,
            'priezvisko' value priezvisko,
            'studium' value json_arrayagg(json_object(
                'oc' value os_cislo,
                'odbor' value st_odbor
                ))
            )
            from (
                select extractvalue(value (t), 'osoba/meno') as meno,
                        extractvalue(value (t), 'osoba/priezvisko') as priezvisko,
                        extractvalue(odbor_table.column_value, 'odbor') as st_odbor,
                        extractvalue(odbor_table.column_value, 'odbor/@os_cislo') as os_cislo

                    from table_of_xml t, table(XMLSEQUENCE(extract(value(t), 'osoba/studium/odbor'))) odbor_table
                 )
            group by meno, priezvisko
        );


-- mam json tabulku chcem vytvoriť xml tabulku
    -- z pola urobim relacnu tabulku pomocou funkcie json_table

select meno, priezvisko, odbor, oc
    from json_tab t, json_table(t.data, '$'
        columns(meno varchar2(20) path '$.meno',
                priezvisko varchar2(20) path '$.priezvisko',
                nested path '$.studium[*]' columns (
                    odbor varchar2(20) path '$.odbor',
                    oc varchar2(20) path '$.oc'
                    ))
        );

commit;