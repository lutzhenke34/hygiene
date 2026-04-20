// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hygiene_aufgabe_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hygieneAufgabeNotifierHash() =>
    r'8e654c7a80291dd0fce0d5e79d66eeb9dd2574fa';

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

abstract class _$HygieneAufgabeNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<HygieneAufgabe>> {
  late final String betriebId;

  FutureOr<List<HygieneAufgabe>> build(
    String betriebId,
  );
}

/// See also [HygieneAufgabeNotifier].
@ProviderFor(HygieneAufgabeNotifier)
const hygieneAufgabeNotifierProvider = HygieneAufgabeNotifierFamily();

/// See also [HygieneAufgabeNotifier].
class HygieneAufgabeNotifierFamily
    extends Family<AsyncValue<List<HygieneAufgabe>>> {
  /// See also [HygieneAufgabeNotifier].
  const HygieneAufgabeNotifierFamily();

  /// See also [HygieneAufgabeNotifier].
  HygieneAufgabeNotifierProvider call(
    String betriebId,
  ) {
    return HygieneAufgabeNotifierProvider(
      betriebId,
    );
  }

  @override
  HygieneAufgabeNotifierProvider getProviderOverride(
    covariant HygieneAufgabeNotifierProvider provider,
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
  String? get name => r'hygieneAufgabeNotifierProvider';
}

/// See also [HygieneAufgabeNotifier].
class HygieneAufgabeNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<HygieneAufgabeNotifier,
        List<HygieneAufgabe>> {
  /// See also [HygieneAufgabeNotifier].
  HygieneAufgabeNotifierProvider(
    String betriebId,
  ) : this._internal(
          () => HygieneAufgabeNotifier()..betriebId = betriebId,
          from: hygieneAufgabeNotifierProvider,
          name: r'hygieneAufgabeNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$hygieneAufgabeNotifierHash,
          dependencies: HygieneAufgabeNotifierFamily._dependencies,
          allTransitiveDependencies:
              HygieneAufgabeNotifierFamily._allTransitiveDependencies,
          betriebId: betriebId,
        );

  HygieneAufgabeNotifierProvider._internal(
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
  FutureOr<List<HygieneAufgabe>> runNotifierBuild(
    covariant HygieneAufgabeNotifier notifier,
  ) {
    return notifier.build(
      betriebId,
    );
  }

  @override
  Override overrideWith(HygieneAufgabeNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: HygieneAufgabeNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<HygieneAufgabeNotifier,
      List<HygieneAufgabe>> createElement() {
    return _HygieneAufgabeNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HygieneAufgabeNotifierProvider &&
        other.betriebId == betriebId;
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
mixin HygieneAufgabeNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<HygieneAufgabe>> {
  /// The parameter `betriebId` of this provider.
  String get betriebId;
}

class _HygieneAufgabeNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<HygieneAufgabeNotifier,
        List<HygieneAufgabe>> with HygieneAufgabeNotifierRef {
  _HygieneAufgabeNotifierProviderElement(super.provider);

  @override
  String get betriebId => (origin as HygieneAufgabeNotifierProvider).betriebId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
