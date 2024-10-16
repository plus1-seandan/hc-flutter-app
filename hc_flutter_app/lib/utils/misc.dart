String getBaseUrl(String environment) {
  switch (environment) {
    case 'development':
      return 'https://dev.example.com/api';
    case 'staging':
      return 'https://staging.example.com/api';
    case 'production':
      return 'https://example.com/api';
    default:
      throw Exception('Invalid environment: $environment');
  }
}
