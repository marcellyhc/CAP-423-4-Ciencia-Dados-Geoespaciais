------------------------------------------------------------------------------------------------------
-- INSTITUTO NACIONAL DE PESQUISAS ESPACIAIS - INPE

-- Programa de Pós-Graduação em Computação Aplicada - CAP

-- CAP-423-4: Ciência de Dados Geoespaciais

-- Aluna: Marcelly Homem Coelho

------------------------------------------------------------------------------------------------------
ALTER TABLE table_name 
DROP COLUMN column_name;

------------------------------------------------------------------------------------------------------

-- Importar o arquivo shapefile para o banco de dados.
-- O arquivo conjunto_completo_entorno_221_065_2018 foi disponibilizado pelo Programa Queimadas do INPE.


-- Verificar quais são as classes rotuladas.
SELECT DISTINCT classe 
FROM conjunto_completo_entorno_221_065_2018

-- Output: 
-- queimada
-- nao_queimada

-- Verificar a quantidade de polígonos queimados
SELECT COUNT(*) AS qtd_polig_queimado
FROM conjunto_completo_entorno_221_065_2018
WHERE classe = 'queimada'

-- Output:
-- qtd_polig_queimado
-- 40523

-- Verificar a quantidade de polígonos não queimados
SELECT COUNT(*) AS qtd_polig_nqueimado
FROM conjunto_completo_entorno_221_065_2018
WHERE classe = 'nao_queimada'

-- Output:
-- qtd_polig_nqueimado
-- 84324


-- Criar uma tabela com todos os dados.
CREATE TABLE table_CAP423 AS
SELECT *
FROM conjunto_completo_entorno_221_065_2018


-- Calcular a área dos polígonos 
-- Criar uma nova coluna do tipo float
ALTER TABLE table_CAP423
ADD area_km2 float(10)

-- Atribuir o valor de área 
UPDATE table_CAP423
SET area_km2 = (ST_Area(geom) / 1000000.0)


-- Calcular o centroide de cada polígono
-- Criar uma nova coluna do tipo geometry
ALTER TABLE table_CAP423
ADD COLUMN centroide_poligono geometry(Geometry,4326)
	
-- Atribuir o valor do centroide 
UPDATE table_CAP423
SET centroide_poligono = ST_Centroid(geom)


-- Selecionar 10 polígonos queimados com maior área.
CREATE TABLE table_area_queimada_CAP423 AS
SELECT *
FROM table_CAP423
WHERE classe = 'queimada' AND 
	  op = '220_066' 
ORDER BY area_km2 DESC
LIMIT 10


-- Selecionar 10 polígonos não queimados com maior área.
CREATE TABLE table_area_nqueimada_CAP423 AS
SELECT *
FROM table_CAP423
WHERE classe = 'nao_queimada' AND
      op = '220_066'
ORDER BY area_km2 DESC
LIMIT 10


-- Sortear 15 pontos dentro dos polígonos queimados
CREATE TABLE table_pontos_aleatorio_area_queimada_CAP423 AS	
SELECT row_number() over() AS gid, geom, aqm_id, ano, op, data_atual, classe
FROM(
SELECT (ST_DumpPoints(ST_GeneratePoints(geom, 15))).geom AS geom,
	   id AS aqm_id,
	   table_area_queimada_CAP423.ano AS ano,
	   table_area_queimada_CAP423.op AS op,
	   table_area_queimada_CAP423.data_atual AS data_atual,
	   table_area_queimada_CAP423.classe AS classe	
from table_area_queimada_CAP423) AS FOO


-- Criar duas colunas para receber as informações (x, y) = (long, lat) de um atributo geom
ALTER TABLE table_pontos_aleatorio_area_queimada_CAP423
ADD COLUMN x double precision; 

ALTER TABLE table_pontos_aleatorio_area_queimada_CAP423
ADD COLUMN y double precision;

UPDATE table_pontos_aleatorio_area_queimada_CAP423
SET x = st_x(geom),
    y = st_y(geom);
	

-- Sortear 15 pontos dentro dos polígonos não queimados
CREATE TABLE table_pontos_aleatorio_area_nqueimada_CAP423 AS	
SELECT row_number() over() AS gid, geom, aqm_id, ano, op, data_atual, classe
FROM(
SELECT (ST_DumpPoints(ST_GeneratePoints(geom, 15))).geom AS geom,
	   id AS aqm_id,
	   table_area_nqueimada_CAP423.ano AS ano,
	   table_area_nqueimada_CAP423.op AS op,
	   table_area_nqueimada_CAP423.data_atual AS data_atual,
	   table_area_nqueimada_CAP423.classe AS classe	
from table_area_nqueimada_CAP423) AS FOO


-- Criar duas colunas para receber as informações (x, y) = (long, lat) de um atributo geom
ALTER TABLE table_pontos_aleatorio_area_nqueimada_CAP423
ADD COLUMN x double precision; 

ALTER TABLE table_pontos_aleatorio_area_nqueimada_CAP423
ADD COLUMN y double precision;

UPDATE table_pontos_aleatorio_area_nqueimada_CAP423
SET x = st_x(geom),
    y = st_y(geom);
	
	
-- Salvar as duas tabelas em um arquivo do tipo csv



