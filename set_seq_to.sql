set SERVEROUT ON
CREATE OR REPLACE PROCEDURE set_seq_to(
    p_owner IN VARCHAR2
   ,p_name IN VARCHAR2
   ,p_val IN NUMBER
) AS
    l_num NUMBER;
BEGIN
    EXECUTE IMMEDIATE 'SELECT '||p_owner||'.'||p_name||'.nextval FROM dual' INTO l_num;
 
    -- Added check for 0 to avoid "ORA-04002: INCREMENT must be a non-zero integer"
    IF(p_val-l_num-1)!=0 THEN
        EXECUTE IMMEDIATE 'alter sequence '||p_owner||'.'||p_name||' increment by '||(p_val-l_num-1)||' minvalue 0';
    END IF;
    EXECUTE IMMEDIATE 'SELECT '||p_owner||'.'||p_name||'.nextval FROM dual' INTO l_num;
    EXECUTE IMMEDIATE 'alter sequence '||p_owner||'.'||p_name||' increment by 1 ';
    dbms_output.put_line('Sequence '||p_owner||'.'||p_name||' is now at '||p_val);
END;
/