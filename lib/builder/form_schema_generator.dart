import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
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
        'FormSchema annotation can only be applied to classes.',
      );
    }

    final className = element.name;
    final fields = element.fields.where((field) {
      return field.metadata.any((meta) => meta.element?.name == 'FormField');
    });

    final buffer = StringBuffer();
    buffer.writeln('class ${className}Schema extends HookFormSchema {');
    buffer.writeln('  ${className}Schema() : super(');
    buffer.writeln('    fields: {');

    for (final field in fields) {
      final fieldName = field.name;
      final fieldType = field.type.getDisplayString();
      final fieldAnnotation = field.metadata
          .firstWhere((meta) => meta.element?.name == 'FormField')
          .computeConstantValue();
      final validators =
          fieldAnnotation?.getField('validators')?.toListValue() ?? [];

      buffer.writeln('      FormFieldScheme<$fieldType>(');
      buffer.writeln('        $fieldName,');
      buffer.writeln('        validators: (value, context) {');

      // Add validators
      for (final validator in validators) {
        final validatorType = validator.type.toString();
        if (validatorType.contains('RequiredValidator')) {
          buffer.writeln(
              '          final result = (value, context) {}.required()(value, context);');
          buffer.writeln('          if (result != null) return result;');
        } else if (validatorType.contains('EmailValidator')) {
          buffer.writeln(
              '          final result = (value, context) {}.email()(value, context);');
          buffer.writeln('          if (result != null) return result;');
        } else if (validatorType.contains('MinLengthValidator')) {
          final length = validator.getField('length')?.toIntValue() ?? 0;
          buffer.writeln(
              '          final result = (value, context) {}.min($length)(value, context);');
          buffer.writeln('          if (result != null) return result;');
        } else if (validatorType.contains('MaxLengthValidator')) {
          final length = validator.getField('length')?.toIntValue() ?? 0;
          buffer.writeln(
              '          final result = (value, context) {}.max($length)(value, context);');
          buffer.writeln('          if (result != null) return result;');
        } else if (validatorType.contains('CustomValidator')) {
          final validatorFn =
              validator.getField('validator')?.toStringValue() ?? '';
          buffer.writeln('          if (value != null) {');
          buffer.writeln('            final result = $validatorFn(value);');
          buffer.writeln('            if (result != null) return result;');
          buffer.writeln('          }');
        }
      }

      buffer.writeln('          return null;');
      buffer.writeln('        },');
      buffer.writeln('      ),');
    }

    buffer.writeln('    },');
    buffer.writeln('  );');
    buffer.writeln('}');

    return buffer.toString();
  }
}
