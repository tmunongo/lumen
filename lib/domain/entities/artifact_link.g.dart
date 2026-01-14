// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artifact_link.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetArtifactLinkCollection on Isar {
  IsarCollection<ArtifactLink> get artifactLinks => this.collection();
}

const ArtifactLinkSchema = CollectionSchema(
  name: r'ArtifactLink',
  id: -3304332148234627069,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'hashCode': PropertySchema(
      id: 1,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'note': PropertySchema(
      id: 2,
      name: r'note',
      type: IsarType.string,
    ),
    r'projectId': PropertySchema(
      id: 3,
      name: r'projectId',
      type: IsarType.long,
    ),
    r'sourceArtifactId': PropertySchema(
      id: 4,
      name: r'sourceArtifactId',
      type: IsarType.long,
    ),
    r'targetArtifactId': PropertySchema(
      id: 5,
      name: r'targetArtifactId',
      type: IsarType.long,
    )
  },
  estimateSize: _artifactLinkEstimateSize,
  serialize: _artifactLinkSerialize,
  deserialize: _artifactLinkDeserialize,
  deserializeProp: _artifactLinkDeserializeProp,
  idName: r'id',
  indexes: {
    r'sourceArtifactId': IndexSchema(
      id: 2450405623763968556,
      name: r'sourceArtifactId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sourceArtifactId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'targetArtifactId': IndexSchema(
      id: -8311347470493514945,
      name: r'targetArtifactId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'targetArtifactId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'projectId': IndexSchema(
      id: 3305656282123791113,
      name: r'projectId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'projectId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _artifactLinkGetId,
  getLinks: _artifactLinkGetLinks,
  attach: _artifactLinkAttach,
  version: '3.1.0+1',
);

int _artifactLinkEstimateSize(
  ArtifactLink object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _artifactLinkSerialize(
  ArtifactLink object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.hashCode);
  writer.writeString(offsets[2], object.note);
  writer.writeLong(offsets[3], object.projectId);
  writer.writeLong(offsets[4], object.sourceArtifactId);
  writer.writeLong(offsets[5], object.targetArtifactId);
}

ArtifactLink _artifactLinkDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ArtifactLink(
    createdAt: reader.readDateTimeOrNull(offsets[0]),
    note: reader.readStringOrNull(offsets[2]),
    projectId: reader.readLong(offsets[3]),
    sourceArtifactId: reader.readLong(offsets[4]),
    targetArtifactId: reader.readLong(offsets[5]),
  );
  object.id = id;
  return object;
}

P _artifactLinkDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _artifactLinkGetId(ArtifactLink object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _artifactLinkGetLinks(ArtifactLink object) {
  return [];
}

void _artifactLinkAttach(
    IsarCollection<dynamic> col, Id id, ArtifactLink object) {
  object.id = id;
}

extension ArtifactLinkQueryWhereSort
    on QueryBuilder<ArtifactLink, ArtifactLink, QWhere> {
  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhere> anySourceArtifactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sourceArtifactId'),
      );
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhere> anyTargetArtifactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'targetArtifactId'),
      );
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhere> anyProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'projectId'),
      );
    });
  }
}

extension ArtifactLinkQueryWhere
    on QueryBuilder<ArtifactLink, ArtifactLink, QWhereClause> {
  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause> idBetween(
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

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause>
      sourceArtifactIdEqualTo(int sourceArtifactId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sourceArtifactId',
        value: [sourceArtifactId],
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause>
      sourceArtifactIdNotEqualTo(int sourceArtifactId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceArtifactId',
              lower: [],
              upper: [sourceArtifactId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceArtifactId',
              lower: [sourceArtifactId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceArtifactId',
              lower: [sourceArtifactId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceArtifactId',
              lower: [],
              upper: [sourceArtifactId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause>
      sourceArtifactIdGreaterThan(
    int sourceArtifactId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sourceArtifactId',
        lower: [sourceArtifactId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause>
      sourceArtifactIdLessThan(
    int sourceArtifactId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sourceArtifactId',
        lower: [],
        upper: [sourceArtifactId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause>
      sourceArtifactIdBetween(
    int lowerSourceArtifactId,
    int upperSourceArtifactId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sourceArtifactId',
        lower: [lowerSourceArtifactId],
        includeLower: includeLower,
        upper: [upperSourceArtifactId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause>
      targetArtifactIdEqualTo(int targetArtifactId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'targetArtifactId',
        value: [targetArtifactId],
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause>
      targetArtifactIdNotEqualTo(int targetArtifactId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetArtifactId',
              lower: [],
              upper: [targetArtifactId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetArtifactId',
              lower: [targetArtifactId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetArtifactId',
              lower: [targetArtifactId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetArtifactId',
              lower: [],
              upper: [targetArtifactId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause>
      targetArtifactIdGreaterThan(
    int targetArtifactId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'targetArtifactId',
        lower: [targetArtifactId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause>
      targetArtifactIdLessThan(
    int targetArtifactId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'targetArtifactId',
        lower: [],
        upper: [targetArtifactId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause>
      targetArtifactIdBetween(
    int lowerTargetArtifactId,
    int upperTargetArtifactId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'targetArtifactId',
        lower: [lowerTargetArtifactId],
        includeLower: includeLower,
        upper: [upperTargetArtifactId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause> projectIdEqualTo(
      int projectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'projectId',
        value: [projectId],
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause>
      projectIdNotEqualTo(int projectId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'projectId',
              lower: [],
              upper: [projectId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'projectId',
              lower: [projectId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'projectId',
              lower: [projectId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'projectId',
              lower: [],
              upper: [projectId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause>
      projectIdGreaterThan(
    int projectId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'projectId',
        lower: [projectId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause> projectIdLessThan(
    int projectId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'projectId',
        lower: [],
        upper: [projectId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterWhereClause> projectIdBetween(
    int lowerProjectId,
    int upperProjectId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'projectId',
        lower: [lowerProjectId],
        includeLower: includeLower,
        upper: [upperProjectId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ArtifactLinkQueryFilter
    on QueryBuilder<ArtifactLink, ArtifactLink, QFilterCondition> {
  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition> noteContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition> noteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      projectIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectId',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      projectIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'projectId',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      projectIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'projectId',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      projectIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'projectId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      sourceArtifactIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceArtifactId',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      sourceArtifactIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceArtifactId',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      sourceArtifactIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceArtifactId',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      sourceArtifactIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceArtifactId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      targetArtifactIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetArtifactId',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      targetArtifactIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetArtifactId',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      targetArtifactIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetArtifactId',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterFilterCondition>
      targetArtifactIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetArtifactId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ArtifactLinkQueryObject
    on QueryBuilder<ArtifactLink, ArtifactLink, QFilterCondition> {}

extension ArtifactLinkQueryLinks
    on QueryBuilder<ArtifactLink, ArtifactLink, QFilterCondition> {}

extension ArtifactLinkQuerySortBy
    on QueryBuilder<ArtifactLink, ArtifactLink, QSortBy> {
  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> sortByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.asc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> sortByProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.desc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy>
      sortBySourceArtifactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceArtifactId', Sort.asc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy>
      sortBySourceArtifactIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceArtifactId', Sort.desc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy>
      sortByTargetArtifactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetArtifactId', Sort.asc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy>
      sortByTargetArtifactIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetArtifactId', Sort.desc);
    });
  }
}

extension ArtifactLinkQuerySortThenBy
    on QueryBuilder<ArtifactLink, ArtifactLink, QSortThenBy> {
  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> thenByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.asc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy> thenByProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.desc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy>
      thenBySourceArtifactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceArtifactId', Sort.asc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy>
      thenBySourceArtifactIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceArtifactId', Sort.desc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy>
      thenByTargetArtifactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetArtifactId', Sort.asc);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QAfterSortBy>
      thenByTargetArtifactIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetArtifactId', Sort.desc);
    });
  }
}

extension ArtifactLinkQueryWhereDistinct
    on QueryBuilder<ArtifactLink, ArtifactLink, QDistinct> {
  QueryBuilder<ArtifactLink, ArtifactLink, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QDistinct> distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QDistinct> distinctByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectId');
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QDistinct>
      distinctBySourceArtifactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceArtifactId');
    });
  }

  QueryBuilder<ArtifactLink, ArtifactLink, QDistinct>
      distinctByTargetArtifactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetArtifactId');
    });
  }
}

extension ArtifactLinkQueryProperty
    on QueryBuilder<ArtifactLink, ArtifactLink, QQueryProperty> {
  QueryBuilder<ArtifactLink, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ArtifactLink, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ArtifactLink, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<ArtifactLink, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<ArtifactLink, int, QQueryOperations> projectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectId');
    });
  }

  QueryBuilder<ArtifactLink, int, QQueryOperations> sourceArtifactIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceArtifactId');
    });
  }

  QueryBuilder<ArtifactLink, int, QQueryOperations> targetArtifactIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetArtifactId');
    });
  }
}
