/// Dimension & layout tokens derived directly from styles.css
abstract class AppDimens {
  // Page & Shell Dimensions
  static const double appMaxWidth = 480.0;     // .app { max-width: 480px }
  static const double pagePaddingH = 20.0;     // .app { padding: 0 20px 104px }
  static const double pagePaddingBottom = 104.0;
  static const double pagePaddingTop = 48.0;   // .page { padding-top: 48px }
  static const double pageGap = 18.0;          // .page { gap: 18px }
  static const double glowHeight = 300.0;      // .glow { height: 300px }

  // Component Sizes
  static const double btnHeight = 52.0;        // .btn { min-height: 52px }
  static const double btnDangerHeight = 50.0;  // .btn.danger { min-height: 50px }
  static const double inputHeight = 52.0;      // input, select { height: 52px }
  static const double searchInputHeight = 48.0;// .search input { height: 48px }
  static const double navHeight = 80.0;        // .nav { height: 80px }
  static const double iconBtnSize = 44.0;      // .icon-btn { width: 44px; height: 44px }
  static const double avatarSize = 44.0;       // .avatar { width: 44px; height: 44px }
  static const double avatarLgSize = 76.0;     // .avatar.lg { width: 76px; height: 76px }
  static const double dotSize = 9.0;           // .dot { width: 9px; height: 9px }

  // Switch Dimensions
  static const double switchWidth = 46.0;      // .switch { width: 46px }
  static const double switchHeight = 28.0;     // .switch { height: 28px }
  static const double switchKnobSize = 20.0;   // .switch::after { width: 20px; height: 20px }
  static const double switchTravel = 18.0;     // transform: translateX(18px)

  // Dialog Dimensions
  static const double dialogMaxWidth = 420.0;  // dialog { max-width: 420px }
  static const double dialogPadding = 22.0;    // dialog { padding: 22px }
  static const double dialogRadius = 20.0;     // dialog { border-radius: 20px }

  // Component Border Radii
  static const double radiusCard = 16.0;       // .card, .item { border-radius: 16px }
  static const double radiusBtn = 14.0;        // .btn, .icon-btn, input { border-radius: 14px }
  static const double radiusIco = 12.0;        // .ico { border-radius: 12px }
  static const double radiusDialog = 20.0;     // dialog { border-radius: 20px }
  static const double radiusPill = 999.0;      // .chip, .chips button { border-radius: 999px }

  // Grids & List Spacing
  static const double gridGap = 10.0;          // .grid2, .grid3, .list { gap: 10px }
  static const double itemGap = 12.0;          // .item, .row { gap: 12px }
  static const double fieldGap = 8.0;          // .field { gap: 8px }

  // Backward compatibility spacing tokens
  static const double p2 = 2.0;
  static const double p4 = 4.0;
  static const double p6 = 6.0;
  static const double p8 = 8.0;
  static const double p10 = 10.0;
  static const double p12 = 12.0;
  static const double p14 = 14.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
  static const double p48 = 48.0;

  static const double radiusXs = 6.0;
  static const double radiusSm = 10.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;

  static const double blurSubtle = 8.0;
  static const double blurCard = 16.0;
  static const double blurElevated = 28.0;
  static const double bottomNavHeight = 80.0;
  static const double appBarHeight = 52.0;
}
