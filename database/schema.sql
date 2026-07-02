CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================================
-- USERS
-- ==========================================================

CREATE TABLE users (

    id BIGSERIAL PRIMARY KEY,

    full_name VARCHAR(150) NOT NULL,

    email VARCHAR(255) UNIQUE NOT NULL,

    username VARCHAR(100) UNIQUE NOT NULL,

    password_hash TEXT NOT NULL,

    role_id BIGINT
        REFERENCES roles(id),

    is_active BOOLEAN DEFAULT TRUE,

    last_login TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- ROLES
-- ==========================================================

CREATE TABLE roles (

    id BIGSERIAL PRIMARY KEY,

    role_name VARCHAR(50) UNIQUE NOT NULL,

    description TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- CUSTOMERS
-- ==========================================================

CREATE TABLE customers (

    id BIGSERIAL PRIMARY KEY,

    customer_code VARCHAR(30) UNIQUE,

    full_name VARCHAR(150) NOT NULL,

    email VARCHAR(255),

    phone VARCHAR(25),

    city VARCHAR(100),

    state VARCHAR(100),

    country VARCHAR(100),

    region VARCHAR(100),

    customer_segment VARCHAR(50),

    satisfaction_score NUMERIC(5,2),

    total_orders INTEGER DEFAULT 0,

    total_spent NUMERIC(15,2) DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- PRODUCT CATEGORIES
-- ==========================================================

CREATE TABLE categories (

    id BIGSERIAL PRIMARY KEY,

    category_name VARCHAR(100) UNIQUE NOT NULL,

    description TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- PRODUCTS
-- ==========================================================

CREATE TABLE products (

    id BIGSERIAL PRIMARY KEY,

    product_code VARCHAR(50) UNIQUE,

    product_name VARCHAR(255) NOT NULL,

    category_id BIGINT REFERENCES categories(id),

    sku VARCHAR(100) UNIQUE,

    barcode VARCHAR(100),

    unit_price NUMERIC(12,2) NOT NULL,

    cost_price NUMERIC(12,2) NOT NULL,
  
    brand VARCHAR(100),
  
    supplier_sku VARCHAR(100),
    
    minimum_stock INTEGER DEFAULT 0,
    
    maximum_stock INTEGER DEFAULT 0,
    
    volume NUMERIC(10,2),
    
    dimensions VARCHAR(100),
    
    status VARCHAR(30) DEFAULT 'Active',
    
    created_by BIGINT
        REFERENCES users(id),
    
    updated_by BIGINT
        REFERENCES users(id),

    weight NUMERIC(10,2),

    unit VARCHAR(20),

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- SUPPLIERS
-- ==========================================================

CREATE TABLE suppliers (

    id BIGSERIAL PRIMARY KEY,

    supplier_code VARCHAR(30) UNIQUE,

    supplier_name VARCHAR(255) NOT NULL,

    contact_person VARCHAR(150),

    email VARCHAR(255),

    phone VARCHAR(30),

    city VARCHAR(100),

    state VARCHAR(100),

    country VARCHAR(100),

    lead_time_days INTEGER,

    reliability_score NUMERIC(5,2),

    on_time_delivery_rate NUMERIC(5,2),

    rejection_rate NUMERIC(5,2),

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- WAREHOUSES
-- ==========================================================

CREATE TABLE warehouses (

    id BIGSERIAL PRIMARY KEY,

    warehouse_code VARCHAR(30) UNIQUE,

    warehouse_name VARCHAR(255),

    city VARCHAR(100),

    state VARCHAR(100),

    country VARCHAR(100),

    capacity INTEGER,

    utilization NUMERIC(5,2),

    manager_name VARCHAR(150),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- INVENTORY
-- ==========================================================

CREATE TABLE inventory (

    id BIGSERIAL PRIMARY KEY,

    product_id BIGINT NOT NULL REFERENCES products(id),

    warehouse_id BIGINT NOT NULL REFERENCES warehouses(id),

    supplier_id BIGINT REFERENCES suppliers(id),

    quantity_in_stock INTEGER DEFAULT 0,

    reserved_quantity INTEGER DEFAULT 0,

    damaged_quantity INTEGER DEFAULT 0,
  
    available_stock INTEGER,

    incoming_stock INTEGER DEFAULT 0,
    
    last_stock_count DATE,
    
    stock_status VARCHAR(30),
    
    inventory_turnover NUMERIC(10,2),

    abc_class CHAR(1),

    reorder_level INTEGER DEFAULT 0,

    reorder_quantity INTEGER DEFAULT 0,

    safety_stock INTEGER DEFAULT 0,

    inventory_value NUMERIC(15,2),

    last_restocked TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE inventory_transactions (

    id BIGSERIAL PRIMARY KEY,

    inventory_id BIGINT

        REFERENCES inventory(id),

    product_id BIGINT

        REFERENCES products(id),

    warehouse_id BIGINT

        REFERENCES warehouses(id),

    transaction_type VARCHAR(50),

    quantity INTEGER,

    previous_stock INTEGER,

    new_stock INTEGER,

    reference_type VARCHAR(50),

    reference_id BIGINT,

    remarks TEXT,

    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    created_by BIGINT

        REFERENCES users(id)

);

-- ==========================================================
-- INDEXES
-- ==========================================================

CREATE INDEX idx_customer_region
ON customers(region);

CREATE INDEX idx_customer_segment
ON customers(customer_segment);

CREATE INDEX idx_product_category
ON products(category_id);

CREATE INDEX idx_supplier_reliability
ON suppliers(reliability_score);

CREATE INDEX idx_inventory_product
ON inventory(product_id);

CREATE INDEX idx_inventory_warehouse
ON inventory(warehouse_id);

-- ==========================================================
-- DEFAULT ROLES
-- ==========================================================

INSERT INTO roles(role_name,description)

VALUES

('Admin','System Administrator'),

('Manager','Operations Manager'),

('Analyst','Business Analyst'),

('User','Standard User');

-- ==========================================================
-- DEFAULT CATEGORIES
-- ==========================================================

INSERT INTO categories(category_name)

VALUES

('Electronics'),

('Fashion'),

('Home'),

('Groceries'),

('Sports'),

('Books'),

('Beauty');

-- ==========================================================
-- EMPLOYEES
-- ==========================================================

CREATE TABLE employees (

    id BIGSERIAL PRIMARY KEY,

    employee_code VARCHAR(30) UNIQUE,

    full_name VARCHAR(150) NOT NULL,

    email VARCHAR(255),

    phone VARCHAR(30),

    department VARCHAR(100),

    designation VARCHAR(100),

    manager_name VARCHAR(150),

    city VARCHAR(100),

    productivity_score NUMERIC(5,2),

    tasks_completed INTEGER DEFAULT 0,

    average_completion_hours NUMERIC(8,2),

    joining_date DATE,

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE employee_tasks (

    id BIGSERIAL PRIMARY KEY,

    employee_id BIGINT

        REFERENCES employees(id),

    task_name VARCHAR(255),

    task_type VARCHAR(100),

    assigned_at TIMESTAMP,

    completed_at TIMESTAMP,

    duration_hours NUMERIC(8,2),

    status VARCHAR(30),

    priority VARCHAR(30)

);

-- ==========================================================
-- ORDERS
-- ==========================================================

CREATE TABLE orders (

    id BIGSERIAL PRIMARY KEY,

    order_number VARCHAR(50) UNIQUE,

    customer_id BIGINT NOT NULL

        REFERENCES customers(id),

    warehouse_id BIGINT

        REFERENCES warehouses(id),

    employee_id BIGINT

        REFERENCES employees(id),

    order_date TIMESTAMP,

    expected_delivery DATE,

    delivered_date DATE,

    status VARCHAR(30),

    payment_method VARCHAR(50),

    payment_status VARCHAR(30),
  
    shipping_address TEXT,
  
    billing_address TEXT,
    
    currency VARCHAR(10) DEFAULT 'INR',
    
    order_source VARCHAR(50),
    
    sales_channel VARCHAR(50),

    shipping_cost NUMERIC(12,2),

    tax_amount NUMERIC(12,2),

    discount_amount NUMERIC(12,2),

    subtotal NUMERIC(15,2),

    total_amount NUMERIC(15,2),

    order_priority VARCHAR(20),

    processing_hours NUMERIC(8,2),

    fulfillment_rate NUMERIC(5,2),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- ORDER ITEMS
-- ==========================================================

CREATE TABLE order_items (

    id BIGSERIAL PRIMARY KEY,

    order_id BIGINT NOT NULL

        REFERENCES orders(id)

        ON DELETE CASCADE,

    product_id BIGINT NOT NULL

        REFERENCES products(id),

    quantity INTEGER,

    unit_price NUMERIC(12,2),

    cost_price NUMERIC(12,2),

    discount NUMERIC(12,2),

    total_price NUMERIC(15,2)

);

-- ==========================================================
-- SHIPMENTS
-- ==========================================================

CREATE TABLE shipments (

    id BIGSERIAL PRIMARY KEY,

    shipment_number VARCHAR(50) UNIQUE,

    order_id BIGINT NOT NULL

        REFERENCES orders(id),

    supplier_id BIGINT

        REFERENCES suppliers(id),

    warehouse_id BIGINT

        REFERENCES warehouses(id),

    carrier VARCHAR(100),
  
    vehicle_number VARCHAR(50),

    driver_name VARCHAR(100),
    
    tracking_url TEXT,
    
    shipping_partner VARCHAR(100),
    
    distance_km NUMERIC(10,2),
    
    shipping_zone VARCHAR(50),

    tracking_number VARCHAR(100),

    shipped_date DATE,

    delivered_date DATE,

    estimated_delivery DATE,

    delivery_status VARCHAR(30),

    delay_days INTEGER,

    shipping_cost NUMERIC(12,2),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- RETURNS & ORDER STATUS HISTORY 
-- ==========================================================

CREATE TABLE returns (

    id BIGSERIAL PRIMARY KEY,

    order_item_id BIGINT

        REFERENCES order_items(id),

    return_date DATE,

    return_reason TEXT,

    refund_amount NUMERIC(12,2),

    return_status VARCHAR(30),

    inspected_by BIGINT

        REFERENCES employees(id),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE customer_feedback (

    id BIGSERIAL PRIMARY KEY,

    customer_id BIGINT
        REFERENCES customers(id),

    order_id BIGINT
        REFERENCES orders(id),

    rating NUMERIC(2,1),

    feedback TEXT,

    sentiment VARCHAR(30),

    feedback_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE order_status_history (

    id BIGSERIAL PRIMARY KEY,

    order_id BIGINT

        REFERENCES orders(id)

        ON DELETE CASCADE,

    previous_status VARCHAR(30),

    current_status VARCHAR(30),

    changed_by BIGINT

        REFERENCES users(id),

    remarks TEXT,

    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
-- ==========================================================
-- PURCHASE ORDERS
-- ==========================================================

CREATE TABLE purchase_orders (

    id BIGSERIAL PRIMARY KEY,

    po_number VARCHAR(50) UNIQUE,

    supplier_id BIGINT

        REFERENCES suppliers(id),

    warehouse_id BIGINT

        REFERENCES warehouses(id),

    order_date DATE,

    expected_delivery DATE,

    received_date DATE,

    total_cost NUMERIC(15,2),

    status VARCHAR(30),
  
    purchase_status VARCHAR(30),

    approved_by BIGINT
        REFERENCES users(id),
    
    approved_date TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- PURCHASE ITEMS
-- ==========================================================

CREATE TABLE purchase_items (

    id BIGSERIAL PRIMARY KEY,

    purchase_order_id BIGINT

        REFERENCES purchase_orders(id)

        ON DELETE CASCADE,

    product_id BIGINT

        REFERENCES products(id),

    quantity INTEGER,

    purchase_price NUMERIC(12,2),

    total_price NUMERIC(15,2)

);

-- ==========================================================
-- DELIVERY EVENTS
-- ==========================================================

CREATE TABLE supplier_performance_history (

    id BIGSERIAL PRIMARY KEY,

    supplier_id BIGINT

        REFERENCES suppliers(id),

    evaluation_month DATE,

    reliability_score NUMERIC(5,2),

    delivery_score NUMERIC(5,2),

    quality_score NUMERIC(5,2),

    rejection_rate NUMERIC(5,2),

    average_lead_time NUMERIC(8,2),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- Supplier Performance History
-- ==========================================================

CREATE TABLE delivery_events (

    id BIGSERIAL PRIMARY KEY,

    shipment_id BIGINT

        REFERENCES shipments(id)

        ON DELETE CASCADE,

    event_time TIMESTAMP,

    location VARCHAR(150),

    status VARCHAR(100),

    remarks TEXT

);

-- ==========================================================
-- INDEXES
-- ==========================================================

CREATE INDEX idx_orders_customer

ON orders(customer_id);

CREATE INDEX idx_orders_date

ON orders(order_date);

CREATE INDEX idx_orders_status

ON orders(status);

CREATE INDEX idx_orders_employee

ON orders(employee_id);

CREATE INDEX idx_order_items_order

ON order_items(order_id);

CREATE INDEX idx_order_items_product

ON order_items(product_id);

CREATE INDEX idx_shipments_order

ON shipments(order_id);

CREATE INDEX idx_shipments_status

ON shipments(delivery_status);

CREATE INDEX idx_returns_item

ON returns(order_item_id);

CREATE INDEX idx_purchase_supplier

ON purchase_orders(supplier_id);

CREATE INDEX idx_delivery_events

ON delivery_events(shipment_id);

-- ==========================================================
-- BUSINESS INTELLIGENCE LAYER
-- ==========================================================

-- ==========================================================
-- KPI SNAPSHOTS & TARGETS
-- ==========================================================

CREATE TABLE kpi_snapshots (

    id BIGSERIAL PRIMARY KEY,

    snapshot_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    revenue NUMERIC(15,2),

    profit NUMERIC(15,2),

    operating_cost NUMERIC(15,2),

    total_orders INTEGER,

    fulfilled_orders INTEGER,

    cancelled_orders INTEGER,

    returned_orders INTEGER,

    average_order_value NUMERIC(12,2),

    inventory_health NUMERIC(5,2),

    supplier_reliability NUMERIC(5,2),

    customer_satisfaction NUMERIC(5,2),

    operational_efficiency NUMERIC(5,2),

    sla_compliance NUMERIC(5,2),

    warehouse_utilization NUMERIC(5,2),

    active_alerts INTEGER,

    business_health_score NUMERIC(5,2),

    created_by BIGINT REFERENCES users(id)

);

CREATE TABLE kpi_targets (

    id BIGSERIAL PRIMARY KEY,

    kpi_name VARCHAR(100),

    target_value NUMERIC(15,2),

    warning_threshold NUMERIC(15,2),

    critical_threshold NUMERIC(15,2)

);

-- ==========================================================
-- DASHBOARD SNAPSHOTS & BUSINESS TARGETS
-- ==========================================================

CREATE TABLE dashboard_snapshots (

    id BIGSERIAL PRIMARY KEY,

    snapshot_name VARCHAR(150),

    dashboard_type VARCHAR(100),

    description TEXT,

    snapshot_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    revenue NUMERIC(15,2),

    profit NUMERIC(15,2),

    orders INTEGER,

    inventory_value NUMERIC(15,2),

    customer_count INTEGER,

    supplier_count INTEGER,

    alert_count INTEGER,

    filters JSONB,

    dashboard_json JSONB,

    created_by BIGINT REFERENCES users(id)

);

CREATE TABLE business_targets (

    id BIGSERIAL PRIMARY KEY,

    target_name VARCHAR(150),

    metric_name VARCHAR(100),

    target_value NUMERIC(15,2),

    start_date DATE,

    end_date DATE,

    created_by BIGINT
        REFERENCES users(id)

);
-- ==========================================================
-- FORECAST RUNS
-- ==========================================================

CREATE TABLE forecast_runs (

    id BIGSERIAL PRIMARY KEY,

    run_name VARCHAR(150),

    model_name VARCHAR(100),

    target_metric VARCHAR(100),

    algorithm VARCHAR(100),

    dataset_version VARCHAR(100),

    training_rows INTEGER,

    testing_rows INTEGER,

    accuracy NUMERIC(6,3),

    precision_score NUMERIC(6,3),

    recall_score NUMERIC(6,3),

    rmse NUMERIC(12,4),

    mae NUMERIC(12,4),

    confidence_score NUMERIC(5,2),

    execution_time_seconds NUMERIC(10,2),

    model_version VARCHAR(50),

    trained_at TIMESTAMP,

    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    created_by BIGINT REFERENCES users(id)

);

-- ==========================================================
-- FORECAST RESULTS
-- ==========================================================

CREATE TABLE forecast_results (

    id BIGSERIAL PRIMARY KEY,

    forecast_run_id BIGINT

        REFERENCES forecast_runs(id)

        ON DELETE CASCADE,

    forecast_date DATE,

    metric_name VARCHAR(100),

    predicted_value NUMERIC(15,2),

    lower_bound NUMERIC(15,2),

    upper_bound NUMERIC(15,2),

    confidence_percentage NUMERIC(5,2),

    actual_value NUMERIC(15,2),

    prediction_error NUMERIC(15,2),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- INDEXES
-- ==========================================================

CREATE INDEX idx_kpi_snapshot_time

ON kpi_snapshots(snapshot_time);

CREATE INDEX idx_dashboard_snapshot

ON dashboard_snapshots(snapshot_time);

CREATE INDEX idx_forecast_run

ON forecast_runs(executed_at);

CREATE INDEX idx_forecast_metric

ON forecast_results(metric_name);

CREATE INDEX idx_forecast_date

ON forecast_results(forecast_date);

-- ==========================================================
-- VIEW
-- Latest KPI Dashboard
-- ==========================================================

CREATE VIEW latest_business_kpis AS

SELECT *

FROM kpi_snapshots

ORDER BY snapshot_time DESC

LIMIT 1;

-- ==========================================================
-- VIEW
-- Latest Forecast Results
-- ==========================================================

CREATE VIEW latest_forecasts AS

SELECT

fr.metric_name,

fr.forecast_date,

fr.predicted_value,

fr.confidence_percentage,

fr.actual_value

FROM forecast_results fr

JOIN forecast_runs r

ON fr.forecast_run_id = r.id

WHERE r.executed_at = (

    SELECT MAX(executed_at)

    FROM forecast_runs

);

-- ==========================================================
-- AI INTELLIGENCE LAYER
-- ==========================================================

-- ==========================================================
-- MODEL REGISTRY & PREDICTION HISTORY
-- ==========================================================

CREATE TABLE model_registry (

    id BIGSERIAL PRIMARY KEY,

    model_name VARCHAR(100),

    version VARCHAR(50),

    algorithm VARCHAR(100),

    accuracy NUMERIC(6,3),

    model_path TEXT,

    deployed_at TIMESTAMP,

    is_active BOOLEAN DEFAULT TRUE

);

CREATE TABLE prediction_history (

    id BIGSERIAL PRIMARY KEY,

    model_id BIGINT
        REFERENCES model_registry(id),

    prediction_type VARCHAR(100),

    predicted_value NUMERIC(15,2),

    actual_value NUMERIC(15,2),

    prediction_date DATE,

    confidence NUMERIC(5,2)

);

-- ==========================================================
-- AI SUMMARIES
-- Stores every AI-generated business summary
-- ==========================================================

CREATE TABLE ai_summaries (

    id BIGSERIAL PRIMARY KEY,

    summary_title VARCHAR(200),

    module_name VARCHAR(100),

    report_period VARCHAR(100),

    prompt TEXT NOT NULL,

    ai_response TEXT NOT NULL,

    ai_model VARCHAR(100),

    token_usage INTEGER,

    execution_time_ms INTEGER,

    confidence_score NUMERIC(5,2),
  
    temperature NUMERIC(4,2),
  
    model_version VARCHAR(50),
    
    latency_ms INTEGER,
    
    estimated_cost NUMERIC(10,4),

    generated_by BIGINT

        REFERENCES users(id),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- EXECUTIVE REPORTS
-- Stores complete executive reports generated by AI
-- ==========================================================

CREATE TABLE executive_reports (

    id BIGSERIAL PRIMARY KEY,

    report_name VARCHAR(200),

    report_type VARCHAR(100),

    reporting_period VARCHAR(100),

    generated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    generated_by BIGINT

        REFERENCES users(id),

    business_health_score NUMERIC(5,2),

    executive_summary TEXT,

    key_findings TEXT,

    identified_risks TEXT,

    recommended_actions TEXT,

    forecast_summary TEXT,

    report_file VARCHAR(255),

    pdf_path VARCHAR(255),

    excel_path VARCHAR(255),

    status VARCHAR(30) DEFAULT 'Completed'

);

-- ==========================================================
-- RECOMMENDATION HISTORY
-- Stores every recommendation produced by AI
-- ==========================================================

CREATE TABLE recommendation_history (

    id BIGSERIAL PRIMARY KEY,

    recommendation_type VARCHAR(100),

    module_name VARCHAR(100),

    business_problem TEXT,

    recommendation TEXT,

    expected_impact TEXT,
  
    expected_savings NUMERIC(15,2),

    estimated_roi NUMERIC(10,2),
    
    actual_roi NUMERIC(10,2),

    priority VARCHAR(20),

    confidence_score NUMERIC(5,2),

    implementation_status VARCHAR(30)

        DEFAULT 'Pending',

    implemented_by BIGINT

        REFERENCES users(id),

    implementation_date DATE,

    outcome_notes TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- INDEXES
-- ==========================================================

CREATE INDEX idx_ai_summary_date

ON ai_summaries(created_at);

CREATE INDEX idx_ai_module

ON ai_summaries(module_name);

CREATE INDEX idx_exec_reports

ON executive_reports(generated_on);

CREATE INDEX idx_report_type

ON executive_reports(report_type);

CREATE INDEX idx_recommendations

ON recommendation_history(priority);

CREATE INDEX idx_recommendation_status

ON recommendation_history(implementation_status);

-- ==========================================================
-- VIEW
-- Latest Executive Report
-- ==========================================================

CREATE VIEW latest_executive_report AS

SELECT *

FROM executive_reports

ORDER BY generated_on DESC

LIMIT 1;

-- ==========================================================
-- VIEW
-- Pending Recommendations
-- ==========================================================

CREATE VIEW pending_recommendations AS

SELECT *

FROM recommendation_history

WHERE implementation_status = 'Pending'

ORDER BY priority DESC,
         created_at DESC;

-- ==========================================================
-- System Layer
-- ==========================================================

-- ==========================================================
-- ALERTS
-- ==========================================================

CREATE TABLE alerts (

    id BIGSERIAL PRIMARY KEY,

    alert_code UUID DEFAULT uuid_generate_v4(),

    title VARCHAR(200) NOT NULL,

    description TEXT,

    module_name VARCHAR(100),

    category VARCHAR(100),

    severity VARCHAR(20),
  
    severity_score INTEGER,

    resolved_duration_hours NUMERIC(8,2),

    priority VARCHAR(20),

    status VARCHAR(30) DEFAULT 'Open',

    source VARCHAR(100),

    affected_entity VARCHAR(150),

    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    resolved_at TIMESTAMP,

    resolved_by BIGINT

        REFERENCES users(id),

    created_by BIGINT

        REFERENCES users(id)

);

CREATE TABLE notifications (

    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT
        REFERENCES users(id),

    title VARCHAR(200),

    message TEXT,

    notification_type VARCHAR(50),

    is_read BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- ACTIVITY LOGS
-- ==========================================================

CREATE TABLE activity_logs (

    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT

        REFERENCES users(id),

    activity_type VARCHAR(100),

    module_name VARCHAR(100),

    description TEXT,

    ip_address VARCHAR(50),

    device_info TEXT,

    browser TEXT,

    operating_system TEXT,

    session_id VARCHAR(255),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- AUDIT LOGS
-- ==========================================================

CREATE TABLE audit_logs (

    id BIGSERIAL PRIMARY KEY,

    table_name VARCHAR(100),

    record_id BIGINT,

    operation VARCHAR(20),

    old_values JSONB,

    new_values JSONB,

    changed_columns JSONB,

    performed_by BIGINT

        REFERENCES users(id),

    reason TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- UPLOAD HISTORY
-- ==========================================================

CREATE TABLE upload_history (

    id BIGSERIAL PRIMARY KEY,

    uploaded_by BIGINT

        REFERENCES users(id),

    file_name VARCHAR(255),

    original_file_name VARCHAR(255),

    file_type VARCHAR(20),

    file_size_mb NUMERIC(10,2),

    total_rows INTEGER,

    total_columns INTEGER,

    missing_values INTEGER,

    duplicate_rows INTEGER,

    quality_score NUMERIC(5,2),

    upload_status VARCHAR(30),

    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- SCHEDULED REPORTS
-- ==========================================================

CREATE TABLE scheduled_reports (

    id BIGSERIAL PRIMARY KEY,

    report_name VARCHAR(150),

    frequency VARCHAR(30),

    next_run TIMESTAMP,

    recipients TEXT,

    created_by BIGINT
        REFERENCES users(id)

);

-- ==========================================================
-- SYSTEM SETTINGS
-- ==========================================================

CREATE TABLE system_settings (

    id BIGSERIAL PRIMARY KEY,

    setting_key VARCHAR(150) UNIQUE,

    setting_value TEXT,

    data_type VARCHAR(30),

    category VARCHAR(100),

    description TEXT,

    editable BOOLEAN DEFAULT TRUE,

    updated_by BIGINT

        REFERENCES users(id),

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- DEFAULT SYSTEM SETTINGS
-- ==========================================================

INSERT INTO system_settings
(setting_key, setting_value, data_type, category, description)
VALUES

('theme','dark','string','UI','Application Theme'),

('currency','INR','string','General','Default Currency'),

('date_format','DD-MM-YYYY','string','General','Date Format'),

('time_zone','Asia/Kolkata','string','General','Application Time Zone'),

('language','English','string','General','Default Language'),

('auto_refresh','60','integer','Dashboard','Dashboard Refresh Interval'),

('max_upload_size','100','integer','Upload','Maximum Upload Size (MB)'),

('forecast_horizon','30','integer','AI','Forecast Horizon (Days)'),

('business_health_threshold','80','integer','Analytics','Business Health Threshold'),

('alert_email_notifications','true','boolean','Alerts','Enable Email Alerts');

-- ==========================================================
-- USER PREFERENES & SAVED DASHBOARDS
-- ==========================================================

CREATE TABLE user_preferences (

    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT
        REFERENCES users(id),

    theme VARCHAR(30),

    language VARCHAR(50),

    timezone VARCHAR(100),

    default_dashboard VARCHAR(100),

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE saved_dashboards (

    id BIGSERIAL PRIMARY KEY,

    dashboard_name VARCHAR(150),

    dashboard_type VARCHAR(100),

    configuration JSONB,

    created_by BIGINT
        REFERENCES users(id),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================================
-- INDEXES
-- ==========================================================

CREATE INDEX idx_alert_status
ON alerts(status);

CREATE INDEX idx_alert_priority
ON alerts(priority);

CREATE INDEX idx_alert_module
ON alerts(module_name);

CREATE INDEX idx_activity_user
ON activity_logs(user_id);

CREATE INDEX idx_activity_module
ON activity_logs(module_name);

CREATE INDEX idx_activity_time
ON activity_logs(created_at);

CREATE INDEX idx_audit_table
ON audit_logs(table_name);

CREATE INDEX idx_audit_record
ON audit_logs(record_id);

CREATE INDEX idx_upload_user
ON upload_history(uploaded_by);

CREATE INDEX idx_upload_date
ON upload_history(uploaded_at);

-- ==========================================================
-- VIEW
-- Active Alerts
-- ==========================================================

CREATE VIEW active_alerts AS

SELECT *

FROM alerts

WHERE status <> 'Resolved'

ORDER BY priority DESC,
         detected_at DESC;

-- ==========================================================
-- VIEW
-- Recent Uploads
-- ==========================================================

CREATE VIEW recent_uploads AS

SELECT *

FROM upload_history

ORDER BY uploaded_at DESC;

-- ==========================================================
-- VIEW
-- Recent Activity
-- ==========================================================

CREATE VIEW recent_activity AS

SELECT *

FROM activity_logs

ORDER BY created_at DESC
LIMIT 100;
