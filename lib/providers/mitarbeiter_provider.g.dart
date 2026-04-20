// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mitarbeiter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mitarbeiterNotifierHash() =>
    r'ddaa28468867f942f2f8500440bf84628289656d';

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

abstract class _$MitarbeiterNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Mitarbeiter>> {
  late final String betriebId;

  FutureOr<List<Mitarbeiter>> build(
    String betriebId,
  );
}

/// See also [MitarbeiterNotifier].
@ProviderFor(MitarbeiterNotifier)
const mitarbeiterNotifierProvider = MitarbeiterNotifierFamily();

/// See also [MitarbeiterNotifier].
class MitarbeiterNotifierFamily extends Family<AsyncValue<List<Mitarbeiter>>> {
  /// See also [MitarbeiterNotifier].
  const MitarbeiterNotifierFamily();

  /// See also [MitarbeiterNotifier].
  MitarbeiterNotifierProvider call(
    String betriebId,
  ) {
    return MitarbeiterNotifierProvider(
      betriebId,
    );
  }

  @override
  MitarbeiterNotifierProvider getProviderOverride(
    covariant MitarbeiterNotifierProvider provider,
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
  String? get name => r'mitarbeiterNotifierProvider';
}

/// See also [MitarbeiterNotifier].
class MitarbeiterNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    MitarbeiterNotifier, List<Mitarbeiter>> {
  /// See also [MitarbeiterNotifier].
  MitarbeiterNotifierProvider(
    String betriebId,
  ) : this._internal(
          () => MitarbeiterNotifier()..betriebId = betriebId,
          from: mitarbeiterNotifierProvider,
          name: r'mitarbeiterNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mitarbeiterNotifierHash,
          dependencies: MitarbeiterNotifierFamily._dependencies,
          allTransitiveDependencies:
              MitarbeiterNotifierFamily._allTransitiveDependencies,
          betriebId: betriebId,
        );

  MitarbeiterNotifierProvider._internal(
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
  FutureOr<List<Mitarbeiter>> runNotifierBuild(
    covariant MitarbeiterNotifier notifier,
  ) {
    return notifier.build(
      betriebId,
    );
  }

  @override
  Override overrideWith(MitarbeiterNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MitarbeiterNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<MitarbeiterNotifier,
      List<Mitarbeiter>> createElement() {
    return _MitarbeiterNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MitarbeiterNotifierProvider && other.betriebId == betriebId;
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
mixin MitarbeiterNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<Mitarbeiter>> {
  /// The parameter `betriebId` of this provider.
  String get betriebId;
}

class _MitarbeiterNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MitarbeiterNotifier,
        List<Mitarbeiter>> with MitarbeiterNotifierRef {
  _MitarbeiterNotifierProviderElement(super.provider);

  @override
  String get betriebId => (origin as MitarbeiterNotifierProvider).betriebId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
