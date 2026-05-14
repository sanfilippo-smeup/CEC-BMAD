      *=====================================================================
      * JSONDATA - Core Data Structures for RPGLE-Json Query Utility
      *=====================================================================
      * Description: Defines all core data structures used throughout the
      *              JSON parser and query engine.
      *
      * Author: Mauro
      * Date: 2026-04-28
      * Version: 1.0
      *
      * Story: E1-S4 - Core Data Structures
      *=====================================================================

      *---------------------------------------------------------------------
      * JSON Node Types
      *---------------------------------------------------------------------
     D JSON_TYPE_NULL  C                   CONST('N')
     D JSON_TYPE_BOOL  C                   CONST('B')
     D JSON_TYPE_NUM   C                   CONST('#')
     D JSON_TYPE_STR   C                   CONST('S')
     D JSON_TYPE_ARR   C                   CONST('A')
     D JSON_TYPE_OBJ   C                   CONST('O')

      *---------------------------------------------------------------------
      * Token Types
      *---------------------------------------------------------------------
     D TOK_LBRACE      C                   CONST('{')
     D TOK_RBRACE      C                   CONST('}')
     D TOK_LBRACKET    C                   CONST('[')
     D TOK_RBRACKET    C                   CONST(']')
     D TOK_COLON       C                   CONST(':')
     D TOK_COMMA       C                   CONST(',')
     D TOK_STRING      C                   CONST('S')
     D TOK_NUMBER      C                   CONST('#')
     D TOK_TRUE        C                   CONST('T')
     D TOK_FALSE       C                   CONST('F')
     D TOK_NULL        C                   CONST('N')
     D TOK_EOF         C                   CONST('E')

      *---------------------------------------------------------------------
      * Error Code Ranges
      *---------------------------------------------------------------------
     D ERR_FILE_MIN    C                   CONST('JSON001')
     D ERR_FILE_MAX    C                   CONST('JSON099')
     D ERR_PARSE_MIN   C                   CONST('JSON100')
     D ERR_PARSE_MAX   C                   CONST('JSON199')
     D ERR_QUERY_MIN   C                   CONST('JSON200')
     D ERR_QUERY_MAX   C                   CONST('JSON299')
     D ERR_RUNTIME_MIN C                   CONST('JSON300')
     D ERR_RUNTIME_MAX C                   CONST('JSON399')

      *---------------------------------------------------------------------
      * Common Error Codes
      *---------------------------------------------------------------------
     D ERR_FILE_NOTFND C                   CONST('JSON001')
     D ERR_FILE_ACCESS C                   CONST('JSON002')
     D ERR_FILE_READ   C                   CONST('JSON003')
     D ERR_PARSE_SYNTA C                   CONST('JSON100')
     D ERR_PARSE_UNEXP C                   CONST('JSON101')
     D ERR_PARSE_EOF   C                   CONST('JSON102')
     D ERR_MEM_ALLOC   C                   CONST('JSON300')
     D ERR_MEM_POOL    C                   CONST('JSON301')

      *---------------------------------------------------------------------
      * Buffer Constants
      *---------------------------------------------------------------------
     D BUF_SIZE_ACTIV  C                   CONST(4096)
     D BUF_SIZE_AHEAD  C                   CONST(8192)
     D BUF_REFILL_THR  C                   CONST(1024)

      *---------------------------------------------------------------------
      * Memory Pool Constants
      *---------------------------------------------------------------------
     D POOL_SIZE_DFLT  C                   CONST(10000)
     D NODE_SIZE       C                   CONST(512)

      *=====================================================================
      * Data Structure: JsonNode
      * Purpose: Represents a node in the JSON parse tree
      *=====================================================================
     D JsonNode        DS                  QUALIFIED BASED(nodePtr)
      * Node type (N=null, B=bool, #=number, S=string, A=array, O=object)
     D   nodeType                     1A
      * Node name (for object properties)
     D   name                       256A   VARYING
      * Node value (for primitives)
     D   value                      256A   VARYING
      * Tree navigation pointers
     D   parent                        *
     D   firstChild                    *
     D   lastChild                     *
     D   nextSibling                   *
     D   prevSibling                   *
      * Array/Object metadata
     D   childCount                  10I 0
      * Memory management
     D   refCount                    10I 0
     D   poolIndex                   10I 0

      *=====================================================================
      * Data Structure: Token
      * Purpose: Represents a lexical token from JSON input
      *=====================================================================
     D Token           DS                  QUALIFIED BASED(tokenPtr)
      * Token type (see TOK_* constants)
     D   tokenType                    1A
      * Token value (for strings, numbers)
     D   value                      256A   VARYING
      * Position in source
     D   line                        10I 0
     D   column                      10I 0
     D   offset                      10I 0
      * Token length
     D   length                      10I 0

      *=====================================================================
      * Data Structure: Position
      * Purpose: Tracks position in source file for error reporting
      *=====================================================================
     D Position        DS                  QUALIFIED BASED(posPtr)
     D   line                        10I 0
     D   column                      10I 0
     D   offset                      10I 0

      *=====================================================================
      * Data Structure: ErrorInfo
      * Purpose: Contains error information
      *=====================================================================
     D ErrorInfo       DS                  QUALIFIED BASED(errorPtr)
      * Error code (JSON001-JSON399)
     D   errorCode                   10A
      * Error message
     D   message                    256A   VARYING
      * Position where error occurred
     D   line                        10I 0
     D   column                      10I 0
     D   offset                      10I 0
      * Additional context
     D   context                    128A   VARYING

      *=====================================================================
      * Data Structure: FileHandle
      * Purpose: Represents an open IFS file
      *=====================================================================
     D FileHandle      DS                  QUALIFIED BASED(filePtr)
      * File descriptor from open()
     D   fd                          10I 0
      * File path
     D   path                       256A   VARYING
      * File size
     D   size                        20I 0
      * Current position
     D   position                    20I 0
      * File status flags
     D   isOpen                       1N
     D   isEOF                        1N
     D   hasError                     1N

      *=====================================================================
      * Data Structure: BufferHandle
      * Purpose: Manages buffered file reading
      *=====================================================================
     D BufferHandle    DS                  QUALIFIED BASED(bufPtr)
      * Associated file handle
     D   fileHandle                    *
      * Active buffer (4KB)
     D   buffer                    4096A
      * Read-ahead buffer (8KB)
     D   readAhead                 8192A
      * Buffer state
     D   bufferSize                  10I 0
     D   bufferPos                   10I 0
     D   bytesInBuf                  10I 0
     D   bytesInAhead                10I 0
      * Position tracking
     D   position                      *
      * EOF flag
     D   isEOF                        1N

      *=====================================================================
      * Data Structure: MemoryPool
      * Purpose: Manages memory allocation for nodes
      *=====================================================================
     D MemoryPool      DS                  QUALIFIED BASED(poolPtr)
      * Pool configuration
     D   poolSize                    10I 0
     D   nodeSize                    10I 0
      * Pool statistics
     D   totalNodes                  10I 0
     D   usedNodes                   10I 0
     D   freeNodes                   10I 0
     D   peakUsage                   10I 0
      * Free list head
     D   freeListHead                  *
      * Pool memory pointer
     D   poolMemory                    *
      * Allocation tracking
     D   allocCount                  10I 0
     D   freeCount                   10I 0

      *=====================================================================
      * Data Structure: Session
      * Purpose: Represents a JSON parsing/query session
      *=====================================================================
     D Session         DS                  QUALIFIED BASED(sessionPtr)
      * Session identifier
     D   handle                      10I 0
      * Associated file
     D   fileHandle                    *
      * Parse tree root
     D   parseTree                     *
      * Memory pool
     D   memoryPool                    *
      * Error information
     D   errorInfo                     *
      * Session state
     D   isActive                     1N
     D   isParsed                     1N
     D   hasError                     1N
      * Performance metrics
     D   parseTime                   10I 0
     D   queryCount                  10I 0

      *=====================================================================
      * Data Structure: QueryContext
      * Purpose: Context for JSONPath query evaluation
      *=====================================================================
     D QueryContext    DS                  QUALIFIED BASED(qryCtxPtr)
      * Query string
     D   query                      512A   VARYING
      * Current node being evaluated
     D   currentNode                   *
      * Result collection
     D   results                       *
     D   resultCount                 10I 0
      * Query state
     D   isRecursive                  1N
     D   depth                       10I 0

      *=====================================================================
      * Data Structure: ResultSet
      * Purpose: Collection of query results
      *=====================================================================
     D ResultSet       DS                  QUALIFIED BASED(resultPtr)
      * Result array (pointer to array of node pointers)
     D   nodes                         *
      * Result count
     D   count                       10I 0
     D   capacity                    10I 0
      * Result metadata
     D   queryTime                   10I 0
     D   fromCache                    1N

      *=====================================================================
      * Data Structure: PathSegment
      * Purpose: Represents a segment of a JSONPath query
      *=====================================================================
     D PathSegment     DS                  QUALIFIED BASED(segPtr)
      * Segment type (R=root, D=dot, B=bracket, W=wildcard, R=recursive)
     D   segmentType                  1A
      * Segment value (property name, index, etc.)
     D   value                      128A   VARYING
      * Array slice parameters
     D   sliceStart                  10I 0
     D   sliceEnd                    10I 0
     D   sliceStep                   10I 0
      * Filter expression
     D   filter                     256A   VARYING
      * Next segment
     D   nextSegment                   *

      *=====================================================================
      * Data Structure: PoolStats
      * Purpose: Memory pool statistics
      *=====================================================================
     D PoolStats       DS                  QUALIFIED
     D   totalNodes                  10I 0
     D   usedNodes                   10I 0
     D   freeNodes                   10I 0
     D   peakUsage                   10I 0
     D   allocCount                  10I 0
     D   freeCount                   10I 0
     D   fragmentation               10I 0

      *=====================================================================
      * Data Structure: TestResult
      * Purpose: Unit test result information
      *=====================================================================
     D TestResult      DS                  QUALIFIED
     D   testName                    64A   VARYING
     D   passed                       1N
     D   message                    256A   VARYING
     D   duration                    10I 0

      *=====================================================================
      * End of JSONDATA
      *=====================================================================