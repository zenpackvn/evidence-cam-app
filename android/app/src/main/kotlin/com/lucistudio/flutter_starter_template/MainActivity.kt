package com.lucistudio.flutter_starter_template

import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * FlutterFragmentActivity chứ không phải FlutterActivity.
 *
 * Màn paywall của RevenueCat là một Fragment của Android, nên nó cần một
 * activity có FragmentManager. Với FlutterActivity thì SDK từ chối mở và trả
 * về PAYWALLS_MISSING_WRONG_ACTIVITY — người dùng bấm "Nâng cấp gói" và không
 * thấy gì xảy ra, không một thông báo nào.
 */
class MainActivity : FlutterFragmentActivity()
