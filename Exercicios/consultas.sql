/* Filtrar dependentes

Criar uma consulta que liste os dependentes que nasceram em abril, maio ou junho, ou tenha a letra "h" no nome.

Crit�rios de aceita��o
1- Ordene primeiramente pelo nome do colaborador, depois pelo nome do dependente.
*/
SELECT c.nome Colaborador,
       d.nome Dependente,
       to_char(d.data_nascimento, 'dd/mm/yyyy') AS Data_Nascimento_Dependente
  FROM brh.dependente d 
  INNER JOIN brh.colaborador c
    ON c.matricula = d.colaborador
    WHERE to_char(d.data_nascimento, 'MM') IN (04, 05, 06)
        OR UPPER(d.nome) LIKE '%H'
    ORDER BY c.nome, d.nome;
 
    
    
/*--Listar colaborador com maior sal�rio
Criar consulta que liste nome e o sal�rio do colaborador com o maior sal�rio.

**OBS.: A consulta deve ser flex�vel para continuar funcionando caso surja algum funcion�rio com sal�rio maior que o do Zico.
*/
SELECT c.nome,
       c.salario
  FROM brh.colaborador c
    WHERE salario = (SELECT MAX(salario) FROM brh.colaborador)
    ORDER BY c.salario DESC;



/*Relat�rio de senioridade
Criar uma consulta que liste a matr�cula, nome, sal�rio, e n�vel de senioridade do colaborador.

A senioridade dos colaboradores determina a faixa salarial:

 -J�nior: at� R$ 3.000,00;
 -Pleno: R$ 3.000,01 a R$ 6.000,00;
 -S�nior: R$ 6.000,01 a R$ 20.000,00;
 -Corpo diretor: acima de R$ 20.000,00.

Regras de aceita��o
 -Ordene a listagem por senioridade e por nome.
*/
SELECT matricula,
       nome,
       salario,
    CASE WHEN salario <= 3000 THEN 'J�nior' 
         WHEN salario > 3000 AND salario <= 6000 THEN 'Pleno'
         WHEN salario > 6000 AND salario <= 20000 THEN 'S�nior'
    ELSE
     'Corpo diretor'
    END AS SENIORIDADE
  FROM brh.colaborador
  ORDER BY senioridade, nome;
    


/*Listar colaboradores em projetos
Criar consulta que liste o nome do departamento, nome do projeto e quantos colaboradores daquele departamento fazem parte do projeto.

Regras de aceita��o
 -Ordene a consulta pelo nome do departamento e nome do projeto.
*/
SELECT d.nome Departamento,
       pj.nome Projeto,
       COUNT(*) 
  FROM brh.departamento d
    INNER JOIN brh.colaborador c
        ON c.departamento = d.sigla
    INNER JOIN brh.atribuicao a
        ON c.matricula = a.colaborador
    INNER JOIN brh.projeto pj
        ON a.projeto = pj.id
    GROUP BY d.nome, pj.nome
    ORDER BY d.nome, pj.nome;



/* Listar colaboradores com mais dependentes
Criar consulta que liste nome do colaborador e a quantidade de dependentes que ele possui.

Regras de aceita��o
  -No relat�rio deve ter somente colaboradores com 2 ou mais dependentes.
  -Ordenar consulta pela quantidade de dependentes em ordem decrescente, e colaborador crescente.
*/
SELECT c.nome Colaborador,
       COUNT(*) quantidade_dependente
  FROM brh.colaborador c
    INNER JOIN brh.dependente d
        ON d.colaborador = c.matricula
    GROUP BY c.nome
    HAVING COUNT(*) >= 2
    ORDER BY quantidade_dependente DESC, c.nome;
    
SELECT * FROM (
    SELECT c.nome colaborador,
           COUNT(*) quantidade_dependentes
        FROM brh.colaborador c 
        INNER JOIN brh.dependente d
            ON c.matricula = d.colaborador
        GROUP BY c.nome
    ) dependentes_colaborador
    WHERE quantidade_dependentes >= 2
    ORDER BY quantidade_dependentes DESC, colaborador;
    
    
/* Listar faixa et�ria dos dependentes
Criar consulta que liste o CPF do dependente, o nome do dependente, a data de nascimento (formato brasileiro), parentesco, matr�cula do colaborador, a idade do dependente e sua faixa et�ria.

Regras de aceita��o
 -Se o dependente tiver menos de 18 anos, informar a faixa et�ria Menor de idade;
 -Se o dependente tiver 18 anos ou mais, informar faixa et�ria Maior de idade;
 -Ordenar consulta por matr�cula do colaborador e nome do dependente.
*/
 SELECT d.cpf CPF_Dependente,
        d.nome Dependente,
        TO_CHAR(d.data_nascimento, 'dd/mm/yyyy') Data_Nascimento,
        d.parentesco,
        c.matricula Matricula_Colaborador,
        NVL(FLOOR((MONTHS_BETWEEN(SYSDATE, data_nascimento) / 12)), 0) idade,
            CASE 
              WHEN NVL(FLOOR ((MONTHS_BETWEEN(SYSDATE, data_nascimento) /12)),0) < 18 THEN 
                'Menor de Idade' 
               ELSE
                'Maior de Idade'               
            END faixa_etaria           
  FROM brh.dependente d
    INNER JOIN brh.colaborador c
        ON d.colaborador = c.matricula
  ORDER BY c.matricula, d.nome;
  
SELECT colaborador,
       cpf,
       nome,
       data_nascimento,
       parentesco,
       NVL(FLOOR((MONTHS_BETWEEN(SYSDATE, data_nascimento)) / 12), 0) idade,
       'Menor de idade' AS faixa_etaria
    FROM brh.dependente
    WHERE NVL(FLOOR((MONTHS_BETWEEN(SYSDATE, data_nascimento)) / 12), 0) < 18
    UNION
SELECT colaborador,
       cpf,
       nome,
       data_nascimento,
       parentesco,
       NVL(FLOOR((MONTHS_BETWEEN(SYSDATE, data_nascimento)) / 12), 0) idade,
       'Maior de idade'
    FROM brh.dependente
        WHERE NVL(FLOOR((MONTHS_BETWEEN(SYSDATE, data_nascimento)) / 12), 0) >= 18
        ORDER BY colaborador ,nome;  
  
--Analisar necessidade de criar view
CREATE OR REPLACE VIEW VW_COLABORADOR_ALOCADO 
 AS
  SELECT c.nome Colaborador,
       c.matricula,
       d.nome Departamento,
       pj.nome Projeto
  FROM brh.departamento d
    INNER JOIN brh.colaborador c
        ON c.departamento = d.sigla
    INNER JOIN brh.atribuicao a
        ON c.matricula = a.colaborador
    INNER JOIN brh.projeto pj
        ON a.projeto = pj.id ;

SELECT * FROM brh.VW_COLABORADOR_ALOCADO;

--Exerc�cio: Listar colaboradores em projetos, 
--Utilizando View, Departamento e Projeto em que o Colaborador est� alocado
SELECT vw_alocado.departamento Departamento,
       vw_alocado.projeto Projeto,
       COUNT(*) 
  FROM(SELECT * FROM brh.vw_colaborador_alocado) vw_alocado
  GROUP BY vw_alocado.departamento, vw_alocado.projeto 
  ORDER BY vw_alocado.departamento, vw_alocado.projeto;
 
 
    
/* Relat�rio de plano de sa�de
O usu�rio quer saber quanto � a mensalidade que cada colaborador deve pagar ao plano de sa�de. As regras de pagamento s�o:

Cada n�vel de senioridade tem um percentual de contribui��o diferente:
  -J�nior paga 1% do sal�rio;
  -Pleno paga 2% do sal�rio;
  -S�nior paga 3% do sal�rio;
  -Corpo diretor paga 5% do sal�rio.
  
Cada tipo de dependente tem um valor adicional diferente:
  -C�njuge acrescenta R$ 100,00 na mensalidade;
  -Maior de idade acrescenta R$ 50,00 na mensalidade;
  -Menor de idade acrescenta R$ 25,00 na mensalidade.
  
O valor a ser pago � a soma do percentual definido pela senioridade mais o valor de cada dependente do colaborador.
*/
SELECT plano.colab AS colaborador,
        SUM(plano.dependente_pagar) + plano.senioridade_pagar AS valor_total
FROM
    (SELECT c.nome AS colab,
    (CASE  WHEN d.parentesco = 'Cônjuge' THEN 100
           WHEN  NVL(Floor(Months_Between(SYSDATE,d.data_nascimento)/12),0) >= 18 THEN 50
           ELSE 25           
      END) AS dependente_pagar,
      (CASE WHEN c.salario <= 3000 THEN salario * 0.01
          WHEN c.salario <= 6000 THEN salario * 0.02
          WHEN c.salario <= 20000 THEN salario * 0.03
     ELSE
          c.salario * 0.05
     END) AS senioridade_pagar
     FROM brh.colaborador c
    INNER JOIN brh.dependente d
        ON d.colaborador = c.matricula) plano
GROUP BY plano.colab, plano.senioridade_pagar
ORDER BY plano.colab;
 
 
 
/* Paginar listagem de colaboradores
O usu�rio quer paginar a listagem de colaboradores em p�ginas de 10 registros cada. H� 26 colaboradores na base, ent�o h� 3 p�ginas:

P�gina 1: da Ana ao Jo�o (registros 1 ao 10);
P�gina 2: da Kelly � Tati (registros 11 ao 20); e
P�gina 3: do Uri ao Zico (registros 21 ao 26).

OBS.: pense que novos registros podem ser inclusos � tabela; logo, a consulta n�o deve levar em considera��o matr�cula, etc.
*/

--P�gina 1: da Ana ao Jo�o (registros 1 ao 10);
 SELECT * FROM 
  (SELECT rownum as linha, c.*
   FROM brh.colaborador c) consulta_paginada
    WHERE linha >= 1 AND linha <= 10
    ORDER BY nome; 
    
--P�gina 2: da Kelly � Tati (registros 11 ao 20);    
SELECT * FROM 
  (SELECT rownum as linha, c.*
   FROM brh.colaborador c) consulta_paginada
    WHERE linha >= 11 AND linha <= 20
    ORDER BY nome;
    
--P�gina 3: do Uri ao Zico (registros 21 ao 26)  
SELECT * FROM 
  (SELECT rownum as linha, c.*
   FROM brh.colaborador c) consulta_paginada
    WHERE linha >= 21 AND linha <= 30
    ORDER BY nome;
 
 
 
/* Listar colaboradores que participaram de todos os projetos
Crie um relat�rio que informe os colaboradores que participaram de todos os projetos.

OBS.: Pense que novos projetos podem ser cadastrados, ent�o a consulta n�o deve ser fixada somente aos projetos atuais, mas ser flex�vel para projetos futuros.
*/
SELECT c.matricula,
       COUNT(atr.projeto) AS Qtd_Projetos
  FROM brh.colaborador c
  INNER JOIN brh.atribuicao atr
    ON atr.colaborador = c.matricula 
  GROUP BY c.matricula
  HAVING COUNT(atr.projeto) = (SELECT COUNT(*) FROM brh.projeto pj); 
 
 
 
 
 

