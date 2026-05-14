      *=====================================================================
      * JSONH - Main Header File for RPGLE-Json Query Utility
      *=====================================================================
      * Description: Main /COPY member that includes all necessary
      *              prototypes and data structures for using the
      *              RPGLE-Json library.
      *
      * Usage: /COPY QRPGLESRC,JSONH
      *
      * Author: Mauro
      * Date: 2026-04-28
      * Version: 1.0
      *=====================================================================

      *---------------------------------------------------------------------
      * Include Core Data Structures
      *---------------------------------------------------------------------
     D/COPY QRPGLESRC,JSONDATA

      *---------------------------------------------------------------------
      * Error Handling Prototypes
      *---------------------------------------------------------------------
     D InitError       PR              N
     D SetError        PR              N
     D   code                        10A   CONST
     D   msg                        256A   CONST VARYING
     D   line                        10I 0 CONST OPTIONS(*NOPASS)
     D   col                         10I 0 CONST OPTIONS(*NOPASS)
     D   ctx                        128A   CONST VARYING OPTIONS(*NOPASS)
     D GetError        PR              N
     D   errorInfo                         LIKEDS(ErrorInfo)
     D ClearError      PR              N
     D IsError         PR              N
     D GetErrorCode    PR            10A
     D GetErrorMsg     PR           256A   VARYING
     D FormatError     PR           512A   VARYING
     D   errorInfo                         LIKEDS(ErrorInfo) CONST
     D FormatCurrentError...
     D                 PR           512A   VARYING
     D SetFileError    PR              N
     D   code                        10A   CONST
     D   path                       256A   CONST VARYING
     D   detail                     128A   CONST VARYING OPTIONS(*NOPASS)
     D SetParseError   PR              N
     D   code                        10A   CONST
     D   msg                        256A   CONST VARYING
     D   line                        10I 0 CONST
     D   col                         10I 0 CONST
     D   near                        64A   CONST VARYING OPTIONS(*NOPASS)
     D SetQueryError   PR              N
     D   code                        10A   CONST
     D   msg                        256A   CONST VARYING
     D   query                      256A   CONST VARYING OPTIONS(*NOPASS)
     D SetMemoryError  PR              N
     D   code                        10A   CONST
     D   operation                   64A   CONST VARYING
     D IsFileError     PR              N
     D IsParseError    PR              N
     D IsQueryError    PR              N
     D IsRuntimeError  PR              N

      *---------------------------------------------------------------------
      * String Utility Prototypes
      *---------------------------------------------------------------------
     D StrLen          PR            10I 0
     D   str                      32767A   CONST VARYING
     D StrLenTrim      PR            10I 0
     D   str                      32767A   CONST VARYING
     D StrCat          PR         32767A   VARYING
     D   str1                     32767A   CONST VARYING
     D   str2                     32767A   CONST VARYING
     D StrCat3         PR         32767A   VARYING
     D   str1                     32767A   CONST VARYING
     D   str2                     32767A   CONST VARYING
     D   str3                     32767A   CONST VARYING
     D StrCmp          PR            10I 0
     D   str1                     32767A   CONST VARYING
     D   str2                     32767A   CONST VARYING
     D StrCmpI         PR            10I 0
     D   str1                     32767A   CONST VARYING
     D   str2                     32767A   CONST VARYING
     D StrEquals       PR              N
     D   str1                     32767A   CONST VARYING
     D   str2                     32767A   CONST VARYING
     D StrEqualsI      PR              N
     D   str1                     32767A   CONST VARYING
     D   str2                     32767A   CONST VARYING
     D StrCopy         PR              N
     D   dest                     32767A   VARYING
     D   src                      32767A   CONST VARYING
     D StrTrim         PR         32767A   VARYING
     D   str                      32767A   CONST VARYING
     D StrTrimL        PR         32767A   VARYING
     D   str                      32767A   CONST VARYING
     D StrTrimR        PR         32767A   VARYING
     D   str                      32767A   CONST VARYING
     D StrUpper        PR         32767A   VARYING
     D   str                      32767A   CONST VARYING
     D StrLower        PR         32767A   VARYING
     D   str                      32767A   CONST VARYING
     D StrSubstr       PR         32767A   VARYING
     D   str                      32767A   CONST VARYING
     D   start                       10I 0 CONST
     D   length                      10I 0 CONST OPTIONS(*NOPASS)
     D StrPos          PR            10I 0
     D   str                      32767A   CONST VARYING
     D   search                   32767A   CONST VARYING
     D   start                       10I 0 CONST OPTIONS(*NOPASS)
     D StrReplace      PR         32767A   VARYING
     D   str                      32767A   CONST VARYING
     D   search                   32767A   CONST VARYING
     D   replace                  32767A   CONST VARYING
     D StrStartsWith   PR              N
     D   str                      32767A   CONST VARYING
     D   prefix                   32767A   CONST VARYING
     D StrEndsWith     PR              N
     D   str                      32767A   CONST VARYING
     D   suffix                   32767A   CONST VARYING
     D StrContains     PR              N
     D   str                      32767A   CONST VARYING
     D   search                   32767A   CONST VARYING
     D StrIsEmpty      PR              N
     D   str                      32767A   CONST VARYING
     D StrIsBlank      PR              N
     D   str                      32767A   CONST VARYING
     D StrRepeat       PR         32767A   VARYING
     D   str                      32767A   CONST VARYING
     D   count                       10I 0 CONST
     D StrPadLeft      PR         32767A   VARYING
     D   str                      32767A   CONST VARYING
     D   length                      10I 0 CONST
     D   padChar                      1A   CONST OPTIONS(*NOPASS)
     D StrPadRight     PR         32767A   VARYING
     D   str                      32767A   CONST VARYING
     D   length                      10I 0 CONST
     D   padChar                      1A   CONST OPTIONS(*NOPASS)

      *---------------------------------------------------------------------
      * Memory Management Prototypes
      *---------------------------------------------------------------------
     D InitMemoryPool  PR              *
     D   poolSize                    10I 0 CONST OPTIONS(*NOPASS)
     D CleanupPool     PR              N
     D   pool                          *   CONST
     D AllocNode       PR              *
     D   pool                          *   CONST
     D FreeNode        PR              N
     D   pool                          *   CONST
     D   node                          *   CONST
     D FreeNodeTree    PR              N
     D   pool                          *   CONST
     D   node                          *   CONST
     D GetPoolStats    PR                  LIKEDS(PoolStats)
     D   pool                          *   CONST
     D GetPoolUsage    PR            10I 0
     D   pool                          *   CONST
     D IsPoolExhausted...
     D                 PR              N
     D   pool                          *   CONST
     D GetPoolCapacity...
     D                 PR            10I 0
     D   pool                          *   CONST
     D ResetPoolStats  PR              N
     D   pool                          *   CONST
     D CreateNode      PR              *
     D   pool                          *   CONST
     D   nodeType                     1A   CONST
     D CreateNodeWithValue...
     D                 PR              *
     D   pool                          *   CONST
     D   nodeType                     1A   CONST
     D   value                      256A   CONST VARYING
     D CreateNodeWithName...
     D                 PR              *
     D   pool                          *   CONST
     D   nodeType                     1A   CONST
     D   name                       256A   CONST VARYING

      *---------------------------------------------------------------------
      * File I/O Prototypes
      *---------------------------------------------------------------------
     D OpenFile        PR              *
     D   path                       256A   CONST VARYING
     D CloseFile       PR              N
     D   handle                        *   CONST
     D ReadChunk       PR            10I 0
     D   handle                        *   CONST
     D   buffer                    4096A
     D   size                        10I 0 CONST OPTIONS(*NOPASS)
     D GetFileSize     PR            20I 0
     D   handle                        *   CONST
     D GetFilePosition...
     D                 PR            20I 0
     D   handle                        *   CONST
     D IsEOF           PR              N
     D   handle                        *   CONST
     D HasFileError    PR              N
     D   handle                        *   CONST
     D SeekFile        PR              N
     D   handle                        *   CONST
     D   offset                      10I 0 CONST
     D   whence                      10I 0 CONST OPTIONS(*NOPASS)
     D RewindFile      PR              N
     D   handle                        *   CONST
     D GetFilePath     PR           256A   VARYING
     D   handle                        *   CONST
     D FileExists      PR              N
     D   path                       256A   CONST VARYING

      *---------------------------------------------------------------------
      * Buffer Management Prototypes
      *---------------------------------------------------------------------
     D InitBuffer      PR              *
     D   fileHandle                    *   CONST
     D CleanupBuffer   PR              N
     D   buffer                        *   CONST
     D RefillBuffer    PR              N
     D   buffer                        *   CONST
     D PeekChar        PR             1A
     D   buffer                        *   CONST
     D ReadChar        PR             1A
     D   buffer                        *   CONST
     D UnreadChar      PR              N
     D   buffer                        *   CONST
     D IsBufferEOF     PR              N
     D   buffer                        *   CONST
     D GetPosition     PR                  LIKEDS(Position)
     D   buffer                        *   CONST
     D GetLine         PR            10I 0
     D   buffer                        *   CONST
     D GetColumn       PR            10I 0
     D   buffer                        *   CONST
     D GetOffset       PR            10I 0
     D   buffer                        *   CONST
     D SkipWhitespace  PR              N
     D   buffer                        *   CONST
     D PeekString      PR           256A   VARYING
     D   buffer                        *   CONST
     D   length                      10I 0 CONST

      *=====================================================================
      * End of JSONH
      *=====================================================================