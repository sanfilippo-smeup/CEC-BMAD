      *=====================================================================
      * JSONBUF - Buffer Management System for RPGLE-Json Query Utility
      *=====================================================================
      * Description: Provides efficient buffered file reading with read-ahead
      *              and position tracking for error reporting.
      *
      * Author: Mauro
      * Date: 2026-04-28
      * Version: 1.0
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
      /FREE
       IF fileHandle = *NULL;
         SetFileError(ERR_FILE_ACCESS: '': 'Null file handle');
         RETURN *NULL;
       ENDIF;
       
       // Allocate buffer handle
       buffer = %ALLOC(%SIZE(BufferHandle));
       IF buffer = *NULL;
         SetMemoryError(ERR_MEM_ALLOC: 'InitBuffer');
         RETURN *NULL;
       ENDIF;
       
       // Allocate position structure
       position = %ALLOC(%SIZE(Position));
       IF position = *NULL;
         DEALLOC buffer;
         SetMemoryError(ERR_MEM_ALLOC: 'InitBuffer - position');
         RETURN *NULL;
       ENDIF;
       
       // Initialize buffer
       CLEAR bufferDs;
       bufferDs.fileHandle = fileHandle;
       bufferDs.bufferSize = BUF_SIZE_ACTIV;
       bufferDs.bufferPos = 0;
       bufferDs.bytesInBuf = 0;
       bufferDs.bytesInAhead = 0;
       bufferDs.isEOF = *OFF;
       bufferDs.position = position;
       
       // Initialize position
       CLEAR positionDs;
       positionDs.line = 1;
       positionDs.column = 1;
       positionDs.offset = 0;
       
       // Fill initial buffer
       RefillBuffer(buffer);
       
       RETURN buffer;
      /END-FREE
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
      /FREE
       IF buffer = *NULL;
         RETURN *OFF;
       ENDIF;
       
       // Free position structure
       IF bufferDs.position <> *NULL;
         DEALLOC bufferDs.position;
       ENDIF;
       
       // Free buffer
       DEALLOC buffer;
       
       RETURN *ON;
      /END-FREE
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
      /FREE
       IF buffer = *NULL;
         RETURN *OFF;
       ENDIF;
       
       IF bufferDs.isEOF;
         RETURN *OFF;
       ENDIF;
       
       // Move read-ahead to active buffer if available
       IF bufferDs.bytesInAhead > 0;
         bufferDs.buffer = %SUBST(bufferDs.readAhead: 1:
                                  bufferDs.bytesInAhead);
         bufferDs.bytesInBuf = bufferDs.bytesInAhead;
         bufferDs.bufferPos = 0;
         bufferDs.bytesInAhead = 0;
       ELSE;
         // Read into active buffer
         bytesRead = ReadChunk(bufferDs.fileHandle: tempBuf:
                               BUF_SIZE_ACTIV);
         
         IF bytesRead < 0;
           RETURN *OFF;
         ENDIF;
         
         IF bytesRead = 0;
           bufferDs.isEOF = *ON;
           RETURN *OFF;
         ENDIF;
         
         bufferDs.buffer = %SUBST(tempBuf: 1: bytesRead);
         bufferDs.bytesInBuf = bytesRead;
         bufferDs.bufferPos = 0;
       ENDIF;
       
       // Read ahead if not at EOF
       IF NOT IsEOF(bufferDs.fileHandle);
         bytesRead = ReadChunk(bufferDs.fileHandle: tempBuf:
                               BUF_SIZE_AHEAD);
         
         IF bytesRead > 0;
           bufferDs.readAhead = %SUBST(tempBuf: 1: bytesRead);
           bufferDs.bytesInAhead = bytesRead;
         ENDIF;
       ENDIF;
       
       RETURN *ON;
      /END-FREE
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
      /FREE
       IF buffer = *NULL;
         RETURN x'00';
       ENDIF;
       
       // Check if buffer needs refill
       IF bufferDs.bufferPos >= bufferDs.bytesInBuf;
         IF NOT RefillBuffer(buffer);
           RETURN x'00';
         ENDIF;
       ENDIF;
       
       // Return character at current position
       RETURN %SUBST(bufferDs.buffer: bufferDs.bufferPos + 1: 1);
      /END-FREE
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
      /FREE
       IF buffer = *NULL;
         RETURN x'00';
       ENDIF;
       
       // Check if buffer needs refill
       IF bufferDs.bufferPos >= bufferDs.bytesInBuf;
         IF NOT RefillBuffer(buffer);
           RETURN x'00';
         ENDIF;
       ENDIF;
       
       // Get character
       char = %SUBST(bufferDs.buffer: bufferDs.bufferPos + 1: 1);
       
       // Advance buffer position
       bufferDs.bufferPos = bufferDs.bufferPos + 1;
       
       // Update position tracking
       positionDs.offset = positionDs.offset + 1;
       
       IF char = x'0A' OR char = x'0D';  // Newline (LF or CR)
         // Handle CR+LF as single newline
         IF char = x'0D';
           IF PeekChar(buffer) = x'0A';
             bufferDs.bufferPos = bufferDs.bufferPos + 1;
             positionDs.offset = positionDs.offset + 1;
           ENDIF;
         ENDIF;
         
         positionDs.line = positionDs.line + 1;
         positionDs.column = 1;
       ELSE;
         positionDs.column = positionDs.column + 1;
       ENDIF;
       
       // Check if we need to refill soon
       IF bufferDs.bytesInBuf - bufferDs.bufferPos < BUF_REFILL_THR;
         IF bufferDs.bytesInAhead = 0 AND NOT bufferDs.isEOF;
           RefillBuffer(buffer);
         ENDIF;
       ENDIF;
       
       RETURN char;
      /END-FREE
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
      /FREE
       IF buffer = *NULL;
         RETURN *OFF;
       ENDIF;
       
       IF bufferDs.bufferPos = 0;
         RETURN *OFF;  // Can't unread past buffer start
       ENDIF;
       
       bufferDs.bufferPos = bufferDs.bufferPos - 1;
       positionDs.offset = positionDs.offset - 1;
       
       // Note: Column/line tracking not reversed (complex with newlines)
       // This is acceptable for limited unread use cases
       
       RETURN *ON;
      /END-FREE
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
      /FREE
       IF buffer = *NULL;
         RETURN *ON;
       ENDIF;
       
       RETURN (bufferDs.isEOF AND
               bufferDs.bufferPos >= bufferDs.bytesInBuf);
      /END-FREE
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
      /FREE
       CLEAR result;
       
       IF buffer = *NULL OR bufferDs.position = *NULL;
         RETURN result;
       ENDIF;
       
       result = positionDs;
       RETURN result;
      /END-FREE
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
      /FREE
       IF buffer = *NULL OR bufferDs.position = *NULL;
         RETURN 0;
       ENDIF;
       
       RETURN positionDs.line;
      /END-FREE
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
      /FREE
       IF buffer = *NULL OR bufferDs.position = *NULL;
         RETURN 0;
       ENDIF;
       
       RETURN positionDs.column;
      /END-FREE
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
      /FREE
       IF buffer = *NULL OR bufferDs.position = *NULL;
         RETURN 0;
       ENDIF;
       
       RETURN positionDs.offset;
      /END-FREE
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
      /FREE
       IF buffer = *NULL;
         RETURN *OFF;
       ENDIF;
       
       char = PeekChar(buffer);
       
       DOW char = ' ' OR char = x'09' OR    // Space, Tab
           char = x'0A' OR char = x'0D';    // LF, CR
         
         ReadChar(buffer);
         
         IF IsBufferEOF(buffer);
           RETURN *ON;
         ENDIF;
         
         char = PeekChar(buffer);
       ENDDO;
       
       RETURN *ON;
      /END-FREE
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
      /FREE
       result = '';
       
       IF buffer = *NULL OR length <= 0;
         RETURN result;
       ENDIF;
       
       pos = bufferDs.bufferPos;
       
       FOR i = 1 TO length;
         IF pos >= bufferDs.bytesInBuf;
           LEAVE;
         ENDIF;
         
         result = result + %SUBST(bufferDs.buffer: pos + 1: 1);
         pos = pos + 1;
       ENDFOR;
       
       RETURN result;
      /END-FREE
     P PeekString      E

      *=====================================================================
      * End of JSONBUF
      *=====================================================================