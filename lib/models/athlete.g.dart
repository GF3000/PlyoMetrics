// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athlete.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAthleteCollection on Isar {
  IsarCollection<Athlete> get athletes => this.collection();
}

const AthleteSchema = CollectionSchema(
  name: r'Athlete',
  id: 6386904496293942511,
  properties: {
    r'asymmetryDate': PropertySchema(
      id: 0,
      name: r'asymmetryDate',
      type: IsarType.dateTime,
    ),
    r'asymmetryStrongerLeg': PropertySchema(
      id: 1,
      name: r'asymmetryStrongerLeg',
      type: IsarType.string,
    ),
    r'avatarUrl': PropertySchema(
      id: 2,
      name: r'avatarUrl',
      type: IsarType.string,
    ),
    r'baselineCmjHeight': PropertySchema(
      id: 3,
      name: r'baselineCmjHeight',
      type: IsarType.double,
    ),
    r'baselineDate': PropertySchema(
      id: 4,
      name: r'baselineDate',
      type: IsarType.dateTime,
    ),
    r'baselineRsi': PropertySchema(
      id: 5,
      name: r'baselineRsi',
      type: IsarType.double,
    ),
    r'heightCm': PropertySchema(
      id: 6,
      name: r'heightCm',
      type: IsarType.double,
    ),
    r'latestAsymmetryPct': PropertySchema(
      id: 7,
      name: r'latestAsymmetryPct',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 8,
      name: r'name',
      type: IsarType.string,
    ),
    r'sortOrder': PropertySchema(
      id: 9,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'weightKg': PropertySchema(
      id: 10,
      name: r'weightKg',
      type: IsarType.double,
    )
  },
  estimateSize: _athleteEstimateSize,
  serialize: _athleteSerialize,
  deserialize: _athleteDeserialize,
  deserializeProp: _athleteDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _athleteGetId,
  getLinks: _athleteGetLinks,
  attach: _athleteAttach,
  version: '3.1.0+1',
);

int _athleteEstimateSize(
  Athlete object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.asymmetryStrongerLeg;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.avatarUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _athleteSerialize(
  Athlete object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.asymmetryDate);
  writer.writeString(offsets[1], object.asymmetryStrongerLeg);
  writer.writeString(offsets[2], object.avatarUrl);
  writer.writeDouble(offsets[3], object.baselineCmjHeight);
  writer.writeDateTime(offsets[4], object.baselineDate);
  writer.writeDouble(offsets[5], object.baselineRsi);
  writer.writeDouble(offsets[6], object.heightCm);
  writer.writeDouble(offsets[7], object.latestAsymmetryPct);
  writer.writeString(offsets[8], object.name);
  writer.writeLong(offsets[9], object.sortOrder);
  writer.writeDouble(offsets[10], object.weightKg);
}

Athlete _athleteDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Athlete();
  object.asymmetryDate = reader.readDateTimeOrNull(offsets[0]);
  object.asymmetryStrongerLeg = reader.readStringOrNull(offsets[1]);
  object.avatarUrl = reader.readStringOrNull(offsets[2]);
  object.baselineCmjHeight = reader.readDoubleOrNull(offsets[3]);
  object.baselineDate = reader.readDateTimeOrNull(offsets[4]);
  object.baselineRsi = reader.readDoubleOrNull(offsets[5]);
  object.heightCm = reader.readDoubleOrNull(offsets[6]);
  object.id = id;
  object.latestAsymmetryPct = reader.readDoubleOrNull(offsets[7]);
  object.name = reader.readString(offsets[8]);
  object.sortOrder = reader.readLong(offsets[9]);
  object.weightKg = reader.readDoubleOrNull(offsets[10]);
  return object;
}

P _athleteDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _athleteGetId(Athlete object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _athleteGetLinks(Athlete object) {
  return [];
}

void _athleteAttach(IsarCollection<dynamic> col, Id id, Athlete object) {
  object.id = id;
}

extension AthleteQueryWhereSort on QueryBuilder<Athlete, Athlete, QWhere> {
  QueryBuilder<Athlete, Athlete, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AthleteQueryWhere on QueryBuilder<Athlete, Athlete, QWhereClause> {
  QueryBuilder<Athlete, Athlete, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AthleteQueryFilter
    on QueryBuilder<Athlete, Athlete, QFilterCondition> {
  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> asymmetryDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'asymmetryDate',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      asymmetryDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'asymmetryDate',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> asymmetryDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'asymmetryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      asymmetryDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'asymmetryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> asymmetryDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'asymmetryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> asymmetryDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'asymmetryDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      asymmetryStrongerLegIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'asymmetryStrongerLeg',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      asymmetryStrongerLegIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'asymmetryStrongerLeg',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      asymmetryStrongerLegEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'asymmetryStrongerLeg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      asymmetryStrongerLegGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'asymmetryStrongerLeg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      asymmetryStrongerLegLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'asymmetryStrongerLeg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      asymmetryStrongerLegBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'asymmetryStrongerLeg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      asymmetryStrongerLegStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'asymmetryStrongerLeg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      asymmetryStrongerLegEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'asymmetryStrongerLeg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      asymmetryStrongerLegContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'asymmetryStrongerLeg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      asymmetryStrongerLegMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'asymmetryStrongerLeg',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      asymmetryStrongerLegIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'asymmetryStrongerLeg',
        value: '',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      asymmetryStrongerLegIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'asymmetryStrongerLeg',
        value: '',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> avatarUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'avatarUrl',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> avatarUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'avatarUrl',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> avatarUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> avatarUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> avatarUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> avatarUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avatarUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> avatarUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'avatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> avatarUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'avatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> avatarUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'avatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> avatarUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'avatarUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> avatarUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatarUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> avatarUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'avatarUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      baselineCmjHeightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'baselineCmjHeight',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      baselineCmjHeightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'baselineCmjHeight',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      baselineCmjHeightEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baselineCmjHeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      baselineCmjHeightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baselineCmjHeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      baselineCmjHeightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baselineCmjHeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      baselineCmjHeightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baselineCmjHeight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> baselineDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'baselineDate',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      baselineDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'baselineDate',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> baselineDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baselineDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> baselineDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baselineDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> baselineDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baselineDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> baselineDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baselineDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> baselineRsiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'baselineRsi',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> baselineRsiIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'baselineRsi',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> baselineRsiEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baselineRsi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> baselineRsiGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baselineRsi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> baselineRsiLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baselineRsi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> baselineRsiBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baselineRsi',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> heightCmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'heightCm',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> heightCmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'heightCm',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> heightCmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heightCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> heightCmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'heightCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> heightCmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'heightCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> heightCmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'heightCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      latestAsymmetryPctIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'latestAsymmetryPct',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      latestAsymmetryPctIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'latestAsymmetryPct',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      latestAsymmetryPctEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latestAsymmetryPct',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      latestAsymmetryPctGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latestAsymmetryPct',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      latestAsymmetryPctLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latestAsymmetryPct',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition>
      latestAsymmetryPctBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latestAsymmetryPct',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> sortOrderEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> weightKgIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weightKg',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> weightKgIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weightKg',
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> weightKgEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> weightKgGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> weightKgLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterFilterCondition> weightKgBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weightKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension AthleteQueryObject
    on QueryBuilder<Athlete, Athlete, QFilterCondition> {}

extension AthleteQueryLinks
    on QueryBuilder<Athlete, Athlete, QFilterCondition> {}

extension AthleteQuerySortBy on QueryBuilder<Athlete, Athlete, QSortBy> {
  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByAsymmetryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asymmetryDate', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByAsymmetryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asymmetryDate', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByAsymmetryStrongerLeg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asymmetryStrongerLeg', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy>
      sortByAsymmetryStrongerLegDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asymmetryStrongerLeg', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByAvatarUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarUrl', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByAvatarUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarUrl', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByBaselineCmjHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineCmjHeight', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByBaselineCmjHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineCmjHeight', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByBaselineDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineDate', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByBaselineDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineDate', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByBaselineRsi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineRsi', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByBaselineRsiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineRsi', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByHeightCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByHeightCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByLatestAsymmetryPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestAsymmetryPct', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByLatestAsymmetryPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestAsymmetryPct', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> sortByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension AthleteQuerySortThenBy
    on QueryBuilder<Athlete, Athlete, QSortThenBy> {
  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByAsymmetryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asymmetryDate', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByAsymmetryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asymmetryDate', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByAsymmetryStrongerLeg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asymmetryStrongerLeg', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy>
      thenByAsymmetryStrongerLegDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asymmetryStrongerLeg', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByAvatarUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarUrl', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByAvatarUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarUrl', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByBaselineCmjHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineCmjHeight', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByBaselineCmjHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineCmjHeight', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByBaselineDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineDate', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByBaselineDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineDate', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByBaselineRsi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineRsi', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByBaselineRsiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineRsi', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByHeightCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByHeightCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByLatestAsymmetryPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestAsymmetryPct', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByLatestAsymmetryPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestAsymmetryPct', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<Athlete, Athlete, QAfterSortBy> thenByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension AthleteQueryWhereDistinct
    on QueryBuilder<Athlete, Athlete, QDistinct> {
  QueryBuilder<Athlete, Athlete, QDistinct> distinctByAsymmetryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'asymmetryDate');
    });
  }

  QueryBuilder<Athlete, Athlete, QDistinct> distinctByAsymmetryStrongerLeg(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'asymmetryStrongerLeg',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Athlete, Athlete, QDistinct> distinctByAvatarUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avatarUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Athlete, Athlete, QDistinct> distinctByBaselineCmjHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baselineCmjHeight');
    });
  }

  QueryBuilder<Athlete, Athlete, QDistinct> distinctByBaselineDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baselineDate');
    });
  }

  QueryBuilder<Athlete, Athlete, QDistinct> distinctByBaselineRsi() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baselineRsi');
    });
  }

  QueryBuilder<Athlete, Athlete, QDistinct> distinctByHeightCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heightCm');
    });
  }

  QueryBuilder<Athlete, Athlete, QDistinct> distinctByLatestAsymmetryPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latestAsymmetryPct');
    });
  }

  QueryBuilder<Athlete, Athlete, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Athlete, Athlete, QDistinct> distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<Athlete, Athlete, QDistinct> distinctByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightKg');
    });
  }
}

extension AthleteQueryProperty
    on QueryBuilder<Athlete, Athlete, QQueryProperty> {
  QueryBuilder<Athlete, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Athlete, DateTime?, QQueryOperations> asymmetryDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'asymmetryDate');
    });
  }

  QueryBuilder<Athlete, String?, QQueryOperations>
      asymmetryStrongerLegProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'asymmetryStrongerLeg');
    });
  }

  QueryBuilder<Athlete, String?, QQueryOperations> avatarUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avatarUrl');
    });
  }

  QueryBuilder<Athlete, double?, QQueryOperations> baselineCmjHeightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baselineCmjHeight');
    });
  }

  QueryBuilder<Athlete, DateTime?, QQueryOperations> baselineDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baselineDate');
    });
  }

  QueryBuilder<Athlete, double?, QQueryOperations> baselineRsiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baselineRsi');
    });
  }

  QueryBuilder<Athlete, double?, QQueryOperations> heightCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heightCm');
    });
  }

  QueryBuilder<Athlete, double?, QQueryOperations>
      latestAsymmetryPctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latestAsymmetryPct');
    });
  }

  QueryBuilder<Athlete, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Athlete, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<Athlete, double?, QQueryOperations> weightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightKg');
    });
  }
}
