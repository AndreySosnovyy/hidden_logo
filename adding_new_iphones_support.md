# Adding iPhone support

Enable a model only after independently verifying its identifiers and cutout
geometry. Unknown identifiers must continue to display the app body without a logo.

1. Check Apple's device profiles and runtime identifiers for each variant and
   alias. In `lib/src/parser.dart`, update `DeviceModel`, the identifier map,
   logo type, maximum constraints and Dynamic Island top padding as needed.
2. Compare saturated logo captures with and without the simulator's black and
   alpha masks. Check standard portrait and Display Zoom layouts, device pixel
   ratios, downsampled mini screens and landscape behavior. Keep the logo inside
   the mask's opaque interior. Simulator checks do not replace physical-device
   checks of Display Zoom or active Dynamic Island states.
3. Update the model lists in `test/utils.dart` and tests in `test/parser/`.
   Add widget coverage for positioning and scaling. For Dynamic Island models,
   extend `test/fixtures/dynamic_island_masks.json` with independently measured
   mask rows and provenance, then check
   `test/widgets/dynamic_island_geometry_regression_test.dart`. For notch changes,
   check `test/widgets/notch_geometry_regression_test.dart`.
4. Add the model to the supported-device table in `README.md` and describe the
   change in `CHANGELOG.md`. Keep measurement logs and temporary captures out of
   README; retained mask evidence belongs in the test fixtures.
5. Run the [development checks](CONTRIBUTING.md#local-checks), the relevant native
   builds and visual checks from the [example guide](example/README.md).

## iPhone Duo

Duo remains without a logo. Do not reuse centered notch or Dynamic Island presets.
Before enabling it, verify its identifiers, both screen configurations and camera
masks with a simulator/runtime that contains the model, then add regression tests.
