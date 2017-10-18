require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Question
  attr_accessor :title, :body, :user_id
  attr_reader :id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM questions WHERE id = ?;
    SQL
    Question.new(data.first)
  end

  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT * FROM questions WHERE user_id = ?;
    SQL

    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed(n = 1)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n = 1)
    QuestionLike.most_liked_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def author
    User.find_by_id(@user_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end
end

class User
  attr_accessor :fname, :lname
  attr_reader :id

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT * FROM users WHERE fname = ? AND lname = ?;
    SQL

    data.map { |datum| User.new(datum) }
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM users WHERE id = ?;
    SQL
    User.new(data.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT (COUNT(question_likes.id) / COUNT(questions.id)) AS average_likes
      FROM questions
      JOIN question_likes ON questions.id = question_likes.question_id
      WHERE questions.user_id = ?;
    SQL

    data.first.values.first
  end
end

class QuestionFollow
  attr_accessor :user_id, :question_id
  attr_reader :id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM question_follows WHERE id = ?;
    SQL
    QuestionFollow.new(data.first)
  end

  def self.followers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.*
      FROM users
      JOIN question_follows
        ON question_follows.user_id = users.id
      WHERE question_follows.question_id = ?
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT questions.*
      FROM questions
      JOIN question_follows
        ON question_follows.question_id = questions.id
      WHERE question_follows.user_id = ?
    SQL

    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT questions.*
      FROM questions
      JOIN question_follows
        ON question_follows.question_id = questions.id
      GROUP BY questions.id
      ORDER BY COUNT(question_follows.question_id) DESC
      LIMIT ?;
    SQL

    data.map { |datum| Question.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end

class Reply
  attr_accessor :user_id, :question_id, :replies_id, :body
  attr_reader :id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM replies WHERE id = ?;
    SQL
    Reply.new(data.first)
  end

  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT * FROM replies WHERE user_id = ?;
    SQL

    Reply.new(data.first)
  end

  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT * FROM replies WHERE question_id = ?;
    SQL

    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_replies_id(replies_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, replies_id)
      SELECT * FROM replies WHERE replies_id = ?;
    SQL

    data.map { |datum| Reply.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
    @replies_id = options['replies_id']
    @body = options['body']
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    raise 'Reply has no parent reply' unless @replies_id
    Reply.find_by_id(@replies_id)
  end

  def child_replies
    Reply.find_by_replies_id(@id)
  end
end

class QuestionLike
  attr_accessor :user_id, :question_id
  attr_reader :id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM likes WHERE id = ?;
    SQL

    data.map { |datum| QuestionLike.new(datum) }
  end

  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.*
      FROM users
      JOIN question_likes ON users.id = question_likes.user_id
      WHERE question_likes.question_id = ?
      GROUP BY question_likes.user_id
    SQL

    data.map { |datum| QuestionLike.new(datum) }
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT COUNT(user_id) AS num_likes
      FROM question_likes
      WHERE question_likes.question_id = ?
    SQL

    data.first.values.first
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT questions.*
      FROM questions
      JOIN question_likes ON question_likes.question_id = questions.id
      WHERE question_likes.user_id = ?
    SQL

    data.map { |datum| Question.new(datum) }
  end

  def self.most_liked_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT questions.*
      FROM questions
      JOIN question_likes ON question_likes.question_id = questions.id
      GROUP BY questions.id
      ORDER BY question_likes.question_id DESC
      LIMIT ?;
    SQL

    data.map { |datum| Question.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end











# 
# SELECT (COUNT(question_likes.qid) / COUNT(questions.id)) AS average_likes
# FROM questions
# JOIN question_likes ON questions.id = question_likes.question_id
# WHERE question_likes.user_id = 1;
#
# SELECT COUNT(question_likes.question_id), COUNT(questions.id)
# FROM questions
# JOIN question_likes ON questions.id = question_likes.question_id
# WHERE questions.user_id = 1;
#
# SELECT question_likes.user_id, question_likes.question_id
# FROM question_likes
# WHERE question_likes.user_id = 1;

# JOIN question_likes ON questions.id = question_likes.question_id
