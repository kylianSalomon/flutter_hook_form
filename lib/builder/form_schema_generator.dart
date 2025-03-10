import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import '../annotations/form_annotations.dart';

/// Generator for form schemas.
class FormSchemaGenerator extends GeneratorForAnnotation<HookFormSchema> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'HookFormSchema annotation can only be applied to classes.',
      );
    }

    final className = element.name;
    final fields = _getAnnotatedFields(element);

    final buffer = StringBuffer();

    // Add necessary imports
    buffer.writeln('// ignore_for_file: type=lint');
    buffer.writeln();
    buffer.writeln(
        'part of \'${path.basename(element.library.source.uri.path)}\';');
    buffer.writeln();

    // Generate the base class
    buffer.writeln('abstract class _$className extends FormSchema {');

    // Add constructor parameters for each field
    if (fields.isNotEmpty) {
      buffer.write('  _$className({');
      for (final field in fields) {
        final fieldName = field.name;
        final fieldSchemaName = '_${fieldName._capitalize()}FieldSchema';
        buffer.write('required $fieldSchemaName $fieldName, ');
      }
      buffer.writeln('}) : super(');
    } else {
      buffer.writeln('  _$className() : super(');
    }
    buffer.writeln('    fields: {');

    // Add field schemas
    for (final field in fields) {
      final fieldName = field.name;
      final fieldType = _getFieldType(field);

      // Get the field annotation
      final annotation = field.metadata.firstWhere((meta) {
        try {
          final source = meta.toSource();
          return source.startsWith('@HookFormField');
        } catch (e) {
          return false;
        }
      });

      final source = annotation.toSource();
      final start = source.indexOf('[');
      final end = source.lastIndexOf(']');
      final validatorsSource = source.substring(start, end + 1);

      buffer.writeln('      FormFieldScheme<$fieldType>(');
      buffer.writeln('        $fieldName,');
      buffer.writeln('        validators: $validatorsSource,');
      buffer.writeln('      ),');
    }

    buffer.writeln('    },');
    buffer.writeln('  );');
    buffer.writeln('}');
    buffer.writeln();

    // Generate field schema classes
    for (final field in fields) {
      final fieldName = field.name;
      final fieldType = _getFieldType(field);
      buffer.writeln(
          'class _${fieldName._capitalize()}FieldSchema extends TypedId<$fieldType> {');
      buffer.writeln(
          '  const _${fieldName._capitalize()}FieldSchema() : super(\'$fieldName\');');
      buffer.writeln('}');
      buffer.writeln();
    }

    return buffer.toString();
  }

  List<FieldElement> _getAnnotatedFields(ClassElement element) {
    final fields = <FieldElement>[];

    // Get fields from the current class
    final currentFields = element.fields.where((field) {
      if (!field.isStatic) {
        return false;
      }

      final hasAnnotation = field.metadata.any((meta) {
        try {
          final source = meta.toSource();
          return source.startsWith('@HookFormField');
        } catch (e) {
          return false;
        }
      });

      return hasAnnotation;
    }).toList();

    fields.addAll(currentFields);

    return fields;
  }

  String _getFieldType(FieldElement field) {
    final fieldType = field.type;

    if (fieldType is ParameterizedType) {
      if (fieldType.element?.name == 'TypedId') {
        final typeArgs = fieldType.typeArguments;
        if (typeArgs.isNotEmpty) {
          return typeArgs.first.getDisplayString();
        }
      }
    }

    return 'dynamic';
  }
}

extension on String {
  String _capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
