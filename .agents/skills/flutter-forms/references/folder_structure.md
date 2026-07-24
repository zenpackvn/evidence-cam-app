# Forms — Folder Structure

## Core forms infrastructure

```text
lib/src/core/
  forms/
    form_validator.dart                  ← Pure validation functions
    form_field_state.dart                ← Generic field state model
    form_mixin.dart                      ← Cubit mixin for form lifecycle
```

## Feature layout (multi-step example)

```text
lib/src/features/
  registration/                          ← Multi-step form example
    domain/
      registration_validator.dart        ← Feature-specific validation rules
    presentation/
      registration_cubit.dart            ← Form state machine
      registration_state.dart            ← Sealed form states
      pages/
        registration_page.dart           ← Stepper / PageView host
        step_personal_info.dart          ← Step 1 widget
        step_address.dart                ← Step 2 widget
        step_review.dart                 ← Step 3 widget
    di/
      registration_module.dart           ← DI registration
```
