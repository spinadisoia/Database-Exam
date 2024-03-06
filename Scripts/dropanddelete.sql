SET search_path to 'prova3';

DROP TABLE Sioccupadi CASCADE;
DROP TABLE Finanziamento CASCADE;
DROP TABLE rilevazione CASCADE;
DROP TABLE responsabile CASCADE;
DROP TABLE replica CASCADE;
DROP TABLE gruppo CASCADE;
DROP TABLE sensore CASCADE;
DROP TABLE orto CASCADE;
DROP TABLE specie CASCADE;
DROP TABLE classe CASCADE;
DROP TABLE persona CASCADE;
DROP TABLE scuola CASCADE;

DROP SCHEMA prova3 CASCADE;

-- Per ripopolare --
 
DELETE FROM Sioccupadi;
DELETE FROM Finanziamento;
DELETE FROM rilevazione;
DELETE FROM responsabile;
DELETE FROM replica;
DELETE FROM gruppo;
DELETE FROM sensore;
DELETE FROM orto;
DELETE FROM specie;
DELETE FROM classe;
DELETE FROM scuola;
DELETE FROM persona;
