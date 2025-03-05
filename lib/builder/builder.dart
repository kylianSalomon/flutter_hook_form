import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'form_schema_generator.dart';

Builder formSchemaBuilder(BuilderOptions options) => LibraryBuilder(
      FormSchemaGenerator(),
      generatedExtension: '.schema.dart',
    );
