import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator/form_schema_generator.dart';

/// A builder that generates a form schema from a Dart file.
Builder formSchemaBuilder(BuilderOptions options) => LibraryBuilder(
      FormSchemaGenerator(),
      generatedExtension: '.schema.dart',
    );
