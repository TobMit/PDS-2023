load data 
infile 'transakcie.csv' "str '\n'"
append
into table TRANSAKCIE
fields terminated by ','
trailing nullcols
           ( ID_OSOBY,
             ID_VOZIDLA CHAR(17),
             DAT_OD DATE "RRRR-MM-DD",
             DAT_DO DATE "RRRR-MM-DD",
             SUMA
           )
