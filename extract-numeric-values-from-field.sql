SELECT
    regexp_replace(
        '1234bsdfs3@23#-86743123dsf42562543412#PU',
        '[^0-9]',
        ''
    ) nums
FROM
    dual;