#
#       (c) Copyright Four Js 2018. 
#
#                                 MIT License
#

#+ Genero BDL wrapper around the Genero Test Plugin.
OPTIONS SHORT CIRCUIT
IMPORT util
IMPORT os
IMPORT FGL fgldialog
# defines GIT_VERSION and GIT_COMMIT_ID and is created during the build process
&include "git_version.txt"
CONSTANT _CALL="call"
CONSTANT CDV="cordova"
CONSTANT GT="GeneroTestPlugin"
PUBLIC TYPE TestType RECORD
  str STRING,
  i INT,
  b BOOLEAN,
  test STRING
END RECORD

#+ Initializes the plugin
#+ must be called prior other calls
PUBLIC FUNCTION initialize()
  IF ui.Interface.getFrontEndName()=="GMI" AND
      versionBiggerOrEqual(ui.Interface.getFrontEndVersion(),'1.30.13') THEN
    CALL checkGitVersion(GIT_VERSION,GIT_COMMIT_ID)
  END IF
END FUNCTION

#+ Splits a given version string (separated by dots) into a dynamic ARRAY 
#+ @param version - a version number like '1.30.15'
#+
#+ @return the version numbers in an array
PRIVATE FUNCTION splitNumbers(version STRING) RETURNS DYNAMIC ARRAY OF INT
  DEFINE arr DYNAMIC ARRAY OF INT
  DEFINE tok base.StringTokenizer
  LET tok=base.StringTokenizer.create(version,".")
  WHILE tok.hasMoreTokens()
    LET arr[arr.getLength()+1]=tok.nextToken()
    IF arr.getLength()==3 THEN
      EXIT WHILE
    END IF
  END WHILE
  RETURN arr
END FUNCTION

#+ checks if a clients version number is bigger or equal to a given version number
#+
#+ @param version - a version number like '1.30.15'
#+ @param compare_version - a version number like '1.30.01'
#+ @return TRUE if version>=compare version
PRIVATE FUNCTION versionBiggerOrEqual(version STRING,compare_version STRING) RETURNS BOOLEAN
  DEFINE idx INT
  DEFINE internal BOOLEAN
  DEFINE arr,comp DYNAMIC ARRAY OF INT
  LET comp=splitNumbers(compare_version)
  DISPLAY "version:",version
  --cut the git describe part for internal versions
  IF (idx:=version.getIndexOf("-",1))>0 THEN
    LET version=version.subString(1,idx-1)
    LET internal=TRUE
  END IF
  LET arr=splitNumbers(version)
  LET idx=1
  WHILE idx<=arr.getLength() AND idx<=comp.getLength()
    --DISPLAY sfmt("idx:%1,a:%2,comp:%3",idx,arr[idx],comp[idx])
    CASE
      WHEN idx==3
        IF internal THEN
          --pretending being one maintenance version ahead if internal
          LET arr[3]=arr[3]+1
        END IF
        IF (arr[3]>=comp[3]) THEN
          RETURN TRUE
        ELSE
          RETURN FALSE
        END IF
      WHEN arr[idx]>comp[idx]
        RETURN TRUE
      WHEN arr[idx]<comp[idx]
        RETURN FALSE
    END CASE
    LET idx=idx+1
  END WHILE
  RETURN FALSE
END FUNCTION


#+ Checks if this wrappers git version is equal to the version
#+ of the native plugin.
#+ The program is stopped if the versions do not match
#+
#+ @param gitver - a version number like 'gm_1.30.15'
PRIVATE FUNCTION checkGitVersion(git_version STRING,git_commit_id STRING)
  DEFINE rec RECORD
    git_version STRING,
    git_commit_id STRING
  END RECORD
  DEFINE msg STRING
  CALL ui.interface.frontcall("cordova","getPluginInfo",["GeneroTestPlugin"],[rec])
  --if the commit id is equal then no activity is required
  IF git_commit_id.equals(rec.git_commit_id) THEN
    DISPLAY "git_commit_id equal"
    RETURN
  END IF
  LET msg=sfmt("Version mismatch, actual git commit id of the native plugin:%1, expected:%2.\n(Git tag version native plugin:%3 , wrapper:%4)",rec.git_commit_id,git_commit_id,rec.git_version,git_version)
  DISPLAY "Error in fglcvdGeneroTestPlugin.4gl:",msg
  CALL fgl_winmessage("Error in fglcdvGeneroTestPlugin.4gl",msg,"error")
  EXIT PROGRAM 1
END FUNCTION

FUNCTION stringEcho(in STRING) RETURNS STRING
   DEFINE out STRING
   CALL ui.interface.frontcall(CDV,_CALL, [GT,"stringEcho",in],[out])
   RETURN out
END FUNCTION

FUNCTION testRecord(in TestType) RETURNS TestType
   DEFINE out TestType
   CALL ui.interface.frontcall(CDV,_CALL, [GT,"testRecord",in],[out])
   RETURN out.*
END FUNCTION

FUNCTION getPluginInfo() RETURNS STRING
  DEFINE out STRING
  CALL ui.interface.frontcall("cordova","getPluginInfo",[GT],[out])
  RETURN out
END FUNCTION
