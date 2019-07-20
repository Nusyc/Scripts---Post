-- INSERINDO DADOS PARA TESTE.
use REMOVENDO_EAGERSPOOL

-- EXEMPLO 1

IF OBJECT_ID('TEMPDB..#RESULTADO_FINAL') IS NOT NULL DROP TABLE #RESULTADO_FINAL
IF OBJECT_ID('TEMPDB..#TABELA_AUXILIAR') IS NOT NULL DROP TABLE #TABELA_AUXILIAR

-- INDICE

SELECT
*
INTO #RESULTADO_FINAL
FROM
	FactProductInventory

CREATE NONCLUSTERED INDEX IX_EAGER ON #RESULTADO_FINAL (DateKey,ProductKey)
INCLUDE (MovementDate, UnitCost, UnitsIn, UnitsOut, UnitsBalance)

--- EXEMPLO 1 

-- CONSULTA EM QUESTÃO

BEGIN TRAN

INSERT INTO #RESULTADO_FINAL (ProductKey,DateKey, MovementDate, UnitCost, UnitsIn, UnitsOut, UnitsBalance)
SELECT
	ProductKey,DateKey, MovementDate, UnitCost, UnitsIn, UnitsOut, UnitsBalance
FROM
	FactProductInventory
WHERE
	 EXISTS (
				SELECT * FROM #RESULTADO_FINAL 
				WHERE FactProductInventory.ProductKey = ProductKey
				AND FactProductInventory.DateKey = DateKey 
			)
OPTION (MAXDOP 1)

ROLLBACK 
----------------------------------------------
-------------- FIM ---------------------------
----------------------------------------------

-- SOLUÇÃO APLICADA.

SELECT
	ProductKey,DateKey, MovementDate, UnitCost, UnitsIn, UnitsOut, UnitsBalance

	INTO #TABELA_AUXILIAR

FROM
	FactProductInventory
WHERE
	 EXISTS (
				SELECT * FROM #RESULTADO_FINAL 
				WHERE FactProductInventory.ProductKey = ProductKey
				AND FactProductInventory.DateKey = DateKey 
			)
OPTION(MAXDOP 1)

INSERT INTO #RESULTADO_FINAL (ProductKey,DateKey, MovementDate, UnitCost, UnitsIn, UnitsOut, UnitsBalance)
SELECT ProductKey,DateKey, MovementDate, UnitCost, UnitsIn, UnitsOut, UnitsBalance 
FROM
	#TABELA_AUXILIAR
OPTION(MAXDOP 1)





