# Property of Four Js*
# (c) Copyright Four Js 2018, 2018. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
# 
# Four Js and its suppliers do not warrant or guarantee that these
# samples are accurate and suitable for your purposes. Their inclusion is
# purely for information purposes only.

# Cordova echo demo, using the fglcdvGeneroTestPlugin module

IMPORT FGL fgldialog
IMPORT FGL fglcdvGeneroTestPlugin

MAIN
  DEFINE echo STRING
  CALL fglcdvGeneroTestPlugin.initialize()
  LET echo=fglcdvGeneroTestPlugin.stringEcho("Hello world")
  MESSAGE echo
  MENU
    COMMAND "info"
      CALL fgldialog.fgl_winMessage("Plugin Information",fglcdvGeneroTestPlugin.getPluginInfo(),"information")
    COMMAND "exit"
      EXIT MENU
  END MENU
END MAIN
