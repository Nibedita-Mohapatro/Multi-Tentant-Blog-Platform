-- Sample Data for Multi-Tenant Blogging Platform
-- Inserting sample data to showcase platform features

-- Insert sample tenants (blogs)
INSERT INTO tenants (tenant_name) VALUES 
('Tech Insights Blog'),
('Travel Diaries'),
('Cooking Adventures');

-- Insert sample users
INSERT INTO users (username, email, password_hash) VALUES 
('rajesh_tech', 'rajesh.sharma@example.com', 'hashed_password_1'),
('priya_traveler', 'priya.patel@example.com', 'hashed_password_2'),
('amit_chef', 'amit.kumar@example.com', 'hashed_password_3'),
('sneha_writer', 'sneha.gupta@example.com', 'hashed_password_4'),
('vikram_contributor', 'vikram.singh@example.com', 'hashed_password_5');

-- Insert user profiles
INSERT INTO user_profiles (user_id, display_name, bio, avatar_url) VALUES 
(1, 'Rajesh Sharma', 'Tech enthusiast and software engineer', 'https://example.com/avatars/rajesh.jpg'),
(2, 'Priya Patel', 'Wanderlust-driven travel blogger', 'https://example.com/avatars/priya.jpg'),
(3, 'Amit Kumar', 'Passionate home cook and food lover', 'https://example.com/avatars/amit.jpg'),
(4, 'Sneha Gupta', 'Professional content writer', 'https://example.com/avatars/sneha.jpg'),
(5, 'Vikram Singh', 'Aspiring writer', 'https://example.com/avatars/vikram.jpg');

-- Insert custom domains
INSERT INTO custom_domains (tenant_id, domain_name, is_verified) VALUES 
(1, 'techinsights.blog', TRUE),
(2, 'traveldiaries.in', TRUE),
(3, 'cookingadventures.com', FALSE);

-- Insert categories
INSERT INTO categories (tenant_id, name, slug, description) VALUES 
(1, 'Software Development', 'software-dev', 'Latest trends in coding and technology'),
(1, 'Tech Reviews', 'tech-reviews', 'Honest reviews of latest gadgets'),
(2, 'Destination Guides', 'destination-guides', 'Comprehensive travel guides'),
(2, 'Travel Tips', 'travel-tips', 'Practical advice for travelers'),
(3, 'Indian Cuisine', 'indian-cuisine', 'Traditional and modern Indian recipes'),
(3, 'Baking', 'baking', 'Sweet and savory baking recipes');

-- Insert tags
INSERT INTO tags (tenant_id, name, slug) VALUES 
(1, 'Python', 'python'),
(1, 'Machine Learning', 'ml'),
(2, 'Budget Travel', 'budget-travel'),
(2, 'Backpacking', 'backpacking'),
(3, 'Vegetarian', 'vegetarian'),
(3, 'Desserts', 'desserts');

-- Insert tenant_users with roles
INSERT INTO tenant_users (tenant_id, user_id, role_id) VALUES 
(1, 1, 1),  -- Rajesh is owner of Tech Insights
(1, 4, 3),  -- Sneha is an editor
(2, 2, 1),  -- Priya is owner of Travel Diaries
(2, 5, 4),  -- Vikram is an author
(3, 3, 1);  -- Amit is owner of Cooking Adventures

-- Insert posts
INSERT INTO posts (tenant_id, author_id, title, slug, content, status, published_at) VALUES 
(1, 1, 'Introduction to Machine Learning', 'ml-intro', 'Detailed guide to getting started with ML...', 'published', NOW()),
(1, 4, 'Top 10 Python Libraries in 2023', 'python-libraries', 'Exploring the most useful Python libraries...', 'published', NOW()),
(2, 2, 'Backpacking in Himalayas', 'himalaya-trip', 'My incredible journey through the Himalayan trails...', 'published', NOW()),
(2, 5, 'Budget Travel Tips for Students', 'budget-travel-tips', 'How to travel on a shoestring budget...', 'draft', NULL),
(3, 3, 'Classic Gulab Jamun Recipe', 'gulab-jamun-recipe', 'Traditional method to make perfect Gulab Jamun...', 'published', NOW());

-- Insert comments
INSERT INTO comments (post_id, author_name, author_email, content, status) VALUES 
(1, 'Ankit Mehta', 'ankit@example.com', 'Great introduction to ML!', 'approved'),
(2, 'Deepa Reddy', 'deepa@example.com', 'Very helpful list of libraries', 'approved'),
(3, 'Rahul Sharma', 'rahul@example.com', 'Inspiring travel story!', 'pending'),
(5, 'Neha Kapoor', 'neha@example.com', 'Mouth-watering recipe', 'approved');

-- Insert post_categories and post_tags
INSERT INTO post_categories (post_id, category_id) VALUES 
(1, 1),
(2, 1),
(3, 3),
(4, 4),
(5, 5);

INSERT INTO post_tags (post_id, tag_id) VALUES 
(1, 2),
(2, 1),
(3, 3),
(4, 4),
(5, 5); 