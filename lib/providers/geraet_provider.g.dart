// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geraet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$geraetNotifierHash() => r'4c1c795da48066364ac92f6772b1cbd15d3cd779';

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

abstract class _$GeraetNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Geraet>> {
  late final String betriebId;

  FutureOr<List<Geraet>> build(
    String betriebId,
  );
}

/// See also [GeraetNotifier].
@ProviderFor(GeraetNotifier)
const geraetNotifierProvider = GeraetNotifierFamily();

/// See also [GeraetNotifier].
class GeraetNotifierFamily extends Family<AsyncValue<List<Geraet>>> {
  /// See also [GeraetNotifier].
  const GeraetNotifierFamily();

  /// See also [GeraetNotifier].
  GeraetNotifierProvider call(
    String betriebId,
  ) {
    return GeraetNotifierProvider(
      betriebId,
    );
  }

  @override
  GeraetNotifierProvider getProviderOverride(
    covariant GeraetNotifierProvider provider,
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
  String? get name => r'geraetNotifierProvider';
}

/// See also [GeraetNotifier].
class GeraetNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<GeraetNotifier, List<Geraet>> {
  /// See also [GeraetNotifier].
  GeraetNotifierProvider(
    String betriebId,
  ) : this._internal(
          () => GeraetNotifier()..betriebId = betriebId,
          from: geraetNotifierProvider,
          name: r'geraetNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$geraetNotifierHash,
          dependencies: GeraetNotifierFamily._dependencies,
          allTransitiveDependencies:
              GeraetNotifierFamily._allTransitiveDependencies,
          betriebId: betriebId,
        );

  GeraetNotifierProvider._internal(
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
  FutureOr<List<Geraet>> runNotifierBuild(
    covariant GeraetNotifier notifier,
  ) {
    return notifier.build(
      betriebId,
    );
  }

  @override
  Override overrideWith(GeraetNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: GeraetNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<GeraetNotifier, List<Geraet>>
      createElement() {
    return _GeraetNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GeraetNotifierProvider && other.betriebId == betriebId;
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
mixin GeraetNotifierRef on AutoDisposeAsyncNotifierProviderRef<List<Geraet>> {
  /// The parameter `betriebId` of this provider.
  String get betriebId;
}

class _GeraetNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<GeraetNotifier,
        List<Geraet>> with GeraetNotifierRef {
  _GeraetNotifierProviderElement(super.provider);

  @override
  String get betriebId => (origin as GeraetNotifierProvider).betriebId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
