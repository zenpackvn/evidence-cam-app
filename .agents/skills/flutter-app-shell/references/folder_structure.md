# App Shell — Folder Structure

Full project tree for the opinionated Flutter app layout. Every section links to its own template for concrete code.

```text
assets/
  i18n/
    en.json                            ← English translations
    vi.json                            ← Vietnamese translations
lib/
  main_dev.dart                        ← Dev entry point: bootstrap(Env.dev), runApp
  main_uat.dart                        ← UAT entry point: bootstrap(Env.uat), runApp
  main_prod.dart                       ← Prod entry point: bootstrap(Env.prod), runApp
  src/
    app/
      app.dart                         ← MaterialApp.router: theme, router, localization
      bootstrap/
        app_bootstrap.dart             ← Init DI, localization, global error handlers
      locale/
        app_locale.dart                ← Translation keys for flutter_localization
        locale_controller.dart         ← Optional locale switching state
      router/                           → template-routing.md
        app_router.dart                ← GoRouter with route definitions and guards
        route_names.dart               ← Named route constants
      theme/                           → template-theme.md
        app_theme.dart                 ← ThemeData (light + dark)
        app_colors.dart                ← Color tokens
        app_spacing.dart               ← Spacing tokens
        app_typography.dart            ← Typography tokens
    core/
      config/                          → template-flavors.md
        env.dart                       ← Env enum (dev, uat, prod)
        env_config.dart                ← Per-env values (URLs, flags, timeouts)
        app_config.dart                ← Typed config built from Env + --dart-define overrides
      di/                              → template-di.md
        service_locator.dart           ← Composition root: configureDependencies()
      error/                           → template-network.md
        failure.dart                   ← Sealed Failure hierarchy + FailureException
      logging/                         → template-logging.md
        app_logger.dart                ← AppLogger interface
        logger_impl.dart               ← LoggerImpl wraps package:logger (only import)
      network/                         → template-network.md
        api_client.dart                ← @RestApi() Retrofit client
        dio_client.dart                ← Configured Dio instance
        interceptors/
          auth_interceptor.dart        ← Injects auth token
          error_interceptor.dart       ← Maps DioException → Failure
          logging_interceptor.dart     ← Delegates to AppLogger
      storage/                         → template-storage.md
        secure_storage.dart            ← SecureStorage interface
        secure_storage_impl.dart       ← Wraps flutter_secure_storage (only import)
      database/                        → template-storage.md
        app_database.dart              ← Drift database (only drift import)
        daos/
          cached_item_dao.dart         ← Example DAO
      auth/                            → template-auth.md
        auth_service.dart              ← Auth interface (login, logout, refresh, stream)
        auth_service_impl.dart         ← Token storage + API implementation
        token_manager.dart             ← Token storage, refresh, expiry check
        biometric_service.dart         ← Biometric auth interface
        biometric_service_impl.dart    ← Wraps local_auth (only import)
      analytics/                       → template-analytics.md
        analytics_service.dart         ← Analytics interface (track event/screen)
        analytics_service_impl.dart    ← Wraps Firebase Analytics (only import)
        crash_reporter.dart            ← Crash reporting interface
        crash_reporter_impl.dart       ← Wraps Sentry (only import)
      permissions/                     → template-permissions.md
        permission_service.dart        ← Permission interface
        permission_service_impl.dart   ← Wraps permission_handler (only import)
      push/                            → template-push.md
        push_notification_service.dart ← Push interface
        push_notification_service_impl.dart ← Wraps firebase_messaging (only import)
        local_notification_service.dart     ← Local notification interface
        local_notification_service_impl.dart ← Wraps flutter_local_notifications (only import)
      connectivity/                    → template-offline.md
        connectivity_service.dart      ← Connectivity interface
        connectivity_service_impl.dart ← Wraps connectivity_plus (only import)
      sync/                            → template-offline.md
        sync_queue.dart                ← Pending operations queue
        sync_manager.dart              ← Processes queue when online
      constants/                       ← App-wide constants
      extensions/                      ← Dart extension methods
      utils/                           ← Shared utilities
      widgets/
        common/                        → template-common-widgets.md
          app_top_bar.dart             ← Standard app bar (back button, title, actions)
          app_search_bar.dart          ← App bar with search, AppSliverBar
          app_button.dart              ← AppButton, AppOutlinedButton, AppTextButton, AppIconButton
          app_text_field.dart          ← Text input with label, hint, error, prefix/suffix
          app_password_field.dart      ← Password with show/hide toggle
          app_search_field.dart        ← Search input with clear button
          app_text_area.dart           ← Multiline input with character count
          app_card.dart                ← Content card with consistent padding
          app_selectable_card.dart     ← Card with selected/unselected state
          app_list_tile.dart           ← Standardized list item
          app_divider.dart             ← AppDivider, AppVerticalDivider
          app_section_header.dart      ← Section label + action + divider
          app_badge.dart               ← Notification count badge
          app_status_chip.dart         ← Colored status chip
          app_tag.dart                 ← Small label tag
          app_avatar.dart              ← Circular avatar (image/initials/status dot)
          app_cached_image.dart        ← Wraps cached_network_image (only import)
          app_empty_state.dart         ← Empty state placeholder
          app_error_state.dart         ← Error state with retry
          app_spacer.dart              ← AppSpacerV, AppSpacerH gap widgets
          common.dart                  ← Barrel export
        dialog/                        → template-dialog.md
          app_dialog.dart              ← AppDialog interface (no flutter_smart_dialog import)
          app_dialog_impl.dart         ← Wraps flutter_smart_dialog (only import)
          dialog.dart                  ← Barrel export
        loading/                       → template-loading.md
          app_loading_indicator.dart   ← Wraps flutter_spinkit (only import)
          app_shimmer.dart             ← Wraps shimmer_animation (only import)
          super_list_view.dart         ← All-in-one list: shimmer→error/empty→data+refresh
          screen_loading.dart          ← Full-screen centered loading
          loading_overlay.dart         ← Modal overlay
          loading_button.dart          ← Button with inline spinner
          loading.dart                 ← Barrel export
    features/
      auth/                            ← Example: auth feature
        di/
          auth_module.dart
        presentation/
          pages/
            sign_in_page.dart
          widgets/
            sign_in_form.dart
          cubit/
            sign_in_cubit.dart
            sign_in_state.dart
        domain/
          entities/
          repositories/
        data/
          models/
          sources/
          auth_repository_impl.dart
      home/                            → template-feature-example.md
        di/
          home_module.dart
        presentation/
          pages/
            home_page.dart
          cubit/
            home_cubit.dart
            home_state.dart
          widgets/
        domain/
          home_repository.dart
        data/
          home_repository_impl.dart
test/                                  → template-tests.md
  app_smoke_test.dart
  features/
    home/
      home_cubit_test.dart
```
