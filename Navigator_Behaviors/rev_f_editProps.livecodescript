﻿script "rev_f_editProps"
local sProp -- stores the name of the property we're working on
local sWhichLine -- stores the number of the line we're working on

function truncateString S,L
   if L < 6 then return char 1 to L of S
   if length(S) > L then return (char 1 to L - 3 of S) & "..."
   return S
end truncateString

on mouseDown
   put word 2 of the clickline into sWhichLine
   if sWhichLine is empty or the text of me is empty then exit mouseDown
   put line sWhichLine of me into tLineData
   set the itemDelimiter to tab
   put item 1 of tLineData into sProp
   put item 2 of tLineData into tVal
   set the itemDelimiter to comma
   --cSourceID
   if item 1 of the mouseLoc < 125 and the cObjectCount of me > 1 then
      -- do values popup here
      put the cSourceID of me into tSourceID
      put the cCustomProperties of me into customPropertyB
      put the cCustomPropertySet of me into pCustomPropertySet
      if customPropertyB 
      then put value(merge("the [[pCustomPropertySet]][ [[quote]][[sProp]][[quote]]] of [[tSourceID]]")) into tIDVal
      else put the sProp of tSourceID into tIDVal
      if not customPropertyB and tIDVal is empty then put the effective sProp of tSourceID into tIDVal
      put tSourceID into valToID[tIDVal]
      put truncateString(tIDVal,30) into tIDtoVal[tSourceID]
      put -1 into tIDAddCount[tSourceID]
      repeat for each line tID in the cIDList of me
         if customPropertyB 
         then put value(merge("the [[pCustomPropertySet]][ [[quote]][[sProp]][[quote]]] of [[tID]]")) into tIDVal
         else put the sProp of tID into tIDVal
         if not customPropertyB and tIDVal is empty then put the effective sProp of tID into tIDVal
         if valToID[tIDVal] is empty then 
            put tID into valToID[tIDVal]
            put truncateString(tIDVal,30) into tIDtoVal[tID]
            put 0 into tIDAddCount[tID]
         else
            add 1 to tIDAddCount[valToID[tIDVal]]
         end if
      end repeat
      put the name of tSourceID & iff(tIDAddCount[tSourceID] > 0," +" & tIDAddCount[tSourceID],"") && tIDtoVal[tSourceID] into tMenu
      delete variable tIDtoVal[tSourceID]
      put the keys of tIDtoVal into keyList
      sort lines of keyList
      
      repeat for each line K in keyList
         put cr & the name of K & iff(tIDAddCount[K] > 0," +" & tIDAddCount[K],"") && tIDtoVal[K] after tMenu
      end repeat
      dispatch "doSetup" to btn "propListPopup" with false,sProp,(tSourceID & cr & keyList),customPropertyB,(the cCustomPropertySet of me)
      put tMenu into btn "propListPopup"
      popup btn "propListPopup"
   else if the cCustomProperties of me is true then 
      exit mouseDown
   else
      if sProp = "textFont" then
         put the fontNames into propOptionList
         replace "(" with "\(" in propOptionList
         sort lines of propOptionList
      end if
      if propOptionList is empty then
         put "u" & sProp into tCProp
         put "u" & word 1 of the cSourceID of me & sProp into tTypeCProp
         put the tTypeCProp of fld "editProps" of stack "revNavigator" into propOptionList
         if propOptionList is empty then put the tCProp of fld "editProps" of stack "revNavigator" into propOptionList
      end if
      if propOptionList is empty then exit mouseDown
      put propOptionList into btn "propListPopup"
      dispatch "doSetup" to btn "propListPopup" with true
      popup btn "propListPopup"
   end if
end mouseDown


on mouseUp
   put word 2 of the clickline into sWhichLine
   if sWhichLine is empty or the text of me is empty then exit mouseUp
   put the cSourceID of me into tSourceID
   put line sWhichLine of me into tLineData
   set the itemDelimiter to tab
   put item 1 of tLineData into sProp
   put item 2 of tLineData into tVal
   if the cCustomProperties of me is not true then
      if sProp is "colors" then
         dispatch "editColors" to group "setColors" with tSourceID,(the cIDList of me)
      else if char -5 to -1 of sProp is "color" then
         answer color with item 2 of tLineData
         if the result is empty then 
            setValue it 
         end if
      else if tVal is among the words of "true false" then
         setValue not tVal
      else if sProp is among the lines of the oneLiners of stack "revNavigator" then
         if sProp is "name" then put the short name of tSourceID into tVal else put the sProp of tSourceID into tVal
         dispatch "editValue" to fld "PropEditor" with sWhichLine,tVal
      else
         put true into showEditor
      end if
      if not showEditor then exit mouseUp
   end if
   
   set the uID of group "editContents" to the long id of me
   put the cSourceID of me into tID
   
   if the cCustomProperties of me is true then 
      --set the customPropertySet of tID to (the cCustomPropertySet of me)
      put the cCustomPropertySet of me into pCustomPropertySet
      put value(merge("the [[pCustomPropertySet]][ [[quote]][[sProp]][[quote]]] of [[tID]]")) into tDefaultVal
   else
      put the sProp of tID into tDefaultVal
   end if
   set the uDialogText of group "editContents" to tDefaultVal
   dispatch "showMe" to group "editContents" with true,(sProp is "htmlText"),(the cCustomProperties of me is false and sProp is among the lines of the oneLiners of stack "revNavigator")
   
   --put value(the clickline)
end mouseUp

on resultMessage pText
   if pText is empty then 
      if sProp is "htmlText" then put the htmlText of fld "setContents" into pText
      else put fld "setContents" into pText
   end if
   setValue pText
end resultMessage

on setValue pText
   put the cCustomPropertySet of me into pCustomPropertySet
   if the cCustomProperties of me is true then
      repeat for each line tID in the cIDList of me
         do merge("set the [[pCustomPropertySet]][ [[quote]][[sProp]][[quote]]] of [[tID]] to [[pText]]")
      end repeat
   else
      repeat for each line tID in the cIDList of me
         add 1 to typeList[word 1 of tID]
         
         set the sProp of tID to pText
      end repeat
      setRecentProp (the keys of typeList),sProp
   end if
   set the itemDelimiter to tab
   put line 1 of pText into item 2 of line sWhichLine of me
   updateDisplay ,true
end setValue

on scrollbardrag
   if the vis of fld "propEditor" then dispatch "setRect" to fld "propEditor"
end scrollbardrag
