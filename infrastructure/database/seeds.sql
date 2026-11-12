-- Anabhay Ventures — Restaurant Management Seed Data
-- Demo Tenant: "Anabhay Royal Kitchen & Bar"

-- 1. Demo Tenant
INSERT INTO tenants (id, name, slug, business_type, owner_name, owner_email, owner_phone, currency, country, subscription_plan, status, is_active)
VALUES (
    'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
    'Anabhay Royal Kitchen & Bar',
    'anabhay-royal-kitchen',
    'fine_dining',
    'Vikramaditya Anabhay',
    'vikram@anabhayventures.com',
    '+91 98765 43210',
    'INR',
    'IN',
    'enterprise',
    'active',
    TRUE
) ON CONFLICT DO NOTHING;

-- 2. Demo Branch
INSERT INTO branches (id, tenant_id, name, branch_code, address, city, state, pincode, phone, email, gstin, fssai_license, is_main_branch, is_active)
VALUES (
    'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e',
    'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
    'Connaught Place Flagship',
    'CP-01',
    'B-14, Inner Circle, Connaught Place',
    'New Delhi',
    'Delhi',
    '110001',
    '+91 11 2341 5678',
    'cp@anabhayventures.com',
    '07AAAAA0000A1Z5',
    '13320005000142',
    TRUE,
    TRUE
) ON CONFLICT DO NOTHING;

-- 3. Demo Users (Owner, Manager, Cashier, Waiter, Chef)
INSERT INTO users (id, tenant_id, branch_id, email, phone, full_name, password_hash, role, is_active, is_verified)
VALUES 
(
    'c3d4e5f6-a7b8-9c0d-1e2f-3a4b5c6d7e8f',
    'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
    'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e',
    'owner@anabhayventures.com',
    '+91 98765 43210',
    'Vikramaditya Anabhay',
    '$2a$12$eX8mE4G6yq5U...demo_hash',
    'restaurant_owner',
    TRUE,
    TRUE
),
(
    'd4e5f6a7-b8c9-0d1e-2f3a-4b5c6d7e8f9a',
    'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
    'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e',
    'manager@anabhayventures.com',
    '+91 98765 43211',
    'Rajesh Sharma',
    '$2a$12$eX8mE4G6yq5U...demo_hash',
    'branch_manager',
    TRUE,
    TRUE
),
(
    'e5f6a7b8-c9d0-1e2f-3a4b-5c6d7e8f9a0b',
    'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
    'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e',
    'cashier@anabhayventures.com',
    '+91 98765 43212',
    'Anita Roy',
    '$2a$12$eX8mE4G6yq5U...demo_hash',
    'cashier',
    TRUE,
    TRUE
) ON CONFLICT DO NOTHING;

-- 4. Restaurant Tables
INSERT INTO restaurant_tables (tenant_id, branch_id, table_number, capacity, floor_zone, status)
VALUES 
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'T-01', 2, 'Main Dining Hall', 'available'),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'T-02', 4, 'Main Dining Hall', 'occupied'),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'T-03', 4, 'Main Dining Hall', 'available'),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'T-04', 6, 'Main Dining Hall', 'occupied'),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'T-05', 2, 'Terrace Garden', 'available'),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'T-06', 4, 'Terrace Garden', 'reserved'),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'VIP-01', 8, 'VIP Lounge', 'occupied'),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'VIP-02', 10, 'VIP Lounge', 'available');

-- 5. Menu Categories
INSERT INTO menu_categories (id, tenant_id, branch_id, name, description, display_order)
VALUES 
('f6a7b8c9-d01e-2f3a-4b5c-6d7e8f9a0b1c', 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'Starters', 'Clay oven tandoori and crisp starters', 1),
('a7b8c9d0-1e2f-3a4b-5c6d-7e8f9a0b1c2d', 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'Main Course', 'Rich slow-simmered royal gravies', 2),
('b8c9d01e-2f3a-4b5c-6d7e-8f9a0b1c2d3e', 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'Biryani & Rice', 'Dum biryani in sealed clay handis', 3),
('c9d01e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f', 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'Breads', 'Artisanal Indian breads from tandoor', 4),
('d01e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5a', 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'Desserts', 'Traditional and modern artisanal sweets', 5)
ON CONFLICT DO NOTHING;

-- 6. Menu Items
INSERT INTO menu_items (tenant_id, category_id, name, description, price, tax_rate, is_veg, is_available)
VALUES 
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'f6a7b8c9-d01e-2f3a-4b5c-6d7e8f9a0b1c', 'Murgh Malai Tikka', 'Charcoal-grilled tender chicken morsels with cardamom cream', 460.00, 5.00, FALSE, TRUE),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'f6a7b8c9-d01e-2f3a-4b5c-6d7e8f9a0b1c', 'Paneer Tikka Angara', 'Smoked cottage cheese cubes with bell peppers and roasted spices', 390.00, 5.00, TRUE, TRUE),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'f6a7b8c9-d01e-2f3a-4b5c-6d7e8f9a0b1c', 'Dahi Ke Kebab', 'Hung yogurt patties flavored with green cardamom and coriander', 340.00, 5.00, TRUE, TRUE),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'a7b8c9d0-1e2f-3a4b-5c6d-7e8f9a0b1c2d', 'Dal Makhani Bukhara', 'Overnight slow-cooked black lentils with churned butter and cream', 380.00, 5.00, TRUE, TRUE),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'a7b8c9d0-1e2f-3a4b-5c6d-7e8f9a0b1c2d', 'Butter Chicken Aslam', 'Tandoori chicken pulled and simmered in velvety tomato makhani', 520.00, 5.00, FALSE, TRUE),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'a7b8c9d0-1e2f-3a4b-5c6d-7e8f9a0b1c2d', 'Paneer Lababdar', 'Diced cottage cheese in rich tomato-onion-cashew gravy', 440.00, 5.00, TRUE, TRUE),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'b8c9d01e-2f3a-4b5c-6d7e-8f9a0b1c2d3e', 'Saffron Dum Biryani (Chicken)', 'Fragrant basmati rice layered with spiced chicken in dough seal', 540.00, 5.00, FALSE, TRUE),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'b8c9d01e-2f3a-4b5c-6d7e-8f9a0b1c2d3e', 'Subz Dum Biryani', 'Seasonal fresh vegetables with aromatic spices and saffron', 420.00, 5.00, TRUE, TRUE),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'c9d01e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f', 'Butter Garlic Naan', 'Clay oven leavened bread brushed with melted butter and roasted garlic', 85.00, 5.00, TRUE, TRUE),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'c9d01e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f', 'Tandoori Roti', 'Crisp whole wheat bread baked in clay tandoor', 45.00, 5.00, TRUE, TRUE),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'd01e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5a', 'Gulab Jamun with Saffron Rabdi', 'Warm milk dumplings soaked in cardamom syrup with chilled rabdi', 220.00, 5.00, TRUE, TRUE);

