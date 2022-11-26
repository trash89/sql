COLUMN ROWLEN FORMAT 999990
COLUMN QLTY   FORMAT 999990

SELECT * FROM
(SELECT
   SUBSTR(I.INDEX_NAME, 1, 20) INDEX_NAME,
   I.NUM_ROWS NUM_ROWS,
   SUM(TC.AVG_COL_LEN + 1) + 7 ROWLEN,
   I.LEAF_BLOCKS LEAVES,
   ROUND((SUM(TC.AVG_COL_LEN + 1) + 7) * I.NUM_ROWS /
     1000000, 0) NET_MB,
   ROUND(I.LEAF_BLOCKS * (8079 - 23 * I.INI_TRANS) *
     (1 - I.PCT_FREE / 100) / 1000000, 0) GROSS_MB,
   ROUND((SUM(TC.AVG_COL_LEN + 1) + 7) * I.NUM_ROWS /
     (I.LEAF_BLOCKS * (8079 - 23 * I.INI_TRANS) *
     (1 - I.PCT_FREE / 100)) * 100, 0) QLTY
FROM DBA_TABLES T, DBA_INDEXES I, DBA_TAB_COLUMNS TC,
       DBA_IND_COLUMNS IC
WHERE T.TABLE_NAME = TC.TABLE_NAME AND
       T.OWNER = TC.OWNER AND
       I.INDEX_NAME = IC.INDEX_NAME AND
       I.OWNER = IC.INDEX_OWNER AND
       TC.TABLE_NAME = IC.TABLE_NAME AND
       TC.OWNER = IC.INDEX_OWNER AND
       TC.COLUMN_NAME = IC.COLUMN_NAME AND
       I.INDEX_TYPE = 'NORMAL' AND
       I.OWNER LIKE 'SAP%' AND
       I.LEAF_BLOCKS > 200
GROUP BY T.TABLE_NAME, T.OWNER, I.NUM_ROWS, I.LEAF_BLOCKS,
       I.INDEX_NAME, I.INI_TRANS, I.PCT_FREE
ORDER BY 7)
WHERE ROWNUM <=20;
