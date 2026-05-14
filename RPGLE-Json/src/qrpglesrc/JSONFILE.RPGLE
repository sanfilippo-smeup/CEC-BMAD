      *=====================================================================
      * JSONFILE - IFS File Stream Reader for RPGLE-Json Query Utility
      *=====================================================================
      * Description: Provides streaming file I/O for reading JSON files
      *              from the IFS using C APIs.
      *
      * Author: Mauro
      * Date: 2026-04-28
      * Version: 1.0
      *
      * Story: E1-S1 - IFS File Stream Reader
      *=====================================================================

      *---------------------------------------------------------------------
      * Copy Data Structures
      *---------------------------------------------------------------------
     D/COPY QRPGLESRC,JSONDATA
     D/COPY QRPGLESRC,JSONERR

      *---------------------------------------------------------------------
      * IFS C API Prototypes
      *---------------------------------------------------------------------
     D open            PR            10I 0 EXTPROC('open')
     D   path                          *   VALUE OPTIONS(*STRING)
     D   oflag                       10I 0 VALUE
     D   mode                        10U 0 VALUE OPTIONS(*NOPASS)
     D   codepage                    10U 0 VALUE OPTIONS(*NOPASS)

     D read            PR            10I 0 EXTPROC('read')
     D   fd                          10I 0 VALUE
     D   buf                           *   VALUE
     D   nbyte                       10U 0 VALUE

     D close           PR            10I 0 EXTPROC('close')
     D   fd                          10I 0 VALUE

     D lseek           PR            10I 0 EXTPROC('lseek')
     D   fd                          10I 0 VALUE
     D   offset                      10I 0 VALUE
     D   whence                      10I 0 VALUE

     D stat            PR            10I 0 EXTPROC('stat')
     D   path                          *   VALUE OPTIONS(*STRING)
     D   buf                           *   VALUE

      *---------------------------------------------------------------------
      * IFS Constants
      *---------------------------------------------------------------------
     D O_RDONLY        C                   CONST(1)
     D O_WRONLY        C                   CONST(2)
     D O_RDWR          C                   CONST(4)
     D O_CREAT         C                   CONST(8)
     D O_EXCL          C                   CONST(16)
     D O_TRUNC         C                   CONST(64)
     D O_TEXTDATA      C                   CONST(16777216)
     D O_CCSID         C                   CONST(32)

     D SEEK_SET        C                   CONST(0)
     D SEEK_CUR        C                   CONST(1)
     D SEEK_END        C                   CONST(2)

     D S_IRWXU         C                   CONST(448)
     D S_IRUSR         C                   CONST(256)
     D S_IWUSR         C                   CONST(128)

      *---------------------------------------------------------------------
      * stat structure for file information
      *---------------------------------------------------------------------
     D statDs          DS                  QUALIFIED
     D   st_mode                     10U 0
     D   st_ino                      10U 0
     D   st_nlink                     5U 0
     D   st_pad1                      2A
     D   st_uid                      10U 0
     D   st_gid                      10U 0
     D   st_size                     10I 0
     D   st_atime                    10I 0
     D   st_mtime                    10I 0
     D   st_ctime                    10I 0
     D   st_dev                      10U 0
     D   st_blksize                  10U 0
     D   st_alc                      10U 0
     D   st_objtype                  11A
     D   st_codepage                  5U 0

      *=====================================================================
      * Procedure: OpenFile
      * Purpose: Open an IFS file for reading
      *=====================================================================
     P OpenFile        B                   EXPORT
     D OpenFile        PI              *
     D   path                       256A   CONST VARYING
      *
     D handle          S               *
     D handleDs        DS                  LIKEDS(FileHandle) BASED(handle)
     D fd              S             10I 0
     D rc              S             10I 0
      *
      /FREE
       // Allocate file handle
       handle = %ALLOC(%SIZE(FileHandle));
       IF handle = *NULL;
         SetFileError(ERR_MEM_ALLOC: path: 'Failed to allocate handle');
         RETURN *NULL;
       ENDIF;
       
       // Initialize handle
       CLEAR handleDs;
       handleDs.path = path;
       handleDs.isOpen = *OFF;
       handleDs.isEOF = *OFF;
       handleDs.hasError = *OFF;
       handleDs.position = 0;
       handleDs.size = 0;
       
       // Get file size
       rc = stat(%TRIM(path): %ADDR(statDs));
       IF rc = 0;
         handleDs.size = statDs.st_size;
       ENDIF;
       
       // Open file for reading (text mode, UTF-8)
       fd = open(%TRIM(path): O_RDONLY + O_TEXTDATA: S_IRUSR: 1208);
       IF fd < 0;
         DEALLOC handle;
         SetFileError(ERR_FILE_NOTFND: path: 'File not found or access denied');
         RETURN *NULL;
       ENDIF;
       
       handleDs.fd = fd;
       handleDs.isOpen = *ON;
       
       RETURN handle;
      /END-FREE
     P OpenFile        E

      *=====================================================================
      * Procedure: CloseFile
      * Purpose: Close an open file
      *=====================================================================
     P CloseFile       B                   EXPORT
     D CloseFile       PI              N
     D   handle                        *   CONST
      *
     D handleDs        DS                  LIKEDS(FileHandle) BASED(handle)
     D rc              S             10I 0
      *
      /FREE
       IF handle = *NULL;
         RETURN *OFF;
       ENDIF;
       
       IF handleDs.isOpen;
         rc = close(handleDs.fd);
         handleDs.isOpen = *OFF;
       ENDIF;
       
       DEALLOC handle;
       
       RETURN *ON;
      /END-FREE
     P CloseFile       E

      *=====================================================================
      * Procedure: ReadChunk
      * Purpose: Read a chunk of data from file
      *=====================================================================
     P ReadChunk       B                   EXPORT
     D ReadChunk       PI            10I 0
     D   handle                        *   CONST
     D   buffer                    4096A
     D   size                        10I 0 CONST OPTIONS(*NOPASS)
      *
     D handleDs        DS                  LIKEDS(FileHandle) BASED(handle)
     D bytesRead       S             10I 0
     D readSize        S             10I 0
     D parmCount       S             10I 0
      *
      /FREE
       IF handle = *NULL OR NOT handleDs.isOpen;
         RETURN -1;
       ENDIF;
       
       IF handleDs.isEOF;
         RETURN 0;
       ENDIF;
       
       // Determine read size
       parmCount = %PARMS();
       IF parmCount >= 3;
         readSize = size;
       ELSE;
         readSize = %SIZE(buffer);
       ENDIF;
       
       // Read from file
       bytesRead = read(handleDs.fd: %ADDR(buffer): readSize);
       
       IF bytesRead < 0;
         handleDs.hasError = *ON;
         SetFileError(ERR_FILE_READ: handleDs.path: 'Read error');
         RETURN -1;
       ENDIF;
       
       IF bytesRead = 0;
         handleDs.isEOF = *ON;
       ENDIF;
       
       handleDs.position = handleDs.position + bytesRead;
       
       RETURN bytesRead;
      /END-FREE
     P ReadChunk       E

      *=====================================================================
      * Procedure: GetFileSize
      * Purpose: Get size of file in bytes
      *=====================================================================
     P GetFileSize     B                   EXPORT
     D GetFileSize     PI            20I 0
     D   handle                        *   CONST
      *
     D handleDs        DS                  LIKEDS(FileHandle) BASED(handle)
      *
      /FREE
       IF handle = *NULL;
         RETURN 0;
       ENDIF;
       
       RETURN handleDs.size;
      /END-FREE
     P GetFileSize     E

      *=====================================================================
      * Procedure: GetFilePosition
      * Purpose: Get current position in file
      *=====================================================================
     P GetFilePosition...
     P                 B                   EXPORT
     D GetFilePosition...
     D                 PI            20I 0
     D   handle                        *   CONST
      *
     D handleDs        DS                  LIKEDS(FileHandle) BASED(handle)
      *
      /FREE
       IF handle = *NULL;
         RETURN 0;
       ENDIF;
       
       RETURN handleDs.position;
      /END-FREE
     P GetFilePosition...
     P                 E

      *=====================================================================
      * Procedure: IsEOF
      * Purpose: Check if end of file reached
      *=====================================================================
     P IsEOF           B                   EXPORT
     D IsEOF           PI              N
     D   handle                        *   CONST
      *
     D handleDs        DS                  LIKEDS(FileHandle) BASED(handle)
      *
      /FREE
       IF handle = *NULL;
         RETURN *ON;
       ENDIF;
       
       RETURN handleDs.isEOF;
      /END-FREE
     P IsEOF           E

      *=====================================================================
      * Procedure: HasFileError
      * Purpose: Check if file has error
      *=====================================================================
     P HasFileError    B                   EXPORT
     D HasFileError    PI              N
     D   handle                        *   CONST
      *
     D handleDs        DS                  LIKEDS(FileHandle) BASED(handle)
      *
      /FREE
       IF handle = *NULL;
         RETURN *ON;
       ENDIF;
       
       RETURN handleDs.hasError;
      /END-FREE
     P HasFileError    E

      *=====================================================================
      * Procedure: SeekFile
      * Purpose: Seek to position in file
      *=====================================================================
     P SeekFile        B                   EXPORT
     D SeekFile        PI              N
     D   handle                        *   CONST
     D   offset                      10I 0 CONST
     D   whence                      10I 0 CONST OPTIONS(*NOPASS)
      *
     D handleDs        DS                  LIKEDS(FileHandle) BASED(handle)
     D seekWhence      S             10I 0
     D rc              S             10I 0
     D parmCount       S             10I 0
      *
      /FREE
       IF handle = *NULL OR NOT handleDs.isOpen;
         RETURN *OFF;
       ENDIF;
       
       parmCount = %PARMS();
       IF parmCount >= 3;
         seekWhence = whence;
       ELSE;
         seekWhence = SEEK_SET;
       ENDIF;
       
       rc = lseek(handleDs.fd: offset: seekWhence);
       IF rc < 0;
         handleDs.hasError = *ON;
         SetFileError(ERR_FILE_READ: handleDs.path: 'Seek error');
         RETURN *OFF;
       ENDIF;
       
       handleDs.position = rc;
       handleDs.isEOF = *OFF;
       
       RETURN *ON;
      /END-FREE
     P SeekFile        E

      *=====================================================================
      * Procedure: RewindFile
      * Purpose: Rewind file to beginning
      *=====================================================================
     P RewindFile      B                   EXPORT
     D RewindFile      PI              N
     D   handle                        *   CONST
      *
      /FREE
       RETURN SeekFile(handle: 0: SEEK_SET);
      /END-FREE
     P RewindFile      E

      *=====================================================================
      * Procedure: GetFilePath
      * Purpose: Get file path
      *=====================================================================
     P GetFilePath     B                   EXPORT
     D GetFilePath     PI           256A   VARYING
     D   handle                        *   CONST
      *
     D handleDs        DS                  LIKEDS(FileHandle) BASED(handle)
      *
      /FREE
       IF handle = *NULL;
         RETURN '';
       ENDIF;
       
       RETURN handleDs.path;
      /END-FREE
     P GetFilePath     E

      *=====================================================================
      * Procedure: FileExists
      * Purpose: Check if file exists
      *=====================================================================
     P FileExists      B                   EXPORT
     D FileExists      PI              N
     D   path                       256A   CONST VARYING
      *
     D rc              S             10I 0
      *
      /FREE
       rc = stat(%TRIM(path): %ADDR(statDs));
       RETURN (rc = 0);
      /END-FREE
     P FileExists      E

      *=====================================================================
      * End of JSONFILE
      *=====================================================================