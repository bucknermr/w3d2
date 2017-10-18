CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  replies_id INTEGER,
  user_id INTEGER NOT NULL,
  body VARCHAR(255) NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (replies_id) REFERENCES replies(id)
);

CREATE TABLE  question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ('matthew', 'shmorgaspord'),
  ('michael', 'tiles'),
  ('frioendly', 'cup'),
  ('willie', 'takeawhile'),
  ('fudge', 'smith');

INSERT INTO
  questions(title, body, user_id)
VALUES
  ('help', 'I don''t know what to do?', 2),
  ('how long', 'Will he take one unit of while?', 4),
  ('friendly', 'How do you spell fereoikndfly?', 3),
  ('math', 'what is a unit of while?', 4),
  ('shmorg', 'borg?', 1);

INSERT INTO
  question_follows(user_id, question_id)
VALUES
  (5, 5),
  (5, 1),
  (5, 3),
  (2, 1),
  (2, 5),
  (3, 4),
  (3, 2),
  (1, 3);

INSERT INTO
  replies(question_id, replies_id, user_id, body)
VALUES
  (2, null, 2, 'what is a unit of while?'),
  (2, 1, 1, 'time measured in eons.'),
  (2, 2, 5, 'I''m out of the bathroom.  It''s your turn...'),
  (2, null, 5, 'borg?'),
  (1, null, 3, 'Is that a question?'),
  (1, 5, 5, 'Is taht an answer?'),
  (4, null, 5, 'I think it''s time measured in eons????????'),
  (4, 7, 2, 'Stop trolling brah.'),
  (5, null, 3, 'So what you have to do is fill the coffee cup up to the rim, and then make sure that the coffee is inside, and that''s how I start my days.');

INSERT INTO
  question_likes(user_id, question_id)
VALUES
  (1, 5),
  (5, 5),
  (2, 1),
  (2, 4),
  (2, 3);
