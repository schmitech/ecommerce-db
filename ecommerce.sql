-- Users/Customers
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Addresses
CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    user_id INT,
    address_type VARCHAR(20), -- Billing/Shipping
    street_address VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    is_default BOOLEAN,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Product Categories
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    parent_category_id INT,
    name VARCHAR(50),
    description TEXT,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- Products
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    category_id INT,
    name VARCHAR(100),
    description TEXT,
    base_price DECIMAL(10,2),
    brand VARCHAR(50),
    sku VARCHAR(50) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Product Variants
CREATE TABLE product_variants (
    variant_id SERIAL PRIMARY KEY,
    product_id INT,
    sku VARCHAR(50) UNIQUE,
    variant_name VARCHAR(100),
    size VARCHAR(50),
    color VARCHAR(50),
    material VARCHAR(50),
    price_adjustment DECIMAL(10,2),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Product Attributes
CREATE TABLE product_attributes (
    attribute_id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

-- Product Attribute Values
CREATE TABLE product_attribute_values (
    product_id INT,
    attribute_id INT,
    value VARCHAR(100),
    PRIMARY KEY (product_id, attribute_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (attribute_id) REFERENCES product_attributes(attribute_id)
);

-- Warehouses
CREATE TABLE warehouses (
    warehouse_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    location TEXT,
    contact_number VARCHAR(20)
);

-- Inventory
CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INT,
    variant_id INT,
    quantity INT,
    warehouse_id INT,
    stock_alert_threshold INT,
    reorder_point INT,
    last_updated TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (variant_id) REFERENCES product_variants(variant_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);

-- Orders
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT,
    order_status VARCHAR(20) CHECK (order_status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'returned')),
    shipping_address_id INT,
    billing_address_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    shipping_cost DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    shipping_method_id INT,
    tax_rate_id INT,
    store_id INT,
    loyalty_points_earned INT,
    loyalty_points_used INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id),
    FOREIGN KEY (billing_address_id) REFERENCES addresses(address_id),
    FOREIGN KEY (shipping_method_id) REFERENCES shipping_methods(shipping_method_id),
    FOREIGN KEY (tax_rate_id) REFERENCES tax_rates(tax_rate_id),
    FOREIGN KEY (store_id) REFERENCES store_locations(store_id)
);

-- Order Items
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT,
    product_id INT,
    variant_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (variant_id) REFERENCES product_variants(variant_id)
);

-- Shopping Cart
CREATE TABLE shopping_cart (
    cart_id SERIAL PRIMARY KEY,
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Shopping Cart Items
CREATE TABLE cart_items (
    cart_id INT,
    product_id INT,
    variant_id INT,
    quantity INT,
    PRIMARY KEY (cart_id, product_id, variant_id),
    FOREIGN KEY (cart_id) REFERENCES shopping_cart(cart_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (variant_id) REFERENCES product_variants(variant_id)
);

-- Payments
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20),
    amount DECIMAL(10,2),
    transaction_id VARCHAR(100),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Product Reviews
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INT,
    user_id INT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Wishlist
CREATE TABLE wishlist (
    wishlist_id SERIAL PRIMARY KEY,
    user_id INT,
    product_id INT,
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Promotions
CREATE TABLE promotions (
    promotion_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    discount_type VARCHAR(20), -- Percentage/Fixed Amount
    discount_value DECIMAL(10,2),
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    is_active BOOLEAN
);

-- Product Promotions
CREATE TABLE product_promotions (
    product_id INT,
    promotion_id INT,
    PRIMARY KEY (product_id, promotion_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id)
);

-- Shipping Methods
CREATE TABLE shipping_methods (
    shipping_method_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    description TEXT,
    base_cost DECIMAL(10,2),
    estimated_days_min INT,
    estimated_days_max INT,
    is_active BOOLEAN DEFAULT true
);

-- Shipping Zones
CREATE TABLE shipping_zones (
    zone_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50)
);

-- Shipping Rates
CREATE TABLE shipping_rates (
    rate_id SERIAL PRIMARY KEY,
    shipping_method_id INT,
    zone_id INT,
    base_rate DECIMAL(10,2),
    additional_item_rate DECIMAL(10,2),
    FOREIGN KEY (shipping_method_id) REFERENCES shipping_methods(shipping_method_id),
    FOREIGN KEY (zone_id) REFERENCES shipping_zones(zone_id)
);

-- Tax Rates
CREATE TABLE tax_rates (
    tax_rate_id SERIAL PRIMARY KEY,
    country VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(20),
    rate DECIMAL(5,2),
    tax_category VARCHAR(50),
    is_active BOOLEAN DEFAULT true
);

-- Customer Support Tickets
CREATE TABLE support_tickets (
    ticket_id SERIAL PRIMARY KEY,
    user_id INT,
    order_id INT,
    subject VARCHAR(200),
    description TEXT,
    status VARCHAR(20),
    priority VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Support Ticket Messages
CREATE TABLE ticket_messages (
    message_id SERIAL PRIMARY KEY,
    ticket_id INT,
    user_id INT,
    staff_id INT,
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES support_tickets(ticket_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Returns
CREATE TABLE returns (
    return_id SERIAL PRIMARY KEY,
    order_id INT,
    user_id INT,
    status VARCHAR(20),
    return_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Return Items
CREATE TABLE return_items (
    return_item_id SERIAL PRIMARY KEY,
    return_id INT,
    order_item_id INT,
    quantity INT,
    return_reason VARCHAR(100),
    condition_description TEXT,
    refund_amount DECIMAL(10,2),
    FOREIGN KEY (return_id) REFERENCES returns(return_id),
    FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id)
);

-- Vendors/Suppliers
CREATE TABLE vendors (
    vendor_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    tax_id VARCHAR(50),
    status VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vendor Products
CREATE TABLE vendor_products (
    vendor_id INT,
    product_id INT,
    vendor_sku VARCHAR(50),
    cost_price DECIMAL(10,2),
    lead_time_days INT,
    minimum_order_quantity INT,
    PRIMARY KEY (vendor_id, product_id),
    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Product Images
CREATE TABLE product_images (
    image_id SERIAL PRIMARY KEY,
    product_id INT,
    variant_id INT,
    image_url VARCHAR(255),
    alt_text VARCHAR(100),
    is_primary BOOLEAN DEFAULT false,
    display_order INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (variant_id) REFERENCES product_variants(variant_id)
);

-- Loyalty Program
CREATE TABLE loyalty_program (
    program_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    description TEXT,
    points_per_dollar DECIMAL(10,2),
    minimum_points_redemption INT,
    points_to_currency_ratio DECIMAL(10,2)
);

-- Customer Loyalty
CREATE TABLE customer_loyalty (
    user_id INT,
    current_points INT DEFAULT 0,
    lifetime_points INT DEFAULT 0,
    tier_level VARCHAR(20),
    joined_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Loyalty Transactions
CREATE TABLE loyalty_transactions (
    transaction_id SERIAL PRIMARY KEY,
    user_id INT,
    order_id INT,
    points_earned INT,
    points_redeemed INT,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Gift Cards
CREATE TABLE gift_cards (
    gift_card_id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    initial_balance DECIMAL(10,2),
    current_balance DECIMAL(10,2),
    issuer_user_id INT,
    recipient_email VARCHAR(100),
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiry_date TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    FOREIGN KEY (issuer_user_id) REFERENCES users(user_id)
);

-- Gift Card Transactions
CREATE TABLE gift_card_transactions (
    transaction_id SERIAL PRIMARY KEY,
    gift_card_id INT,
    order_id INT,
    amount DECIMAL(10,2),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (gift_card_id) REFERENCES gift_cards(gift_card_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Store Locations
CREATE TABLE store_locations (
    store_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100),
    operating_hours TEXT,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    is_active BOOLEAN DEFAULT true
);

-- Store Inventory
CREATE TABLE store_inventory (
    store_id INT,
    product_id INT,
    variant_id INT,
    quantity INT,
    last_updated TIMESTAMP,
    PRIMARY KEY (store_id, product_id, variant_id),
    FOREIGN KEY (store_id) REFERENCES store_locations(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (variant_id) REFERENCES product_variants(variant_id)
);

-- Customer Interactions
CREATE TABLE email_campaigns (
    campaign_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    status VARCHAR(20)
);

CREATE TABLE newsletter_subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    user_id INT,
    subscribed BOOLEAN DEFAULT true,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Content Management
CREATE TABLE blog_posts (
    post_id SERIAL PRIMARY KEY,
    title VARCHAR(200),
    content TEXT,
    author_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(user_id)
);

CREATE TABLE pages (
    page_id SERIAL PRIMARY KEY,
    title VARCHAR(200),
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);