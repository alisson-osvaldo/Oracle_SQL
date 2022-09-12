/*
Criar procedure insere_projeto
Crie a procedure brh.insere_projeto para cadastrar um novo projeto na base de dados.

Par�metros da procedure
Nome do projeto: varchar com nome do novo projeto.

Crit�rios de aceita��o
* Deve inserir um novo registro na tabela brh.projeto;
* N�o deve fazer commit em seu c�digo (a efetiva��o da transa��o deve ser feita por quem invoca a procedure).
*/
CREATE OR REPLACE PROCEDURE brh.insere_projeto
    (p_ID IN brh.projeto.ID%type, 
     p_NOME IN brh.projeto.NOME%type, 
     p_RESPONSAVEL IN brh.projeto.RESPONSAVEL%type, 
     p_INICIO IN brh.projeto.INICIO%type DEFAULT SYSDATE)
IS    
BEGIN
    INSERT INTO brh.projeto(ID, NOME, RESPONSAVEL, INICIO)
    VALUES
    (p_ID, upper(p_NOME), upper(p_RESPONSAVEL), p_INICIO);
    
    EXCEPTION 
       WHEN DUP_VAL_ON_INDEX then
            RAISE_APPLICATION_ERROR(-20001, 'ID j� cadastrado!!!');
        WHEN OTHERS
            THEN
            DBMS_OUTPUT.PUT_LINE('ERRO Oralcle: ' || SQLCODE || SQLERRM);
END;


EXECUTE brh.insere_projeto( 6, 'NEW_TEST', 'P123', SYSDATE); 
COMMIT;

SELECT * FROM brh.projeto;

--DELETE FROM brh.projeto WHERE ID > 4;


--------------------------------------------------------------------------------
/* Criar fun��o calcula_idade
Crie a function brh.calcula_idade que informa a idade a partir de uma data.

Par�metros da function
Data: date com a data de refer�ncia para calcular a idade.
Retorno da function
Deve retornar um n�mero inteiro com a idade.
Dica
Utilize a fun��o MONTHS_BETWEEN para calcular a idade.
� mais f�cil testar fun��es com o seguinte c�digo: select SCHEMA.FUNCAO(param1, param2, ..., paramN) from dual;.
*/
CREATE OR REPLACE FUNCTION brh.calcula_idade
        (p_data IN DATE)
        RETURN INT
    IS
        e_data_invalida EXCEPTION;
BEGIN  
    IF p_data > SYSDATE OR p_data IS NULL
        THEN RAISE e_data_invalida;
    ELSE
        RETURN INT(NVL(FLOOR((MONTHS_BETWEEN(SYSDATE, p_data) / 12)), 0));
    END IF;

    EXCEPTION 
        WHEN e_data_invalida
            THEN raise_application_error(-20001, 'Imposs�vel calcular idade! Data inv�lida: ' || p_data);
END;
    
    
SELECT brh.calcula_idade (TO_DATE('01/01/2000', 'dd/mm/yyyy')) FROM DUAL;


--------------------------------------------------------------------------------
/*Criar function finaliza_projeto
Crie a function brh.finaliza_projeto para registrar o t�rmino da execu��o de um projeto.

Par�metros da function
ID do projeto: number com identificador do projeto a ser finalizado.
Retorno da function
Deve retornar a data de finaliza��o atribu�da ao projeto.

Crit�rios de aceita��o
* A data fim do projeto para a data e hora atual;
* N�o deve fazer commit em seu c�digo (a efetiva��o da transa��o deve ser feita por quem invoca a function).
*/
SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION brh.finaliza_projeto
    (p_ID IN brh.projeto.ID%type)
    RETURN brh.projeto.fim%type
IS
    v_data_finalizacao brh.projeto.FIM%type;
BEGIN
    SELECT fim INTO v_data_finalizacao FROM brh.projeto WHERE id = p_ID;
       
    IF  v_data_finalizacao IS NOT NULL THEN
        RETURN v_data_finalizacao;  
    ELSE
        UPDATE brh.projeto SET FIM = SYSDATE WHERE ID = p_ID;
        RETURN v_data_finalizacao;    
    END IF;
    
    EXCEPTION 
        WHEN no_data_found THEN
            raise_application_error(-20001, 'Projeto inexistente: ' || p_ID);
        WHEN OTHERS
            THEN
            DBMS_OUTPUT.PUT_LINE('ERRO Oralcle: ' || SQLCODE || SQLERRM);   
END;
        
        
DECLARE
 data_fim DATE;
BEGIN
    data_fim := brh.finaliza_projeto(1);
    dbms_output.put_line('A data de fizali��o �: ' || data_fim );
END;

SELECT * FROM BRH.PROJETO;


--------------------------------------------------------------------------------
/*Validar novo projeto
Crie a function brh.finaliza_projeto para registrar o t�rmino da execu��o de um projeto.

Par�metros da function
ID do projeto: number com identificador do projeto a ser finalizado.
Retorno da function
Deve retornar a data de finaliza��o atribu�da ao projeto.

Crit�rios de aceita��o
A data fim do projeto para a data e hora atual;
N�o deve fazer commit em seu c�digo (a efetiva��o da transa��o deve ser feita por quem invoca a function).
*/
CREATE OR REPLACE PROCEDURE brh.insere_projeto
    (p_ID IN brh.projeto.ID%type, 
     p_NOME IN brh.projeto.NOME%type, 
     p_RESPONSAVEL IN brh.projeto.RESPONSAVEL%type, 
     p_INICIO IN brh.projeto.INICIO%type DEFAULT SYSDATE)
IS    
   e_cadastro_invalido EXCEPTION;
   e_null exception;
   pragma exception_init (e_null, -1400);
BEGIN
    INSERT INTO brh.projeto(ID, NOME, RESPONSAVEL, INICIO)
    VALUES
    (p_ID, upper(p_NOME), upper(p_RESPONSAVEL), p_INICIO);

    IF LENGTH(p_NOME) < 2 OR p_NOME = NULL  
        THEN
            RAISE e_cadastro_invalido;
    END IF;

    EXCEPTION        
        WHEN e_cadastro_invalido
            THEN  raise_application_error(-20001,'Nome de projeto inv�lido! Deve ter dois ou mais caracteres.');
        WHEN e_null THEN
            raise_application_error(-20002, 'Nome de projeto inv�lido! Deve ter dois ou mais caracteres.');
         WHEN DUP_VAL_ON_INDEX then
            RAISE_APPLICATION_ERROR(-20003, 'ID j� cadastrado!!!');
        WHEN OTHERS
            THEN
            DBMS_OUTPUT.PUT_LINE('ERRO Oralcle: ' || SQLCODE || SQLERRM);
END;


EXECUTE brh.insere_projeto(7, 'AAA', 'T123', SYSDATE);
SELECT * FROM brh.projeto;


--------------------------------------------------------------------------------
/*Validar c�lculo de idade
Altere a fun��o brh.calcula_idade para n�o permitir datas inv�lidas.

Crit�rios de aceita��o
A data recebida por par�metro deve ser menor que a data atual::
Se maior, ou null, lance uma exce��o com a mensagem "Imposs�vel calcular idade! Data inv�lida: <DATA_RECEBIDA_POR_PAR�METRO>.".
*/
CREATE OR REPLACE FUNCTION brh.calcula_idade
    (p_data IN DATE)
    RETURN INT
IS
    e_data_invalida EXCEPTION;
BEGIN  
DBMS_OUTPUT.PUT_LINE('Chamei a rotina FORMAT_CNPJ interna');
    IF p_data > SYSDATE OR p_data IS NULL
        THEN RAISE e_data_invalida;
    ELSE
        RETURN INT(NVL(FLOOR((MONTHS_BETWEEN(SYSDATE, p_data) / 12)), 0));
    END IF;

    EXCEPTION 
        WHEN e_data_invalida
            THEN raise_application_error(-20001, 'Imposs�vel calcular idade! Data inv�lida: ' || p_data);
        WHEN OTHERS
            THEN
            DBMS_OUTPUT.PUT_LINE('ERRO Oralcle: ' || SQLCODE || SQLERRM);
END;


SELECT brh.calcula_idade (TO_DATE('09/09/2021', 'dd/mm/yyyy')) FROM DUAL;
SELECT brh.calcula_idade(null) FROM DUAL;

--------------------------------------------------------------------------------
/* Mover procedures e fun��es para package
Agrupe todas as procedures e functions criadas para um novo package chamado brh.pkg_projeto.
*/

--Criando a PACKAGE
CREATE OR REPLACE PACKAGE brh.pkg_projeto
IS 
    FUNCTION calcula_idade
        (p_data IN DATE)
        RETURN INT;

    FUNCTION finaliza_projeto
        (p_ID IN brh.projeto.ID%type)
        RETURN brh.projeto.fim%type;
        
    PROCEDURE     insere_projeto
        (p_ID IN brh.projeto.ID%type, 
         p_NOME IN brh.projeto.NOME%type, 
         p_RESPONSAVEL IN brh.projeto.RESPONSAVEL%type, 
         p_INICIO IN brh.projeto.INICIO%type DEFAULT SYSDATE);
        
    PROCEDURE     define_atribuicao
        (p_nome_colaborador IN brh.colaborador.nome%type,
         p_nome_projeto IN brh.projeto.nome%type,
         p_nome_papel IN brh.papel.nome%type);
END;


--2 Passo : Criar Corpo onde vai nossa l�gica
CREATE OR REPLACE PACKAGE BODY brh.pkg_projeto
IS
--FUNCTIONS
    FUNCTION calcula_idade
        (p_data IN DATE)
        RETURN INT
    IS
        e_data_invalida EXCEPTION;
    BEGIN  
    DBMS_OUTPUT.PUT_LINE('Chamei a rotina FORMAT_CNPJ interna');
        IF p_data > SYSDATE OR p_data IS NULL
            THEN RAISE e_data_invalida;
        ELSE
            RETURN INT(NVL(FLOOR((MONTHS_BETWEEN(SYSDATE, p_data) / 12)), 0));
        END IF;
    
        EXCEPTION 
            WHEN e_data_invalida
                THEN raise_application_error(-20001, 'Imposs�vel calcular idade! Data inv�lida: ' || p_data);
            WHEN OTHERS
                THEN
                DBMS_OUTPUT.PUT_LINE('ERRO Oralcle: ' || SQLCODE || SQLERRM);
    END;
    
    FUNCTION finaliza_projeto
        (p_ID IN brh.projeto.ID%type)
        RETURN brh.projeto.fim%type
    IS
        v_data_finalizacao brh.projeto.FIM%type;
    BEGIN
        SELECT fim INTO v_data_finalizacao FROM brh.projeto WHERE id = p_ID;
           
        IF  v_data_finalizacao IS NOT NULL THEN
            RETURN v_data_finalizacao;  
        ELSE
            UPDATE brh.projeto SET FIM = SYSDATE WHERE ID = p_ID;
            RETURN v_data_finalizacao;    
        END IF;
        
        EXCEPTION 
            WHEN no_data_found THEN
                raise_application_error(-20001, 'Projeto inexistente: ' || p_ID);
            WHEN OTHERS
                THEN
                DBMS_OUTPUT.PUT_LINE('ERRO Oralcle: ' || SQLCODE || SQLERRM);   
    END;
    
--PROCEDURES
    PROCEDURE insere_projeto
        (p_ID IN brh.projeto.ID%type, 
         p_NOME IN brh.projeto.NOME%type, 
         p_RESPONSAVEL IN brh.projeto.RESPONSAVEL%type, 
         p_INICIO IN brh.projeto.INICIO%type DEFAULT SYSDATE)
    IS    
       e_cadastro_invalido EXCEPTION;
       e_null exception;
       pragma exception_init (e_null, -1400);
    BEGIN
        INSERT INTO brh.projeto(ID, NOME, RESPONSAVEL, INICIO)
        VALUES
        (p_ID, upper(p_NOME), upper(p_RESPONSAVEL), p_INICIO);
    
        IF LENGTH(p_NOME) < 2 OR p_NOME = NULL  
            THEN
                RAISE e_cadastro_invalido;
        END IF;
    
        EXCEPTION        
            WHEN e_cadastro_invalido
                THEN  raise_application_error(-20001,'Nome de projeto inv�lido! Deve ter dois ou mais caracteres.');
            WHEN e_null THEN
                raise_application_error(-20002, 'Nome de projeto inv�lido! Deve ter dois ou mais caracteres.');
             WHEN DUP_VAL_ON_INDEX then
                RAISE_APPLICATION_ERROR(-20003, 'ID j� cadastrado!!!');
            WHEN OTHERS
                THEN
                DBMS_OUTPUT.PUT_LINE('ERRO Oralcle: ' || SQLCODE || SQLERRM);
    END;

    PROCEDURE define_atribuicao
        (p_nome_colaborador IN brh.colaborador.nome%type,
         p_nome_projeto IN brh.projeto.nome%type,
         p_nome_papel IN brh.papel.nome%type)
    IS
        v_colaborador brh.colaborador.matricula%type;
        v_projeto brh.projeto.id%type;
        v_papel brh.papel.id%type;
    BEGIN
    
        BEGIN
           SELECT matricula
             INTO v_colaborador
             FROM brh.colaborador
            WHERE nome = p_nome_colaborador;
            EXCEPTION 
                WHEN no_data_found THEN
                    raise_application_error(-20001, 'Colaborador inexistente: ' || p_nome_colaborador);
        END; 
        BEGIN
            SELECT id
              INTO v_projeto
              FROM brh.projeto
             WHERE nome = p_nome_projeto;
            EXCEPTION 
                WHEN no_data_found THEN
                    raise_application_error(-20002, 'Projeto inexistente: ' || p_nome_projeto);      
         END;  
         BEGIN
                SELECT id
                  INTO v_papel
                  FROM brh.papel
                 WHERE nome = p_nome_papel;          
                EXCEPTION 
                    WHEN no_data_found THEN
                        INSERT INTO brh.papel (NOME) VALUES (p_nome_papel) RETURN id INTO v_papel;                  
         END;
         
         INSERT INTO brh.atribuicao (COLABORADOR, PROJETO, PAPEL)
         VALUES
            (v_colaborador, v_projeto, v_papel);
        EXCEPTION
           WHEN DUP_VAL_ON_INDEX then
               RAISE_APPLICATION_ERROR(-20003, 'N�o foi poss�vel inserir, Colaborador j� foi atribuido a esse projeto e papel!!!');
            WHEN OTHERS
                THEN
                DBMS_OUTPUT.PUT_LINE('ERRO Oralcle: ' || SQLCODE || SQLERRM);      
    END;

END;


--Criar sin�nimo 
CREATE PUBLIC SYNONYM pkg_projeto FOR brh.pkg_projeto;

--Executando a PACKAGE 
SET SERVEROUTPUT ON;
EXECUTE PKG_PROJETO.INSERE_PROJETO(9, 'NEW', 'T123', SYSDATE);      --ID e Nome devem ser Unico

SELECT * FROM brh.projeto;


--Executando as FUNCTIONS da PACKAGE
SET SERVEROUTPUT ON
--Calcula_Idade
SELECT PKG_PROJETO.calcula_idade(TO_DATE('11/09/2010', 'dd/mm/yyyy')) FROM DUAL;

--Fizaliza_Projeto
SELECT PKG_PROJETO.FINALIZA_PROJETO(4) FROM DUAL;


--------------------------------------------------------------------------------
/*--Criar define_atribuicao
Criar a procedure brh.define_atribuicao para inserir um colaborador num projeto em um determinado papel.

Par�metros da procedure
Nome do colaborador: varchar com o nome do colaborador a ser designado;
Nome do projeto: varchar com nome do projeto que o colaborador atuar�;
Nome do papel: varchar com nome do papel a ser exercido pelo colaborador.

Crit�rios de aceita��o
* Se o colaborador n�o existir, lan�ar exce��o com a mensagem _"Colaborador inexistente: <NOME_DO_COLABORADOR_RECEBIDO>.";
* Se o projeto n�o existir, lan�ar exce��o com a mensagem _"Projeto inexistente: <NOME_DO_PROJETO_RECEBIDO>.";
* Se o papel n�o existir, cadastrar novo papel com o nome recebido e utiliz�-lo na atribui��o;
* Crie a procedure na package brh.pkg_projeto, caso tenha feito a tarefa anterior.
*/
CREATE OR REPLACE PROCEDURE brh.define_atribuicao
    (p_nome_colaborador IN brh.colaborador.nome%type,
     p_nome_projeto IN brh.projeto.nome%type,
     p_nome_papel IN brh.papel.nome%type)
IS
    v_colaborador brh.colaborador.matricula%type;
    v_projeto brh.projeto.id%type;
    v_papel brh.papel.id%type;
BEGIN

    BEGIN
       SELECT matricula
         INTO v_colaborador
         FROM brh.colaborador
        WHERE nome = p_nome_colaborador;
        EXCEPTION 
            WHEN no_data_found THEN
                raise_application_error(-20001, 'Colaborador inexistente: ' || p_nome_colaborador);
    END; 
    BEGIN
        SELECT id
          INTO v_projeto
          FROM brh.projeto
         WHERE nome = p_nome_projeto;
        EXCEPTION 
            WHEN no_data_found THEN
                raise_application_error(-20002, 'Projeto inexistente: ' || p_nome_projeto);      
     END;  
     BEGIN
            SELECT id
              INTO v_papel
              FROM brh.papel
             WHERE nome = p_nome_papel;          
            EXCEPTION 
                WHEN no_data_found THEN
                    INSERT INTO brh.papel (NOME) VALUES (p_nome_papel) RETURN id INTO v_papel;                  
     END;
     
     INSERT INTO brh.atribuicao (COLABORADOR, PROJETO, PAPEL)
     VALUES
        (v_colaborador, v_projeto, v_papel);
    EXCEPTION
       WHEN DUP_VAL_ON_INDEX then
           RAISE_APPLICATION_ERROR(-20003, 'N�o foi poss�vel inserir, Colaborador j� foi atribuido a esse projeto e papel!!!');
       WHEN OTHERS
                THEN
                DBMS_OUTPUT.PUT_LINE('ERRO Oralcle: ' || SQLCODE || SQLERRM);    
END;

SET SERVEROUTPUT ON;
EXECUTE brh.define_atribuicao('Ana', 'BRH', 'tecnico');

--Executa pela PACKAGE
EXECUTE pkg_projeto.define_atribuicao('Bia', 'Comex', 'Analista');









