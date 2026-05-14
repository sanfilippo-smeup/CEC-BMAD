      *=====================================================================
      * JSONERR - Error Handling Framework for RPGLE-Json Query Utility
      *=====================================================================
      * Description: Provides consistent error handling, reporting, and
      *              cleanup across all components.
      *
      * Author: Mauro
      * Date: 2026-04-28
      * Version: 1.1 (Refactored to fixed-form)
      *
      * Story: E1-S5 - Error Handling Framework
      *=====================================================================

      *---------------------------------------------------------------------
      * Copy Data Structures
      *---------------------------------------------------------------------
     D/COPY QRPGLESRC,JSONDATA

      *---------------------------------------------------------------------
      * Global Error State
      *---------------------------------------------------------------------
     D gErrorInfo      DS                  LIKEDS(ErrorInfo)
     D gHasError       S               N   INZ(*OFF)
     D gIndicator35    S               N   INZ(*OFF)

      *=====================================================================
      * Procedure: InitError
      * Purpose: Initialize error handling system
      *=====================================================================
     P InitError       B                   EXPORT
     D InitError       PI              N
      *
     D success         S               N   INZ(*ON)
      *
     C                   CLEAR                   gErrorInfo
     C                   EVAL      gHasError = *OFF
     C                   EVAL      gIndicator35 = *OFF
      *
     C                   RETURN    success
     P InitError       E

      *=====================================================================
      * Procedure: SetError
      * Purpose: Set error information and indicator
      *=====================================================================
     P SetError        B                   EXPORT
     D SetError        PI              N
     D   code                        10A   CONST
     D   msg                        256A   CONST VARYING
     D   line                        10I 0 CONST OPTIONS(*NOPASS)
     D   col                         10I 0 CONST OPTIONS(*NOPASS)
     D   ctx                        128A   CONST VARYING OPTIONS(*NOPASS)
      *
     D parmCount       S             10I 0
      *
      * Set error code
     C                   EVAL      gErrorInfo.errorCode = code
      *
      * Set error message
     C                   EVAL      gErrorInfo.message = msg
      *
      * Set position if provided
     C                   EVAL      parmCount = %PARMS()
     C                   IF        parmCount >= 3
     C                   EVAL      gErrorInfo.line = line
     C                   ELSE
     C                   EVAL      gErrorInfo.line = 0
     C                   ENDIF
      *
     C                   IF        parmCount >= 4
     C                   EVAL      gErrorInfo.column = col
     C                   ELSE
     C                   EVAL      gErrorInfo.column = 0
     C                   ENDIF
      *
      * Set context if provided
     C                   IF        parmCount >= 5
     C                   EVAL      gErrorInfo.context = ctx
     C                   ELSE
     C                   EVAL      gErrorInfo.context = ''
     C                   ENDIF
      *
      * Set error flags
     C                   EVAL      gHasError = *ON
     C                   EVAL      gIndicator35 = *ON
     C                   SETON                                        35
      *
     C                   RETURN    *ON
     P SetError        E

      *=====================================================================
      * Procedure: GetError
      * Purpose: Retrieve current error information
      *=====================================================================
     P GetError        B                   EXPORT
     D GetError        PI              N
     D   errorInfo                         LIKEDS(ErrorInfo)
      *
     C                   IF        gHasError
     C                   EVAL      errorInfo = gErrorInfo
     C                   RETURN    *ON
     C                   ELSE
     C                   CLEAR                   errorInfo
     C                   RETURN    *OFF
     C                   ENDIF
     P GetError        E

      *=====================================================================
      * Procedure: ClearError
      * Purpose: Clear current error state
      *=====================================================================
     P ClearError      B                   EXPORT
     D ClearError      PI              N
      *
     C                   CLEAR                   gErrorInfo
     C                   EVAL      gHasError = *OFF
     C                   EVAL      gIndicator35 = *OFF
     C                   SETOFF                                       35
      *
     C                   RETURN    *ON
     P ClearError      E

      *=====================================================================
      * Procedure: IsError
      * Purpose: Check if an error is currently set
      *=====================================================================
     P IsError         B                   EXPORT
     D IsError         PI              N
      *
     C                   RETURN    gHasError
     P IsError         E

      *=====================================================================
      * Procedure: GetErrorCode
      * Purpose: Get current error code
      *=====================================================================
     P GetErrorCode    B                   EXPORT
     D GetErrorCode    PI            10A
      *
     C                   IF        gHasError
     C                   RETURN    gErrorInfo.errorCode
     C                   ELSE
     C                   RETURN    ''
     C                   ENDIF
     P GetErrorCode    E

      *=====================================================================
      * Procedure: GetErrorMsg
      * Purpose: Get current error message
      *=====================================================================
     P GetErrorMsg     B                   EXPORT
     D GetErrorMsg     PI           256A   VARYING
      *
     C                   IF        gHasError
     C                   RETURN    gErrorInfo.message
     C                   ELSE
     C                   RETURN    ''
     C                   ENDIF
     P GetErrorMsg     E

      *=====================================================================
      * Procedure: FormatError
      * Purpose: Format error information as a readable string
      *=====================================================================
     P FormatError     B                   EXPORT
     D FormatError     PI           512A   VARYING
     D   errorInfo                         LIKEDS(ErrorInfo) CONST
      *
     D formatted       S            512A   VARYING
      *
      * Start with error code and message
     C                   EVAL      formatted = 'Error ' +
     C                               %TRIM(errorInfo.errorCode) + ': ' +
     C                               errorInfo.message
      *
      * Add position if available
     C                   IF        errorInfo.line > 0
     C                   EVAL      formatted = formatted + ' at line ' +
     C                               %CHAR(errorInfo.line)
      *
     C                   IF        errorInfo.column > 0
     C                   EVAL      formatted = formatted + ', column ' +
     C                               %CHAR(errorInfo.column)
     C                   ENDIF
     C                   ENDIF
      *
      * Add context if available
     C                   IF        errorInfo.context <> ''
     C                   EVAL      formatted = formatted + ' [' +
     C                               errorInfo.context + ']'
     C                   ENDIF
      *
     C                   RETURN    formatted
     P FormatError     E

      *=====================================================================
      * Procedure: FormatCurrentError
      * Purpose: Format current error as a readable string
      *=====================================================================
     P FormatCurrentError...
     P                 B                   EXPORT
     D FormatCurrentError...
     D                 PI           512A   VARYING
      *
     C                   IF        gHasError
     C                   RETURN    FormatError(gErrorInfo)
     C                   ELSE
     C                   RETURN    'No error'
     C                   ENDIF
     P FormatCurrentError...
     P                 E

      *=====================================================================
      * Procedure: SetFileError
      * Purpose: Set a file-related error
      *=====================================================================
     P SetFileError    B                   EXPORT
     D SetFileError    PI              N
     D   code                        10A   CONST
     D   path                       256A   CONST VARYING
     D   detail                     128A   CONST VARYING OPTIONS(*NOPASS)
      *
     D msg             S            256A   VARYING
     D ctx             S            128A   VARYING
     D parmCount       S             10I 0
      *
      * Build error message
     C                   EVAL      msg = 'File error: ' + path
      *
      * Add detail if provided
     C                   EVAL      parmCount = %PARMS()
     C                   IF        parmCount >= 3
     C                   EVAL      msg = msg + ' - ' + detail
     C                   ENDIF
      *
      * Set context
     C                   EVAL      ctx = 'File I/O'
      *
     C                   RETURN    SetError(code: msg: 0: 0: ctx)
     P SetFileError    E

      *=====================================================================
      * Procedure: SetParseError
      * Purpose: Set a parsing-related error
      *=====================================================================
     P SetParseError   B                   EXPORT
     D SetParseError   PI              N
     D   code                        10A   CONST
     D   msg                        256A   CONST VARYING
     D   line                        10I 0 CONST
     D   col                         10I 0 CONST
     D   near                        64A   CONST VARYING OPTIONS(*NOPASS)
      *
     D fullMsg         S            256A   VARYING
     D ctx             S            128A   VARYING
     D parmCount       S             10I 0
      *
     C                   EVAL      fullMsg = msg
      *
      * Add "near" context if provided
     C                   EVAL      parmCount = %PARMS()
     C                   IF        parmCount >= 5 AND near <> ''
     C                   EVAL      ctx = 'Near: ' + near
     C                   ELSE
     C                   EVAL      ctx = 'JSON Parsing'
     C                   ENDIF
      *
     C                   RETURN    SetError(code: fullMsg: line: col: ctx)
     P SetParseError   E

      *=====================================================================
      * Procedure: SetQueryError
      * Purpose: Set a query-related error
      *=====================================================================
     P SetQueryError   B                   EXPORT
     D SetQueryError   PI              N
     D   code                        10A   CONST
     D   msg                        256A   CONST VARYING
     D   query                      256A   CONST VARYING OPTIONS(*NOPASS)
      *
     D fullMsg         S            256A   VARYING
     D ctx             S            128A   VARYING
     D parmCount       S             10I 0
      *
     C                   EVAL      fullMsg = msg
      *
      * Add query context if provided
     C                   EVAL      parmCount = %PARMS()
     C                   IF        parmCount >= 3 AND query <> ''
     C                   EVAL      ctx = 'Query: ' + query
     C                   ELSE
     C                   EVAL      ctx = 'JSONPath Query'
     C                   ENDIF
      *
     C                   RETURN    SetError(code: fullMsg: 0: 0: ctx)
     P SetQueryError   E

      *=====================================================================
      * Procedure: SetMemoryError
      * Purpose: Set a memory-related error
      *=====================================================================
     P SetMemoryError  B                   EXPORT
     D SetMemoryError  PI              N
     D   code                        10A   CONST
     D   operation                   64A   CONST VARYING
      *
     D msg             S            256A   VARYING
     D ctx             S            128A   VARYING
      *
     C                   EVAL      msg = 'Memory error during: ' + operation
     C                   EVAL      ctx = 'Memory Management'
      *
     C                   RETURN    SetError(code: msg: 0: 0: ctx)
     P SetMemoryError  E

      *=====================================================================
      * Procedure: IsFileError
      * Purpose: Check if current error is a file error
      *=====================================================================
     P IsFileError     B                   EXPORT
     D IsFileError     PI              N
      *
     C                   IF        NOT gHasError
     C                   RETURN    *OFF
     C                   ENDIF
      *
     C                   RETURN    (gErrorInfo.errorCode >= ERR_FILE_MIN AND
     C                               gErrorInfo.errorCode <= ERR_FILE_MAX)
     P IsFileError     E

      *=====================================================================
      * Procedure: IsParseError
      * Purpose: Check if current error is a parse error
      *=====================================================================
     P IsParseError    B                   EXPORT
     D IsParseError    PI              N
      *
     C                   IF        NOT gHasError
     C                   RETURN    *OFF
     C                   ENDIF
      *
     C                   RETURN    (gErrorInfo.errorCode >= ERR_PARSE_MIN AND
     C                               gErrorInfo.errorCode <= ERR_PARSE_MAX)
     P IsParseError    E

      *=====================================================================
      * Procedure: IsQueryError
      * Purpose: Check if current error is a query error
      *=====================================================================
     P IsQueryError    B                   EXPORT
     D IsQueryError    PI              N
      *
     C                   IF        NOT gHasError
     C                   RETURN    *OFF
     C                   ENDIF
      *
     C                   RETURN    (gErrorInfo.errorCode >= ERR_QUERY_MIN AND
     C                               gErrorInfo.errorCode <= ERR_QUERY_MAX)
     P IsQueryError    E

      *=====================================================================
      * Procedure: IsRuntimeError
      * Purpose: Check if current error is a runtime error
      *=====================================================================
     P IsRuntimeError  B                   EXPORT
     D IsRuntimeError  PI              N
      *
     C                   IF        NOT gHasError
     C                   RETURN    *OFF
     C                   ENDIF
      *
     C                   RETURN    (gErrorInfo.errorCode >= ERR_RUNTIME_MIN AND
     C                               gErrorInfo.errorCode <= ERR_RUNTIME_MAX)
     P IsRuntimeError  E

      *=====================================================================
      * End of JSONERR
      *=====================================================================
