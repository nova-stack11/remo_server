# rafaelbarbosatec_api

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![Powered by Dart Frog](https://img.shields.io/endpoint?url=https://tinyurl.com/dartfrog-badge)](https://dartfrog.vgv.dev)

An example application built with dart_frog

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis


Run server
```bash
dart_frog dev
```

Note release:
```bash
sh deploy_docker_release.sh
```

💡 Nếu gặp lỗi “Permission denied”:
chmod +x deploy.sh

Reset db postgres:
cd ..
```bash
docker-compose down -v
docker-compose up -d
```
