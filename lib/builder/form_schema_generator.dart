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
        final fieldSchemaName = '_${fieldName.capitalize()}FieldSchema';
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
      final fieldAnnotation = field.metadata.firstWhere((meta) {
        try {
          final value = meta.computeConstantValue();
          return value?.type?.toString().contains('HookFormField') ?? false;
        } catch (e) {
          return false;
        }
      }).computeConstantValue();

      final validators =
          fieldAnnotation?.getField('validators')?.toListValue() ?? [];

      buffer.writeln('      FormFieldScheme<$fieldType>(');
      buffer.writeln('        $fieldName,');
      buffer.writeln('        validators: (value, context) {');

      // Chain validators
      var validatorChain = '(value, context) {}';
      for (final validator in validators.reversed) {
        final validatorType = validator.type.toString();
        if (validatorType.contains('RequiredValidator')) {
          validatorChain = '$validatorChain.required()';
        } else if (validatorType.contains('EmailValidator')) {
          validatorChain = '$validatorChain.email()';
        } else if (validatorType.contains('MinLengthValidator')) {
          final length = validator.getField('length')?.toIntValue() ?? 0;
          validatorChain = '$validatorChain.min($length)';
        } else if (validatorType.contains('MaxLengthValidator')) {
          final length = validator.getField('length')?.toIntValue() ?? 0;
          validatorChain = '$validatorChain.max($length)';
        } else if (validatorType.contains('CustomValidator')) {
          final validatorFn =
              validator.getField('validator')?.toStringValue() ?? '';
          validatorChain = '$validatorChain.custom($validatorFn)';
        }
      }
      buffer.writeln('          return $validatorChain(value, context);');
      buffer.writeln('        },');
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
          'class _${fieldName.capitalize()}FieldSchema extends TypedId<$fieldType> {');
      buffer.writeln(
          '  const _${fieldName.capitalize()}FieldSchema() : super(\'$fieldName\');');
      buffer.writeln('}');
      buffer.writeln();
    }

    return buffer.toString();
  }

  List<FieldElement> _getAnnotatedFields(ClassElement element) {
    final fields = <FieldElement>[];

    // Get fields from the current class
    final currentFields = element.fields.where((field) {
      final hasAnnotation = field.metadata.any((meta) {
        try {
          final value = meta.computeConstantValue();
          return value?.type?.toString().contains('HookFormField') ?? false;
        } catch (e) {
          return false;
        }
      });

      return hasAnnotation && field.isStatic;
    });

    fields.addAll(currentFields);

    // Get fields from the parent class
    final parent = element.supertype?.element;
    if (parent is ClassElement) {
      fields.addAll(_getAnnotatedFields(parent));
    }

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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
