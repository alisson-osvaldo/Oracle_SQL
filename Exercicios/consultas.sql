/* Filtrar dependentes

Criar uma consulta que liste os dependentes que nasceram em abril, maio ou junho, ou tenha a letra "h" no nome.

Critérios de aceitação
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
 
    
    
/*--Listar colaborador com maior salário
Criar consulta que liste nome e o salário do colaborador com o maior salário.

**OBS.: A consulta deve ser flexível para continuar funcionando caso surja algum funcionário com salário maior que o do Zico.
*/
SELECT c.nome,
       c.salario
  FROM brh.colaborador c
    WHERE salario = (SELECT MAX(salario) FROM brh.colaborador)
    ORDER BY c.salario DESC;



/*Relatório de senioridade
Criar uma consulta que liste a matrícula, nome, salário, e nível de senioridade do colaborador.

A senioridade dos colaboradores determina a faixa salarial:

 -Júnior: até R$ 3.000,00;
 -Pleno: R$ 3.000,01 a R$ 6.000,00;
 -Sênior: R$ 6.000,01 a R$ 20.000,00;
 -Corpo diretor: acima de R$ 20.000,00.

Regras de aceitação
 -Ordene a listagem por senioridade e por nome.
*/
SELECT matricula,
       nome,
       salario,
    CASE WHEN salario <= 3000 THEN 'Júnior' 
         WHEN salario > 3000 AND salario <= 6000 THEN 'Pleno'
         WHEN salario > 6000 AND salario <= 20000 THEN 'Sênior'
    ELSE
     'Corpo diretor'
    END AS SENIORIDADE
  FROM brh.colaborador
  ORDER BY senioridade, nome;
    


/*Listar colaboradores em projetos
Criar consulta que liste o nome do departamento, nome do projeto e quantos colaboradores daquele departamento fazem parte do projeto.

Regras de aceitação
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

Regras de aceitação
  -No relatório deve ter somente colaboradores com 2 ou mais dependentes.
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
    
    
/* Listar faixa etária dos dependentes
Criar consulta que liste o CPF do dependente, o nome do dependente, a data de nascimento (formato brasileiro), parentesco, matrícula do colaborador, a idade do dependente e sua faixa etária.

Regras de aceitação
 -Se o dependente tiver menos de 18 anos, informar a faixa etária Menor de idade;
 -Se o dependente tiver 18 anos ou mais, informar faixa etária Maior de idade;
 -Ordenar consulta por matrícula do colaborador e nome do dependente.
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

--Exercício: Listar colaboradores em projetos, 
--Utilizando View, Departamento e Projeto em que o Colaborador está alocado
SELECT vw_alocado.departamento Departamento,
       vw_alocado.projeto Projeto,
       COUNT(*) 
  FROM(SELECT * FROM brh.vw_colaborador_alocado) vw_alocado
  GROUP BY vw_alocado.departamento, vw_alocado.projeto 
  ORDER BY vw_alocado.departamento, vw_alocado.projeto;
 
 
    
/* Relatório de plano de saúde
O usuário quer saber quanto é a mensalidade que cada colaborador deve pagar ao plano de saúde. As regras de pagamento são:

Cada nível de senioridade tem um percentual de contribuição diferente:
  -Júnior paga 1% do salário;
  -Pleno paga 2% do salário;
  -Sênior paga 3% do salário;
  -Corpo diretor paga 5% do salário.
  
Cada tipo de dependente tem um valor adicional diferente:
  -Cônjuge acrescenta R$ 100,00 na mensalidade;
  -Maior de idade acrescenta R$ 50,00 na mensalidade;
  -Menor de idade acrescenta R$ 25,00 na mensalidade.
  
O valor a ser pago é a soma do percentual definido pela senioridade mais o valor de cada dependente do colaborador.
*/
SELECT plano.colab AS colaborador,
        SUM(plano.dependente_pagar) + plano.senioridade_pagar AS valor_total
FROM
    (SELECT c.nome AS colab,
    (CASE  WHEN d.parentesco = 'CÃ´njuge' THEN 100
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
O usuário quer paginar a listagem de colaboradores em páginas de 10 registros cada. Há 26 colaboradores na base, então há 3 páginas:

Página 1: da Ana ao João (registros 1 ao 10);
Página 2: da Kelly à Tati (registros 11 ao 20); e
Página 3: do Uri ao Zico (registros 21 ao 26).

OBS.: pense que novos registros podem ser inclusos à tabela; logo, a consulta não deve levar em consideração matrícula, etc.
*/

--Página 1: da Ana ao João (registros 1 ao 10);
 SELECT * FROM 
  (SELECT rownum as linha, c.*
   FROM brh.colaborador c) consulta_paginada
    WHERE linha >= 1 AND linha <= 10
    ORDER BY nome; 
    
--Página 2: da Kelly à Tati (registros 11 ao 20);    
SELECT * FROM 
  (SELECT rownum as linha, c.*
   FROM brh.colaborador c) consulta_paginada
    WHERE linha >= 11 AND linha <= 20
    ORDER BY nome;
    
--Página 3: do Uri ao Zico (registros 21 ao 26)  
SELECT * FROM 
  (SELECT rownum as linha, c.*
   FROM brh.colaborador c) consulta_paginada
    WHERE linha >= 21 AND linha <= 30
    ORDER BY nome;
 
 
 
/* Listar colaboradores que participaram de todos os projetos
Crie um relatório que informe os colaboradores que participaram de todos os projetos.

OBS.: Pense que novos projetos podem ser cadastrados, então a consulta não deve ser fixada somente aos projetos atuais, mas ser flexível para projetos futuros.
*/
SELECT c.matricula,
       COUNT(atr.projeto) AS Qtd_Projetos
  FROM brh.colaborador c
  INNER JOIN brh.atribuicao atr
    ON atr.colaborador = c.matricula 
  GROUP BY c.matricula
  HAVING COUNT(atr.projeto) = (SELECT COUNT(*) FROM brh.projeto pj); 
 
 
 
 
 

