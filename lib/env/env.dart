class Env {
  // Strings from compile-time defines
  static const appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'App',
  );

  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: '');

  static const cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: '',
  );

  static const cloudinaryUploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: '',
  );

  static const env = String.fromEnvironment('ENV', defaultValue: 'local');

  static bool get isProd => env.toLowerCase() == 'production';
  static bool get isLocal => env.toLowerCase() == 'local';

  static Uri get apiBaseUri => Uri.parse(apiUrl);
}
