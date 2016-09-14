
CREATE TABLE GAME.POKEMON
(
  POKE_NAME  VARCHAR2(10 BYTE),
  PRICE      NUMBER(10,3)
)

SET DEFINE OFF;
Insert into GAME.POKEMON
   (POKE_NAME, PRICE)
 Values
   ('Pikachu', 6);
Insert into GAME.POKEMON
   (POKE_NAME, PRICE)
 Values
   ('Charmander', 5);
Insert into GAME.POKEMON
   (POKE_NAME, PRICE)
 Values
   ('Squirtle', 5);
COMMIT;

CREATE TABLE GAME.OFFER
(
  DIFF_POKEMON  NUMBER(10),
  OFFERS_PER    NUMBER(10)
)
SET DEFINE OFF;
Insert into GAME.OFFER
   (DIFF_POKEMON, OFFERS_PER)
 Values
   (1, 0);
Insert into GAME.OFFER
   (DIFF_POKEMON, OFFERS_PER)
 Values
   (2, 10);
Insert into GAME.OFFER
   (DIFF_POKEMON, OFFERS_PER)
 Values
   (3, 20);
COMMIT;
CREATE TABLE GAME.SALES
(
  USERID    NUMBER,
  POKEMON   VARCHAR2(20 BYTE),
  QUANTITY  NUMBER
)
SET DEFINE OFF;
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (1, 'PIKACHU', 1);
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (2, 'PIKACHU', 2);
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (3, 'PIKACHU', 1);
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (3, 'SQUIRTLE', 1);
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (4, 'PIKACHU', 2);
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (4, 'SQUIRTLE', 2);
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (5, 'PIKACHU', 3);
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (5, 'SQUIRTLE', 3);
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (6, 'PIKACHU', 2);
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (6, 'SQUIRTLE', 1);
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (7, 'PIKACHU', 1);
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (7, 'SQUIRTLE', 1);
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (7, 'CHARMANDER', 1);
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (8, 'PIKACHU', 2);
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (8, 'SQUIRTLE', 1);
Insert into GAME.SALES
   (USERID, POKEMON, QUANTITY)
 Values
   (8, 'CHARMANDER', 1);
COMMIT;
WITH POKEMON1
     AS (SELECT P1.USERID,
                NVL (P1.QUANTITY, 0) P_QUANTITY,
                NVL (S.QUANTITY, 0) S_QUANTITY,
                NVL (C.QUANTITY, 0) C_QUANTITY
           FROM (SELECT USERID, QUANTITY, PRICE
                   FROM SALES A, POKEMON B
                  WHERE     A.POKEMON = UPPER (B.POKE_NAME)
                        AND A.POKEMON = 'PIKACHU') P1
                FULL OUTER JOIN (SELECT USERID, QUANTITY, PRICE
                                   FROM SALES A, POKEMON B
                                  WHERE     A.POKEMON = UPPER (B.POKE_NAME)
                                        AND A.POKEMON = 'SQUIRTLE') S
                   ON P1.USERID = S.USERID
                FULL OUTER JOIN (SELECT USERID, QUANTITY, PRICE
                                   FROM SALES A, POKEMON B
                                  WHERE     A.POKEMON = UPPER (B.POKE_NAME)
                                        AND A.POKEMON = 'CHARMANDER') C
                   ON P1.USERID = C.USERID)
SELECT AMOUNT.USERID,
       AMOUNT.COST_BEFORE_DISCOUNT,
       (  AMOUNT.COST_BEFORE_DISCOUNT
        - (  OFFER.OFFERS_PER
           * 0.01
           * (AMOUNT.COST_BEFORE_DISCOUNT - DIFF.DIFF_PRICE)))
          "COST_AFTER_DISCOUNT"
  FROM (  SELECT USERID, SUM (COST) "COST_BEFORE_DISCOUNT"
            FROM (SELECT A.*, B.PRICE, A.QUANTITY * B.PRICE "COST"
                    FROM SALES A, POKEMON B
                   WHERE A.POKEMON = UPPER (B.POKE_NAME))
        GROUP BY USERID) "AMOUNT",
       (  SELECT USERID, COUNT (*) "DISTINCT_POKEMON"
            FROM SALES
        GROUP BY USERID) "D_POKEMON",
       OFFER,
       (SELECT A.USERID,
               CASE
                  WHEN A.DISTINCT_POKEMON = 1
                  THEN
                     0
                  WHEN A.DISTINCT_POKEMON = 2
                  THEN
                     CASE
                        WHEN S.QUANTITY = 0
                        THEN
                           CASE
                              WHEN P1.QUANTITY > C.QUANTITY
                              THEN
                                 ( (P1.QUANTITY - C.QUANTITY) * P1.PRICE)
                              WHEN P1.QUANTITY < C.QUANTITY
                              THEN
                                 ( (C.QUANTITY - P1.QUANTITY) * C.PRICE)
                              ELSE
                                 0
                           END
                        WHEN C.QUANTITY = 0
                        THEN
                           CASE
                              WHEN P1.QUANTITY > S.QUANTITY
                              THEN
                                 ( (P1.QUANTITY - S.QUANTITY) * P1.PRICE)
                              WHEN P1.QUANTITY < C.QUANTITY
                              THEN
                                 ( (S.QUANTITY - P1.QUANTITY) * S.PRICE)
                              ELSE
                                 0
                           END
                        WHEN P1.QUANTITY = 0
                        THEN
                           CASE
                              WHEN C.QUANTITY > S.QUANTITY
                              THEN
                                 ( (C.QUANTITY - S.QUANTITY) * C.PRICE)
                              WHEN C.QUANTITY < S.QUANTITY
                              THEN
                                 ( (S.QUANTITY - C.QUANTITY) * S.PRICE)
                              ELSE
                                 0
                           END
                        ELSE
                           0
                     END
                  WHEN A.DISTINCT_POKEMON = 3
                  THEN
                     CASE
                        WHEN     S.QUANTITY = P1.QUANTITY
                             AND S.QUANTITY = C.QUANTITY
                        THEN
                           0
                        WHEN     S.QUANTITY = P1.QUANTITY
                             AND S.QUANTITY <> C.QUANTITY
                        THEN
                           CASE
                              WHEN C.QUANTITY > S.QUANTITY
                              THEN
                                 ( (C.QUANTITY - S.QUANTITY) * C.PRICE)
                              WHEN C.QUANTITY < S.QUANTITY
                              THEN
                                 ( (S.QUANTITY - C.QUANTITY) * S.PRICE)
                              ELSE
                                 0
                           END
                        WHEN     S.QUANTITY = C.QUANTITY
                             AND S.QUANTITY <> P1.QUANTITY
                        THEN
                           CASE
                              WHEN P1.QUANTITY > S.QUANTITY
                              THEN
                                 ( (P1.QUANTITY - S.QUANTITY) * P1.PRICE)
                              WHEN P1.QUANTITY < C.QUANTITY
                              THEN
                                 ( (S.QUANTITY - P1.QUANTITY) * S.PRICE)
                              ELSE
                                 0
                           END
                        WHEN     C.QUANTITY = P1.QUANTITY
                             AND S.QUANTITY <> C.QUANTITY
                        THEN
                           CASE
                              WHEN C.QUANTITY > S.QUANTITY
                              THEN
                                 ( (C.QUANTITY - S.QUANTITY) * C.PRICE)
                              WHEN C.QUANTITY < S.QUANTITY
                              THEN
                                 ( (S.QUANTITY - C.QUANTITY) * S.PRICE)
                              ELSE
                                 0
                           END
                        WHEN     C.QUANTITY <> P1.QUANTITY
                             AND S.QUANTITY <> C.QUANTITY
                        THEN
                           CASE
                              WHEN     C.QUANTITY > P1.QUANTITY
                                   AND C.QUANTITY > S.QUANTITY
                              THEN
                                 CASE
                                    WHEN P1.QUANTITY > S.QUANTITY
                                    THEN
                                       (C.QUANTITY - P1.QUANTITY) * C.PRICE
                                    WHEN P1.QUANTITY < S.QUANTITY
                                    THEN
                                       (C.QUANTITY - S.QUANTITY) * C.PRICE
                                 END
                              WHEN     P1.QUANTITY > C.QUANTITY
                                   AND P1.QUANTITY > S.QUANTITY
                              THEN
                                 CASE
                                    WHEN S.QUANTITY > C.QUANTITY
                                    THEN
                                       (P1.QUANTITY - S.QUANTITY) * P1.PRICE
                                    WHEN S.QUANTITY < C.QUANTITY
                                    THEN
                                       (P1.QUANTITY - C.QUANTITY) * P1.PRICE
                                 END
                              WHEN     S.QUANTITY > P1.QUANTITY
                                   AND S.QUANTITY > C.QUANTITY
                              THEN
                                 CASE
                                    WHEN P1.QUANTITY > C.QUANTITY
                                    THEN
                                       (S.QUANTITY - P1.QUANTITY) * S.PRICE
                                    WHEN P1.QUANTITY < C.QUANTITY
                                    THEN
                                       (S.QUANTITY - C.QUANTITY) * S.PRICE
                                 END
                           END
                     END
               END
                  "DIFF_PRICE"
          FROM (  SELECT USERID, COUNT (*) "DISTINCT_POKEMON"
                    FROM SALES
                GROUP BY USERID) A,
               (SELECT USERID, P_QUANTITY QUANTITY, PRICE
                  FROM POKEMON A, POKEMON1 B
                 WHERE UPPER (A.POKE_NAME) = 'PIKACHU') P1,
               (SELECT USERID, S_QUANTITY QUANTITY, PRICE
                  FROM POKEMON A, POKEMON1 B
                 WHERE UPPER (A.POKE_NAME) = 'SQUIRTLE') S,
               (SELECT USERID, C_QUANTITY QUANTITY, PRICE
                  FROM POKEMON A, POKEMON1 B
                 WHERE UPPER (A.POKE_NAME) = 'CHARMANDER') C
         WHERE     P1.USERID = S.USERID
               AND P1.USERID = C.USERID
               AND P1.USERID = A.USERID) "DIFF"
 WHERE     OFFER.DIFF_POKEMON = D_POKEMON.DISTINCT_POKEMON
       AND D_POKEMON.USERID = AMOUNT.USERID
       AND DIFF.USERID = AMOUNT.USERID  ORDER BY USERID