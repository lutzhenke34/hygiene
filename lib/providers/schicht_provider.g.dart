// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schicht_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$schichtNotifierHash() => r'4492a8f5982cb932066256663c8f38ffd9853345';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$SchichtNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Schicht>> {
  late final String betriebId;

  FutureOr<List<Schicht>> build(
    String betriebId,
  );
}

/// See also [SchichtNotifier].
@ProviderFor(SchichtNotifier)
const schichtNotifierProvider = SchichtNotifierFamily();

/// See also [SchichtNotifier].
class SchichtNotifierFamily extends Family<AsyncValue<List<Schicht>>> {
  /// See also [SchichtNotifier].
  const SchichtNotifierFamily();

  /// See also [SchichtNotifier].
  SchichtNotifierProvider call(
    String betriebId,
  ) {
    return SchichtNotifierProvider(
      betriebId,
    );
  }

  @override
  SchichtNotifierProvider getProviderOverride(
    covariant SchichtNotifierProvider provider,
  ) {
    return call(
      provider.betriebId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'schichtNotifierProvider';
}

/// See also [SchichtNotifier].
class SchichtNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    SchichtNotifier, List<Schicht>> {
  /// See also [SchichtNotifier].
  SchichtNotifierProvider(
    String betriebId,
  ) : this._internal(
          () => SchichtNotifier()..betriebId = betriebId,
          from: schichtNotifierProvider,
          name: r'schichtNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$schichtNotifierHash,
          dependencies: SchichtNotifierFamily._dependencies,
          allTransitiveDependencies:
              SchichtNotifierFamily._allTransitiveDependencies,
          betriebId: betriebId,
        );

  SchichtNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.betriebId,
  }) : super.internal();

  final String betriebId;

  @override
  FutureOr<List<Schicht>> runNotifierBuild(
    covariant SchichtNotifier notifier,
  ) {
    return notifier.build(
      betriebId,
    );
  }

  @override
  Override overrideWith(SchichtNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: SchichtNotifierProvider._internal(
        () => create()..betriebId = betriebId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        betriebId: betriebId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<SchichtNotifier, List<Schicht>>
      createElement() {
    return _SchichtNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SchichtNotifierProvider && other.betriebId == betriebId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, betriebId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SchichtNotifierRef on AutoDisposeAsyncNotifierProviderRef<List<Schicht>> {
  /// The parameter `betriebId` of this provider.
  String get betriebId;
}

class _SchichtNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<SchichtNotifier,
        List<Schicht>> with SchichtNotifierRef {
  _SchichtNotifierProviderElement(super.provider);

  @override
  String get betriebId => (origin as SchichtNotifierProvider).betriebId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
