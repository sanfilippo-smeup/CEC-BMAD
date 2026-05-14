      *=====================================================================
      * JSONMEM - Memory Allocation Framework for RPGLE-Json Query Utility
      *=====================================================================
      * Description: Provides memory allocation and management for JSON
      *              parse tree nodes with pooling for performance.
      *
      * Author: Mauro
      * Date: 2026-04-28
      * Version: 1.1 (Refactored to fixed-form)
      *
      * Story: E1-S3 - Memory Allocation Framework
      *=====================================================================

      *---------------------------------------------------------------------
      * Copy Data Structures
      *---------------------------------------------------------------------
     D/COPY QRPGLESRC,JSONDATA
     D/COPY QRPGLESRC,JSONERR

      *---------------------------------------------------------------------
      * C Runtime Functions
      *---------------------------------------------------------------------
     D malloc          PR              *   EXTPROC('malloc')
     D   size                        10U 0 VALUE

     D free            PR                  EXTPROC('free')
     D   ptr                           *   VALUE

     D memset          PR              *   EXTPROC('memset')
     D   ptr                           *   VALUE
     D   value                       10I 0 VALUE
     D   size                        10U 0 VALUE

      *=====================================================================
      * Procedure: InitMemoryPool
      * Purpose: Initialize memory pool for node allocation
      *=====================================================================
     P InitMemoryPool  B                   EXPORT
     D InitMemoryPool  PI              *
     D   poolSize                    10I 0 CONST OPTIONS(*NOPASS)
      *
     D pool            S               *
     D poolDs          DS                  LIKEDS(MemoryPool) BASED(pool)
     D size            S             10I 0
     D totalSize       S             10U 0
     D parmCount       S             10I 0
     D i               S             10I 0
     D nodePtr         S               *
     D prevPtr         S               *
     D nextPtr         S               *   BASED(prevPtr)
      *
      * Determine pool size
     C                   EVAL      parmCount = %PARMS()
     C                   IF        parmCount >= 1
     C                   EVAL      size = poolSize
     C                   ELSE
     C                   EVAL      size = POOL_SIZE_DFLT
     C                   ENDIF
      *
      * Allocate pool structure
     C                   EVAL      pool = malloc(%SIZE(MemoryPool))
     C                   IF        pool = *NULL
     C                   CALLP     SetMemoryError(ERR_MEM_POOL:
     C                               'InitMemoryPool')
     C                   RETURN    *NULL
     C                   ENDIF
      *
      * Initialize pool structure
     C                   CALLP     memset(pool: 0: %SIZE(MemoryPool))
     C                   EVAL      poolDs.poolSize = size
     C                   EVAL      poolDs.nodeSize = NODE_SIZE
     C                   EVAL      poolDs.totalNodes = size
     C                   EVAL      poolDs.usedNodes = 0
     C                   EVAL      poolDs.freeNodes = size
     C                   EVAL      poolDs.peakUsage = 0
     C                   EVAL      poolDs.allocCount = 0
     C                   EVAL      poolDs.freeCount = 0
      *
      * Allocate pool memory
     C                   EVAL      totalSize = size * NODE_SIZE
     C                   EVAL      poolDs.poolMemory = malloc(totalSize)
     C                   IF        poolDs.poolMemory = *NULL
     C                   CALLP     free(pool)
     C                   CALLP     SetMemoryError(ERR_MEM_POOL:
     C                               'InitMemoryPool - pool memory')
     C                   RETURN    *NULL
     C                   ENDIF
      *
      * Initialize free list
     C                   EVAL      poolDs.freeListHead = poolDs.poolMemory
     C                   EVAL      prevPtr = *NULL
      *
     C                   DO        size          i
     C                   EVAL      nodePtr = poolDs.poolMemory +
     C                               ((i-1) * NODE_SIZE)
      *
      * Link to previous node
     C                   IF        prevPtr <> *NULL
     C                   EVAL      nextPtr = nodePtr
     C                   ENDIF
      *
     C                   EVAL      prevPtr = nodePtr
     C                   ENDDO
      *
      * Last node points to NULL
     C                   IF        prevPtr <> *NULL
     C                   EVAL      nextPtr = *NULL
     C                   ENDIF
      *
     C                   RETURN    pool
     P InitMemoryPool  E

      *=====================================================================
      * Procedure: CleanupPool
      * Purpose: Free all memory in pool
      *=====================================================================
     P CleanupPool     B                   EXPORT
     D CleanupPool     PI              N
     D   pool                          *   CONST
      *
     D poolDs          DS                  LIKEDS(MemoryPool) BASED(pool)
      *
     C                   IF        pool = *NULL
     C                   RETURN    *OFF
     C                   ENDIF
      *
      * Free pool memory
     C                   IF        poolDs.poolMemory <> *NULL
     C                   CALLP     free(poolDs.poolMemory)
     C                   ENDIF
      *
      * Free pool structure
     C                   CALLP     free(pool)
      *
     C                   RETURN    *ON
     P CleanupPool     E

      *=====================================================================
      * Procedure: AllocNode
      * Purpose: Allocate a node from the pool
      *=====================================================================
     P AllocNode       B                   EXPORT
     D AllocNode       PI              *
     D   pool                          *   CONST
      *
     D poolDs          DS                  LIKEDS(MemoryPool) BASED(pool)
     D nodePtr         S               *
     D nextPtr         S               *   BASED(nodePtr)
      *
     C                   IF        pool = *NULL
     C                   CALLP     SetMemoryError(ERR_MEM_POOL:
     C                               'AllocNode - null pool')
     C                   RETURN    *NULL
     C                   ENDIF
      *
      * Check if pool is exhausted
     C                   IF        poolDs.freeListHead = *NULL
     C                   CALLP     SetMemoryError(ERR_MEM_ALLOC:
     C                               'AllocNode - pool exhausted')
     C                   RETURN    *NULL
     C                   ENDIF
      *
      * Get node from free list
     C                   EVAL      nodePtr = poolDs.freeListHead
      *
      * Update free list head to next node
     C                   EVAL      poolDs.freeListHead = nextPtr
      *
      * Clear node memory
     C                   CALLP     memset(nodePtr: 0: NODE_SIZE)
      *
      * Update statistics
     C                   EVAL      poolDs.usedNodes = poolDs.usedNodes + 1
     C                   EVAL      poolDs.freeNodes = poolDs.freeNodes - 1
     C                   EVAL      poolDs.allocCount = poolDs.allocCount + 1
      *
     C                   IF        poolDs.usedNodes > poolDs.peakUsage
     C                   EVAL      poolDs.peakUsage = poolDs.usedNodes
     C                   ENDIF
      *
     C                   RETURN    nodePtr
     P AllocNode       E

      *=====================================================================
      * Procedure: FreeNode
      * Purpose: Return a node to the pool
      *=====================================================================
     P FreeNode        B                   EXPORT
     D FreeNode        PI              N
     D   pool                          *   CONST
     D   node                          *   CONST
      *
     D poolDs          DS                  LIKEDS(MemoryPool) BASED(pool)
     D nextPtr         S               *   BASED(node)
      *
     C                   IF        pool = *NULL OR node = *NULL
     C                   RETURN    *OFF
     C                   ENDIF
      *
      * Clear node data
     C                   CALLP     memset(node: 0: NODE_SIZE)
      *
      * Add node to free list
     C                   EVAL      nextPtr = poolDs.freeListHead
     C                   EVAL      poolDs.freeListHead = node
      *
      * Update statistics
     C                   EVAL      poolDs.usedNodes = poolDs.usedNodes - 1
     C                   EVAL      poolDs.freeNodes = poolDs.freeNodes + 1
     C                   EVAL      poolDs.freeCount = poolDs.freeCount + 1
      *
     C                   RETURN    *ON
     P FreeNode        E

      *=====================================================================
      * Procedure: FreeNodeTree
      * Purpose: Recursively free a node and all its children
      *=====================================================================
     P FreeNodeTree    B                   EXPORT
     D FreeNodeTree    PI              N
     D   pool                          *   CONST
     D   node                          *   CONST
      *
     D nodeDs          DS                  LIKEDS(JsonNode) BASED(node)
     D childDs         DS                  LIKEDS(JsonNode) BASED(child)
     D child           S               *
     D nextChild       S               *
      *
     C                   IF        pool = *NULL OR node = *NULL
     C                   RETURN    *OFF
     C                   ENDIF
      *
      * Free all children first
     C                   EVAL      child = nodeDs.firstChild
     C                   DOW       child <> *NULL
     C                   EVAL      nextChild = childDs.nextSibling
     C                   CALLP     FreeNodeTree(pool: child)
     C                   EVAL      child = nextChild
     C                   ENDDO
      *
      * Free this node
     C                   RETURN    FreeNode(pool: node)
     P FreeNodeTree    E

      *=====================================================================
      * Procedure: GetPoolStats
      * Purpose: Get memory pool statistics
      *=====================================================================
     P GetPoolStats    B                   EXPORT
     D GetPoolStats    PI                  LIKEDS(PoolStats)
     D   pool                          *   CONST
      *
     D poolDs          DS                  LIKEDS(MemoryPool) BASED(pool)
     D stats           DS                  LIKEDS(PoolStats)
      *
     C                   CLEAR                   stats
      *
     C                   IF        pool = *NULL
     C                   RETURN    stats
     C                   ENDIF
      *
     C                   EVAL      stats.totalNodes = poolDs.totalNodes
     C                   EVAL      stats.usedNodes = poolDs.usedNodes
     C                   EVAL      stats.freeNodes = poolDs.freeNodes
     C                   EVAL      stats.peakUsage = poolDs.peakUsage
     C                   EVAL      stats.allocCount = poolDs.allocCount
     C                   EVAL      stats.freeCount = poolDs.freeCount
      *
      * Calculate fragmentation (simplified)
     C                   IF        poolDs.totalNodes > 0
     C                   EVAL      stats.fragmentation =
     C                               (poolDs.usedNodes * 100) /
     C                               poolDs.totalNodes
     C                   ELSE
     C                   EVAL      stats.fragmentation = 0
     C                   ENDIF
      *
     C                   RETURN    stats
     P GetPoolStats    E

      *=====================================================================
      * Procedure: GetPoolUsage
      * Purpose: Get current pool usage percentage
      *=====================================================================
     P GetPoolUsage    B                   EXPORT
     D GetPoolUsage    PI            10I 0
     D   pool                          *   CONST
      *
     D poolDs          DS                  LIKEDS(MemoryPool) BASED(pool)
      *
     C                   IF        pool = *NULL OR poolDs.totalNodes = 0
     C                   RETURN    0
     C                   ENDIF
      *
     C                   RETURN    (poolDs.usedNodes * 100) /
     C                               poolDs.totalNodes
     P GetPoolUsage    E

      *=====================================================================
      * Procedure: IsPoolExhausted
      * Purpose: Check if pool is exhausted
      *=====================================================================
     P IsPoolExhausted...
     P                 B                   EXPORT
     D IsPoolExhausted...
     D                 PI              N
     D   pool                          *   CONST
      *
     D poolDs          DS                  LIKEDS(MemoryPool) BASED(pool)
      *
     C                   IF        pool = *NULL
     C                   RETURN    *ON
     C                   ENDIF
      *
     C                   RETURN    (poolDs.freeListHead = *NULL)
     P IsPoolExhausted...
     P                 E

      *=====================================================================
      * Procedure: GetPoolCapacity
      * Purpose: Get remaining pool capacity
      *=====================================================================
     P GetPoolCapacity...
     P                 B                   EXPORT
     D GetPoolCapacity...
     D                 PI            10I 0
     D   pool                          *   CONST
      *
     D poolDs          DS                  LIKEDS(MemoryPool) BASED(pool)
      *
     C                   IF        pool = *NULL
     C                   RETURN    0
     C                   ENDIF
      *
     C                   RETURN    poolDs.freeNodes
     P GetPoolCapacity...
     P                 E

      *=====================================================================
      * Procedure: ResetPoolStats
      * Purpose: Reset pool statistics (not memory)
      *=====================================================================
     P ResetPoolStats  B                   EXPORT
     D ResetPoolStats  PI              N
     D   pool                          *   CONST
      *
     D poolDs          DS                  LIKEDS(MemoryPool) BASED(pool)
      *
     C                   IF        pool = *NULL
     C                   RETURN    *OFF
     C                   ENDIF
      *
     C                   EVAL      poolDs.peakUsage = poolDs.usedNodes
     C                   EVAL      poolDs.allocCount = 0
     C                   EVAL      poolDs.freeCount = 0
      *
     C                   RETURN    *ON
     P ResetPoolStats  E

      *=====================================================================
      * Procedure: CreateNode
      * Purpose: Allocate and initialize a new JSON node
      *=====================================================================
     P CreateNode      B                   EXPORT
     D CreateNode      PI              *
     D   pool                          *   CONST
     D   nodeType                     1A   CONST
      *
     D node            S               *
     D nodeDs          DS                  LIKEDS(JsonNode) BASED(node)
      *
      * Allocate node
     C                   EVAL      node = AllocNode(pool)
     C                   IF        node = *NULL
     C                   RETURN    *NULL
     C                   ENDIF
      *
      * Initialize node
     C                   EVAL      nodeDs.nodeType = nodeType
     C                   EVAL      nodeDs.name = ''
     C                   EVAL      nodeDs.value = ''
     C                   EVAL      nodeDs.parent = *NULL
     C                   EVAL      nodeDs.firstChild = *NULL
     C                   EVAL      nodeDs.lastChild = *NULL
     C                   EVAL      nodeDs.nextSibling = *NULL
     C                   EVAL      nodeDs.prevSibling = *NULL
     C                   EVAL      nodeDs.childCount = 0
     C                   EVAL      nodeDs.refCount = 1
     C                   EVAL      nodeDs.poolIndex = 0
      *
     C                   RETURN    node
     P CreateNode      E

      *=====================================================================
      * Procedure: CreateNodeWithValue
      * Purpose: Create node with type and value
      *=====================================================================
     P CreateNodeWithValue...
     P                 B                   EXPORT
     D CreateNodeWithValue...
     D                 PI              *
     D   pool                          *   CONST
     D   nodeType                     1A   CONST
     D   value                      256A   CONST VARYING
      *
     D node            S               *
     D nodeDs          DS                  LIKEDS(JsonNode) BASED(node)
      *
     C                   EVAL      node = CreateNode(pool: nodeType)
     C                   IF        node = *NULL
     C                   RETURN    *NULL
     C                   ENDIF
      *
     C                   EVAL      nodeDs.value = value
      *
     C                   RETURN    node
     P CreateNodeWithValue...
     P                 E

      *=====================================================================
      * Procedure: CreateNodeWithName
      * Purpose: Create node with type and name (for object properties)
      *=====================================================================
     P CreateNodeWithName...
     P                 B                   EXPORT
     D CreateNodeWithName...
     D                 PI              *
     D   pool                          *   CONST
     D   nodeType                     1A   CONST
     D   name                       256A   CONST VARYING
      *
     D node            S               *
     D nodeDs          DS                  LIKEDS(JsonNode) BASED(node)
      *
     C                   EVAL      node = CreateNode(pool: nodeType)
     C                   IF        node = *NULL
     C                   RETURN    *NULL
     C                   ENDIF
      *
     C                   EVAL      nodeDs.name = name
      *
     C                   RETURN    node
     P CreateNodeWithName...
     P                 E

      *=====================================================================
      * End of JSONMEM
      *=====================================================================
