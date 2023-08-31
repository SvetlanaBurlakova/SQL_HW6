USE lesson_4;

/* 1. Создайте таблицу users_old, аналогичную таблице users. Создайте процедуру, 
с помощью которой можно переместить любого (одного) пользователя из таблицы users 
в таблицу users_old. (использование транзакции с выбором commit или rollback – обязательно). */

DROP TABLE IF EXISTS users_old;
CREATE TABLE users_old (
    id INT PRIMARY KEY, 
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    email VARCHAR(120) UNIQUE
);

DROP PROCEDURE IF EXISTS sp_user_move;
DELIMITER //
CREATE PROCEDURE sp_user_move(id_move INT,	
	OUT result VARCHAR(30))
BEGIN
    DECLARE id_move_in_users BOOL;

	START TRANSACTION;
	SET id_move_in_users = EXISTS(SELECT id FROM users WHERE id = id_move);

	IF id_move_in_users = 1 THEN
        	INSERT INTO users_old (id, firstname, lastname, email)
		SELECT id, firstname, lastname, email
		  FROM users
        	WHERE id = id_move;
        	SET result = "User moved!";
		COMMIT;
	ELSE
		SET result = "User not moved!";
        	ROLLBACK;
	END IF;
END//
DELIMITER ;

CALL sp_user_move(10, @result); 
SELECT @result;

SELECT * FROM users_old;

/* 2. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от 
текущего времени суток. С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 
до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 
— "Доброй ночи". */

DROP FUNCTION IF EXISTS hello;
DELIMITER //
CREATE FUNCTION hello()
RETURNS VARCHAR(50) READS SQL DATA
BEGIN
	DECLARE time_now TIME; -- заявок к пользователю

	SET time_now = (
		SELECT NOW());
	IF (HOUR(time_now) >= 0) AND (HOUR(time_now) < 6) THEN
		RETURN "Доброй ночи"; 
	ELSEIF (HOUR(time_now) >= 6) AND (HOUR(time_now) < 12) THEN
		RETURN "Доброе утро";
	ELSEIF (HOUR(time_now) >= 12) AND (HOUR(time_now) < 18) THEN
		RETURN "Добрый день";
	ELSE
		RETURN "Добрый вечер";        
	END IF;
END//
DELIMITER ;

SELECT hello() AS "Приветствие";

/* 3. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, communities и messages 
в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа. */

DROP TABLE IF EXISTS archive;
CREATE TABLE archive (
    time_add DATETIME, 
    table_name VARCHAR(50),
    id INT
);

DELIMITER //
CREATE TRIGGER after_users_insert
AFTER INSERT
ON users FOR EACH ROW
BEGIN
	INSERT INTO archive(time_add, table_name, id)
        VALUES(NOW(), "users", new.id);
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_communities_insert
AFTER INSERT
ON communities FOR EACH ROW
BEGIN
	INSERT INTO archive(time_add, table_name, id)
        VALUES(NOW(), "communities", new.id);
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_messages_insert
AFTER INSERT
ON messages FOR EACH ROW
BEGIN
	INSERT INTO archive(time_add, table_name, id)
        VALUES(NOW(), "messages", new.id);
END//
DELIMITER ;

INSERT INTO users(firstname, lastname, email)
		VALUES ("Петр", "Петров", "petrov_4@email");
    
INSERT INTO communities(name)
		VALUES ("community123");
        
INSERT INTO messages(from_user_id, to_user_id,body,created_at)
		VALUES (2,5,"Message", "2023-07-12 09:15:20");
        
SELECT * 
	FROM archive;
        
