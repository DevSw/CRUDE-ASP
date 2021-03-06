<%@ LANGUAGE="VBSCRIPT" CODEPAGE="1255" %>
<!--#include file="dist/asp/inc_config.asp" -->
<%' use this meta tag instead of adovbs.inc%>
<!--METADATA TYPE="typelib" uuid="00000205-0000-0010-8000-00AA006D2EA4" -->
<%
Response.CodePage = 1255
Session.CodePage = 1255

' Local Constants
'=======================
Const constPageScriptName = "admin_dataviewfields.asp"
Dim strPageTitle
strPageTitle = "Manage Data View Fields"

' Init Variables
'=======================
Dim nItemID, strMode, nCount, nIndex

' Open DB Connection
'=======================
adoConn.Open
%><!--#include file="dist/asp/inc_crudeconstants.asp" --><%
Dim strFieldLabel, strFieldSource, strDataViewTitle, nViewID, strDefaultValue, strUriPath, strLinkedTable, strLinkedTableGroupField
Dim strLinkedTableTitleField, strLinkedTableAddition, strLinkedTableValueField, nFlags, nFieldType, nOrdering
Dim nUriStyle, nMaxLength, nWidth, nHeight, strFieldDescription
    
strMode = Request("mode")
nItemID = Request("ItemID")
IF NOT IsNumeric(nItemID) THEN nItemID = ""
nViewID = Request("ViewID")
IF NOT IsNumeric(nViewID) THEN nItemID = ""

    
IF nViewID <> "" AND IsNumeric(nViewID) THEN
	strSQL = "SELECT Title FROM portal.DataView WHERE ViewID = " & nViewID
	rsItems.Open strSQL, adoConn
	IF NOT rsItems.EOF THEN
		strDataViewTitle = rsItems("Title")
	Else
		nViewID = ""
	END IF
	rsItems.Close
END IF

IF nViewID = "" OR NOT IsNumeric(nViewID) THEN Response.Redirect("admin_dataviews.asp?MSG=notfound")
strPageTitle = strPageTitle & " for " & strDataViewTitle
strFieldLabel = Request("FieldLabel")
strFieldSource = Request("FieldSource")
nFieldType = Request("FieldType")
IF nFieldType = "" OR NOT IsNumeric(nFieldType) THEN nFieldType = 1
strFieldDescription = Request("FieldDescription")
strDefaultValue = Request("DefaultValue")
strUriPath = Request("UriPath")
nUriStyle = Request("UriStyle")
IF nUriStyle = "" OR NOT IsNumeric(nUriStyle) THEN nUriStyle = 1
strLinkedTable = Request("LinkedTable")
strLinkedTableGroupField = Request("LinkedTableGroupField")
strLinkedTableTitleField = Request("LinkedTableTitleField")
strLinkedTableValueField = Request("LinkedTableValueField")
strLinkedTableAddition = Request("LinkedTableAddition")
nMaxLength = Request("MaxLength")
IF nMaxLength = "" OR NOT IsNumeric(nMaxLength) THEN nMaxLength = 100
nWidth = Request("Width")
IF nWidth = "" OR NOT IsNumeric(nWidth) THEN nWidth = 0
nHeight = Request("Height")
IF nHeight = "" OR NOT IsNumeric(nHeight) THEN nHeight = 0
nFlags = 0

For nIndex = 1 TO Request.Form("FieldFlags").Count
    nFlags= nFlags + CInt(Request.Form("FieldFlags")(nIndex))
Next

IF Request.Form("FieldLabel") <> "" THEN
	
	IF strMode = "add" THEN
		strSQL = "SELECT TOP 1 FieldOrder FROM portal.DataViewField WHERE ViewID = " & nViewID & " ORDER BY FieldOrder DESC"
        SET rsItems = Server.CreateObject("ADODB.Recordset")
		rsItems.Open strSQL, adoConn
		IF NOT rsItems.EOF THEN
			nOrdering = rsItems("FieldOrder") + 1
		Else
			nOrdering = 1
		END IF
		rsItems.Close
        SET rsItems = Nothing
    END IF

    strSQL = "SELECT * FROM portal.DataViewField WHERE "
    IF strMode = "add" THEN
        strSQL = strSQL & "1=2"
    ELSEIF strMode ="edit" AND nItemID <> "" AND IsNumeric(nItemID) THEN
        strSQL = strSQL & "FieldID = " & nItemID
    ELSE
        strError = "Invalid input!"
        strSQL = ""
    END IF

	IF strSQL <> "" THEN
        SET rsItems = Server.CreateObject("ADODB.Recordset")
        rsItems.CursorLocation = adUseClient
        rsItems.CursorType = adOpenKeyset
        rsItems.LockType = adLockOptimistic
        rsItems.Open strSQL, adoConn
    
        IF strMode = "add" THEN
            rsItems.AddNew
            rsItems("FieldOrder") = nOrdering
        END IF

        IF strMode = "edit" AND rsItems.EOF THEN
            strError = "Item Not Found<br/>"
            rsItems.Close    
        ELSE
            rsItems("ViewID") = nViewID
            rsItems("FieldLabel") = strFieldLabel
            rsItems("FieldSource") = strFieldSource
            rsItems("FieldType") = nFieldType
            rsItems("FieldDescription") = strFieldDescription
            rsItems("DefaultValue") = strDefaultValue
            rsItems("UriPath") = strUriPath
            rsItems("UriStyle") = nUriStyle
            rsItems("LinkedTable") = strLinkedTable
            rsItems("LinkedTableGroupField") = strLinkedTableGroupField
            rsItems("LinkedTableTitleField") = strLinkedTableTitleField
            rsItems("LinkedTableValueField") = strLinkedTableValueField
            rsItems("LinkedTableAddition") = strLinkedTableAddition
            rsItems("FieldFlags") = nFlags
            rsItems("MaxLength") = nMaxLength
            rsItems("Width") = nWidth
            rsItems("Height") = nHeight 
    
            ON ERROR RESUME NEXT
    
            rsItems.Update
            rsItems.Close   
            
            ON ERROR GOTO 0
        END IF

        ' check for errors
        If adoConn.Errors.Count > 0 Then
            DIM Err
            strError = strError & " Error(s) while performing &quot;" & strMode & "&quot;:<br/>" 
            For Each Err In adoConn.Errors
			    strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
            Next
            IF globalIsAdmin THEN strError = strError & "While trying to run:<br/><b>" & strSQL & "</b>"
        End If
	
	    IF strError = "" THEN 
            adoConn.Close
	        Response.Redirect(constPageScriptName & "?ViewID=" & nViewID & "&MSG=" & strMode)
        END IF
	END IF

ELSEIF strMode = "sortFields" THEN
	strSQL = "SELECT FieldID, FieldOrder FROM portal.DataViewField WHERE ViewID = " & nViewID
    SET rsItems = Server.CreateObject("ADODB.Recordset")
    rsItems.Open strSQL, adoConn

    WHILE NOT rsItems.EOF
		IF Request.Form("sort_" & rsItems("FieldID")) <> "" AND IsNumeric(Request.Form("sort_" & rsItems("FieldID"))) THEN
			adoConn.Execute "UPDATE portal.DataViewField SET FieldOrder = " & Request("sort_" & rsItems("FieldID")) & _
							" WHERE FieldID = " & rsItems("FieldID")
        END IF

        rsItems.MoveNext
    WEND
    rsItems.Close
    SET rsItems = Nothing

	adoConn.Close
	SET adoConn = Nothing
	
	Response.Redirect(constPageScriptName & "?ViewID=" & nViewID & "&MSG=sorted")

ELSEIF strMode = "autoinit" THEN
		
	adoConn.Execute "EXEC portal.AutoInitDataViewFields @ViewID = " & nViewID & ";"
	
	adoConn.Close
	SET adoConn = Nothing
	
	Response.Redirect(constPageScriptName & "?ViewID=" & nViewID & "&MSG=autoinit")

ELSEIF strMode = "delete" AND nItemID <> "" THEN
		
	adoConn.Execute "DELETE FROM portal.DataViewField WHERE FieldID = " & nItemID
	
	adoConn.Close
	SET adoConn = Nothing
	
	Response.Redirect(constPageScriptName & "?ViewID=" & nViewID & "&MSG=delete")
END IF
%>
<!DOCTYPE html>
<html>
<head>
  <title><%= GetPageTitle() %></title>
<!--#include file="dist/asp/inc_meta.asp" -->
</head>
<body class="<%= globalBodyClass %>">
<div class="wrapper">
<!--#include file="dist/asp/inc_header.asp" -->

  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <%= strPageTitle %>
      </h1>

      <ol class="breadcrumb">
        <li><a href="default.asp"><i class="fas fa-tachometer-alt"></i> Home</a></li>
        <li><a href="admin_dataviews.asp?mode=edit&ItemID=<%= nViewID %>"> <%= Sanitizer.HTMLDisplay(strDataViewTitle) %></a></li>
        <li class="active"><%= Sanitizer.HTMLDisplay(strPageTitle) %></li>
      </ol>

    </section>

    <!-- Main content -->
    <section class="content container-fluid">

<div class="row">
    <div class="col col-sm-12">
        <a class="btn btn-primary" role="button" href="admin_dataviews.asp?mode=edit&ItemID=<%= nViewID %>"><i class="fas fa-edit"></i> Edit Data View</a>
        &nbsp;
        <a role="button" href="dataview.asp?ViewID=<%= nViewID %>" class="btn btn-primary"><i class="fas fa-eye"></i> Open Data View</a>
    </div>
</div>

<div class="row">
<%
SET rsItems = Server.CreateObject("ADODB.Recordset")

IF (strMode = "edit" AND nItemID <> "") OR strMode = "add" Then

IF strMode = "edit" AND nItemID <> "" Then
	strSQL = "SELECT * FROM portal.DataViewField WHERE FieldID = " & nItemID
	rsItems.Open strSQL, adoConn
	IF NOT rsItems.EOF THEN
		strFieldLabel = rsItems("FieldLabel")
		strFieldSource = rsItems("FieldSource")
        nFieldType = rsItems("FieldType")
        strFieldDescription = rsItems("FieldDescription")
		strDefaultValue = rsItems("DefaultValue")
		nFlags = rsItems("FieldFlags")
        strLinkedTable = rsItems("LinkedTable")
        strLinkedTableGroupField = rsItems("LinkedTableGroupField")
		strLinkedTableTitleField = rsItems("LinkedTableTitleField")
		strLinkedTableValueField = rsItems("LinkedTableValueField")
		strLinkedTableAddition = rsItems("LinkedTableAddition")
        strUriPath = rsItems("UriPath")
        nUriStyle = rsItems("UriStyle")
        nMaxLength = rsItems("MaxLength")
        nWidth = rsItems("Width")
        nHeight = rsItems("Height")
	END IF
	rsItems.Close
ELSE
	nFlags = 1
	strMode = "add"
END IF
%>

<!-- Update/Insert Form -->
<div class="col-md-10 col-lg-8">
    <br />
<div class="panel panel-primary">
<div class="box-header with-border">
    <h3 class="box-title">
        <% IF strMode = "edit" AND nItemID <> "" THEN Response.Write "Edit" ELSE Response.Write "Add" %> Data View Field

    </h3>
    <!-- tools box -->
    <div class="pull-right box-tools">
    <a role="button" class="btn btn-primary btn-sm" title="Cancel" href="<%= constPageScriptName %>?ViewID=<%= nViewID %>"><i class="fas fa-times"></i></a>
    </div>
    <!-- /. tools -->
</div>
<form class="form-horizontal" action="<%= constPageScriptName %>" method="post">
    <div class="panel-body">
    <div class="form-group">
        <label for="inputFieldLabel" class="col-sm-3 col-md-3 col-lg-2 control-label">Field Label</label>

        <div class="col-sm-9 col-md-9 col-lg-10">
        <input type="text" class="form-control" id="inputFieldLabel" data-toggle="tooltip" title="The field label displayed to the users" placeholder="FieldLabel" name="FieldLabel" value="<%= Sanitizer.HTMLFormControl(strFieldLabel) %>" required="required">
        </div>
    </div>
    <div class="form-group">
        <label for="inputFieldSource" class="col-sm-3 col-md-3 col-lg-2 control-label">Field Source</label>

        <div class="col-sm-9 col-md-9 col-lg-10">
        <input type="text" class="form-control" id="inputFieldSource" data-toggle="tooltip" title="The actual column name from the database" placeholder="Field Source Column" name="FieldSource" value="<%= Sanitizer.HTMLFormControl(strFieldSource) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputFieldType" class="col-sm-3 col-md-3 col-lg-2 control-label">Field Type</label>

        <div class="col-sm-9 col-md-9 col-lg-10">
            <select class="form-control" id="inputFieldType" name="FieldType">
                <% FOR nIndex = 0 TO UBound(arrDataViewFieldTypes,2) %>
                <option value="<%= arrDataViewFieldTypes(dvftValue, nIndex) %>" <% IF CStr(arrDataViewFieldTypes(dvftValue, nIndex)) = CStr(nFieldType) THEN Response.Write "selected='selected'" %>>
                    <%= arrDataViewFieldTypes(dvftLabel,nIndex) %>
                </option>
                <% NEXT %>
            </select>
        </div>
    </div>
    <div class="form-group">
        <label for="inputFieldDescription" class="col-sm-3 col-md-3 col-lg-2 control-label">Tooltip</label>

        <div class="col-sm-9 col-md-9 col-lg-10">
        <input type="text" class="form-control" id="inputFieldDescription" data-toggle="tooltip" title="The tooltip text displayed to users (kinda like this one, actually)" placeholder="Field Tooltip" name="FieldDescription" value="<%= Sanitizer.HTMLFormControl(strFieldDescription) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputDefaultValue" class="col-sm-3 col-md-3 col-lg-2 control-label">Default Value</label>

        <div class="col-sm-9 col-md-9 col-lg-10">
        <input type="text" class="form-control" id="inputDefaultValue" data-toggle="tooltip" title="The default value automatically filled out when adding a new item" placeholder="Default Value" name="DefaultValue" value="<%= Sanitizer.HTMLFormControl(strDefaultValue) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputMaxLength" class="col-sm-3 col-md-3 col-lg-2 control-label">Max Length</label>

        <div class="col-sm-9 col-md-9 col-lg-10">
        <input type="number" min="0" step="1" class="form-control" data-toggle="tooltip" title="Relevant to textual field types such as Text, Password, Email and Phone" id="inputMaxLength" placeholder="Max Length" name="MaxLength" value="<%= Sanitizer.HTMLFormControl(nMaxLength) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputWidth" class="col-sm-3 col-md-3 col-lg-2 control-label">Width</label>

        <div class="col-sm-9 col-md-9 col-lg-10">
        <input type="number" min="0" step="1" class="form-control" id="inputWidth" data-toggle="tooltip" title="Horizontal width of the input" placeholder="Width" name="Width" value="<%= Sanitizer.HTMLFormControl(nWidth) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputHeight" class="col-sm-3 col-md-3 col-lg-2 control-label">Height</label>

        <div class="col-sm-9 col-md-9 col-lg-10">
        <input type="number" min="0" step="1" class="form-control" id="inputHeight" data-toggle="tooltip" title="Vertical height of the input (relevant only to Text Area and Multi-Selection box)" placeholder="Height" name="Height" value="<%= Sanitizer.HTMLFormControl(nHeight) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputUriPath" class="col-sm-3 col-md-3 col-lg-2 control-label">Link URI</label>

        <div class="col-sm-9 col-md-9 col-lg-10">
        <input type="text" class="form-control" id="inputUriPath" placeholder="Link URI Path" data-toggle="tooltip" title="Provide a URL to make the field clickable in the items list" name="UriPath" value="<%= Sanitizer.HTMLFormControl(strUriPath) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputUriStyle" class="col-sm-3 col-md-3 col-lg-2 control-label">Link Style</label>

        <div class="col-sm-9 col-md-9 col-lg-10">
            <select class="form-control" id="inputUriStyle" name="UriStyle" data-toggle="tooltip" title="Choose how the link would look like">
                <% FOR nIndex = 0 TO UBound(arrDataViewUriStyles,2) %><option value="<%= arrDataViewUriStyles(dvusValue, nIndex) %>" <% IF arrDataViewUriStyles(dvusValue, nIndex) = nUriStyle THEN Response.Write "selected" %>><%= arrDataViewUriStyles(dvusLabel,nIndex) %></option>
                <% NEXT %>
            </select>
        </div>
    </div>
    <div class="form-group">
        <label for="inputLinkedTable" class="col-sm-3 col-md-3 col-lg-2 control-label">Linked Table</label>

        <div class="col-sm-9 col-md-9 col-lg-10">
        <input type="text" class="form-control" id="inputLinkedTable" data-toggle="tooltip" title="Used for Dropdown and Multi-Selection Box" placeholder="Linked Table Name" name="LinkedTable" value="<%= Sanitizer.HTMLFormControl(strLinkedTable) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputLinkedTableGroupField" class="col-sm-3 col-md-3 col-lg-2 control-label">Linked Table Group Field</label>

        <div class="col-sm-9 col-md-9 col-lg-10">
        <input type="text" class="form-control" id="inputLinkedTableGroupField" data-toggle="tooltip" title="Used for Dropdown and Multi-Selection Box" placeholder="Linked Table Group Field Column" name="LinkedTableGroupField" value="<%= Sanitizer.HTMLFormControl(strLinkedTableGroupField) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputLinkedTableTitleField" class="col-sm-3 col-md-3 col-lg-2 control-label">Linked Table Title Field</label>

        <div class="col-sm-9 col-md-9 col-lg-10">
        <input type="text" class="form-control" id="inputLinkedTableTitleField" data-toggle="tooltip" title="Used for Dropdown and Multi-Selection Box" placeholder="Linked Table Title Field Column" name="LinkedTableTitleField" value="<%= Sanitizer.HTMLFormControl(strLinkedTableTitleField) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputLinkedTableValueField" class="col-sm-3 col-md-3 col-lg-2 control-label">Linked Table Value Field</label>

        <div class="col-sm-9 col-md-9 col-lg-10">
        <input type="text" class="form-control" id="inputLinkedTableValueField" data-toggle="tooltip" title="Used for Dropdown and Multi-Selection Box" placeholder="Linked Table Value Column" name="LinkedTableValueField" value="<%= Sanitizer.HTMLFormControl(strLinkedTableValueField) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputLinkedTableAddition" class="col-sm-3 col-md-3 col-lg-2 control-label">Linked Table Addition</label>

        <div class="col-sm-9 col-md-9 col-lg-10">
        <textarea class="form-control" id="inputLinkedTableAddition" name="LinkedTableAddition" data-toggle="tooltip" title="Used for Dropdown and Multi-Selection Box" placeholder="Linked Table Addition" height="4"><%= Sanitizer.HTMLFormControl(strLinkedTableAddition) %></textarea>
        </div>
    </div>
    <div class="form-group">
        <label for="inputFlags" class="col-sm-3 col-md-3 col-lg-2 control-label">Properties</label>
        
        <div class="col-sm-9 col-md-9 col-lg-10">
        <% FOR nIndex = 0 TO UBound(arrDataViewFieldFlags, 2) %>
        <div class="checkbox">
            <label>
            <input type="checkbox" name="FieldFlags" value="<%= arrDataViewFieldFlags(dvffValue, nIndex) %>" <% IF (arrDataViewFieldFlags(dvffValue, nIndex) AND nFlags) > 0 THEN Response.Write "checked" %> /> 
                <i class="<%= arrDataViewFieldFlags(dvffGlyph, nIndex) %>"></i> <%= arrDataViewFieldFlags(dvffLabel, nIndex) %>
            </label>
        </div>
        <% NEXT %>
        </div>
    </div>
    </div>
    <!-- /.panel-body -->
    <div class="panel-footer">
    <input type="hidden" name="ItemID" value="<%= nItemID %>" />
    <input type="hidden" name="ViewID" value="<%= nViewID %>" />
    <input type="hidden" name="mode" value="<%= strMode %>" />

    <a class="btn btn-default" role="button" href="<%= constPageScriptName %>?ViewID=<%= nViewID %>">Cancel</a>

    <button type="submit" class="btn btn-success pull-right">Submit</button>
    </div>
    <!-- /.panel-footer -->
</form>
</div>
</div>
<!-- /.update-insert-form -->
<% END IF %>
</div>
        <!-- Items List -->
        
<form name="frmFieldSorting" action="<%= constPageScriptName %>?ViewID=<%= nViewID %>" method="post">
<div class="row">
    <div class="col col-sm-12"><br />
        <button type="submit" class="btn btn-primary btn-sm"><i class="fas fa-sort-amount-down"></i> Update Sorting</button>
        &nbsp;
        <a class="btn btn-primary btn-sm" role="button" href="<%= constPageScriptName %>?mode=add&ViewID=<%= nViewID %>"><i class="fas fa-plus"></i> Add Field</a>
    </div>
</div>

<table class="table table-hover">
<tr>
    <th>Order</th>
    <th>Title</th>
    <th>Source Column</th>
    <th>Type</th>
    <th>Properties</th>
    <th>Actions</th>
</tr>
<tbody>
<%
Set rsItems = Server.CreateObject("ADODB.Recordset")
strSQL = "SELECT * FROM portal.DataViewField WHERE ViewID = " & nViewID & " ORDER BY FieldOrder ASC"
rsItems.Open strSQL, adoConn

Dim arrRows, nTotalRows
nTotalRows = 0

IF rsItems.EOF THEN %>
    <tr><td align="center" colspan="6">No fields were set for this data view.<br /><a href="<%= constPageScriptName %>?ViewID=<%= nViewID %>&mode=autoinit" class="btn btn-primary">Click here to auto-create fields based on table schema</a>.</td></tr><%
ELSE
    arrRows = rsItems.GetRows()
    nTotalRows = UBound(arrRows, 2)
    rsItems.MoveFirst
END IF 

WHILE NOT rsItems.EOF

%><tr>
    <td><select class="form-control" name="sort_<%= rsItems("FieldID") %>"><% FOR nIndex = 0 TO nTotalRows %>
        <option value="<%= nIndex + 1 %>" <% IF nIndex + 1 = rsItems("FieldOrder") THEN Response.Write "selected" %>><%= nIndex + 1 %></option>
        <% NEXT %>
        </select></td>
    <th><%= Sanitizer.HTMLDisplay(rsItems("FieldLabel")) %></th>
    <td><%= Sanitizer.HTMLDisplay(rsItems("FieldSource")) %></td>
    <td><%= arrDataViewFieldTypes(dvftLabel,rsItems("FieldType") - 1) %></td>
    <td>
        <% FOR nIndex = 0 TO UBound(arrDataViewFieldFlags, 2)
            IF (rsItems("FieldFlags") AND arrDataViewFieldFlags(dvffValue, nIndex)) THEN %>
        <b data-toggle="tooltip" title="<%= arrDataViewFieldFlags(dvffLabel, nIndex) %>"><i class="<%= arrDataViewFieldFlags(dvffGlyph, nIndex) %>"></i></b>
        &nbsp;
        <% END IF
            NEXT %>
    </td>
    <td>
        <a data-toggle="tooltip" title="Edit" class="btn btn-primary" href="<%= constPageScriptName %>?mode=edit&ViewID=<%= nViewID %>&ItemID=<%= rsItems("FieldID") %>"><i class="fas fa-edit"></i> Edit</a>
        &nbsp;
        <a data-toggle="tooltip" title="Delete" class="btn btn-primary" href="<%= constPageScriptName %>?mode=delete&ViewID=<%= nViewID %>&ItemID=<%= rsItems("FieldID") %>"><i class="far fa-trash-alt"></i> Delete</a>
    </td>
  </tr>
    <% 
    rsItems.MoveNext
WEND %>
</tbody>
</table>
<input type="hidden" name="mode" value="sortFields" />
</form>

    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->

<!--#include file="dist/asp/inc_footer.asp" -->
</div>
<!-- ./wrapper -->

<!-- REQUIRED JS SCRIPTS -->
<!--#include file="dist/asp/inc_footer_jscripts.asp" -->

<!-- AdminLTE App -->
<script src="dist/js/adminlte.min.js"></script>

<!-- Optionally, you can add Slimscroll and FastClick plugins.
     Both of these plugins are recommended to enhance the
     user experience. -->
</body>
</html>