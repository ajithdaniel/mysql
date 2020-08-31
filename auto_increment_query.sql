SELECT table_schema, table_name, column_name, auto_increment,
                  pow(2, case data_type
                    when 'tinyint'   then 7
                    when 'smallint'  then 15
                    when 'mediumint' then 23
                    when 'int'       then 31
                    when 'bigint'    then 63
                    end+(column_type like '% unsigned'))-1 as max_int
                  FROM information_schema.tables t
                  JOIN information_schema.columns c USING (table_schema,table_name)
                  WHERE c.extra = 'auto_increment' AND t.auto_increment IS NOT NULL\G
