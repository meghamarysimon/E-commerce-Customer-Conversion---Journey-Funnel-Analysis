# E-commerce Customer Conversion & Journey Funnel Analysis

Version 2 - validated synthetic capstone dataset.

## Purpose
Designed specifically for:
Visit -> Product View -> Add to Cart -> Checkout -> Payment -> Purchase

## Tables
customers.csv
products.csv
sessions.csv
events.csv
orders.csv
order_items.csv
data_dictionary.csv

## Key project dimensions
- Customer journey and funnel drop-off
- New vs Returning visitors
- Device type
- Traffic source
- Campaign
- Region/country
- Product category and brand
- Payment method
- Revenue and net revenue
- Discounts and shipping
- Order status
- Session engagement

## Date coverage
All sessions, events and orders are within calendar year 2025.

## Important definitions
- first_purchase_date is populated only when the customer has at least one COMPLETED order.
- visitor_type is session-level: Returning means the customer had a prior completed purchase before that session; otherwise New.
- net_revenue is recognized only for Completed orders. Cancelled and Refunded orders have net_revenue = 0.
- Synthetic data is intended for academic/portfolio analysis and must be described as synthetic.

## Dataset size
Customers: 8,500
Products: 500
Sessions: 12,000
Events: 31,633
Orders: 1,750
Order items: 1,750
