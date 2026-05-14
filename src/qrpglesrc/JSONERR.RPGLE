      *=====================================================================
      * JSONERR - Error Handling Framework for RPGLE-Json Query Utility
      *=====================================================================
      * Description: Provides consistent error handling, reporting, and
      *              cleanup across all components.
      *
      * Author: Mauro
      * Date: 2026-04-28
      * Version: 1.0
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
      /FREE
       // Clear global error state
       CLEAR gErrorInfo;
       gHasError = *OFF;
       gIndicator35 = *OFF;
       
       RETURN success;
      /END-FREE
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
      /FREE
       // Set error code
       gErrorInfo.errorCode = code;
       
       // Set error message
       gErrorInfo.message = msg;
       
       // Set position if provided
       parmCount = %PARMS();
       IF parmCount >= 3;
         gErrorInfo.line = line;
       ELSE;
         gErrorInfo.line = 0;
       ENDIF;
       
       IF parmCount >= 4;
         gErrorInfo.column = col;
       ELSE;
         gErrorInfo.column = 0;
       ENDIF;
       
       // Set context if provided
       IF parmCount >= 5;
         gErrorInfo.context = ctx;
       ELSE;
         gErrorInfo.context = '';
       ENDIF;
       
       // Set error flags
       gHasError = *ON;
       gIndicator35 = *ON;
       *IN35 = *ON;
       
       RETURN *ON;
      /END-FREE
     P SetError        E

      *=====================================================================
      * Procedure: GetError
      * Purpose: Retrieve current error information
      *=====================================================================
     P GetError        B                   EXPORT
     D GetError        PI              N
     D   errorInfo                         LIKEDS(ErrorInfo)
      *
      /FREE
       IF gHasError;
         errorInfo = gErrorInfo;
         RETURN *ON;
       ELSE;
         CLEAR errorInfo;
         RETURN *OFF;
       ENDIF;
      /END-FREE
     P GetError        E

      *=====================================================================
      * Procedure: ClearError
      * Purpose: Clear current error state
      *=====================================================================
     P ClearError      B                   EXPORT
     D ClearError      PI              N
      *
      /FREE
       CLEAR gErrorInfo;
       gHasError = *OFF;
       gIndicator35 = *OFF;
       *IN35 = *OFF;
       
       RETURN *ON;
      /END-FREE
     P ClearError      E

      *=====================================================================
      * Procedure: IsError
      * Purpose: Check if an error is currently set
      *=====================================================================
     P IsError         B                   EXPORT
     D IsError         PI              N
      *
      /FREE
       RETURN gHasError;
      /END-FREE
     P IsError         E

      *=====================================================================
      * Procedure: GetErrorCode
      * Purpose: Get current error code
      *=====================================================================
     P GetErrorCode    B                   EXPORT
     D GetErrorCode    PI            10A
      *
      /FREE
       IF gHasError;
         RETURN gErrorInfo.errorCode;
       ELSE;
         RETURN '';
       ENDIF;
      /END-FREE
     P GetErrorCode    E

      *=====================================================================
      * Procedure: GetErrorMsg
      * Purpose: Get current error message
      *=====================================================================
     P GetErrorMsg     B                   EXPORT
     D GetErrorMsg     PI           256A   VARYING
      *
      /FREE
       IF gHasError;
         RETURN gErrorInfo.message;
       ELSE;
         RETURN '';
       ENDIF;
      /END-FREE
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
      /FREE
       // Start with error code and message
       formatted = 'Error ' + %TRIM(errorInfo.errorCode) + ': ' +
                   errorInfo.message;
       
       // Add position if available
       IF errorInfo.line > 0;
         formatted = formatted + ' at line ' +
                     %CHAR(errorInfo.line);
         
         IF errorInfo.column > 0;
           formatted = formatted + ', column ' +
                       %CHAR(errorInfo.column);
         ENDIF;
       ENDIF;
       
       // Add context if available
       IF errorInfo.context <> '';
         formatted = formatted + ' [' + errorInfo.context + ']';
       ENDIF;
       
       RETURN formatted;
      /END-FREE
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
      /FREE
       IF gHasError;
         RETURN FormatError(gErrorInfo);
       ELSE;
         RETURN 'No error';
       ENDIF;
      /END-FREE
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
      /FREE
       // Build error message
       msg = 'File error: ' + path;
       
       // Add detail if provided
       parmCount = %PARMS();
       IF parmCount >= 3;
         msg = msg + ' - ' + detail;
       ENDIF;
       
       // Set context
       ctx = 'File I/O';
       
       RETURN SetError(code: msg: 0: 0: ctx);
      /END-FREE
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
      /FREE
       fullMsg = msg;
       
       // Add "near" context if provided
       parmCount = %PARMS();
       IF parmCount >= 5 AND near <> '';
         ctx = 'Near: ' + near;
       ELSE;
         ctx = 'JSON Parsing';
       ENDIF;
       
       RETURN SetError(code: fullMsg: line: col: ctx);
      /END-FREE
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
      /FREE
       fullMsg = msg;
       
       // Add query context if provided
       parmCount = %PARMS();
       IF parmCount >= 3 AND query <> '';
         ctx = 'Query: ' + query;
       ELSE;
         ctx = 'JSONPath Query';
       ENDIF;
       
       RETURN SetError(code: fullMsg: 0: 0: ctx);
      /END-FREE
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
      /FREE
       msg = 'Memory error during: ' + operation;
       ctx = 'Memory Management';
       
       RETURN SetError(code: msg: 0: 0: ctx);
      /END-FREE
     P SetMemoryError  E

      *=====================================================================
      * Procedure: IsFileError
      * Purpose: Check if current error is a file error
      *=====================================================================
     P IsFileError     B                   EXPORT
     D IsFileError     PI              N
      *
      /FREE
       IF NOT gHasError;
         RETURN *OFF;
       ENDIF;
       
       RETURN (gErrorInfo.errorCode >= ERR_FILE_MIN AND
               gErrorInfo.errorCode <= ERR_FILE_MAX);
      /END-FREE
     P IsFileError     E

      *=====================================================================
      * Procedure: IsParseError
      * Purpose: Check if current error is a parse error
      *=====================================================================
     P IsParseError    B                   EXPORT
     D IsParseError    PI              N
      *
      /FREE
       IF NOT gHasError;
         RETURN *OFF;
       ENDIF;
       
       RETURN (gErrorInfo.errorCode >= ERR_PARSE_MIN AND
               gErrorInfo.errorCode <= ERR_PARSE_MAX);
      /END-FREE
     P IsParseError    E

      *=====================================================================
      * Procedure: IsQueryError
      * Purpose: Check if current error is a query error
      *=====================================================================
     P IsQueryError    B                   EXPORT
     D IsQueryError    PI              N
      *
      /FREE
       IF NOT gHasError;
         RETURN *OFF;
       ENDIF;
       
       RETURN (gErrorInfo.errorCode >= ERR_QUERY_MIN AND
               gErrorInfo.errorCode <= ERR_QUERY_MAX);
      /END-FREE
     P IsQueryError    E

      *=====================================================================
      * Procedure: IsRuntimeError
      * Purpose: Check if current error is a runtime error
      *=====================================================================
     P IsRuntimeError  B                   EXPORT
     D IsRuntimeError  PI              N
      *
      /FREE
       IF NOT gHasError;
         RETURN *OFF;
       ENDIF;
       
       RETURN (gErrorInfo.errorCode >= ERR_RUNTIME_MIN AND
               gErrorInfo.errorCode <= ERR_RUNTIME_MAX);
      /END-FREE
     P IsRuntimeError  E

      *=====================================================================
      * End of JSONERR
      *=====================================================================