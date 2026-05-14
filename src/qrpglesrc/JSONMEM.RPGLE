      *=====================================================================
      * JSONMEM - Memory Allocation Framework for RPGLE-Json Query Utility
      *=====================================================================
      * Description: Provides memory allocation and management for JSON
      *              parse tree nodes with pooling for performance.
      *
      * Author: Mauro
      * Date: 2026-04-28
      * Version: 1.0
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
      *
      /FREE
       // Determine pool size
       parmCount = %PARMS();
       IF parmCount >= 1;
         size = poolSize;
       ELSE;
         size = POOL_SIZE_DFLT;
       ENDIF;
       
       // Allocate pool structure
       pool = malloc(%SIZE(MemoryPool));
       IF pool = *NULL;
         SetMemoryError(ERR_MEM_POOL: 'InitMemoryPool');
         RETURN *NULL;
       ENDIF;
       
       // Initialize pool structure
       memset(pool: 0: %SIZE(MemoryPool));
       poolDs.poolSize = size;
       poolDs.nodeSize = NODE_SIZE;
       poolDs.totalNodes = size;
       poolDs.usedNodes = 0;
       poolDs.freeNodes = size;
       poolDs.peakUsage = 0;
       poolDs.allocCount = 0;
       poolDs.freeCount = 0;
       
       // Allocate pool memory
       totalSize = size * NODE_SIZE;
       poolDs.poolMemory = malloc(totalSize);
       IF poolDs.poolMemory = *NULL;
         free(pool);
         SetMemoryError(ERR_MEM_POOL: 'InitMemoryPool - pool memory');
         RETURN *NULL;
       ENDIF;
       
       // Initialize free list
       poolDs.freeListHead = poolDs.poolMemory;
       prevPtr = *NULL;
       
       FOR i = 0 TO size - 1;
         nodePtr = poolDs.poolMemory + (i * NODE_SIZE);
         
         // Link to previous node
         IF prevPtr <> *NULL;
           %ADDR(prevPtr) = nodePtr;
         ENDIF;
         
         prevPtr = nodePtr;
       ENDFOR;
       
       // Last node points to NULL
       IF prevPtr <> *NULL;
         %ADDR(prevPtr) = *NULL;
       ENDIF;
       
       RETURN pool;
      /END-FREE
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
      /FREE
       IF pool = *NULL;
         RETURN *OFF;
       ENDIF;
       
       // Free pool memory
       IF poolDs.poolMemory <> *NULL;
         free(poolDs.poolMemory);
       ENDIF;
       
       // Free pool structure
       free(pool);
       
       RETURN *ON;
      /END-FREE
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
     D nextPtr         S               *
      *
      /FREE
       IF pool = *NULL;
         SetMemoryError(ERR_MEM_POOL: 'AllocNode - null pool');
         RETURN *NULL;
       ENDIF;
       
       // Check if pool is exhausted
       IF poolDs.freeListHead = *NULL;
         SetMemoryError(ERR_MEM_ALLOC: 'AllocNode - pool exhausted');
         RETURN *NULL;
       ENDIF;
       
       // Get node from free list
       nodePtr = poolDs.freeListHead;
       
       // Update free list head to next node
       nextPtr = %ADDR(nodePtr);
       poolDs.freeListHead = nextPtr;
       
       // Clear node memory
       memset(nodePtr: 0: NODE_SIZE);
       
       // Update statistics
       poolDs.usedNodes = poolDs.usedNodes + 1;
       poolDs.freeNodes = poolDs.freeNodes - 1;
       poolDs.allocCount = poolDs.allocCount + 1;
       
       IF poolDs.usedNodes > poolDs.peakUsage;
         poolDs.peakUsage = poolDs.usedNodes;
       ENDIF;
       
       RETURN nodePtr;
      /END-FREE
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
     D nodeDs          DS                  LIKEDS(JsonNode) BASED(node)
      *
      /FREE
       IF pool = *NULL OR node = *NULL;
         RETURN *OFF;
       ENDIF;
       
       // Clear node data
       memset(node: 0: NODE_SIZE);
       
       // Add node to free list
       %ADDR(node) = poolDs.freeListHead;
       poolDs.freeListHead = node;
       
       // Update statistics
       poolDs.usedNodes = poolDs.usedNodes - 1;
       poolDs.freeNodes = poolDs.freeNodes + 1;
       poolDs.freeCount = poolDs.freeCount + 1;
       
       RETURN *ON;
      /END-FREE
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
     D child           S               *
     D nextChild       S               *
      *
      /FREE
       IF pool = *NULL OR node = *NULL;
         RETURN *OFF;
       ENDIF;
       
       // Free all children first
       child = nodeDs.firstChild;
       DOW child <> *NULL;
         nextChild = nodeDs.nextSibling;
         FreeNodeTree(pool: child);
         child = nextChild;
       ENDDO;
       
       // Free this node
       RETURN FreeNode(pool: node);
      /END-FREE
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
      /FREE
       CLEAR stats;
       
       IF pool = *NULL;
         RETURN stats;
       ENDIF;
       
       stats.totalNodes = poolDs.totalNodes;
       stats.usedNodes = poolDs.usedNodes;
       stats.freeNodes = poolDs.freeNodes;
       stats.peakUsage = poolDs.peakUsage;
       stats.allocCount = poolDs.allocCount;
       stats.freeCount = poolDs.freeCount;
       
       // Calculate fragmentation (simplified)
       IF poolDs.totalNodes > 0;
         stats.fragmentation =
           (poolDs.usedNodes * 100) / poolDs.totalNodes;
       ELSE;
         stats.fragmentation = 0;
       ENDIF;
       
       RETURN stats;
      /END-FREE
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
      /FREE
       IF pool = *NULL OR poolDs.totalNodes = 0;
         RETURN 0;
       ENDIF;
       
       RETURN (poolDs.usedNodes * 100) / poolDs.totalNodes;
      /END-FREE
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
      /FREE
       IF pool = *NULL;
         RETURN *ON;
       ENDIF;
       
       RETURN (poolDs.freeListHead = *NULL);
      /END-FREE
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
      /FREE
       IF pool = *NULL;
         RETURN 0;
       ENDIF;
       
       RETURN poolDs.freeNodes;
      /END-FREE
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
      /FREE
       IF pool = *NULL;
         RETURN *OFF;
       ENDIF;
       
       poolDs.peakUsage = poolDs.usedNodes;
       poolDs.allocCount = 0;
       poolDs.freeCount = 0;
       
       RETURN *ON;
      /END-FREE
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
      /FREE
       // Allocate node
       node = AllocNode(pool);
       IF node = *NULL;
         RETURN *NULL;
       ENDIF;
       
       // Initialize node
       nodeDs.nodeType = nodeType;
       nodeDs.name = '';
       nodeDs.value = '';
       nodeDs.parent = *NULL;
       nodeDs.firstChild = *NULL;
       nodeDs.lastChild = *NULL;
       nodeDs.nextSibling = *NULL;
       nodeDs.prevSibling = *NULL;
       nodeDs.childCount = 0;
       nodeDs.refCount = 1;
       nodeDs.poolIndex = 0;
       
       RETURN node;
      /END-FREE
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
      /FREE
       node = CreateNode(pool: nodeType);
       IF node = *NULL;
         RETURN *NULL;
       ENDIF;
       
       nodeDs.value = value;
       
       RETURN node;
      /END-FREE
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
      /FREE
       node = CreateNode(pool: nodeType);
       IF node = *NULL;
         RETURN *NULL;
       ENDIF;
       
       nodeDs.name = name;
       
       RETURN node;
      /END-FREE
     P CreateNodeWithName...
     P                 E

      *=====================================================================
      * End of JSONMEM
      *=====================================================================