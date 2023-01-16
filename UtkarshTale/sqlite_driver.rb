require 'sqlite3'
require 'json'

# Create DB file if not exists
$db = SQLite3::Database.open 'project.db'
$db.results_as_hash = true

# Create tables if not exists on DB
$db.execute "create table if not exists user(
    id        integer primary key autoincrement,
    username  text,
    password  text,
    email     text,
    bio       text,
    createdAt text default current_timestamp,
    updatedAt text,
    isDeleted boolean default false,
    deletedAt text                                
)"

$db.execute "create table if not exists post (
    id          integer primary key autoincrement,
    u_id        integer not null,
    title       text,
    body        text,
    likesCount  integer default 0,
    createdAt   text default current_timestamp,
    updatedAt   text,
    isDeleted   boolean default false,
    deletedAt   text,
    foreign key (u_id) references user(id)
)"

# Create a Post
def create_post(u_id, title, body)
    $db.query "INSERT INTO post(u_id, title, body) VALUES (?, ?, ?)", u_id, title, body
end

# Get all posts
def get_posts
    posts = Array.new
    results_set = $db.query "SELECT * from post WHERE isDeleted=false"
    results_set.each { |row| posts.push(row)}
    return posts
end

# get one post given id
def get_post(id)
    result_set = $db.query "SELECT * FROM post WHERE post.id = ? AND isDeleted=false", id
    return result_set.next
end

# Update post fields
def update_post(id, title, body)
    time = Time.new.utc
    current_time = time.strftime("%Y-%m-%d %H:%M:%S")
    old_post = $db.query "SELECT * FROM post WHERE post.id = ? AND isDeleted=false", id
    old_post = old_post.next
    # if passed value is null, use old values
    if title.nil?
        title = old_post['title']
    end
    if body.nil?
        body = old_post['body']
    end
    $db.query "UPDATE post SET title=?, body=?, updatedAt=? WHERE id=?", title, body, current_time, id
end

# Like certain post
def like_post(id)
    $db.query("UPDATE post SET likesCount = likesCount + 1")
end

# Delete post [just mark it as deleted and give timestamp]
def delete_post(id)
    time = Time.new.utc
    current_time = time.strftime("%Y-%m-%d %H:%M:%S")
    result_set = $db.query "UPDATE post SET isDeleted=true, deletedAt=? WHERE id = ?", current_time, id
end

# Create new user
def create_user(username, password, email, bio)
    $db.query "INSERT INTO user(username, password, email, bio) VALUES (?, ?, ?, ?)", username, password, email, bio
end

# Get a user details
def get_user(id)
    results_set = $db.query "SELECT * FROM user WHERE user.id = ? and isDeleted=false", id
    return results_set.next
end

# Delete user [mark as delete and give timestamp]
def delete_user(id)
    time = Time.new.utc
    current_time = time.strftime("%Y-%m-%d %H:%M:%S")
    result_set = $db.query "UPDATE user SET isDeleted=true, deletedAt=? WHERE id = ?", current_time, id
    $db.query "UPDATE post SET isDeleted=true, deletedAt=? WHERE u_id=?", current_time, id
end

# Update current user fields
def update_user(id, username, password, email, bio)
    time = Time.new.utc
    current_time = time.strftime("%Y-%m-%d %H:%M:%S")
    old_user = $db.query "SELECT * FROM user WHERE user.id = ? AND isDeleted=false", id
    old_user = old_user.next
    # if passed value is null, use old values
    if username.nil?
        username = old_user['username']
    end
    if password.nil?
        password = old_user['password']
    end
    if email.nil?
        email = old_user["email"]
    end
    if bio.nil?
        bio = old_user["bio"]
    end
    $db.query "UPDATE user SET username=?, password=?, email=?, bio=?, updatedAt=? WHERE id=?", username, password, email, bio, current_time, id
end

# Login user [return logged in if username and password combination is correct]
def login_user(username, password)
    result_set = $db.query "SELECT * FROM user WHERE user.username=?", username
    result_set = result_set.next
    if password == result_set["password"]
        return "Logged in"
    else
        return "Incorrect"
    end
end