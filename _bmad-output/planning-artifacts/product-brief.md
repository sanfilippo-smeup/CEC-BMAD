# Product Brief: RPGLE-Json Query Utility

**Project Name:** RPGLE-Json  
**Version:** 1.0  
**Date:** 2026-04-28  
**Author:** Mauro  
**Status:** Draft

---

## Executive Summary

RPGLE-Json is a standalone utility that enables RPG developers to query JSON files stored in the IFS using JSONPath syntax. Implemented as a fixed-form RPGLE program with a `/COPY` wrapper procedure, it provides high-performance JSON querying capabilities without external dependencies, specifically designed for OS/400 v7.5

---

## Problem Statement

RPG developers on IBM i systems need to work with JSON data from modern APIs, configuration files, and data exchanges. Current solutions either:
- Require external libraries that may not be available or approved
- Lack JSONPath query capabilities
- Don't support large files efficiently
- Are incompatible with fixed-form RPGLE or older OS versions

This creates a significant barrier for integrating legacy RPG applications with modern JSON-based systems.

---

## Target Users

**Primary User:** RPG Developers on IBM i (OS/400 v7.5)

**User Profile:**
- Experienced with fixed-form RPGLE programming
- Working with JSON data from REST APIs, configuration files, or data pipelines
- Need to integrate JSON processing into existing RPG programs
- Often work within DO and FOR loops requiring multiple queries on the same file
- Prefer native solutions over external dependencies

**Use Cases:**
1. **API Integration:** Parse REST API responses to extract specific data elements
2. **Configuration Management:** Read and query JSON configuration files
3. **Data Processing:** Extract multiple values from JSON files in batch operations
4. **Legacy Modernization:** Add JSON capabilities to existing RPG applications

---

## Product Goals

### Primary Goals
1. **Performance:** Achieve <1ms time-to-first-byte for initial query
2. **Scalability:** Handle JSON files from 0 to 100MB efficiently
3. **Compatibility:** Work on OS/400 v7.5 with fixed-form RPGLE
4. **Independence:** No external library dependencies
5. **Usability:** Simple `/COPY` integration with clear error handling

### Success Criteria
- Query response time <1ms for first byte
- Support files up to 100MB without memory issues
- Full JSONPath specification compliance
- Zero external dependencies
- Clear error reporting via indicator 35 and message variable
- Optimized for multiple queries on same file

---

## Core Features

### 1. JSONPath Query Engine
**Description:** Full JSONPath specification support for flexible data extraction

**Capabilities:**
- Dot notation for object navigation (`$.user.name`)
- Array indexing and slicing (`$.items[0]`, `$.items[0:5]`)
- Wildcard matching (`$.*.name`, `$..price`)
- Filter expressions (`$.items[?(@.price < 10)]`)
- Recursive descent (`$..author`)
- Multiple selectors and unions

### 2. Streaming JSON Parser
**Description:** Memory-efficient parser for large files

**Capabilities:**
- Stream-based parsing to handle 100MB+ files
- Incremental processing without loading entire file
- Optimized for repeated queries on same file
- Automatic resource cleanup

### 3. Result Management
**Description:** Flexible result handling for multiple matches

**Capabilities:**
- Return multiple matching nodes as a list structure
- Configurable result format
- Efficient memory management for large result sets
- Support for nested and complex JSON structures

### 4. Error Handling
**Description:** Clear, actionable error reporting

**Capabilities:**
- Indicator 35 set ON for any error condition
- Output variable containing detailed error message
- Error categories:
  - File not found or inaccessible
  - Malformed JSON syntax
  - Invalid JSONPath query
  - Memory allocation failures
  - Parsing errors with line/column information

### 5. Integration Interface
**Description:** Simple `/COPY` integration for RPG programs

**Capabilities:**
- Single procedure call interface
- Input parameters: file path, JSONPath query
- Output parameters: result list, error indicator, error message
- Stateful operation for query optimization
- Resource management (open/close file context)

---

## Technical Constraints

### Hard Requirements
1. **Language:** STRICT Fixed-form RPGLE only (NO /FREE or /END-FREE blocks)
2. **Platform:** OS/400 v7.5
3. **Dependencies:** Zero external libraries
4. **Performance:** <1ms first-byte latency
5. **File Size:** Support 0-100MB files
6. **Memory:** Streaming approach, no full-file loading

### Technical Challenges

#### 1. JSONPath Implementation in Fixed-Form RPGLE
**Challenge:** Implementing a full JSONPath parser and evaluator in fixed-form RPGLE without modern language features

**Considerations:**
- Limited string handling capabilities
- No native regex support
- Fixed-length field constraints
- Complex expression parsing requirements

#### 2. Streaming Parser Architecture
**Challenge:** Building a streaming JSON parser that maintains state for multiple queries

**Considerations:**
- IFS file I/O optimization
- Token buffering strategy
- State management between queries
- Memory allocation for parse tree

#### 3. Performance Optimization
**Challenge:** Achieving <1ms first-byte with streaming approach

**Considerations:**
- File caching strategy
- Index building for repeated queries
- Efficient data structure design
- Minimizing IFS I/O operations

#### 4. Memory Management
**Challenge:** Handling 100MB files without memory exhaustion

**Considerations:**
- Dynamic memory allocation in RPGLE
- Garbage collection strategy
- Buffer size optimization
- Resource cleanup on error

#### 5. Result List Implementation
**Challenge:** Returning variable-length list of results in fixed-form RPGLE

**Considerations:**
- Data structure design for result list
- Maximum result set size
- String concatenation efficiency
- Memory allocation for results

---

## Out of Scope

The following features are explicitly **not** included in this version:

1. **JSON Generation/Writing:** Only reading and querying
2. **JSON Modification:** No in-place editing or updates
3. **Schema Validation:** No JSON schema validation
4. **Multiple File Operations:** Single file per query session
5. **Free-Form RPGLE:** Fixed-form only
6. **Older OS Versions:** OS/400 v7.5 minimum
7. **Network Operations:** IFS files only, no HTTP/REST client
8. **Async Operations:** Synchronous processing only
9. **GUI/Interactive Tools:** Command-line/programmatic only
10. **Alternative Query Languages:** JSONPath only (no XPath, SQL-like, etc.)

---

## Success Metrics

### Performance Metrics
- **Query Latency:** <1ms time-to-first-byte (P99)
- **Throughput:** Support 1000+ queries/second on same file
- **Memory Usage:** <10MB overhead for parser state
- **File Size Support:** Successfully handle 100MB files

### Quality Metrics
- **JSONPath Compliance:** 100% of JSONPath specification
- **Error Detection:** Catch and report all malformed JSON
- **Stability:** Zero memory leaks in 24-hour stress test
- **Compatibility:** Works on OS/400 v7.5 without modifications

### Usability Metrics
- **Integration Time:** <30 minutes to add to existing RPG program
- **Error Clarity:** 100% of errors include actionable messages
- **Documentation:** Complete API reference and examples

---

## Risks and Mitigation

### Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| JSONPath complexity exceeds fixed-form RPGLE capabilities | High | Medium | Phased implementation; start with core features |
| Streaming parser cannot achieve <1ms latency | High | Medium | Implement file indexing and caching strategies |
| Memory management issues with large files | High | Low | Extensive testing with various file sizes; implement safeguards |
| Fixed-form RPGLE string handling limitations | Medium | High | Design efficient string buffer management; use pointers |
| IFS I/O performance bottleneck | Medium | Medium | Optimize buffer sizes; implement read-ahead caching |

### Project Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Scope creep (adding JSON writing, etc.) | Medium | High | Strict scope adherence; document future enhancements separately |
| Performance requirements unachievable | High | Low | Early prototyping and benchmarking |
| OS/400 v7.5 compatibility issues | Medium | Low | Test on target platform early and often |

---

## Dependencies

### Platform Dependencies
- OS/400 v7.5 or higher
- IFS (Integrated File System) access
- RPGLE compiler

### Development Dependencies
- None (no external libraries)

### Runtime Dependencies
- None (standalone utility)

---

## Timeline Estimate

**Note:** Detailed timeline will be created during sprint planning

**Rough Phases:**
1. **Design & Architecture** (1-2 weeks)
   - JSONPath parser design
   - Streaming architecture design
   - Data structure definitions

2. **Core Implementation** (4-6 weeks)
   - JSON tokenizer/lexer
   - Streaming parser
   - JSONPath evaluator
   - Result management

3. **Integration & Testing** (2-3 weeks)
   - `/COPY` wrapper
   - Error handling
   - Performance optimization
   - Comprehensive testing

4. **Documentation & Release** (1 week)
   - API documentation
   - Usage examples
   - Performance benchmarks

**Total Estimate:** 8-12 weeks

---

## Next Steps

1. **Review and Approve Brief:** Stakeholder review of this document
2. **Create PRD:** Detailed Product Requirements Document
3. **Architecture Design:** Technical architecture and design decisions
4. **Sprint Planning:** Break down into implementable stories
5. **Prototype:** Build proof-of-concept for critical components

---

## Appendix

### Example Usage

```rpgle
     C/COPY QRPGLESRC,JSONQUERY
     
     C                   EVAL      FilePath = '/data/api-response.json'
     C                   EVAL      Query = '$.users[?(@.active==true)].email'
     
     C                   CALL      'JSONQRY'
     C                   PARM                    FilePath
     C                   PARM                    Query
     C                   PARM                    Results
     C                   PARM                    ErrMsg
     
     C                   IF        *IN35 = *ON
     C                   DSPLY                   ErrMsg
     C                   ELSE
     C                   EXSR      ProcessResults
     C                   ENDIF
```

### JSONPath Examples

| Query | Description | Example Result |
|-------|-------------|----------------|
| `$.store.book[0].title` | First book title | "Moby Dick" |
| `$..author` | All authors (recursive) | ["Herman Melville", "J.R.R. Tolkien"] |
| `$.store.book[*].price` | All book prices | [8.95, 12.99, 8.99] |
| `$.store.book[?(@.price < 10)]` | Books under $10 | [{...}, {...}] |
| `$..book[0,1]` | First two books | [{...}, {...}] |

---

**Document Control:**
- **Created:** 2026-04-28
- **Last Modified:** 2026-04-28
- **Version:** 1.0
- **Status:** Draft - Awaiting Review