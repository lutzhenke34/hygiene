// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mitarbeiterHash() => r'a09c44c825c69f0a6c97f485a57ac3179f9ffda0';

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

/// See also [mitarbeiter].
@ProviderFor(mitarbeiter)
const mitarbeiterProvider = MitarbeiterFamily();

/// See also [mitarbeiter].
class MitarbeiterFamily extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [mitarbeiter].
  const MitarbeiterFamily();

  /// See also [mitarbeiter].
  MitarbeiterProvider call(
    String betriebId,
  ) {
    return MitarbeiterProvider(
      betriebId,
    );
  }

  @override
  MitarbeiterProvider getProviderOverride(
    covariant MitarbeiterProvider provider,
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
  String? get name => r'mitarbeiterProvider';
}

/// See also [mitarbeiter].
class MitarbeiterProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [mitarbeiter].
  MitarbeiterProvider(
    String betriebId,
  ) : this._internal(
          (ref) => mitarbeiter(
            ref as MitarbeiterRef,
            betriebId,
          ),
          from: mitarbeiterProvider,
          name: r'mitarbeiterProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mitarbeiterHash,
          dependencies: MitarbeiterFamily._dependencies,
          allTransitiveDependencies:
              MitarbeiterFamily._allTransitiveDependencies,
          betriebId: betriebId,
        );

  MitarbeiterProvider._internal(
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
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(MitarbeiterRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MitarbeiterProvider._internal(
        (ref) => create(ref as MitarbeiterRef),
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
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _MitarbeiterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MitarbeiterProvider && other.betriebId == betriebId;
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
mixin MitarbeiterRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `betriebId` of this provider.
  String get betriebId;
}

class _MitarbeiterProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with MitarbeiterRef {
  _MitarbeiterProviderElement(super.provider);

  @override
  String get betriebId => (origin as MitarbeiterProvider).betriebId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
