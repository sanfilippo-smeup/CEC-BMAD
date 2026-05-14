# Technical Architecture Document
# RPGLE-Json Query Utility

**Project Name:** RPGLE-Json  
**Version:** 1.0  
**Date:** 2026-04-28  
**Author:** Mauro  
**Status:** Draft  
**Related Documents:** [Product Brief](product-brief.md) | [PRD](prd.md)

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [System Architecture](#system-architecture)
3. [Component Design](#component-design)
4. [Data Structures](#data-structures)
5. [Algorithms](#algorithms)
6. [Performance Optimization](#performance-optimization)
7. [Memory Management](#memory-management)
8. [Error Handling Strategy](#error-handling-strategy)
9. [Technical Decisions](#technical-decisions)
10. [Implementation Phases](#implementation-phases)

---

## Architecture Overview

### Design Philosophy

The RPGLE-Json architecture follows these core principles:

1. **Streaming-First:** Process JSON incrementally to handle large files efficiently
2. **Stateful Sessions:** Cache parsed structures for repeated queries
3. **Modular Design:** Separate concerns into distinct, testable components
4. **Fixed-Form Compatible:** Use only fixed-form RPGLE constructs
5. **Zero Dependencies:** Implement all functionality natively

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Client RPGLE Program                    │
│                    (Uses /COPY JSONQRY)                     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Public API Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  JSONQRY     │  │  JSONOPEN    │  │  JSONCLOSE   │       │
│  │  (One-shot)  │  │  (Session)   │  │  (Session)   │       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│                   Session Manager                           │
│  • File session lifecycle                                   │
│  • Parse tree caching                                       │
│  • Resource cleanup                                         │
└────────────────────────┬────────────────────────────────────┘
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   File I/O  │  │JSON Parser  │  │JSONPath     │
│   Manager   │  │   Engine    │  │  Engine     │
└─────────────┘  └─────────────┘  └─────────────┘
      │                 │                 │
      ▼                 ▼                 ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│IFS Stream   │  │Parse Tree   │  │Query        │
│Reader       │  │Builder      │  │Evaluator    │
└─────────────┘  └─────────────┘  └─────────────┘
```

---

## System Architecture

### Component Layers

#### Layer 1: Public API
**Purpose:** Provide simple, documented interface for client programs

**Components:**
- `JSONQRY` - Single-query interface
- `JSONOPEN` - Open file session
- `JSONQRYS` - Query within session
- `JSONCLOSE` - Close file session

**Responsibilities:**
- Parameter validation
- Error indicator management
- Result formatting
- Session handle management

---

#### Layer 2: Session Manager
**Purpose:** Manage file sessions and cached parse trees

**Components:**
- Session lifecycle controller
- Parse tree cache
- Resource tracker

**Responsibilities:**
- Create/destroy sessions
- Cache parsed JSON structures
- Track open file handles
- Cleanup on errors or completion

---

#### Layer 3: Core Engines

##### File I/O Manager
**Purpose:** Handle IFS file operations efficiently

**Components:**
- Stream reader
- Buffer manager
- File handle pool

**Responsibilities:**
- Open/close IFS files
- Streaming read operations
- Buffer management
- Read-ahead optimization

##### JSON Parser Engine
**Purpose:** Parse JSON into navigable structure

**Components:**
- Lexer (tokenizer)
- Parser (structure builder)
- Parse tree builder

**Responsibilities:**
- Tokenize JSON input
- Build parse tree
- Validate JSON syntax
- Track source positions

##### JSONPath Engine
**Purpose:** Execute JSONPath queries on parse tree

**Components:**
- Query parser
- Query compiler
- Query evaluator
- Filter processor

**Responsibilities:**
- Parse JSONPath expressions
- Compile to execution plan
- Evaluate queries
- Process filter expressions

---

## Component Design

### 1. File I/O Manager

#### Stream Reader

```rpgle
     D StreamReader    DS                  QUALIFIED
     D  FileHandle                   10I 0
     D  FilePath                   1024A   VARYING
     D  FileSize                     20I 0
     D  CurrentPos                   20I 0
     D  Buffer                    32766A
     D  BufferSize                   10I 0
     D  BufferPos                    10I 0
     D  BufferLen                    10I 0
     D  EOF                           1N
```

**Key Operations:**
- `OpenStream(FilePath)` - Open file for streaming
- `ReadChunk()` - Read next buffer chunk
- `PeekChar()` - Look ahead without consuming
- `ReadChar()` - Read and consume next character
- `CloseStream()` - Close file and cleanup

**Algorithm:**
```
OpenStream(FilePath):
  1. Validate file path
  2. Check file exists and readable
  3. Get file size
  4. Open file handle
  5. Initialize buffer
  6. Read first chunk
  
ReadChar():
  1. If buffer exhausted:
     a. Read next chunk
     b. If EOF, return EOF marker
  2. Get char at buffer position
  3. Increment buffer position
  4. Return character
```

---

### 2. JSON Parser Engine

#### Lexer (Tokenizer)

```rpgle
     D Token           DS                  QUALIFIED
     D  Type                          1A
     D  Value                     32766A   VARYING
     D  Line                         10I 0
     D  Column                       10I 0
     
     D TokenType       C                   CONST
     D  TK_LBRACE      C                   '{'
     D  TK_RBRACE      C                   '}'
     D  TK_LBRACKET    C                   '['
     D  TK_RBRACKET    C                   ']'
     D  TK_COLON       C                   ':'
     D  TK_COMMA       C                   ','
     D  TK_STRING      C                   'S'
     D  TK_NUMBER      C                   'N'
     D  TK_TRUE        C                   'T'
     D  TK_FALSE       C                   'F'
     D  TK_NULL        C                   'Z'
     D  TK_EOF         C                   'E'
```

**Key Operations:**
- `NextToken()` - Get next token from stream
- `ParseString()` - Parse JSON string with escapes
- `ParseNumber()` - Parse numeric value
- `ParseKeyword()` - Parse true/false/null

**Algorithm:**
```
NextToken():
  1. Skip whitespace
  2. Peek next character
  3. Switch on character:
     '{' → Return LBRACE token
     '}' → Return RBRACE token
     '[' → Return LBRACKET token
     ']' → Return RBRACKET token
     ':' → Return COLON token
     ',' → Return COMMA token
     '"' → Call ParseString()
     '0'-'9', '-' → Call ParseNumber()
     't' → Call ParseKeyword('true')
     'f' → Call ParseKeyword('false')
     'n' → Call ParseKeyword('null')
     EOF → Return EOF token
     else → Error: unexpected character
```

---

#### Parser (Structure Builder)

```rpgle
     D JsonNode        DS                  QUALIFIED BASED(NodePtr)
     D  Type                          1A
     D  Parent                         *
     D  FirstChild                     *
     D  NextSibling                    *
     D  Key                        4096A   VARYING
     D  Value                     32766A   VARYING
     D  StartPos                     20I 0
     D  EndPos                       20I 0
     
     D NodeType        C                   CONST
     D  NT_OBJECT      C                   'O'
     D  NT_ARRAY       C                   'A'
     D  NT_STRING      C                   'S'
     D  NT_NUMBER      C                   'N'
     D  NT_BOOLEAN     C                   'B'
     D  NT_NULL        C                   'Z'
```

**Key Operations:**
- `ParseValue()` - Parse any JSON value
- `ParseObject()` - Parse object structure
- `ParseArray()` - Parse array structure
- `BuildParseTree()` - Build complete tree

**Algorithm:**
```
ParseValue():
  1. Get next token
  2. Switch on token type:
     LBRACE → Call ParseObject()
     LBRACKET → Call ParseArray()
     STRING → Create string node
     NUMBER → Create number node
     TRUE/FALSE → Create boolean node
     NULL → Create null node
     else → Error: unexpected token
  3. Return node pointer

ParseObject():
  1. Create object node
  2. Expect LBRACE token
  3. While next token != RBRACE:
     a. Expect STRING token (key)
     b. Expect COLON token
     c. Parse value (recursive)
     d. Add key-value pair to object
     e. If next token == COMMA, continue
     f. Else expect RBRACE
  4. Return object node

ParseArray():
  1. Create array node
  2. Expect LBRACKET token
  3. While next token != RBRACKET:
     a. Parse value (recursive)
     b. Add value to array
     c. If next token == COMMA, continue
     d. Else expect RBRACKET
  4. Return array node
```

---

### 3. JSONPath Engine

#### Query Parser

```rpgle
     D PathSegment     DS                  QUALIFIED BASED(SegPtr)
     D  Type                          1A
     D  Key                        4096A   VARYING
     D  Index                        10I 0
     D  SliceStart                   10I 0
     D  SliceEnd                     10I 0
     D  SliceStep                    10I 0
     D  Filter                         *
     D  Next                           *
     
     D SegmentType     C                   CONST
     D  SEG_ROOT       C                   'R'
     D  SEG_CHILD      C                   'C'
     D  SEG_WILDCARD   C                   'W'
     D  SEG_RECURSIVE  C                   'D'
     D  SEG_INDEX      C                   'I'
     D  SEG_SLICE      C                   'S'
     D  SEG_FILTER     C                   'F'
```

**Key Operations:**
- `ParsePath(Query)` - Parse JSONPath into segments
- `ParseSegment()` - Parse single path segment
- `ParseFilter()` - Parse filter expression
- `CompilePath()` - Optimize path for execution

**Algorithm:**
```
ParsePath(Query):
  1. Validate query starts with '$'
  2. Initialize segment list
  3. Position = 1 (after '$')
  4. While position < query length:
     a. Parse next segment
     b. Add to segment list
     c. Advance position
  5. Return segment list

ParseSegment():
  1. Peek next character
  2. Switch on character:
     '.' → Parse child or recursive descent
     '[' → Parse bracket notation
     '*' → Create wildcard segment
     else → Error: invalid syntax
  3. Return segment

ParseBracketNotation():
  1. Expect '['
  2. Peek next character:
     '*' → Wildcard
     '?' → Filter expression
     '-' or digit → Index or slice
     '\'' or '"' → Key name
  3. Parse accordingly
  4. Expect ']'
  5. Return segment
```

---

#### Query Evaluator

```rpgle
     D QueryContext    DS                  QUALIFIED
     D  RootNode                       *
     D  CurrentNode                    *
     D  Results                        *   DIM(10000)
     D  ResultCount                  10I 0
     D  MaxResults                   10I 0
```

**Key Operations:**
- `EvaluatePath(Root, Path)` - Execute query
- `EvaluateSegment(Node, Segment)` - Process one segment
- `EvaluateFilter(Node, Filter)` - Apply filter
- `CollectResults()` - Gather matching nodes

**Algorithm:**
```
EvaluatePath(Root, Path):
  1. Initialize context with root node
  2. Initialize result set
  3. For each segment in path:
     a. Get current node set
     b. For each node in set:
        i. Evaluate segment on node
        ii. Add matches to new node set
     c. Replace current set with new set
  4. Collect final results
  5. Return results

EvaluateSegment(Node, Segment):
  1. Switch on segment type:
     CHILD → Get child by key
     WILDCARD → Get all children
     RECURSIVE → Get all descendants
     INDEX → Get array element
     SLICE → Get array slice
     FILTER → Apply filter expression
  2. Return matching nodes

EvaluateFilter(Node, Filter):
  1. Parse filter expression
  2. Evaluate left operand
  3. Evaluate operator
  4. Evaluate right operand
  5. Apply comparison
  6. Return boolean result
```

---

### 4. Session Manager

```rpgle
     D Session         DS                  QUALIFIED BASED(SessPtr)
     D  Handle                       10I 0
     D  FilePath                   1024A   VARYING
     D  FileHandle                   10I 0
     D  ParseTree                      *
     D  OpenTime                      8A
     D  QueryCount                   10I 0
     D  Active                        1N
     
     D SessionPool     DS                  QUALIFIED
     D  Sessions                       *   DIM(10)
     D  Count                        10I 0
     D  NextHandle                   10I 0
```

**Key Operations:**
- `CreateSession(FilePath)` - Create new session
- `GetSession(Handle)` - Retrieve session
- `CloseSession(Handle)` - Close and cleanup
- `CleanupAll()` - Emergency cleanup

**Algorithm:**
```
CreateSession(FilePath):
  1. Check session pool not full
  2. Allocate session structure
  3. Generate unique handle
  4. Open file stream
  5. Parse JSON into tree
  6. Cache parse tree
  7. Add to session pool
  8. Return handle

GetSession(Handle):
  1. Search session pool
  2. Validate handle exists
  3. Validate session active
  4. Return session pointer

CloseSession(Handle):
  1. Get session by handle
  2. Close file stream
  3. Free parse tree
  4. Free session structure
  5. Remove from pool
```

---

## Data Structures

### Parse Tree Structure

The parse tree uses a parent-child-sibling structure for memory efficiency:

```
Object: { "name": "John", "age": 30, "active": true }

Tree Structure:
┌─────────────┐
│ ROOT (Obj)  │
└──────┬──────┘
       │
       ├─→ ┌──────────────┐
       │   │ "name" (Str) │
       │   │ Value: "John"│
       │   └──────────────┘
       │
       ├─→ ┌──────────────┐
       │   │ "age" (Num)  │
       │   │ Value: "30"  │
       │   └──────────────┘
       │
       └─→ ┌──────────────┐
           │"active"(Bool)│
           │ Value: "true"│
           └──────────────┘

Array: ["a", "b", "c"]

Tree Structure:
┌─────────────┐
│ ROOT (Arr)  │
└──────┬──────┘
       │
       ├─→ ┌──────────────┐
       │   │ [0] (String) │
       │   │ Value: "a"   │
       │   └──────────────┘
       │
       ├─→ ┌──────────────┐
       │   │ [1] (String) │
       │   │ Value: "b"   │
       │   └──────────────┘
       │
       └─→ ┌──────────────┐
           │ [2] (String) │
           │ Value: "c"   │
           └──────────────┘
```

### Memory Layout

```rpgle
     D JsonNode        DS                  QUALIFIED BASED(NodePtr)
     D  Type                          1A   Node type indicator
     D  Parent                         *   Pointer to parent node
     D  FirstChild                     *   Pointer to first child
     D  NextSibling                    *   Pointer to next sibling
     D  Key                        4096A   VARYING (for object properties)
     D  Value                     32766A   VARYING (for primitives)
     D  StartPos                     20I 0 Source position (start)
     D  EndPos                       20I 0 Source position (end)
```

**Size per node:** ~41KB (with varying fields)
**Estimated nodes for 1MB JSON:** ~500-1000 nodes
**Memory for 1MB JSON:** ~20-40MB parse tree

---

## Algorithms

### 1. Streaming JSON Parser

**Challenge:** Parse JSON without loading entire file into memory

**Solution:** Token-based streaming parser with minimal lookahead

```
Algorithm: StreamingParse(FileStream)
Input: FileStream - Open file stream
Output: ParseTree - Root node of parse tree

1. Initialize lexer with file stream
2. Initialize parser state stack
3. Root = ParseValue()
4. If not EOF:
   Error: Extra content after JSON
5. Return Root

ParseValue():
1. Token = NextToken()
2. Switch Token.Type:
   LBRACE:
     Return ParseObject()
   LBRACKET:
     Return ParseArray()
   STRING, NUMBER, TRUE, FALSE, NULL:
     Node = CreateNode(Token)
     Return Node
   else:
     Error: Unexpected token
     
ParseObject():
1. Node = CreateNode(OBJECT)
2. Expect(LBRACE)
3. If Peek() == RBRACE:
   Consume(RBRACE)
   Return Node
4. Loop:
   a. KeyToken = Expect(STRING)
   b. Expect(COLON)
   c. Value = ParseValue()
   d. AddChild(Node, KeyToken.Value, Value)
   e. Token = NextToken()
   f. If Token == RBRACE:
      Break
   g. If Token != COMMA:
      Error: Expected comma or close brace
5. Return Node

ParseArray():
1. Node = CreateNode(ARRAY)
2. Expect(LBRACKET)
3. If Peek() == RBRACKET:
   Consume(RBRACKET)
   Return Node
4. Index = 0
5. Loop:
   a. Value = ParseValue()
   b. AddChild(Node, Index, Value)
   c. Index++
   d. Token = NextToken()
   e. If Token == RBRACKET:
      Break
   f. If Token != COMMA:
      Error: Expected comma or close bracket
6. Return Node
```

**Complexity:**
- Time: O(n) where n = file size
- Space: O(d) where d = maximum nesting depth
- Memory: O(m) where m = number of nodes in tree

---

### 2. JSONPath Query Evaluation

**Challenge:** Efficiently evaluate complex JSONPath queries

**Solution:** Segment-by-segment evaluation with result set propagation

```
Algorithm: EvaluateQuery(Root, Query)
Input: Root - Parse tree root
       Query - JSONPath query string
Output: Results - Array of matching nodes

1. Segments = ParseQuery(Query)
2. CurrentSet = [Root]
3. For each Segment in Segments:
   a. NextSet = []
   b. For each Node in CurrentSet:
      i. Matches = EvaluateSegment(Node, Segment)
      ii. Add Matches to NextSet
   c. CurrentSet = NextSet
4. Return CurrentSet

EvaluateSegment(Node, Segment):
1. Switch Segment.Type:
   CHILD:
     Return GetChild(Node, Segment.Key)
   WILDCARD:
     Return GetAllChildren(Node)
   RECURSIVE:
     Return GetAllDescendants(Node, Segment.Key)
   INDEX:
     Return GetArrayElement(Node, Segment.Index)
   SLICE:
     Return GetArraySlice(Node, Segment.Slice)
   FILTER:
     Return ApplyFilter(Node, Segment.Filter)

GetAllDescendants(Node, Key):
1. Results = []
2. If Node matches Key:
   Add Node to Results
3. For each Child of Node:
   a. ChildResults = GetAllDescendants(Child, Key)
   b. Add ChildResults to Results
4. Return Results

ApplyFilter(Node, Filter):
1. Results = []
2. For each Child of Node:
   a. If EvaluateFilterExpression(Child, Filter):
      Add Child to Results
3. Return Results

EvaluateFilterExpression(Node, Filter):
1. Left = EvaluateOperand(Node, Filter.Left)
2. Right = EvaluateOperand(Node, Filter.Right)
3. Return ApplyOperator(Left, Filter.Operator, Right)
```

**Complexity:**
- Time: O(n * s) where n = nodes, s = segments
- Space: O(r) where r = result set size
- Worst case: O(n²) for recursive descent with filters

---

### 3. Query Optimization

**Challenge:** Repeated queries on same file should be fast

**Solution:** Multi-level caching and indexing

```
Algorithm: OptimizedQuery(SessionHandle, Query)
Input: SessionHandle - Open session
       Query - JSONPath query
Output: Results - Matching nodes

1. Session = GetSession(SessionHandle)
2. If Query in Session.QueryCache:
   Return Session.QueryCache[Query]
3. If Session.ParseTree == NULL:
   Session.ParseTree = ParseFile(Session.FilePath)
4. If Session.Index == NULL:
   Session.Index = BuildIndex(Session.ParseTree)
5. Results = EvaluateWithIndex(Session.ParseTree, 
                                Session.Index, 
                                Query)
6. Session.QueryCache[Query] = Results
7. Return Results

BuildIndex(Root):
1. Index = CreateHashMap()
2. For each Node in PreOrderTraversal(Root):
   a. Path = GetNodePath(Node)
   b. Index[Path] = Node
   c. If Node.Type == OBJECT:
      For each Key in Node:
        Index[Path + "." + Key] = Node.Child[Key]
3. Return Index

EvaluateWithIndex(Root, Index, Query):
1. If Query is simple path (no wildcards/filters):
   a. If Query in Index:
      Return [Index[Query]]
   b. Return []
2. Else:
   Return EvaluateQuery(Root, Query)
```

**Performance Impact:**
- First query: Parse + Index + Evaluate = ~100ms
- Cached query: Index lookup = ~0.01ms
- Complex query: Index-assisted = ~1-10ms

---

## Performance Optimization

### 1. Buffer Management

**Strategy:** Use read-ahead buffering to minimize I/O operations

```rpgle
     D BufferConfig    DS                  QUALIFIED
     D  BufferSize                   10I 0 INZ(4096)
     D  ReadAhead                    10I 0 INZ(8192)
     D  MinRefill                    10I 0 INZ(1024)
```

**Algorithm:**
```
ReadChar():
1. If BufferPos >= BufferLen - MinRefill:
   a. If not EOF:
      i. Shift remaining bytes to start
      ii. Read ReadAhead bytes
      iii. Update BufferLen
2. Char = Buffer[BufferPos]
3. BufferPos++
4. Return Char
```

**Impact:** Reduces I/O calls by 75-90%

---

### 2. Memory Pooling

**Strategy:** Pre-allocate node pools to reduce allocation overhead

```rpgle
     D NodePool        DS                  QUALIFIED
     D  Nodes                          *   DIM(10000)
     D  FreeList                       *
     D  AllocCount                   10I 0
     D  FreeCount                    10I 0
```

**Algorithm:**
```
AllocateNode():
1. If FreeList not empty:
   a. Node = Pop(FreeList)
   b. Clear(Node)
   c. Return Node
2. If AllocCount < PoolSize:
   a. Node = Pool[AllocCount]
   b. AllocCount++
   c. Return Node
3. Node = SystemAlloc()
4. Return Node

FreeNode(Node):
1. Clear(Node)
2. Push(FreeList, Node)
3. FreeCount++
```

**Impact:** 50-70% faster node allocation

---

### 3. Query Compilation

**Strategy:** Compile JSONPath queries to optimized execution plans

```rpgle
     D QueryPlan       DS                  QUALIFIED
     D  Segments                       *   DIM(100)
     D  SegmentCount                 10I 0
     D  UseIndex                      1N
     D  IndexKey                   4096A   VARYING
     D  Complexity                   10I 0
```

**Optimization Rules:**
1. Simple paths → Direct index lookup
2. Wildcards at end → Partial index + scan
3. Filters → Index + filter application
4. Recursive descent → Full tree scan (cache results)

**Impact:** 10-100x faster for repeated queries

---

### 4. Result Set Optimization

**Strategy:** Use lazy evaluation for large result sets

```rpgle
     D ResultSet       DS                  QUALIFIED
     D  Nodes                          *   DIM(10000)
     D  Count                        10I 0
     D  Capacity                     10I 0
     D  Materialized                  1N
```

**Algorithm:**
```
GetResults():
1. If not Materialized:
   a. For each Node in LazyIterator:
      i. If Count >= Capacity:
         Expand capacity
      ii. Results[Count] = Node
      iii. Count++
   b. Materialized = True
2. Return Results[0..Count]
```

**Impact:** Faster for queries returning few results

---

## Memory Management

### Memory Budget

| Component | Budget | Notes |
|-----------|--------|-------|
| Parser State | 2MB | Lexer + parser stack |
| Node Pool | 50MB | Pre-allocated nodes |
| Parse Tree | 2x file size | Actual parsed structure |
| Index | 1x file size | Path-to-node mapping |
| Result Buffer | 1MB | Query results |
| Session Cache | 10MB | Multiple sessions |
| **Total** | **~200MB** | For 100MB file |

### Allocation Strategy

```
Startup:
1. Allocate parser state (2MB)
2. Allocate node pool (50MB)
3. Initialize session pool

Per Session:
1. Allocate parse tree (dynamic)
2. Build index (dynamic)
3. Allocate result buffer (1MB)

Per Query:
1. Reuse result buffer
2. Allocate temporary structures
3. Free after query complete

Shutdown:
1. Free all sessions
2. Free node pool
3. Free parser state
```

### Cleanup Strategy

```rpgle
     P CleanupSession  B
     D CleanupSession  PI
     D  Session                        *   CONST
     
     C                   CALLP     FreeParseTree(Session.ParseTree)
     C                   CALLP     FreeIndex(Session.Index)
     C                   CALLP     CloseFile(Session.FileHandle)
     C                   CALLP     FreeQueryCache(Session.Cache)
     C                   DEALLOC                 Session
     P CleanupSession  E
```

**Cleanup Triggers:**
1. Explicit `JSONCLOSE` call
2. Program end (automatic)
3. Error condition (emergency)
4. Session timeout (optional)

---

## Error Handling Strategy

### Error Categories

```rpgle
     D ErrorCategory   S              1A
     D  ERR_FILE       C                   'F'
     D  ERR_PARSE      C                   'P'
     D  ERR_QUERY      C                   'Q'
     D  ERR_RUNTIME    C                   'R'
```

### Error Propagation

```
Function Call Stack:
┌─────────────────┐
│   JSONQRY       │ ← Set *IN35, format message
└────────┬────────┘
         │
┌────────▼────────┐
│ SessionManager  │ ← Cleanup resources
└────────┬────────┘
         │
┌────────▼────────┐
│  JSON Parser    │ ← Detect error, set code
└─────────────────┘

Error Flow:
1. Detect error condition
2. Set error code and message
3. Cleanup allocated resources
4. Propagate to caller
5. Set indicator 35
6. Return to client
```

### Error Recovery

```rpgle
     P ParseWithRecovery B
     D ParseWithRecovery PI           1N
     D  Stream                         *   CONST
     D  Result                         *
     D  Error                              LIKEDS(ErrorInfo)
     
     C                   MONITOR
     C                   EVAL      Result = ParseValue(Stream)
     C                   RETURN    *ON
     
     C                   ON-ERROR
     C                   EVAL      Error = GetLastError()
     C                   CALLP     CleanupParser()
     C                   RETURN    *OFF
     C                   ENDMON
     P ParseWithRecovery E
```

---

## Technical Decisions

### Decision 1: Streaming vs. In-Memory Parsing

**Options:**
1. Load entire file into memory
2. Stream file with buffering
3. Memory-mapped file access

**Decision:** Streaming with buffering

**Rationale:**
- ✅ Handles 100MB files within memory budget
- ✅ Consistent memory usage regardless of file size
- ✅ Better cache locality
- ❌ Slightly more complex implementation
- ❌ Cannot random access (mitigated by indexing)

---

### Decision 2: Parse Tree Structure

**Options:**
1. Array-based tree (flat structure)
2. Pointer-based tree (parent-child-sibling)
3. Hash-based tree (key-value pairs)

**Decision:** Pointer-based parent-child-sibling

**Rationale:**
- ✅ Memory efficient for sparse trees
- ✅ Natural representation of JSON
- ✅ Easy navigation
- ✅ Supports arbitrary nesting
- ❌ Pointer overhead
- ❌ Cache misses (mitigated by node pooling)

---

### Decision 3: JSONPath Implementation

**Options:**
1. Regex-based parsing
2. Hand-written recursive descent parser
3. State machine parser

**Decision:** Hand-written recursive descent

**Rationale:**
- ✅ Full control over parsing
- ✅ Better error messages
- ✅ Easier to optimize
- ✅ No regex dependency
- ❌ More code to maintain
- ❌ Requires careful testing

---

### Decision 4: Query Optimization Strategy

**Options:**
1. No caching (parse every time)
2. Parse tree caching only
3. Parse tree + index + query cache

**Decision:** Multi-level caching (parse tree + index + query cache)

**Rationale:**
- ✅ Meets <1ms requirement for cached queries
- ✅ Supports repeated query use case
- ✅ Reasonable memory overhead
- ❌ More complex implementation
- ❌ Cache invalidation complexity (mitigated by session model)

---

### Decision 5: STRICT Fixed-Form RPGLE Mandate

**Decision:** ALL RPGLE source code and architectural designs MUST use strict fixed-format (H, F, D, I, C, O, P specs). The use of `/FREE` or `/END-FREE` blocks is STRICTLY PROHIBITED.

**Rationale:**
- ✅ Ensures 100% compatibility with legacy systems and established coding standards.
- ✅ Prevents fragmentation of coding styles within the project.
- ✅ Forces disciplined use of traditional RPGLE constructs.

---

### Decision 6: Fixed-Form RPGLE Implementation Strategies

**Challenges:**
- Limited string handling (fixed-length fields)
- No dynamic arrays
- No modern data structures
- Column-based syntax

**Solutions:**
1. **Strings:** Use VARYING fields with maximum lengths
2. **Dynamic Arrays:** Use pointer-based linked lists
3. **Data Structures:** Use BASED data structures with pointers
4. **Memory:** Use %ALLOC and DEALLOC for dynamic allocation

**Example:**
```rpgle
     D String          S          32766A   VARYING
     D NodePtr         S               *
     D Node            DS                  QUALIFIED BASED(NodePtr)
     D  Value                     32766A   VARYING
     D  Next                           *
```

---

### Decision 7: Error Handling Mechanism

**Options:**
1. Return codes only
2. Indicator + message
3. Exception handling (MONITOR/ON-ERROR)

**Decision:** Indicator 35 + message + internal exceptions

**Rationale:**
- ✅ Follows RPGLE conventions (indicator 35)
- ✅ Provides detailed error messages
- ✅ Internal exceptions for cleanup
- ✅ Simple for client programs
- ❌ Requires consistent error handling

---

## Implementation Phases

### Phase 1: Foundation (Weeks 1-2)

**Components:**
- File I/O Manager
  - Stream reader
  - Buffer management
  - File handle pool
- Basic data structures
  - Node structure
  - Token structure
  - Error structure

**Deliverables:**
- Working file stream reader
- Buffer management tested
- Basic data structures defined

**Success Criteria:**
- Can read 100MB file in chunks
- Memory usage stable
- No file handle leaks

---

### Phase 2: JSON Parser (Weeks 3-4)

**Components:**
- Lexer (tokenizer)
  - Token recognition
  - Escape sequence handling
  - Error detection
- Parser
  - Object parsing
  - Array parsing
  - Primitive parsing
- Parse tree builder

**Deliverables:**
- Complete JSON parser
- Parse tree construction
- Comprehensive error messages

**Success Criteria:**
- Parses all valid JSON
- Detects all syntax errors
- Handles 100-level nesting
- Parse time <100ms for 10MB

---

### Phase 3: JSONPath Engine (Weeks 5-6)

**Components:**
- Query parser
  - Path segment parsing
  - Filter expression parsing
- Query evaluator
  - Basic navigation
  - Wildcard support
  - Array operations
- Filter processor
  - Comparison operators
  - Boolean logic

**Deliverables:**
- Complete JSONPath implementation
- All selector types working
- Filter expressions functional

**Success Criteria:**
- All JSONPath features work
- Query evaluation correct
- Handles complex queries

---

### Phase 4: Optimization (Week 7)

**Components:**
- Session manager
  - Session lifecycle
  - Parse tree caching
- Index builder
  - Path-to-node mapping
- Query optimizer
  - Query compilation
  - Execution plan optimization

**Deliverables:**
- Session-based API
- Index-accelerated queries
- Query caching

**Success Criteria:**
- First query <1ms (P99)
- Cached query <0.1ms (P99)
- Memory usage acceptable

---

### Phase 5: Integration & Testing (Weeks 8-9)

**Components:**
- Public API
  - JSONQRY procedure
  - JSONOPEN/JSONQRYS/JSONCLOSE
  - /COPY member
- Error handling
  - All error paths
  - Resource cleanup
- Documentation
  - API reference
  - Usage examples

**Deliverables:**
- Complete public API
- Comprehensive test suite
- Full documentation

**Success Criteria:**
- All tests passing
- No memory leaks
- Documentation complete

---

### Phase 6: Performance Tuning (Week 10)

**Components:**
- Performance profiling
- Bottleneck identification
- Optimization implementation
- Benchmark validation

**Deliverables:**
- Performance benchmarks
- Optimization report
- Tuning guide

**Success Criteria:**
- All performance targets met
- Benchmarks documented
- No regressions

---

## Architecture Diagrams

### Component Interaction Flow

```
Client Program
      │
      │ CALL JSONQRY
      ▼
┌─────────────────────────────────────────┐
│         Public API Layer                │
│  • Validate parameters                  │
│  • Create/get session                   │
│  • Format results                       │
│  • Set error indicator                  │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│       Session Manager                   │
│  • Manage session lifecycle             │
│  • Cache parse trees                    │
│  • Track resources                      │
└──────┬──────────────────┬───────────────┘
       │                  │
       │ Parse            │ Query
       ▼                  ▼
┌──────────────┐   ┌──────────────┐
│ JSON Parser  │   │JSONPath      │
│              │   │Engine        │
│ • Tokenize   │   │              │
│ • Parse      │   │ • Parse path │
│ • Build tree │   │ • Evaluate   │
└──────┬───────┘   │ • Filter     │
       │           └──────┬───────┘
       │                  │
       ▼                  ▼
┌──────────────────────────────────┐
│        Parse Tree                │
│  • Navigable structure           │
│  • Indexed for fast access       │
└──────────────────────────────────┘
```

### Memory Layout

```
┌─────────────────────────────────────────┐
│         Process Memory Space            │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  Static Data (10MB)               │  │
│  │  • Parser state                   │  │
│  │  • Node pool                      │  │
│  │  • Session pool                   │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  Dynamic Data (Variable)          │  │
│  │                                   │  │
│  │  Session 1:                       │  │
│  │  ├─ Parse Tree (2x file size)     │  │
│  │  ├─ Index (1x file size)          │  │
│  │  └─ Query Cache (1MB)             │  │
│  │                                   │  │
│  │  Session 2:                       │  │
│  │  ├─ Parse Tree                    │  │
│  │  └─ ...                           │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  Temporary (1MB)                  │  │
│  │  • Result buffers                 │  │
│  │  • Working memory                 │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

---

## Appendix: Code Structure

### Source Files Organization

```
QRPGLESRC/
├── JSONQRY     - Public API procedures
├── JSONSESS    - Session manager
├── JSONFILE    - File I/O manager
├── JSONLEX     - Lexer (tokenizer)
├── JSONPARSE   - Parser
├── JSONPATH    - JSONPath engine
├── JSONEVAL    - Query evaluator
├── JSONFILTER  - Filter processor
├── JSONUTIL    - Utility procedures
├── JSONERR     - Error handling
└── JSONCOPY    - /COPY member (public interface)

QRPGLEREF/
├── JSONNODE    - Node data structure
├── JSONTOKEN   - Token data structure
├── JSONSEG     - Path segment structure
├── JSONERROR   - Error structure
└── JSONCONST   - Constants
```

### Procedure Naming Convention

```
Public API:      JSONQRY, JSONOPEN, JSONCLOSE
Internal:        JSON_ParseValue, JSON_EvalPath
Utilities:       JSONU_AllocNode, JSONU_FreeNode
Error Handling:  JSONE_SetError, JSONE_GetError
```

---

**END OF DOCUMENT**