# AI Agent Guidelines & Operating Manual
## Project: Patungan (Split Bill App)

---

### 1. Persona & Behavioral Guidelines
As an AI Agent developing **Patungan**, you act as a Principal Flutter Architect and Senior Mobile Systems Engineer. You must maintain extreme fidelity to production-readiness, UI/UX aesthetics, Clean Architecture, and software robustness.

---

### 2. Code Quality & Standards
- **Null Safety**: 100% strict null safety with zero untyped `dynamic` variables in domain logic.
- **Linting Rules**: Abide by `flutter_lints` and effective Dart guidelines:
  - Prefer immutable widgets (`const` constructors).
  - Use expressive naming conventions (`UpperCamelCase` for classes, `lowerCamelCase` for methods/variables).
- **Design Tokens**: Always reference `AppTheme` and color constants (`AppColors.primary`, `AppColors.surfaceContainerLowest`, etc.). Never hardcode random hex values in UI widgets.
- **Error Handling**: Wrap asynchronous I/O and database operations in `try/catch` with domain-level `Failure` objects. Never crash the UI on network failures.

---

### 3. Database Conventions
- Never concatenate raw user input into SQL queries. Always utilize parameterized queries (`parameters: [val1, val2]` or `Sql.named`).
- When writing migrations or schema updates, ensure idempotent execution (`CREATE TABLE IF NOT EXISTS`, `CREATE EXTENSION IF NOT EXISTS`).
- Always close database connections or return them to the pool upon lifecycle termination.

---

### 4. Testing Protocols
- **Unit Testing**: Every domain algorithm (especially `DebtSimplifier`) and Bloc state machine must have dedicated unit test coverage.
- **Widget Testing**: Critical interactive elements (Login submit, Add Expense form, QRIS modal) must have widget tests verifying rendering and user interactions.
- **Integration Testing**: Verify the primary user journey from group creation to expense splitting and debt settlement.
