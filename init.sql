CREATE TABLE emberek (
    id TEXT,
    vezeteknev TEXT,
    keresztnev TEXT
);

INSERT INTO emberek (vezeteknev, keresztnev) VALUES ('John', 'Doe');

CREATE TABLE IF NOT EXISTS kor (
    id TEXT,
    ember_id TEXT,
    kor TEXT
);

INSERT INTO kor (id, ember_id, kor) VALUES ('1', '1', '49');