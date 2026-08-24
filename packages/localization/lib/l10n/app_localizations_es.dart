// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get bundleBackendPending =>
      'Esperando un endpoint del servidor para esto';

  @override
  String get bundleCreate => 'Crear';

  @override
  String get bundleCreateClaim => 'Crear expediente de reclamación';

  @override
  String get accountClaims => 'Expedientes de reclamación';

  @override
  String get claimsTitle => 'Expedientes de reclamación';

  @override
  String get claimsLocalOnlyNote =>
      'Algunos expedientes aún no se han subido, por lo que solo existen en este dispositivo.';

  @override
  String get claimsOfflineNote =>
      'No se puede conectar con el servidor; esta es la copia local. Vuelve a abrir con conexión para verlo todo.';

  @override
  String get claimsEmpty =>
      'Aún no hay expedientes. Abre la pestaña Pedidos, toca el botón más y elige las pruebas.';

  @override
  String claimsSummary(int orders, int evidence) {
    return '$orders pedidos · $evidence pruebas';
  }

  @override
  String claimsEvidenceOnly(int evidence) {
    return '$evidence pruebas';
  }

  @override
  String get claimsCopied => 'Contenido del expediente copiado';

  @override
  String get claimsCreated => 'Expediente de reclamación creado';

  @override
  String get claimsPickNothing => 'No hay pruebas seleccionadas';

  @override
  String get claimsDelete => 'Eliminar expediente';

  @override
  String get claimsDeleteConfirm =>
      '¿Eliminar este expediente? Las pruebas en los pedidos no se tocan.';

  @override
  String get claimsDeleteConfirmLink =>
      '¿Eliminar este expediente? Su enlace público muere de inmediato — quien ya lo recibió verá una página vacía. Las pruebas en los pedidos no se tocan.';

  @override
  String get claimsRevokeFailed =>
      'No se pudo revocar el enlace, así que el expediente queda igual. El enlace sigue abierto — inténtalo con mejor conexión, o pide al propietario de la tienda que lo revoque.';

  @override
  String get claimsDeleted => 'Expediente eliminado';

  @override
  String get claimsPhotoAdded =>
      'Foto añadida al expediente y puesta en cola en el pedido';

  @override
  String get claimsAddedLater => 'añadida después';

  @override
  String get claimsCreateTitle => 'Nuevo expediente de reclamación';

  @override
  String get claimsCreateSearchHint =>
      'Escribe o escanea el número de seguimiento';

  @override
  String get claimsCreateNameHint => 'p. ej. Reclamación de devolución 12/08';

  @override
  String get claimsCreateNameLabel => 'Nombre del expediente';

  @override
  String get claimInfoTitle => 'Datos del expediente';

  @override
  String get claimTrackingLabel => 'Código de seguimiento';

  @override
  String get claimShopLabel => 'Tienda';

  @override
  String get claimChannelLabel => 'Canal de venta';

  @override
  String get claimOrderCreatedAt => 'Fecha del pedido';

  @override
  String get claimEvidenceLabel => 'Pruebas';

  @override
  String claimEvidenceCount(int videos, int photos) {
    return '$videos vídeos · $photos fotos';
  }

  @override
  String get claimCreatedAtLabel => 'Expediente creado';

  @override
  String get claimCopyLink => 'Copy link';

  @override
  String get claimsRevokeNoLink =>
      'This dossier is not on the server yet, so there is no link to revoke.';

  @override
  String get claimPageFailed =>
      'Could not open the dossier page. Check your connection and try again.';

  @override
  String get claimLinkLabel => 'Enlace del expediente';

  @override
  String get claimLinkHint =>
      'Cualquiera con el enlace puede verlo, sin iniciar sesión. Sigue activo hasta que lo revoques.';

  @override
  String get claimRevokedBadge => 'Revocado';

  @override
  String get claimRevokedHint =>
      'El enlace está muerto. Los datos siguen intactos: crea un expediente nuevo para volver a compartir.';

  @override
  String get claimRevoke => 'Revocar';

  @override
  String get claimUntitled => 'Expediente sin título';

  @override
  String get claimRevokeConfirmTitle => '¿Revocar este expediente?';

  @override
  String get claimRevokeConfirmBody =>
      'El enlace muere de inmediato para cualquiera que lo tenga, incluido el marketplace. Los datos y los enlaces por pedido no se ven afectados.';

  @override
  String get claimRevoked => 'Expediente revocado. El enlace ya no abre.';

  @override
  String get claimRevokeFailed =>
      'No se pudo revocar. Inténtalo de nuevo cuando tengas conexión.';

  @override
  String get claimNotUploaded =>
      'Este expediente aún no se ha subido, por lo que no tiene enlace. Vuelve a abrirlo cuando tengas conexión.';

  @override
  String get claimDetailLoadFailed =>
      'No se pudo cargar el expediente. Comprueba la conexión y vuelve a abrirlo.';

  @override
  String get claimsCreateStart =>
      'Escribe el número de seguimiento, o toca escanear, para encontrar el pedido de la reclamación.';

  @override
  String get claimsCreateNoOrder =>
      'No hay ningún pedido con ese número de seguimiento en la tienda seleccionada.';

  @override
  String get claimsRemoveItemTitle => 'Quitar del expediente';

  @override
  String get claimsRemoveItemConfirm =>
      '¿Quitar esta prueba del expediente? El vídeo/la foto del pedido no se toca.';

  @override
  String get claimsItemRemoved => 'Quitada del expediente';

  @override
  String get claimsItemAdded => 'Añadido al expediente';

  @override
  String get commonRemove => 'Quitar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get settingDefaultSuffix => 'predeterminado';

  @override
  String get shopDetailClipLength => 'Duración del vídeo';

  @override
  String get shopDeleteTitle => 'Eliminar tienda';

  @override
  String get shopDeleteConfirm =>
      '¿Eliminar esta tienda? Todos sus pedidos, vídeos y fotos se van con ella y no se pueden recuperar.';

  @override
  String get shopDeleteBlockedTitle => 'La tienda todavía tiene miembros';

  @override
  String shopDeleteBlockedBody(int count) {
    return 'Quita a todos los miembros antes de eliminar la tienda. Aún quedan $count.';
  }

  @override
  String get shopDeleted => 'Tienda eliminada.';

  @override
  String bundleSelected(int count) {
    return '$count seleccionados';
  }

  @override
  String get bundleUploadDrive => 'Subir a Drive';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get toastChangeLanguage => 'Cambiar idioma';

  @override
  String get toastTermsPolicy => 'Términos y política';

  @override
  String get toastInfoSaved => 'Datos guardados';

  @override
  String get toastPasswordCreated => 'Contraseña creada';

  @override
  String get toastPasswordChanged => 'Contraseña cambiada';

  @override
  String get toastPendingDossierConfirm =>
      'Todavía tienes un expediente de reclamación abierto, confirma otra vez';

  @override
  String get toastCopiedShareLink => 'Enlace para compartir copiado';

  @override
  String get toastShareFailed => 'No se pudo compartir, inténtalo más tarde';

  @override
  String get toastDownloadingVideo => 'Descargando el vídeo';

  @override
  String get toastVideoDownloadedCopied => 'Vídeo descargado y ruta copiada';

  @override
  String get toastVideoSavedToGallery =>
      'Vídeo guardado en la galería de tu dispositivo';

  @override
  String get toastVideoDownloadFailed =>
      'No se pudo descargar el vídeo, inténtalo más tarde';

  @override
  String get toastVideoDeleteUnavailable => 'Este vídeo no se puede eliminar';

  @override
  String get toastDownloadingPhoto => 'Descargando la foto';

  @override
  String get toastPhotoSavedToGallery =>
      'Foto guardada en la galería de tu dispositivo';

  @override
  String get toastPhotoDownloadedCopied => 'Foto descargada y ruta copiada';

  @override
  String get toastPhotoDownloadFailed =>
      'No se pudo descargar la foto, inténtalo más tarde';

  @override
  String get toastPhotoNoDownloadLink =>
      'La foto aún no tiene enlace de descarga';

  @override
  String get toastPhotoQueued => 'Foto adjuntada — puesta en la cola de subida';

  @override
  String imageOverFixedCap(String megabytes, String limit) {
    return 'La foto pesa $megabytes MB — por encima del límite de $limit MB, no se adjuntó. Elige una imagen más pequeña.';
  }

  @override
  String get toastInvitePending => 'Esperando una invitación a una tienda';

  @override
  String get toastInviteSent => 'Invitación enviada';

  @override
  String get toastMemberAdded => 'Miembro añadido';

  @override
  String get toastVideoPlayFailed => 'No se pudo reproducir el vídeo';

  @override
  String get toastShopCreated => 'Nueva tienda creada';

  @override
  String get toastVideoQueued => 'Vídeo guardado — puesto en la cola de subida';

  @override
  String get toastVideoNoPlayLink =>
      'El vídeo aún no tiene enlace de reproducción';

  @override
  String get toastVideoNoDownloadLink =>
      'El vídeo aún no tiene enlace de descarga';

  @override
  String get toastVideoDeleted => 'Vídeo eliminado';

  @override
  String get toastVideoTypeSaved => 'Tipo de vídeo guardado';

  @override
  String get toastVideoTypeDeleted => 'Tipo de vídeo eliminado';

  @override
  String get toastNoVideoTypeToDelete => 'No hay tipo de vídeo que eliminar';

  @override
  String get toastNoMemberToUpdate => 'No hay miembro que actualizar';

  @override
  String get toastMemberRemoved =>
      'Quitado de la tienda (los vídeos grabados terminan de subirse igualmente)';

  @override
  String get toastInviteRevoked =>
      'Invitación eliminada — el enlace del correo ya no funciona';

  @override
  String copiedLabel(String label) {
    return '$label copiado';
  }

  @override
  String get labelTrackingCode => 'número de seguimiento';

  @override
  String resolutionChanged(String value) {
    return 'Resolución: $value';
  }

  @override
  String get accountNoName => 'Aún sin nombre';

  @override
  String get accountNoShop => 'No hay tienda seleccionada';

  @override
  String get accountCreatePassword => 'Crear contraseña';

  @override
  String get accountChangePassword => 'Cambiar contraseña';

  @override
  String accountLinkedMethods(int count) {
    return '$count vinculados';
  }

  @override
  String get roleOwner => 'Propietario';

  @override
  String get roleStaff => 'Empleado';

  @override
  String memberInviteSent(String role) {
    return '$role · invitación enviada';
  }

  @override
  String memberInvitePending(String role) {
    return '$role · pendiente de confirmación';
  }

  @override
  String get planFree => 'Gratis';

  @override
  String get planBasic => 'Basic';

  @override
  String get planSaver => 'Saver';

  @override
  String get planPremium => 'Premium';

  @override
  String get planPro => 'Pro';

  @override
  String get planEnterprise => 'Empresa';

  @override
  String get roleOther => 'Otro';

  @override
  String get roleUnknown => 'Desconocido';

  @override
  String get memberFallbackName => 'Miembro';

  @override
  String get uploadStatusDone => 'Subido';

  @override
  String get uploadStatusPending => 'Esperando subida';

  @override
  String get uploadStatusQuotaHold => 'En espera (cuota)';

  @override
  String get uploadStatusDeleted => 'Eliminado';

  @override
  String get uploadStatusError =>
      'Subida sin terminar: el vídeo sigue en el dispositivo que lo grabó';

  @override
  String get uploadStatusExpired => 'Periodo de conservación vencido';

  @override
  String expiredOnDate(String date) {
    return 'Periodo de conservación vencido el $date';
  }

  @override
  String get kindPhoto => 'Foto adjunta';

  @override
  String get kindVideo => 'Vídeo';

  @override
  String get recordedByFallback => 'Cuenta actual';

  @override
  String get deviceUnknown => 'Dispositivo desconocido';

  @override
  String get orderNoEvidence => 'Aún no hay pruebas';

  @override
  String get timelineEmpty => 'Este envío todavía no tiene vídeo ni foto';

  @override
  String get errorGenericRetry => 'Algo salió mal, inténtalo de nuevo.';

  @override
  String get errorPendingDossier =>
      'Todavía tienes un expediente de reclamación abierto, resuélvelo antes de continuar.';

  @override
  String get errorSessionExpired =>
      'Tu sesión ha caducado, inicia sesión de nuevo.';

  @override
  String get errorNoNetwork => 'No hay conexión de red, inténtalo de nuevo.';

  @override
  String get errorNoPermission => 'No tienes permiso para esta acción.';

  @override
  String get errorServerBusy => 'El sistema está ocupado, inténtalo más tarde.';

  @override
  String get errorSessionInvalid => 'Sesión no válida, inicia sesión de nuevo.';

  @override
  String get errorVideoTypeInUse =>
      'No se puede eliminar un tipo de vídeo que ya tiene vídeos. Revisa primero los vídeos que usan este tipo.';

  @override
  String get errorBuiltinVideoTypeLocked =>
      'Los 3 tipos de vídeo integrados no se pueden editar ni eliminar.';

  @override
  String get errorVideoTypeNameExists =>
      'Ese nombre de tipo de vídeo ya existe en la tienda.';

  @override
  String get errorCheckNetwork => 'Comprueba tu red o inténtalo más tarde.';

  @override
  String get errorLoadShopList => 'No se pudo cargar la lista de tiendas';

  @override
  String get errorLoadShopMgmt => 'No se pudo cargar la gestión de la tienda';

  @override
  String get errorLoadShopDetail =>
      'No se pudieron cargar los detalles de la tienda';

  @override
  String get errorLoadMembers => 'No se pudo cargar la lista de miembros';

  @override
  String get membersRestricted =>
      'Solo el propietario de la tienda ve la lista de miembros';

  @override
  String get errorLoadOrders => 'No se pudieron cargar los pedidos';

  @override
  String get errorLoadOrderDetail =>
      'No se pudieron cargar los detalles del pedido';

  @override
  String get noShopSelectedOrdersDetail =>
      'Elige primero una tienda para ver los pedidos.';

  @override
  String get noShopSelectedRecordDetail =>
      'Elige primero una tienda antes de grabar.';

  @override
  String get noShopSelectedManageDetail => 'Elige una tienda para gestionar.';

  @override
  String get noOrdersTitle => 'Aún no hay pedidos';

  @override
  String get noOrdersDetail => 'Elige un pedido de la lista.';

  @override
  String get noVideoDataTitle => 'No hay datos de vídeo';

  @override
  String get cannotOpenVideoTitle => 'No se pudo abrir el vídeo';

  @override
  String get cannotOpenVideoDetail =>
      'El vídeo aún no tiene enlace de reproducción.';

  @override
  String get createOrderDialogTitle => '¿Crear un pedido nuevo?';

  @override
  String createOrderDialogBody(String code) {
    return '$code no coincide con ningún número de seguimiento de esta tienda. Revisa el código o confirma la creación de un pedido nuevo.';
  }

  @override
  String get createOrderConfirm => 'Crear pedido nuevo';

  @override
  String get statOrdersToday => 'Pedidos';

  @override
  String get statVideosRecorded => 'Vídeos grabados';

  @override
  String get statPendingUpload => 'Subida pendiente';

  @override
  String get accountPlanQuota => 'Almacenamiento';

  @override
  String get accountChangePlan => 'Cambiar de plan';

  @override
  String get accountSectionApp => 'PLAN Y APP';

  @override
  String get avatarCropTitle => 'Adjust photo';

  @override
  String get avatarCropHint =>
      'Drag and pinch to choose the part you want. Only what is inside the circle is saved.';

  @override
  String get avatarCropConfirm => 'Use this photo';

  @override
  String get avatarCropFailed =>
      'Could not process the photo. Pick another one.';

  @override
  String get accountLanguage => 'Idioma';

  @override
  String get accountSectionSecurity => 'SEGURIDAD E INICIO DE SESIÓN';

  @override
  String get accountLoginMethods => 'Método de inicio de sesión';

  @override
  String get accountSignOut => 'Cerrar sesión';

  @override
  String get accountSignOutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get accountSignOutConfirmMessage =>
      'Tendrás que iniciar sesión otra vez para seguir usando la app.';

  @override
  String get accountDeleteAccount => 'Eliminar cuenta';

  @override
  String accountVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get accountShopMgmtHint =>
      'Gestionar tienda/miembros: toca atrás en la cabecera para volver al nivel Tienda';

  @override
  String get accountInfoTitle => 'Información de la cuenta';

  @override
  String get accountFullName => 'Nombre completo';

  @override
  String get accountFullNameHint => 'Escribe tu nombre completo';

  @override
  String get accountFullNameRequired => 'Escribe tu nombre completo';

  @override
  String get phoneOptionalLabel => 'Número de teléfono (opcional)';

  @override
  String get phoneOptionalHint => 'Opcional — solo para soporte de la cuenta';

  @override
  String get phoneInvalid => 'Número de teléfono no válido';

  @override
  String get accountSaveChanges => 'Guardar cambios';

  @override
  String get accountEmailLockedHint =>
      'Correo usado para iniciar sesión — no se puede cambiar';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonLater => 'Más tarde';

  @override
  String get cameraPermissionRationaleTitle => 'Se necesita acceso a la cámara';

  @override
  String get cameraPermissionRationaleBody =>
      'ZenPack necesita la cámara para grabar vídeos de prueba del empaquetado de tus pedidos.';

  @override
  String get cameraPermissionDeniedTitle => 'Todavía no se puede grabar';

  @override
  String get cameraPermissionDeniedBody =>
      'ZenPack no puede grabar vídeo porque no se ha concedido el acceso a la cámara. Aun así puedes ver, buscar y gestionar tus pedidos.';

  @override
  String get cameraPermissionOpenSettings => 'Abrir Ajustes';

  @override
  String get languageNameVietnamese => 'Vietnamita';

  @override
  String get languageNameEnglish => 'Inglés';

  @override
  String get languageChangeAppliesNote =>
      'Los cambios se aplican al instante en toda la app';

  @override
  String get linkLinked => 'Vinculado';

  @override
  String get linkNotLinked => 'No vinculado';

  @override
  String get loginMethodsEmailNote =>
      'El correo es el identificador de tu cuenta — no se puede quitar. Vincula Google/Apple para iniciar sesión rápido con la misma cuenta.';

  @override
  String get loginMethodIdentity => 'Identificador';

  @override
  String get linkAction => 'Vincular';

  @override
  String get linkUnlink => 'Desvincular';

  @override
  String get quotaScreenTitle => 'Informes y cuota';

  @override
  String get quotaRemainingThisMonth => 'Restante este mes';

  @override
  String get quotaSubtitle => 'Controla el almacenamiento que usas';

  @override
  String quotaRemainingAmount(String amount) {
    return '$amount restantes';
  }

  @override
  String get quotaStorage => 'Almacenamiento';

  @override
  String get deleteAccountTitleStep1 => '¿Eliminar la cuenta?';

  @override
  String get deleteAccountTitleStep2 => '¿Confirmas la eliminación permanente?';

  @override
  String get deleteAccountBodyStep1 =>
      'Todos tus vídeos, envíos y expedientes se eliminarán permanentemente. Esta acción no se puede deshacer.';

  @override
  String get deleteAccountBodyStep2 =>
      'Este es el último paso de confirmación. Tras eliminar, se cerrará tu sesión de inmediato.';

  @override
  String get deleteConfirmPermanent => 'Eliminar permanentemente';

  @override
  String get deleteStep1Hint => 'Paso 1/2 — se pedirá confirmación otra vez';

  @override
  String get deleteStep2Hint => 'Paso 2/2 — esta acción no se puede deshacer';

  @override
  String get passwordCurrentLabel => 'Contraseña actual';

  @override
  String get passwordCurrentRequired => 'Escribe tu contraseña actual';

  @override
  String get passwordNewLabel => 'Contraseña nueva';

  @override
  String get passwordMinHint => 'Al menos 8 caracteres';

  @override
  String get passwordNewRequired => 'Escribe una contraseña nueva';

  @override
  String get passwordMin8Error =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get passwordNeedsLetterDigit =>
      'La contraseña necesita letras y números';

  @override
  String get passwordTooCommon =>
      'Esa contraseña es demasiado fácil de adivinar — elige otra';

  @override
  String get passwordConfirmLabel => 'Repite la contraseña nueva';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden';

  @override
  String get passwordSave => 'Guardar contraseña';

  @override
  String get passwordChangeLogoutNote =>
      'Se cerrará tu sesión en otros dispositivos tras el cambio';

  @override
  String get navOrders => 'Pedidos';

  @override
  String get navRecord => 'Grabar';

  @override
  String get navAccount => 'Cuenta';

  @override
  String get navClaims => 'Reclamaciones';

  @override
  String get changeAvatar => 'Cambiar foto de perfil';

  @override
  String quotaVideosRatio(int remaining, int total) {
    return '$remaining / $total vídeos';
  }

  @override
  String quotaUsedPercent(int percent) {
    return 'Usado $percent%';
  }

  @override
  String quotaRetentionDays(int days) {
    return '$days días';
  }

  @override
  String quotaUsedRatio(String used, String cap, int percent) {
    return 'Usado $used / $cap · $percent%';
  }

  @override
  String get quotaVideosStored => 'Vídeos almacenados';

  @override
  String quotaVideosStoredCount(int count) {
    return '$count vídeos';
  }

  @override
  String get quotaByType => 'Almacenamiento por tipo';

  @override
  String quotaByTypeVideosCount(int count) {
    return '$count vídeos almacenados';
  }

  @override
  String quotaRefundNote(int days) {
    return 'El almacenamiento se libera cuando un vídeo supera su conservación de $days días';
  }

  @override
  String deletePendingProfilesWarning(int count) {
    return 'Todavía tienes $count expedientes “enviados a la plataforma” — sus enlaces para compartir dejarán de funcionar';
  }

  @override
  String get detailRecordedTime => 'Hora de grabación';

  @override
  String get detailDuration => 'Duración';

  @override
  String get detailRecordedBy => 'Grabado por';

  @override
  String get detailCapturedTime => 'Hora de captura';

  @override
  String get detailCapturedBy => 'Capturado por';

  @override
  String get detailDevice => 'Dispositivo';

  @override
  String get detailSize => 'Tamaño';

  @override
  String get detailUploadStatus => 'Estado de subida';

  @override
  String get detailSeal => 'Sellado';

  @override
  String sealSealed(String at) {
    return 'Bloqueado · $at';
  }

  @override
  String get sealWorking => 'Marcando la hora…';

  @override
  String get sealWorkingHint =>
      'La copia almacenada aún no tiene la hora grabada en la imagen, así que el enlace para compartir y la descarga esperan. Suelen ser unos segundos.';

  @override
  String get playLocalCopyNote =>
      'Copia temporal en este dispositivo — todavía sin hora en las imágenes';

  @override
  String get sealNone => 'Grabado antes de que existiera el sellado';

  @override
  String get sealFailed =>
      'Aún sin marca de hora · el vídeo se reproduce y se descarga igualmente';

  @override
  String get sealMismatch =>
      'La huella no coincide — vuelve a grabar este clip';

  @override
  String get sealTimeDrift =>
      'El reloj de la cámara se desvió del servidor, por eso el sello grabado lleva también la hora en que el servidor recibió el clip.';

  @override
  String get detailSealAnchor => 'Prueba independiente';

  @override
  String sealAnchorConfirmed(String block) {
    return 'Sí · entrada n.º $block';
  }

  @override
  String get sealAnchorConfirmedNoBlock => 'Sí';

  @override
  String get sealAnchorPending =>
      'Escribiéndose en el registro público (unas horas)';

  @override
  String get sealAnchorNone => 'Ninguna';

  @override
  String get sealVerifyOpen => 'Abrir la página de verificación';

  @override
  String get sealVerifyHint =>
      'Envía este enlace al marketplace — puede verificarlo por su cuenta, sin confiar en ZenPack.';

  @override
  String get sealVerifyFailed => 'No se pudo abrir la página de verificación.';

  @override
  String get detailPlayVideo => 'Reproducir vídeo';

  @override
  String get detailCopyAssetLink => 'Copiar enlace';

  @override
  String get assetLinkTitle => 'Enlace de la prueba';

  @override
  String get detailDownloadVideo => 'Descargar vídeo';

  @override
  String get detailDownloadNote =>
      'Solo propietario/gerente · para cuando el marketplace pida el archivo original';

  @override
  String get detailTrimVideo => 'Recortar un clip corto para enviar';

  @override
  String get detailTrimNote =>
      'El clip completo queda intacto · el recorte conserva su marca de hora';

  @override
  String get trimSave => 'Guardar';

  @override
  String get trimEstimatedSize => 'Aprox.';

  @override
  String get trimFailed =>
      'No se pudo recortar el vídeo. El clip completo sigue ahí.';

  @override
  String get trimPreparing => 'Descargando el clip completo…';

  @override
  String get detailDownloadPhoto => 'Descargar foto';

  @override
  String get attachPhotoToOrder => 'Adjuntar foto al pedido';

  @override
  String get deleteVideoAction => 'Eliminar vídeo';

  @override
  String get deletePhotoAction => 'Eliminar foto';

  @override
  String get deleteVideoNote =>
      'Solo propietario/gerente · bloqueado mientras haya un expediente abierto · confirmación en dos pasos';

  @override
  String deleteVideoInDossier(String dossier) {
    return 'This evidence is in claim dossier $dossier — remove it from the dossier first, then delete.';
  }

  @override
  String get deleteVideoConfirmTitle => 'Confirmación final';

  @override
  String get deleteVideoConfirmBody =>
      'Esta prueba se eliminará permanentemente y no se podrá recuperar — ¿eliminar de todos modos?';

  @override
  String get deleteVideoConfirmAction => 'Eliminar permanentemente';

  @override
  String ordersErrorCount(int count) {
    return '· $count errores';
  }

  @override
  String ordersPendingCount(int count) {
    return '· $count pendientes';
  }

  @override
  String ordersPendingEvidenceWarning(int count) {
    return '$count pruebas sin subir · aún no hay enlace que copiar';
  }

  @override
  String get captureFramePrompt => 'Escanea el número de seguimiento';

  @override
  String get captureCameraDownHint => 'Coloca la etiqueta dentro del marco';

  @override
  String get cutoverSavedVideo => 'Vídeo guardado';

  @override
  String get cutoverPreparingNext => 'Preparando el siguiente';

  @override
  String get cutoverNextOrder => 'Siguiente pedido';

  @override
  String get lowStorageTitle => 'Almacenamiento casi lleno';

  @override
  String get lowStorageBody =>
      'A este dispositivo le queda poco espacio — una grabación en curso podría no guardarse entera. Libera espacio antes de seguir grabando.';

  @override
  String get lowStorageAction => 'Entendido';

  @override
  String cutoverClosedSummary(String code, String duration) {
    return 'Número de seguimiento $code cerrado ($duration)';
  }

  @override
  String get cutoverSignalText => 'Sonido + vibración al cambiar de pedido';

  @override
  String get tooltipBack => 'Atrás';

  @override
  String get tooltipSwitchCamera => 'Cambiar cámara';

  @override
  String get tooltipEnterTracking => 'Escribir número de seguimiento';

  @override
  String get tooltipZoomIn => 'Acercar';

  @override
  String get tooltipZoomOut => 'Alejar';

  @override
  String get captureResolution => 'Resolución';

  @override
  String get stopRecording => 'Detener la grabación';

  @override
  String get videoTypeSettings => 'Ajustes de tipos de vídeo';

  @override
  String get uploadQueueTitle => 'Cola de subida';

  @override
  String get quotaExhaustedNote =>
      'La cuota mensual se agotó. Grabar sigue funcionando, pero estos clips están EN ESTE TELÉFONO y aún sin protección — se subirán solos en cuanto se amplíe la cuota.';

  @override
  String get queueEmpty => 'Aún no hay vídeos en la cola';

  @override
  String get queueAutoUploadNote =>
      'La subida ocurre automáticamente cuando estás en línea';

  @override
  String get waitingUpload => 'Esperando subida';

  @override
  String get queueUploading => 'Subiendo';

  @override
  String get queueQuotaShort => 'Esperando cuota';

  @override
  String get queueUploadFailed => 'Subida sin terminar';

  @override
  String get uploaded => 'Subido';

  @override
  String get waitingQuota => 'Esperando cuota · aún en el dispositivo';

  @override
  String get pausedUpload => 'En pausa';

  @override
  String get queuePauseAction => 'Pausar';

  @override
  String get queueResumeAction => 'Reanudar';

  @override
  String get queueDeleteAction => 'Quitar';

  @override
  String get queueClearAction => 'Vaciar';

  @override
  String get queueClearConfirmTitle => '¿Vaciar toda la cola?';

  @override
  String get queueClearConfirmBody =>
      'Los clips sin subir solo existen en este teléfono. Vaciar los borra definitivamente.';

  @override
  String get queueDeleteConfirmTitle => '¿Quitar de la cola?';

  @override
  String get queueDeleteConfirmBody =>
      'Este clip aún no se ha subido — al quitarlo se elimina permanentemente de tu dispositivo.';

  @override
  String get toastQueueItemDeleted => 'Quitado de la cola de subida';

  @override
  String get manualTrackingTitle => 'Escribir número de seguimiento';

  @override
  String get manualTrackingNote => 'Escríbelo o vuelve a escanear el código';

  @override
  String get commonDone => 'Listo';

  @override
  String get startRecording => 'Empezar a grabar';

  @override
  String get returnCodeMismatch => 'El código de devolución no coincide';

  @override
  String get enterCodeManually => 'Escribir el código a mano';

  @override
  String get videoTypeLabel => 'Tipo de vídeo';

  @override
  String get videoTypeSelectNote =>
      'Elige el tipo correcto — añadir/editar/eliminar en Detalles de la tienda';

  @override
  String get videoTypeSheetTitle => 'Elige un tipo de vídeo';

  @override
  String get videoTypeGroupDefault => 'Tipos predeterminados (obligatorios)';

  @override
  String get videoTypeGroupCustom => 'Tipos propios de la tienda';

  @override
  String get manageVideoTypesNote =>
      'Gestionar tipos de vídeo — abrir Detalles de la tienda';

  @override
  String queueFilterAll(int count) {
    return 'Todos ($count)';
  }

  @override
  String queueFilterUploading(int count) {
    return 'Subiendo ($count)';
  }

  @override
  String queueFilterErrored(int count) {
    return 'Errores ($count)';
  }

  @override
  String queueFilterQuotaWait(int count) {
    return 'Esperando cuota ($count)';
  }

  @override
  String queueSummary(int pending, int uploading, int errored) {
    return '$pending vídeos esperando · $uploading subiendo · $errored fallidos';
  }

  @override
  String uploadingProgress(int percent) {
    return 'Subiendo $percent%';
  }

  @override
  String errorRetryCount(int count) {
    return 'Error · Reintentar ($count)';
  }

  @override
  String returnCodeMismatchBody(String returnCode, String shopName) {
    return '$returnCode no coincide con ningún pedido de $shopName. Revisa el código, escríbelo a mano o confirma la creación de un pedido nuevo.';
  }

  @override
  String get onboardingSubtitle =>
      'Graba vídeos de prueba del empaquetado para vendedores online';

  @override
  String get onboardingStart => 'Empezar';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authChooseMethod => 'Elige un método de inicio de sesión';

  @override
  String get authEmailRequired => 'Escribe tu correo';

  @override
  String get authEmailInvalid => 'Correo no válido';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authPasswordRequired => 'Escribe tu contraseña';

  @override
  String get authForgotPassword => '¿Olvidaste la contraseña?';

  @override
  String get registerWithGoogle => 'Registrarse con Google';

  @override
  String get registerWithApple => 'Registrarse con Apple';

  @override
  String get authSignInGoogle => 'Iniciar sesión con Google';

  @override
  String get authSignInApple => 'Iniciar sesión con Apple';

  @override
  String get authNoAccountPrompt => '¿No tienes cuenta? ';

  @override
  String get authRegister => 'Registrarse';

  @override
  String get authOr => 'o';

  @override
  String get registerTitle => 'Crear una cuenta nueva';

  @override
  String get registerConfirmPassword => 'Repite la contraseña';

  @override
  String get registerAgreePolicy => 'Acepto la política ';

  @override
  String get registerViewPolicy => 'Ver la política';

  @override
  String get registerCreateAccount => 'Crear cuenta';

  @override
  String get registerSameEmailNote =>
      'El mismo correo se vinculará automáticamente a una sola cuenta';

  @override
  String get registerHaveAccountPrompt => '¿Ya tienes cuenta? ';

  @override
  String get registerSuccessTitle => 'Cuenta creada';

  @override
  String registerSuccessVerifyMessage(String email) {
    return 'Enviamos un correo de verificación a $email. Revisa tu bandeja (también el spam) y luego inicia sesión.';
  }

  @override
  String get registerSuccessMessage =>
      'Tu cuenta está lista. Inicia sesión con el correo y la contraseña que acabas de registrar.';

  @override
  String get registerSuccessAction => 'Iniciar sesión';

  @override
  String get loginNotVerifiedTitle => 'Correo sin verificar';

  @override
  String loginNotVerifiedMessage(String email) {
    return 'Abre el correo de verificación enviado a $email (revisa también el spam), sigue el enlace y vuelve a iniciar sesión.';
  }

  @override
  String get loginResendVerification => 'Reenviar correo';

  @override
  String get loginVerificationResent => 'Correo de verificación reenviado';

  @override
  String get forgotPasswordTitle => 'Olvidé la contraseña';

  @override
  String get forgotPasswordSubtitle =>
      'Escribe tu correo para recibir un enlace de restablecimiento';

  @override
  String get forgotPasswordSubmit => 'Enviar enlace';

  @override
  String get forgotPasswordSent =>
      'Enviado — revisa tu bandeja (también el spam)';

  @override
  String get forgotPasswordRememberPrompt => '¿Recordaste la contraseña? ';

  @override
  String get shopYourShops => 'Tus tiendas';

  @override
  String get shopTapToClockIn =>
      'Toca una tienda para fichar · gestiónala aquí mismo';

  @override
  String get shopLastOpenedNote =>
      'La próxima vez se abrirá directamente la última tienda usada';

  @override
  String get shopManageStore => 'Gestionar tienda';

  @override
  String get shopManageVisibilityNote =>
      'Visible solo para el titular de la cuenta / gerente de la tienda';

  @override
  String get shopEmpty => 'Aún no hay tiendas';

  @override
  String get shopEmptyBody =>
      'Tu cuenta todavía no pertenece a ninguna tienda. Crea una para empezar, o espera la invitación de un propietario.';

  @override
  String get shopCreateNew => 'Crear tienda nueva (nombre + plataforma)';

  @override
  String get shopInvitesHere => 'Las invitaciones a tiendas aparecerán aquí';

  @override
  String get shopCreateTitle => 'Crear tienda';

  @override
  String get shopNameLabel => 'Nombre de la tienda';

  @override
  String get shopNameRequired => 'Escribe un nombre de tienda';

  @override
  String get shopPlatform => 'Marketplace';

  @override
  String get shopCreateOwnerNote =>
      'Serás el propietario de la tienda — añade miembros más tarde en Gestionar tienda';

  @override
  String get shopMgmtVisibilityNote =>
      'Los empleados no ven esta pantalla · los gerentes solo ven las tiendas que gestionan';

  @override
  String get shopAddNew => 'Añadir tienda nueva';

  @override
  String get sectionMembers => 'MIEMBROS';

  @override
  String get sectionShopSettings => 'AJUSTES DE LA TIENDA';

  @override
  String get sectionVideoTypes => 'TIPOS DE VÍDEO';

  @override
  String get videoTypesLockedNote =>
      'Los 3 tipos integrados están bloqueados — no se pueden editar/eliminar';

  @override
  String get addMemberByContact => 'Añadir miembro por correo/teléfono';

  @override
  String get recordResolution => 'Resolución de grabación';

  @override
  String get addVideoType => 'Añadir tipo (escribe un nombre)';

  @override
  String get createVideoTypeTitle => 'Crear tipo de vídeo';

  @override
  String get videoTypeName => 'Nombre del tipo de vídeo';

  @override
  String get videoTypeNameHint => 'p. ej. Pesaje';

  @override
  String get createVideoType => 'Crear tipo';

  @override
  String get deleteVideoTypeBody =>
      'Solo se puede eliminar mientras este tipo no tenga vídeos. Si los tiene, el sistema bloquea la eliminación para no romper los filtros de pruebas ni las estadísticas.';

  @override
  String get deleteVideoTypeConfirm => 'Eliminar tipo';

  @override
  String get deleteVideoTypeNote =>
      '(Solo se puede eliminar mientras el tipo no tenga vídeos)';

  @override
  String get addMemberTitle => 'Añadir miembro';

  @override
  String get addMemberBody =>
      'Escribe el correo de una cuenta ZenPack ya registrada. Recibirá una invitación y tendrá que confirmarla para entrar en la tienda.';

  @override
  String get emailLabel => 'Correo';

  @override
  String get emailRequired => 'Escribe una dirección de correo.';

  @override
  String get emailInvalid => 'Escribe una sola dirección de correo válida.';

  @override
  String get errorInviteAccountNotFound =>
      'Este correo aún no tiene cuenta ZenPack. Pídele que se registre primero y vuelve a invitar.';

  @override
  String get errorInviteAlreadyMember => 'Ya es miembro de esta tienda.';

  @override
  String get errorInviteMemberLimit =>
      'El límite de miembros de este plan está lleno. Las invitaciones pendientes cuentan — revoca una para liberar un sitio.';

  @override
  String get errorInviteAlreadyOwner =>
      'Ese es el propietario de la tienda — no hace falta invitación.';

  @override
  String get errorInviteInvalidRequest =>
      'Ese correo no es válido. Revísalo y envía de nuevo.';

  @override
  String get addMemberSubmit => 'Añadir';

  @override
  String get memberOwnerLocked =>
      'Al propietario no se le puede cambiar el rol ni quitarlo aquí — la propiedad pertenece a la tienda, no a una fila de miembros.';

  @override
  String get removeFromShop => 'Quitar de la tienda';

  @override
  String get revokeInvite => 'Eliminar invitación';

  @override
  String get resolutionAppliesNote =>
      'Se aplica a los vídeos nuevos que grabe la tienda';

  @override
  String get resolutionDefaultOption => '720p (predeterminada)';

  @override
  String get ordersSearchHint => 'Escribir número de seguimiento';

  @override
  String get ordersEmpty => 'Esta tienda aún no tiene pedidos';

  @override
  String recordAutoStopIn(String time) {
    return 'Se detiene solo en $time';
  }

  @override
  String get ordersNotFound => 'No se encontraron pedidos';

  @override
  String get ordersNotFoundHint =>
      'Revisa el número de seguimiento e inténtalo de nuevo';

  @override
  String ordersPageRange(int first, int last, int total) {
    return '$first–$last de $total pedidos';
  }

  @override
  String get ordersPagePrevious => 'Página anterior';

  @override
  String get ordersPageNext => 'Página siguiente';

  @override
  String ordersPageNumber(int page) {
    return 'Página $page';
  }

  @override
  String get filterStatusLabel => 'Estado';

  @override
  String get filterStatusAll => 'Todos';

  @override
  String get filterStatusPending => 'Esperando subida';

  @override
  String get filterStatusError => 'Errores de subida';

  @override
  String get filterStatusDone => 'Subidos por completo';

  @override
  String get filterTimeLabel => 'Fecha';

  @override
  String get filterTimeAll => 'Cualquier fecha';

  @override
  String get filterTimeToday => 'Hoy';

  @override
  String get filterTimeYesterday => 'Ayer';

  @override
  String get filterTime7d => 'Últimos 7 días';

  @override
  String get filterTime30d => 'Últimos 30 días';

  @override
  String get filterTimePickDate => 'Elegir una fecha…';

  @override
  String get filterTypeLabel => 'Tipo de vídeo';

  @override
  String get filterTypeAll => 'Todos';

  @override
  String deleteVideoTypeTitle(String typeName) {
    return '¿Eliminar el tipo \"$typeName\"?';
  }

  @override
  String memberCurrentRole(String role) {
    return 'Rol actual: $role';
  }

  @override
  String get stopCodeTitle => 'Código QR para detener la grabación';

  @override
  String get stopCodeInstructions =>
      'Imprímelo y pégalo en la mesa de empaquetado. Muéstraselo a la cámara durante la grabación para detenerla automáticamente.';

  @override
  String get scannedCodeNotFound =>
      'Ningún pedido coincide con el código escaneado';

  @override
  String get onboardingTaglineOne => 'Cada paquete.';

  @override
  String get onboardingTaglineTwo => 'Una prueba.';

  @override
  String get onboardingTaglineThree => 'Protege tus ingresos.';

  @override
  String get authEmailPlaceholder => 'Escribe tu correo';

  @override
  String get authPasswordPlaceholder => 'Escribe tu contraseña';

  @override
  String get registerCreateAccountSubtitle => 'Crear una cuenta nueva';

  @override
  String get registerFullName => 'Nombre completo';

  @override
  String get registerFullNameRequired => 'Escribe tu nombre completo';

  @override
  String get registerFullNamePlaceholder => 'e.g. Jane Doe';

  @override
  String get registerFullNameTooShort =>
      'Full name needs at least 2 characters.';

  @override
  String get phonePlaceholder => 'e.g. 0912 345 678';

  @override
  String get registerConfirmPasswordPlaceholder =>
      'Type the same password again';

  @override
  String get termsLoadFailed =>
      'Could not open the terms page. Check your connection and try again.';

  @override
  String get termsOpenInBrowser => 'Open in browser';

  @override
  String get registerAgreePrefix => 'Acepto los';

  @override
  String get registerTermsOfUse => 'Términos de uso';

  @override
  String get shopChooseTitle => 'Elige una tienda';

  @override
  String get shopChooseSubtitle => 'Elige una tienda para continuar';

  @override
  String get shopManageTitle => 'Gestionar tiendas';

  @override
  String get shopManageOwnerOnly => 'Visible solo para propietarios y gerentes';

  @override
  String get noShopTitle => 'Aún no hay tiendas';

  @override
  String get noShopLineOne =>
      'Tu cuenta todavía no pertenece a ninguna tienda.';

  @override
  String get noShopLineTwo => 'Crea una tienda para empezar,';

  @override
  String get noShopLineThree => 'o espera la invitación de un propietario.';

  @override
  String get noShopCreateCta => 'Crear una tienda (nombre + marketplace)';

  @override
  String get noShopInviteHint => 'Las invitaciones a tiendas aparecerán aquí';

  @override
  String get createShopTitle => 'Crear tienda';

  @override
  String get createShopNameLabel => 'Nombre de la tienda';

  @override
  String get createShopNameHint => 'p. ej. Tienda ABC';

  @override
  String get createShopPlatformLabel => 'Marketplace';

  @override
  String get createShopOwnerNote =>
      'Serás el propietario de la tienda — añade miembros más tarde en Gestionar tiendas';

  @override
  String get createShopSubmit => 'Crear tienda';

  @override
  String get shopManageDescription =>
      'Consulta y gestiona las tiendas que administras.';

  @override
  String get shopManageAddCta => 'Añadir una tienda';

  @override
  String get shopManageStaffNote =>
      'Los empleados no ven esta pantalla — solo propietarios y gerentes.';

  @override
  String get shopDetailTitle => 'Detalles de la tienda';

  @override
  String get shopDetailResolution => 'Resolución de grabación';

  @override
  String get shopDetailClipDuration => 'Duración máx./vídeo';

  @override
  String clipDurationValue(String minutes) {
    return '$minutes min';
  }

  @override
  String clipRecommendedHint(
    String minutes,
    String platform,
    String megabytes,
    String resolution,
  ) {
    return 'Recomendado $minutes min — para $platform ($megabytes MB/vídeo) + $resolution';
  }

  @override
  String clipRecommendedHintUnverified(String minutes, String platform) {
    return 'Recomendado $minutes min — los límites de $platform no están confirmados, se usan los valores conocidos más seguros';
  }

  @override
  String clipOverRecommendedWarning(
    String minutes,
    String platform,
    String chosen,
    String megabytes,
  ) {
    return 'Por encima de la recomendación de $minutes min para $platform — un vídeo de $chosen min pesa unos $megabytes MB, así que hay que enviarlo como enlace de expediente en lugar de adjuntarlo al formulario de reclamación.';
  }

  @override
  String get clipDurationTitle => 'Duración máxima por vídeo';

  @override
  String get clipDurationSubtitle => 'Se cierra solo al llegar a esta duración';

  @override
  String clipDurationPlanCap(String minutes) {
    return 'Tu plan permite hasta $minutes min';
  }

  @override
  String clipDurationChanged(String minutes) {
    return 'Duración máx./vídeo: $minutes min';
  }

  @override
  String get shopDetailImageSize => 'Tamaño de imagen';

  @override
  String get shopDetailVideoSize => 'Tamaño de vídeo';

  @override
  String get shopDetailUploadSize => 'Tamaño máx./archivo';

  @override
  String uploadSizeValue(String megabytes) {
    return '$megabytes MB';
  }

  @override
  String uploadRecommendedHint(String megabytes, String platform) {
    return 'Recomendado $megabytes MB — límite de adjuntos de $platform';
  }

  @override
  String uploadOverRecommendedWarning(
    String megabytes,
    String platform,
    String chosen,
  ) {
    return 'Por encima de la recomendación de $megabytes MB para $platform — un archivo de hasta $chosen MB se sigue guardando entero, pero hay que enviarlo como enlace de expediente en lugar de adjuntarlo al formulario de reclamación.';
  }

  @override
  String get uploadSizeValueUnlimited => 'Sin límite';

  @override
  String get uploadSizeTitle => 'Tamaño máximo por archivo';

  @override
  String uploadSizeSubtitle(String megabytes, String platform) {
    return 'Los archivos por encima del límite no se adjuntan; $megabytes MB todavía se adjuntan directamente a $platform';
  }

  @override
  String uploadSizeOptionRecommended(String megabytes) {
    return '$megabytes MB (recomendado)';
  }

  @override
  String uploadSizeChanged(String megabytes) {
    return 'Tamaño por archivo: $megabytes';
  }

  @override
  String avatarTooLarge(String megabytes, String limit) {
    return 'Nombre y teléfono guardados. La foto de perfil de $megabytes MB supera el límite de $limit MB y no llegó al servidor — elige una imagen más pequeña.';
  }

  @override
  String avatarUploadFailed(String reason) {
    return 'Nombre y teléfono guardados. La foto de perfil no llegó al servidor: $reason';
  }

  @override
  String nearClipLimitWarning(String minutes) {
    return 'Cerca del límite de $minutes min — el vídeo se cerrará solo';
  }

  @override
  String get shopDetailAddType => 'Añadir un tipo (escribe un nombre)';

  @override
  String get inviteMemberTitle => 'Invitar a un miembro';

  @override
  String get inviteRoleFixedNote =>
      'Entra como empleado: graba vídeos y revisa los suyos.';

  @override
  String get inviteMemberHint => '(aún sin cuenta → enviar invitación)';

  @override
  String get videoTypeIcon => 'Icono';

  @override
  String get videoTypeColor => 'Color';

  @override
  String get createVideoTypeSubmit => 'Crear tipo';

  @override
  String get deleteVideoTypeSafeNote => 'No se pierde ninguna prueba';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String orderErrorCount(int count) {
    return '$count fallidos';
  }

  @override
  String get videoDetailSheetTitle => 'Detalle del vídeo';

  @override
  String get tooltipStopRecording => 'Detener la grabación';

  @override
  String get dossierLinkTitle => 'Enlace del expediente de disputa';

  @override
  String get accountEndQr => 'Código para detener la grabación';

  @override
  String get accountEndQrTitle => 'Código para detener la grabación';

  @override
  String get accountEndQrShare => 'Compartir código';

  @override
  String get accountEndQrSave => 'Guardar en la fototeca';

  @override
  String get recordInterruptedTitle => 'Grabación en pausa';

  @override
  String get recordInterruptedBody =>
      'La grabación se pausó porque algo la interrumpió. ¿Seguir grabando?';

  @override
  String get recordInterruptedResume => 'Continuar';

  @override
  String get recordInterruptedFinish => 'Terminar';

  @override
  String get commonApply => 'Aplicar';

  @override
  String get unitMinutes => 'min';

  @override
  String get clipDurationCustomLabel =>
      'O escribe el número de minutos que quieras';

  @override
  String get supportOpenFailed =>
      'No se pudo abrir — comprueba que la app esté instalada';

  @override
  String get feedbackThanksTitle => '¡Gracias!';

  @override
  String get feedbackThanksBody => 'Tus comentarios ayudan a mejorar ZenPack.';

  @override
  String get feedbackTitle => '¿Qué quieres contarnos?';

  @override
  String get feedbackHint => 'Escribe tu comentario...';

  @override
  String get feedbackSend => 'Enviar comentario';

  @override
  String get feedbackThanks => 'Gracias por tu comentario';

  @override
  String get accountSectionAbout => 'ACERCA DE';

  @override
  String get accountFeedback => 'Envíanos un comentario';

  @override
  String get accountFeedbackNote => 'Comparte tu opinión para mejorar ZenPack';

  @override
  String get accountRateApp => 'Valorar la app';

  @override
  String get accountRateAppNote => 'Apoya el desarrollo de ZenPack';

  @override
  String get supportFacebook => 'Escribir por Facebook';

  @override
  String get supportZalo => 'Escribir por Zalo';

  @override
  String get supportCall => 'Llamar a soporte';

  @override
  String sheetCustomMin(String min, String unit) {
    return 'Escribe $min $unit o más';
  }

  @override
  String sheetCustomRange(String min, String max, String unit) {
    return 'Escribe entre $min y $max $unit';
  }

  @override
  String get accountEndQrNote =>
      'Imprímelo y pégalo en la mesa de empaquetado. Escanearlo durante la grabación cierra el clip. El mismo código funciona en cualquier dispositivo.';

  @override
  String get languageChangeScopeNote =>
      'Cada etiqueta, aviso y expediente\ncambia al idioma que elijas.';

  @override
  String get manualEntryEmptyError =>
      'Escribe un número de seguimiento antes de grabar';

  @override
  String get appUpdateTitle => 'Hay una versión nueva';

  @override
  String get appUpdateMessage =>
      'Actualiza ZenPack para tener las últimas correcciones y novedades.';

  @override
  String get appUpdateNow => 'Actualizar';

  @override
  String get appUpdateLater => 'Más tarde';

  @override
  String get quotaVideosThisMonth => 'Vídeos este mes';

  @override
  String get quotaSubtitleVideos =>
      'Controla cuántos vídeos has grabado este mes';

  @override
  String get quotaUpgrade => 'Mejorar el plan';

  @override
  String get quotaBlockedTitle => 'Cuota de vídeos agotada';

  @override
  String get quotaBlockedNote =>
      'Grabar sigue funcionando, pero los clips todavía no pueden subirse — están en este teléfono, sin protección. Se subirán solos en cuanto se amplíe la cuota.';

  @override
  String get quotaBlockedOwnerNote =>
      'El límite de esta tienda lo fija el titular de la cuenta: pídele que lo amplíe. Un plan que compres se aplica solo a tu propia cuenta.';

  @override
  String get quotaTopupCredits => 'Recargar créditos';

  @override
  String get quotaOverCap => 'Por encima de la cuota del plan';

  @override
  String quotaBlockAt(int n) {
    return 'Nuevas grabaciones bloqueadas en $n vídeos';
  }

  @override
  String get quotaResetMonthly =>
      'Se reinicia al principio del mes que viene; no se acumula nada';

  @override
  String get storageOwnTitle => 'Tu propio almacenamiento';

  @override
  String storageOwnPending(int count) {
    return '$count vídeos esperando para ir a tu almacenamiento';
  }

  @override
  String storageOwnProblem(int count) {
    return '$count vídeos de tu almacenamiento tienen problemas';
  }

  @override
  String get quotaExhaustedWarn =>
      'No desinstales la app ni borres sus datos hasta que se hayan subido.';

  @override
  String quotaStrandedTitle(int count) {
    return '$count vídeos esperando en este teléfono';
  }

  @override
  String get quotaStrandedNote =>
      'Estos vídeos solo existen en este teléfono. Perderlo, desinstalar la app o borrar sus datos los hace desaparecer.';

  @override
  String get storageTitle => 'Almacenamiento de vídeo';

  @override
  String get storageSave => 'Guardar la opción de almacenamiento';

  @override
  String get storageSystemName => 'Almacenamiento del sistema';

  @override
  String get storageS3Name => 'Tu propio almacenamiento (S3)';

  @override
  String get storageDriveName => 'Tu Google Drive';

  @override
  String get storageSystemDesc =>
      'La opción predeterminada; nada que configurar. Es el único sitio donde se mantienen todos los compromisos sobre la prueba.';

  @override
  String get storageOwnDesc =>
      'Los vídeos nuevos van directos a tu almacenamiento. Los antiguos se quedan donde están hasta que acabe su conservación.';

  @override
  String get storageNoPresign =>
      'Este almacenamiento no puede firmar enlaces de descarga, así que los vídeos deben pasar por el servidor — quien abra tu enlace lo notará más lento.';

  @override
  String get storageNoObjectLock =>
      'Este almacenamiento no tiene bloqueo de objetos. No puedes prometerle a un marketplace que la prueba no se pueda borrar.';

  @override
  String get storageNotInPlan =>
      'Tu plan todavía no incluye almacenamiento propio. Mejora el plan en la web para usarlo.';

  @override
  String get storageHealthTitle => 'Salud del almacenamiento';

  @override
  String get storageHealthTotal => 'Vídeos totales';

  @override
  String get storageHealthIntact => 'Intactos';

  @override
  String get storageHealthUnreachable => 'Inalcanzables';

  @override
  String get storageHealthMismatched => 'No coinciden con el sellado';

  @override
  String get storageHealthPendingRelay => 'Esperando en la zona de relevo';

  @override
  String get storageProblemsNote =>
      'Algunos vídeos tienen problemas en tu almacenamiento. Revisa los permisos de acceso en el proveedor.';

  @override
  String get storageTest => 'Volver a probar la conexión';

  @override
  String get storageInUse => 'En uso';

  @override
  String storageLastCheckAt(String time) {
    return 'Última auditoría: $time';
  }

  @override
  String get storageNeverChecked => 'Nunca auditado.';

  @override
  String storageDriveCurrentAccount(String email) {
    return 'Currently connected: $email. Sign in with that address to keep the same Drive, or pick another to switch.';
  }

  @override
  String get storageDriveAccount => 'Cuenta de Drive';

  @override
  String get storageDriveSwitchAccount => 'Switch account';

  @override
  String get storageDriveLogout => 'Sign out of Drive';

  @override
  String get storageDriveLoggedOut => 'Signed out of Drive.';

  @override
  String get storageDriveLogoutConfirm =>
      'The Google account will be removed from this shop and new videos go to system storage. Older videos stay in your Drive, but the system loses its path to them. Reconnecting means granting access again.';

  @override
  String get storageDisconnect => 'Dejar de usar el almacenamiento propio';

  @override
  String get storageDisconnectConfirm =>
      'Los vídeos grabados a partir de ahora van al almacenamiento del sistema. Los antiguos se quedan en el tuyo y el sistema pierde la ruta hacia ellos.';

  @override
  String get storageConnectS3 => 'Conectar almacenamiento S3';

  @override
  String get storageConnectDrive => 'Conectar Google Drive';

  @override
  String get storageConnectHint =>
      'Concede lectura/escritura/borrado solo en el prefijo de abajo — no hace falta permiso sobre todo el bucket.';

  @override
  String get storageConnectSubmit => 'Probar y guardar';

  @override
  String get storageFieldEndpoint => 'Endpoint';

  @override
  String get storageFieldBucket => 'Bucket';

  @override
  String get storageFieldAccessKey => 'Access key ID';

  @override
  String get storageFieldSecretKey => 'Secret access key';

  @override
  String get storageFieldRegion => 'Región';

  @override
  String get storageFieldPrefix => 'Prefijo';

  @override
  String get storageFieldPrefixHint =>
      'Subcarpeta dentro del bucket. Deja el valor predeterminado si no estás seguro.';

  @override
  String get storageDriveFailed =>
      'Could not connect Google Drive: the server\'s connection to Google is not configured yet. That is system-side setup, not a permission the app can ask you for — tell your technical contact.';

  @override
  String get storageConnected => 'Almacenamiento propio conectado.';

  @override
  String get storageDisconnected => 'Almacenamiento propio desconectado.';

  @override
  String get storageSwitchedToSystem =>
      'Saved. New videos go to Cloud Zenpack; your own-storage account is kept.';

  @override
  String get storageResumed => 'Saved. Using your connected storage again.';

  @override
  String get storageTestOk => 'La conexión está bien.';

  @override
  String get storageServerOutdated =>
      'The server does not support switching storage yet. Your videos stay where they are — tell your admin to update the server.';

  @override
  String get storageOwnerOnly =>
      'Solo el propietario de la tienda puede cambiar el almacenamiento.';

  @override
  String get dangerZone => 'Zona peligrosa';

  @override
  String get shopDelete => 'Eliminar tienda';

  @override
  String get shopDeleteDesc =>
      'Elimina permanentemente pedidos, pruebas, archivos guardados y miembros. No se puede deshacer.';

  @override
  String get shopDeleteConfirmTitle => '¿Eliminar esta tienda?';

  @override
  String shopDeleteConfirmBody(int orders, int videos, int members) {
    return '$orders pedidos · $videos vídeos · $members miembros se eliminarán permanentemente.';
  }

  @override
  String shopDeleteOpenDossiers(int n) {
    return 'Todavía hay $n expedientes de reclamación abiertos. Los enlaces ya enviados a los marketplaces mueren en cuanto elimines.';
  }

  @override
  String get shopDeleteForce => 'Eliminar de todos modos';

  @override
  String get shopDeleteFailed => 'No se pudo eliminar la tienda.';

  @override
  String get claimsCreatedLocalOnly =>
      'Expediente guardado en este teléfono. No se pudo subir, así que aún no hay enlace para compartir — vuelve a abrirlo cuando tengas conexión.';

  @override
  String get claimsLinkCopied =>
      'Enlace del expediente copiado. Pégalo en el canal de reclamaciones del marketplace.';

  @override
  String get shopRenameTitle => 'Cambiar nombre de la tienda';

  @override
  String get shopRenameHint => 'Nombre de la tienda';

  @override
  String get shopRenamed => 'Nombre de la tienda cambiado';

  @override
  String get commonSave => 'Guardar';

  @override
  String get inviteJoinRow => 'Tengo una invitación';

  @override
  String inviteJoinedShop(String shop) {
    return 'Te uniste a $shop';
  }

  @override
  String inviteAlreadyJoined(String shop) {
    return 'Ya estás en $shop';
  }

  @override
  String get inviteBadLink =>
      'Ese enlace no es válido. Pega el enlace entero del correo.';

  @override
  String get inviteNotFound => 'La invitación no existe o fue revocada';

  @override
  String get inviteTaken => 'Otra persona ya aceptó esta invitación';

  @override
  String get inviteExpired =>
      'La invitación ha caducado. Pide al propietario de la tienda que la reenvíe.';

  @override
  String get inviteQrRow => 'Código QR';

  @override
  String get inviteQrTitle => 'Código de invitación a la tienda';

  @override
  String get inviteQrNote =>
      'Muestra esta pantalla a la persona que quieres invitar. El código es de un solo uso: cambia cuando alguien se une.';

  @override
  String get inviteScanTitle => 'Escanear el código de invitación';

  @override
  String get inviteScanDetail =>
      'Pide al propietario de la tienda que muestre el código QR de invitación y escanéalo aquí.';

  @override
  String get commonShare => 'Compartir';

  @override
  String get inviteQrSaved => 'Código QR guardado en tu galería';

  @override
  String get inviteQrSaveFailed => 'No se pudo guardar el código QR';

  @override
  String get voiceRecordingStarted => 'Grabación iniciada';

  @override
  String get voiceRecordingStopped => 'Grabación detenida';

  @override
  String get voiceWrongCode => 'Código incorrecto';

  @override
  String get voiceCapSoon => 'El vídeo se cerrará pronto';

  @override
  String voiceCapNear(int minutes) {
    return 'Cerca del límite de $minutes minutos, el vídeo se cerrará solo';
  }

  @override
  String get voiceInterrupted => 'La grabación se interrumpió';

  @override
  String get videoTypePacking => 'Empaquetado';

  @override
  String get videoTypeCarrier => 'Entrega al transportista';

  @override
  String get videoTypeReturn => 'Devolución';

  @override
  String get storageIntro =>
      'Dónde se guardan los vídeos de la tienda. Estén donde estén, el registro del sellado se queda en el sistema — cambiar de almacenamiento nunca debilita la prueba.';

  @override
  String get storageS3Title =>
      'Tu propio almacenamiento en la nube (compatible con S3)';

  @override
  String get storageS3Desc =>
      'AWS S3, Cloudflare R2, MinIO, Wasabi… Los vídeos están en tu bucket y su durabilidad corre por tu cuenta.';

  @override
  String get storageDriveTitle => 'Google Drive';

  @override
  String get storageDriveDesc =>
      'Se conecta con un solo permiso, sin pegar claves. Una cuenta gratuita solo tiene 15 GB compartidos con Gmail.';

  @override
  String get storageNeedProPlan =>
      'Conectar tu propio almacenamiento requiere el plan Profesional o superior.';

  @override
  String get attachCodeToOrder => 'Escanear otro código en este pedido';

  @override
  String get attachedCodes => 'Códigos adjuntos';

  @override
  String get codeAttached => 'Código adjuntado a este pedido';

  @override
  String get codeBelongsToAnotherOrder =>
      'Este código ya pertenece a otro pedido.';

  @override
  String get codeAttachFailed => 'No se pudo adjuntar el código.';

  @override
  String get storageEditCta => 'Change settings';

  @override
  String get storageValidateOk =>
      'The config works. Press Save to switch to this storage.';

  @override
  String get storageTestOnlyCta => 'Test';

  @override
  String shopOwnerLine(String name) {
    return 'Shop owner: $name';
  }

  @override
  String get storageConnectNote =>
      'We write–read–delete a tiny test object before saving. Note: periodic audits download ~1% of videos weekly to verify them — some providers charge egress. If your storage loses data, the video cannot be recovered from anywhere.';

  @override
  String get storageNotConfigured =>
      'This shop has no storage of its own connected, so there is nothing to switch on or off. Reload this screen and try again.';

  @override
  String get storageDriveAccountUnknown => 'Google account not read yet';

  @override
  String get storageSystemSaveNote =>
      'Save removes your own storage: new videos go to system storage.';

  @override
  String get storageDriveSaveNote =>
      'No account connected yet. Tap this card to pick a Google account.';

  @override
  String get storageDriveNoConsent =>
      'Google did not grant long-lived access this time. Open your Google Account → Third-party apps, remove Zenpack, then connect again.';

  @override
  String get storageDriveRejected =>
      'Google refused the grant. Try again; if it keeps failing, tell your admin.';
}
