// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jump_test.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetJumpTestCollection on Isar {
  IsarCollection<JumpTest> get jumpTests => this.collection();
}

const JumpTestSchema = CollectionSchema(
  name: r'JumpTest',
  id: -6600465219072699580,
  properties: {
    r'athleteId': PropertySchema(
      id: 0,
      name: r'athleteId',
      type: IsarType.long,
    ),
    r'baselineAtTest': PropertySchema(
      id: 1,
      name: r'baselineAtTest',
      type: IsarType.double,
    ),
    r'baselineSessionId': PropertySchema(
      id: 2,
      name: r'baselineSessionId',
      type: IsarType.long,
    ),
    r'contactTimeMs': PropertySchema(
      id: 3,
      name: r'contactTimeMs',
      type: IsarType.double,
    ),
    r'deltaHCm': PropertySchema(
      id: 4,
      name: r'deltaHCm',
      type: IsarType.double,
    ),
    r'flightTimeMs': PropertySchema(
      id: 5,
      name: r'flightTimeMs',
      type: IsarType.double,
    ),
    r'fps': PropertySchema(
      id: 6,
      name: r'fps',
      type: IsarType.double,
    ),
    r'heightCm': PropertySchema(
      id: 7,
      name: r'heightCm',
      type: IsarType.double,
    ),
    r'isOutlier': PropertySchema(
      id: 8,
      name: r'isOutlier',
      type: IsarType.bool,
    ),
    r'landingFrame': PropertySchema(
      id: 9,
      name: r'landingFrame',
      type: IsarType.long,
    ),
    r'rsiScore': PropertySchema(
      id: 10,
      name: r'rsiScore',
      type: IsarType.double,
    ),
    r'takeoffFrame': PropertySchema(
      id: 11,
      name: r'takeoffFrame',
      type: IsarType.long,
    ),
    r'testType': PropertySchema(
      id: 12,
      name: r'testType',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 13,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _jumpTestEstimateSize,
  serialize: _jumpTestSerialize,
  deserialize: _jumpTestDeserialize,
  deserializeProp: _jumpTestDeserializeProp,
  idName: r'id',
  indexes: {
    r'athleteId': IndexSchema(
      id: 5701844619232095782,
      name: r'athleteId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'athleteId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'testType': IndexSchema(
      id: -1676870248283008756,
      name: r'testType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'testType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _jumpTestGetId,
  getLinks: _jumpTestGetLinks,
  attach: _jumpTestAttach,
  version: '3.1.0+1',
);

int _jumpTestEstimateSize(
  JumpTest object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.testType.length * 3;
  return bytesCount;
}

void _jumpTestSerialize(
  JumpTest object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.athleteId);
  writer.writeDouble(offsets[1], object.baselineAtTest);
  writer.writeLong(offsets[2], object.baselineSessionId);
  writer.writeDouble(offsets[3], object.contactTimeMs);
  writer.writeDouble(offsets[4], object.deltaHCm);
  writer.writeDouble(offsets[5], object.flightTimeMs);
  writer.writeDouble(offsets[6], object.fps);
  writer.writeDouble(offsets[7], object.heightCm);
  writer.writeBool(offsets[8], object.isOutlier);
  writer.writeLong(offsets[9], object.landingFrame);
  writer.writeDouble(offsets[10], object.rsiScore);
  writer.writeLong(offsets[11], object.takeoffFrame);
  writer.writeString(offsets[12], object.testType);
  writer.writeDateTime(offsets[13], object.timestamp);
}

JumpTest _jumpTestDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = JumpTest();
  object.athleteId = reader.readLong(offsets[0]);
  object.baselineAtTest = reader.readDoubleOrNull(offsets[1]);
  object.baselineSessionId = reader.readLongOrNull(offsets[2]);
  object.contactTimeMs = reader.readDoubleOrNull(offsets[3]);
  object.deltaHCm = reader.readDouble(offsets[4]);
  object.flightTimeMs = reader.readDouble(offsets[5]);
  object.fps = reader.readDouble(offsets[6]);
  object.heightCm = reader.readDouble(offsets[7]);
  object.id = id;
  object.isOutlier = reader.readBool(offsets[8]);
  object.landingFrame = reader.readLong(offsets[9]);
  object.rsiScore = reader.readDoubleOrNull(offsets[10]);
  object.takeoffFrame = reader.readLong(offsets[11]);
  object.testType = reader.readString(offsets[12]);
  object.timestamp = reader.readDateTime(offsets[13]);
  return object;
}

P _jumpTestDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _jumpTestGetId(JumpTest object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _jumpTestGetLinks(JumpTest object) {
  return [];
}

void _jumpTestAttach(IsarCollection<dynamic> col, Id id, JumpTest object) {
  object.id = id;
}

extension JumpTestQueryWhereSort on QueryBuilder<JumpTest, JumpTest, QWhere> {
  QueryBuilder<JumpTest, JumpTest, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterWhere> anyAthleteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'athleteId'),
      );
    });
  }
}

extension JumpTestQueryWhere on QueryBuilder<JumpTest, JumpTest, QWhereClause> {
  QueryBuilder<JumpTest, JumpTest, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<JumpTest, JumpTest, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterWhereClause> idBetween(
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

  QueryBuilder<JumpTest, JumpTest, QAfterWhereClause> athleteIdEqualTo(
      int athleteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'athleteId',
        value: [athleteId],
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterWhereClause> athleteIdNotEqualTo(
      int athleteId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'athleteId',
              lower: [],
              upper: [athleteId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'athleteId',
              lower: [athleteId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'athleteId',
              lower: [athleteId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'athleteId',
              lower: [],
              upper: [athleteId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterWhereClause> athleteIdGreaterThan(
    int athleteId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'athleteId',
        lower: [athleteId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterWhereClause> athleteIdLessThan(
    int athleteId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'athleteId',
        lower: [],
        upper: [athleteId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterWhereClause> athleteIdBetween(
    int lowerAthleteId,
    int upperAthleteId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'athleteId',
        lower: [lowerAthleteId],
        includeLower: includeLower,
        upper: [upperAthleteId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterWhereClause> testTypeEqualTo(
      String testType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'testType',
        value: [testType],
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterWhereClause> testTypeNotEqualTo(
      String testType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'testType',
              lower: [],
              upper: [testType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'testType',
              lower: [testType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'testType',
              lower: [testType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'testType',
              lower: [],
              upper: [testType],
              includeUpper: false,
            ));
      }
    });
  }
}

extension JumpTestQueryFilter
    on QueryBuilder<JumpTest, JumpTest, QFilterCondition> {
  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> athleteIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'athleteId',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> athleteIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'athleteId',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> athleteIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'athleteId',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> athleteIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'athleteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      baselineAtTestIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'baselineAtTest',
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      baselineAtTestIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'baselineAtTest',
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> baselineAtTestEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baselineAtTest',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      baselineAtTestGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baselineAtTest',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      baselineAtTestLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baselineAtTest',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> baselineAtTestBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baselineAtTest',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      baselineSessionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'baselineSessionId',
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      baselineSessionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'baselineSessionId',
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      baselineSessionIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baselineSessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      baselineSessionIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baselineSessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      baselineSessionIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baselineSessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      baselineSessionIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baselineSessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      contactTimeMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contactTimeMs',
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      contactTimeMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contactTimeMs',
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> contactTimeMsEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactTimeMs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      contactTimeMsGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contactTimeMs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> contactTimeMsLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contactTimeMs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> contactTimeMsBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contactTimeMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> deltaHCmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deltaHCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> deltaHCmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deltaHCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> deltaHCmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deltaHCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> deltaHCmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deltaHCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> flightTimeMsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'flightTimeMs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      flightTimeMsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'flightTimeMs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> flightTimeMsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'flightTimeMs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> flightTimeMsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'flightTimeMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> fpsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fps',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> fpsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fps',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> fpsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fps',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> fpsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> heightCmEqualTo(
    double value, {
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

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> heightCmGreaterThan(
    double value, {
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

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> heightCmLessThan(
    double value, {
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

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> heightCmBetween(
    double lower,
    double upper, {
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

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> idBetween(
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

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> isOutlierEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isOutlier',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> landingFrameEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'landingFrame',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      landingFrameGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'landingFrame',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> landingFrameLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'landingFrame',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> landingFrameBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'landingFrame',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> rsiScoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rsiScore',
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> rsiScoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rsiScore',
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> rsiScoreEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rsiScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> rsiScoreGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rsiScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> rsiScoreLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rsiScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> rsiScoreBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rsiScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> takeoffFrameEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'takeoffFrame',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition>
      takeoffFrameGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'takeoffFrame',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> takeoffFrameLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'takeoffFrame',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> takeoffFrameBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'takeoffFrame',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> testTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'testType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> testTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'testType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> testTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'testType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> testTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'testType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> testTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'testType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> testTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'testType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> testTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'testType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> testTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'testType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> testTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'testType',
        value: '',
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> testTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'testType',
        value: '',
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> timestampEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension JumpTestQueryObject
    on QueryBuilder<JumpTest, JumpTest, QFilterCondition> {}

extension JumpTestQueryLinks
    on QueryBuilder<JumpTest, JumpTest, QFilterCondition> {}

extension JumpTestQuerySortBy on QueryBuilder<JumpTest, JumpTest, QSortBy> {
  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByAthleteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'athleteId', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByAthleteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'athleteId', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByBaselineAtTest() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineAtTest', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByBaselineAtTestDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineAtTest', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByBaselineSessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineSessionId', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByBaselineSessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineSessionId', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByContactTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactTimeMs', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByContactTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactTimeMs', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByDeltaHCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deltaHCm', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByDeltaHCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deltaHCm', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByFlightTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flightTimeMs', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByFlightTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flightTimeMs', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByFps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fps', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByFpsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fps', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByHeightCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByHeightCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByIsOutlier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutlier', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByIsOutlierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutlier', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByLandingFrame() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'landingFrame', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByLandingFrameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'landingFrame', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByRsiScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rsiScore', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByRsiScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rsiScore', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByTakeoffFrame() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'takeoffFrame', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByTakeoffFrameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'takeoffFrame', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByTestType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testType', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByTestTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testType', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension JumpTestQuerySortThenBy
    on QueryBuilder<JumpTest, JumpTest, QSortThenBy> {
  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByAthleteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'athleteId', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByAthleteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'athleteId', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByBaselineAtTest() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineAtTest', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByBaselineAtTestDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineAtTest', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByBaselineSessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineSessionId', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByBaselineSessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baselineSessionId', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByContactTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactTimeMs', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByContactTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactTimeMs', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByDeltaHCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deltaHCm', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByDeltaHCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deltaHCm', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByFlightTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flightTimeMs', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByFlightTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flightTimeMs', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByFps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fps', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByFpsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fps', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByHeightCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByHeightCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByIsOutlier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutlier', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByIsOutlierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOutlier', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByLandingFrame() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'landingFrame', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByLandingFrameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'landingFrame', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByRsiScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rsiScore', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByRsiScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rsiScore', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByTakeoffFrame() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'takeoffFrame', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByTakeoffFrameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'takeoffFrame', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByTestType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testType', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByTestTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testType', Sort.desc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension JumpTestQueryWhereDistinct
    on QueryBuilder<JumpTest, JumpTest, QDistinct> {
  QueryBuilder<JumpTest, JumpTest, QDistinct> distinctByAthleteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'athleteId');
    });
  }

  QueryBuilder<JumpTest, JumpTest, QDistinct> distinctByBaselineAtTest() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baselineAtTest');
    });
  }

  QueryBuilder<JumpTest, JumpTest, QDistinct> distinctByBaselineSessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baselineSessionId');
    });
  }

  QueryBuilder<JumpTest, JumpTest, QDistinct> distinctByContactTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contactTimeMs');
    });
  }

  QueryBuilder<JumpTest, JumpTest, QDistinct> distinctByDeltaHCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deltaHCm');
    });
  }

  QueryBuilder<JumpTest, JumpTest, QDistinct> distinctByFlightTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'flightTimeMs');
    });
  }

  QueryBuilder<JumpTest, JumpTest, QDistinct> distinctByFps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fps');
    });
  }

  QueryBuilder<JumpTest, JumpTest, QDistinct> distinctByHeightCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heightCm');
    });
  }

  QueryBuilder<JumpTest, JumpTest, QDistinct> distinctByIsOutlier() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOutlier');
    });
  }

  QueryBuilder<JumpTest, JumpTest, QDistinct> distinctByLandingFrame() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'landingFrame');
    });
  }

  QueryBuilder<JumpTest, JumpTest, QDistinct> distinctByRsiScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rsiScore');
    });
  }

  QueryBuilder<JumpTest, JumpTest, QDistinct> distinctByTakeoffFrame() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'takeoffFrame');
    });
  }

  QueryBuilder<JumpTest, JumpTest, QDistinct> distinctByTestType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'testType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JumpTest, JumpTest, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension JumpTestQueryProperty
    on QueryBuilder<JumpTest, JumpTest, QQueryProperty> {
  QueryBuilder<JumpTest, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<JumpTest, int, QQueryOperations> athleteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'athleteId');
    });
  }

  QueryBuilder<JumpTest, double?, QQueryOperations> baselineAtTestProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baselineAtTest');
    });
  }

  QueryBuilder<JumpTest, int?, QQueryOperations> baselineSessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baselineSessionId');
    });
  }

  QueryBuilder<JumpTest, double?, QQueryOperations> contactTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contactTimeMs');
    });
  }

  QueryBuilder<JumpTest, double, QQueryOperations> deltaHCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deltaHCm');
    });
  }

  QueryBuilder<JumpTest, double, QQueryOperations> flightTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'flightTimeMs');
    });
  }

  QueryBuilder<JumpTest, double, QQueryOperations> fpsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fps');
    });
  }

  QueryBuilder<JumpTest, double, QQueryOperations> heightCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heightCm');
    });
  }

  QueryBuilder<JumpTest, bool, QQueryOperations> isOutlierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOutlier');
    });
  }

  QueryBuilder<JumpTest, int, QQueryOperations> landingFrameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'landingFrame');
    });
  }

  QueryBuilder<JumpTest, double?, QQueryOperations> rsiScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rsiScore');
    });
  }

  QueryBuilder<JumpTest, int, QQueryOperations> takeoffFrameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'takeoffFrame');
    });
  }

  QueryBuilder<JumpTest, String, QQueryOperations> testTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'testType');
    });
  }

  QueryBuilder<JumpTest, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
