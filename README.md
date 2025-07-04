# Multi-Tenant Blogging Platform Database Schema

## Project Overview
This is my database design project for Advanced DBMS course. I've created a robust multi-tenant blogging platform schema that supports multiple blogs, authors, and features.

## Key Features
- Multi-tenancy support
- Flexible author and blog management
- Comprehensive comment and tagging system
- Bonus features like post versioning and soft deletes

## Sample Queries

### 1. Get All Posts for a Specific Tenant
```sql
SELECT p.post_id, p.title, u.username AS author, t.tenant_name
FROM posts p
JOIN users u ON p.author_id = u.user_id
JOIN tenants t ON p.tenant_id = t.tenant_id
WHERE t.tenant_name = 'Tech Insights Blog';
```

### 2. Find Posts with Specific Tags
```sql
SELECT p.title, t.name AS tag_name
FROM posts p
JOIN post_tags pt ON p.post_id = pt.post_id
JOIN tags t ON pt.tag_id = t.tag_id
WHERE t.name = 'Python';
```

### 3. Get User Roles in a Tenant
```sql
SELECT u.username, r.role_name, t.tenant_name
FROM tenant_users tu
JOIN users u ON tu.user_id = u.user_id
JOIN roles r ON tu.role_id = r.role_id
JOIN tenants t ON tu.tenant_id = t.tenant_id;
```

### 4. Count Comments by Status
```sql
SELECT status, COUNT(*) as comment_count
FROM comments
GROUP BY status;
```
