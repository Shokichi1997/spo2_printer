class PosFont {
  static const int FONT_A = 0; // default
  static const int FONT_B = 1;
  static const int FONT_C = 2;
}

class PosAlign {
  static const int ALIGN_LEFT = 0;
  static const int ALIGN_CENTER = 1;
  static const int ALIGN_RIGHT = 2;
}

class PosCut {
  static const int CUT_NO_FEED = 0;
  static const int CUT_FEED = 1;
}

class PosColor {
  // TM-m30 only support color 1
  static const int COLOR_1 = 1;
}

class PosMode {
  static const int MODE_MONO = 0;
  static const int MODE_MONO_HIGH_DENSITY = 2;
}

class PosHalftone {
  static const int HALFTONE_DITHER = 0;
  static const int HALFTONE_ERROR_DIFFUSION = 1;
  static const int HALFTONE_THRESHOLD = 2;
}

class PosCompress {
  static const int COMPRESS_NONE = 0;
  static const int COMPRESS_DEFLATE = 1;
  static const int COMPRESS_AUTO = 2;
}

class PosConnection {
  static const int EPOS2_FALSE = 0;
  static const int EPOS2_TRUE = 1;
}

