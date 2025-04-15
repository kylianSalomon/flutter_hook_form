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

    // Add necessary imports and part directive
    buffer.writeln('// ignore_for_file: type=lint');
    buffer.writeln();
    buffer.writeln(
        'part of \'${path.basename(element.library.source.uri.path)}\';');
    buffer.writeln();

    // Generate the base class
    buffer.writeln('abstract class _$className extends FormSchema {');
    buffer.writeln('  const _$className();');
    buffer.writeln();

    // Generate static HookField constants
    for (final field in fields) {
      final fieldName = field.name;
      final fieldType = _getFieldType(field);
      final validatorsSource = _getValidatorsSource(field);

      buffer.writeln(
          '  static const $fieldName = HookField<$className, $fieldType>(');
      buffer.writeln('    \'$fieldName\',');
      if (validatorsSource != null) {
        buffer.writeln('    validators: $validatorsSource,');
      }
      buffer.writeln('  );');
    }
    buffer.writeln();

    // Generate fields getter
    buffer.writeln('  @override');
    buffer.writeln('  Set<HookField<FormSchema, dynamic>> get fields => {');
    for (final field in fields) {
      buffer.writeln('    ${field.name},');
    }
    buffer.writeln('  };');
    buffer.writeln();

    // Generate initialValues function
    buffer.writeln(
        '  static Set<InitializedField<$className, dynamic>> initializeWith({');
    // Add parameters
    for (final field in fields) {
      final fieldType = _getFieldType(field);
      buffer.writeln('    $fieldType? ${field.name},');
    }
    buffer.writeln('  }) {');
    buffer.writeln('    return {');
    // Add field initializations
    for (final field in fields) {
      buffer.writeln(
          '      _$className.${field.name}.withInitialValue(${field.name}),');
    }
    buffer.writeln('    };');
    buffer.writeln('  }');

    buffer.writeln('}');

    return buffer.toString();
  }

  String? _getValidatorsSource(FieldElement field) {
    final annotation = field.metadata.firstWhere(
      (meta) => meta.toSource().startsWith('@HookFormField'),
      orElse: () => throw InvalidGenerationSourceError(
        'Field ${field.name} must have @HookFormField annotation',
      ),
    );

    final source = annotation.toSource();
    if (source.contains('validators:')) {
      final start = source.indexOf('[');
      final end = source.lastIndexOf(']');
      if (start != -1 && end != -1) {
        return source.substring(start, end + 1);
      }
    }
    return null;
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
    // First try to get type from annotation
    final annotation = field.metadata.firstWhere(
      (meta) => meta.toSource().startsWith('@HookFormField'),
      orElse: () => throw InvalidGenerationSourceError(
        'Field ${field.name} must have @HookFormField annotation',
      ),
    );

    final source = annotation.toSource();
    if (source.startsWith('@HookFormField<')) {
      final start = source.indexOf('<') + 1;
      // Find the matching closing bracket by counting open/close brackets
      int openBrackets = 1;
      int end = start;

      while (openBrackets > 0 && end < source.length) {
        end++;
        if (source[end] == '<') {
          openBrackets++;
        } else if (source[end] == '>') {
          openBrackets--;
        }
      }

      if (start != -1 && end != -1 && end > start) {
        return source.substring(start, end);
      }
    }

    // Fallback to field type if no explicit type in annotation
    final fieldType = field.type;
    if (fieldType is ParameterizedType) {
      if (fieldType.element?.name == 'HookedFieldId') {
        final typeArgs = fieldType.typeArguments;
        if (typeArgs.isNotEmpty) {
          return typeArgs.first.getDisplayString();
        }
      }
    }

    return 'dynamic';
  }
}
