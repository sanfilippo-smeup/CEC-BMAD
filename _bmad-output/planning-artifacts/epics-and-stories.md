# Epics and Stories
# RPGLE-Json Query Utility

**Project Name:** RPGLE-Json  
**Version:** 1.0  
**Date:** 2026-04-28  
**Author:** Mauro  
**Status:** Draft  
**Related Documents:** [Product Brief](product-brief.md) | [PRD](prd.md) | [Architecture](architecture.md)

---

## Table of Contents

1. [Epic Overview](#epic-overview)
2. [Epic Breakdown](#epic-breakdown)
3. [Story Dependencies](#story-dependencies)
4. [Story Prioritization](#story-prioritization)
5. [Implementation Sequence](#implementation-sequence)

---

## Epic Overview

The RPGLE-Json project is broken down into **6 major epics**, each representing a significant functional area:

| Epic ID | Epic Name | Stories | Priority | Dependencies |
|---------|-----------|---------|----------|--------------|
| E1 | Foundation Infrastructure | 8 | P0 | None |
| E2 | JSON Parser Engine | 12 | P0 | E1 |
| E3 | JSONPath Query Engine | 15 | P0 | E2 |
| E4 | Performance Optimization | 8 | P1 | E3 |
| E5 | Public API & Integration | 10 | P0 | E3, E4 |
| E6 | Testing & Documentation | 12 | P1 | E5 |

**Total Stories:** 65

---

## Epic Breakdown

### Epic 1: Foundation Infrastructure

**Goal:** Establish core infrastructure for file I/O, memory management, and basic data structures

**Priority:** P0 (Critical)  
**Dependencies:** None  
**Estimated Effort:** 2-3 days with AI assistance

#### Stories

##### E1-S1: IFS File Stream Reader
**As a** developer  
**I want** to read IFS files using a streaming approach  
**So that** I can process large JSON files without loading them entirely into memory

**Acceptance Criteria:**
- [ ] Can open IFS file by path (absolute and relative)
- [ ] Reads file in configurable buffer chunks (default 4KB)
- [ ] Maintains file position for sequential reading
- [ ] Properly closes file handle on completion
- [ ] Returns appropriate errors for file not found, permission denied

**Technical Notes:**
- Use IFS C APIs: `open()`, `read()`, `close()`
- Implement buffer management with read-ahead
- Handle UTF-8 encoding

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** None

---

##### E1-S2: Buffer Management System
**As a** developer  
**I want** an efficient buffer management system  
**So that** file reading is optimized with minimal I/O operations

**Acceptance Criteria:**
- [ ] Implements read-ahead buffering (8KB default)
- [ ] Automatically refills buffer when threshold reached
- [ ] Provides `PeekChar()` and `ReadChar()` operations
- [ ] Handles EOF gracefully
- [ ] Maintains line and column tracking for error reporting

**Technical Notes:**
- Buffer size: 4KB active + 8KB read-ahead
- Refill threshold: 1KB remaining
- Track position for error messages

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E1-S1

---

##### E1-S3: Memory Allocation Framework
**As a** developer  
**I want** a memory allocation framework  
**So that** I can dynamically allocate and free memory for parse tree nodes

**Acceptance Criteria:**
- [ ] Implements `AllocNode()` and `FreeNode()` procedures
- [ ] Uses node pooling for performance
- [ ] Tracks allocated memory for cleanup
- [ ] Provides emergency cleanup on errors
- [ ] Prevents memory leaks

**Technical Notes:**
- Pre-allocate node pool (10,000 nodes)
- Use free list for recycling
- Implement reference counting if needed

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** None

---

##### E1-S4: Core Data Structures
**As a** developer  
**I want** well-defined data structures for nodes, tokens, and sessions  
**So that** the codebase is maintainable and type-safe

**Acceptance Criteria:**
- [ ] Define `JsonNode` structure (type, parent, children, value)
- [ ] Define `Token` structure (type, value, position)
- [ ] Define `Session` structure (handle, file, parse tree)
- [ ] Define `ErrorInfo` structure (code, message, position)
- [ ] All structures use QUALIFIED and BASED where appropriate

**Technical Notes:**
- Use VARYING fields for strings
- Use pointers for tree navigation
- Document all fields clearly

**Priority:** P0  
**Effort:** Small  
**Dependencies:** None

---

##### E1-S5: Error Handling Framework
**As a** developer  
**I want** a consistent error handling framework  
**So that** all errors are properly detected, reported, and cleaned up

**Acceptance Criteria:**
- [ ] Define error codes (JSON001-JSON399)
- [ ] Implement `SetError()` and `GetError()` procedures
- [ ] Set indicator 35 for all errors
- [ ] Format error messages with context
- [ ] Cleanup resources on error paths

**Technical Notes:**
- Error categories: File, Parse, Query, Runtime
- Include line/column in parse errors
- Use MONITOR/ON-ERROR for internal exceptions

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E1-S4

---

##### E1-S6: String Utilities
**As a** developer  
**I want** string utility procedures  
**So that** I can efficiently manipulate strings in fixed-form RPGLE

**Acceptance Criteria:**
- [ ] `StrLen()` - Get string length
- [ ] `StrCat()` - Concatenate strings
- [ ] `StrCmp()` - Compare strings
- [ ] `StrCopy()` - Copy string
- [ ] `StrTrim()` - Trim whitespace

**Technical Notes:**
- Use VARYING fields where possible
- Handle null terminators correctly
- Optimize for common cases

**Priority:** P1  
**Effort:** Small  
**Dependencies:** None

---

##### E1-S7: Position Tracking
**As a** developer  
**I want** accurate position tracking during parsing  
**So that** error messages include line and column numbers

**Acceptance Criteria:**
- [ ] Track current line number
- [ ] Track current column number
- [ ] Update on each character read
- [ ] Handle newline characters correctly
- [ ] Provide `GetPosition()` procedure

**Technical Notes:**
- Initialize at line 1, column 1
- Increment column on each char
- Reset column and increment line on newline

**Priority:** P1  
**Effort:** Small  
**Dependencies:** E1-S2

---

##### E1-S8: Unit Test Framework Setup
**As a** developer  
**I want** a basic unit testing framework  
**So that** I can test components as I build them

**Acceptance Criteria:**
- [ ] Create test harness program
- [ ] Implement assertion procedures
- [ ] Support test case registration
- [ ] Report test results clearly
- [ ] Handle test failures gracefully

**Technical Notes:**
- Simple pass/fail reporting
- Isolate test cases
- Easy to add new tests

**Priority:** P1  
**Effort:** Small  
**Dependencies:** None

---

### Epic 2: JSON Parser Engine

**Goal:** Build a complete JSON parser that creates a navigable parse tree

**Priority:** P0 (Critical)  
**Dependencies:** E1 (Foundation Infrastructure)  
**Estimated Effort:** 3-5 days with AI assistance

#### Stories

##### E2-S1: JSON Lexer - Token Recognition
**As a** developer  
**I want** a lexer that recognizes all JSON tokens  
**So that** I can tokenize JSON input for parsing

**Acceptance Criteria:**
- [ ] Recognizes structural tokens: `{`, `}`, `[`, `]`, `:`, `,`
- [ ] Recognizes value tokens: string, number, true, false, null
- [ ] Skips whitespace (space, tab, newline, CR)
- [ ] Tracks token position (line, column)
- [ ] Returns EOF token at end of input

**Technical Notes:**
- Implement `NextToken()` procedure
- Use character-by-character scanning
- Maintain lexer state

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E1-S2, E1-S7

---

##### E2-S2: JSON Lexer - String Parsing
**As a** developer  
**I want** to parse JSON strings with escape sequences  
**So that** all valid JSON strings are correctly tokenized

**Acceptance Criteria:**
- [ ] Parses quoted strings
- [ ] Handles escape sequences: `\"`, `\\`, `\/`, `\b`, `\f`, `\n`, `\r`, `\t`
- [ ] Handles Unicode escapes: `\uXXXX`
- [ ] Detects unterminated strings
- [ ] Detects invalid escape sequences

**Technical Notes:**
- Build string incrementally
- Convert escape sequences to actual characters
- Handle Unicode code points

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E2-S1

---

##### E2-S3: JSON Lexer - Number Parsing
**As a** developer  
**I want** to parse JSON numbers  
**So that** all valid numeric formats are recognized

**Acceptance Criteria:**
- [ ] Parses integers: `123`, `-456`
- [ ] Parses decimals: `123.456`, `-0.789`
- [ ] Parses scientific notation: `1.23e10`, `4.56E-7`
- [ ] Detects invalid number formats
- [ ] Preserves numeric precision

**Technical Notes:**
- Support full JSON number spec
- Store as string to preserve precision
- Validate format during parsing

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E2-S1

---

##### E2-S4: JSON Lexer - Keyword Parsing
**As a** developer  
**I want** to parse JSON keywords (true, false, null)  
**So that** boolean and null values are recognized

**Acceptance Criteria:**
- [ ] Recognizes `true` keyword
- [ ] Recognizes `false` keyword
- [ ] Recognizes `null` keyword
- [ ] Detects invalid keywords
- [ ] Case-sensitive matching

**Technical Notes:**
- Simple string matching
- Return appropriate token type
- Error on partial matches

**Priority:** P0  
**Effort:** Small  
**Dependencies:** E2-S1

---

##### E2-S5: JSON Parser - Value Parsing
**As a** developer  
**I want** to parse any JSON value  
**So that** I can build the parse tree recursively

**Acceptance Criteria:**
- [ ] Dispatches to appropriate parser based on token
- [ ] Handles objects, arrays, and primitives
- [ ] Creates appropriate node type
- [ ] Returns node pointer
- [ ] Detects unexpected tokens

**Technical Notes:**
- Implement `ParseValue()` procedure
- Use token type to dispatch
- Recursive for nested structures

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E2-S1

---

##### E2-S6: JSON Parser - Object Parsing
**As a** developer  
**I want** to parse JSON objects  
**So that** key-value structures are correctly represented

**Acceptance Criteria:**
- [ ] Parses empty objects: `{}`
- [ ] Parses single property: `{"key": "value"}`
- [ ] Parses multiple properties with commas
- [ ] Validates key is string
- [ ] Detects missing colons, commas, or braces
- [ ] Handles nested objects

**Technical Notes:**
- Implement `ParseObject()` procedure
- Create object node with children
- Link properties as child nodes

**Priority:** P0  
**Effort:** Large  
**Dependencies:** E2-S5

---

##### E2-S7: JSON Parser - Array Parsing
**As a** developer  
**I want** to parse JSON arrays  
**So that** ordered lists are correctly represented

**Acceptance Criteria:**
- [ ] Parses empty arrays: `[]`
- [ ] Parses single element: `[1]`
- [ ] Parses multiple elements with commas
- [ ] Handles mixed types
- [ ] Detects missing commas or brackets
- [ ] Handles nested arrays

**Technical Notes:**
- Implement `ParseArray()` procedure
- Create array node with indexed children
- Maintain element order

**Priority:** P0  
**Effort:** Large  
**Dependencies:** E2-S5

---

##### E2-S8: JSON Parser - Primitive Parsing
**As a** developer  
**I want** to parse JSON primitives (string, number, boolean, null)  
**So that** leaf values are correctly stored

**Acceptance Criteria:**
- [ ] Creates string nodes
- [ ] Creates number nodes
- [ ] Creates boolean nodes
- [ ] Creates null nodes
- [ ] Stores value in node

**Technical Notes:**
- Simple node creation
- Copy token value to node
- Set appropriate node type

**Priority:** P0  
**Effort:** Small  
**Dependencies:** E2-S5

---

##### E2-S9: Parse Tree Builder
**As a** developer  
**I want** to build a complete parse tree  
**So that** the JSON structure is navigable

**Acceptance Criteria:**
- [ ] Builds parent-child-sibling structure
- [ ] Links all nodes correctly
- [ ] Maintains source positions
- [ ] Handles arbitrary nesting (100+ levels)
- [ ] Returns root node pointer

**Technical Notes:**
- Use pointer-based tree structure
- Allocate nodes from pool
- Track parent for navigation

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E2-S6, E2-S7, E2-S8

---

##### E2-S10: Parse Tree Navigation
**As a** developer  
**I want** procedures to navigate the parse tree  
**So that** I can traverse and query the structure

**Acceptance Criteria:**
- [ ] `GetChild(node, key)` - Get child by key
- [ ] `GetArrayElement(node, index)` - Get array element
- [ ] `GetChildren(node)` - Get all children
- [ ] `GetParent(node)` - Get parent node
- [ ] `GetNodeType(node)` - Get node type

**Technical Notes:**
- Follow pointer links
- Handle missing children gracefully
- Return null for not found

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E2-S9

---

##### E2-S11: JSON Syntax Error Detection
**As a** developer  
**I want** comprehensive syntax error detection  
**So that** malformed JSON is rejected with clear messages

**Acceptance Criteria:**
- [ ] Detects unexpected tokens
- [ ] Detects unterminated strings
- [ ] Detects invalid escape sequences
- [ ] Detects invalid number formats
- [ ] Detects unexpected EOF
- [ ] Provides line and column in error messages

**Technical Notes:**
- Check at each parsing step
- Use position tracking
- Format clear error messages

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E2-S1 through E2-S9

---

##### E2-S12: JSON Parser Integration Tests
**As a** developer  
**I want** comprehensive parser tests  
**So that** I can verify correct parsing of all JSON structures

**Acceptance Criteria:**
- [ ] Tests valid JSON documents (20+ cases)
- [ ] Tests invalid JSON documents (10+ cases)
- [ ] Tests edge cases (empty, large, deeply nested)
- [ ] Tests all data types
- [ ] Tests escape sequences

**Technical Notes:**
- Use test framework from E1-S8
- Include real-world JSON examples
- Test error messages

**Priority:** P1  
**Effort:** Medium  
**Dependencies:** E2-S11

---

### Epic 3: JSONPath Query Engine

**Goal:** Implement complete JSONPath specification for querying JSON structures

**Priority:** P0 (Critical)  
**Dependencies:** E2 (JSON Parser Engine)  
**Estimated Effort:** 3-5 days with AI assistance

#### Stories

##### E3-S1: JSONPath Query Parser - Root Selector
**As a** developer  
**I want** to parse the root selector `$`  
**So that** queries can reference the document root

**Acceptance Criteria:**
- [ ] Recognizes `$` as root selector
- [ ] Validates query starts with `$`
- [ ] Creates root segment
- [ ] Returns error for missing `$`

**Technical Notes:**
- First character must be `$`
- Simple validation
- Create segment structure

**Priority:** P0  
**Effort:** Small  
**Dependencies:** E1-S4

---

##### E3-S2: JSONPath Query Parser - Dot Notation
**As a** developer  
**I want** to parse dot notation (`.property`)  
**So that** object properties can be accessed

**Acceptance Criteria:**
- [ ] Parses `.key` syntax
- [ ] Handles multiple levels: `$.a.b.c`
- [ ] Validates property names
- [ ] Creates child segments

**Technical Notes:**
- Parse after `.` character
- Property name until next `.`, `[`, or end
- Create CHILD segment type

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E3-S1

---

##### E3-S3: JSONPath Query Parser - Bracket Notation
**As a** developer  
**I want** to parse bracket notation (`['property']`)  
**So that** properties with special characters can be accessed

**Acceptance Criteria:**
- [ ] Parses `['key']` syntax
- [ ] Parses `["key"]` syntax
- [ ] Handles escaped quotes in keys
- [ ] Creates child segments

**Technical Notes:**
- Parse between `[` and `]`
- Handle both single and double quotes
- Equivalent to dot notation

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E3-S1

---

##### E3-S4: JSONPath Query Parser - Array Indexing
**As a** developer  
**I want** to parse array indexing (`[0]`, `[-1]`)  
**So that** array elements can be accessed by position

**Acceptance Criteria:**
- [ ] Parses positive indices: `[0]`, `[5]`
- [ ] Parses negative indices: `[-1]`, `[-5]`
- [ ] Validates index is integer
- [ ] Creates INDEX segment

**Technical Notes:**
- Parse number between `[` and `]`
- Negative indices count from end
- Create INDEX segment with index value

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E3-S1

---

##### E3-S5: JSONPath Query Parser - Array Slicing
**As a** developer  
**I want** to parse array slicing (`[start:end:step]`)  
**So that** array ranges can be selected

**Acceptance Criteria:**
- [ ] Parses `[start:end]` syntax
- [ ] Parses `[start:end:step]` syntax
- [ ] Handles omitted values: `[:5]`, `[2:]`, `[::2]`
- [ ] Validates slice parameters
- [ ] Creates SLICE segment

**Technical Notes:**
- Parse colon-separated values
- Default: start=0, end=length, step=1
- Create SLICE segment with parameters

**Priority:** P0  
**Effort:** Large  
**Dependencies:** E3-S4

---

##### E3-S6: JSONPath Query Parser - Wildcards
**As a** developer  
**I want** to parse wildcard selectors (`*`)  
**So that** all children can be selected

**Acceptance Criteria:**
- [ ] Parses `.*` syntax
- [ ] Parses `[*]` syntax
- [ ] Creates WILDCARD segment
- [ ] Works with objects and arrays

**Technical Notes:**
- Recognize `*` character
- Create WILDCARD segment
- Evaluator returns all children

**Priority:** P0  
**Effort:** Small  
**Dependencies:** E3-S2

---

##### E3-S7: JSONPath Query Parser - Recursive Descent
**As a** developer  
**I want** to parse recursive descent (`..`)  
**So that** all descendants can be searched

**Acceptance Criteria:**
- [ ] Parses `..key` syntax
- [ ] Parses `..[*]` syntax
- [ ] Creates RECURSIVE segment
- [ ] Searches entire subtree

**Technical Notes:**
- Recognize `..` sequence
- Create RECURSIVE segment
- Evaluator does depth-first search

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E3-S2

---

##### E3-S8: JSONPath Query Parser - Filter Expressions
**As a** developer  
**I want** to parse filter expressions (`[?(@.price < 10)]`)  
**So that** conditional selection is possible

**Acceptance Criteria:**
- [ ] Parses `[?(...)]` syntax
- [ ] Recognizes `@` (current node)
- [ ] Parses comparison operators: `==`, `!=`, `<`, `<=`, `>`, `>=`
- [ ] Parses boolean operators: `&&`, `||`, `!`
- [ ] Creates FILTER segment with expression tree

**Technical Notes:**
- Complex parsing with operator precedence
- Build expression tree
- Support nested property access

**Priority:** P0  
**Effort:** X-Large  
**Dependencies:** E3-S2

---

##### E3-S9: Query Evaluator - Basic Navigation
**As a** developer  
**I want** to evaluate basic path segments  
**So that** simple queries work correctly

**Acceptance Criteria:**
- [ ] Evaluates root selector
- [ ] Evaluates child selectors (dot and bracket)
- [ ] Evaluates array indices
- [ ] Returns matching nodes
- [ ] Handles not found gracefully

**Technical Notes:**
- Implement `EvaluateSegment()` procedure
- Use parse tree navigation
- Return node array

**Priority:** P0  
**Effort:** Large  
**Dependencies:** E3-S1, E3-S2, E3-S3, E3-S4, E2-S10

---

##### E3-S10: Query Evaluator - Array Operations
**As a** developer  
**I want** to evaluate array slicing and wildcards  
**So that** array queries work correctly

**Acceptance Criteria:**
- [ ] Evaluates array slices with start, end, step
- [ ] Handles negative indices
- [ ] Evaluates array wildcards
- [ ] Returns elements in order
- [ ] Handles out-of-bounds gracefully

**Technical Notes:**
- Implement slice logic
- Convert negative indices
- Collect matching elements

**Priority:** P0  
**Effort:** Large  
**Dependencies:** E3-S5, E3-S6, E3-S9

---

##### E3-S11: Query Evaluator - Recursive Descent
**As a** developer  
**I want** to evaluate recursive descent  
**So that** deep searches work correctly

**Acceptance Criteria:**
- [ ] Searches entire subtree
- [ ] Returns all matching descendants
- [ ] Maintains document order
- [ ] Handles deep nesting (100+ levels)
- [ ] Avoids infinite loops

**Technical Notes:**
- Implement depth-first search
- Use recursion or stack
- Track visited nodes if needed

**Priority:** P0  
**Effort:** Large  
**Dependencies:** E3-S7, E3-S9

---

##### E3-S12: Query Evaluator - Filter Expressions
**As a** developer  
**I want** to evaluate filter expressions  
**So that** conditional queries work correctly

**Acceptance Criteria:**
- [ ] Evaluates comparison operators
- [ ] Evaluates boolean operators
- [ ] Handles type coercion
- [ ] Supports nested property access in filters
- [ ] Returns filtered results

**Technical Notes:**
- Evaluate expression tree
- Compare values by type
- Handle missing properties

**Priority:** P0  
**Effort:** X-Large  
**Dependencies:** E3-S8, E3-S9

---

##### E3-S13: Query Result Collection
**As a** developer  
**I want** to collect query results efficiently  
**So that** large result sets are handled properly

**Acceptance Criteria:**
- [ ] Collects all matching nodes
- [ ] Maintains document order
- [ ] Handles empty results
- [ ] Handles large result sets (10,000+ items)
- [ ] Provides result count

**Technical Notes:**
- Use dynamic array or linked list
- Allocate as needed
- Track count

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E3-S9

---

##### E3-S14: Query Compilation
**As a** developer  
**I want** to compile queries into execution plans  
**So that** repeated queries are faster

**Acceptance Criteria:**
- [ ] Parses query once
- [ ] Creates optimized execution plan
- [ ] Caches compiled queries
- [ ] Reuses plans for same query
- [ ] Identifies optimization opportunities

**Technical Notes:**
- Analyze query structure
- Identify index opportunities
- Cache by query string

**Priority:** P1  
**Effort:** Large  
**Dependencies:** E3-S1 through E3-S8

---

##### E3-S15: JSONPath Integration Tests
**As a** developer  
**I want** comprehensive JSONPath tests  
**So that** all query features are verified

**Acceptance Criteria:**
- [ ] Tests all selector types (30+ cases)
- [ ] Tests filter expressions (20+ cases)
- [ ] Tests complex queries (10+ cases)
- [ ] Tests edge cases
- [ ] Tests error conditions

**Technical Notes:**
- Use standard JSONPath test suite
- Include real-world queries
- Verify result correctness

**Priority:** P1  
**Effort:** Large  
**Dependencies:** E3-S12, E3-S13

---

### Epic 4: Performance Optimization

**Goal:** Optimize performance to meet <1ms query latency requirements

**Priority:** P1 (High)  
**Dependencies:** E3 (JSONPath Query Engine)  
**Estimated Effort:** 2-3 days with AI assistance

#### Stories

##### E4-S1: Session Manager
**As a** developer  
**I want** a session manager for file contexts  
**So that** parse trees can be cached for repeated queries

**Acceptance Criteria:**
- [ ] Creates session with unique handle
- [ ] Associates file path with session
- [ ] Caches parse tree in session
- [ ] Supports multiple concurrent sessions (10+)
- [ ] Cleans up on session close

**Technical Notes:**
- Session pool with handles
- Track active sessions
- Automatic cleanup on program end

**Priority:** P0  
**Effort:** Large  
**Dependencies:** E2-S9

---

##### E4-S2: Parse Tree Caching
**As a** developer  
**I want** to cache parsed JSON structures  
**So that** repeated queries don't re-parse the file

**Acceptance Criteria:**
- [ ] Caches parse tree after first parse
- [ ] Reuses cached tree for subsequent queries
- [ ] Invalidates cache on file change (optional)
- [ ] Limits cache size
- [ ] Tracks cache hit rate

**Technical Notes:**
- Store in session structure
- Check cache before parsing
- Implement LRU eviction if needed

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E4-S1

---

##### E4-S3: Path Index Builder
**As a** developer  
**I want** to build an index of paths to nodes  
**So that** simple queries can use direct lookup

**Acceptance Criteria:**
- [ ] Builds path-to-node mapping
- [ ] Indexes all paths in tree
- [ ] Supports O(1) lookup for simple paths
- [ ] Updates on tree changes
- [ ] Reasonable memory overhead (<1x file size)

**Technical Notes:**
- Hash map of paths to nodes
- Build during or after parsing
- Store in session

**Priority:** P1  
**Effort:** Large  
**Dependencies:** E4-S2

---

##### E4-S4: Query Plan Optimization
**As a** developer  
**I want** to optimize query execution plans  
**So that** queries execute as fast as possible

**Acceptance Criteria:**
- [ ] Identifies simple paths for index lookup
- [ ] Reorders segments for efficiency
- [ ] Pushes filters down
- [ ] Caches query plans
- [ ] Measures plan effectiveness

**Technical Notes:**
- Analyze query structure
- Apply optimization rules
- Cache optimized plans

**Priority:** P1  
**Effort:** Large  
**Dependencies:** E4-S3, E3-S14

---

##### E4-S5: Memory Pooling Optimization
**As a** developer  
**I want** optimized memory pooling  
**So that** node allocation is fast

**Acceptance Criteria:**
- [ ] Pre-allocates node pool
- [ ] Reuses freed nodes
- [ ] Minimizes allocation overhead
- [ ] Tracks pool usage
- [ ] Expands pool if needed

**Technical Notes:**
- Pool size: 10,000 nodes initially
- Free list for recycling
- Measure allocation time

**Priority:** P1  
**Effort:** Medium  
**Dependencies:** E1-S3

---

##### E4-S6: Buffer Optimization
**As a** developer  
**I want** optimized buffer management  
**So that** file I/O is minimized

**Acceptance Criteria:**
- [ ] Implements read-ahead buffering
- [ ] Tunes buffer sizes for performance
- [ ] Minimizes I/O operations
- [ ] Measures I/O efficiency
- [ ] Handles large files efficiently

**Technical Notes:**
- Test different buffer sizes
- Measure I/O call count
- Optimize for common cases

**Priority:** P1  
**Effort:** Medium  
**Dependencies:** E1-S2

---

##### E4-S7: Result Set Optimization
**As a** developer  
**I want** optimized result collection  
**So that** large result sets are handled efficiently

**Acceptance Criteria:**
- [ ] Uses efficient data structure
- [ ] Minimizes memory allocations
- [ ] Supports lazy evaluation
- [ ] Handles 10,000+ results
- [ ] Measures collection time

**Technical Notes:**
- Consider linked list vs array
- Allocate in chunks
- Lazy evaluation for large sets

**Priority:** P1  
**Effort:** Medium  
**Dependencies:** E3-S13

---

##### E4-S8: Performance Benchmarking
**As a** developer  
**I want** comprehensive performance benchmarks  
**So that** I can verify performance targets are met

**Acceptance Criteria:**
- [ ] Benchmarks 5 scenarios from PRD
- [ ] Measures first-byte latency
- [ ] Measures cached query latency
- [ ] Measures throughput
- [ ] Documents results

**Technical Notes:**
- Use high-resolution timer
- Run multiple iterations
- Report P50, P99, P99.9

**Priority:** P1  
**Effort:** Medium  
**Dependencies:** E4-S1 through E4-S7

---

### Epic 5: Public API & Integration

**Goal:** Create public API and integration interface for client programs

**Priority:** P0 (Critical)  
**Dependencies:** E3 (JSONPath Engine), E4 (Optimization)  
**Estimated Effort:** 2-3 days with AI assistance

#### Stories

##### E5-S1: JSONQRY Procedure - One-Shot Query
**As a** RPG developer  
**I want** a simple procedure to query JSON files  
**So that** I can use it without managing sessions

**Acceptance Criteria:**
- [ ] Takes file path and query as input
- [ ] Returns results and count
- [ ] Sets indicator 35 on error
- [ ] Returns error message
- [ ] Cleans up automatically

**Technical Notes:**
- Wrapper around session-based API
- Creates temporary session
- Closes session after query

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E4-S1, E3-S9

---

##### E5-S2: JSONOPEN Procedure - Open Session
**As a** RPG developer  
**I want** to open a file session  
**So that** I can run multiple queries efficiently

**Acceptance Criteria:**
- [ ] Takes file path as input
- [ ] Returns session handle
- [ ] Parses file and caches tree
- [ ] Sets indicator 35 on error
- [ ] Returns error message

**Technical Notes:**
- Creates session
- Parses file immediately
- Returns handle for subsequent queries

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E4-S1

---

##### E5-S3: JSONQRYS Procedure - Query in Session
**As a** RPG developer  
**I want** to query within an open session  
**So that** repeated queries are fast

**Acceptance Criteria:**
- [ ] Takes session handle and query
- [ ] Returns results and count
- [ ] Uses cached parse tree
- [ ] Sets indicator 35 on error
- [ ] Returns error message

**Technical Notes:**
- Validates session handle
- Uses cached tree
- Optimized execution

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E5-S2, E3-S9

---

##### E5-S4: JSONCLOSE Procedure - Close Session
**As a** RPG developer  
**I want** to close a file session  
**So that** resources are released

**Acceptance Criteria:**
- [ ] Takes session handle
- [ ] Frees parse tree
- [ ] Closes file handle
- [ ] Releases session
- [ ] No error if already closed

**Technical Notes:**
- Cleanup all session resources
- Remove from session pool
- Idempotent operation

**Priority:** P0  
**Effort:** Small  
**Dependencies:** E5-S2

---

##### E5-S5: Result Data Structure Definition
**As a** RPG developer  
**I want** a well-defined result data structure  
**So that** I can easily access query results

**Acceptance Criteria:**
- [ ] Defines result array structure
- [ ] Includes value, type, path fields
- [ ] Supports up to 10,000 results
- [ ] Uses VARYING for strings
- [ ] Documented clearly

**Technical Notes:**
- QUALIFIED data structure
- DIM(10000) for array
- VARYING fields for efficiency

**Priority:** P0  
**Effort:** Small  
**Dependencies:** None

---

##### E5-S6: Parameter Validation
**As a** developer  
**I want** comprehensive parameter validation  
**So that** invalid inputs are rejected early

**Acceptance Criteria:**
- [ ] Validates file paths
- [ ] Validates query syntax
- [ ] Validates session handles
- [ ] Returns clear error messages
- [ ] Prevents crashes

**Technical Notes:**
- Check for null/empty
- Validate before processing
- Set appropriate error codes

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E5-S1, E5-S2, E5-S3

---

##### E5-S7: Result Formatting
**As a** developer  
**I want** to format results for RPGLE consumption  
**So that** results are easy to use

**Acceptance Criteria:**
- [ ] Converts nodes to string values
- [ ] Sets type indicators
- [ ] Includes JSONPath to result
- [ ] Handles truncation
- [ ] Preserves JSON structure for complex types

**Technical Notes:**
- Serialize objects/arrays to JSON strings
- Set type: S, N, B, O, A, Z
- Truncate with indicator if needed

**Priority:** P0  
**Effort:** Medium  
**Dependencies:** E5-S5, E3-S13

---

##### E5-S8: /COPY Member Creation
**As a** RPG developer  
**I want** a /COPY member with the public interface  
**So that** I can easily include it in my programs

**Acceptance Criteria:**
- [ ] Defines all public procedures
- [ ] Defines result data structure
- [ ] Defines constants
- [ ] Includes usage comments
- [ ] Compiles without errors

**Technical Notes:**
- Standard RPGLE /COPY format
- Clear procedure prototypes
- Example usage in comments

**Priority:** P0  
**Effort:** Small  
**Dependencies:** E5-S1 through E5-S7

---

##### E5-S9: Error Message Formatting
**As a** developer  
**I want** well-formatted error messages  
**So that** users can understand and fix errors

**Acceptance Criteria:**
- [ ] Includes error code
- [ ] Includes descriptive message
- [ ] Includes context (file, line, column)
- [ ] Fits in 256-character field
- [ ] Clear and actionable

**Technical Notes:**
- Format: "JSON###: message [context]"
- Truncate if needed
- Include relevant details

**Priority:** P0  
**Effort:** Small  
**Dependencies:** E1-S5

---

##### E5-S10: Integration Examples
**As a** RPG developer  
**I want** working code examples  
**So that** I can learn how to use the utility

**Acceptance Criteria:**
- [ ] Example 1: Simple one-shot query
- [ ] Example 2: Session-based multiple queries
- [ ] Example 3: Error handling
- [ ] Example 4: Complex query with filters
- [ ] Example 5: Processing results in loop
- [ ] All examples compile and run

**Technical Notes:**
- Complete working programs
- Well-commented
- Cover common use cases

**Priority:** P1  
**Effort:** Medium  
**Dependencies:** E5-S8

---

### Epic 6: Testing & Documentation

**Goal:** Comprehensive testing and documentation for production readiness

**Priority:** P1 (High)  
**Dependencies:** E5 (Public API & Integration)  
**Estimated Effort:** 2-3 days with AI assistance

#### Stories

##### E6-S1: Unit Test Suite - Foundation
**As a** developer  
**I want** unit tests for foundation components  
**So that** core functionality is verified

**Acceptance Criteria:**
- [ ] Tests file I/O operations (10+ tests)
- [ ] Tests buffer management (5+ tests)
- [ ] Tests memory allocation (5+ tests)
- [ ] Tests string utilities (10+ tests)
- [ ] All tests pass

**Technical Notes:**
- Use test framework from E1-S8
- Test normal and edge cases
- Test error conditions

**Priority:** P1  
**Effort:** Medium  
**Dependencies:** E1-S1 through E1-S7

---

##### E6-S2: Unit Test Suite - JSON Parser
**As a** developer  
**I want** unit tests for JSON parser  
**So that** parsing is verified

**Acceptance Criteria:**
- [ ] Tests valid JSON (30+ tests)
- [ ] Tests invalid JSON (20+ tests)
- [ ] Tests all data types (10+ tests)
- [ ] Tests escape sequences (10+ tests)
- [ ] Tests edge cases (10+ tests)
- [ ] All tests pass

**Technical Notes:**
- Include real-world JSON
- Test error messages
- Test deeply nested structures

**Priority:** P1  
**Effort:** Large  
**Dependencies:** E2-S12

---

##### E6-S3: Unit Test Suite - JSONPath Engine
**As a** developer  
**I want** unit tests for JSONPath engine  
**So that** query evaluation is verified

**Acceptance Criteria:**
- [ ] Tests all selector types (40+ tests)
- [ ] Tests filter expressions (30+ tests)
- [ ] Tests complex queries (20+ tests)
- [ ] Tests edge cases (10+ tests)
- [ ] All tests pass

**Technical Notes:**
- Use JSONPath test suite
- Test result correctness
- Test performance

**Priority:** P1  
**Effort:** Large  
**Dependencies:** E3-S15

---

##### E6-S4: Integration Test Suite
**As a** developer  
**I want** end-to-end integration tests  
**So that** the complete system is verified

**Acceptance Criteria:**
- [ ] Tests complete workflows (20+ tests)
- [ ] Tests session management (10+ tests)
- [ ] Tests error handling (10+ tests)
- [ ] Tests performance scenarios (5+ tests)
- [ ] All tests pass

**Technical Notes:**
- Test realistic scenarios
- Test with various file sizes
- Test concurrent sessions

**Priority:** P1  
**Effort:** Large  
**Dependencies:** E5-S1 through E5-S7

---

##### E6-S5: Performance Test Suite
**As a** developer  
**I want** performance tests  
**So that** performance targets are verified

**Acceptance Criteria:**
- [ ] Tests 5 benchmark scenarios
- [ ] Measures latency (P50, P99)
- [ ] Measures throughput
- [ ] Measures memory usage
- [ ] All targets met

**Technical Notes:**
- Use high-resolution timing
- Multiple iterations
- Document results

**Priority:** P1  
**Effort:** Medium  
**Dependencies:** E4-S8

---

##### E6-S6: Memory Leak Testing
**As a** developer  
**I want** memory leak tests  
**So that** resource leaks are detected

**Acceptance Criteria:**
- [ ] 24-hour stress test
- [ ] Monitors memory usage
- [ ] Tests all code paths
- [ ] Tests error paths
- [ ] Zero leaks detected

**Technical Notes:**
- Run continuous queries
- Monitor system memory
- Test cleanup on errors

**Priority:** P1  
**Effort:** Medium  
**Dependencies:** E6-S4

---

##### E6-S7: API Reference Documentation
**As a** RPG developer  
**I want** complete API documentation  
**So that** I know how to use all features

**Acceptance Criteria:**
- [ ] Documents all procedures
- [ ] Documents all parameters
- [ ] Documents all error codes
- [ ] Includes examples
- [ ] Clear and complete

**Technical Notes:**
- Standard format
- Include code examples
- Cross-reference related items

**Priority:** P1  
**Effort:** Medium  
**Dependencies:** E5-S8

---

##### E6-S8: Usage Guide
**As a** RPG developer  
**I want** a usage guide  
**So that** I can learn how to use the utility

**Acceptance Criteria:**
- [ ] Getting started section
- [ ] Common use cases
- [ ] Best practices
- [ ] Troubleshooting guide
- [ ] Performance tips

**Technical Notes:**
- Tutorial style
- Progressive complexity
- Real-world examples

**Priority:** P1  
**Effort:** Medium  
**Dependencies:** E5-S10

---

##### E6-S9: JSONPath Reference
**As a** RPG developer  
**I want** a JSONPath reference  
**So that** I can write correct queries

**Acceptance Criteria:**
- [ ] Explains all selector types
- [ ] Explains filter expressions
- [ ] Includes examples for each
- [ ] Includes tips and tricks
- [ ] Easy to reference

**Technical Notes:**
- Quick reference format
- Lots of examples
- Common patterns

**Priority:** P1  
**Effort:** Small  
**Dependencies:** E3-S15

---

##### E6-S10: Error Code Reference
**As a** RPG developer  
**I want** an error code reference  
**So that** I can understand and fix errors

**Acceptance Criteria:**
- [ ] Lists all error codes
- [ ] Explains each error
- [ ] Provides solutions
- [ ] Includes examples
- [ ] Easy to search

**Technical Notes:**
- Organized by category
- Clear explanations
- Actionable solutions

**Priority:** P1  
**Effort:** Small  
**Dependencies:** E1-S5, E5-S9

---

##### E6-S11: Performance Tuning Guide
**As a** RPG developer  
**I want** a performance tuning guide  
**So that** I can optimize my usage

**Acceptance Criteria:**
- [ ] Explains session management
- [ ] Explains query optimization
- [ ] Provides benchmarks
- [ ] Includes best practices
- [ ] Includes anti-patterns

**Technical Notes:**
- Based on actual measurements
- Practical advice
- Real-world scenarios

**Priority:** P1  
**Effort:** Medium  
**Dependencies:** E4-S8, E6-S5

---

##### E6-S12: Release Checklist Verification
**As a** project manager  
**I want** to verify all release criteria  
**So that** the product is ready for release

**Acceptance Criteria:**
- [ ] All P0 stories complete
- [ ] All tests passing
- [ ] Performance targets met
- [ ] Documentation complete
- [ ] No critical bugs
- [ ] Code review passed

**Technical Notes:**
- Review acceptance criteria from PRD
- Verify each item
- Document any exceptions

**Priority:** P0  
**Effort:** Small  
**Dependencies:** All previous stories

---

## Story Dependencies

### Dependency Graph

```
E1: Foundation Infrastructure
├─ E1-S1 → E1-S2 → E1-S7
├─ E1-S3 → E4-S5
├─ E1-S4 → E1-S5
├─ E1-S6 (independent)
└─ E1-S8 (independent)

E2: JSON Parser Engine (depends on E1)
├─ E2-S1 → E2-S2, E2-S3, E2-S4
├─ E2-S5 → E2-S6, E2-S7, E2-S8
├─ E2-S9 → E2-S10
├─ E2-S11 (depends on E2-S1 through E2-S9)
└─ E2-S12 (depends on E2-S11)

E3: JSONPath Query Engine (depends on E2)
├─ E3-S1 → E3-S2, E3-S3, E3-S4, E3-S5, E3-S6, E3-S7, E3-S8
├─ E3-S9 → E3-S10, E3-S11, E3-S12, E3-S13
├─ E3-S14 (depends on E3-S1 through E3-S8)
└─ E3-S15 (depends on E3-S12, E3-S13)

E4: Performance Optimization (depends on E3)
├─ E4-S1 → E4-S2 → E4-S3 → E4-S4
├─ E4-S5 (depends on E1-S3)
├─ E4-S6 (depends on E1-S2)
├─ E4-S7 (depends on E3-S13)
└─ E4-S8 (depends on E4-S1 through E4-S7)

E5: Public API & Integration (depends on E3, E4)
├─ E5-S1, E5-S2, E5-S3, E5-S4 (session management)
├─ E5-S5 → E5-S7
├─ E5-S6 (depends on E5-S1, E5-S2, E5-S3)
├─ E5-S8 (depends on E5-S1 through E5-S7)
├─ E5-S9 (depends on E1-S5)
└─ E5-S10 (depends on E5-S8)

E6: Testing & Documentation (depends on E5)
├─ E6-S1 (depends on E1)
├─ E6-S2 (depends on E2-S12)
├─ E6-S3 (depends on E3-S15)
├─ E6-S4 (depends on E5)
├─ E6-S5 (depends on E4-S8)
├─ E6-S6 (depends on E6-S4)
├─ E6-S7 through E6-S11 (documentation)
└─ E6-S12 (depends on all)
```

---

## Story Prioritization

### Priority Levels

- **P0 (Critical):** Must have for MVP, blocks other work
- **P1 (High):** Important for quality and usability
- **P2 (Medium):** Nice to have, can be deferred
- **P3 (Low):** Future enhancement

### Priority Breakdown

| Priority | Stories | Percentage |
|----------|---------|------------|
| P0 | 42 | 65% |
| P1 | 23 | 35% |
| P2 | 0 | 0% |
| P3 | 0 | 0% |

### Critical Path (P0 Stories)

1. **Foundation (E1):** S1, S2, S3, S4, S5 (5 stories)
2. **Parser (E2):** S1-S11 (11 stories)
3. **JSONPath (E3):** S1-S13 (13 stories)
4. **Optimization (E4):** S1, S2 (2 stories)
5. **API (E5):** S1-S9 (9 stories)
6. **Testing (E6):** S12 (1 story)

**Total Critical Path:** 41 stories

---

## Implementation Sequence

### Phase 1: Foundation (Days 1-3)
**Goal:** Build core infrastructure

**Stories:**
1. E1-S1: IFS File Stream Reader
2. E1-S2: Buffer Management System
3. E1-S3: Memory Allocation Framework
4. E1-S4: Core Data Structures
5. E1-S5: Error Handling Framework
6. E1-S7: Position Tracking
7. E1-S8: Unit Test Framework Setup

**Deliverables:**
- Working file I/O
- Memory management
- Error handling
- Test framework

**Success Criteria:**
- Can read 100MB file
- Memory stable
- Tests passing

---

### Phase 2: JSON Parser (Days 4-8)
**Goal:** Complete JSON parsing capability

**Stories:**
1. E2-S1: JSON Lexer - Token Recognition
2. E2-S2: JSON Lexer - String Parsing
3. E2-S3: JSON Lexer - Number Parsing
4. E2-S4: JSON Lexer - Keyword Parsing
5. E2-S5: JSON Parser - Value Parsing
6. E2-S6: JSON Parser - Object Parsing
7. E2-S7: JSON Parser - Array Parsing
8. E2-S8: JSON Parser - Primitive Parsing
9. E2-S9: Parse Tree Builder
10. E2-S10: Parse Tree Navigation
11. E2-S11: JSON Syntax Error Detection
12. E2-S12: JSON Parser Integration Tests

**Deliverables:**
- Complete JSON parser
- Parse tree structure
- Error detection
- Parser tests

**Success Criteria:**
- Parses all valid JSON
- Detects syntax errors
- Tests passing

---

### Phase 3: JSONPath Engine (Days 9-13)
**Goal:** Complete JSONPath query capability

**Stories:**
1. E3-S1: JSONPath Query Parser - Root Selector
2. E3-S2: JSONPath Query Parser - Dot Notation
3. E3-S3: JSONPath Query Parser - Bracket Notation
4. E3-S4: JSONPath Query Parser - Array Indexing
5. E3-S5: JSONPath Query Parser - Array Slicing
6. E3-S6: JSONPath Query Parser - Wildcards
7. E3-S7: JSONPath Query Parser - Recursive Descent
8. E3-S8: JSONPath Query Parser - Filter Expressions
9. E3-S9: Query Evaluator - Basic Navigation
10. E3-S10: Query Evaluator - Array Operations
11. E3-S11: Query Evaluator - Recursive Descent
12. E3-S12: Query Evaluator - Filter Expressions
13. E3-S13: Query Result Collection
14. E3-S14: Query Compilation
15. E3-S15: JSONPath Integration Tests

**Deliverables:**
- Complete JSONPath engine
- All query features
- Query tests

**Success Criteria:**
- All JSONPath features work
- Tests passing
- Correct results

---

### Phase 4: Optimization (Days 14-16)
**Goal:** Meet performance requirements

**Stories:**
1. E4-S1: Session Manager
2. E4-S2: Parse Tree Caching
3. E4-S3: Path Index Builder
4. E4-S4: Query Plan Optimization
5. E4-S5: Memory Pooling Optimization
6. E4-S6: Buffer Optimization
7. E4-S7: Result Set Optimization
8. E4-S8: Performance Benchmarking

**Deliverables:**
- Session management
- Caching system
- Performance optimizations
- Benchmarks

**Success Criteria:**
- <1ms first query (P99)
- <0.1ms cached query (P99)
- Benchmarks documented

---

### Phase 5: Public API (Days 17-19)
**Goal:** Create usable public interface

**Stories:**
1. E5-S1: JSONQRY Procedure
2. E5-S2: JSONOPEN Procedure
3. E5-S3: JSONQRYS Procedure
4. E5-S4: JSONCLOSE Procedure
5. E5-S5: Result Data Structure Definition
6. E5-S6: Parameter Validation
7. E5-S7: Result Formatting
8. E5-S8: /COPY Member Creation
9. E5-S9: Error Message Formatting
10. E5-S10: Integration Examples

**Deliverables:**
- Complete public API
- /COPY member
- Examples

**Success Criteria:**
- API works correctly
- Examples compile and run
- Easy to use

---

### Phase 6: Testing & Documentation (Days 20-22)
**Goal:** Production readiness

**Stories:**
1. E6-S1: Unit Test Suite - Foundation
2. E6-S2: Unit Test Suite - JSON Parser
3. E6-S3: Unit Test Suite - JSONPath Engine
4. E6-S4: Integration Test Suite
5. E6-S5: Performance Test Suite
6. E6-S6: Memory Leak Testing
7. E6-S7: API Reference Documentation
8. E6-S8: Usage Guide
9. E6-S9: JSONPath Reference
10. E6-S10: Error Code Reference
11. E6-S11: Performance Tuning Guide
12. E6-S12: Release Checklist Verification

**Deliverables:**
- Complete test suite
- Full documentation
- Release verification

**Success Criteria:**
- All tests passing
- No memory leaks
- Documentation complete
- Ready for release

---

## Story Estimation Summary

### By Epic

| Epic | Stories | P0 Stories | P1 Stories | Total Effort |
|------|---------|------------|------------|--------------|
| E1 | 8 | 5 | 3 | 2-3 days |
| E2 | 12 | 11 | 1 | 3-5 days |
| E3 | 15 | 13 | 2 | 3-5 days |
| E4 | 8 | 2 | 6 | 2-3 days |
| E5 | 10 | 9 | 1 | 2-3 days |
| E6 | 12 | 1 | 11 | 2-3 days |
| **Total** | **65** | **41** | **24** | **14-22 days** |

### By Effort Size

| Size | Stories | Percentage |
|------|---------|------------|
| Small | 15 | 23% |
| Medium | 30 | 46% |
| Large | 17 | 26% |
| X-Large | 3 | 5% |

---

## Notes

### AI-Assisted Development Assumptions

These estimates assume:
- **Active collaboration:** Daily work sessions with AI
- **Quick iteration:** Fast feedback and refinement cycles
- **Testing access:** Ability to test on OS/400 v7.5
- **RPGLE familiarity:** Understanding of fixed-form RPGLE

### Adjustment Factors

Estimates may vary based on:
- **Experience level:** More experienced = faster
- **Testing availability:** Limited testing = slower
- **Complexity discoveries:** Unexpected challenges = slower
- **Scope changes:** Additional requirements = more time

### Success Factors

For successful implementation:
1. **STRICT Fixed-Form:** ALL logic must use traditional column-based C-specs; NO /FREE or /END-FREE permitted.
2. **Clear requirements:** Well-defined acceptance criteria
3. **Incremental progress:** Complete stories one at a time
4. **Continuous testing:** Test as you build
5. **Regular validation:** Verify on target platform
6. **Documentation:** Document as you go

---

**END OF DOCUMENT**