import '../../core/constants/app_strings.dart';
import '../../core/localization/app_localizations.dart';

class CvRules {
  static List<String> hintsForType(String cvType, AppLocalizations l) {
    if (cvType == AppStrings.cvTypeGulf) {
      return [
        l.t('hintsGulfPhoto'),
        l.t('hintsGulfPassport'),
        l.t('hintsGulfLicenses'),
      ];
    }
    return [
      l.t('hintsProPhoto'),
      l.t('hintsProResults'),
      l.t('hintsProSummary'),
    ];
  }
}
