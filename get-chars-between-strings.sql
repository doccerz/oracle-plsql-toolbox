SELECT regexp_substr(<SOURCE-STRING>, '<STRING1>([^}]+)<STRING2>', 1,1,NULL,1) AS output
FROM dual