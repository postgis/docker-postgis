
# Developer Documentation

* 🧪 test images: https://hub.docker.com/r/imresamu/postgis
* 🧪 test github: https://github.com/ImreSamu/docker-postgis

## Development Goals Prior to Public Discussion:

- [x] Use Dockerfile templates and version.json, and follow best practices from the official PostgreSQL Dockerfiles as closely as possible.
- [x] Support for multiple Debian and Alpine releases (e.g., Buster, Bullseye, Alpine 3.18)
- [x] Release new Geo bundle version with pgRouting,MobilityDB,H3,...
  - [ ] need more test, refactoring
- [x] Support multi tags
 - `15-3.4-alpine3.18 15-3.4.0-alpine3.18 15-3.4-alpine alpine`
 - `15-3.4-bundle-bookworm 15-3.4.0-bundle-bookworm 15-3.4-bundle bundle`
 - `15-master-bookworm 15-master`
- [x] Special tags for the latest versions `alpine`,`bundle`,`latest`
- [x] Automatically update continuous integration (CI) scripts, and maintain `README.md` based on `./version.json`
- [x] Support development repositories with easier setup ( `.env`  )
- [ ] Implement multi-architecture multi-cloud support
  - [x] Support amd64 via GitHub Actions `.github/workflows/main.yml`
  - [x] Support arm64 via CircleCI (using native arm, not emulated) `.circleci/config.yml`
  - [ ] Synchronize CI Tasks
  - [ ] Handle manifest creation (complex task)
- [x] Shellcheck verify
- [x] Minimal test flow with local registy ( `./localtest.sh` )
- [x] New Makefile; with `make help`
- [ ] Refactoring README.md ( Github API 25000 char limit  )
- [ ] Refactoring & Testing
- [ ] Provide developer documentation



https://github.com/dvershinin/lastversion
