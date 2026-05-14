      *=====================================================================
      * JSONBUF - Buffer Management System for RPGLE-Json Query Utility
      *=====================================================================
      * Description: Provides efficient buffered file reading with read-ahead
      *              and position tracking for error reporting.
      *
      * Author: Mauro
      * Date: 2026-04-28
      * Version: 1.1 (Refactored to fixed-form)
      *
      * Stories: E1-S2 - Buffer Management System
      *          E1-S7 - Position Tracking
      *=====================================================================

      *---------------------------------------------------------------------
      * Copy Data Structures
      *---------------------------------------------------------------------
     D/COPY QRPGLESRC,JSONDATA
     D/COPY QRPGLESRC,JSONERR
     D/COPY QRPGLESRC,JSONFILE

      *=====================================================================
      * Procedure: InitBuffer
      * Purpose: Initialize buffer for file reading
      *=====================================================================
     P InitBuffer      B                   EXPORT
     D InitBuffer      PI              *
     D   fileHandle                    *   CONST
      *
     D buffer          S               *
     D bufferDs        DS                  LIKEDS(BufferHandle) BASED(buffer)
     D position        S               *
     D positionDs      DS                  LIKEDS(Position) BASED(position)
      *
     C                   IF        fileHandle = *NULL
     C                   CALLP     SetFileError(ERR_FILE_ACCESS: '':
     C                               'Null file handle')
     C                   RETURN    *NULL
     C                   ENDIF
      *
      * Allocate buffer handle
     C                   EVAL      buffer = %ALLOC(%SIZE(BufferHandle))
     C                   IF        buffer = *NULL
     C                   CALLP     SetMemoryError(ERR_MEM_ALLOC: 'InitBuffer')
     C                   RETURN    *NULL
     C                   ENDIF
      *
      * Allocate position structure
     C                   EVAL      position = %ALLOC(%SIZE(Position))
     C                   IF        position = *NULL
     C                   CALLP     DEALLOC(buffer)
     C                   CALLP     SetMemoryError(ERR_MEM_ALLOC:
     C                               'InitBuffer - position')
     C                   RETURN    *NULL
     C                   ENDIF
      *
      * Initialize buffer
     C                   CLEAR                   bufferDs
     C                   EVAL      bufferDs.fileHandle = fileHandle
     C                   EVAL      bufferDs.bufferSize = BUF_SIZE_ACTIV
     C                   EVAL      bufferDs.bufferPos = 0
     C                   EVAL      bufferDs.bytesInBuf = 0
     C                   EVAL      bufferDs.bytesInAhead = 0
     C                   EVAL      bufferDs.isEOF = *OFF
     C                   EVAL      bufferDs.position = position
      *
      * Initialize position
     C                   CLEAR                   positionDs
     C                   EVAL      positionDs.line = 1
     C                   EVAL      positionDs.column = 1
     C                   EVAL      positionDs.offset = 0
      *
      * Fill initial buffer
     C                   CALLP     RefillBuffer(buffer)
      *
     C                   RETURN    buffer
     P InitBuffer      E

      *=====================================================================
      * Procedure: CleanupBuffer
      * Purpose: Free buffer resources
      *=====================================================================
     P CleanupBuffer   B                   EXPORT
     D CleanupBuffer   PI              N
     D   buffer                        *   CONST
      *
     D bufferDs        DS                  LIKEDS(BufferHandle) BASED(buffer)
      *
     C                   IF        buffer = *NULL
     C                   RETURN    *OFF
     C                   ENDIF
      *
      * Free position structure
     C                   IF        bufferDs.position <> *NULL
     C                   CALLP     DEALLOC(bufferDs.position)
     C                   ENDIF
      *
      * Free buffer
     C                   CALLP     DEALLOC(buffer)
      *
     C                   RETURN    *ON
     P CleanupBuffer   E

      *=====================================================================
      * Procedure: RefillBuffer
      * Purpose: Refill buffer from file
      *=====================================================================
     P RefillBuffer    B                   EXPORT
     D RefillBuffer    PI              N
     D   buffer                        *   CONST
      *
     D bufferDs        DS                  LIKEDS(BufferHandle) BASED(buffer)
     D bytesRead       S             10I 0
     D tempBuf         S           4096A
      *
     C                   IF        buffer = *NULL
     C                   RETURN    *OFF
     C                   ENDIF
      *
     C                   IF        bufferDs.isEOF
     C                   RETURN    *OFF
     C                   ENDIF
      *
      * Move read-ahead to active buffer if available
     C                   IF        bufferDs.bytesInAhead > 0
     C                   EVAL      bufferDs.buffer = %SUBST(bufferDs.readAhead:
     C                               1: bufferDs.bytesInAhead)
     C                   EVAL      bufferDs.bytesInBuf = bufferDs.bytesInAhead
     C                   EVAL      bufferDs.bufferPos = 0
     C                   EVAL      bufferDs.bytesInAhead = 0
     C                   ELSE
      *
      * Read into active buffer
     C                   EVAL      bytesRead = ReadChunk(bufferDs.fileHandle:
     C                               tempBuf: BUF_SIZE_ACTIV)
      *
     C                   IF        bytesRead < 0
     C                   RETURN    *OFF
     C                   ENDIF
      *
     C                   IF        bytesRead = 0
     C                   EVAL      bufferDs.isEOF = *ON
     C                   RETURN    *OFF
     C                   ENDIF
      *
     C                   EVAL      bufferDs.buffer = %SUBST(tempBuf: 1:
     C                               bytesRead)
     C                   EVAL      bufferDs.bytesInBuf = bytesRead
     C                   EVAL      bufferDs.bufferPos = 0
     C                   ENDIF
      *
      * Read ahead if not at EOF
     C                   IF        NOT IsEOF(bufferDs.fileHandle)
     C                   EVAL      bytesRead = ReadChunk(bufferDs.fileHandle:
     C                               tempBuf: BUF_SIZE_AHEAD)
      *
     C                   IF        bytesRead > 0
     C                   EVAL      bufferDs.readAhead = %SUBST(tempBuf: 1:
     C                               bytesRead)
     C                   EVAL      bufferDs.bytesInAhead = bytesRead
     C                   ENDIF
     C                   ENDIF
      *
     C                   RETURN    *ON
     P RefillBuffer    E

      *=====================================================================
      * Procedure: PeekChar
      * Purpose: Peek at next character without advancing position
      *=====================================================================
     P PeekChar        B                   EXPORT
     D PeekChar        PI             1A
     D   buffer                        *   CONST
      *
     D bufferDs        DS                  LIKEDS(BufferHandle) BASED(buffer)
      *
     C                   IF        buffer = *NULL
     C                   RETURN    x'00'
     C                   ENDIF
      *
      * Check if buffer needs refill
     C                   IF        bufferDs.bufferPos >= bufferDs.bytesInBuf
     C                   IF        NOT RefillBuffer(buffer)
     C                   RETURN    x'00'
     C                   ENDIF
     C                   ENDIF
      *
      * Return character at current position
     C                   RETURN    %SUBST(bufferDs.buffer:
     C                               bufferDs.bufferPos + 1: 1)
     P PeekChar        E

      *=====================================================================
      * Procedure: ReadChar
      * Purpose: Read next character and advance position
      *=====================================================================
     P ReadChar        B                   EXPORT
     D ReadChar        PI             1A
     D   buffer                        *   CONST
      *
     D bufferDs        DS                  LIKEDS(BufferHandle) BASED(buffer)
     D positionDs      DS                  LIKEDS(Position)
     D                                     BASED(bufferDs.position)
     D char            S              1A
      *
     C                   IF        buffer = *NULL
     C                   RETURN    x'00'
     C                   ENDIF
      *
      * Check if buffer needs refill
     C                   IF        bufferDs.bufferPos >= bufferDs.bytesInBuf
     C                   IF        NOT RefillBuffer(buffer)
     C                   RETURN    x'00'
     C                   ENDIF
     C                   ENDIF
      *
      * Get character
     C                   EVAL      char = %SUBST(bufferDs.buffer:
     C                               bufferDs.bufferPos + 1: 1)
      *
      * Advance buffer position
     C                   EVAL      bufferDs.bufferPos = bufferDs.bufferPos + 1
      *
      * Update position tracking
     C                   EVAL      positionDs.offset = positionDs.offset + 1
      *
     C                   IF        char = x'0A' OR char = x'0D'
      * Handle CR+LF as single newline
     C                   IF        char = x'0D'
     C                   IF        PeekChar(buffer) = x'0A'
     C                   EVAL      bufferDs.bufferPos = bufferDs.bufferPos + 1
     C                   EVAL      positionDs.offset = positionDs.offset + 1
     C                   ENDIF
     C                   ENDIF
      *
     C                   EVAL      positionDs.line = positionDs.line + 1
     C                   EVAL      positionDs.column = 1
     C                   ELSE
     C                   EVAL      positionDs.column = positionDs.column + 1
     C                   ENDIF
      *
      * Check if we need to refill soon
     C                   IF        bufferDs.bytesInBuf - bufferDs.bufferPos <
     C                               BUF_REFILL_THR
     C                   IF        bufferDs.bytesInAhead = 0 AND
     C                               NOT bufferDs.isEOF
     C                   CALLP     RefillBuffer(buffer)
     C                   ENDIF
     C                   ENDIF
      *
     C                   RETURN    char
     P ReadChar        E

      *=====================================================================
      * Procedure: UnreadChar
      * Purpose: Move back one character (limited unread capability)
      *=====================================================================
     P UnreadChar      B                   EXPORT
     D UnreadChar      PI              N
     D   buffer                        *   CONST
      *
     D bufferDs        DS                  LIKEDS(BufferHandle) BASED(buffer)
     D positionDs      DS                  LIKEDS(Position)
     D                                     BASED(bufferDs.position)
      *
     C                   IF        buffer = *NULL
     C                   RETURN    *OFF
     C                   ENDIF
      *
     C                   IF        bufferDs.bufferPos = 0
     C                   RETURN    *OFF
     C                   ENDIF
      *
     C                   EVAL      bufferDs.bufferPos = bufferDs.bufferPos - 1
     C                   EVAL      positionDs.offset = positionDs.offset - 1
      *
     C                   RETURN    *ON
     P UnreadChar      E

      *=====================================================================
      * Procedure: IsBufferEOF
      * Purpose: Check if buffer has reached end of file
      *=====================================================================
     P IsBufferEOF     B                   EXPORT
     D IsBufferEOF     PI              N
     D   buffer                        *   CONST
      *
     D bufferDs        DS                  LIKEDS(BufferHandle) BASED(buffer)
      *
     C                   IF        buffer = *NULL
     C                   RETURN    *ON
     C                   ENDIF
      *
     C                   RETURN    (bufferDs.isEOF AND
     C                               bufferDs.bufferPos >= bufferDs.bytesInBuf)
     P IsBufferEOF     E

      *=====================================================================
      * Procedure: GetPosition
      * Purpose: Get current position in file
      *=====================================================================
     P GetPosition     B                   EXPORT
     D GetPosition     PI                  LIKEDS(Position)
     D   buffer                        *   CONST
      *
     D bufferDs        DS                  LIKEDS(BufferHandle) BASED(buffer)
     D positionDs      DS                  LIKEDS(Position)
     D                                     BASED(bufferDs.position)
     D result          DS                  LIKEDS(Position)
      *
     C                   CLEAR                   result
      *
     C                   IF        buffer = *NULL OR bufferDs.position = *NULL
     C                   RETURN    result
     C                   ENDIF
      *
     C                   EVAL      result = positionDs
     C                   RETURN    result
     P GetPosition     E

      *=====================================================================
      * Procedure: GetLine
      * Purpose: Get current line number
      *=====================================================================
     P GetLine         B                   EXPORT
     D GetLine         PI            10I 0
     D   buffer                        *   CONST
      *
     D bufferDs        DS                  LIKEDS(BufferHandle) BASED(buffer)
     D positionDs      DS                  LIKEDS(Position)
     D                                     BASED(bufferDs.position)
      *
     C                   IF        buffer = *NULL OR bufferDs.position = *NULL
     C                   RETURN    0
     C                   ENDIF
      *
     C                   RETURN    positionDs.line
     P GetLine         E

      *=====================================================================
      * Procedure: GetColumn
      * Purpose: Get current column number
      *=====================================================================
     P GetColumn       B                   EXPORT
     D GetColumn       PI            10I 0
     D   buffer                        *   CONST
      *
     D bufferDs        DS                  LIKEDS(BufferHandle) BASED(buffer)
     D positionDs      DS                  LIKEDS(Position)
     D                                     BASED(bufferDs.position)
      *
     C                   IF        buffer = *NULL OR bufferDs.position = *NULL
     C                   RETURN    0
     C                   ENDIF
      *
     C                   RETURN    positionDs.column
     P GetColumn       E

      *=====================================================================
      * Procedure: GetOffset
      * Purpose: Get current byte offset
      *=====================================================================
     P GetOffset       B                   EXPORT
     D GetOffset       PI            10I 0
     D   buffer                        *   CONST
      *
     D bufferDs        DS                  LIKEDS(BufferHandle) BASED(buffer)
     D positionDs      DS                  LIKEDS(Position)
     D                                     BASED(bufferDs.position)
      *
     C                   IF        buffer = *NULL OR bufferDs.position = *NULL
     C                   RETURN    0
     C                   ENDIF
      *
     C                   RETURN    positionDs.offset
     P GetOffset       E

      *=====================================================================
      * Procedure: SkipWhitespace
      * Purpose: Skip whitespace characters
      *=====================================================================
     P SkipWhitespace  B                   EXPORT
     D SkipWhitespace  PI              N
     D   buffer                        *   CONST
      *
     D char            S              1A
      *
     C                   IF        buffer = *NULL
     C                   RETURN    *OFF
     C                   ENDIF
      *
     C                   EVAL      char = PeekChar(buffer)
      *
     C                   DOW       char = ' ' OR char = x'09' OR
     C                               char = x'0A' OR char = x'0D'
      *
     C                   CALLP     ReadChar(buffer)
      *
     C                   IF        IsBufferEOF(buffer)
     C                   RETURN    *ON
     C                   ENDIF
      *
     C                   EVAL      char = PeekChar(buffer)
     C                   ENDDO
      *
     C                   RETURN    *ON
     P SkipWhitespace  E

      *=====================================================================
      * Procedure: PeekString
      * Purpose: Peek at next n characters without advancing
      *=====================================================================
     P PeekString      B                   EXPORT
     D PeekString      PI           256A   VARYING
     D   buffer                        *   CONST
     D   length                      10I 0 CONST
      *
     D bufferDs        DS                  LIKEDS(BufferHandle) BASED(buffer)
     D result          S            256A   VARYING
     D i               S             10I 0
     D pos             S             10I 0
      *
     C                   EVAL      result = ''
      *
     C                   IF        buffer = *NULL OR length <= 0
     C                   RETURN    result
     C                   ENDIF
      *
     C                   EVAL      pos = bufferDs.bufferPos
      *
     C                   DO        length        i
     C                   IF        pos >= bufferDs.bytesInBuf
     C                   IF        NOT bufferDs.isEOF
     C                   CALLP     RefillBuffer(buffer)
     C                   EVAL      pos = 0
     C                   ELSE
     C                   LEAVE
     C                   ENDIF
     C                   ENDIF
      *
     C                   EVAL      result = result +
     C                               %SUBST(bufferDs.buffer: pos + 1: 1)
     C                   EVAL      pos = pos + 1
     C                   ENDDO
      *
     C                   RETURN    result
     P PeekString      E

      *=====================================================================
      * End of JSONBUF
      *=====================================================================
