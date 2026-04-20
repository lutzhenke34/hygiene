// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aufgabe_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aufgabeNotifierHash() => r'745b18c7ad67bdefef82d21bf999604bcbcd49a7';

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

abstract class _$AufgabeNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Aufgabe>> {
  late final String betriebId;

  FutureOr<List<Aufgabe>> build(
    String betriebId,
  );
}

/// See also [AufgabeNotifier].
@ProviderFor(AufgabeNotifier)
const aufgabeNotifierProvider = AufgabeNotifierFamily();

/// See also [AufgabeNotifier].
class AufgabeNotifierFamily extends Family<AsyncValue<List<Aufgabe>>> {
  /// See also [AufgabeNotifier].
  const AufgabeNotifierFamily();

  /// See also [AufgabeNotifier].
  AufgabeNotifierProvider call(
    String betriebId,
  ) {
    return AufgabeNotifierProvider(
      betriebId,
    );
  }

  @override
  AufgabeNotifierProvider getProviderOverride(
    covariant AufgabeNotifierProvider provider,
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
  String? get name => r'aufgabeNotifierProvider';
}

/// See also [AufgabeNotifier].
class AufgabeNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    AufgabeNotifier, List<Aufgabe>> {
  /// See also [AufgabeNotifier].
  AufgabeNotifierProvider(
    String betriebId,
  ) : this._internal(
          () => AufgabeNotifier()..betriebId = betriebId,
          from: aufgabeNotifierProvider,
          name: r'aufgabeNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$aufgabeNotifierHash,
          dependencies: AufgabeNotifierFamily._dependencies,
          allTransitiveDependencies:
              AufgabeNotifierFamily._allTransitiveDependencies,
          betriebId: betriebId,
        );

  AufgabeNotifierProvider._internal(
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
  FutureOr<List<Aufgabe>> runNotifierBuild(
    covariant AufgabeNotifier notifier,
  ) {
    return notifier.build(
      betriebId,
    );
  }

  @override
  Override overrideWith(AufgabeNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: AufgabeNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<AufgabeNotifier, List<Aufgabe>>
      createElement() {
    return _AufgabeNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AufgabeNotifierProvider && other.betriebId == betriebId;
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
mixin AufgabeNotifierRef on AutoDisposeAsyncNotifierProviderRef<List<Aufgabe>> {
  /// The parameter `betriebId` of this provider.
  String get betriebId;
}

class _AufgabeNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<AufgabeNotifier,
        List<Aufgabe>> with AufgabeNotifierRef {
  _AufgabeNotifierProviderElement(super.provider);

  @override
  String get betriebId => (origin as AufgabeNotifierProvider).betriebId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
