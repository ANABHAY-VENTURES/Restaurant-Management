# Restaurant Management

**An Enterprise Restaurant Operating System by Anabhay Ventures**

Built exclusively with a **Dart-first and Flutter-first architecture** across Web, Android, iOS, and Desktop.

---

## 💎 Official Premium Design System

Adhering strictly to the official Anabhay Ventures palette:
- **Matte Black (`#171717`)**: Root canvas and primary background.
- **Deep Charcoal (`#242321`)**: Surfaces, navigation panels, elevated cards, and sidebar.
- **Champagne Gold (`#B88746`)**: Brand identity, active navigation states, primary buttons, and currency highlights.
- **Warm Ivory (`#F3EBDD`)**: High-contrast, elegant typography.
- **Copper (`#A45D35`)**: Secondary accents, station tags, and badges.
- **Muted Grey (`#88847C`)**: Secondary text, subtle borders, and placeholder glyphs.
- **Semantic Accents**: Success Green (`#39734D`), Warning Amber (`#C58B38`), Error Red (`#B94B42`).

---

## 🏛️ Monorepo Structure

```text
restaurant_management/
├── apps/
│   ├── restaurant_app/           # Primary multi-platform restaurant operations app
│   └── customer_qr_app/          # Mobile-first customer QR dining & ordering web app
├── packages/
│   ├── design_system/            # Reusable theme tokens & UI component library
│   ├── shared_models/            # Pure Dart domain entities (Tenants, Tables, Menu, Orders)
│   └── shared_services/          # Dio ApiClient, Network, Storage & Realtime event bus
├── server/
│   └── restaurant_server/        # High-performance Dart Shelf/Serverpod backend
├── frontend/                     # Active Flutter application workspace
│   ├── lib/
│   │   ├── core/                 # Design tokens & GoRouter navigation
│   │   ├── features/
│   │   │   ├── dashboard/        # Owner Dashboard with KPIs & Sales charts
│   │   │   ├── pos/              # POS Billing & GST Thermal Invoice Preview
│   │   │   ├── kitchen/          # Kitchen Display System (KDS) & bump-bar
│   │   │   ├── tables/           # Interactive Floor Plan & table statuses
│   │   │   ├── menu/             # Menu & Category management with stock toggles
│   │   │   ├── inventory/        # Raw materials, units, and low-stock alerts
│   │   │   └── customer_qr/      # Mobile QR ordering view
│   │   └── shared/widgets/       # Standard reusable components
│   └── test/                     # Flutter widget test suite
├── backend/                      # Production Dart REST API server
│   ├── bin/server.dart           # Shelf HTTP server with port auto-fallback
│   ├── lib/src/database/         # PostgreSQL connection pool & schema DDL
│   └── test/server_test.dart     # Endpoint unit tests
├── infrastructure/
│   ├── database/                 # schema.sql & rich demo seeds.sql
│   ├── docker/                   # Dockerfile.frontend & Dockerfile.backend
│   └── nginx/                    # Reverse proxy & SPA routing configs
├── docs/                         # Architecture documentation
└── docker-compose.yml            # Multi-service stack (PostgreSQL, Redis, Backend, Frontend)
```

---

## 📱 Implemented Screens & Features

1. **Owner Dashboard (`/`)**:
   - Financial KPIs: Today's Sales, Orders Count, Active Tables, Kitchen Queue.
   - Dynamic Hourly Sales Bar Chart (`fl_chart`).
   - Live Kitchen preparation progress card.
   - Top-Selling menu items table.
   - Recent transaction audit feed.
   - Labeled `DEMO DATA` status indicator.

2. **Point of Sale (POS) Billing (`/pos`)**:
   - Categorized menu item selector with vegetarian / non-vegetarian badges.
   - Instant search and category chip filters.
   - Live cart with automatic 5% GST calculation (2.5% CGST + 2.5% SGST).
   - Order type switcher (Dine-in, Takeaway, Delivery).
   - Print & Kot dispatch triggers.

3. **Tax Invoice Preview (Modal Dialog)**:
   - High-fidelity thermal receipt layout (80mm specification).
   - FSSAI License, GSTIN, invoice timestamp, itemized unit prices, and tax breakdown.
   - Print invoice action button.

4. **Kitchen Display System (KDS) (`/kitchen`)**:
   - Station filters: Tandoor & Grill, Curry & Main, Breads, Dessert & Bar.
   - Elapsed order preparation timers with color thresholds (<10m Green, 10-12m Amber, >12m Red).
   - Interactive item strike-through checklist.
   - One-tap "Mark Ready & Bump" workflow.

5. **Table Management & Floor Plan (`/tables`)**:
   - Interactive dining zones (Main Dining Hall, Terrace Garden, VIP Lounge, Private Dining).
   - Real-time status indicators (Available, Occupied, Billed, Reserved).
   - Waiter assignments, seated capacity, and live running bill totals.

6. **Menu & Category Management (`/menu`)**:
   - Real-time in-stock / out-of-stock availability toggles.
   - Veg / non-veg categorization and itemized pricing.
   - Interactive "Add New Dish" modal dialog.

7. **Inventory & Stock Tracking (`/inventory`)**:
   - Raw ingredient threshold monitoring (Grains, Spices, Dairy, Meat).
   - Low-stock warning banner.
   - "Record Stock Inward" modal dialog.

8. **Customer QR Digital Menu (`/qr-menu` / `/qr/:table`)**:
   - Standalone mobile-web optimized interface (no sidebar).
   - Category filtering and Veg-only toggle.
   - Interactive cart with floating checkout bar.

---

## 🛠️ Verification & Test Results

| Component | Tool | Result |
| :--- | :--- | :--- |
| **Frontend Code Quality** | `flutter analyze` | **0 issues found** |
| **Frontend Widget Tests** | `flutter test` | **100% Passed** |
| **Backend Code Quality** | `dart analyze` | **0 issues found** |
| **Backend Unit Tests** | `dart test` | **100% Passed** |
| **Web Compilation** | Flutter Web Chrome | **Verified (Port 3000)** |
| **Mobile Hardware** | Samsung Galaxy A16 5G (`SM A166P`) | **Installed & Running (Impeller Vulkan)** |

---

## 🚀 Run Commands

### 1. Launch Flutter Web App
```powershell
cd frontend
flutter run -d chrome --web-port=3000
```

### 2. Launch on Connected Android Device (Samsung Galaxy A16 5G)
```powershell
cd frontend
flutter run -d R9ZY802J5DK
```

### 3. Start Dart Backend Server
```powershell
cd backend
dart run bin/server.dart
```
*Auto-binds to available port (default `8085` / fallback `8080`).*
- Health Check: `GET http://localhost:8085/api/v1/health`
- Dashboard Summary: `GET http://localhost:8085/api/v1/dashboard/summary`

### 4. Run Test Suites
```powershell
# Frontend tests
cd frontend
flutter test

# Backend tests
cd ../backend
dart test
```
