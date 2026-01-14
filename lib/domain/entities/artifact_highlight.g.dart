// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artifact_highlight.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetArtifactHighlightCollection on Isar {
  IsarCollection<ArtifactHighlight> get artifactHighlights => this.collection();
}

const ArtifactHighlightSchema = CollectionSchema(
  name: r'ArtifactHighlight',
  id: 7794138565434428067,
  properties: {
    r'artifactId': PropertySchema(
      id: 0,
      name: r'artifactId',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'note': PropertySchema(
      id: 2,
      name: r'note',
      type: IsarType.string,
    ),
    r'selectedText': PropertySchema(
      id: 3,
      name: r'selectedText',
      type: IsarType.string,
    ),
    r'style': PropertySchema(
      id: 4,
      name: r'style',
      type: IsarType.string,
    )
  },
  estimateSize: _artifactHighlightEstimateSize,
  serialize: _artifactHighlightSerialize,
  deserialize: _artifactHighlightDeserialize,
  deserializeProp: _artifactHighlightDeserializeProp,
  idName: r'id',
  indexes: {
    r'artifactId': IndexSchema(
      id: 5090864862615015280,
      name: r'artifactId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'artifactId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _artifactHighlightGetId,
  getLinks: _artifactHighlightGetLinks,
  attach: _artifactHighlightAttach,
  version: '3.1.0+1',
);

int _artifactHighlightEstimateSize(
  ArtifactHighlight object,
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
  bytesCount += 3 + object.selectedText.length * 3;
  bytesCount += 3 + object.style.length * 3;
  return bytesCount;
}

void _artifactHighlightSerialize(
  ArtifactHighlight object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.artifactId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.note);
  writer.writeString(offsets[3], object.selectedText);
  writer.writeString(offsets[4], object.style);
}

ArtifactHighlight _artifactHighlightDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ArtifactHighlight(
    artifactId: reader.readLong(offsets[0]),
    createdAt: reader.readDateTimeOrNull(offsets[1]),
    note: reader.readStringOrNull(offsets[2]),
    selectedText: reader.readString(offsets[3]),
    style: reader.readStringOrNull(offsets[4]) ?? 'yellow',
  );
  object.id = id;
  return object;
}

P _artifactHighlightDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset) ?? 'yellow') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _artifactHighlightGetId(ArtifactHighlight object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _artifactHighlightGetLinks(
    ArtifactHighlight object) {
  return [];
}

void _artifactHighlightAttach(
    IsarCollection<dynamic> col, Id id, ArtifactHighlight object) {
  object.id = id;
}

extension ArtifactHighlightQueryWhereSort
    on QueryBuilder<ArtifactHighlight, ArtifactHighlight, QWhere> {
  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterWhere>
      anyArtifactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'artifactId'),
      );
    });
  }
}

extension ArtifactHighlightQueryWhere
    on QueryBuilder<ArtifactHighlight, ArtifactHighlight, QWhereClause> {
  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterWhereClause>
      artifactIdEqualTo(int artifactId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'artifactId',
        value: [artifactId],
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterWhereClause>
      artifactIdNotEqualTo(int artifactId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artifactId',
              lower: [],
              upper: [artifactId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artifactId',
              lower: [artifactId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artifactId',
              lower: [artifactId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artifactId',
              lower: [],
              upper: [artifactId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterWhereClause>
      artifactIdGreaterThan(
    int artifactId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'artifactId',
        lower: [artifactId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterWhereClause>
      artifactIdLessThan(
    int artifactId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'artifactId',
        lower: [],
        upper: [artifactId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterWhereClause>
      artifactIdBetween(
    int lowerArtifactId,
    int upperArtifactId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'artifactId',
        lower: [lowerArtifactId],
        includeLower: includeLower,
        upper: [upperArtifactId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ArtifactHighlightQueryFilter
    on QueryBuilder<ArtifactHighlight, ArtifactHighlight, QFilterCondition> {
  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      artifactIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artifactId',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      artifactIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artifactId',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      artifactIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artifactId',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      artifactIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artifactId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
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

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
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

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
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

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      noteEqualTo(
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

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
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

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      noteLessThan(
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

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      noteBetween(
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

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
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

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      noteEndsWith(
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

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      selectedTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      selectedTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      selectedTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      selectedTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'selectedText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      selectedTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      selectedTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      selectedTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      selectedTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'selectedText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      selectedTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selectedText',
        value: '',
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      selectedTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'selectedText',
        value: '',
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      styleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'style',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      styleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'style',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      styleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'style',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      styleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'style',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      styleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'style',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      styleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'style',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      styleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'style',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      styleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'style',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      styleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'style',
        value: '',
      ));
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterFilterCondition>
      styleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'style',
        value: '',
      ));
    });
  }
}

extension ArtifactHighlightQueryObject
    on QueryBuilder<ArtifactHighlight, ArtifactHighlight, QFilterCondition> {}

extension ArtifactHighlightQueryLinks
    on QueryBuilder<ArtifactHighlight, ArtifactHighlight, QFilterCondition> {}

extension ArtifactHighlightQuerySortBy
    on QueryBuilder<ArtifactHighlight, ArtifactHighlight, QSortBy> {
  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      sortByArtifactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artifactId', Sort.asc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      sortByArtifactIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artifactId', Sort.desc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      sortBySelectedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.asc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      sortBySelectedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.desc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      sortByStyle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'style', Sort.asc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      sortByStyleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'style', Sort.desc);
    });
  }
}

extension ArtifactHighlightQuerySortThenBy
    on QueryBuilder<ArtifactHighlight, ArtifactHighlight, QSortThenBy> {
  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      thenByArtifactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artifactId', Sort.asc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      thenByArtifactIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artifactId', Sort.desc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      thenBySelectedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.asc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      thenBySelectedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.desc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      thenByStyle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'style', Sort.asc);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QAfterSortBy>
      thenByStyleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'style', Sort.desc);
    });
  }
}

extension ArtifactHighlightQueryWhereDistinct
    on QueryBuilder<ArtifactHighlight, ArtifactHighlight, QDistinct> {
  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QDistinct>
      distinctByArtifactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artifactId');
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QDistinct>
      distinctBySelectedText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'selectedText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArtifactHighlight, ArtifactHighlight, QDistinct> distinctByStyle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'style', caseSensitive: caseSensitive);
    });
  }
}

extension ArtifactHighlightQueryProperty
    on QueryBuilder<ArtifactHighlight, ArtifactHighlight, QQueryProperty> {
  QueryBuilder<ArtifactHighlight, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ArtifactHighlight, int, QQueryOperations> artifactIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artifactId');
    });
  }

  QueryBuilder<ArtifactHighlight, DateTime?, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ArtifactHighlight, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<ArtifactHighlight, String, QQueryOperations>
      selectedTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedText');
    });
  }

  QueryBuilder<ArtifactHighlight, String, QQueryOperations> styleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'style');
    });
  }
}
