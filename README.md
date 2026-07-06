# Flutter Clean Builder

Flutter Web MVP that generates Cubit + Clean Architecture feature files from API request and response JSON samples.

## Run On Mac

```bash
cd flutter_clean_builder
flutter pub get
flutter run -d chrome
```

## Current MVP

- Enter feature name, model name, operation name, method, endpoint.
- Paste request JSON and response JSON.
- Generate:
  - entity
  - model
  - request model when request JSON exists
  - remote data source
  - repository interface
  - repository implementation
  - usecase
  - cubit
  - state
  - starter screen
- Preview each generated file.
- Copy one file or copy all generated files.

## First Supported Flow

- `GET` list/detail
- `POST`, `PUT`, `DELETE` with JSON body
- common response wrappers:
  - `data`
  - `result`
  - `items`
  - `records`
  - nested `data.result`

## Next Decisions

- Add ZIP export.
- Add multiple endpoints per feature.
- Add project-level core templates.
- Add custom Masafat-style naming/templates.
- Add form/list screen generator.
- Add drag and drop UI builder after API generator becomes stable.
