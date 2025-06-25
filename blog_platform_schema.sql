-- My Database Design Project for Advanced DBMS
-- Trying to implement a multi-tenant blog platform (wish me luck!)

DROP DATABASE IF EXISTS blog_platform;
CREATE DATABASE blog_platform;
USE blog_platform;

-- Create Tenants table (represents blogs)
CREATE TABLE tenants (
    tenant_id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Create custom domains table
CREATE TABLE custom_domains (
    domain_id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    domain_name VARCHAR(255) NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (domain_name),
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id) ON DELETE CASCADE
);

-- Create users table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL, -- would store hashed passwords in real app
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE KEY (email),
    UNIQUE KEY (username)
);

-- User profiles (bonus feature)
CREATE TABLE user_profiles (
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    display_name VARCHAR(100),
    bio TEXT,
    avatar_url VARCHAR(255),
    website_url VARCHAR(255),
    social_twitter VARCHAR(100),
    social_facebook VARCHAR(100),
    social_linkedin VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Create roles table
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    UNIQUE KEY (role_name)
);

-- Create tenant_users junction table (authors belonging to tenants/blogs)
CREATE TABLE tenant_users (
    tenant_id INT NOT NULL,
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (tenant_id, user_id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE RESTRICT
);

-- Create categories table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (tenant_id, slug),
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id) ON DELETE CASCADE
);

-- Create tags table
CREATE TABLE tags (
    tag_id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    slug VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (tenant_id, slug),
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id) ON DELETE CASCADE
);

-- Create posts table
CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    author_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    content TEXT,
    excerpt TEXT,
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft',
    comment_status ENUM('open', 'closed') DEFAULT 'open',
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE, -- For soft delete functionality
    UNIQUE KEY (tenant_id, slug),
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- Create post_categories junction table
CREATE TABLE post_categories (
    post_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (post_id, category_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

-- Create post_tags junction table
CREATE TABLE post_tags (
    post_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (post_id, tag_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

-- Create comments table
CREATE TABLE comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    parent_comment_id INT NULL,
    author_name VARCHAR(100),
    author_email VARCHAR(100),
    author_user_id INT NULL, -- NULL for guest comments
    content TEXT NOT NULL,
    status ENUM('pending', 'approved', 'rejected', 'spam') DEFAULT 'pending',
    ip_address VARCHAR(45), -- IPv4 or IPv6
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE, -- For soft delete functionality
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES comments(comment_id) ON DELETE SET NULL,
    FOREIGN KEY (author_user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Create post_versions table (bonus feature - versioning)
CREATE TABLE post_versions (
    version_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    excerpt TEXT,
    modified_by_user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (modified_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- Create rate_limits table (bonus feature - rate limiting)
CREATE TABLE rate_limits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ip_address VARCHAR(45) NOT NULL,
    action_type VARCHAR(50) NOT NULL, -- e.g., 'comment', 'login'
    count INT DEFAULT 1,
    first_attempt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_attempt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (ip_address, action_type)
);

-- Create indexes for performance
CREATE INDEX idx_posts_tenant_status ON posts(tenant_id, status);
CREATE INDEX idx_posts_published_at ON posts(published_at);
CREATE INDEX idx_comments_status ON comments(status);
CREATE INDEX idx_tenant_users_role ON tenant_users(role_id);

-- Insert default roles
INSERT INTO roles (role_name, description) VALUES
('owner', 'Blog owner with full administrative privileges'),
('admin', 'Administrator with high-level privileges'),
('editor', 'Can publish and manage posts including those of other users'),
('author', 'Can publish and manage only their own posts'),
('contributor', 'Can write and edit their own posts but cannot publish them');

-- Add full-text search index (bonus feature)
ALTER TABLE posts ADD FULLTEXT INDEX ft_posts_content (title, content);

-- Add stored procedures for core operations

-- Procedure to create a new blog post with validation
DELIMITER //
CREATE PROCEDURE CreateNewPost(
    IN p_tenant_id INT,
    IN p_author_id INT,
    IN p_title VARCHAR(255),
    IN p_slug VARCHAR(255),
    IN p_content TEXT,
    IN p_excerpt TEXT,
    IN p_status ENUM('draft', 'published', 'archived'),
    OUT p_result VARCHAR(255)
)
BEGIN
    DECLARE v_slug_exists INT;
    
    -- Check if slug already exists for this tenant
    SELECT COUNT(*) INTO v_slug_exists
    FROM posts
    WHERE tenant_id = p_tenant_id AND slug = p_slug;
    
    IF v_slug_exists > 0 THEN
        SET p_result = 'Error: Slug already exists';
    ELSE
        -- Insert the new post
        INSERT INTO posts (
            tenant_id, author_id, title, slug, content, 
            excerpt, status, published_at
        ) VALUES (
            p_tenant_id, p_author_id, p_title, p_slug, p_content,
            p_excerpt, p_status, 
            CASE WHEN p_status = 'published' THEN CURRENT_TIMESTAMP ELSE NULL END
        );
        
        SET p_result = 'Post created successfully';
    END IF;
END //
DELIMITER ;

-- Procedure to moderate comments
DELIMITER //
CREATE PROCEDURE ModerateComment(
    IN p_comment_id INT,
    IN p_new_status ENUM('pending', 'approved', 'rejected', 'spam'),
    IN p_moderator_user_id INT,
    OUT p_result VARCHAR(255)
)
BEGIN
    DECLARE v_current_status ENUM('pending', 'approved', 'rejected', 'spam');
    
    -- Get current comment status
    SELECT status INTO v_current_status
    FROM comments
    WHERE comment_id = p_comment_id;
    
    -- Update comment status
    UPDATE comments 
    SET status = p_new_status
    WHERE comment_id = p_comment_id;
    
    -- Log moderation action (in a real system, you'd have a separate moderation_logs table)
    INSERT INTO post_versions (
        post_id, 
        title, 
        content, 
        excerpt, 
        modified_by_user_id
    ) VALUES (
        (SELECT post_id FROM comments WHERE comment_id = p_comment_id),
        CONCAT('Comment ', p_comment_id, ' moderated'),
        CONCAT('Status changed from ', v_current_status, ' to ', p_new_status),
        '',
        p_moderator_user_id
    );
    
    SET p_result = CONCAT('Comment ', p_comment_id, ' moderated to ', p_new_status);
END //
DELIMITER ;

-- Procedure to get posts by tag
DELIMITER //
CREATE PROCEDURE GetPostsByTag(
    IN p_tenant_id INT,
    IN p_tag_name VARCHAR(50)
)
BEGIN
    SELECT p.post_id, p.title, p.content, u.username AS author_name, t.name AS tag_name
    FROM posts p
    JOIN users u ON p.author_id = u.user_id
    JOIN post_tags pt ON p.post_id = pt.post_id
    JOIN tags t ON pt.tag_id = t.tag_id
    WHERE p.tenant_id = p_tenant_id AND t.name = p_tag_name AND p.status = 'published'
    ORDER BY p.published_at DESC;
END //
DELIMITER ; 