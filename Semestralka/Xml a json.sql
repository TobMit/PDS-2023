-- xml pre vypis zisku
SELECT xmlroot(XMLELEMENT(
               "zisk",
               XMLAGG(
                       rok_xml
               )
       ),version '1.0' ) AS dokument
            FROM (SELECT XMLELEMENT(
                     "rok",
                     XMLATTRIBUTES(rok AS "rok"),
                     XMLAGG(
                             XMLELEMENT(
                                     "mesiac",
                                     XMLATTRIBUTES(mesiac_sum AS "zisk"),
                                     mesiac
                             )
                     )
             ) as rok_xml
                FROM (SELECT rok, mesiac, mesiac_sum
                        FROM (SELECT EXTRACT(YEAR FROM dat_do) AS rok,
                                    EXTRACT(MONTH FROM dat_do) AS mesiac,
                                    SUM(suma) OVER (PARTITION BY EXTRACT(YEAR FROM dat_do), EXTRACT(MONTH FROM dat_do)) AS mesiac_sum
                                        FROM TRANSAKCIA
                            )
                                GROUP BY rok, mesiac, mesiac_sum
                                    ORDER BY rok, mesiac
                        )
                            GROUP BY rok
                )
-- json ktorý obsahuje vozdila a k ním servis v poslednom roku (keby to chceme pre všetky roky tak nam to oracle nedovolí (príliž dlhý reťazec))
select json_object(
        'id_vozidla' value seriove_cislo_vozidla,
        'servis' value json_arrayagg(
            json_object(
                'datum' value dat_od,
                'suma' value suma
            )
        )
    )
    from vozidlo v left join servis s on v. seriove_cislo_vozidla = s.ID_VOZIDLA
        where extract(year from dat_od) = extract(year from sysdate)
            group by seriove_cislo_vozidla;