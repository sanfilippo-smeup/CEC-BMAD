# Product Requirements Document (PRD)
# RPGLE-Json Query Utility

**Project Name:** RPGLE-Json  
**Version:** 1.0  
**Date:** 2026-04-28  
**Author:** Mauro  
**Status:** Draft  
**Related Documents:** [Product Brief](product-brief.md)

---

## Table of Contents

1. [Document Overview](#document-overview)
2. [Product Vision](#product-vision)
3. [Functional Requirements](#functional-requirements)
4. [Non-Functional Requirements](#non-functional-requirements)
5. [API Specifications](#api-specifications)
6. [Data Structures](#data-structures)
7. [Error Handling](#error-handling)
8. [Performance Requirements](#performance-requirements)
9. [Security & Compliance](#security--compliance)
10. [Testing Requirements](#testing-requirements)
11. [Acceptance Criteria](#acceptance-criteria)
12. [Dependencies & Constraints](#dependencies--constraints)
13. [Glossary](#glossary)

---

## Document Overview

### Purpose
This PRD defines the detailed requirements for the RPGLE-Json Query Utility, a fixed-form RPGLE program that enables JSON file querying using JSONPath syntax on OS/400 v7.5 systems.

### Scope
This document covers:
- Complete functional requirements for JSON parsing and JSONPath querying
- Non-functional requirements including performance, scalability, and reliability
- API specifications for the `/COPY` interface
- Data structures and error handling mechanisms
- Testing and acceptance criteria

### Audience
- Development team implementing the utility
- QA team designing test cases
- RPG developers who will use the utility
- Technical reviewers and stakeholders

---

## Product Vision

### Vision Statement
Enable RPG developers to seamlessly integrate JSON data processing into their applications through a high-performance, dependency-free utility that handles files from 0 to 100MB with sub-millisecond response times.

### Key Differentiators
1. **Zero Dependencies:** No external libraries required
2. **High Performance:** <1ms first-byte latency with streaming architecture
3. **Full JSONPath Support:** Complete specification compliance
4. **Fixed-Form Compatible:** Works with legacy RPGLE codebases
5. **Optimized for Loops:** Efficient repeated queries on same file

---

## Functional Requirements

### FR-1: JSON File Reading

#### FR-1.1: IFS File Access
**Priority:** P0 (Critical)  
**Description:** Read JSON files from the Integrated File System (IFS)

**Requirements:**
- **FR-1.1.1:** Support absolute file paths (e.g., `/data/config.json`)
- **FR-1.1.2:** Support relative file paths from current working directory
- **FR-1.1.3:** Handle file paths up to 1024 characters
- **FR-1.1.4:** Detect and report file not found errors
- **FR-1.1.5:** Detect and report permission denied errors
- **FR-1.1.6:** Support files with UTF-8 encoding
- **FR-1.1.7:** Handle files from 0 bytes to 100MB

**Acceptance Criteria:**
- Successfully opens valid IFS file paths
- Returns appropriate error for non-existent files
- Returns appropriate error for permission issues
- Handles empty files (0 bytes) without error
- Successfully processes 100MB test file

---

#### FR-1.2: Streaming File Reading
**Priority:** P0 (Critical)  
**Description:** Read files using streaming approach to minimize memory usage

**Requirements:**
- **FR-1.2.1:** Read file in configurable buffer chunks (default 4KB)
- **FR-1.2.2:** Maintain file position for sequential reading
- **FR-1.2.3:** Support file rewind for multiple queries
- **FR-1.2.4:** Implement read-ahead buffering for performance
- **FR-1.2.5:** Release file handle on completion or error
- **FR-1.2.6:** Support concurrent file sessions (different files)

**Acceptance Criteria:**
- Memory usage remains constant regardless of file size
- Can process 100MB file with <10MB memory overhead
- File handle properly released in all scenarios
- Multiple queries on same file don't re-read entire file

---

### FR-2: JSON Parsing

#### FR-2.1: JSON Tokenization
**Priority:** P0 (Critical)  
**Description:** Break JSON content into tokens for parsing

**Requirements:**
- **FR-2.1.1:** Recognize all JSON token types: `{`, `}`, `[`, `]`, `:`, `,`, string, number, boolean, null
- **FR-2.1.2:** Handle escaped characters in strings: `\"`, `\\`, `\/`, `\b`, `\f`, `\n`, `\r`, `\t`
- **FR-2.1.3:** Support Unicode escape sequences: `\uXXXX`
- **FR-2.1.4:** Ignore whitespace (space, tab, newline, carriage return)
- **FR-2.1.5:** Detect and report malformed JSON syntax
- **FR-2.1.6:** Track line and column numbers for error reporting

**Acceptance Criteria:**
- Correctly tokenizes valid JSON documents
- Detects all common JSON syntax errors
- Provides line/column information for errors
- Handles all escape sequences correctly

---

#### FR-2.2: JSON Structure Parsing
**Priority:** P0 (Critical)  
**Description:** Build internal representation of JSON structure

**Requirements:**
- **FR-2.2.1:** Parse JSON objects (key-value pairs)
- **FR-2.2.2:** Parse JSON arrays (ordered lists)
- **FR-2.2.3:** Parse primitive values (string, number, boolean, null)
- **FR-2.2.4:** Support nested structures (objects within objects, arrays within arrays)
- **FR-2.2.5:** Handle arbitrary nesting depth (minimum 100 levels)
- **FR-2.2.6:** Build navigable parse tree for query evaluation
- **FR-2.2.7:** Maintain source position mapping for result extraction

**Acceptance Criteria:**
- Successfully parses all valid JSON structures
- Handles deeply nested documents (100+ levels)
- Parse tree accurately represents JSON structure
- Can navigate to any element in parsed structure

---

#### FR-2.3: JSON Data Types
**Priority:** P0 (Critical)  
**Description:** Support all JSON data types

**Requirements:**
- **FR-2.3.1:** **Strings:** UTF-8 encoded, with escape sequences
- **FR-2.3.2:** **Numbers:** Integer and floating-point, including scientific notation
- **FR-2.3.3:** **Booleans:** `true` and `false`
- **FR-2.3.4:** **Null:** `null` value
- **FR-2.3.5:** **Objects:** Unordered key-value collections
- **FR-2.3.6:** **Arrays:** Ordered value collections

**Acceptance Criteria:**
- Correctly identifies and stores all data types
- Preserves numeric precision for integers and decimals
- Handles scientific notation (e.g., `1.23e-4`)
- Distinguishes between null and empty string

---

### FR-3: JSONPath Query Engine

#### FR-3.1: Basic Path Navigation
**Priority:** P0 (Critical)  
**Description:** Support fundamental JSONPath navigation

**Requirements:**
- **FR-3.1.1:** Root selector: `$` (document root)
- **FR-3.1.2:** Dot notation: `$.store.book` (child access)
- **FR-3.1.3:** Bracket notation: `$['store']['book']` (alternative child access)
- **FR-3.1.4:** Array indexing: `$.items[0]` (zero-based)
- **FR-3.1.5:** Negative array indexing: `$.items[-1]` (last element)
- **FR-3.1.6:** Array slicing: `$.items[0:5]` (range selection)
- **FR-3.1.7:** Array slice with step: `$.items[0:10:2]` (every 2nd element)

**Acceptance Criteria:**
- All basic selectors work correctly
- Array indexing handles out-of-bounds gracefully
- Negative indices work from array end
- Slicing produces correct subsets

---

#### FR-3.2: Advanced Selectors
**Priority:** P0 (Critical)  
**Description:** Support advanced JSONPath features

**Requirements:**
- **FR-3.2.1:** Wildcard: `$.store.*` (all children)
- **FR-3.2.2:** Recursive descent: `$..author` (all matching descendants)
- **FR-3.2.3:** Array wildcard: `$.items[*]` (all array elements)
- **FR-3.2.4:** Multiple selectors: `$.items[0,2,4]` (specific indices)
- **FR-3.2.5:** Union operator: `$['name','title']` (multiple keys)

**Acceptance Criteria:**
- Wildcards return all matching elements
- Recursive descent finds all occurrences at any depth
- Multiple selectors return combined results
- Union operator works with mixed types

---

#### FR-3.3: Filter Expressions
**Priority:** P0 (Critical)  
**Description:** Support JSONPath filter expressions

**Requirements:**
- **FR-3.3.1:** Basic filters: `$.items[?(@.price)]` (existence check)
- **FR-3.3.2:** Comparison operators: `==`, `!=`, `<`, `<=`, `>`, `>=`
- **FR-3.3.3:** Numeric comparisons: `$.items[?(@.price < 10)]`
- **FR-3.3.4:** String comparisons: `$.items[?(@.category == 'fiction')]`
- **FR-3.3.5:** Boolean logic: `&&` (AND), `||` (OR)
- **FR-3.3.6:** Negation: `!` (NOT)
- **FR-3.3.7:** Current node reference: `@` (in filter context)
- **FR-3.3.8:** Root reference: `$` (in filter context)
- **FR-3.3.9:** Nested filters: `$.items[?(@.author.name == 'Smith')]`

**Acceptance Criteria:**
- All comparison operators work correctly
- Boolean logic combines filters properly
- Filters work with all data types
- Nested property access in filters works

---

#### FR-3.4: Query Optimization
**Priority:** P1 (High)  
**Description:** Optimize query execution for repeated queries

**Requirements:**
- **FR-3.4.1:** Cache parsed JSON structure for file session
- **FR-3.4.2:** Build index for frequently accessed paths
- **FR-3.4.3:** Reuse query compilation results
- **FR-3.4.4:** Implement query plan optimization
- **FR-3.4.5:** Support explicit file session management (open/close)

**Acceptance Criteria:**
- Second query on same file is >10x faster than first
- Memory usage for cached structure is reasonable
- Session cleanup releases all resources
- Query compilation overhead is minimal

---

### FR-4: Result Management

#### FR-4.1: Result Collection
**Priority:** P0 (Critical)  
**Description:** Collect and return query results

**Requirements:**
- **FR-4.1.1:** Return all matching nodes as a list
- **FR-4.1.2:** Preserve result order (document order)
- **FR-4.1.3:** Support empty result set (no matches)
- **FR-4.1.4:** Handle single result efficiently
- **FR-4.1.5:** Support large result sets (1000+ matches)
- **FR-4.1.6:** Extract result values as strings

**Acceptance Criteria:**
- All matching nodes are returned
- Results maintain document order
- Empty results handled gracefully
- Large result sets don't cause memory issues

---

#### FR-4.2: Result Formatting
**Priority:** P0 (Critical)  
**Description:** Format results for RPGLE consumption

**Requirements:**
- **FR-4.2.1:** Return results as data structure array
- **FR-4.2.2:** Each result includes: value (string), type (indicator), path (string)
- **FR-4.2.3:** Support result count indicator
- **FR-4.2.4:** Truncate oversized values with indicator
- **FR-4.2.5:** Convert all JSON types to string representation
- **FR-4.2.6:** Preserve JSON structure in string format for objects/arrays

**Acceptance Criteria:**
- Results accessible via standard RPGLE data structures
- Type information preserved for each result
- Truncation clearly indicated
- Complex types serialized correctly

---

### FR-5: Integration Interface

#### FR-5.1: Procedure Interface
**Priority:** P0 (Critical)  
**Description:** Define the main query procedure interface

**Requirements:**
- **FR-5.1.1:** Procedure name: `JSONQRY`
- **FR-5.1.2:** Input parameter: File path (1024A)
- **FR-5.1.3:** Input parameter: JSONPath query (4096A)
- **FR-5.1.4:** Output parameter: Result array data structure
- **FR-5.1.5:** Output parameter: Result count (10I 0)
- **FR-5.1.6:** Output parameter: Error message (256A)
- **FR-5.1.7:** Error indicator: *IN35 (set ON for any error)

**Acceptance Criteria:**
- Procedure callable from any RPGLE program
- All parameters properly defined
- Error indicator reliably set
- Interface documented in `/COPY` member

---

#### FR-5.2: Session Management
**Priority:** P1 (High)  
**Description:** Manage file sessions for optimization

**Requirements:**
- **FR-5.2.1:** Procedure: `JSONOPEN` - Open file session
- **FR-5.2.2:** Procedure: `JSONQRYS` - Query within session
- **FR-5.2.3:** Procedure: `JSONCLOSE` - Close file session
- **FR-5.2.4:** Return session handle for multi-query operations
- **FR-5.2.5:** Automatic cleanup on program end
- **FR-5.2.6:** Support multiple concurrent sessions

**Acceptance Criteria:**
- Session-based queries significantly faster
- Sessions properly isolated
- Resources released on close
- Automatic cleanup prevents leaks

---

### FR-6: Error Detection and Reporting

#### FR-6.1: File Errors
**Priority:** P0 (Critical)  
**Description:** Detect and report file-related errors

**Requirements:**
- **FR-6.1.1:** File not found
- **FR-6.1.2:** Permission denied
- **FR-6.1.3:** File too large (>100MB)
- **FR-6.1.4:** Read error (I/O failure)
- **FR-6.1.5:** Invalid file path

**Error Messages:**
- `JSON001: File not found: {path}`
- `JSON002: Permission denied: {path}`
- `JSON003: File exceeds maximum size (100MB): {path}`
- `JSON004: I/O error reading file: {path}`
- `JSON005: Invalid file path: {path}`

---

#### FR-6.2: JSON Parsing Errors
**Priority:** P0 (Critical)  
**Description:** Detect and report JSON syntax errors

**Requirements:**
- **FR-6.2.1:** Unexpected token
- **FR-6.2.2:** Unterminated string
- **FR-6.2.3:** Invalid escape sequence
- **FR-6.2.4:** Invalid number format
- **FR-6.2.5:** Unexpected end of file
- **FR-6.2.6:** Duplicate object keys (warning)

**Error Messages:**
- `JSON101: Unexpected token '{token}' at line {line}, column {col}`
- `JSON102: Unterminated string at line {line}, column {col}`
- `JSON103: Invalid escape sequence '\{char}' at line {line}, column {col}`
- `JSON104: Invalid number format at line {line}, column {col}`
- `JSON105: Unexpected end of file at line {line}, column {col}`
- `JSON106: Duplicate key '{key}' at line {line}, column {col}`

---

#### FR-6.3: JSONPath Query Errors
**Priority:** P0 (Critical)  
**Description:** Detect and report query syntax errors

**Requirements:**
- **FR-6.3.1:** Invalid query syntax
- **FR-6.3.2:** Unsupported operator
- **FR-6.3.3:** Malformed filter expression
- **FR-6.3.4:** Invalid array index
- **FR-6.3.5:** Type mismatch in comparison

**Error Messages:**
- `JSON201: Invalid JSONPath syntax: {query}`
- `JSON202: Unsupported operator '{op}' in query`
- `JSON203: Malformed filter expression: {expression}`
- `JSON204: Invalid array index: {index}`
- `JSON205: Type mismatch in comparison at: {location}`

---

#### FR-6.4: Runtime Errors
**Priority:** P0 (Critical)  
**Description:** Detect and report runtime errors

**Requirements:**
- **FR-6.4.1:** Memory allocation failure
- **FR-6.4.2:** Stack overflow (deep nesting)
- **FR-6.4.3:** Result set too large
- **FR-6.4.4:** Internal error

**Error Messages:**
- `JSON301: Memory allocation failed`
- `JSON302: Maximum nesting depth exceeded (100 levels)`
- `JSON303: Result set exceeds maximum size`
- `JSON304: Internal error: {details}`

---

## Non-Functional Requirements

### NFR-1: Performance

#### NFR-1.1: Query Latency
**Priority:** P0 (Critical)

| Metric | Requirement | Measurement |
|--------|-------------|-------------|
| First-byte latency | <1ms (P99) | Time from procedure call to first result byte |
| Subsequent queries | <0.1ms (P99) | Queries on cached file |
| Query throughput | >1000 queries/sec | On same file with session |
| Parse time | <100ms for 10MB | Initial file parsing |

**Acceptance Criteria:**
- 99% of first queries complete in <1ms
- 99% of cached queries complete in <0.1ms
- Sustained throughput of 1000+ queries/sec
- 10MB file parses in <100ms

---

#### NFR-1.2: Memory Usage
**Priority:** P0 (Critical)

| Metric | Requirement | Measurement |
|--------|-------------|-------------|
| Parser overhead | <10MB | Memory used by parser state |
| Per-file cache | <2x file size | Cached parse tree size |
| Result buffer | <1MB default | Configurable result buffer |
| Peak memory | <200MB | For 100MB file processing |

**Acceptance Criteria:**
- Parser uses <10MB for state management
- Cached structures are <2x original file size
- 100MB file processing uses <200MB total memory

---

#### NFR-1.3: Scalability
**Priority:** P1 (High)

| Metric | Requirement | Measurement |
|--------|-------------|-------------|
| File size | 0-100MB | Tested range |
| Nesting depth | 100 levels | Maximum supported |
| Result set size | 10,000 matches | Maximum results |
| Concurrent sessions | 10 files | Simultaneous open files |

**Acceptance Criteria:**
- Successfully processes 100MB files
- Handles 100-level nesting without error
- Returns up to 10,000 results efficiently
- Supports 10 concurrent file sessions

---

### NFR-2: Reliability

#### NFR-2.1: Error Handling
**Priority:** P0 (Critical)

**Requirements:**
- **NFR-2.1.1:** All errors set indicator 35 ON
- **NFR-2.1.2:** All errors provide descriptive message
- **NFR-2.1.3:** No silent failures
- **NFR-2.1.4:** Graceful degradation on resource limits
- **NFR-2.1.5:** Proper cleanup on all error paths

**Acceptance Criteria:**
- 100% of error conditions set indicator 35
- All error messages are actionable
- No crashes or hangs on invalid input
- Resources released on all error paths

---

#### NFR-2.2: Stability
**Priority:** P0 (Critical)

**Requirements:**
- **NFR-2.2.1:** No memory leaks in 24-hour stress test
- **NFR-2.2.2:** No crashes on malformed input
- **NFR-2.2.3:** Consistent behavior across runs
- **NFR-2.2.4:** Proper resource cleanup

**Acceptance Criteria:**
- Zero memory leaks in 24-hour test
- Handles all malformed input gracefully
- Deterministic results for same input
- All file handles and memory released

---

### NFR-3: Compatibility

#### NFR-3.1: Platform Requirements
**Priority:** P0 (Critical)

**Requirements:**
- **NFR-3.1.1:** OS/400 v7.5 or higher
- **NFR-3.1.2:** Fixed-form RPGLE compiler
- **NFR-3.1.3:** IFS file system access
- **NFR-3.1.4:** No external library dependencies

**Acceptance Criteria:**
- Compiles on OS/400 v7.5 without errors
- Uses only fixed-form RPGLE syntax
- Accesses IFS through standard APIs
- Zero external dependencies

---

#### NFR-3.2: Integration Compatibility
**Priority:** P0 (Critical)

**Requirements:**
- **NFR-3.2.1:** Works with existing RPGLE programs
- **NFR-3.2.2:** Compatible with `/COPY` inclusion
- **NFR-3.2.3:** No naming conflicts with common identifiers
- **NFR-3.2.4:** Thread-safe for multi-threaded programs

**Acceptance Criteria:**
- Integrates into existing programs via `/COPY`
- No conflicts with standard RPGLE identifiers
- Safe for use in multi-threaded environments

---

### NFR-4: Maintainability

#### NFR-4.1: Code Quality
**Priority:** P1 (High)

**Requirements:**
- **NFR-4.1.1:** Clear, descriptive variable names
- **NFR-4.1.2:** Comprehensive inline comments
- **NFR-4.1.3:** Modular procedure design
- **NFR-4.1.4:** Consistent coding style
- **NFR-4.1.5:** Error handling in all procedures

**Acceptance Criteria:**
- Code review passes quality standards
- All procedures have header comments
- Consistent naming conventions throughout
- Error handling present in all procedures

---

#### NFR-4.2: Documentation
**Priority:** P1 (High)

**Requirements:**
- **NFR-4.2.1:** API reference documentation
- **NFR-4.2.2:** Usage examples for common scenarios
- **NFR-4.2.3:** Error code reference
- **NFR-4.2.4:** Performance tuning guide
- **NFR-4.2.5:** Integration guide

**Acceptance Criteria:**
- Complete API documentation available
- At least 10 usage examples provided
- All error codes documented
- Performance guide includes benchmarks
- Integration guide covers common scenarios

---

### NFR-5: Security

#### NFR-5.1: File Access Security
**Priority:** P1 (High)

**Requirements:**
- **NFR-5.1.1:** Respect IFS file permissions
- **NFR-5.1.2:** No privilege escalation
- **NFR-5.1.3:** Validate file paths (no directory traversal)
- **NFR-5.1.4:** Read-only file access

**Acceptance Criteria:**
- Cannot read files without proper permissions
- No security vulnerabilities in file access
- Path validation prevents traversal attacks
- Never modifies source files

---

## API Specifications

### Primary Query Interface

```rpgle
     C/COPY QRPGLESRC,JSONQRY
     
     C                   EVAL      FilePath = '/data/file.json'
     C                   EVAL      Query = '$.users[*].email'
     
     C                   CALL      'JSONQRY'
     C                   PARM                    FilePath    1024
     C                   PARM                    Query       4096
     C                   PARM                    Results     
     C                   PARM                    ResCount    10I 0
     C                   PARM                    ErrMsg      256
     
     C                   IF        *IN35 = *ON
     C                   DSPLY                   ErrMsg
     C                   ELSE
     C                   EXSR      ProcessResults
     C                   ENDIF
```

### Parameters

#### Input Parameters

| Parameter | Type | Length | Description |
|-----------|------|--------|-------------|
| FilePath | CHAR | 1024 | Absolute or relative IFS file path |
| Query | CHAR | 4096 | JSONPath query expression |

#### Output Parameters

| Parameter | Type | Length | Description |
|-----------|------|--------|-------------|
| Results | DS Array | Variable | Array of result data structures |
| ResCount | INT | 10I 0 | Number of results returned |
| ErrMsg | CHAR | 256 | Error message (if *IN35 = ON) |

#### Indicators

| Indicator | Description |
|-----------|-------------|
| *IN35 | Error indicator (ON = error occurred) |

---

### Session-Based Interface

```rpgle
     C/COPY QRPGLESRC,JSONQRY
     
     C* Open file session
     C                   EVAL      FilePath = '/data/file.json'
     C                   CALL      'JSONOPEN'
     C                   PARM                    FilePath    1024
     C                   PARM                    Session     10I 0
     C                   PARM                    ErrMsg      256
     
     C                   IF        *IN35 = *OFF
     
     C* Execute multiple queries on same file
     C                   EVAL      Query1 = '$.users[0].name'
     C                   CALL      'JSONQRYS'
     C                   PARM                    Session
     C                   PARM                    Query1      4096
     C                   PARM                    Results1
     C                   PARM                    ResCount1   10I 0
     C                   PARM                    ErrMsg
     
     C                   EVAL      Query2 = '$.users[0].email'
     C                   CALL      'JSONQRYS'
     C                   PARM                    Session
     C                   PARM                    Query2      4096
     C                   PARM                    Results2
     C                   PARM                    ResCount2   10I 0
     C                   PARM                    ErrMsg
     
     C* Close session
     C                   CALL      'JSONCLOSE'
     C                   PARM                    Session
     
     C                   ENDIF
```

---

## Data Structures

### Result Data Structure

```rpgle
     D Results         DS                  QUALIFIED DIM(1000)
     D  Value                      32766A  VARYING
     D  Type                          1A
     D  Path                       4096A  VARYING
     D  Truncated                    1N
```

#### Fields

| Field | Type | Description |
|-------|------|-------------|
| Value | VARCHAR(32766) | String representation of result value |
| Type | CHAR(1) | Type indicator: 'S'=String, 'N'=Number, 'B'=Boolean, 'O'=Object, 'A'=Array, 'Z'=Null |
| Path | VARCHAR(4096) | JSONPath to this result |
| Truncated | IND | *ON if value was truncated to fit |

---

### Session Handle

```rpgle
     D Session         S             10I 0
```

Internal session identifier for multi-query operations.

---

## Error Handling

### Error Categories

| Category | Code Range | Description |
|----------|------------|-------------|
| File Errors | JSON001-JSON099 | File access and I/O errors |
| Parse Errors | JSON100-JSON199 | JSON syntax and parsing errors |
| Query Errors | JSON200-JSON299 | JSONPath query errors |
| Runtime Errors | JSON300-JSON399 | Memory and runtime errors |

### Error Response Pattern

All errors follow this pattern:
1. Set indicator 35 ON
2. Populate ErrMsg with error code and description
3. Return immediately (no partial results)
4. Clean up all allocated resources

### Example Error Messages

```
JSON001: File not found: /data/missing.json
JSON101: Unexpected token '}' at line 15, column 8
JSON201: Invalid JSONPath syntax: $.users[.name
JSON301: Memory allocation failed
```

---

## Performance Requirements

### Benchmark Scenarios

#### Scenario 1: Small File, Simple Query
- **File Size:** 10KB
- **Query:** `$.user.name`
- **Target:** <0.5ms (P99)

#### Scenario 2: Medium File, Complex Query
- **File Size:** 1MB
- **Query:** `$.items[?(@.price < 100)].name`
- **Target:** <5ms (P99)

#### Scenario 3: Large File, Recursive Query
- **File Size:** 10MB
- **Query:** `$..author`
- **Target:** <50ms (P99)

#### Scenario 4: Very Large File, Simple Query
- **File Size:** 100MB
- **Query:** `$.config.version`
- **Target:** <100ms (P99)

#### Scenario 5: Repeated Queries (Session)
- **File Size:** 1MB
- **Queries:** 100 different queries
- **Target:** <10ms total (after first query)

---

## Security & Compliance

### Security Requirements

#### SEC-1: File Access Control
- Respect OS/400 file permissions
- No privilege escalation attempts
- Read-only access to JSON files
- Validate all file paths

#### SEC-2: Input Validation
- Sanitize file paths (prevent directory traversal)
- Validate JSONPath query syntax
- Limit query complexity (prevent DoS)
- Bounds checking on all array access

#### SEC-3: Resource Limits
- Maximum file size: 100MB
- Maximum nesting depth: 100 levels
- Maximum result set: 10,000 items
- Query timeout: 30 seconds

### Compliance

- **Platform Compliance:** OS/400 v7.5 standards
- **Coding Standards:** IBM RPGLE best practices
- **Security Standards:** IBM i security guidelines

---

## Testing Requirements

### Unit Testing

#### UT-1: JSON Parser Tests
- Valid JSON documents (100+ test cases)
- Invalid JSON documents (50+ error cases)
- Edge cases (empty, large, deeply nested)
- All data types
- Escape sequences and Unicode

#### UT-2: JSONPath Engine Tests
- All selector types (50+ test cases)
- Filter expressions (30+ test cases)
- Edge cases (empty results, large results)
- Error conditions (invalid syntax)

#### UT-3: File I/O Tests
- Various file sizes (0B to 100MB)
- File access errors
- Permission errors
- Concurrent access

---

### Integration Testing

#### IT-1: End-to-End Scenarios
- Complete workflow tests (20+ scenarios)
- Real-world JSON documents
- Common use cases (API responses, configs)
- Error recovery scenarios

#### IT-2: Performance Testing
- Benchmark scenarios (5 scenarios above)
- Load testing (sustained throughput)
- Stress testing (resource limits)
- Memory leak testing (24-hour run)

#### IT-3: Compatibility Testing
- OS/400 v7.5 platform
- Integration with sample RPGLE programs
- `/COPY` inclusion testing
- Multi-threaded environment

---

### Acceptance Testing

#### AT-1: Functional Acceptance
- All functional requirements verified
- All error conditions tested
- Documentation complete and accurate
- Examples work as documented

#### AT-2: Performance Acceptance
- All performance targets met
- Benchmark results documented
- No performance regressions
- Resource usage within limits

#### AT-3: Quality Acceptance
- Zero critical bugs
- Zero memory leaks
- Code review passed
- Documentation review passed

---

## Acceptance Criteria

### Release Criteria

The product is ready for release when ALL of the following are met:

#### Functional Completeness
- [ ] All P0 functional requirements implemented
- [ ] All P1 functional requirements implemented
- [ ] All error conditions handled
- [ ] All test cases passing

#### Performance Targets
- [ ] First-byte latency <1ms (P99)
- [ ] Cached query latency <0.1ms (P99)
- [ ] 100MB file processing successful
- [ ] Memory usage within limits

#### Quality Standards
- [ ] Zero critical bugs
- [ ] Zero high-priority bugs
- [ ] <5 medium-priority bugs
- [ ] Code review approved
- [ ] No memory leaks detected

#### Documentation
- [ ] API reference complete
- [ ] Usage examples provided (10+)
- [ ] Error code reference complete
- [ ] Integration guide complete
- [ ] Performance guide complete

#### Testing
- [ ] All unit tests passing (100%)
- [ ] All integration tests passing (100%)
- [ ] All acceptance tests passing (100%)
- [ ] Performance benchmarks documented
- [ ] 24-hour stability test passed

#### Compatibility
- [ ] Compiles on OS/400 v7.5
- [ ] Works with fixed-form RPGLE
- [ ] `/COPY` integration verified
- [ ] No external dependencies

---

## Dependencies & Constraints

### Technical Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| OS/400 | v7.5+ | Operating system |
| RPGLE Compiler | Fixed-form | Language compiler |
| IFS | Standard | File system access |

### Technical Constraints

| Constraint | Impact | Mitigation |
|------------|--------|------------|
| STRICT Fixed-form RPGLE | Mandatory column-based syntax; NO /FREE or /END-FREE blocks permitted. | Winston (Architect) enforces this in all designs. |
| No external libraries | Must implement everything | Focus on essential features |
| 100MB file limit | Cannot process larger files | Document limitation clearly |
| OS/400 v7.5 only | No newer features | Use compatible APIs only |

### Resource Constraints

| Resource | Limit | Justification |
|----------|-------|---------------|
| Memory | 200MB max | Reasonable for 100MB file processing |
| File handles | 10 concurrent | Sufficient for typical usage |
| Result set | 10,000 items | Balance between utility and performance |
| Query timeout | 30 seconds | Prevent runaway queries |

---

## Glossary

| Term | Definition |
|------|------------|
| **IFS** | Integrated File System - IBM i file system for stream files |
| **JSONPath** | Query language for JSON, similar to XPath for XML |
| **Fixed-form RPGLE** | Traditional column-based RPGLE syntax (vs free-form) |
| **OS/400** | IBM i operating system (also called IBM i, i5/OS) |
| **Streaming Parser** | Parser that processes data incrementally without loading entire file |
| **Parse Tree** | Internal representation of JSON structure for navigation |
| **Session** | Persistent file context for multiple queries |
| **First-byte Latency** | Time from query start to first result byte available |
| **P99** | 99th percentile - 99% of operations complete within this time |
| **/COPY** | RPGLE directive to include external source code |
| **Indicator 35** | RPGLE error indicator convention |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-28 | Mauro | Initial PRD creation |

---

## Appendix A: JSONPath Examples

### Basic Navigation
```
$.store.book[0].title          → First book title
$.store.book[*].author         → All book authors
$.store.book[-1].price         → Last book price
```

### Array Operations
```
$.store.book[0:2]              → First two books
$.store.book[::2]              → Every other book
$.store.book[-2:]              → Last two books
```

### Wildcards and Recursion
```
$.store.*                      → All store children
$..author                      → All authors (any depth)
$.store.book[*].author         → All book authors
```

### Filters
```
$.store.book[?(@.price < 10)]           → Books under $10
$.store.book[?(@.category == 'fiction')] → Fiction books
$.store.book[?(@.price < 10 && @.category == 'fiction')] → Cheap fiction
```

### Complex Queries
```
$..book[?(@.author =~ /.*Tolkien.*/)]   → Books by Tolkien
$.store.book[?(@.price < $.expensive)]   → Books cheaper than expensive threshold
```

---

## Appendix B: Sample JSON Documents

### Simple API Response
```json
{
  "user": {
    "id": 12345,
    "name": "John Doe",
    "email": "john@example.com",
    "active": true
  }
}
```

### Array of Objects
```json
{
  "users": [
    {"id": 1, "name": "Alice", "role": "admin"},
    {"id": 2, "name": "Bob", "role": "user"},
    {"id": 3, "name": "Charlie", "role": "user"}
  ]
}
```

### Nested Structure
```json
{
  "store": {
    "book": [
      {
        "category": "fiction",
        "author": "Herman Melville",
        "title": "Moby Dick",
        "price": 8.99
      },
      {
        "category": "fiction",
        "author": "J.R.R. Tolkien",
        "title": "The Lord of the Rings",
        "price": 22.99
      }
    ],
    "bicycle": {
      "color": "red",
      "price": 19.95
    }
  }
}
```

---

**END OF DOCUMENT**
