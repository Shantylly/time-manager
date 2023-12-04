-- Create teams table
CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    manager_id INTEGER,
    inserted_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert sample teams
INSERT INTO teams (name,manager_id) VALUES
    ('Team A',1),
    ('Team B',1),
    ('Team C',1),
    ('Team D',1);

-- Create users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    firstname VARCHAR(255) NOT NULL,
    lastname VARCHAR(255) NOT NULL,
    genre VARCHAR(2) NOT NULL,
    role VARCHAR(255) NOT NULL,
    mail VARCHAR(255) NOT NULL UNIQUE,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    team_id INTEGER REFERENCES teams(id) ON DELETE SET NULL,
    password VARCHAR(255) NOT NULL,
    inserted_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert sample users
INSERT INTO users (firstname, lastname, role,genre, mail, address, phone, team_id, password) VALUES
    ('John', 'Doe', 'Manager','H', 'john.doe@example.com', '123 Main St', '123-456-7890', 1, 'password123'),
    ('Alice', 'Johnson', 'User','F', 'alice@example.com', '456 Elm St', '456-789-0123', 1, 'password456'),
    ('Bob', 'Smith', 'User','H', 'bob@example.com', '789 Oak St', '789-012-3456', 2, 'password789'),
    ('Bob2', 'Smith', 'User','H', 'bob@example.com', '789 Oak St', '789-012-3456', 3, 'password789'),
    ('Bob3', 'Smith', 'User','F', 'bob@example.com', '789 Oak St', '789-012-3456', 3, 'password789'),
    ('Bob4', 'Smith', 'User','N', 'bob@example.com', '789 Oak St', '789-012-3456', 1, 'password789');
    ;

-- Create clocks table
CREATE TABLE clocks (
    id SERIAL PRIMARY KEY,
    status BOOLEAN DEFAULT FALSE,
    time TIMESTAMPTZ,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    inserted_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert sample clocks
INSERT INTO clocks (status, time, user_id) VALUES
    (FALSE, NOW() - INTERVAL '1 day', 1),
    (TRUE, NOW() - INTERVAL '12 hours', 2),
    (FALSE, NOW() - INTERVAL '2 days', 3);

-- Create timespents table
CREATE TABLE timespents (
    id SERIAL PRIMARY KEY,
    description TEXT,
    date_start TIMESTAMPTZ,
    date_end TIMESTAMPTZ,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    inserted_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert sample time spent
INSERT INTO timespents (description, date_start, date_end, user_id) VALUES
    ('Task 1', NOW() - INTERVAL '1 day', NOW(), 1),
    ('Task 2', NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day', 2),
    ('Task 3', NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days', 3);
