// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kuehlgeraet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$kuehlgeraetNotifierHash() =>
    r'83e136af9ab8ee5e25b311d773b710a175c0573a';

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

abstract class _$KuehlgeraetNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Kuehlgeraet>> {
  late final String betriebId;

  FutureOr<List<Kuehlgeraet>> build(
    String betriebId,
  );
}

/// See also [KuehlgeraetNotifier].
@ProviderFor(KuehlgeraetNotifier)
const kuehlgeraetNotifierProvider = KuehlgeraetNotifierFamily();

/// See also [KuehlgeraetNotifier].
class KuehlgeraetNotifierFamily extends Family<AsyncValue<List<Kuehlgeraet>>> {
  /// See also [KuehlgeraetNotifier].
  const KuehlgeraetNotifierFamily();

  /// See also [KuehlgeraetNotifier].
  KuehlgeraetNotifierProvider call(
    String betriebId,
  ) {
    return KuehlgeraetNotifierProvider(
      betriebId,
    );
  }

  @override
  KuehlgeraetNotifierProvider getProviderOverride(
    covariant KuehlgeraetNotifierProvider provider,
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
  String? get name => r'kuehlgeraetNotifierProvider';
}

/// See also [KuehlgeraetNotifier].
class KuehlgeraetNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    KuehlgeraetNotifier, List<Kuehlgeraet>> {
  /// See also [KuehlgeraetNotifier].
  KuehlgeraetNotifierProvider(
    String betriebId,
  ) : this._internal(
          () => KuehlgeraetNotifier()..betriebId = betriebId,
          from: kuehlgeraetNotifierProvider,
          name: r'kuehlgeraetNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$kuehlgeraetNotifierHash,
          dependencies: KuehlgeraetNotifierFamily._dependencies,
          allTransitiveDependencies:
              KuehlgeraetNotifierFamily._allTransitiveDependencies,
          betriebId: betriebId,
        );

  KuehlgeraetNotifierProvider._internal(
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
  FutureOr<List<Kuehlgeraet>> runNotifierBuild(
    covariant KuehlgeraetNotifier notifier,
  ) {
    return notifier.build(
      betriebId,
    );
  }

  @override
  Override overrideWith(KuehlgeraetNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: KuehlgeraetNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<KuehlgeraetNotifier,
      List<Kuehlgeraet>> createElement() {
    return _KuehlgeraetNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is KuehlgeraetNotifierProvider && other.betriebId == betriebId;
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
mixin KuehlgeraetNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<Kuehlgeraet>> {
  /// The parameter `betriebId` of this provider.
  String get betriebId;
}

class _KuehlgeraetNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<KuehlgeraetNotifier,
        List<Kuehlgeraet>> with KuehlgeraetNotifierRef {
  _KuehlgeraetNotifierProviderElement(super.provider);

  @override
  String get betriebId => (origin as KuehlgeraetNotifierProvider).betriebId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
