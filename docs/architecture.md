# Restaurant Management — System Architecture
## By Anabhay Ventures

### 1. Technology Ecosystem
- **Frontend**: Flutter & Dart (Web, Android, iOS, Windows/macOS Desktop)
- **State Management**: Flutter Riverpod 2.6
- **Navigation**: GoRouter 14.8 with shell navigation
- **Backend**: Dart Shelf HTTP Server & Serverpod ORM/PostgreSQL integration
- **Database**: PostgreSQL 16 with UUID PKs, Numeric financial calculations, and UTC timestamps
- **Cache & Realtime**: Redis 7 and WebSockets
- **Infrastructure**: Docker, Docker Compose, Nginx Reverse Proxy

### 2. Premium Design System Palette
| Colour Name | Hex Code | Purpose |
|---|---|---|
| Matte Black | `#171717` | Primary background, root canvas |
| Deep Charcoal | `#242321` | Sidebar and primary surface background |
| Champagne Gold | `#B88746` | Brand accent, active states, key financial highlights |
| Warm Ivory | `#F3EBDD` | Primary typography and headings |
| Copper | `#A45D35` | Secondary accent, trending tags, badges |
| Muted Grey | `#88847C` | Subdued labels, disabled states, borders |
| Success Green | `#39734D` | Positive financial trends, paid invoices, in-stock status |
| Warning Amber | `#C58B38` | Pending orders, preparing tickets, demo notices |
| Error Red | `#B94B42` | Out-of-stock items, cancelled orders, overdue tickets |

### 3. User Roles (10 Roles)
1. **SaaS Super Admin** (Anabhay Ventures platform administration)
2. **Restaurant Owner** (Full restaurant overview, financial analytics, branch controls)
3. **Restaurant Admin** (Menu, pricing, inventory, staff assignments)
4. **Branch Manager** (Shift oversight, daily register closing, operational reports)
5. **Cashier** (POS billing, GST calculation, split bills, payment collection)
6. **Waiter** (Table management, order creation, order modification, guest requests)
7. **Kitchen Staff** (KDS station queue, order preparation, bump bar status updates)
8. **Inventory Manager** (Stock intake, recipe wastage, low stock replenishment, suppliers)
9. **Accountant** (Financial ledger, GST returns, expense entries, profit/loss analysis)
10. **Customer** (QR table ordering, digital menu browsing, feedback, loyalty)

### 4. Database Models (Phase 1 Baseline)
- `tenants`: Multi-tenant organization boundaries and subscription tiers
- `branches`: Physical restaurant branch locations with GSTIN/FSSAI compliance
- `users`: Staff and owner accounts with role-based access control (RBAC)
- `restaurant_tables`: Floor map layout, table numbers, guest capacities, and statuses
- `menu_categories`: Food and beverage categorization
- `menu_items`: Food items, prices, GST tax rates, veg/non-veg tags, and prep times
- `orders`: Dine-in, takeaway, and delivery orders with GST calculation
- `order_items`: Line items with quantities, pricing, and special kitchen instructions

### 5. Multi-Tenant Isolation
Every query enforces `tenant_id` and `branch_id` scoping. No tenant data is ever visible across organization boundaries.

