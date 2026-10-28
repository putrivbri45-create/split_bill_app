# System Architecture & Technical Specifications
## Application: Patungan (Split Bill App)

---

### 1. High-Level Architectural Pattern: Clean Architecture
Patungan adopts **Clean Architecture** combined with a **Feature-First** modular organization. This enforces strict separation of concerns, decoupling domain business logic from UI frameworks and low-level data drivers.

```
lib/
├── config/                  # App constants, routes, theme & design tokens
│   ├── routes.dart          # Named routes & transition animators
│   └── theme.dart           # Emerald/Mint tokens, typography, dark/light styles
├── core/                    # Cross-cutting foundational infrastructure
│   ├── algorithm/           # DebtSimplifier greedy debt minimization engine
│   ├── database/            # Neon Postgres client, pool manager & retry interceptors
│   ├── errors/              # Custom exceptions & failures
│   ├── network/             # Connectivity & SSL channel validation
│   ├── security/            # BCrypt/Argon2 hashing & flutter_secure_storage wrapper
│   └── utils/               # Currency formatters (IDR Rp), date formatters
├── features/                # Domain-centric feature modules
│   ├── auth/                # Login, Register, Biometric lock
│   ├── dashboard/           # Home, Balance cards, Recent activities
│   ├── groups/              # Group creation, details, member lists
│   ├── expenses/            # Add expense, multi-split calculators, receipt uploads
│   ├── settlements/         # Split summary, debt graph, QRIS payment modal
│   ├── history/             # Filterable transaction ledger & PDF/CSV export
│   ├── notifications/       # Activity notification feed
│   ├── profile/             # Profile avatar, linked payment accounts
│   └── settings/            # Security, Theme, Language, Cache, Logout
└── shared/                  # Reusable presentation widgets & UI components
    ├── buttons/             # Primary, secondary, outline & icon buttons
    ├── cards/               # Bento summary cards, ledger cards
    ├── inputs/              # Currency input, text input, search bars
    └── modals/              # QRIS bottom sheet, confirm dialogs
```

---

### 2. Layers Breakdown

#### A. Domain Layer (Innermost - Pure Dart)
- **Entities**: Business models (`User`, `Group`, `Expense`, `ExpenseSplit`, `Settlement`).
- **Repositories (Interfaces)**: Pure abstract contracts defining required data interactions without knowledge of databases.
- **Use Cases**: Encapsulated business actions (`CalculateSplit`, `SimplifyDebts`, `SettleDebt`, `CreateExpense`).

#### B. Data Layer (Middle - Persistence & APIs)
- **Data Sources**:
  - `PostgresRemoteDataSource`: Direct connection pool to Neon PostgreSQL utilizing parameterized queries.
  - `LocalCacheDataSource`: Offline caching with `SharedPreferences` and encrypted session keys in `FlutterSecureStorage`.
- **Repository Implementations**: Coordinates between local cache and Neon database, handling auto-reconnect, exponential backoff, and offline fallback.
- **Models / Mappers**: Translates raw database rows and JSON payloads into domain entities.

#### C. Presentation Layer (Outermost - Flutter UI & BLoCs)
- **State Management**: **BLoC (Business Logic Component)** with unidirectional data flow:
  `UI Event -> BLoC -> Use Case / Repository -> State (Initial, Loading, Success, Failure) -> UI Rebuild`.
- **Reactive UI**: Utilizes `BlocBuilder`, `BlocConsumer`, and `BlocListener` for toast notifications and routing.

---

### 3. Split & Debt Simplification Algorithm (DebtSimplifier)

#### Algorithm Logic:
1. **Net Balance Calculation**:
   $$\text{net\_balance}_i = \sum \text{paid}_i - \sum \text{owed}_i$$
2. **Partitioning**:
   - Debtors list: users with $\text{net\_balance} < 0$.
   - Creditors list: users with $\text{net\_balance} > 0$.
   - Balanced users ($\text{net\_balance} == 0$) are omitted.
3. **Greedy Matching**:
   - Sort debtors ascending (largest debt first) and creditors descending (largest credit first).
   - In each iteration, match the top debtor with the top creditor for the amount:
     $$\text{amount} = \min(|\text{debtor.balance}|, \text{creditor.balance})$$
   - Deduct $\text{amount}$ from both balances; push transaction $(\text{debtor} \to \text{creditor}, \text{amount})$ to result list.
   - Remove zeroed-out parties and repeat until all balances are zero.

---

### 4. Database Connection & Resilience Strategy

- **Connection Pool**: Maintains a pool of reusable connections to Neon PostgreSQL.
- **SSL / TLS Enforced**: `SslMode.require` ensures all network packets are encrypted.
- **Auto-Reconnect & Retry Interceptor**: Automatically retries queries on transient SSL connection drops or pool idle timeouts using exponential backoff (1s, 2s, 4s).
- **Graceful Offline Fallback**: If internet connectivity is interrupted, the app serves cached group data and queues unsent operations locally.

---

### 5. Security & Protection Mandates

- **Credential Obfuscation**: Database secrets stored in `.env` and loaded at runtime via `flutter_dotenv`.
- **Zero Plaintext Passwords**: Password verification utilizes cryptographic hashing (`pgcrypto` / SHA-256 with salt).
- **SQL Injection Immunization**: 100% of queries use prepared statements with positional parameters (`Sql.named` / `$1, $2`).
- **Biometric Integration**: `local_auth` provides instant fingerprint/Face ID protection on app launch and settlement authorization.
