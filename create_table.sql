CREATE TABLE customers (
    customer_id INT,
    signup_date DATE
);

CREATE TABLE orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    order_amount DECIMAL(10,2),
    product_id INT,
    category VARCHAR(50),
    discount_applied DECIMAL(5,2),
    payment_method VARCHAR(50)
);
















